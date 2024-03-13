local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local ClientState = require("ROK/ClientState")

local IconButton = require("ROK/UI/BaseComponents/IconButton")
---------------------------------------

-- TODO add credits for icons
local SET_TIME_ICON = getTexture("media/textures/BeforeMatchPanel/SetTime.png")     -- https://www.freepik.com/icon/weather_12954793#fromView=family&page=1&position=2&uuid=e4dc941c-8a03-404a-897d-a58f9f2e6fe4
local TELEPORT_SAFEHOUSE_ICON = getTexture("media/textures/BeforeMatchPanel/TeleportSafehouse.png") -- https://www.freepik.com/icon/home_12484335#fromView=family&page=1&position=1&uuid=3dba7879-de2d-400d-95e9-a8b1c6e83bf3

---@class OtherOptionsPanel : ISCollapsableWindow
local OtherOptionsPanel = ISCollapsableWindow:derive("OtherOptionsPanel")

function OtherOptionsPanel.Open(x, y, width, height)
    if OtherOptionsPanel.instance then
        OtherOptionsPanel.instance:close()
    end

    local modal = OtherOptionsPanel:new(x, y, width, height)
    modal:initialise()
    modal:addToUIManager()
    --modal.instance:setKeyboardFocus()

    return modal
end

function OtherOptionsPanel:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
    o.width = width
    o.height = height
    o.resizable = false
    o.moveWithMouse = false
    OtherOptionsPanel.instance = o
    return o
end

function OtherOptionsPanel:createChildren()
    local btnHeight = 50
    local xPadding = GenericUI.X_PADDING
    local btnWidth = self:getWidth() - xPadding * 2
    local yPadding = 10

    local label = ISLabel:new(xPadding, yPadding, 25, getText("IGUI_EFT_AdminPanel_OtherOptions"), 1, 1, 1, 1, UIFont.NewLarge, true)
    label:initialise()
    label:instantiate()
    self:addChild(label)


    --* Start from the mid point and work from there

    ------------
    --* Top Part
    local y = (self:getHeight() - btnHeight - yPadding)/2


    self.btnSetTime = IconButton:new(
        xPadding, y, btnWidth, btnHeight,
        SET_TIME_ICON, "", "SET_TIME",
        self, self.onClick
    )
    self.btnSetTime:initialise()
    self.btnSetTime:setEnable(false)
    self:addChild(self.btnSetTime)

    -- Additional handling for the btnSetTime
    self.btnSetTimeTab = {
        prevInt = "",
        isChanging = false
    }


    ------------
    --* Bottom part 

    y = (self:getHeight() + btnHeight + yPadding)/2


    self.btnTeleportToSafehouse = IconButton:new(
        xPadding, y, btnWidth, btnHeight,
        TELEPORT_SAFEHOUSE_ICON, getText("IGUI_EFT_AdminPanel_TeleportToSafehouse"), "TELEPORT_SAFEHOUSE",
        self, self.onClick
    )
    self.btnTeleportToSafehouse:initialise()
    self.btnTeleportToSafehouse:setEnable(true)
    self:addChild(self.btnTeleportToSafehouse)

end

function OtherOptionsPanel:initialise()
    ISCollapsableWindow.initialise(self)
end


function OtherOptionsPanel:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
end


function OtherOptionsPanel:onClick(btn)
    if btn.internal == 'SET_TIME_DAY' then
        debugPrint("Setting Day Time")
        sendClientCommand(EFT_MODULES.Time, "SetDayTime", {})
        btn:setEnable(false)
        self.btnSetTimeTab.isChanging = true
        self.btnSetTimeTab.prevInt = 'SET_TIME_DAY'
    elseif btn.internal == 'SET_TIME_NIGHT' then
        debugPrint("Setting Night Time")
        sendClientCommand(EFT_MODULES.Time, "SetNightTime", {})
        btn:setEnable(false)
        self.btnSetTimeTab.isChanging = true
        self.btnSetTimeTab.prevInt = 'SET_TIME_NIGHT'
    elseif btn.internal == 'TELEPORT_SAFEHOUSE' then
        sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", {teleport = true})
    end
end


function OtherOptionsPanel:updateSetTimeBtn()
   -- Check hour 
    local time = getGameTime():getTimeOfDay()
    --debugPrint(time)
    if time > 9 and time < 21 then
        self.btnSetTime:setInternal("SET_TIME_NIGHT")
        self.btnSetTime:setTitle(getText("IGUI_EFT_AdminPanel_SetNightTime"))
    else
        self.btnSetTime:setInternal("SET_TIME_DAY")
        self.btnSetTime:setTitle(getText("IGUI_EFT_AdminPanel_SetDayTime"))

    end

    -- Reactivates the btnSetTime only when the internal has changed
    if self.btnSetTimeTab.isChanging then
        if self.btnSetTimeTab.prevInt ~= self.btnSetTime:getInternal() then
            self.btnSetTime:setEnable(not ClientState.GetIsStartingMatch())

            -- Reset the table
            self.btnSetTimeTab.prevInt = ""
            self.btnSetTimeTab.isChanging = false
        else
            self.btnSetTime:setEnable(false)
        end
    else
        self.btnSetTime:setEnable(not ClientState.GetIsStartingMatch())
    end
end


function OtherOptionsPanel:update()
    ISCollapsableWindow.update(self)

    self:updateSetTimeBtn()

end

function OtherOptionsPanel:render()
    ISCollapsableWindow.render(self)

end

function OtherOptionsPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end
    ISCollapsableWindow.close(self)
end


return OtherOptionsPanel