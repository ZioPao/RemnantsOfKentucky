objects = {}

local function CreateATVs()
  local name = "atv"
  local type = "ParkingStall"

  local x = 128
  local y = 364
  local width = 14
  local height = 5

  local pvpInstances
  if isServer() then
    pvpInstances = ServerData.PVPInstances.GetPvpInstances()
  else
    pvpInstances = ClientData.PVPInstances.GetPvpInstances()
  end

  --print("Reloading objects for BriaIsle")

  for _, inst in pairs(pvpInstances) do
    local modX = x + (inst.x * 300)
    local modY = y + (inst.y * 300)
    print(tostring(modX) .. " - " .. tostring(modY))
    table.insert(objects, { name = name, type = type, x = modX, y = modY, z = 0, width = width, height = height })
  end
end

CreateATVs()
-- objects = {
--   { name = "atv", type = "ParkingStall", x = 128, y = 364, z = 0, width = 14, height = 5 },
-- }
