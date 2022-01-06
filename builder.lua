os.loadAPI("util");
os.loadAPI("turtleWrapper");
os.loadAPI("miner");
os.loadAPI("pathfinderTurtle");
os.loadAPI("inventory");

Builder = util.createClass(pathfinderTurtle.Pathfinder);

function Builder:_init()
  pathfinderTurtle.Pathfinder._init(self);
  self.offset = vector.new(0,0,0);

  self.inv = inventory.InventoryManager();
  self.inv:save("minecraft:torch",64);
  self.inv:save("minecraft:coal",64);

  self:doTriggers();
end

function Builder:beforeMove(vertical,reversed)
  return true;
end

function Builder:afterMove()
  return true;
end

function Builder:noTriggers()
  self.doInventoryCheck = false;
  self.placeFloor = false;
end

function Builder:doTriggers()
  self.doInventoryCheck = true;
  self.placeFloor = true;
end

function Builder:doDetect(vertical,reversed)
  if not vertical and not reversed then
    return turtle.detect();
  elseif vertical and not reversed then
    return turtle.detectUp();
  elseif vertical and reversed then
    return turtle.detectDown();
  end
end

function Builder:doInspect(vertical,reversed)
  if not vertical and not reversed then
    return turtle.inspect();
  elseif vertical and not reversed then
    return turtle.inspectUp();
  elseif vertical and reversed then
    return turtle.inspectDown();
  end
end

function Builder:doMoveDig(vertical,reversed)
  if not vertical and not reversed then
    turtle.dig();
  elseif vertical and not reversed then
    turtle.digUp();
  elseif vertical and reversed then
    turtle.digDown();
  end
end

function Builder:afterMove()
  self:performInventoryCheck();
  self:doPlaceFloor();
end

function Builder:doPlaceFloor()
  if self.placeFloor and not turtle.detectDown() then
    turtleUtil.placeBlockDown("minecraft:cobblestone");
  end
end

function Builder:performInventoryCheck()
  if self.doInventoryCheck and turtleUtil.getEmptySlots() < 3 then
    --Fix me
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