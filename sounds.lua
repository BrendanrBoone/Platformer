local Sounds = {}

function Sounds:load()

    self.bgm = {}
    self.bgm.OathHeart = love.audio.newSource("assets/bgm/OathOfTheHeart_inazumaElevenOST.mp3", "stream")
    self.bgm.NakamaNoShirushi = love.audio.newSource("assets/bgm/One Piece OST - Nakama no Shirushi da! Sign Of Friendship.mp3", "stream")

    self.sfx = {}
    self.sfx.playerGetCoin = love.audio.newSource("assets/sfx/player_get_coin.ogg", "static")
    self.sfx.playerHit = love.audio.newSource("assets/sfx/player_hit.ogg", "static")
    self.sfx.playerJump = love.audio.newSource("assets/sfx/player_jump.ogg", "static")

    self.bgmLevels = {
        self.bgm.OathHeart,
        self.bgm.OathHeart,
        self.bgm.OathHeart,
        self.bgm.NakamaNoShirushi
    }
    self.currentlyPlayingBgm = self.bgmLevels[1]
    self.currentlyPlayingBgm:play()
end

function Sounds:update(dt)

end

function Sounds:playMusic(level)
    for i, bgm in ipairs(self.bgmLevels) do
        if i == level and bgm ~= self.currentlyPlayingBgm then
            print("play music")
            self.currentlyPlayingBgm:stop()
            self.playSound(self.bgmLevels[level])
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