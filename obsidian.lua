os.loadAPI("util");
os.loadAPI("miner");
os.loadAPI("turtleWrapper");

function mineObsidian()
  t = miner.Miner();
  t:noTriggers();
  go = true
  while go do
    turtle.digDown();
    t:moveN(1);

    local success,block = turtle.inspectDown();
    go = block.name == "minecraft:obsidian";
  end
end
mineObsidian()
