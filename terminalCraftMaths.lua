--To use, place computer next to rsBridge that is connect to a Refined Storage system that has crafting capabilities.
--The command use is `craft <amount> <item>` modded items need the prefix "refinedstorage:quartz_enriched_iron". Vanilla items do not "waxed_weathered_cut_copper_stairs" but you can if you want.
--When using the command it will craft the amount of items requested, if you do not have enough items to craft the entire amount it prints amount of items you are missing.
--Unless you have a pattern for the missing item, it will be off by the amount of items given by the pattern "1 iron_block is 9 iron_ingot" so the system will always think it has 9 less iron than it really does.
--I will fix this at some point. currently the only way i can think of to fix it is make it = 0 if the system contains the amount of items crafted from the pattern "for iron 1-8 & 10-ininity would work, but 9 would be 0".
--This issue is caused because the rsBridge read the pattern in the system as its results, once the item is in the system the rsBridge just sees the item.

-- Find the RS Bridge peripheral
local rsBridge = peripheral.find("rsBridge")

-- Define a function to handle the crafting command
local function handleCraftCommand(craftAmount, craftItem)
    -- Get the crafting pattern for the specified item
    local pattern, errorMessage = rsBridge.getPattern({ name = craftItem })

    -- Check if the crafting pattern was successfully retrieved
    if pattern then
        -- Determine the crafting multiplier based on the number of outputs
        local craftingMultiplier = 1
        if pattern.outputs and #pattern.outputs > 0 then
            craftingMultiplier = math.ceil(craftAmount / pattern.outputs[1].amount)
        end
        
        -- Table to store aggregated amounts for each input name
        local aggregatedInputs = {}
        
        -- Iterate over the inputs and aggregate amounts
        for _, inputList in ipairs(pattern.inputs) do
            for _, input in ipairs(inputList) do
                -- Check if the input has a name and amount property
                if input and input.name and input.amount then
                    -- Aggregate the amounts for each input name
                    if not aggregatedInputs[input.name] then
                        aggregatedInputs[input.name] = input.amount
                    else
                        aggregatedInputs[input.name] = aggregatedInputs[input.name] + input.amount
                    end
                else
                    print("Invalid input item found")
                    return
                end
            end
        end
        
        -- Calculate the total required amount
        local totalRequiredAmount = 0
        for _, requiredAmount in pairs(aggregatedInputs) do
            totalRequiredAmount = totalRequiredAmount + requiredAmount * craftingMultiplier
        end
        
        -- If there are items missing, print the details
        local itemsMissing = {}
        for name, requiredAmount in pairs(aggregatedInputs) do
            local itemInfo = rsBridge.getItem({ name = name })
            if itemInfo and itemInfo.amount then
                -- Check if the item has a pattern and calculate the amount obtained from the pattern
                local patternAmount = 0
                local patternInfo = rsBridge.getPattern({ name = name })
                if patternInfo then
                    patternAmount = patternInfo.outputs[1].amount
                end
                
                local missingAmount = requiredAmount * craftingMultiplier - (itemInfo.amount - patternAmount)
                if missingAmount > 0 then
                    -- Retrieve the display name from the pattern
                    local displayName
                    for _, inputList in ipairs(pattern.inputs) do
                        for _, input in ipairs(inputList) do
                            if input.name == name then
                                displayName = input.displayName
                                break
                            end
                        end
                        if displayName then break end
                    end
                    itemsMissing[name] = { displayName = displayName, amount = missingAmount, multiplier = craftingMultiplier }
                end
            else
                print("Failed to retrieve information for " .. name)
                return
            end
        end
        
        -- If there are items missing, print the details
        if next(itemsMissing) then
            for itemName, itemData in pairs(itemsMissing) do
                print("Missing " .. itemData.amount .. " " .. itemData.displayName .. ".")
            end
        else
            -- If there are enough items, perform the craft
            rsBridge.craftItem({ name = craftItem, count = craftAmount }) -- Ensure that only <craftItem> is crafted
            print("Crafting " .. craftAmount .. " " .. craftItem .. ".")
        end
    else
        if not errorMessage then
            errorMessage = "Unknown error"
        end
        print("Missing pattern for " .. craftItem .. ".")
    end
end

-- Command handler loop
while true do
    -- Read input from user
    local input = read()

    -- Parse the input command
    local command, craftAmount, craftItem = input:match("(%a+)%s+(%d+)%s+(%S+)")

    -- Check if the command is "craft"
    if command == "craft" then
        -- Call the handleCraftCommand function with the specified amount and item name
        handleCraftCommand(tonumber(craftAmount), craftItem)
    else
        print("Invalid command. Usage: craft <amount> <item>")
    end
end
