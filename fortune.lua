os.loadAPI("util");
os.loadAPI("turtleWrapper");
os.loadAPI("miner");

FortuneMiner = util.createClass(miner.Miner);

function FortuneMiner:_init()
  miner.Miner.construct(self)
end

function Miner:beforeMove()
  if self.doDig and turtle.detect() then
    local success,block = turtle.inspect();
    if not success or self:isAvoided(block) then

    else
      turtle.dig();
    end
  end
end

function Miner:afterMove()
end

function Miner:isValuable(block)
  return string.find(block.name,"iron") or string.find(block.name,"coal");
end

function Miner:isAvoided(block)
  return string.find(block.name,"diamond");
end
