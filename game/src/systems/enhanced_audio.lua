-- enhanced_audio.lua - Enhanced music generation
-- More melodic and harmonious background music

local EnhancedAudio = {}

-- Musical scales and chords
local SCALES = {
    -- C Major scale (happy, bright)
    c_major = {261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25},
    
    -- A Minor scale (melancholic, mysterious)
    a_minor = {220.00, 246.94, 261.63, 293.66, 329.63, 349.23, 392.00, 440.00},
    
    -- Pentatonic scale (Asian, peaceful)
    pentatonic = {261.63, 293.66, 329.63, 392.00, 440.00},
    
    -- Battle scale (intense, dramatic)
    battle = {220.00, 233.08, 261.63, 277.18, 311.13, 329.63, 369.99, 392.00}
}

-- Chord progressions
local PROGRESSIONS = {
    exploration = {
        {1, 3, 5},  -- I chord
        {6, 1, 3},  -- vi chord
        {4, 6, 1},  -- IV chord
        {5, 7, 2}   -- V chord
    },
    battle = {
        {1, 3, 5},  -- i chord
        {4, 6, 1},  -- iv chord
        {5, 7, 2},  -- v chord
        {1, 3, 5}   -- i chord
    }
}

-- Generate enhanced BGM
function EnhancedAudio.generateBGM(theme, duration)
    local sampleRate = 44100
    local samples = math.floor(sampleRate * duration)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 2)  -- Stereo
    
    local scale, progression
    
    if theme == "exploration" or theme == "spring" or theme == "summer" then
        scale = SCALES.c_major
        progression = PROGRESSIONS.exploration
    elseif theme == "battle" then
        scale = SCALES.battle
        progression = PROGRESSIONS.battle
    elseif theme == "autumn" then
        scale = SCALES.pentatonic
        progression = PROGRESSIONS.exploration
    elseif theme == "winter" then
        scale = SCALES.a_minor
        progression = PROGRESSIONS.exploration
    else
        scale = SCALES.c_major
        progression = PROGRESSIONS.exploration
    end
    
    -- Generate melody with harmony
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local value = 0
        
        -- Determine current chord
        local chordIndex = math.floor((t / duration) * #progression) + 1
        if chordIndex > #progression then
            chordIndex = #progression
        end
        local chord = progression[chordIndex]
        
        -- Melody (main voice)
        local melodyNote = scale[chord[1]]
        local melody = math.sin(2 * math.pi * melodyNote * t)
        
        -- Harmony (chord tones)
        local harmony1 = math.sin(2 * math.pi * scale[chord[2]] * t) * 0.5
        local harmony2 = math.sin(2 * math.pi * scale[chord[3]] * t) * 0.3
        
        -- Bass (root note, one octave lower)
        local bass = math.sin(2 * math.pi * (melodyNote / 2) * t) * 0.4
        
        -- ADSR envelope
        local attack = 0.05
        local decay = 0.1
        local sustain = 0.7
        local release = 0.2
        
        local noteTime = t % 1.0  -- Each note lasts 1 second
        local envelope = 1.0
        
        if noteTime < attack then
            envelope = noteTime / attack
        elseif noteTime < attack + decay then
            envelope = 1.0 - (1.0 - sustain) * ((noteTime - attack) / decay)
        elseif noteTime < 1.0 - release then
            envelope = sustain
        else
            envelope = sustain * (1.0 - (noteTime - (1.0 - release)) / release)
        end
        
        -- Combine all voices
        value = (melody + harmony1 + harmony2 + bass) * envelope * 0.15
        
        -- Add slight stereo effect
        local leftValue = value * (1.0 + math.sin(t * 0.5) * 0.1)
        local rightValue = value * (1.0 - math.sin(t * 0.5) * 0.1)
        
        -- Clamp values
        leftValue = math.max(-1, math.min(1, leftValue))
        rightValue = math.max(-1, math.min(1, rightValue))

        -- Love2D uses 1-based channel indexing for stereo (1=left, 2=right)
        soundData:setSample(i, leftValue, rightValue)
    end
    
    return love.audio.newSource(soundData)
end

-- Generate battle music (more intense)
function EnhancedAudio.generateBattleBGM(duration)
    local sampleRate = 44100
    local samples = math.floor(sampleRate * duration)
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 2)
    
    local scale = SCALES.battle
    local tempo = 2.0  -- Faster tempo
    
    for i = 0, samples - 1 do
        local t = i / sampleRate
        local value = 0
        
        -- Fast arpeggio pattern
        local noteIndex = math.floor(t * tempo * 4) % #scale + 1
        local freq = scale[noteIndex]
        
        -- Main melody with octave
        local melody = math.sin(2 * math.pi * freq * t)
        local octave = math.sin(2 * math.pi * freq * 2 * t) * 0.3
        
        -- Driving bass
        local bassFreq = scale[1] / 2
        local bass = math.sin(2 * math.pi * bassFreq * t) * 0.6
        
        -- Percussion-like rhythm
        local rhythm = 0
        if math.floor(t * 4) % 2 == 0 then
            rhythm = math.sin(2 * math.pi * 100 * t) * 0.2 * math.exp(-10 * (t % 0.25))
        end
        
        -- Quick envelope
        local noteTime = (t * tempo) % 0.5
        local envelope = math.exp(-noteTime * 3)
        
        -- Combine
        value = (melody * envelope + octave * envelope + bass + rhythm) * 0.2
        
        -- Stereo panning
        local pan = math.sin(t * 2)
        local leftValue = value * (1.0 - pan * 0.3)
        local rightValue = value * (1.0 + pan * 0.3)
        
        leftValue = math.max(-1, math.min(1, leftValue))
        rightValue = math.max(-1, math.min(1, rightValue))

        soundData:setSample(i, leftValue, rightValue)
    end
    
    return love.audio.newSource(soundData)
end

-- Generate seasonal music
function EnhancedAudio.generateSeasonalBGM(season, duration)
    if season == "spring" then
        return EnhancedAudio.generateBGM("spring", duration)
    elseif season == "summer" then
        return EnhancedAudio.generateBGM("summer", duration)
    elseif season == "autumn" then
        return EnhancedAudio.generateBGM("autumn", duration)
    elseif season == "winter" then
        return EnhancedAudio.generateBGM("winter", duration)
    else
        return EnhancedAudio.generateBGM("exploration", duration)
    end
end

return EnhancedAudio

