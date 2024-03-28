-- Find the RS Bridge peripheral
local rsBridge = peripheral.find("rsBridge")

-- Define a function to handle the crafting command
local function handleCraftCommand(craftAmount, craftItem)
    -- Get the crafting pattern for the specified item
    local pattern, errorMessage = rsBridge.getPattern({ name = craftItem })

    -- Check if the crafting pattern was successfully retrieved
    if pattern then
        -- Table to store aggregated amounts for each input name
        local aggregatedInputs = {}
        
        -- Iterate over the inputs and aggregate amounts
        for _, inputList in ipairs(pattern.inputs) do
            for _, input in ipairs(inputList) do
                -- Check if the input has a name and amount property
                if input and input.name and input.amount then
                    -- Aggregate the amounts for each input name
                    if not aggregatedInputs[input.name] then
                        aggregatedInputs[input.name] = input.amount * craftAmount
                    else
                        aggregatedInputs[input.name] = aggregatedInputs[input.name] + (input.amount * craftAmount)
                    end
                else
                    print("Invalid input item found")
                    return
                end
            end
        end
        
        -- Check if there are enough items in the system
        local enoughItems = true
        for name, requiredAmount in pairs(aggregatedInputs) do
            local itemInfo = rsBridge.getItem({ name = name })
            if itemInfo and itemInfo.amount then
                if itemInfo.amount < requiredAmount then
                    print("Missing " .. requiredAmount .. " " .. name .. "(s)") -- Adjusted print statement for missing items
                    enoughItems = false
                end
            else
                print("Failed to retrieve information for " .. name)
                enoughItems = false
            end
        end
        
        -- If there are enough items, perform the craft
        if enoughItems then
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
    local command, craftAmount, craftItem = input:match("(%a+)%s+(%d+)%s+(%a+)")
    
    -- Check if the command is "craft"
    if command == "craft" then
        -- Call the handleCraftCommand function with the specified amount and item name
        handleCraftCommand(tonumber(craftAmount), craftItem)
    else
        print("Invalid command. Usage: craft <amount> <item>")
    end
end
