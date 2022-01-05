os.loadAPI("util");
os.loadAPI("turtleWrapper");

Miner = util.createClass(turtleWrapper.Turtle);

function Miner:_init()
  self.maxMoveFailCount = 5;
  self.pos = vector.new(0,0,0);
  self.dir = 1;
  self.minerStatus = nil;

  self.torchSide = "left";

  self:doTriggers();
end

function Miner:noTriggers()
  self.doDig = false;
  self.placeFloor = false;
  self.doTunnel = false;
  self.placeTorches = false;
  self.digOre = false;
  self.doInventoryCheck = false;
end

function Miner:doTriggers()
  self.doDig = true;
  self.placeFloor = true;
  self.doTunnel = true;
  self.placeTorches = true;
  self.digOre = true;
  self.doInventoryCheck = true;
end

function Miner:beforeMove(vertical,reversed)
  if self.doDig and turtle.detect() then
    turtle.dig();
  end
  return true;
end

function Miner:afterMove()
  self:makeTunnel();
  self:doPlaceTorches();
  self:doMineVein();
  self:doPlaceFloor();
  self:performInventoryCheck();
end

function Miner:isValuable(block)
  return turtleUtil.isOre(block);
end

function Miner:makeTunnel()
  if self.doTunnel and turtle.detectUp() then
    local success,block = turtle.inspectUp();
    if success and self:isValuable(block) then
      self:mineVein(vector.new(self.pos.x,self.pos.y,self.pos.z+1));
    end
    if success and block.name ~= "minecraft:torch" then
      turtle.digUp();
    end
  end
end

function Miner:doPlaceTorches()
  if self.placeTorches and self.pos.x % 5 == 0 and self.pos.y % 5 == 0 then
    self:noTriggers();

    turtle.digUp();
    self:vmove();
    if self.torchSide == "left" then
      self:right();
      turtle.dig();
      self:left();
    else
      self:left();
      turtle.dig();
      self:right();
    end
    self:vmove(true);

    turtleUtil.placeBlockUp("minecraft:torch");

    self:doTriggers();
  end
end

function Miner:doMineVein()
  if self.digOre and turtle.detectDown() then
    local success,block = turtle.inspectDown();
    if success and self:isValuable(block) then
      self:mineVein(vector.new(self.pos.x,self.pos.y,self.pos.z-1));
    end
  end
end

function Miner:performInventoryCheck()
  if self.doInventoryCheck and turtleUtil.getEmptySlots() < 3 then
    self:noTriggers();
    self.doDig = true;

    local returnTo = vector.new(self.pos.x,self.pos.y,self.pos.z);
    self:go(vector.new(0,0,0));
    self:turnTo(3);
    self:depositItems();
    self:go(returnTo);

    self:doTriggers();
  end
end

function Miner:mineVein(pos)
  util.db("# mineVein "..pos:tostring());
  self.minerStatus = {};
  util.db("saving "..self.pos:tostring());
  self.minerStatus.origin = vector.new(self.pos.x,self.pos.y,self.pos.z);
  self.minerStatus.originalDir = self.dir;
  self.minerStatus.checked = {};
  self.minerStatus.depth = 1;
  self:noTriggers();

  self:markChecked(self.pos);

  self:minePosition(pos);
  self:go(pos);
  self:searchForOre();

  util.db("done mining, going to: "..self.minerStatus.origin:tostring());
  self:go(self.minerStatus.origin);
  self:turnTo(self.minerStatus.originalDir);

  self.minerStatus = nil;
  self:doTriggers();
end

function getAdjacentPositions(pos)
  local rels = {};
  table.insert(rels,vector.new(0,0,1));
  table.insert(rels,vector.new(0,0,-1));
  table.insert(rels,vector.new(-1,0,0));
  table.insert(rels,vector.new(1,0,0));
  table.insert(rels,vector.new(0,-1,0));
  table.insert(rels,vector.new(0,1,0));

  local absolutes = {};
  for i=1,table.getn(rels) do
    table.insert(absolutes,pos+rels[i]);
  end

  return absolutes;
end

function Miner:omitCheckedPositions(locs)
  local keep = {};
  for i=1,table.getn(locs) do
    if not self:hasChecked(locs[i]) then
      table.insert(keep,locs[i]);
    end
  end

  return keep;
end

function Miner:lookForOre(pos)
  util.db(string.rep("   ",self.minerStatus.depth).."# lookForOre "..pos:tostring());

  if turtleUtil.moveDistanceTo(self.pos,pos) ~= 1 then
    util.db("Invalid look for ore call! Only allows adjacent blocks");
    return false;
  end

  self:markChecked(pos);

  local delta = pos - self.pos;
  if delta.z == 1 then
    u, up = turtle.inspectUp();
    return u and self:isValuable(up)
  end

  if delta.z == -1 then
    d, down = turtle.inspectDown();
    return d and self:isValuable(down)
  end

  self:turnToward(pos);
  f, forward = turtle.inspect();
  return f and self:isValuable(forward);
end

function Miner:searchForOre()
  self.minerStatus.depth = self.minerStatus.depth + 1;
  util.db(string.rep("   ",self.minerStatus.depth).."# searchForOre ");
  local searchLocations = getAdjacentPositions(self.pos);
  searchLocations = self:omitCheckedPositions(searchLocations);

  util.db(string.rep("   ",self.minerStatus.depth).." searching in: "..util.printVectors(searchLocations));

  --TODO sort these so that searching takes less time
  local startPos = vector.new(self.pos.x,self.pos.y,self.pos.z);
  for i=1,table.getn(searchLocations) do
    util.db(string.rep("   ",self.minerStatus.depth).."Searching "..i.." at "..searchLocations[i]:tostring());
    if self:lookForOre(searchLocations[i]) then
      self:minePosition(searchLocations[i]);
      self:go(searchLocations[i]);
      self:searchForOre();
      self:go(startPos);
    end
  end

  self.minerStatus.depth = self.minerStatus.depth - 1;
end

function Miner:markChecked(pos)
  self.minerStatus.checked[positionToKey(pos)] = true;
end

function Miner:hasChecked(pos)
  return self.minerStatus.checked[positionToKey(pos)];
end

function Miner:minePosition(pos)
  util.db(string.rep("   ",self.minerStatus.depth).."# minePosition "..pos:tostring());
  self:markChecked(pos);

  if turtleUtil.moveDistanceTo(self.pos,pos) ~= 1 then
    util.db("Invalid mine position call! Only allows adjacent blocks");
  end

  local delta = pos - self.pos;
  if (delta.z == 1) then
    util.db(string.rep("   ",self.minerStatus.depth).."Ore above, mining");
    turtle.digUp();
  elseif (delta.z == -1) then
    util.db(string.rep("   ",self.minerStatus.depth).."Ore below, mining");
    turtle.digDown();
  else
    util.db(string.rep("   ",self.minerStatus.depth).."Turning toward and mining: "..pos:tostring());
    self:turnToward(pos);
    turtle.dig();
  end
end

function positionToKey(pos)
  return pos.x.."_"..pos.y.."_"..pos.z;
end
