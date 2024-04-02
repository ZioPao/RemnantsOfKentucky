local TextureScreen = require("ROK/UI/BaseComponents/TextureScreen")
local RecapScrollItemsPanel = require("ROK/UI/AfterMatch/RecapScrollItemsPanel")
local RecapScrollKilledPlayersPanel = require("ROK/UI/AfterMatch/RecapScrollKilledPlayersPanel")
local LootRecapHandler = require("ROK/Match/LootRecapHandler")
--------------

local screens = {
    [1] = getTexture("media/textures/RecapScreen/1.png"),
    [2] = getTexture("media/textures/RecapScreen/2.png"),
    [3] = getTexture("media/textures/RecapScreen/3.png"),
    [4] = getTexture("media/textures/RecapScreen/4.png"),
    [5] = getTexture("media/textures/RecapScreen/5.png"),
}


---@class RecapPanel : TextureScreen
---@field text string
---@field textX number
---@field textY number
---@field isClosing boolean
---@field closingTime number
---@field itemsList table
local RecapPanel = TextureScreen:derive("RecapPanel")

---@return RecapPanel
function RecapPanel:new()
    ---@type RecapPanel
    local o = TextureScreen:new()
    setmetatable(o, self)
    self.__index = self

    local i = ZombRand(#screens) + 1
    o.backgroundTexture = screens[i]

    ---@cast o RecapPanel
    RecapPanel.instance = o
    return o
end

function RecapPanel:createChildren()
    TextureScreen.createChildren(self)


    -- Scaling calculated for 16:9 screens
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
    self.mainContainerPanel.backgroundColor = {r=0,g=0,b=0,a=0}
    self:addChild(self.mainContainerPanel)



    local labelHeight = getTextManager():MeasureStringY(UIFont.Large, "Extracted Items")*2

    debugPrint(labelHeight)

    local marginX = 10
    local marginY = 10
    local boxHeight = self.mainContainerPanel.height - labelHeight - (marginY*2)

    -- List of items that the player has extracted
    -- TODO Add translation

    local itemsWidth = self.mainContainerPanel.width/1.5

    self.itemsLabel = ISRichTextPanel:new(marginX, marginY, itemsWidth, labelHeight)
    self.itemsLabel.backgroundColor = {r=0,g=0,b=0,a=1}
    self.itemsLabel.borderColor = {r=1,g=1,b=1,a=1}
    self.itemsLabel:setText("<SIZE:large> Extracted Items")
	self.itemsLabel:initialise()
    self.itemsLabel:paginate()
    self.mainContainerPanel:addChild(self.itemsLabel)

    self.itemsBox = RecapScrollItemsPanel:new(marginX, marginY + labelHeight, itemsWidth, boxHeight)
    self.itemsBox:initalise()
    self.mainContainerPanel:addChild(self.itemsBox)

    if self.itemsList then
        self.itemsBox:initialiseList(self.itemsList)
    end


    -- List of players that the current player has killed
    -- TODO Add translation
    local remainingX = self.itemsBox:getWidth()
    local killedPlayersWidth = self.mainContainerPanel:getWidth() - self.itemsBox:getWidth() - marginX


    self.killsLabel = ISRichTextPanel:new(remainingX, marginY, killedPlayersWidth, labelHeight)
    self.killsLabel.backgroundColor = {r=0,g=0,b=0,a=1}
    self.killsLabel.borderColor = {r=1,g=1,b=1,a=1}
    self.killsLabel:setText("<SIZE:large> Kills")
	self.killsLabel:initialise()
    self.killsLabel:paginate()
    self.mainContainerPanel:addChild(self.killsLabel)


    self.killedPlayersBox = RecapScrollKilledPlayersPanel:new(remainingX, marginY + labelHeight, killedPlayersWidth, boxHeight)
    self.killedPlayersBox:initialise()
    self.mainContainerPanel:addChild(self.killedPlayersBox)

end

function RecapPanel:setItemsList(list)
    self.itemsList = list
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
    RecapPanel.instance:setItemsList(list)
    RecapPanel.instance.itemsBox:initialiseList(list)
end

--Events.PZEFT_LootRecapReady.Add(RecapPanel.SetupItemsList)

function RecapPanel:prerender()

    TextureScreen.prerender(self)
    local alpha = 0.8 - self.closingTime

    --debugPrint("Setting alpha to itemsBox and killerPlayerBox to " .. tostring(alpha))

    if alpha < 0 then alpha = 0 end

    self.itemsBox.scrollingListBox.backgroundColor.a = alpha
    self.killedPlayersBox.scrollingListBox.backgroundColor.a = alpha

end


function RecapPanel:close()
    debugPrint("Closing RecapPanel")
    TextureScreen.close(self)
    RecapPanel.instance = nil
end
-----


function RecapPanel.Open()
    if getPlayer():isDead() then return end -- Workaround to prevent issues when player is dead
    if RecapPanel.instance ~= nil then return end
    debugPrint("Opening recap screen")
    local lootedItems = LootRecapHandler.CompareWithOldInventory()


    local recapScreen = RecapPanel:new()
    recapScreen:setItemsList(lootedItems)
    recapScreen:initialise()
    recapScreen:addToUIManager()
end

function RecapPanel.Close()
    if RecapPanel.instance then
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