local component = require("component")
local inspect = require("inspect")
local event = require( "event" )
local sides = require( "sides" )
local computer = require( "computer" )
local os = require("os")
local gpu = component.gpu

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

function progressBar( label, y, value, maxVal, color, show, unit )
 local oldColor = gpu.getBackground( false )
 gpu.setBackground(0x000000, false)
 gpu.fill( 3, y, 155, 2, " " )
 w = math.floor( value * (155 / maxVal) )
 p = math.floor( (w / 155) * 100 )
 gpu.set( 3, y, label .. ": " .. tostring( p ) .. "%" )
 gpu.setBackground( 0x222222, false )
 gpu.fill( 3, y+1, 155, 1, " " )
 gpu.setBackground( color, false )
 gpu.fill( 3, y+1, w, 1, " " )
 gpu.setBackground( oldColor, false )
 if show then
   local valStr = formatBig( value ) .. unit
   local n = string.len( valStr )
   gpu.set( 158 - n, y, valStr )
 end
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

function main(screenWidth,screenHeight)
  centerText(1,1,screenWidth,"Energy Monitor")
  while true do
    local _,_,x,y = event.pull(1, "touch" )
    if x and y then gpu.set(5,5,"click: "..x..","..y) end

    local cell = proxyDevice("energy_device","f4e5");
    energy = cell.getEnergyStored()
    max = cell.getMaxEnergyStored()
    progressBar("Main Battery", 4 , cell.getEnergyStored(), cell.getMaxEnergyStored() , 0x00bb00, true, "RF" )
    gpu.setForeground(0xff0000)
    gpu.setBackground(0xFF00FF)

    bgColor = 0xff0000
    local generator = proxyDevice("nc_fission_reactor")
    local generatorState = generator.isProcessing()
    if generatorState then bgColor = 0x00ff00 end
    if button( screenWidth - 12,screenHeight - 7,12,"Generator",0xffffff,bgColor,x,y) then
      if generatorState then
        generator.deactivate()
      else
        generator.activate()
      end
    end
    if button( screenWidth - 12,screenHeight - 3,12,"Exit",0xffffff,0x0000ff,x,y) then return end

    os.sleep(0.25)
  end
end

function msg(s)
  gpu.set(1,30,s)
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

local oldW, oldH = gpu.getResolution()
local oldFg = gpu.getForeground()
local oldBg = gpu.getBackground()

--Two energy devices.. gotta configure which one to use
-- local cell = proxyDevice("f4")
-- print(cell.getEnergyStored())
-- print(cell.getMaxEnergyStored())
gpu.setResolution(160, 50)
clearScreen()
main(160,50)
gpu.setForeground(oldFg)
gpu.setBackground(oldBg)
gpu.setResolution(oldW, oldH)
clearScreen()
print("Exiting..")
