-- TODO Add review after extraction for players
local TextureScreen = require("ROK/UI/BaseComponents/TextureScreen")
local BaseScrollItemsPanel = require("ROK/UI/BaseComponents/BaseScrollItemsPanel")
--------------

---@class RecapPanel : TextureScreen
---@field text string
---@field textX number
---@field textY number
---@field isClosing boolean
---@field closingTime number
local RecapPanel = TextureScreen:derive("RecapPanel")

---@return LoadingScreen
function RecapPanel:new()
    local o = TextureScreen:new()
    setmetatable(o, self)
    self.__index = self
    o.backgroundTexture = getTexture("media/textures/ROK_RecapScreen.png")

    ---@cast o LoadingScreen
    RecapPanel.instance = o
    return o
end

function RecapPanel:createChildren()
    TextureScreen.createChildren(self)

    --TODO List of items that the player has extracted
    self.itemsBox = BaseScrollItemsPanel:new(500, 500, 500, 500)
    self.itemsBox:initalise()
    self:addChild(self.itemsBox)


    --TODO List of players that the current player has killed
end
-----

function RecapPanel.Open()
    if not isClient() then return end       -- SP workaround
    if getPlayer():isDead() then return end -- Workaround to prevent issues when player is dead
    if LoadingScreen.instance ~= nil then return end
    debugPrint("Opening black screen")
    local loadginScreen = LoadingScreen:new()
    loadginScreen:initialise()
    loadginScreen:addToUIManager()
end

function RecapPanel.Close()
    if RecapPanel.instance then
        debugPrint("black screen instance available, closing")
        RecapPanel.instance:startFade()
    end
end

function RecapPanel.HandleResolutionChange(oldW, oldH, w, h)
    if RecapPanel.instance then
        RecapPanel.instance:setWidth(w)
        RecapPanel.instance:setHeight(h)
    end
end

Events.OnResolutionChange.Add(RecapPanel.HandleResolutionChange)

return RecapPanel