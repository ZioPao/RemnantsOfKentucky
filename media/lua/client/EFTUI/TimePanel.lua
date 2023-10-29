-- Used in conjuction with a BaseTimer\TimerHandler\CountdownHandler

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"

-- TODO Make this local
TimePanel = ISPanel:derive("TimePanel")

function TimePanel:new(x, y, width, height, isStartingMatch)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.isStartingMatch = isStartingMatch
    o:initialise()

    TimePanel.instance = o
    return o
end

function TimePanel:render()
    local timeNumber = tonumber(ClientState.currentTime)
    if timeNumber == nil then return end

    if timeNumber <= 0 then
        print("Closing timer")
        self:close()
    end
    self.timePanel:setText(EFTGenericUI.FormatTime(timeNumber))
    self.timePanel.textDirty = true

    if self.isStartingMatch then return end

    -- todo In game timer will fade out after some seconds
    -- TODO if we do it via update it could be faster depending on the framerate. Keep this in mind

    --self.color.a = self.timeText.color.a - 0.0001
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

---Show a description on tye upper part of the time panel
function TimePanel:setDescription(description)
    -- TODO This doesn't work reliably
    self.textLabel:setName(description)
end

-------------------------

function TimePanel.Open(description)
    if TimePanel.instance then
        TimePanel.instance:close()
    end

    print("Opening up timer")
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
    -- FIXME sometimes it breaks.
    TimePanel.instance:close()
end
