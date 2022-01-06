os.loadAPI("util");
os.loadAPI("miner");
os.loadAPI("turtleWrapper");
os.loadAPI("pathfinderTurtle");
os.loadAPI("builder");
os.loadAPI("inventory");

local home = vector.new(0,-3,0);

t = builder.Builder();

function doFloor(width,height)
  t:noTriggers()
  t:setDestination(vector.new(0,0,0));
  t:waitUntilDestination();
  t:doTriggers()
  for i=0,height,2 do
    util.db("i="..i)
    t:setDestination(vector.new(0,i,0));
    t:waitUntilDestination();
    t:setDestination(vector.new(width,i,0));
    t:waitUntilDestination();
    t:setDestination(vector.new(width,i+1,0));
    t:waitUntilDestination();
    t:setDestination(vector.new(0,i+1,0));
    t:waitUntilDestination();
  end
end

local size = 18;
local levels = 1;
local width = size;
local height = size;
local halfWidth = math.floor(width / 2);

--t.offset = home;
t:setDestination(vector.new(0,3,0));
t:waitUntilDestination();

--doFloor(width,height);

--Return home
--t:setDestination(home,"xyz");
--t:waitUntilDestination();
util.db("Done");
