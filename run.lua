os.loadAPI("util");
os.loadAPI("miner");
os.loadAPI("turtleWrapper");
os.loadAPI("pathfinderTurtle");

t = pathfinderTurtle.Pathfinder();

t:setDestination(vector.new(3,0,0));

-- while t:isMoving() do
--   t:tick();
-- end

util.db("Done");
