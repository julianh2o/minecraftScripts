os.loadAPI("util");
os.loadAPI("miner");
os.loadAPI("turtleWrapper");

args = {...}

local target = args[1];
util.db("Installing: "..args[1]);

util.fileWriteContents("startup","print(\"Running "..target.."\");\nshell.run(\"download\",\""..target.."\");");
shell.run(target);
