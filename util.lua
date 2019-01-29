os.loadAPI("json")

function readJsonFile(f)
  if (not fs.exists(f)) then
    return nil;
  end

  contents = fileReadContents(f);
  return json.decode(contents);
end

function clearOutputFile()
  fs.delete("out");
end

function db(s)
  h = fs.open("out","a");
  h.write(s.."\n");
  h.close();
  print(s);
end

function writeJsonFile(f,o)
  fileWriteContents(f,json.encode(o));
end

function fileReadContents(f)
  h = fs.open(f,"r");
  contents = h.readAll();
  h.close();
  return contents;
end

function fileWriteContents(f,contents)
  h = fs.open(f,"w");
  h.write(contents);
  h.close();
end

function showPeripherals()
  names = peripheral.getNames();
  for i=1,table.getn(names) do
    side = names[i];
    type = peripheral.getType(side)
    print(side..": "..type);
  end
end

function printVectors(vecs)
  s = "";
  for i=1,table.getn(vecs) do
    s = s.."("..vecs[i]:tostring()..") ";
  end
  return s;
end

function createClass(...)
  -- "cls" is the new class
  local cls, bases = {}, {...}
  -- copy base class contents into the new class
  for i, base in ipairs(bases) do
    for k, v in pairs(base) do
      cls[k] = v
    end
  end
  -- set the class's __index, and start filling an "is_a" table that contains this class and all of its bases
  -- so you can do an "instance of" check using my_instance.is_a[MyClass]
  cls.__index, cls.is_a = cls, {[cls] = true}
  for i, base in ipairs(bases) do
    for c in pairs(base.is_a) do
      cls.is_a[c] = true
    end
    cls.is_a[base] = true
  end
  -- the class's __call metamethod
  setmetatable(cls, {__call = function (c, ...)
    local instance = setmetatable({}, c)
    -- run the init method if it's there
    local init = instance._init
    if init then init(instance, ...) end
    return instance
  end})
  -- return the new class table, that's ready to fill with methods
  return cls
end

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end
