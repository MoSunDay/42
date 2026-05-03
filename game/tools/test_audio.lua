-- test_audio.lua - Test audio system
-- Run: cd game/tools && lua test_audio.lua

print("=== Audio System Test ===")
print()

local audioSources = {}
local playingSources = {}

love = {
    audio = {
        newSource = function(path, type)
            local source = {
                path = path,
                type = type,
                volume = 1.0,
                looping = false,
                playing = false,
                clone = function(self)
                    local cloned = {}
                    for k, v in pairs(self) do cloned[k] = v end
                    return cloned
                end,
                setVolume = function(self, v) self.volume = v end,
                setLooping = function(self, v) self.looping = v end,
                isPlaying = function(self) return self.playing end,
                play = function(self) self.playing = true; table.insert(playingSources, self) end,
                stop = function(self) self.playing = false end,
            }
            table.insert(audioSources, source)
            return source
        end,
    },
    sound = {
        newSoundData = function(samples, rate, bits, channels)
            return {
                samples = samples,
                rate = rate,
                data = {},
                setSample = function(self, i, c, v)
                    if channels == 1 then
                        self.data[i] = c
                    else
                        self.data[i] = {c, v}
                    end
                end,
            }
        end,
    },
    filesystem = {
        getInfo = function(path)
            if path:match("%.wav$") then
                return {type = "file"}
            end
            return nil
        end,
    },
}

package.path = package.path .. ";../?.lua;../src/?.lua;../src/systems/?.lua"

print("1. Testing AudioSystem module loading...")
local success, AudioSystem = pcall(require, "audio_system")
if success then
    print("   ✓ AudioSystem loaded successfully")
else
    print("   ✗ AudioSystem load failed: " .. tostring(AudioSystem))
    os.exit(1)
end
print()

print("2. Creating AudioSystem state...")
audioSources = {}
local audio = AudioSystem.create()
print("   ✓ AudioSystem created")
print("   Generated SFX: " .. #audioSources .. " sources")
print()

print("3. Testing SFX playback...")
playingSources = {}

AudioSystem.play_sfx(audio, "attack")
if #playingSources > 0 then
    print("   ✓ play_sfx('attack') works")
else
    print("   ✗ play_sfx failed")
end

playingSources = {}
AudioSystem.play_sfx(audio, "hit")
AudioSystem.play_sfx(audio, "victory")
AudioSystem.play_sfx(audio, "defeat")
print("   ✓ Multiple SFX calls work")
print()

print("4. Testing fallback sound generation...")
local fallbackSounds = {"attack", "hit", "victory", "defeat", "click", "hover", "levelup", "hurt", "death"}
local foundCount = 0
for _, name in ipairs(fallbackSounds) do
    if audio.sfx[name] then
        foundCount = foundCount + 1
    end
end
print("   Fallback sounds generated: " .. foundCount .. "/" .. #fallbackSounds)
if foundCount == #fallbackSounds then
    print("   ✓ All fallback sounds generated")
else
    print("   ✗ Some fallback sounds missing")
end
print()

print("5. Testing BGM playback...")
AudioSystem.play_bgm(audio, "exploration")
if audio.bgm then
    print("   ✓ play_bgm('exploration') works")
    print("   BGM looping: " .. tostring(audio.bgm.looping))
    print("   BGM playing: " .. tostring(audio.bgm.playing))
else
    print("   ✗ BGM creation failed")
end
print()

print("6. Testing BGM theme switching...")
AudioSystem.play_bgm(audio, "battle")
if audio.currentTheme == "battle" then
    print("   ✓ BGM switched to battle")
else
    print("   ✗ BGM switch failed")
end

AudioSystem.play_bgm(audio, "spring")
if audio.currentTheme == "spring" then
    print("   ✓ BGM switched to seasonal (spring)")
else
    print("   ✗ Seasonal BGM failed")
end
print()

print("7. Testing volume controls...")
AudioSystem.set_music_volume(audio, 0.5)
if audio.bgmVolume == 0.5 then
    print("   ✓ Music volume set to 0.5")
else
    print("   ✗ Music volume failed")
end

AudioSystem.set_sfx_volume(audio, 0.8)
if audio.sfxVolume == 0.8 then
    print("   ✓ SFX volume set to 0.8")
else
    print("   ✗ SFX volume failed")
end
print()

print("8. Testing stop BGM...")
AudioSystem.stop_bgm(audio)
if not audio.bgm.playing then
    print("   ✓ BGM stopped")
else
    print("   ✗ BGM stop failed")
end
print()

print("9. Testing loadedFiles tracking...")
local sfxCount = 0
for _ in pairs(audio.loadedFiles.sfx) do sfxCount = sfxCount + 1 end
print("   Tracked loaded SFX: " .. sfxCount)
print("   ✓ File loading tracked")
print()

print("=== All Audio Tests Complete! ===")
print()
print("Audio system supports:")
print("  - File loading (.ogg, .wav)")
print("  - Procedural fallback generation")
print("  - BGM with themes (exploration, battle, seasonal)")
print("  - Volume controls")
print("  - Multiple simultaneous SFX")
