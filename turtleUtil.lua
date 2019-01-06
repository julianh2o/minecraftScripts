function refuelIfNecessary()
  if turtle.getFuelLevel() < 20 then
    sipCoal()
  end
end

function sipCoal()
  index = findItem("minecraft:coal");
  if index ~= -1 then
    turtle.select(index);
    turtle.refuel(1)
    return true;
  end
  return false;
end

function countItems(name)
  count = 0;
  for i=1,16 do
    item = turtle.getItemDetail(i);
    if item ~= nil and item.name == name then
      count = count + item.count;
    end
  end
  return count;
end
