os.loadAPI("util");

Turtle = util.createClass();

function Turtle:_init()
  print("Remaining Fuel: ",turtle.getFuelLevel());
  self.pos = util.readJsonFile("turtle_position") or {x=0,y=0,z=0,dir=1};
end

function Turtle:forward()
  turtle.forward();
  x = x + 1;
end

function Turtle:back()
  turtle.back();
  x = x - 1;
end
