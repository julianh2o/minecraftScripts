os.loadAPI("util");
os.loadAPI("miner");
os.loadAPI("turtleWrapper");

local chest = peripheral.wrap("right");
local ae = peripheral.wrap("left");

function getCraftingCPU(name)
  local cpus = ae.getCraftingCPUs();
  for k,v in pairs(cpus) do
    if v.name == name then
      return v;
    end
  end
  return nil;
end

function getAvailableCraftingCPUs()
  local cpus = ae.getCraftingCPUs();
  local available = {};
  for k,v in pairs(cpus) do
    if v.busy == false then
      table.insert(available,v);
    end
  end
  return available;
end

while true do
  local refiller = getCraftingCPU("refiller");
  if refiller and not refiller.busy then
    local items = chest.getAllStacks();
    for k,v in pairs(items) do
      local item = v.basic();
      local desiredCount = item.qty * 10;

      local ae_info = ae.getItemDetail(item);
      if ae_info ~= nil then
        local currentCount = ae_info.basic().qty;
        if currentCount < desiredCount then
          local craftCount = desiredCount - currentCount;
          util.db("Crafting "..craftCount.." "..item.display_name);

          ae.requestCrafting(item,craftCount,"refiller");
          break;
        end
      end
    end
  end
  os.sleep(10);
end
