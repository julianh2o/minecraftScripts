os.loadAPI("util");
os.loadAPI("miner");
os.loadAPI("turtleWrapper");
os.loadAPI("pathfinderTurtle");
os.loadAPI("fortune");
os.loadAPI("inventory");

t = fortune.FortuneMiner();

local size = 19;
local levels = 3;
local width = size;
local halfWidth = math.floor(width / 2);
local depth = size;
local startY = -halfWidth;

for level=1,levels do
  local offset = 0;
  local z = 3 * (level - 1);
  if level % 2 == 0 then offset = 1 end;
  t:setDestination(vector.new(0,offset + startY,z),"yxz");
  t:waitUntilDestination();
  t:turnTo(1);

  for i=1,halfWidth+1 do
    util.db("Level "..level.." row "..i);
    local x = depth
    if i % 2 == 0 then
      x = 0
      t.torchSide = "right";
    else
      t.torchSide = "left";
    end

    local y = startY + 2*i;
    if i == halfWidth+1 then
      y = y - 2;
    end

    t:setDestination(vector.new(x,offset + y,z),"xyz");
    t:waitUntilDestination();
  end
end

--Return home
t:setDestination(vector.new(0,0,0),"xyz");
t:waitUntilDestination();

t:turnTo(3);
t.inv:depositItems();
t:turnTo(1);

util.db("Done");
