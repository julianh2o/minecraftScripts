os.loadAPI("util");
os.loadAPI("turtleUtil");

Turtle = util.createClass();

position_file = "_turtlePosition";

function Turtle:_init()
  util.db("init called from turtle wrapper");
  -- self.pos = util.readJsonFile(position_file) or {x=0,y=0,z=0,dir=1};
  --self.pos = {x=0,y=0,z=0,dir=1};
  --TODO load from file
  self.maxMoveFailCount = 1000;
  self.pos = vector.new(0,0,0);
  self.dir = 1;
end

function Turtle:fuelCheck(num)
  return turtle.getFuelLevel() > num;
end

function Turtle:status()
  return turtleUtil.formatPosition(self.pos,self.dir);
end

function Turtle:turnToward(pos)
  local d = pos - self.pos;
  local dir = 1;

  if (math.abs(d.x) > math.abs(d.y)) then
    dir = 1;
    if d.x < 0 then
      dir = turtleUtil.dirAdd(dir,2);
    end
    dist = math.abs(d.x);
  else
    dir = 2;
    if d.y < 0 then
      dir = turtleUtil.dirAdd(dir,2);
    end
    dist = math.abs(d.y);
  end
  self:turnTo(dir);
  return dist;
end

function Turtle:beforeMove()
end

function Turtle:afterMove()
end

function Turtle:moveN(dist)
  local failCount = 0;
  while (dist > 0) do
    if failCount > self.maxMoveFailCount then
      return false;
    end
    self:beforeMove();
    if self:move() then
      dist = dist - 1;
      self:afterMove();
    else
      failCount = failCount + 1;
    end
  end
  return true;
end

function Turtle:vmoveN(dist,down)
  local failCount = 0;
  while (dist > 0) do
    if failCount > self.maxMoveFailCount then
      return false;
    end
    self:beforeMove();
    if self:vmove(down) then
      dist = dist - 1;
      self:afterMove();
    else
      failCount = failCount + 1;
    end
  end
  return true;
end

function Turtle:move(back)
  local success = false;
  local moveDirection = self.dir;
  turtleUtil.refuelIfNecessary();
  if back then
    success = turtle.back();
    moveDirection = turtleUtil.dirAdd(self.dir,2);
  else
    success = turtle.forward()
  end

  if success then
    self.pos = turtleUtil.posInDir(self.pos,moveDirection);
    util.writeJsonFile(position_file,self.pos);
  else
    util.db("Move failed!");
  end

  return success;
end

function Turtle:vmove(down)
  turtleUtil.refuelIfNecessary();
  if down then
    if turtle.down() then
      self.pos.z = self.pos.z - 1;
      util.writeJsonFile(position_file,self.pos);
      return true;
    end
  else
    if turtle.up() then
      self.pos.z = self.pos.z + 1;
      util.writeJsonFile(position_file,self.pos);
      return true;
    end
  end
  return false;
end

function Turtle:forward()
  self:move();
end

function Turtle:back()
  self:move(true);
end

function Turtle:left()
  if turtle.turnLeft() then
    self.dir = turtleUtil.dirAdd(self.dir,-1);
    util.writeJsonFile(position_file,self.pos);
  else
    util.db("Failed to turn left");
  end
end

function Turtle:right()
  if turtle.turnRight() then
    self.dir = turtleUtil.dirAdd(self.dir,1);
    util.writeJsonFile(position_file,self.pos);
  else
    util.db("Failed to turn right");
  end
end

function Turtle:turnTo(dir)
  if math.abs(self.dir-dir) == 2 then
    self:left();
    self:left();
    return;
  end

  if math.abs(self.dir-dir) == 1 then
    if self.dir > dir then
      self:left();
    end

    if self.dir < dir then
      self:right();
    end
  end

  if math.abs(self.dir-dir) == 3 then
    if self.dir < dir then
      self:left();
    end

    if self.dir > dir then
      self:right();
    end
  end
end

-- Static functions
