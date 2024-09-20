local Sounds = {}

-- helper function to make code more legible. Allows sounds to be played repeatedly
function Sounds.playSound(sound)
    sound:stop()
    sound:play()
end

return Sounds