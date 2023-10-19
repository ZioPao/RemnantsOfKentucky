require "ClientState"
local BeforeMatchAdminPanel = require("EFTUI/BeforeMatch/BeforeMatchAdminPanel")
local DuringMatchAdminPanel = require("EFTUI/DuringMatch/DuringMatchAdminPanel")
-- Override ISSafetyUI to have a instance of that so we can reference it later
local og_ISSafetyUI = ISSafetyUI.new

function ISSafetyUI:new(x, y, playerNum)
    local o = og_ISSafetyUI(self, x, y, playerNum)
    ISSafetyUI.instance = o

    return o
end

-----------------------------

BUTTONS_DATA_TEXTURES = {
    LeaderboardButton = {
        ON = getTexture("media/textures/Leaderboard_on.png"),       -- TODO These icons are obviously temporary.
        OFF = getTexture("media/textures/Leaderboard_off.png")
    },

    AdminPanelButton = {
        ON = getTexture("media/textures/AdminPanel_on.png"),
        OFF = getTexture("media/textures/AdminPanel_off.png")
    }
}


ButtonManager = {}

---Based on Community Debug Tools
---@param buttonModule string
---@param onClick function
function ButtonManager.AddNewButton(buttonModule, onClick)

    local additionalY = 50
    -- if ButtonManager.isFirst then
    --     additionalY = 50
    --     ButtonManager.isFirst = false
    -- end

    local xMax = ISEquippedItem.instance.x - 5
    local yMax = ISEquippedItem.instance:getBottom() + additionalY

    ---@type Texture
    local texture = BUTTONS_DATA_TEXTURES[buttonModule].OFF
    local textureW, textureH = texture:getWidth(), texture:getHeight()
    ButtonManager[buttonModule] = ISButton:new(xMax, yMax, textureW, textureH, "", nil, onClick)
    ButtonManager[buttonModule]:forceImageSize(textureW, textureH)
    ButtonManager[buttonModule]:setImage(texture)
    ButtonManager[buttonModule]:setDisplayBackground(false)
    ButtonManager[buttonModule].borderColor = { r = 1, g = 1, b = 1, a = 0.1 }

    ISEquippedItem.instance:addChild(ButtonManager[buttonModule])
    ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight() + ButtonManager[buttonModule]:getHeight() + additionalY)
end

function ButtonManager.RemoveButton(buttonModule)
    if ButtonManager[buttonModule] then
        ISEquippedItem.instance:removeChild(ButtonManager[buttonModule])
        ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight() - ButtonManager[buttonModule]:getHeight() - 50)
        ButtonManager[buttonModule] = nil
    end

end

local function OpenAdminMenu()
    if not ClientState.IsInRaid then
        BeforeMatchAdminPanel.OnOpenPanel()
    else
        DuringMatchAdminPanel.OnOpenPanel()
    end
end



function ButtonManager.CreateButtons(isInRaid)
    print("Create buttons")
    -- This should be active ONLY when players are in their safehouses
    -- FIXME Bit buggy

    ButtonManager.RemoveButton("LeaderboardButton")
    ButtonManager.RemoveButton("AdminPanelButton")
    if type(isInRaid) ~= "boolean" or not isInRaid then
        ButtonManager.AddNewButton("LeaderboardButton", function() LeadearboardPanel.Open(100,100) end)
    end

    -- TODO Check if admin
    ButtonManager.AddNewButton("AdminPanelButton", function() OpenAdminMenu() end)
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
