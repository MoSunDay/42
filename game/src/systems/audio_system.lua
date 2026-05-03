-- audio_system.lua - Audio management system
-- Handles background music and sound effects

local EnhancedAudio = require("src.systems.enhanced_audio")

local AudioSystem = {}

local SFX_PATHS = {
    combat = {
        attack = {"assets/sounds/sfx/combat/attack.ogg", "assets/sounds/sfx/combat/attack.wav"},
        hit = {"assets/sounds/sfx/combat/hit.ogg", "assets/sounds/sfx/combat/hit.wav"},
        critical = {"assets/sounds/sfx/combat/critical.ogg", "assets/sounds/sfx/combat/critical.wav"},
        block = {"assets/sounds/sfx/combat/block.ogg", "assets/sounds/sfx/combat/block.wav"},
        dodge = {"assets/sounds/sfx/combat/dodge.ogg", "assets/sounds/sfx/combat/dodge.wav"},
        skill = {"assets/sounds/sfx/combat/skill.ogg", "assets/sounds/sfx/combat/skill.wav"},
        victory = {"assets/sounds/sfx/combat/victory.ogg", "assets/sounds/sfx/combat/victory.wav"},
        defeat = {"assets/sounds/sfx/combat/defeat.ogg", "assets/sounds/sfx/combat/defeat.wav"}
    },
    ui = {
        click = {"assets/sounds/sfx/ui/click.ogg", "assets/sounds/sfx/ui/click.wav"},
        hover = {"assets/sounds/sfx/ui/hover.ogg", "assets/sounds/sfx/ui/hover.wav"},
        open = {"assets/sounds/sfx/ui/open.ogg", "assets/sounds/sfx/ui/open.wav"},
        close = {"assets/sounds/sfx/ui/close.ogg", "assets/sounds/sfx/ui/close.wav"},
        pickup = {"assets/sounds/sfx/ui/pickup.ogg", "assets/sounds/sfx/ui/pickup.wav"},
        equip = {"assets/sounds/sfx/ui/equip.ogg", "assets/sounds/sfx/ui/equip.wav"},
        levelup = {"assets/sounds/sfx/ui/levelup.ogg", "assets/sounds/sfx/ui/levelup.wav"}
    },
    character = {
        hurt = {"assets/sounds/sfx/character/hurt.ogg", "assets/sounds/sfx/character/hurt.wav"},
        death = {"assets/sounds/sfx/character/death.ogg", "assets/sounds/sfx/character/death.wav"}
    }
}

local BGM_PATHS = {
    exploration = {"assets/sounds/bgm/exploration.ogg", "assets/sounds/bgm/exploration.wav"},
    battle = {"assets/sounds/bgm/battle.ogg", "assets/sounds/bgm/battle.wav"},
    town = {"assets/sounds/bgm/town.ogg", "assets/sounds/bgm/town.wav"},
    spring = {"assets/sounds/bgm/seasonal/spring.ogg", "assets/sounds/bgm/seasonal/spring.wav"},
    summer = {"assets/sounds/bgm/seasonal/summer.ogg", "assets/sounds/bgm/seasonal/summer.wav"},
    autumn = {"assets/sounds/bgm/seasonal/autumn.ogg", "assets/sounds/bgm/seasonal/autumn.wav"},
    winter = {"assets/sounds/bgm/seasonal/winter.ogg", "assets/sounds/bgm/seasonal/winter.wav"}
}

function AudioSystem.create()
    local state = {}

    state.bgm = nil
    state.bgmVolume = 0.3
    state.currentTheme = nil
    state.sfx = {}
    state.sfxVolume = 0.7
    state.loadedFiles = { sfx = {}, bgm = {} }

    AudioSystem.load_sound_files(state)

    return state
end

function AudioSystem.load_sound_files(state)
    local loadedCount = 0

    for category, sounds in pairs(SFX_PATHS) do
        for name, paths in pairs(sounds) do
            for _, path in ipairs(paths) do
                if love.filesystem.getInfo(path) then
                    local success, source = pcall(love.audio.newSource, path, "static")
                    if success then
                        state.sfx[name] = source
                        state.loadedFiles.sfx[name] = true
                        loadedCount = loadedCount + 1
                        break
                    end
                end
            end
        end
    end

    AudioSystem.generate_fallback_sounds(state)

    if loadedCount > 0 then
    else
    end
end

function AudioSystem.generate_fallback_sounds(state)
    local defaults = {
        attack = {0.1, 440},
        hit = {0.08, 220},
        critical = {0.15, 880},
        block = {0.1, 330},
        dodge = {0.08, 550},
        skill = {0.2, 660},
        victory = {0.3, 523},
        defeat = {0.5, 165},
        click = {0.05, 600},
        hover = {0.03, 800},
        open = {0.1, 500},
        close = {0.08, 400},
        pickup = {0.1, 700},
        equip = {0.15, 450},
        levelup = {0.4, 880},
        hurt = {0.15, 200},
        death = {0.5, 150}
    }

    for name, params in pairs(defaults) do
        if not state.sfx[name] then
            state.sfx[name] = AudioSystem.create_beep(state, params[1], params[2])
        end
    end
end

-- Create a simple beep sound
function AudioSystem.create_beep(state, duration, frequency)
    local sampleRate = 44100
    local samples = math.floor(sampleRate * duration)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sampleRate
        -- Simple sine wave with envelope
        local envelope = 1 - (i / samples)  -- Fade out
        local value = math.sin(2 * math.pi * frequency * t) * envelope * 0.3
        soundData:setSample(i, value)
    end

    return love.audio.newSource(soundData, "static")
end

function AudioSystem.play_bgm(state, mode)
    if state.currentTheme == mode and state.bgm and state.bgm:isPlaying() then
        return
    end

    if state.bgm then
        state.bgm:stop()
    end

    local bgmPaths = BGM_PATHS[mode]
    if bgmPaths then
        for _, path in ipairs(bgmPaths) do
            if love.filesystem.getInfo(path) then
                local success, source = pcall(love.audio.newSource, path, "stream")
                if success then
                    state.bgm = source
                    state.loadedFiles.bgm[mode] = true
                    break
                end
            end
        end
    end

    if not state.bgm then
        state.bgm = AudioSystem.generate_procedural_bgm(state, mode)
    end

    if state.bgm then
        state.bgm:setLooping(true)
        state.bgm:setVolume(state.bgmVolume)
        state.bgm:play()
        state.currentTheme = mode
    end
end

function AudioSystem.generate_procedural_bgm(state, mode)
    if mode == "battle" then
        return EnhancedAudio.generate_battle_bgm(8.0)
    elseif mode == "spring" or mode == "summer" or mode == "autumn" or mode == "winter" then
        return EnhancedAudio.generate_seasonal_bgm(mode, 8.0)
    else
        return EnhancedAudio.generate_bgm("exploration", 8.0)
    end
end

-- Create a harmony melody (chords)
function AudioSystem.create_harmony_melody(state, chords, noteDuration)
    local sampleRate = 44100
    local totalDuration = #chords * noteDuration
    local samples = math.floor(sampleRate * totalDuration)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for chordIndex, chord in ipairs(chords) do
        local noteStart = math.floor((chordIndex - 1) * noteDuration * sampleRate)
        local noteEnd = math.floor(chordIndex * noteDuration * sampleRate)

        for i = noteStart, noteEnd - 1 do
            if i < samples then
                local t = (i - noteStart) / sampleRate
                local noteProg = (i - noteStart) / (noteEnd - noteStart)

                -- ADSR envelope (Attack, Decay, Sustain, Release)
                local envelope
                if noteProg < 0.1 then
                    -- Attack
                    envelope = noteProg / 0.1
                elseif noteProg < 0.3 then
                    -- Decay
                    envelope = 1 - (noteProg - 0.1) / 0.2 * 0.3
                elseif noteProg < 0.8 then
                    -- Sustain
                    envelope = 0.7
                else
                    -- Release
                    envelope = 0.7 * (1 - (noteProg - 0.8) / 0.2)
                end

                -- Mix all notes in the chord
                local value = 0
                for _, frequency in ipairs(chord) do
                    -- Add harmonics for richer sound
                    value = value + math.sin(2 * math.pi * frequency * t) * 0.4
                    value = value + math.sin(2 * math.pi * frequency * 2 * t) * 0.1  -- Octave
                end

                value = value * envelope * 0.08
                soundData:setSample(i, value)
            end
        end
    end

    return love.audio.newSource(soundData, "static")
end

-- Play sound effect
function AudioSystem.play_sfx(state, name)
    if state.sfx[name] then
        local sfx = state.sfx[name]:clone()
        sfx:setVolume(state.sfxVolume)
        sfx:play()
    end
end

-- Stop background music
function AudioSystem.stop_bgm(state)
    if state.bgm then
        state.bgm:stop()
    end
end

-- Set music volume
function AudioSystem.set_music_volume(state, volume)
    state.bgmVolume = math.max(0, math.min(1, volume))
    if state.bgm then
        state.bgm:setVolume(state.bgmVolume)
    end
end

-- Set SFX volume
function AudioSystem.set_sfx_volume(state, volume)
    state.sfxVolume = math.max(0, math.min(1, volume))
end

return AudioSystem
