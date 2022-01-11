os.loadAPI("util");
os.loadAPI("turtleUtil");

Pathfinder = util.createClass(turtleWrapper.Turtle);

function Pathfinder:_init()
  turtleWrapper.Turtle._init(self);
  self.destination = nil;
  self.strategy = nil;
  self.stalled = false;

  self.home = vector.new(0,0,0)
end

function Pathfinder:setHome(pos)
  self.home = pos
end

function Pathfinder:setDestinationHome(strategy)
  self:setDestination(self.home,strategy)
end

function Pathfinder:setDestination(pos,strategy)
  pos.x = math.floor(pos.x);
  pos.y = math.floor(pos.y);
  pos.z = math.floor(pos.z);
  util.db("# setDestination: "..pos:tostring());
  if not strategy then
    strategy = "xyz";
  end
  self.stalled = false;
  self.strategy = strategy;
  self.destination = pos;
end

function Pathfinder:isMoving()
  return not self:isAtDestination() and not self:isStalled();
end

function Pathfinder:isStalled()
  return self.stalled;
end

function Pathfinder:isAtDestination()
  return not self.destination or self.pos:tostring() == self.destination:tostring();
end

function Pathfinder:waitUntilDestination()
  while self:isMoving() do
    self:tick();
  end
end

function Pathfinder:tick()
  if not self:isAtDestination() then
    self:moveTowardDestination();
  end
end

function Pathfinder:moveTowardDestination()
  for i=1,string.len(self.strategy) do
    local axis = self.strategy:sub(i,i);
    local dist = self.destination[axis] - self.pos[axis];
    util.db("movingTowardDest - axis: "..axis.." dist: "..dist);
    if axis == "z" then
      util.db("z axis");
      if math.abs(dist) > 0 then
        util.db("math abs passed: ");
        self:vmoveN(1,dist < 0);
        return;
      end
    else
      if math.abs(dist) > 0 then
        util.db(axis.." "..dist);
        self:turnToAxis(axis, dist < 0);
        self:moveN(1);
        return;
      end
    end
  end
end
