local ClientState = require("ROK/ClientState")
local BeforeMatchAdminPanel = require("ROK/UI/BeforeMatch/BeforeMatchAdminPanel")
local DuringMatchAdminPanel = require("ROK/UI/DuringMatch/DuringMatchAdminPanel")
local LeaderboardPanel = require("ROK/UI/BeforeMatch/LeaderboardPanel")
----------------

local og_ISEquippedItem_initialise = ISEquippedItem.initialise

function ISEquippedItem:initialise()
    og_ISEquippedItem_initialise(self)
    debugPrint("initializing ISEquippedItem")

    -- Separator
    self:setHeight(self:getHeight() + 50)
    triggerEvent("PZEFT_PostISEquippedItemInitialization")
end


-- Override ISSafetyUI to have a instance of that so we can reference it later
local og_ISSafetyUI = ISSafetyUI.new

---@diagnostic disable-next-line: duplicate-set-field
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

local function OpenAdminMenu()
    if not ClientState.GetIsInRaid() then
        BeforeMatchAdminPanel.OnOpenPanel()
    else
        DuringMatchAdminPanel.OnOpenPanel()
    end
end

---Based on Community Debug Tools
---@param buttonModule string
---@param onClick function
function ButtonManager.AddNewButton(buttonModule, y, onClick)

    ---@type ISEquippedItem
    local inst = ISEquippedItem.instance

    y = y + ButtonManager.additionalY
    --local y = inst:getHeight() + ButtonManager.additionalY
    debugPrint("Adding " .. buttonModule)
    debugPrint("y = " .. tostring(y))
    local x = inst.x - 5

    ---@type Texture
    local texture = BUTTONS_DATA_TEXTURES[buttonModule].OFF
    local textureW, textureH = texture:getWidthOrig(), texture:getHeightOrig()
    ButtonManager[buttonModule] = ISButton:new(x, y, textureW, textureH, "", nil, onClick)
    ButtonManager[buttonModule]:forceImageSize(textureW, textureH)
    ButtonManager[buttonModule]:setImage(texture)
    ButtonManager[buttonModule]:initialise()
    ButtonManager[buttonModule]:instantiate()
    ButtonManager[buttonModule]:setDisplayBackground(false)
    ButtonManager[buttonModule].borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    ButtonManager[buttonModule]:ignoreWidthChange()
    ButtonManager[buttonModule]:ignoreHeightChange()

    inst:addChild(ButtonManager[buttonModule])
    inst:setHeight(ButtonManager[buttonModule]:getBottom())

    return y + textureH
end

---Creates the buttons.
function ButtonManager.CreateButtons()
    --debugPrint("Creating ROK buttons")
    --debugPrint("ISEquippedItem height: " .. tostring(ISEquippedItem.instance:getHeight()))

    -- We need to get the height here to prevent issues. I've got no clue why, but if I try to get it from inside
    -- the AddNewButton function I will get a different result after the player die, and it will never "fix" itself.
    -- So fuck it, just get it here one time and be done with it
    local y = ISEquippedItem.instance:getHeight()

    if isAdmin() then
        y = ButtonManager.AddNewButton("AdminPanel", y, function() OpenAdminMenu() end)
    end

    y = ButtonManager.AddNewButton("Leaderboard", y, function() LeaderboardPanel.Open(100, 100) end)

    ISEquippedItem.instance:shrinkWrap()
end

function ButtonManager.Hide(isInRaid)
    ButtonManager["Leaderboard"]:setVisible(not isInRaid)
    ButtonManager["Leaderboard"]:setEnabled(not isInRaid)
end


Events.PZEFT_PostISEquippedItemInitialization.Add(ButtonManager.CreateButtons)
Events.PZEFT_UpdateClientStatus.Add(ButtonManager.Hide)