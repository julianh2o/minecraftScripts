function waitForItem()
  while turtle.getItemDetail(1) == nil do
    os.sleep(.5);
  end
end

function dispense()
  redstone.setOutput("front",false);
  os.sleep(.1);
  redstone.setOutput("front",true);
  os.sleep(.1);
end

spells = {
  ["touchdig"]={"Blank Rune","Vinteum Dust","Feather","Raw Fish","Clay","Orange Rune","Iron Shovel","Iron Pickaxe","Spell Parchment"},
  ["selfhasteregen"]={"Blank Rune","Vinteum Dust","Aum","Lesser Focus","NEUTRAL","Yellow Rune","Redstone","Glowstone Dust","Blue Rune","Golden Apple","Spell Parchment"},
  ["test"]={"NEUTRAL"}
};
req = peripheral.wrap("top");

function makespell(spell)
  items = req.getAvailableItems();
  craftable = req.getCraftableItems();

  for i,sc in pairs(spell) do
    if sc == "NEUTRAL" then
      print("Neutral Essence Required.. waiting..");
      last = redstone.getInput("right")
      transitions = 0;
      while true do
        os.sleep(.1);
        new = redstone.getInput("right");
        if new ~= last then
          transitions = transitions + 1;
        end
        last = new;
        if transitions == 2 then
          break;
        end
      end
      found = true;
    else
      found = false;
      for key,value in pairs(items) do
        item = value.getValue1();
        name = item.getName();
        if name == sc then
          found = true;
          print("Have: "..sc);
          req.makeRequest(item,1);
          waitForItem();
          turtle.select(1);
          turtle.drop();
          os.sleep(.2);
          dispense();
        end
      end
      if not found then
        for key,value in pairs(craftable) do
          item = value;
          name = item.getName();
          if name == sc then
            found = true;
            print("Crafting: "..sc);
            req.makeRequest(item,1);
            waitForItem();
            turtle.select(1);
            turtle.drop();
            os.sleep(.2);
            dispense();
          end
        end
      end
    end
    if found == false then
      print(sc.." not found. Aborting!");
      return;
    end
  end
end

makespell(spells["selfhasteregen"])
