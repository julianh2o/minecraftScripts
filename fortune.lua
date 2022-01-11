os.loadAPI("util");
os.loadAPI("turtleWrapper");
os.loadAPI("miner");
os.loadAPI("pathfinderTurtle");
os.loadAPI("inventory");

FortuneMiner = util.createClass(pathfinderTurtle.Pathfinder);

function FortuneMiner:_init()
  pathfinderTurtle.Pathfinder._init(self);
  self.offset = vector.new(0,0,0);
  self.report = {};

  self.inv = inventory.InventoryManager();
  self.inv:save("minecraft:torch",64);
  self.inv:save("minecraft:coal",64);

  self.torchSide = "left";
  self.avoidDirection = "left";
  self.avoiding = false;
  self.torchInterval = 5;
  self.torchSteps = 0;
  self:doTriggers();
end

function FortuneMiner:noTriggers()
  self.doDig = false;
  self.doTunnel = false;
  self.placeTorches = false;
  self.doInventoryCheck = false;
  self.placeFloor = false;
end

function FortuneMiner:doTriggers()
  self.doDig = true;
  self.doTunnel = true;
  self.placeTorches = true;
  self.doInventoryCheck = true;
  self.placeFloor = true;
end

function FortuneMiner:beforeMove(vertical,reversed)
  self:checkAvoidance(vertical,reversed);

  return true;
end

function FortuneMiner:checkAvoidance(vertical,reversed)
  if self.doDig then
    if self:doDetect(vertical,reversed) then
      local success, block = self:doInspect(vertical,reversed)
      if not success or self:isAvoided(block) then
        util.db("Refusing to dig block!");
      else
        self:doMoveDig(vertical,reversed);
      end
    end
  end
end

function FortuneMiner:doDetect(vertical,reversed)
  if not vertical and not reversed then
    return turtle.detect();
  elseif vertical and not reversed then
    return turtle.detectUp();
  elseif vertical and reversed then
    return turtle.detectDown();
  end
end

function FortuneMiner:doInspect(vertical,reversed)
  if not vertical and not reversed then
    return turtle.inspect();
  elseif vertical and not reversed then
    return turtle.inspectUp();
  elseif vertical and reversed then
    return turtle.inspectDown();
  end
end

function FortuneMiner:doMoveDig(vertical,reversed)
  if not vertical and not reversed then
    turtle.dig();
  elseif vertical and not reversed then
    turtle.digUp();
  elseif vertical and reversed then
    turtle.digDown();
  end
end

function FortuneMiner:afterMove()
  self:makeTunnel();
  self:doPlaceTorches();
  self:performInventoryCheck();
  self:reportDiamonds();
  self:doPlaceFloor();
end

function FortuneMiner:reportDiamonds()
  if self:inspectingDiamond(turtle.inspect) or self:inspectingDiamond(turtle.inspectUp) or self:inspectingDiamond(turtle.inspectDown) then
    util.db("FOUND Diamond ore ("..self.pos:tostring()..")");
    table.insert(self.report,"FOUND Diamond ore ("..self.pos:tostring()..")");
  end
end

function FortuneMiner:doReport()
  util.db("\n###### Report ######")
  for i=1,table.getn(self.report) do
    util.db(self.report[i]);
  end
end

function FortuneMiner:performInventoryCheck()
  if self.doInventoryCheck and turtleUtil.getEmptySlots() < 3 then
    self:noTriggers();
    self.doDig = true;

    local returnTo = vector.new(self.pos.x,self.pos.y,self.pos.z);
    local lastDest = vector.new(self.destination.x,self.destination.y,self.destination.z);
    local strategy = self.strategy;

    self:setDestination(vector.new(0,0,0),"xyz");
    self:waitUntilDestination();

    self:turnTo(3);
    self.inv:depositItems();
    self:turnTo(1);

    self:setDestination(returnTo,"zyx");
    self:waitUntilDestination();

    self:setDestination(lastDest,strategy);

    self:doTriggers();
  end
end

function FortuneMiner:doPlaceTorches()
  if self.placeTorches and turtleUtil.countItemsMatching("torch") > 0 and self.torchSteps > self.torchInterval then
    self.torchSteps = 0;
    util.db("Placing torch: "..self.pos:tostring());
    self:noTriggers();

    if self.torchSide == "left" then self:left() else self:right() end
    turtle.dig();
    turtleUtil.placeBlockMatching("torch");
    if self.torchSide == "left" then self:right() else self:left() end

    self:doTriggers();
  else
    self.torchSteps = self.torchSteps + 1;
  end
end

function FortuneMiner:makeTunnel()
  if self.doTunnel and turtle.detectUp() then
    if not self:inspectingAvoided(turtle.inspectUp) then
      turtle.digUp();
    end
  end

  if not self.avoiding and self.offset:length() > 0 then
    self:doUnavoid();
  end
end

function FortuneMiner:doAvoid()
  util.db("# doAvoid");
  self.avoiding = true;

  if self.avoidDirection == "left" then self:left() else self:right() end
  if self:moveN(1) then
    self.offset = turtleUtil.posInDir(self.offset,self.dir);
  end
  if self.avoidDirection == "left" then self:right() else self:left() end

  self.avoiding = false;

  self:checkAvoidance();
end

function FortuneMiner:doUnavoid()
  util.db("# doUnavoid: "..self.offset:tostring());
  self.avoiding = true;

  local saveDir = self.dir;
  dir,dist = self:dirAndDistBetween(self.offset,vector.new(0,0,0));
  self:turnTo(dir);
  while dist > 0 and not self:inspectingAvoided(turtle.inspect) do
    if self:moveN(1) then
      util.db("unavoid correct 1. remain: "..dist);
      dist = dist - 1;
      self.offset = turtleUtil.posInDir(self.offset,self.dir);
    end
  end
  self:turnTo(saveDir);

  self.avoiding = false;
end

function FortuneMiner:isValuable(block)
  return string.find(block.name,"iron") or string.find(block.name,"coal");
end

function FortuneMiner:isAvoided(block)
  --if block.name == "minecraft:torch" then return true end;
  return string.find(block.name:lower(),"diamond");
end

function FortuneMiner:inspectingAvoided(f)
  local success, block = f();
  return success and self:isAvoided(block);
end

function FortuneMiner:inspectingDiamond(f)
  local success, block = f();
  return success and string.find(block.name:lower(),"diamond");
end
