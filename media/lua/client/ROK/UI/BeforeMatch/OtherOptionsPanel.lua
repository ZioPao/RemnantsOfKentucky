local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local ClientState = require("ROK/ClientState")
---------------------------------------

---@class OtherOptionsPanel : ISCollapsableWindow
local OtherOptionsPanel = ISCollapsableWindow:derive("OtherOptionsPanel")

function OtherOptionsPanel.Open(x, y)
    if OtherOptionsPanel.instance then
        OtherOptionsPanel.instance:close()
    end

    local modal = OtherOptionsPanel:new(x, y, 350 * GenericUI.FONT_SCALE, 500)
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
    local xPadding = 20
    local y = self:getHeight()/2 - btnHeight/2
    local btnWidth = self:getWidth() - xPadding * 2

    self.btnSetTime = ISButton:new(xPadding, y, btnWidth, btnHeight, "", self, self.onClick)
    self.btnSetTime.internal = "SET_TIME"
    self.btnSetTime:initialise()
    self.btnSetTime:setEnable(false)
    self:addChild(self.btnSetTime)

    -- Additional handling for the btnSetTime
    self.btnSetTimeTab = {
        prevInt = "",
        isChanging = false
    }
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
        sendClientCommand(EFT_MODULES.UI, "SetDayTime", {})
        btn:setEnable(false)
        self.btnSetTimeTab.isChanging = true
        self.btnSetTimeTab.prevInt = 'SET_TIME_DAY'
    elseif btn.internal == 'SET_TIME_NIGHT' then
        debugPrint("Setting Night Time")
        sendClientCommand(EFT_MODULES.UI, "SetNightTime", {})
        btn:setEnable(false)
        self.btnSetTimeTab.isChanging = true
        self.btnSetTimeTab.prevInt = 'SET_TIME_NIGHT'
    end
end


function OtherOptionsPanel:updateSetTimeBtn()
   -- Check hour 
    local time = getGameTime():getTimeOfDay()
    --debugPrint(time)
    if time > 9 and time < 21 then
        self.btnSetTime.internal = "SET_TIME_NIGHT"
        self.btnSetTime.title = getText("IGUI_EFT_AdminPanel_SetNightTime")
    else
        self.btnSetTime.internal = "SET_TIME_DAY"
        self.btnSetTime.title = getText("IGUI_EFT_AdminPanel_SetDayTime")
    end

    -- Reactivates the btnSetTime only when the internal has changed
    if self.btnSetTimeTab.isChanging then
        if self.btnSetTimeTab.prevInt ~= self.btnSetTime.internal then
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