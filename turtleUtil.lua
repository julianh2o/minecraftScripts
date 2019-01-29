function refuelIfNecessary()
  if turtle.getFuelLevel() < 20 then
    sipCoal()
  end
end

function sipCoal()
  index = findItem("minecraft:coal");
  if index ~= -1 then
    turtle.select(index);
    turtle.refuel(1)
    return true;
  end
  return false;
end

function selectByName(blockName)
  local index = findItem(blockName);
  if index == -1 then
    return false
  end

  turtle.select(index);
  return true;
end

function placeBlock(blockName)
  return selectByName(blockName) and turtle.place();
end

function placeBlockUp(blockName)
  return selectByName(blockName) and turtle.placeUp();
end

function placeBlockDown(blockName)
  return selectByName(blockName) and turtle.placeDown();
end

function findItem(name)
  for i=1,16 do
    local item = turtle.getItemDetail(i)
    if item ~= nil and item.name == name then
      return i;
    end
  end
  return -1;
end

function findFullStack(name)
  for i=1,16 do
    local item = turtle.getItemDetail(i)
    if item ~= nil and item.name == name and turtle.getItemSpace(i) == 0 then
      return i;
    end
  end
  return -1;
end

function getEmptySlots()
  n = 0;
  for i=1,16 do
    if turtle.getItemDetail(i) == nil then
      n = n + 1;
    end
  end
  return n;
end

function countItems(name)
  count = 0;
  for i=1,16 do
    item = turtle.getItemDetail(i);
    if item ~= nil and item.name == name then
      count = count + item.count;
    end
  end
  return count;
end

function isWorthless(item)
  worthless = {
  "minecraft:stone",
  "minecraft:cobblestone",
  "minecraft:sand",
  "minecraft:dirt",
  "minecraft:gravel",
  "minecraft:bedrock",
  "minecraft:lava",
  "minecraft:flowing_lava",
  "minecraft:water",
  "minecraft:flowing_water",
  }
  if item == nil then
    return true;
  end;
  return findInArray(worthless,item.name) ~= -1
end

function isOre(item)
  if item == nil then
    return false;
  end
  return string.find(item.name,"ore") or string.find(item.name,"Ore");
end

function consolidateInventory()
  underfilled = {}
  for i=1,16 do
    item = turtle.getItemDetail(i)
    if item ~= nil then
      uf = underfilled[item.name];
      if uf ~= nil then
        turtle.select(i);
        turtle.transferTo(uf);
        if turtle.getItemSpace(uf) == 0 then
          underfilled[item.name] = nil;
        end
      end
      item = turtle.getItemDetail(i);
      if item ~= nil then
        spaces = turtle.getItemSpace(i)
        if spaces > 0 then
          underfilled[item.name] = i;
        end
      end
    end
  end
end

function dirAdd(dir,a)
  newdir = dir + a;
  while(newdir < 1) do
    newdir = newdir + 4;
  end
  while(newdir > 4) do
    newdir = newdir - 4;
  end
  return newdir;
end

function formatPosition(pos,dir)
  return pos.x..", "..pos.y..", "..pos.z.." ("..dir..")";
end

function posInDir(pos,dir)
  local xtab = {1,0,-1,0};
  local ytab = {0,1,0,-1};
  return vector.new(pos.x + xtab[dir],pos.y + ytab[dir],pos.z);
end

function moveDistanceTo(startPos,endPos)
  local delta = endPos - startPos
  return math.abs(delta.x) + math.abs(delta.y) + math.abs(delta.z);
end
