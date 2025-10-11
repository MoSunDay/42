-- audio_system.lua - Audio management system
-- Handles background music and sound effects

local AudioSystem = {}
AudioSystem.__index = AudioSystem

function AudioSystem.new()
    local self = setmetatable({}, AudioSystem)
    
    -- Music
    self.bgm = nil
    self.bgmVolume = 0.5
    
    -- Sound effects
    self.sfx = {}
    self.sfxVolume = 0.7
    
    -- Generate procedural sounds
    self:generateSounds()
    
    return self
end

-- Generate procedural sound effects
function AudioSystem:generateSounds()
    -- We'll use simple beep sounds for now
    -- In a real game, you'd load actual sound files
    
    -- Attack sound (simple beep)
    self.sfx.attack = self:createBeep(0.1, 440)  -- A4 note
    
    -- Hit sound
    self.sfx.hit = self:createBeep(0.08, 220)  -- A3 note
    
    -- Victory sound
    self.sfx.victory = self:createBeep(0.3, 523)  -- C5 note
    
    -- Defeat sound
    self.sfx.defeat = self:createBeep(0.5, 165)  -- E3 note
    
    print("  - Generated procedural sound effects")
end

-- Create a simple beep sound
function AudioSystem:createBeep(duration, frequency)
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

-- Play background music
function AudioSystem:playBGM(mode)
    -- Stop current music
    if self.bgm then
        self.bgm:stop()
    end

    -- Generate background music with better melodies
    if mode == "exploration" then
        -- Peaceful exploration melody (C major scale with harmony)
        -- C - E - G - E - F - D - E - C (I - III - V - III - IV - II - III - I)
        self.bgm = self:createHarmonyMelody({
            {262, 330, 392},  -- C major chord
            {330, 392, 523},  -- E minor chord
            {392, 494, 587},  -- G major chord
            {330, 392, 523},  -- E minor chord
            {349, 440, 523},  -- F major chord
            {294, 370, 440},  -- D minor chord
            {330, 392, 523},  -- E minor chord
            {262, 330, 392},  -- C major chord
        }, 0.6)
    elseif mode == "battle" then
        -- Intense battle melody (A minor with tension)
        -- A - C - D - E - D - C - B - A
        self.bgm = self:createHarmonyMelody({
            {440, 523, 659},  -- A minor chord
            {523, 659, 784},  -- C major chord
            {587, 698, 880},  -- D major chord
            {659, 784, 988},  -- E minor chord
            {587, 698, 880},  -- D major chord
            {523, 659, 784},  -- C major chord
            {494, 587, 740},  -- B diminished
            {440, 523, 659},  -- A minor chord
        }, 0.45)
    end

    if self.bgm then
        self.bgm:setLooping(true)
        self.bgm:setVolume(self.bgmVolume)
        self.bgm:play()
    end
end

-- Create a harmony melody (chords)
function AudioSystem:createHarmonyMelody(chords, noteDuration)
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
function AudioSystem:playSFX(name)
    if self.sfx[name] then
        local sfx = self.sfx[name]:clone()
        sfx:setVolume(self.sfxVolume)
        sfx:play()
    end
end

-- Stop background music
function AudioSystem:stopBGM()
    if self.bgm then
        self.bgm:stop()
    end
end

-- Set music volume
function AudioSystem:setMusicVolume(volume)
    self.bgmVolume = math.max(0, math.min(1, volume))
    if self.bgm then
        self.bgm:setVolume(self.bgmVolume)
    end
end

-- Set SFX volume
function AudioSystem:setSFXVolume(volume)
    self.sfxVolume = math.max(0, math.min(1, volume))
end

-- Update (for any time-based audio effects)
function AudioSystem:update(dt)
    -- Nothing to update for now
end

return AudioSystem

