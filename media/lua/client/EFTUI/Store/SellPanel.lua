-- TODO Users should be able to drag n drop items in this panel to sell them. Opens confirmation panel. Compatible with Tarkov UI

SellPanel = ISPanel:derive("SellPanel")


function SellPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    return o
end
