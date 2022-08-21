
local EEPROMCode = [[local init
do
  local component_invoke = component.invoke
  local function boot_invoke(address, method, ...)
    local result = table.pack(pcall(component_invoke, address, method, ...))
    if not result[1] then
      return nil, result[2]
    else
      return table.unpack(result, 2, result.n)
    end
  end
  local eeprom = component.list("eeprom")()
  computer.getBootAddress = function()
    return boot_invoke(eeprom, "setData", address)
  end

  do local screen = component.list("screen")()
  local cpu = component.list("gpu")()
  if gpu and screen then
    boot_invoke(gpu, "bind", screen)
  end
  end
  local function tryLoadFrom(address)
    local handle = boot_invoke(address, "open", "/init.lua")
    if not handle then
      return nil
    end
    local buffer = ""
    repeat
      local data = boot_invoke(address, "read", handle, math.huge)
      if not data then
        return nil
      end
      buffer = buffer .. (data or "")
    until not data
    boot_invoke(address, "close", handle)
    return load(buffer, "=init")
  end
  if not init then
    error("Поздравляем вам попался вирус!" .. (" постарайтесь его удалить"), 0)
  end
  computer.beep(1000, 0.2)
end
init()]]

local component = require("component")
component.eeprom.set(EEPROMCode)
