local component = require("component")
local inspect = require("inspect")
local event = require( "event" )
local sides = require( "sides" )
local computer = require( "computer" )
local os = require("os")

function setOutputs(redstone,value)
  redstone.setOutput({
    [sides.left]=value,
    [sides.right]=value,
    [sides.forward]=value,
    [sides.back]=value,
    [sides.top]=value,
    [sides.bottom]=value
  })
end

function start()
  stopwatch = computer.uptime();
end

function stop(s)
  print(s.." took: "..(computer.uptime() - stopwatch))
end

local readings = {}
local window = 2;
local ticks_per_second = 20;
local lastTime = 0;
local redstone = component.proxy(component.list("redstone")())

function readDelta(cell,n,interval)
    local sum = 0
    local lastValue = -1
    local startTime = computer.uptime()
    for i=1,n+1 do
      value = cell.getEnergyStored()
      if lastValue ~= -1 then
        delta = value - lastValue
        print(delta)
        sum = sum + delta
      end
      lastValue = value
      os.sleep(interval)
    end
    local endTime = computer.uptime()
    print("sum: "..sum)
    print("n: "..n)
    print("n: "..interval)
    print("deltat: "..(endTime - startTime))
    return (sum / n) / (endTime - startTime)
end

function readSimple(cell,delay)
  local startCharge = cell.getEnergyStored()
  local startTime = computer.uptime()
  os.sleep(delay)
  local endCharge = cell.getEnergyStored()
  local endTime = computer.uptime()
  return (endCharge - startCharge) / (endTime - startTime)
end

function readCell(shortCode)
    local cell = proxyDevice("energy_device",shortCode);
    local ticks_per_second = 20;
    local energy = cell.getEnergyStored()
    local max = cell.getMaxEnergyStored()

    local readCount = 5
    local readInterval = .1
    local readDelay = .07
    local delay = .5

    local deltaWhileDraining
    local deltaWhileCharging
    if energy > max/2 then
      deltaWhileDraining = (readSimple(cell,delay) / ticks_per_second)

      setOutputs(redstone,0)
      os.sleep(readDelay);
      deltaWhileCharging = readSimple(cell,delay) / ticks_per_second
      setOutputs(redstone,1)
    else
      setOutputs(redstone,0)
      os.sleep(readDelay);
      deltaWhileCharging = readSimple(cell,delay) / ticks_per_second
      setOutputs(redstone,1)

      os.sleep(readDelay);
      deltaWhileDraining = (readSimple(cell,delay) / ticks_per_second)
    end

    local chargeRate = deltaWhileCharging
    local drainRate = deltaWhileDraining - deltaWhileCharging
    local net = chargeRate + drainRate

    return energy,max,chargeRate,drainRate,net
end

function proxyDevice(type,shortCode)
  local devices = component.list(type)
  for key, value in pairs(devices) do
    if not shortCode or key:sub(1,#shortCode) == shortCode then
      return component.proxy(key)
    end
  end
  return nil
end

setOutputs(redstone,2)
while true do
  local _,_,x,y = event.pull( 1, "touch" )
  local count = 0
  if x and y then goto quit end

  loopDelta = ticks_per_second*(computer.uptime() - lastTime);
  lastTime = computer.uptime();

  local energy,max,chargeRate,drainRate,net = readCell("f4e5")
  print(energy," -- ",max," -- ",string.format("%.0f",chargeRate)," -- ",string.format("%.0f",drainRate)," -- ",string.format("%.0f",net));

  os.sleep(0.25)
end

::quit::
setOutputs(redstone,0)
print("Exiting..")
