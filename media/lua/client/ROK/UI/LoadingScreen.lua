local TextureScreen = require("ROK/UI/BaseComponents/TextureScreen")
--------------

-- TODO Add a fail safe


---@class LoadingScreen : TextureScreen
---@field text string
---@field textX number
---@field textY number
---@field isClosing boolean
---@field closingTime number
local LoadingScreen = TextureScreen:derive("LoadingScreen")

---@return LoadingScreen
function LoadingScreen:new()
    local o = TextureScreen:new()
    setmetatable(o, self)
    self.__index = self
    o.backgroundTexture = getTexture("media/textures/ROK_LoadingScreen.png")

    ---@cast o LoadingScreen
    LoadingScreen.instance = o
    return o
end

function LoadingScreen:renderTexture(alpha)
    TextureScreen.renderTexture(self, alpha)
    self:drawText(self.text, self.textX, self.textY, 1, 1, 1, alpha, UIFont.Massive)
end

function LoadingScreen:close()
    TextureScreen.close(self)
    LoadingScreen.instance = nil
end

-----

function LoadingScreen.Open()
    if not isClient() then return end       -- SP workaround
    if getPlayer():isDead() then return end -- Workaround to prevent issues when player is dead
    if LoadingScreen.instance ~= nil then return end
    debugPrint("Opening black screen")
    local loadginScreen = LoadingScreen:new()
    loadginScreen:initialise()
    loadginScreen:addToUIManager()
end

function LoadingScreen.Close()
    --debugPrint("Closing black screen")
    if LoadingScreen.instance then
        debugPrint("black screen instance available, closing")
        LoadingScreen.instance:startFade()
    end
end

Events.PZEFT_OnSuccessfulTeleport.Add(LoadingScreen.Close)



function LoadingScreen.HandleResolutionChange(oldW, oldH, w, h)
    if LoadingScreen.instance then
        LoadingScreen.instance:setWidth(w)
        LoadingScreen.instance:setHeight(h)
    end
end

Events.OnResolutionChange.Add(LoadingScreen.HandleResolutionChange)

return LoadingScreen