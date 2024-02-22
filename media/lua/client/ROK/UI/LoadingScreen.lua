local TextureScreen = require("ROK/UI/BaseComponents/TextureScreen")
local ClientState = require("ROK/ClientState")

--------------


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

---@param sound string?
function LoadingScreen:initialise(sound)
    TextureScreen.initialise(self)

    if sound then
        getSoundManager():playUISound(sound)    -- "BoatSound"
    end

end
function LoadingScreen:renderTexture(alpha)
    TextureScreen.renderTexture(self, alpha)
    self:drawText(self.text, self.textX, self.textY, 1, 1, 1, alpha, UIFont.Massive)
end

function LoadingScreen:close()
    TextureScreen.close(self)
    LoadingScreen.instance = nil
end

--------------------------------


---@param sound string?
function LoadingScreen.Open(sound)
    if getPlayer():isDead() then return end -- Workaround to prevent issues when player is dead
    if LoadingScreen.instance ~= nil then return end
    debugPrint("Opening Loading screen")
    local loadginScreen = LoadingScreen:new()
    loadginScreen:initialise(sound)
    loadginScreen:addToUIManager()
end

function LoadingScreen.Close()
    if LoadingScreen.instance then
        LoadingScreen.instance:startFade()
    end
end


-- Can break Recap Panel if things are too fast (teleport + loading + recap rapidly in succession).
-- This is caused by the delayed teleport check
Events.PZEFT_OnSuccessfulTeleport.Add(function()
    -- If player is in raid, closing the loading screen is handled differently
    if ClientState.GetIsInRaid() then return end
    debugPrint("Trying to close Loading Screen after teleport")
    LoadingScreen.Close()
end)


function LoadingScreen.HandleResolutionChange(oldW, oldH, w, h)
    if LoadingScreen.instance then
        LoadingScreen.instance:setWidth(w)
        LoadingScreen.instance:setHeight(h)
    end
end

Events.OnResolutionChange.Add(LoadingScreen.HandleResolutionChange)

return LoadingScreen