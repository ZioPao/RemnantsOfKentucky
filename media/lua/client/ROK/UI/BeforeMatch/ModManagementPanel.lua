local GenericUI = require("ROK/UI/BaseComponents/GenericUI")
local ClientState = require("ROK/ClientState")

local IconButton = require("ROK/UI/BaseComponents/IconButton")

---------------------------------------

local AUTO_START_ICON = getTexture("media/textures/BeforeMatchPanel/AutoStart.png") -- https://www.freepik.com/icon/rotated_14441036#fromView=family&page=1&position=3&uuid=135de5a3-1019-46dd-bbef-fdbb2fd5b027
local RESET_USED_INSTANCES_ICON = getTexture("media/textures/BeforeMatchPanel/ResetUsedInstances.png")  -- https://www.freepik.com/icon/loading_13570094#fromView=family&page=1&position=53&uuid=7960d82c-7aae-422b-b4ef-fe1338a807bf

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
    local xPadding = 20
    local btnWidth = self:getWidth() - xPadding * 2
    local yPadding = 10

    local label = ISLabel:new(xPadding, yPadding, 25, getText("IGUI_EFT_AdminPanel_ModManagement"), 1, 1, 1, 1, UIFont.NewLarge, true)
    label:initialise()
    label:instantiate()
    self:addChild(label)

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