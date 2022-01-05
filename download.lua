--JSON: pastebin get 4nRg9CHU json
--DOWNLOAD: pastebin get 0WwJsLeG download
base = "http://www.julianhartline.com/minecraft";

args = {...}

local res = http.get(base.."/files.txt");
local fileList = res.readAll();

for f in string.gmatch(fileList, "[^\n]+") do
  if string.find(f, ".lua") then
    local name = string.gsub(f, ".lua", "");
    print("Downloading: "..name);
    local res = http.get(base.."/"..f);
    local contents = res.readAll();
    if (fs.exists(name)) then
      fs.delete(name);
    end
    local h = fs.open(name,"w");
    h.write(contents);
    h.close();
  end
end

cmd = args[1]
if not cmd then
  cmd = "run";
end

if (fs.exists(cmd)) then
  fs.delete("out");
  print("Running "..cmd);
  shell.run(cmd,args[2]);

  -- Upload output file
  if fs.exists("out") then
    local h = fs.open("out","r");
    local contents = h.readAll();
    h.close();

    http.post(base.."/up.php",contents);
  end
end
