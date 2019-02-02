function mineStrip()
  t = miner.Miner();
  local length = 40;
  t:moveN(length);
  t:turnTo(2);
  t:moveN(1);
  t:turnTo(3);
  t:moveN(length);
  t:turnTo(4);
  t:go(vector.new(0,0,0));
  t:turnTo(3);
  t:depositItems();
  t:turnTo(2);
  t:moveN(3);
  t:turnTo(3);
  t:moveN(1);
  t:turnTo(1);
  t:moveN(1);
end

function makeSpiral()
  t = miner.Miner();
  local boxSize = 10;
  local halfSize = boxSize / 2;

  -- Get to initial position
  t:turnTo(4);
  t:moveN(halfSize);
  t:turnTo(1);

  -- Spiral
  for i=1,3 do
    t:moveN(boxSize)
    t:right();
  end
  boxSize = boxSize - 1;

  while boxSize > 0 do
    util.db("boxSize: "..boxSize.." ("..t:status()..")");
    for i=1,2 do
      t:moveN(boxSize)
      t:right();
    end
    boxSize = boxSize - 1;
  end

  -- Return to base
  t:go(vector.new(0,0,0));
  t:turnTo(1);
end
