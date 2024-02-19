-- TODO do it
local TextureScreen = require("ROK/UI/BaseComponents/TextureScreen")

local credits = [[
    <CENTRE> <RED> <SIZE:large> Original Concept by <RGB:1,1,1> 
    <SIZE:medium> BigBadBeaver
    
    <SIZE:large> <RED> Coding  <RGB:1,1,1> 
    <SIZE:medium> Pao, Monkey
    
    <SIZE:large> <RED> Map <RGB:1,1,1> 
    <SIZE:medium> Oppolla
    
    
    <SIZE:large> <RED> Alpha Testers <RGB:1,1,1> 
    <SIZE:medium> NoxKono
    <SIZE:medium> Reincarnation
    <SIZE:medium> Michaelcosio
    <SIZE:medium> W0LF_QC
    <SIZE:medium> VRGladiator1341
    <SIZE:medium> Bob
    <SIZE:medium> Kanjis
    <SIZE:medium> Sentile
    <SIZE:medium> Moisty
]]


-- local credits2 = {
--     ahahah
-- }

local credits2 = {
    [1] = {
        title = "Original Concept By",
        names = {"BigBadBeaver"}
    },

    [2] = {
        title = "Coding",
        names = {"Pao", "Monkey"}
    },

    [3] = {
        title = "Map",
        names = {"Oppolla"}
    },

    [4] = {
        title = "Alpha Testers",
        names = {"NoxKono",
        "Reincarnation",
        "Michaelcosio",
        "W0LF_QC",
        "VRGladiator1341",
        "Bob",
        "Kanjis",
        "Sentile",
        "Moisty"}
    }
}

---@return string
local function GetFullString()
    local richString = ""

    for k,v in ipairs(credits2) do
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
CreditsScreen = TextureScreen:derive("CreditsScreen")
function CreditsScreen:new()
    local o = TextureScreen:new()
    setmetatable(o, self)
    self.__index = self

    o.backgroundTexture = getTexture("media/textures/ROK_LoadingScreen.png")

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
    self.textPanel.defaultFont = UIFont.Medium
    self.textPanel.anchorTop = true
    self.textPanel.anchorLeft = false
    self.textPanel.anchorBottom = true
    self.textPanel.anchorRight = false
    self.textPanel.marginLeft = 0
    self.textPanel.marginRight = 0
    self.textPanel.marginBottom = 0
    self.textPanel.autosetheight = false
    self.textPanel.background = true

    local fullString = GetFullString()
    self.textPanel:setText(fullString)

    local creditsStrY = getTextManager():MeasureStringY(UIFont.Medium, fullString)
    local creditsStrX = getTextManager():MeasureStringX(UIFont.Large, fullString)

    local midX = (self.width - creditsStrX)/2


    self.textPanel:setX(midX)
    self.textPanel:setWidth(creditsStrX)
    self.textPanel.marginTop = creditsStrY/2
    self.textPanel:paginate()
end


function CreditsScreen.OnSpacePressed(key)
    if key ~= Keyboard.KEY_SPACE then return end
    CreditsScreen.Close()
end
Events.OnKeyStartPressed.Add(CreditsScreen.OnSpacePressed)

function CreditsScreen.Open()
    if CreditsScreen.instance ~= nil then
        CreditsScreen.Close()
    end
    debugPrint("Opening CreditsScreen")
    local creditsScreen = CreditsScreen:new()
    creditsScreen:initialise()
    creditsScreen:addToUIManager()
end

function CreditsScreen.Close()
    if CreditsScreen.instance then
        CreditsScreen.instance:close()
    end
end



function CreditsScreen.HandleResolutionChange(oldW, oldH, w, h)
    if CreditsScreen.instance then
        CreditsScreen.Close()
        CreditsScreen.Open()
    end
end

Events.OnResolutionChange.Add(CreditsScreen.HandleResolutionChange)
-- Original Concept by
-- BigBadBeaver

-- Coding
-- Pao, Monkey

-- Map 
-- Oppolla


-- Alpha Testers
-- NoxKono
-- Reincarnation
-- Michaelcosio
-- W0LF_QC
-- VRGladiator1341
-- Bob
-- Kanjis
-- Sentile
-- Moisty


--return CreditsScreen