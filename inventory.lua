os.loadAPI("util");
os.loadAPI("turtleWrapper");
os.loadAPI("miner");
os.loadAPI("pathfinderTurtle");

InventoryManager = util.createClass();

function table.clone(org)
  local tab = {}
  for k,v in pairs(org) do
    tab[k] = v;
  end
  return tab;
end

function InventoryManager:_init()
  self.savedItems = {};
end

function InventoryManager:save(item,quantity)
  self.savedItems[item] = quantity;
end

function InventoryManager:consolidateInventory()
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

function InventoryManager:isChest(block)
  if block.name == "minecraft:chest" then return true end;
  if string.find(block.name:lower(),"chest") then return true end;
  return false;
end

function InventoryManager:suckAll()
  for i=0,turtleUtil.getEmptySlots() do
    turtle.suck()
  end
end

function InventoryManager:depositItems()
  success, block = turtle.inspect()
  if success == false or not self:isChest(block) then
    util.db("no chest found!!")
    return
  end

  self:consolidateInventory();

  local saveCounts = table.clone(self.savedItems);
  for k,v in pairs(saveCounts) do
    util.db(k.." -- "..v);
  end


  for i=1,16 do
    item = turtle.getItemDetail(i);
    if item and saveCounts[item.name] ~= nil and saveCounts[item.name] > 0 then
      saveCounts[item.name] = saveCounts[item.name] - item.count;
      if saveCounts[item.name] < 0 then saveCounts[item.name] = 0 end
    else
      turtle.select(i)
      turtle.drop();
    end
  end
end
