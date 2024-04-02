local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local ClientState = require("ROK/ClientState")

local IconButton = require("ROK/UI/BaseComponents/IconButton")

---------------------------------------

local AUTO_START_ICON = getTexture("media/textures/BeforeMatchPanel/Loop.png")                         -- https://www.freepik.com/icon/rotated_14441036#fromView=family&page=1&position=3&uuid=135de5a3-1019-46dd-bbef-fdbb2fd5b027
local RESET_USED_INSTANCES_ICON = getTexture("media/textures/BeforeMatchPanel/ResetUsedInstances.png") -- https://www.freepik.com/icon/loading_13570094#fromView=family&page=1&position=53&uuid=7960d82c-7aae-422b-b4ef-fe1338a807bf
local SET_TIME_ICON = getTexture("media/textures/BeforeMatchPanel/SetTime.png")                        -- https://www.freepik.com/icon/weather_12954793#fromView=family&page=1&position=2&uuid=e4dc941c-8a03-404a-897d-a58f9f2e6fe4
local TELEPORT_SAFEHOUSE_ICON = getTexture("media/textures/BeforeMatchPanel/TeleportSafehouse.png")    -- https://www.freepik.com/icon/home_12484335#fromView=family&page=1&position=1&uuid=3dba7879-de2d-400d-95e9-a8b1c6e83bf3

---------------------------------------


---@class ModManagementPanel : ISCollapsableWindow
local ModManagementPanel = ISCollapsableWindow:derive("ModManagementPanel")

function ModManagementPanel.Open(x, y, width, height)
    if ModManagementPanel.instance then
        ModManagementPanel.instance:close()
    end

    local modal = ModManagementPanel:new(x, y, width, height)
    modal:initialise()
    modal:addToUIManager()
    --modal.instance:setKeyboardFocus()

    return modal
end

function ModManagementPanel:new(x, y, width, height)
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
    ModManagementPanel.instance = o
    return o
end

function ModManagementPanel:initialise()
    ISCollapsableWindow.initialise(self)
end

function ModManagementPanel:createChildren()
    local btnHeight = 50
    local xPadding = GenericUI.X_PADDING
    local btnWidth = self:getWidth() - xPadding * 2
    local yPadding = 10

    local label = ISLabel:new(xPadding, yPadding, 25, getText("IGUI_EFT_AdminPanel_ModManagement"), 1, 1, 1, 1,
        UIFont.NewLarge, true)
    label:initialise()
    label:instantiate()
    self:addChild(label)

    --* Start from the mid point and work from there

    ------------
    --* Top Part
    local y = (self:getHeight() - btnHeight - yPadding) / 2


    self.btnResetUsedInstances = IconButton:new(
        xPadding, y, btnWidth, btnHeight,
        RESET_USED_INSTANCES_ICON, getText("IGUI_EFT_AdminPanel_ResetUsedInstances"), "RESET_USED_INSTANCES",
        self, self.onClick
    )
    self.btnResetUsedInstances:initialise()
    self.btnResetUsedInstances:setEnable(true)
    self:addChild(self.btnResetUsedInstances)


    y = y - btnHeight - yPadding


    self.btnToggleAutomaticStart = IconButton:new(
        xPadding, y, btnWidth, btnHeight,
        AUTO_START_ICON, getText("IGUI_EFT_AdminPanel_ActivateAutomaticStart"), "TOGGLE_AUTOMATIC_START",
        self, self.onClick
    )
    self.btnToggleAutomaticStart:initialise()
    self.btnToggleAutomaticStart:setEnable(true)
    self:addChild(self.btnToggleAutomaticStart)

    ------------
    --* Bottom part

    y = (self:getHeight() + btnHeight + yPadding) / 2


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

    y = y + btnHeight + yPadding


    self.btnTeleportToSafehouse = IconButton:new(
        xPadding, y, btnWidth, btnHeight,
        TELEPORT_SAFEHOUSE_ICON, getText("IGUI_EFT_AdminPanel_TeleportToSafehouse"), "TELEPORT_SAFEHOUSE",
        self, self.onClick
    )
    self.btnTeleportToSafehouse:initialise()
    self.btnTeleportToSafehouse:setEnable(true)
    self:addChild(self.btnTeleportToSafehouse)
end

function ModManagementPanel:prerender()
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
        self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
        self.borderColor.b)
end

function ModManagementPanel:onClick(btn)
    if btn.internal == 'TOGGLE_AUTOMATIC_START' then
        sendClientCommand(EFT_MODULES.Match, "ToggleAutomaticStart", {})

        -- Let's assume that everything is working fine on the server, and let's just toggle it from here.
        ClientState.SetIsAutomaticStart(not ClientState.GetIsAutomaticStart())
    elseif btn.internal == 'RESET_USED_INSTANCES' then
        debugPrint("Resetting used instances to base values")
        sendClientCommand(EFT_MODULES.PvpInstances, 'ResetPVPInstances', {})
    elseif btn.internal == 'SET_TIME_DAY' then
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
        sendClientCommand(EFT_MODULES.Safehouse, "RequestSafehouseAllocation", { teleport = true })
    end
end

function ModManagementPanel:updateSetTimeBtn()
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

function ModManagementPanel:update()
    ISCollapsableWindow.update(self)

    --Set the toggle match thing
    if ClientState.GetIsAutomaticStart() then
        self.btnToggleAutomaticStart:setTitle(getText("IGUI_EFT_AdminPanel_DeactivateAutomaticStart"))
    else
        self.btnToggleAutomaticStart:setTitle(getText("IGUI_EFT_AdminPanel_ActivateAutomaticStart"))
    end

    self.btnResetUsedInstances:setEnable(not ClientState.GetIsStartingMatch())

    -- Updates time in bottom btns
    self:updateSetTimeBtn()
end

function ModManagementPanel:render()
    ISCollapsableWindow.render(self)
end

function ModManagementPanel:close()
    if self.confirmationPanel then
        self.confirmationPanel:close()
    end
    ISCollapsableWindow.close(self)
end

return ModManagementPanel
