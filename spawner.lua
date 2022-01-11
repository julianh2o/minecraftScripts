os.loadAPI("util");
os.loadAPI("miner");
os.loadAPI("turtleWrapper");
os.loadAPI("pathfinderTurtle");
os.loadAPI("builder");
os.loadAPI("inventory");


t = builder.Builder();
t:setHome(vector.new(-6,0,0))
t:setPos(vector.new(-6,0,0))

function doFloor(width,height,z)
  t:noTriggers()
  t.doDig = true
  t:setDestination(vector.new(0,0,z));
  t:waitUntilDestination();
  t:doTriggers()
  for i=0,height-1,2 do
    util.db("i="..i)
    t:setDestination(vector.new(0,i,z));
    t:waitUntilDestination();
    t:setDestination(vector.new(width,i,z));
    t:waitUntilDestination();
    t:setDestination(vector.new(width,i+1,z));
    t:waitUntilDestination();
    t:setDestination(vector.new(0,i+1,z));
    t:waitUntilDestination();
  end
end

function doWalls(width,height,z)
  t:noTriggers()
  t.doDig = true
  t:setDestination(vector.new(0,0,z));
  t:waitUntilDestination();

  t:doTriggers()
  t:setDestination(vector.new(width,0,z));
  t:waitUntilDestination();
  t:setDestination(vector.new(width,height,z));
  t:waitUntilDestination();
  t:setDestination(vector.new(0,height,z));
  t:waitUntilDestination();
  t:setDestination(vector.new(0,0,z));
  t:waitUntilDestination();
end

-- 0 = wall
-- 1 = water
-- 2 = water
-- 3 = water
-- 4 = water
-- 5 = water
-- 6 = water
-- 7 = water
-- 8 = water
-- 9 = hole
-- 10 = hole
-- 11 = water
-- 12 = water
-- 13 = water
-- 14 = water
-- 15 = water
-- 16 = water
-- 17 = water
-- 18 = water
-- 19 = wall

local waterFlow = 8;
local middleHole = 2;
local wall = 1;
local size = wall*2 + waterFlow * 2 + middleHole - 1;
local levels = 1;
local width = size;
local height = size;
local halfWidth = math.floor(width / 2);
local halfHeight = math.floor(height / 2);

local normalFloorFunction = function()
  if (t.pos.x == halfWidth or t.pos.x == halfWidth-1) and (t.pos.y == halfHeight or t.pos.y == halfHeight-1) then
    return false
  end

  return true
end

local funnelFloorFunction = function()
  --Handle edges
  if t.pos.x == 0 or t.pos.y == 0 or t.pos.x == width or t.pos.y == height then
    return true
  end

  if t.pos.x == halfWidth or t.pos.x == halfWidth-1 then
    return false
  end

  if t.pos.y == halfHeight or t.pos.y == halfHeight-1 then
    return false
  end

  return true
end

t:setFloorFunction(normalFloorFunction)
doFloor(width,height,0);

t:setFloorFunction(funnelFloorFunction)
doFloor(width,height,1);

doWalls(width,height,2);

--Return home
t:noTriggers();
t:setDestinationHome()
t:waitUntilDestination()
t:turnTo(1)
util.db("Done");
