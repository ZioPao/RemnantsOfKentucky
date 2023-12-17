local TextureScreen = require("ROK/UI/BaseComponents/TextureScreen")
local LootRecapHandler = require("ROK/Match/LootRecapHandler")
local RecapScrollItemsPanel = require("ROK/UI/AfterMatch/RecapScrollItemsPanel")
--------------

---@class RecapPanel : TextureScreen
---@field text string
---@field textX number
---@field textY number
---@field isClosing boolean
---@field closingTime number
RecapPanel = TextureScreen:derive("RecapPanel")

---@return RecapPanel
function RecapPanel:new()
    ---@type RecapPanel
    local o = TextureScreen:new()
    setmetatable(o, self)
    self.__index = self
    o.backgroundTexture = getTexture("media/textures/ROK_RecapScreen.png")

    ---@cast o RecapPanel
    RecapPanel.instance = o
    return o
end

function RecapPanel:createChildren()
    TextureScreen.createChildren(self)

    --TODO List of items that the player has extracted

    local scaleX = 6.50847457627119
    local scaleY = 7.3469387755102

    local dimX = 1.45015105740181
    local dimY = 1.31067961165049

    debugPrint(self.width)
    debugPrint(self.height)

    local x = self.width/scaleX
    local y = self.height/scaleY

    local widthPanel = self.width/dimX
    local heightPanel = self.height/dimY

    self.mainContainerPanel = ISPanel:new(x, y, widthPanel, heightPanel)
    self:addChild(self.mainContainerPanel)

    local marginX = 10
    local marginY = 10
    self.itemsBox = RecapScrollItemsPanel:new(marginX, marginY, self.mainContainerPanel.width/1.5, self.mainContainerPanel.height - marginY*2)
    self.itemsBox:initalise()
    self.mainContainerPanel:addChild(self.itemsBox)

    --TODO List of players that the current player has killed
end


function RecapPanel.OnSpacePressed(key)
    if key ~= Keyboard.KEY_SPACE then return end
    RecapPanel.Close()
end
Events.OnKeyStartPressed.Add(RecapPanel.OnSpacePressed)

---comment
---@param list table<string, {actualItem : Item, fullType : string}>
function RecapPanel.SetupItemsList(list)
    if RecapPanel.instance == nil then return end
    RecapPanel.instance.itemsBox:initialiseList(list)
end

Events.PZEFT_LootRecapReady.Add(RecapPanel.SetupItemsList)


function RecapPanel:close()
    TextureScreen.close(self)
    RecapPanel.instance = nil
end
-----

local Delay = require("ROK/Delay")

function RecapPanel.Open()
    if not isClient() then return end       -- SP workaround
    if getPlayer():isDead() then return end -- Workaround to prevent issues when player is dead
    if RecapPanel.instance ~= nil then return end
    debugPrint("Opening recap screen")
    local recapScreen = RecapPanel:new()
    recapScreen:initialise()

    -- TODO Just for test
    Delay:set(2, function ()
        LootRecapHandler.CompareWithOldInventory()
    end)
    recapScreen:addToUIManager()
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

--return RecapPanel