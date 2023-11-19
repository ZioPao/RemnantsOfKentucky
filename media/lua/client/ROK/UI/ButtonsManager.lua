require "ROK/ClientState"
local BeforeMatchAdminPanel = require("ROK/UI/BeforeMatch/BeforeMatchAdminPanel")
local DuringMatchAdminPanel = require("ROK/UI/DuringMatch/DuringMatchAdminPanel")
----------------

-- Override ISSafetyUI to have a instance of that so we can reference it later
local og_ISSafetyUI = ISSafetyUI.new

function ISSafetyUI:new(x, y, playerNum)
    local o = og_ISSafetyUI(self, x, y, playerNum)
    ISSafetyUI.instance = o

    return o
end

-----------------------------

local BUTTONS = {
    "Leaderboard", "AdminPanel"
}


BUTTONS_DATA_TEXTURES = {}
for i = 1, #BUTTONS do
    local btn = BUTTONS[i]
    BUTTONS_DATA_TEXTURES[btn] = {}
    BUTTONS_DATA_TEXTURES[btn].ON = getTexture("media/textures/" .. btn .. "_on.png")
    BUTTONS_DATA_TEXTURES[btn].OFF = getTexture("media/textures/" .. btn .. "_off.png")
end


ButtonManager = {}
ButtonManager.firstInit = true
ButtonManager.additionalY = 10

---Based on Community Debug Tools
---@param buttonModule string
---@param onClick function
function ButtonManager.AddNewButton(buttonModule, onClick)
    local xMax = ISEquippedItem.instance.x - 5
    local yMax = ISEquippedItem.instance:getBottom() + ButtonManager.additionalY

    ---@type Texture
    local texture = BUTTONS_DATA_TEXTURES[buttonModule].OFF
    local textureW, textureH = texture:getWidth(), texture:getHeight()
    ButtonManager[buttonModule] = ISButton:new(xMax, yMax, textureW, textureH, "", nil, onClick)
    ButtonManager[buttonModule]:forceImageSize(textureW, textureH)
    ButtonManager[buttonModule]:setImage(texture)
    ButtonManager[buttonModule]:setDisplayBackground(false)
    ButtonManager[buttonModule].borderColor = { r = 1, g = 1, b = 1, a = 0.1 }

    ISEquippedItem.instance:addChild(ButtonManager[buttonModule])
    ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight() + ButtonManager[buttonModule]:getHeight() +
    ButtonManager.additionalY)
end

function ButtonManager.RemoveButton(buttonModule)
    if ButtonManager[buttonModule] then
        ISEquippedItem.instance:removeChild(ButtonManager[buttonModule])
        ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight() - ButtonManager[buttonModule]:getHeight() -
        ButtonManager.additionalY)
        ButtonManager[buttonModule] = nil
    end
end

local function OpenAdminMenu()
    if not ClientState.isInRaid then
        BeforeMatchAdminPanel.OnOpenPanel()
    else
        DuringMatchAdminPanel.OnOpenPanel()
    end
end


---Creates the buttons. Triggered from an event that starts when player gets teleported in or outside a safehouse
---@param isInRaid boolean
function ButtonManager.CreateButtons(isInRaid)
    if ButtonManager.firstInit then
        ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight() + 50)
        ButtonManager.firstInit = false
    end

    -- Cleans up the buttons before resetting them
    ButtonManager.RemoveButton("Leaderboard")
    ButtonManager.RemoveButton("AdminPanel")

    if isAdmin() then
        ButtonManager.AddNewButton("AdminPanel", function() OpenAdminMenu() end)
    end

    if type(isInRaid) ~= "boolean" or not isInRaid then
        ButtonManager.AddNewButton("Leaderboard", function() LeadearboardPanel.Open(100, 100) end)
    end
end

Events.PZEFT_UpdateClientStatus.Add(ButtonManager.CreateButtons)
Events.OnCreatePlayer.Add(ButtonManager.CreateButtons)

----------------------------------------------------------

-- require "ISUI/ISAdminPanelUI"
-- local _ISAdminPanelUICreate = ISAdminPanelUI.create

-- function ISAdminPanelUI:create()
--     _ISAdminPanelUICreate(self)

--     local function OpenAdminMenu()
--         if not ClientState.IsInRaid then
--             BeforeMatchAdminPanel.OnOpenPanel()
--         else
--             DuringMatchAdminPanel.OnOpenPanel()
--         end
--     end


--     local lastButton = self.children[self.IDMax-1].internal == "CANCEL" and self.children[self.IDMax-2] or self.children[self.IDMax-1]
--     self.btnOpenAdminMenu = ISButton:new(lastButton.x, lastButton.y + 5 + lastButton.height, self.sandboxOptionsBtn.width, self.sandboxOptionsBtn.height, "EFT Admin Menu", self, OpenAdminMenu)
--     self.btnOpenAdminMenu:initialise()
--     self.btnOpenAdminMenu:instantiate()
--     self.btnOpenAdminMenu.borderColor = self.buttonBorderColor
--     self:addChild(self.btnOpenAdminMenu)
-- end
