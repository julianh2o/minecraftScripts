os.loadAPI("util");
os.loadAPI("miner");
os.loadAPI("turtleWrapper");

args = {...}

function main()
    local chest = peripheral.wrap("top");
    local compressor = peripheral.wrap("bottom");

    while true do
        os.queueEvent("fakeEvent");
        os.pullEvent();

        local isBusy = util.countTablePairs(compressor.getAllStacks()) > 0;
        if not isBusy then
            local items = chest.getAllStacks();
            if util.countTablePairs(items) > 0 then
                os.sleep(2);
                local stackSize = getCompressorStackSize(items);
                util.db("Stack size: "..stackSize);
                distributeItems(chest,compressor,items,stackSize)
            end
        else
            os.sleep(1);
        end
    end
end

function distributeItems(chest,compressor,items,stackSize)
    local targetSlot = 4;
    for k,v in pairs(items) do
        local item = v.basic();

        local qty = item.qty;
        while qty > 0 do
            -- util.db("Placing item: "..item.name);
            -- util.db("Placing "..item.name.." from: "..k.." ("..stackSize..") into: "..targetSlot);
            chest.pushItemIntoSlot("DOWN",k,stackSize,1); --From chest, into turtle
            while turtle.getItemDetail(1) do
                compressor.pullItemIntoSlot("UP",1,stackSize,targetSlot); --From turtle, into compressor
                if (turtle.getItemDetail(1)) then
                    targetSlot = targetSlot + 1;
                    if targetSlot > 12 then
                        targetSlot = 4
                    end
                end
            end
            qty = qty - stackSize;
            targetSlot = targetSlot + 1;
        end
    end
end

function equivalentValues(t)
    local lastItem = nil
    for k,v in pairs(t) do
        if lastItem and lastItem ~= v then
            return false
        end
        lastItem = v;
    end
    return true;
end

function getCompressorStackSize(items)
    local counts = {};
    for k,v in pairs(items) do
        local item = v.basic();
        table.insert(counts,item.qty);
    end

    table.sort(counts);

    local equivalent = equivalentValues(counts);
    local lastCount = counts[#counts];
    if table.getn(counts) == 1 and lastCount % 2 == 0 then
        return lastCount/2;
    elseif table.getn(counts) == 1 then
        return lastCount;
    elseif table.getn(counts) == 3 and equivalent then
        return lastCount/2;
    elseif equivalent then
        return lastCount;
    else
        return lastCount/2;
    end
end

main()
