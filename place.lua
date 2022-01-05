os.loadAPI("util");
os.loadAPI("miner");
os.loadAPI("turtleWrapper");

function placeTables()
  t = miner.Miner();
  t:noTriggers();
  go = true
  while go do
    turtleUtil.placeBlock();
  end
end
placeTables()
