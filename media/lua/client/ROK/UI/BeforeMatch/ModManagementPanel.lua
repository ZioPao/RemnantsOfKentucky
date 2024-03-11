local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local ClientState = require("ROK/ClientState")

local IconButton = require("ROK/UI/BaseComponents/IconButton")

---------------------------------------

local AUTO_START_ICON = getTexture("media/textures/BeforeMatchPanel/AutoStart.png")

-- https://www.freepik.com/icon/repeat_13070070#fromView=search&page=1&position=9&uuid=b946dce5-3f7c-4c66-bd15-40276518138c


local RESET_USED_INSTANCES_ICON = getTexture("media/textures/BeforeMatchPanel/ResetUsedInstances.png")
--https://www.freepik.com/icon/refresh_3987207#fromView=search&page=1&position=20&uuid=6f714287-7ada-4ec8-896e-b5a944100b6b
---@class ModManagementPanel : ISCollapsableWindow
local ModManagementPanel = ISCollapsableWindow:derive("ModManagementPanel")

function ModManagementPanel.Open(x, y)
    if ModManagementPanel.instance then
        ModManagementPanel.instance:close()
    end

    local modal = ModManagementPanel:new(x, y, 350 * GenericUI.FONT_SCALE, 500)
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
    local xPadding = 20

    local btnWidth = self:getWidth() - xPadding * 2
    local yPadding = 10


    --* Start from the mid point and work from there

    ------------
    --* Top Part
    local y = (self:getHeight() - btnHeight - yPadding)/2


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

    y = (self:getHeight() + btnHeight + yPadding)/2


    self.btnResetUsedInstances = IconButton:new(
        xPadding, y, btnWidth, btnHeight,
        RESET_USED_INSTANCES_ICON, getText("IGUI_EFT_AdminPanel_ResetUsedInstances"), "RESET_USED_INSTANCES",
        self, self.onClick
    )
    self.btnResetUsedInstances:initialise()
    self.btnResetUsedInstances:setEnable(true)
    self:addChild(self.btnResetUsedInstances)

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