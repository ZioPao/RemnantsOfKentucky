local AdminTopPanel = require("ROK/UI/BaseComponents/AdminTopPanel")
local ClientState = require("ROK/ClientState")

--------------------

---@class BeforeTopPanel : AdminTopPanel
---@field instancesAmount number
local BeforeTopPanel = AdminTopPanel:derive("BeforeTopPanel")

---@param x number
---@param y number
---@param width number
---@param height number
---@return BeforeTopPanel
function BeforeTopPanel:new(x, y, width, height)
    local o = AdminTopPanel:new(x, y, width, height, 25)
    setmetatable(o, self)
    self.__index = self

    ---@cast o BeforeTopPanel
    return o
end

function BeforeTopPanel:createChildren()
    self:createRow("availableInstances")
end

function BeforeTopPanel:render()

    ---@type ISLabel
    local availableInstancesVal = self.availableInstancesLabelVal
    local amount = tostring(ClientState.GetAvailableInstances())
    availableInstancesVal:setName(amount)

end

return BeforeTopPanel



