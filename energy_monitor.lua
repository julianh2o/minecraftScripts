local component = require("component")
local inspect = require("inspect")
local event = require( "event" )
local sides = require( "sides" )
local computer = require( "computer" )
local os = require("os")
local gpu = component.gpu

function proxyDevice(type,shortCode)
  local devices = nil
  if type then
    devices = component.list(type)
  else
    devices = component.list()
  end
  for key, value in pairs(devices) do
    if not shortCode or key:sub(1,#shortCode) == shortCode then
      return component.proxy(key)
    end
  end
  return nil
end

local mainsPower = proxyDevice("redstone","5d58");
local smallReactor = proxyDevice("nc_fission_reactor","157f")
local largeReactor = proxyDevice("nc_fission_reactor","da9b")
local mainBattery = proxyDevice("basic_energy_cube","5e5f")

function clearScreen()
 local oldColor = gpu.getBackground( false )
 local w,h = gpu.getResolution()
 gpu.setBackground( 0x000000, false )
 gpu.fill( 1, 1, w, h, " " )
 gpu.setBackground( oldColor, false )
end

function loadDevices()
  local devices = component.list()
end

function clickWithin(clickX,clickY,x,y,w,h)
  if not clickX or not clickY then return false end
  if clickX < x then return false end
  if clickX > x+w then return false end
  if clickY < y then return false end
  if clickY > y+h then return false end
  return true
end

function centerText(x,y,w,text)
  local pad = (w - text:len()) / 2
  gpu.set(x+pad,y,text)
end

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

function button( x,y,w,text,fg,bg,clickX,clickY)
  local within = clickWithin(clickX,clickY,x,y,w,3)

  if within then
    gpu.setForeground(bg)
    gpu.setBackground(fg)
  else
    gpu.setForeground(fg)
    gpu.setBackground(bg)
  end

  gpu.fill(x,y,w,3," ")
  centerText(x,y+1,w,text)

  return within
end

function readSimple(cell,delay)
  local startCharge = cell.getEnergyStored()
  local startTime = computer.uptime()
  os.sleep(delay)
  local endCharge = cell.getEnergyStored()
  local endTime = computer.uptime()
  return (endCharge - startCharge) / (endTime - startTime)
end

function readCell(cell)
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

      setOutputs(mainsPower,0)
      os.sleep(readDelay);
      deltaWhileCharging = readSimple(cell,delay) / ticks_per_second
      setOutputs(mainsPower,1)
    else
      setOutputs(mainsPower,0)
      os.sleep(readDelay);
      deltaWhileCharging = readSimple(cell,delay) / ticks_per_second
      setOutputs(mainsPower,1)

      os.sleep(readDelay);
      deltaWhileDraining = (readSimple(cell,delay) / ticks_per_second)
    end

    local chargeRate = deltaWhileCharging
    local drainRate = deltaWhileDraining - deltaWhileCharging
    local net = chargeRate + drainRate

    return energy,max,chargeRate,drainRate,net
end

function drawBar(x,y,width,height,current,max,color,invert)
  if current > max then current = max end
 local oldColor = gpu.getBackground( false )
 gpu.setBackground(0x000000, false)
 w = math.floor( current * (width / max) )
 gpu.setBackground( 0x222222, false )
 gpu.fill(x, y, width, height, " " )
 gpu.setBackground( color, false )
 push = 0
 if invert then push = width - w end
 gpu.fill(x+push, y, w, height, " " )
 gpu.setBackground( oldColor, false )
end

function drawCurrentCapacity(y, value, maxVal)
 local oldColor = gpu.getBackground( false )
 gpu.setBackground(0x000000, false)
 gpu.fill( 3, y, 155, 2, " " )

 p = math.floor( (value / maxVal) * 100 )
 gpu.set( 3, y, "Main Battery: " .. tostring( p ) .. "%" )
 drawBar(3,y+1,155,2,value,maxVal,0x00ff00)
 if show then
   local valStr = "       "..formatBig( value ) .. " RF"
   local n = string.len( valStr )
   gpu.set( 158 - n, y, valStr )
 end
end

function drawChargeRate(chargeRate,drainRate,net,range)
  local width = 160
  local padding = 3
  local position = 10

  local barWidth = (width - padding * 2) / 2

  local valStr = string.format("%.0f",drainRate).." RF/t               "
  gpu.set(padding,position, "Drain: ".. valStr)
  drawBar(padding,position+1,barWidth,1,-drainRate,range,0xff0000,true)

  local valStr = "            Charge: "..string.format("%.0f",chargeRate).." RF/t"
  gpu.set(width - padding - string.len(valStr),position,valStr)
  drawBar(width / 2,position+1,barWidth,1,chargeRate,range,0x00ff00,false)

  if (net < 0) then
    negNet = -net
    posNet = 0
  else
    negNet = 0
    posNet = net
  end
  local valStr = "Net: "..string.format("%.0f",net).." RF/t               "
  gpu.set(padding,position+3, valStr)
  drawBar(padding,position+4,barWidth,2,negNet,range,0xff0000,true)
  drawBar(width / 2,position+4,barWidth,2,posNet,range,0x00ff00,false)

  -- local valStr = "       "..string.format("%.0f",net).." RF/t"
  -- local n = string.len( valStr )
  -- gpu.set( 158 - n, y+3, valStr )
end

function formatBig( value )
  local output = ""
  local valRem = 0
  local valPart = 0
  while value > 0 do
    valRem = math.floor( value / 1000 )
    valPart = value - (valRem * 1000)
    if output == "" then
      output = string.format( "%03d", valPart )
    elseif valRem == 0 then
      output = valPart .. "," .. output
    else
      output = string.format( "%03d", valPart ) .. "," .. output
    end
    value = valRem
  end
  return output
end

local touchX = nil
local touchY = nil
function touchEvent(_,_,x,y)
  touchX = x
  touchY = y
end

local settings = {}
function handleReactor(reactor,name,x,y,touchX,touchY)
  if settings[name] ~= nil then
    settings[name] = {}
    settings[name]["auto"] = false
  end

  local auto = settings[name]["auto"]

  gpu.setForeground(0xffffff)
  gpu.set(x,y)

  drawBar(x,y+1,155,2,value,maxVal,0x00ff00)

  bgColor = 0xff0000
  local generatorState = reactor.isProcessing()
  if generatorState then bgColor = 0x00ff00 end
  if button(x,y+2,12,"Generator",0xffffff,bgColor,touchX,touchY) then
    if generatorState then
      reactor.deactivate()
    else
      reactor.activate()
    end
  end
  bgColor = 0xff0000
  if auto then bgColor = 0x00ff00 end
  if button(x+14,y+2,12,"Auto",0xffffff,bgColor,touchX,touchY) then
    settings[name]["auto"] = not auto
  end

  if auto then
    local portion = energy / max
    if not lastAutoUpdate or computer.uptime() - lastAutoUpdate > 10 then
      if portion < .25 and not generatorState then
        reactor.activate()
        lastAutoUpdate = computer.uptime()
      end
      if portion > .75 and generatorState then
        reactor.deactivate()
        lastAutoUpdate = computer.uptime()
      end
    end
  end
end

function main(screenWidth,screenHeight)
  setOutputs(mainsPower,2)

  auto = false
  lastAutoUpdate = nil

  event.listen("touch", touchEvent)

  centerText(1,1,screenWidth,"Energy Monitor")
  while true do
    local energy,max,chargeRate,drainRate,net = readCell(mainBattery)

    gpu.setBackground(0x000000, false)
    drawCurrentCapacity(4, energy, max)
    drawChargeRate(chargeRate,drainRate,net, 3000)

    handleReactor(smallReactor,"Small Reactor",2,screenHeight-20,touchX,touchY)

    if button( screenWidth - 12,screenHeight - 3,12,"Exit",0xffffff,0x0000ff,touchX,touchY) then return end
    touchX = nil
    touchY = nil

    os.sleep(0.25)
  end
end

function msg(s)
  gpu.set(1,30,s)
end


local oldW, oldH = gpu.getResolution()
local oldFg = gpu.getForeground()
local oldBg = gpu.getBackground()

--Two energy devices.. gotta configure which one to use
-- local cell = proxyDevice("f4")
-- print(cell.getEnergyStored())
-- print(cell.getMaxEnergy())
gpu.setResolution(160, 50)
clearScreen()
main(160,50)
gpu.setForeground(oldFg)
gpu.setBackground(oldBg)
gpu.setResolution(oldW, oldH)
clearScreen()
print("Exiting..")
