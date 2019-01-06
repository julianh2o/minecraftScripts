dir = 1
cx = 0
cy = 0
cz = 0

function main()
  turtle.refuel(1)
  print("Remaining Fuel: ",turtle.getFuelLevel());

  checkOre();
end

function unused()
  waypoints = generateWaypoints(0,0,0,50,50,30);

  for i=1,table.getn(waypoints) do
    print(waypoints[i].x..","..waypoints[i].y..","..waypoints[i].z)
  end

  goto(waypoints[1].x,waypoints[1].y,waypoints[1].z,false,true,true,statusAndInventoryCheck)
  if mineWaypoints(waypoints) then
    print("Mining complete!")
    returnToBase(true);
    right();
    right();
  else
    print("Mining incomplete.. out of fuel");
    right();
    right();
  end
end

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

function findItem(name)
  for i=1,16 do
    item = turtle.getItemDetail(i)
    if item ~= nil and item.name == name then
      return i;
    end
  end
  return -1;
end

function findFullStack(name)
  for i=1,16 do
    item = turtle.getItemDetail(i)
    if item ~= nil and item.name == name and turtle.getItemSpace(i) == 0 then
      return i;
    end
  end
  return -1;
end

function fuelAndInventoryCheck()
  if turtle.getFuelLevel() - moveDistanceTo(0,0,0) < 10 then
    if not sipCoal() then
      return false;
    end
  end
  if getEmptySlots() < 4 then
    print("no slots");
    return false;
  end

  return true;
end

function fuelCheck()
  if turtle.getFuelLevel() - moveDistanceTo(0,0,0) < 10 then
    if not sipCoal() then
      return false;
    end
  end

  return true;
end

function mineWaypoints(waypoints)
  for i=1,table.getn(waypoints) do
    wp = waypoints[i];
    while not goto(wp.x,wp.y,wp.z,true,true,false,fuelAndInventoryCheck) do
      if not returnToBase() then
        return false;
      end
    end
  end
  return true;
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

function haveFuelFor(n)
  return turtle.getFuelLevel() + countItems("minecraft:coal")*80 > n;
end

function returnToBase(stay)
  stay = stay or false;
  print("Returning to base to unload..")
  dist = moveDistanceTo(0,0,0)
  sx = cx;
  sy = cy;
  sz = cz;
  sdir = dir;
  goto(0,0,0,false,true,false);
  turnTo(3);
  depositItems();
  if stay or not haveFuelFor(dist*2 + 20) then
    return false;
  end
  goto(sx,sy,sz,false,true,true,fuelAndInventoryCheck);
  turnTo(sdir);
  return true;
end

function moveDistanceTo(x,y,z)
  return math.abs(cx-x) + math.abs(cy-y) + math.abs(cz-z);
end

function generateWaypoints(sx,sy,sz,bx,by,bz)
  ystep = 1;
  if sy > by then
    ystep = -1;
  end
  zstep = 1;
  if sz > bz then
    zstep = -1;
  end

  waypoints = {}

  odd = false;
  yodd = false;
  for z=sz,bz,zstep*3 do
    if yodd then
      for y=by,sy,-ystep do
        if odd then
          table.insert(waypoints,{x=sx,y=y,z=z})
          table.insert(waypoints,{x=bx,y=y,z=z})
        else
          table.insert(waypoints,{x=bx,y=y,z=z})
          table.insert(waypoints,{x=sx,y=y,z=z})
        end
        odd = not odd;
      end
    else
      for y=sy,by,ystep do
        if odd then
          table.insert(waypoints,{x=sx,y=y,z=z})
          table.insert(waypoints,{x=bx,y=y,z=z})
        else
          table.insert(waypoints,{x=bx,y=y,z=z})
          table.insert(waypoints,{x=sx,y=y,z=z})
        end
        odd = not odd;
      end
    end
    yodd = not yodd;
  end

  return waypoints;
end

function vmove(down)
  refuelIfNecessary();
  if down then
    if turtle.down() then
      cz = cz - 1;
    end
  else
    if turtle.up() then
      cz = cz + 1;
    end
  end
end

function posInDir(tdir)
  local xtab = {1,0,-1,0};
  local ytab = {0,1,0,-1};
  return cx + xtab[tdir],cy + ytab[tdir];
end

function move(back)
  local xtab = {1,0,-1,0};
  local ytab = {0,1,0,-1};
  local success = false;
  refuelIfNecessary();
  if back then
    success = turtle.back();
  else
    success = turtle.forward()
  end
  if success then
    if back then
      cx = cx - xtab[dir];
      cy = cy - ytab[dir];
    else
      cx = cx + xtab[dir];
      cy = cy + ytab[dir];
    end
    return true
  else
    print("move failed!");
    return false
  end
end

function left()
  if turtle.turnLeft() then
    dir = dir - 1;
    if dir < 1 then
      dir = 4
    end
  else
    print("failed to turn left");
  end
end

function right()
  if turtle.turnRight() then
    dir = dir + 1;
    if dir > 4 then
      dir = 1;
    end
  else
    print("Failed to turn right");
  end
end

function turnTo(tdir)
  if math.abs(dir-tdir) == 2 then
    left();
    left();
    return;
  end

  if math.abs(dir-tdir) == 1 then
    if dir > tdir then
      left();
    end

    if dir < tdir then
      right();
    end
  end

  if math.abs(dir-tdir) == 3 then
    if dir < tdir then
      left()
    end

    if dir > tdir then
      right();
    end
  end
end

function goto(tx,ty,tz,ore,tunnel,reverse,tick)
  tz = tz or 0;
  ore = ore or false;
  tunnel = tunnel or false;
  reverse = reverse or false;
  if reverse then
    if not gotoX(tx,ore,tunnel,tick) then
      return false;
    end
    if not gotoY(ty,ore,tunnel,tick) then
      return false;
    end
    if not gotoZ(tz,ore,tunnel,tick) then
      return false;
    end
    return true;
  else
    if not gotoZ(tz,ore,tunnel,tick) then
      return false;
    end
    if not gotoY(ty,ore,tunnel,tick) then
      return false;
    end
    if not gotoX(tx,ore,tunnel,tick) then
      return false;
    end
    return true;
  end
end

function doMove(ore,tunnel)
    ore = ore or false;
    tunnel = tunnel or false;
    turtle.dig();
    move();
    if ore then
      local sdir = dir;
      checkOre();
      turnTo(sdir);
    end
    if tunnel then
      turtle.digUp();
    end
end

function gotoX(tx,ore,tunnel,tick)
  if tx > cx then
    turnTo(1)
  elseif tx < cx then
    turnTo(3)
  end
  while tx ~= cx do
    doMove(ore,tunnel);
    if tick and not tick() then
        return false;
    end
  end
  return true;
end

function gotoY(ty,ore,tunnel,tick)
  if ty > cy then
    turnTo(2);
  elseif ty < cy then
    turnTo(4);
  end
  while ty ~= cy do
    doMove(ore,tunnel);
    if tick and not tick() then
        return false;
    end
  end;
  return true;
end

function gotoZ(tz,ore,tunnel,tick)
  while tz < cz do
    turtle.digDown();
    vmove(true);
    if tick and not tick() then
        return false;
    end
  end
  while tz > cz do
    turtle.digUp();
    vmove();
    if tick and not tick() then
        return false;
    end
  end
  return true;
end

function getEmptySlots()
  n = 0;
  for i=1,16 do
    if turtle.getItemDetail(i) == nil then
      n = n + 1;
    end
  end
  return n;
end

function findInArray(arr,ele)
  for i,v in ipairs(arr) do
    if v == ele then
      return i;
    end
  end
  return -1;
end

function isWorthless(item)
  worthless = {
  "minecraft:stone",
  "minecraft:cobblestone",
  "minecraft:sand",
  "minecraft:dirt",
  "minecraft:gravel",
  "minecraft:bedrock",
  "minecraft:lava",
  "minecraft:flowing_lava",
  "minecraft:water",
  "minecraft:flowing_water",
  }
  if item == nil then
    return true;
  end;
  return findInArray(worthless,item.name) ~= -1
end

function isOre(item)
  if item == nil then
    return true;
  end;
  return string.find("ore",item.name) or string.find("Ore",item.name);
end

function dirAdd(mdir,a)
  newdir = mdir + a;
  while(newdir < 1) do
    newdir = newdir + 4;
  end
  while(newdir > 4) do
    newdir = newdir - 4;
  end
  return newdir;
end

function hasChecked(mdir)
  x,y = posInDir(mdir)
  return checked[x.."_"..y.."_"..cz];
end

checked = {}
function findOre()
  odir = dir;
  checkOre();
  i = 0;
  while not hasChecked(dirAdd(dir,-1)) do
    i = i + 1;
    left()
    checkOre();
  end

  if not hasChecked(dirAdd(dir,-2)) then
    left()
    left()
    checkOre();
  end

  if not hasChecked(dirAdd(dir,1)) then
    right();
    checkOre();
  end
end

function checkOre()
  f, forward = turtle.inspect();
  u, up = turtle.inspectUp();
  d, down = turtle.inspectDown();

  x,y = posInDir(dir)
  checked[x.."_"..y.."_"..cz] = true;
  checked[cx.."_"..cy.."_"..cz+1] = true;
  checked[cx.."_"..cy.."_"..cz-1] = true;
  local ax = cx;
  local ay = cy;
  local az = cz;
  refuelIfNecessary();
  if f and isOre(forward) then
    turtle.dig();
    move();
    findOre();
    goto(ax,ay,az,false,false,false,fuelCheck);
  end

  if u and isOre(up) then
    turtle.digUp();
    vmove();
    findOre();
    goto(ax,ay,az,false,false,false,fuelCheck);
  end

  if d and isOre(down) then
    turtle.digDown();
    vmove(true);
    findOre();
    goto(ax,ay,az,false,false,false,fuelCheck);
  end
end

function consolidateAll()
  underfilled = {}
  for i=1,16 do
    item = turtle.getItemDetail(i)
    if item ~= nil then
      uf = underfilled[item.name];
      if uf ~= nil then
        turtle.select(i);
        turtle.transferTo(uf);
        if turtle.getItemSpace(uf) == 0 then
          underfilled[item.name] = nil;
        end
      end
      item = turtle.getItemDetail(i);
      if item ~= nil then
        spaces = turtle.getItemSpace(i)
        if spaces > 0 then
          underfilled[item.name] = i;
        end
      end
    end
  end
end

function depositItems()
  success, item = turtle.inspect()
  if success == false or item.name ~= "minecraft:chest" then
    print("no chest found!!")
    return
  end

  coalSave = -1;
  consolidateAll();
  if countItems("minecraft:coal") > 64 then
    coalSave = findFullStack("minecraft:coal")
  end

  for i=1,16 do
    item = turtle.getItemDetail(i);
    if item ~= nil and not (item.name == "minecraft:coal" and (coalSave == -1 or coalSave == i)) then
      turtle.select(i)
      turtle.drop();
    end
  end
end

main();
