--https://pastebin.com/HuSzyVfL
base = "http://www.julianhartline.com/minecraft";

args = {...}

local res = http.get(base.."/files.txt");
local fileList = res.readAll();

for f in string.gmatch(fileList, "[^\n]+") do
  if string.find(f, ".lua") then
    local name = string.gsub(f, ".lua", "");
    print("Downloading: "..name);
    res = http.get(base.."/"..f);
    local contents = res.readAll();
    if (fs.exists(name)) then
      fs.delete(name);
    end
    local h = fs.open(name,"w");
    h.write(contents);
    h.close();
  end
end

if (fs.exists("run")) then
  util.clearOutputFile();
  if args[1] then
    util.db("Running "..args[1]);
    shell.run(args[1]);
  else
    util.db("Running run");
    shell.run("run");
  end

  -- Upload output file
  local h = fs.open("out","r");
  local contents = h.readAll();
  h.close();

  http.post(base.."/up.php",contents);
end
