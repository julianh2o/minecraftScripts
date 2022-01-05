local internet = require("internet")
local io = require("io")
local component = require("component")

local args = {...}

if #args > 0 then
  local devices = component.list(args[1])
  for key, value in pairs(devices) do
    print(key.." "..value)
    local device = component.proxy(key)

    if #args > 1 then
      print(device.type.." "..device.slot.." "..device[args[2]]())
    else
      for key, value in pairs(device) do
        print("   "..key)
      end
    end
  end
else
  local devices = component.list()
  for key, value in pairs(devices) do
    print(key.." "..value)
  end
end
