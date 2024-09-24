local Sounds = {}

function Sounds:load()

    self.soundToggle = true

    self.bgm = {}
    self.bgm.maxSound = 0.3
    self.bgm.OathHeart = love.audio.newSource("assets/bgm/OathOfTheHeart_inazumaElevenOST.mp3", "stream")
    self.bgm.NakamaNoShirushi = love.audio.newSource("assets/bgm/One Piece OST - Nakama no Shirushi da! Sign Of Friendship.mp3", "stream")

    self.sfx = {}
    self.sfx.maxSound = 0.3
    self.sfx.playerGetCoin = love.audio.newSource("assets/sfx/player_get_coin.ogg", "static")
    self.sfx.playerHit = love.audio.newSource("assets/sfx/frankyOW.mp3", "static")
    self.sfx.frankyEyeCatchTheme = love.audio.newSource("assets/sfx/frankyEyeCatchTheme.mp3", "static")
    self.sfx.playerJump = love.audio.newSource("assets/sfx/player_jump.ogg", "static")

    -- clear profiles necessary => {name, source}
    self.bgmLevels = {
        {"OathHeart", self.bgm.OathHeart},
        {"OathHeart", self.bgm.OathHeart},
        {"OathHeart", self.bgm.OathHeart},
        {"NakamaNoShirushi", self.bgm.NakamaNoShirushi}
    }
    self.currentlyPlayingBgm = self.bgmLevels[1]
    self.currentlyPlayingBgm[2]:play()
    
    self.currentVolume = self.bgm.maxSound
    self.currentlyPlayingBgm[2]:setVolume(self.currentVolume)
end

function Sounds:update(dt)
    if not self.currentlyPlayingBgm[2]:isPlaying() then
        self.playSound(self.currentlyPlayingBgm[2])
    end
    if self.soundToggle and self.currentVolume == 0 then
        self:maxSound(self.currentlyPlayingBgm[2])
    end
end

function Sounds:muteSound(sound)
    sound:setVolume(0)
    self.currentVolume = 0
end

function Sounds:maxSound(sound)
    sound:setVolume(self.bgm.maxSound)
    self.currentVolume = self.bgm.maxSound
end

function Sounds:playMusic(level)
    print("level: "..level..tostring(self.currentlyPlayingBgm))
    for i, bgm in ipairs(self.bgmLevels) do
        if i == level and bgm[1] ~= self.currentlyPlayingBgm[1] then
            self.currentlyPlayingBgm[2]:stop()
            self.playSound(self.bgmLevels[level][2])
            if self.currentVolume == 0 then
                self:muteSound(self.bgmLevels[level][2])
            end
            self.currentlyPlayingBgm = self.bgmLevels[level]
        end
    end
end

-- helper function to make code more legible. Allows sounds to be played repeatedly
function Sounds.playSound(sound)
    sound:stop()
    sound:play()
end

return Sounds