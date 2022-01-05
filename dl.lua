local internet = require("internet")
local io = require("io")

local base = "http://julianhartline.com/minecraft/"


function curl(url)
  local handle = internet.request(url)
  local result = ""
  for chunk in handle do result = result..chunk end
  return result
end

local fileList = curl(base.."files.txt")
for fileName in string.gmatch(fileList, "[^\n]+") do
  if string.find(fileName, ".lua") then
    local name = string.gsub(fileName, ".lua", "");
    print("Downloading: "..name);
    contents = curl(base..fileName);

    local f = io.open(fileName,"w")
    f:write(contents)
    f:close()
  end
end
