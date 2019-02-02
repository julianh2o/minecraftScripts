os.loadAPI("util");
os.loadAPI("turtleUtil");

Pathfinder = util.createClass(turtleWrapper.Turtle);

function Pathfinder:_init()
  util.db("calling init");
  turtleWrapper.Turtle._init(self);
  util.db(self.pos:tostring());
  self.destination = nil;
  self.strategy = nil;
  self.stalled = false;
end

function Pathfinder:setDestination(pos,strategy)
  if not strategy then
    strategy = "xyz";
  end
  self.strategy = strategy;
  self.destination = pos;
end

function Pathfinder:isMoving()
  return not Pathfinder:isAtDestination() and not self:isStalled();
end

function Pathfinder:isStalled()
  return self.stalled;
end

function Pathfinder:isAtDestination()
  -- return self.pos:tostring() ~= self.destination:tostring();
end

function Pathfinder:tick()
  util.db("Tick");
  if self:isAtDestination() then
    self:moveTowardDestination();
  end
end

function Pathfinder:moveTowardDestination()
  for i=1,string.len(self.strategy) do
    local axis = self.strategy[i];
    util.db(axis);
  end
end
