local TextureScreen = require("ROK/UI/BaseComponents/TextureScreen")
----------------------

local credits = {
    [1] = {
        title = "Original Concept By",
        names = {"BigBadBeaver"}
    },

    [2] = {
        title = "Coding",
        names = {"Pao", "Monkey"}
    },

    [3] = {
        title = "Art",
        names = {"Staticbrain_TV"}
    },

    [4] = {
        title = "Map",
        names = {"Oppolla"}
    },

    [5] = {
        title = "Alpha Testers",
        names = {"NoxKono",
        "Reincarnation",
        "Michaelcosio",
        "W0LF_QC",
        "VRGladiator1341",
        "Bob",
        "Kanjis",
        "Sentile",
        "Moisty",
        "Jorgs",}
    }
}

---@return string
local function GetFullString()
    local richString = "<CENTRE> REMNANTS OF KENTUCKY\n\n\n"
    for _,v in ipairs(credits) do
        local title = v.title
        richString = richString .. "<CENTRE> <SIZE:large>" .. title .. "\n"
        local names = v.names

        for i=1, #names do
            local name = names[i]
            richString = richString .. "<SIZE:small>" ..  name .. "\n"
        end

        richString = richString .. "\n"
    end

    return richString
end


--------------


---@class CreditsScreen : TextureScreen
---@field text string
---@field textX number
---@field textY number
---@field isClosing boolean
---@field closingTime number
local CreditsScreen = TextureScreen:derive("CreditsScreen")
function CreditsScreen:new()
    local o = TextureScreen:new()
    setmetatable(o, self)
    self.__index = self

    o.backgroundTexture = getTexture("media/textures/ROK_CreditsScreen.png")

    ---@cast o LoadingScreen
    CreditsScreen.instance = o
    return o
end


function CreditsScreen:createChildren()
    TextureScreen.createChildren(self)
    self.borderColor = { r = 1, g = 0, b = 0, a = 1 }

    self.textPanel = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.textPanel:initialise()
    self:addChild(self.textPanel)
    self.textPanel.defaultFont = UIFont.Massive
    self.textPanel.anchorTop = true
    self.textPanel.anchorLeft = false
    self.textPanel.anchorBottom = true
    self.textPanel.anchorRight = false
    self.textPanel.marginLeft = 0
    self.textPanel.marginRight = 0
    self.textPanel.marginBottom = 0
    self.textPanel.autosetheight = false
    self.textPanel.background = true

    self.fullString = GetFullString()
    self.textPanel:setText(self.fullString)

    self.creditsStrY = getTextManager():MeasureStringY(UIFont.Medium, self.fullString)
    local creditsStrX = getTextManager():MeasureStringX(UIFont.Large, self.fullString)

    local midX = (self.width - creditsStrX)/2


    self.textPanel:setX(midX)
    self.textPanel:setWidth(creditsStrX * 1.25)
    self.textPanel.marginTop = self.height
    self.textPanel:paginate()
end


function CreditsScreen:prerender()
    TextureScreen.prerender(self)
    self.textPanel.marginTop = self.textPanel.marginTop - 3

    if self.textPanel.marginTop < -self.creditsStrY then
        CreditsScreen.Close()
    end

end

function CreditsScreen.OnPressKey(key)
    if key == Keyboard.KEY_SPACE or key == Keyboard.KEY_ESCAPE then
        CreditsScreen.Close()
    end
end
Events.OnKeyStartPressed.Add(CreditsScreen.OnPressKey)

function CreditsScreen.Open()
    if CreditsScreen.instance ~= nil then
        CreditsScreen.Close()
    end
    debugPrint("Opening CreditsScreen")
    local creditsScreen = CreditsScreen:new()
    creditsScreen:initialise()
    creditsScreen:addToUIManager()
    creditsScreen:setAlwaysOnTop(true)
end

function CreditsScreen.Close()
    if CreditsScreen.instance then
        CreditsScreen.instance:close()
    end

    CreditsScreen.instance = nil
end



function CreditsScreen.HandleResolutionChange(oldW, oldH, w, h)
    -- FIXME This will reset the credits, re-starting them
    if CreditsScreen.instance then
        CreditsScreen.Close()
        CreditsScreen.Open()
    end
end

Events.OnResolutionChange.Add(CreditsScreen.HandleResolutionChange)

local old_MainScreen_render = MainScreen.render
local function MainScreenRender(self)
    old_MainScreen_render(self)

    if self.inGame and isClient() then
        self.bottomPanel:setHeight(self.creditsROK:getBottom())
    end
end

local old_MainScreen_instantiate = MainScreen.instantiate
function MainScreen:instantiate()
    old_MainScreen_instantiate(self)

    if self.inGame and isClient() then
        local labelHgt = getTextManager():getFontHeight(UIFont.Large) + 8 * 2
        self.creditsROK = ISLabel:new(self.quitToDesktop.x, self.quitToDesktop.y + labelHgt + 16, labelHgt, "ROK CREDITS", 1, 1, 1, 1, UIFont.Large, true)
        self.creditsROK.internal = "ROK_CREDITS"
        self.creditsROK:initialise()
        self.bottomPanel:addChild(self.creditsROK)
        self.render = MainScreenRender
        self.creditsROK.onMouseDown = function()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            CreditsScreen.Open()
        end
        self.creditsROK.onMouseMove = function(self)
            self.fade:setFadeIn(true)
        end
        self.creditsROK.onMouseMoveOutside = function(self)
            self.fade:setFadeIn(false)
        end
        self.creditsROK:setWidth(self.quitToDesktop.width)
        self.creditsROK.fade = UITransition.new()
        self.creditsROK.fade:setFadeIn(false)
        self.creditsROK.prerender = self.prerenderBottomPanelLabel
    end
end



return CreditsScreen