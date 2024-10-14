local Map = {}
local STI = require("sti")
local Enemy = require("enemy")
local Spike = require("spike")
local Stone = require("stone")
local Coin = require("coin")
local Player = require("player")
local Trampoline = require("trampoline")
local Sounds = require("sounds")
local Hitbox = require("hitbox")
local NicoRobin = require("nicoRobin")

local oceanHighBackground = love.graphics.newImage("assets/oceanBackground.png")
local skyBlueBackground = love.graphics.newImage("assets/background.png")

function Map:load()
    self.currentLevel = 1
    self.firstLevel = 1
    self.lastLevel = 4
    self.backgroundLevels = { -- self.background[i] == background for that level
        oceanHighBackground,
        skyBlueBackground,
        skyBlueBackground,
        oceanHighBackground
    }
    World = love.physics.newWorld(0, 2000)
    World:setCallbacks(beginContact, endContact)

    self:init()
end

function Map:init()
    self.level = STI("map/"..self.currentLevel..".lua", { "box2d" })
    self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity
    self.spawnsLayer = self.level.layers.spawns

    self.solidLayer.visible = false
    self.entityLayer.visible = false
    MapWidth = self.groundLayer.width * 16 -- 16 is the tile size
    MapHeight = self.groundLayer.height * 16

    self:findSpawnPoints()
    self:spawnEntities()
    self:loadBgm()
end

--change background according to what level
function Map:drawBackground()
    local background = self.backgroundLevels[self.currentLevel]
    love.graphics.draw(background)
end

function Map:loadBgm()
    Sounds:playMusic(self.currentLevel)
end

function Map:findSpawnPoints()
    for _, v in ipairs(self.spawnsLayer.objects) do
        if v.type == "end" then
            self.endX, self.endY = v.x, v.y
        elseif v.type == "start" then
            self.startX, self.startY = v.x, v.y
        end
    end
end

function Map:next()
    self:clean()
    self.currentLevel = self.currentLevel + 1
    self:init()
    Map.loadPlayer(self.startX, self.startY)
end

function Map:prev()
    self:clean()
    self.currentLevel = self.currentLevel - 1
    self:init()
    Map.loadPlayer(self.endX, self.endY)
end

function Map.loadPlayer(x, y)
    Player:setPosition(x, y)
    Hitbox.loadAllTargets(ActiveEnemys)
end

function Map:clean()
    self.level:box2d_removeLayer("solid")
    Coin.removeAll()
    Spike.removeAll()
    Stone.removeAll()
    Enemy.removeAll()
    Trampoline.removeAll()
end

function Map:update(dt)
    -- conditions to swap level
    if self.currentLevel ~= self.lastLevel and Player.x > MapWidth - 16 then
        self:next()
    elseif self.currentLevel ~= self.firstLevel and Player.x < 0 + 16 then
        self:prev()
    end
end

function Map:spawnEntities()
    for _, v in ipairs(self.entityLayer.objects) do
        if v.type == "spike" then
            Spike.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "coin" then
            Coin.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "stone" then
            Stone.new(v.x, v.y)
        elseif v.type == "enemy" then
            Enemy.new(v.x, v.y)
        elseif v.type == "trampoline" then
            Trampoline.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "nicoRobin" then
            NicoRobin.new(v.x + v.width / 2, v.y + v.height / 2)
        end
    end
end

return Map