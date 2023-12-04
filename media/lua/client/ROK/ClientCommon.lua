local ClientCommon = {}


function ClientCommon.GiveStarterKit(playerObj)
    for i=1, #PZ_EFT_CONFIG.StarterKit do
        ---@type starterKitType
        local element = PZ_EFT_CONFIG.StarterKit[i]
        playerObj:getInventory():AddItems(element.fullType, element.amount)
    end
end

return ClientCommon