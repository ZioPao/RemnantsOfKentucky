-- Used in conjuction with a BaseTimer\TimerHandler\CountdownHandler
require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
local ClientState = require("ROK/ClientState")
local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
---------------------------

---@class TimePanel : ISPanel
---@field isStartingMatch boolean
local TimePanel = ISPanel:derive("TimePanel")

---@param x number
---@param y number
---@param width number
---@param height number
---@param isStartingMatch boolean
---@return TimePanel
function TimePanel:new(x, y, width, height, isStartingMatch)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.isStartingMatch = isStartingMatch
    o:initialise()

    ---@cast o TimePanel
    TimePanel.instance = o
    return o
end

function TimePanel:initialise()
    ISPanel.initialise(self)

    self.timePanel = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.timePanel:initialise()
    self:addChild(self.timePanel)

    self.timePanel.defaultFont = UIFont.Massive
    self.timePanel.anchorTop = false
    self.timePanel.anchorLeft = false
    self.timePanel.anchorBottom = false
    self.timePanel.anchorRight = false

    self.timePanel.marginLeft = 0
    self.timePanel.marginTop = self.height / 4

    self.timePanel.marginRight = 0
    self.timePanel.marginBottom = 0
    self.timePanel.autosetheight = false
    self.timePanel.background = false

    self.timePanel:paginate()


    -- Additional text on top of the time

    self.textLabel = ISLabel:new(5, 10, 10, "", 1, 1, 1, 1, UIFont.Large, true)
    self.textLabel:initialise()
    self.textLabel:instantiate()
    self.timePanel:addChild(self.textLabel)
end

function TimePanel:render()
    local timeNumber = tonumber(ClientState.currentTime)
    if timeNumber == nil then return end

    if timeNumber <= 0 then
        debugPrint("Closing timer")
        self:close()
    end
    self.timePanel:setText(GenericUI.FormatTime(timeNumber))
    self.timePanel.textDirty = true

    if self.isStartingMatch then return end

    -- todo In game timer will fade out after some seconds
    -- TODO if we do it via update it could be faster depending on the framerate. Keep this in mind

    --self.color.a = self.timeText.color.a - 0.0001
end

---Show a description on tye upper part of the time panel
function TimePanel:setDescription(description)
    -- TODO This doesn't work reliably
    self.textLabel:setName(description)
end

function TimePanel:setPosition(x, y)
    self:setX(x)
    self:setY(y)
end

-------------------------

function TimePanel.Open(description)
    if TimePanel.instance then
        TimePanel.instance:close()
    end

    -- TODO description doesn't always show
    debugPrint("Opening up timer")
    local width = 300
    local height = 100
    local padding = 50
    local posX = getCore():getScreenWidth() - width - padding
    local posY = getCore():getScreenHeight() - height - padding

    local panel = TimePanel:new(posX, posY, width, height, true)
    panel:initialise()
    panel:addToUIManager()
    panel:bringToTop()
    panel:setDescription(description)

    return panel
end

function TimePanel.Close()
    if TimePanel.instance then
        TimePanel.instance:close()
    end
end

function TimePanel.HandleResolutionChange(oldW, oldH, w, h)
    if TimePanel.instance and TimePanel.instance:isVisible() then
        local width = 300
        local height = 100
        local padding = 50
        local posX = w - width - padding
        local posY = h - height - padding
        TimePanel.instance:setPosition(posX, posY)

        -- We need to handle the ExtractionPanel from here since it's dependant on the TimePanel
        local ExtractionPanel = require("ROK/UI/DuringMatch/ExtractionPanel")

        if ExtractionPanel.instance and ExtractionPanel.instance:isVisible() then
            local pos = ExtractionPanel.GetPosition()
            ExtractionPanel.instance:setX(pos.x)
            ExtractionPanel.instance:setY(pos.y)
        end
    end
end

Events.OnResolutionChange.Add(TimePanel.HandleResolutionChange)

------------------------------------------------------------------------
--* COMMANDS FROM SERVER *--
------------------------------------------------------------------------

local MODULE = EFT_MODULES.Time
local TimeCommands = {}

---@param args {description : string}
function TimeCommands.OpenTimePanel(args)
    TimePanel.Close()
    TimePanel.Open(args.description)

    ClientState.currentTime = 100       -- Workaround to prevent the TimePanel from closing
end

---@param args {time : number }
function TimeCommands.ReceiveTimeUpdate(args)
    ClientState.currentTime = args.time
    -- Locally, 1 player, about 4-5 ms of delay.
end

---------------------
local OnTimeCommand = function(module, command, args)

    if module ~= MODULE then return end

    --debugPrint("Running OnTimeCommand " .. command)
    if TimeCommands[command] then
        TimeCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnTimeCommand)

return TimePanel
