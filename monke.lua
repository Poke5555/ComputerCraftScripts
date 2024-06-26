local version = "1.29"  -- Current version number
local updateURL = "https://raw.githubusercontent.com/Poke5555/ComputerCraftScripts/main/monke.lua"

-- Function to check for updates
local function checkForUpdates()
    local response = http.get(updateURL)
    if response then
        local latestScript = response.readAll()
        response.close()
        
        local latestVersion = latestScript:match('local version = "(.-)"')
        if latestVersion and latestVersion ~= version then
            print("A new version (" .. latestVersion .. ") is available. Do you want to update? (yes/no)")
            local input = read()
            if input:lower() == "yes" then
                local file = fs.open(shell.getRunningProgram(), "w")
                file.write(latestScript)
                file.close()
                print("Update successful. Please restart the program.")
                return true
            end
        else
            print("You are using the latest version.")
        end
    else
        print("Failed to check for updates.")
    end
    return false
end

-- Check for updates on startup
checkForUpdates()

term.clear()  -- Clear the screen before displaying the next acronym
term.setCursorPos(1, 1)  -- Move cursor to the top-left corner
print("Master of Operations, Networking, and Keeping Everything")

-- Find the RS Bridge peripheral
local rsBridge = peripheral.find("rsBridge")
if not rsBridge then
    error("RS Bridge peripheral not found!")
end

-- Find the Chat Box peripheral
local chatBox = peripheral.find("chatBox")
if not chatBox then
    error("Chat Box peripheral not found!")
end

-- Find the Chat Box peripheral
local player_detector = peripheral.find("playerDetector")
if not player_detector then
    error("playerDetector peripheral not found!")
end

-- Define a table to store shorthand mappings
local itemMappings = {}

-- Function to save item mappings to a file
local function saveItemMappingsToFile()
    local file = fs.open("itemMappings.txt", "w")
    if not file then
        error("Unable to open file for writing.")
    end
    file.write(textutils.serialize(itemMappings))
    file.close()
end

-- Function to load item mappings from a file
local function loadItemMappingsFromFile()
    if fs.exists("itemMappings.txt") then
        local file = fs.open("itemMappings.txt", "r")
        if file then
            local data = file.readAll()
            file.close()
            itemMappings = textutils.unserialize(data) or {}
        else
            error("Unable to open file for reading.")
        end
    else
        saveItemMappingsToFile()  -- Create a new file if it doesn't exist
    end
end

-- Define the handleMapCommand function
local function handleMapCommand(shortName, fullName)
    -- Your implementation here
    -- This function should handle the mapping of shortName to fullName
    -- For example, you can add the mapping to the itemMappings table
    itemMappings[shortName] = fullName
    saveItemMappingsToFile()  -- Save the updated mappings to file
    chatBox.sendMessage("Mapped '" .. shortName .. "' to '" .. fullName .. "'", "&lm.o.n.k.e")
end

-- Call loadItemMappingsFromFile function to load mappings when the script starts
loadItemMappingsFromFile()

-- Define the player mappings table
local playerMappings = {}

-- Function to save player mappings to a file
local function savePlayerMappingsToFile()
    local file = fs.open("playerMappings.txt", "w")
    if not file then
        error("Unable to open file for writing.")
    end
    file.write(textutils.serialize(playerMappings))
    file.close()
end

-- Function to load player mappings from a file
local function loadPlayerMappingsFromFile()
    if fs.exists("playerMappings.txt") then
        local file = fs.open("playerMappings.txt", "r")
        if file then
            local data = file.readAll()
            file.close()
            playerMappings = textutils.unserialize(data) or {}
        else
            error("Unable to open file for reading.")
        end
    else
        savePlayerMappingsToFile()  -- Create a new file if it doesn't exist
    end
end

-- Function to handle the "monke playermap" command
local function handlePlayerMapCommand(shortName, playerName)
    -- Your implementation here
    -- This function should handle the mapping of shortName to playerName
    -- For example, you can add the mapping to the playerMappings table
    playerMappings[shortName] = playerName
    savePlayerMappingsToFile()  -- Save the updated mappings to file
    chatBox.sendMessage("Mapped '" .. shortName .. "' to '" .. playerName .. "'", "&lm.o.n.k.e")
end

-- Call loadPlayerMappingsFromFile function to load mappings when the script starts
loadPlayerMappingsFromFile()

-- Define a table to store permitted users
local permittedUsers = {}

-- Function to save permitted users to a file
local function savePermittedUsersToFile()
    local file = fs.open("users.txt", "w")
    if not file then
        error("Unable to open file for writing.")
    end
    for _, user in ipairs(permittedUsers) do
        file.writeLine(user)
    end
    file.close()
end

-- Function to load permitted users from a file
local function loadPermittedUsersFromFile()
    if fs.exists("users.txt") then
        local file = fs.open("users.txt", "r")
        if file then
            for user in file.readLine do
                table.insert(permittedUsers, user)
            end
            file.close()
        else
            error("Unable to open file for reading.")
        end
    else
        -- Add default user if users.txt doesn't exist
        table.insert(permittedUsers, "Poke_Benji")
        savePermittedUsersToFile()
    end
end

-- Call loadPermittedUsersFromFile function to load permitted users when the script starts
loadPermittedUsersFromFile()

-- Function to check if a user is permitted to run commands
local function isPermittedUser(username)
    for _, user in ipairs(permittedUsers) do
        if user == username then
            return true
        end
    end
    return false
end

-- Function to convert words representing numbers into their numerical equivalents
local function wordsToNumber(words)
    local wordToNumber = {
        zero = 0, one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9,
        ten = 10, eleven = 11, twelve = 12, thirteen = 13, fourteen = 14, fifteen = 15, sixteen = 16,
        seventeen = 17, eighteen = 18, nineteen = 19, twenty = 20, thirty = 30, forty = 40, fifty = 50,
        sixty = 60, seventy = 70, eighty = 80, ninety = 90, hundred = 100, thousand = 1000, million = 1000000
    }

    local total = 0
    local currentNumber = 0
    local lastNumber = 0
    local invalidWordDetected = false  -- Flag to indicate if an invalid word is detected

    for word in words:gmatch("%S+") do
        if word == "and" then
            -- Skip the word "and"
        else
            local number = tonumber(word) or wordToNumber[word]
            if number then
                if number >= 1000 then
                    total = (total + lastNumber) * number
                    lastNumber = 0
                elseif number >= 100 then
                    lastNumber = lastNumber * number
                else
                    lastNumber = lastNumber + number
                end
            else
                -- Report the invalid word in the chat
                chatBox.sendMessage("Invalid word detected: " .. word, "&lm.o.n.k.e")
                invalidWordDetected = true
            end
        end
    end

    if invalidWordDetected then
        -- Do something here if needed
    end

    return total + lastNumber
end

-- Function to export items to a chest above the RS Bridge with formatted numbers
local function exportItemsToChest(item, amount)
    local direction = "up"
    local fullName = itemMappings[item.name] or item.name
    local itemInfo = rsBridge.getItem({name = fullName})
    
    if itemInfo then
        local exportedAmount = rsBridge.exportItem({name = fullName, count = amount}, direction)
        local formattedExportedAmount = tostring(exportedAmount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
        local message = (exportedAmount > 0) and ("Exported " .. formattedExportedAmount .. " " .. fullName .. "(s)") or ("Error " .. itemInfo.amount .. " " .. fullName .. "(s) in system.")
        chatBox.sendMessage(message, "&lm.o.n.k.e")
    else
        chatBox.sendMessage("Item " .. fullName .. " does not exist in the system.", "&lm.o.n.k.e")
    end
end

-- Function to export items to a chest below the RS Bridge with commas in exported amount
local function exportItemsToShareChest(item, amount)
    local direction = "down"
    local fullName = itemMappings[item.name] or item.name
    local itemInfo = rsBridge.getItem({name = fullName})
    
    if itemInfo then
        local exportedAmount = rsBridge.exportItem({name = fullName, count = amount}, direction)
        local formattedExportedAmount = tostring(exportedAmount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
        local message = (exportedAmount > 0) and ("Shared " .. formattedExportedAmount .. " " .. fullName .. "(s)") or ("Failed to send items.")
        chatBox.sendMessage(message, "&lm.o.n.k.e")
    else
        chatBox.sendMessage("Item " .. fullName .. " does not exist in the system.", "&lm.o.n.k.e")
    end
end

-- Function to export items to inventory left of the RS Bridge with commas in exported amount and ignoring inventory size
local function exportItemsToLoadChest(item, amount)
    local direction = "left"
    local fullName = itemMappings[item.name] or item.name
    local itemInfo = rsBridge.getItem({name = fullName})
    
    if itemInfo then
        -- Keep track of the remaining amount to export
        local remainingAmount = amount
        
        -- Export items until the remaining amount is zero
        while remainingAmount > 0 do
            -- Export the remaining amount or 64 (whichever is smaller) in each iteration
            local exportedAmount = rsBridge.exportItem({name = fullName, count = math.min(remainingAmount, 4096)}, direction, true)  -- The 'true' parameter ignores inventory size
            
            -- Update the remaining amount
            remainingAmount = remainingAmount - exportedAmount
            
            -- If no items were exported in this iteration, break the loop
            if exportedAmount == 0 then
                break
            end
        end
        
        -- Format the exported amount with commas
        local formattedExportedAmount = tostring(amount - remainingAmount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
        
        -- Send the appropriate message
        local message = (amount - remainingAmount > 0) and ("Loaded " .. formattedExportedAmount .. " " .. fullName .. "(s)") or ("Failed to load items.")
        chatBox.sendMessage(message, "&lm.o.n.k.e")
    else
        chatBox.sendMessage("Item " .. fullName .. " does not exist in the system.", "&lm.o.n.k.e")
    end
end

-- Define the handleGiveCommand function
local function handleGiveCommand(amount, itemName)
    local numericAmount = tonumber(amount)
    if not numericAmount then
        numericAmount = wordsToNumber(amount)
    end
    if numericAmount then
        itemName = itemName:lower()
        exportItemsToChest({name = itemName}, numericAmount)
    end
end

-- Define the handleShareCommand function
local function handleShareCommand(amount, itemName)
    local numericAmount = tonumber(amount)
    if not numericAmount then
        numericAmount = wordsToNumber(amount)
    end
    if numericAmount then
        itemName = itemName:lower()
        exportItemsToShareChest({name = itemName}, numericAmount)
    end
end

-- Define the handleLoadCommand function
local function handleLoadCommand(amount, itemName)
    local numericAmount = tonumber(amount)
    if not numericAmount then
        numericAmount = wordsToNumber(amount)
    end
    if numericAmount then
        itemName = itemName:lower()
        exportItemsToLoadChest({name = itemName}, numericAmount)
    end
end

-- Function to import all items from the chest above the RS Bridge into the RS system with formatted numbers
local function importAllItemsFromChest()
    local direction = "up"
    local totalImported = 0 
    
    repeat
        local importedAmount = rsBridge.importItem({}, direction)
        totalImported = totalImported + importedAmount
    until importedAmount == 0 
    
    local formattedTotalImported = tostring(totalImported):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    chatBox.sendMessage("Imported " .. formattedTotalImported .. " item(s) into system", "&lm.o.n.k.e")
end

-- Function to unload all items from the inventory left of the RS Bridge into the RS system with formatted numbers
local function unloadAllItemsFromChest()
    local direction = "left"
    local batchSize = 4096  -- Adjust the batch size as needed
    local totalImported = 0 
    
    repeat
        local importedAmount = rsBridge.importItem({ count = batchSize }, direction)
        totalImported = totalImported + importedAmount
    until importedAmount == 0 
    
    local formattedTotalImported = tostring(totalImported):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    chatBox.sendMessage("Imported " .. formattedTotalImported .. " item(s) into system", "&lm.o.n.k.e")
end

-- Function to count the number of a specific item in the RS system with formatted numbers
local function countItemInSystem(itemName)
    local fullName = itemMappings[itemName] or itemName
    local itemInfo = rsBridge.getItem({name = fullName})
    if itemInfo then
        local formattedAmount = tostring(itemInfo.amount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
        chatBox.sendMessage(formattedAmount .. " " .. fullName .. "(s) in the system.", "&lm.o.n.k.e")
    else
        chatBox.sendMessage("Item " .. fullName .. " not found in the system.", "&lm.o.n.k.e")
    end
end
 
-- Function to save welcome messages to a file
local function saveWelcomeMessagesToFile(messages)
    if not fs.exists("welcome.txt") then
        local file = fs.open("welcome.txt", "w")
        if not file then
            error("Unable to create file for writing.")
        end
        file.writeLine(",o/") -- Default message if file doesn't exist
        file.close()
    end
    
    local file = fs.open("welcome.txt", "a")
    if not file then
        error("Unable to open file for writing.")
    end
    for _, message in ipairs(messages) do
        file.writeLine(message)
    end
    file.close()
end

 -- Function to read welcome messages from file
local function readWelcomeMessagesFromFile()
    local messages = {}
    if fs.exists("welcome.txt") then
        local file = fs.open("welcome.txt", "r")
        if file then
            for line in file.readLine do
                table.insert(messages, line)
            end
            file.close()
        else
            error("Unable to open file for reading.")
        end
    else
        -- Create the welcome message file if it doesn't exist
        local file = fs.open("welcome.txt", "w")
        if file then
            file.writeLine(",o/")
            file.close()
            messages = {",o/"}
        else
            error("Unable to create file for writing.")
        end
    end
    return messages
end

-- Function to send a random welcome message to a player
local function sendWelcomeMessage(player)
    local messages = readWelcomeMessagesFromFile()
    if #messages > 0 then
        local randomIndex = math.random(1, #messages)
        local message = messages[randomIndex]
        chatBox.sendMessage(message, "&lm.o.n.k.e")  -- Using "m.o.n.k.e" as prefix
    else
        chatBox.sendMessage("Welcome!", player)  -- Default welcome message if file is empty
    end
end

-- Function to handle the "monke find" command
local function handleFindCommand(player)
    -- Convert player name to lowercase for case-insensitive lookup
    local lowercasePlayer = player:lower()

    -- Check if the player is mapped
    local fullName = playerMappings[lowercasePlayer]
    if fullName then
        player = fullName  -- Use the mapped player name
    end
    
    -- Check if the player exists in the server
    local playerExists = peripheral.find("playerDetector").getPlayerPos(player)
    if playerExists then
        -- Get the position of the player and print their coordinates
        local pos = player_detector.getPlayerPos(player)
        if pos then
            local dimension = (pos.dimension or ""):gsub("^.+:", "")  -- Remove prefix from dimension name
            local message = player .. " is "
            if pos.x and pos.y and pos.z and dimension then
                message = message .. "xaero-waypoint:" .. player .. "'s location:S:" .. pos.x .. ":" .. pos.y .. ":" .. pos.z .. ":9:false:0:Internal-" .. dimension .. "-waypoints"
            else
                message = message .. "not a recognized player"
            end
            chatBox.sendMessage(message, "&lm.o.n.k.e")
        else
            chatBox.sendMessage("Position of player " .. player .. " not found.", "&lm.o.n.k.e")
        end
    else
        chatBox.sendMessage("Player " .. player .. " not found.", "&lm.o.n.k.e")
    end
end

-- Function to handle the "craft" command with formatted numbers
local function handleCraftCommand(itemMappings, craftAmount, craftItem)
    -- Convert words to numbers if necessary
    local numericAmount = tonumber(craftAmount)
    if not numericAmount then
        numericAmount = wordsToNumber(craftAmount)
    end
    
    -- Format numericAmount with commas
    local formattedAmount = tostring(numericAmount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
    
    -- Map the item name using itemMappings
    local mappedCraftItem = itemMappings[craftItem:lower()] or craftItem
    
    -- Get the crafting pattern for the mapped item
    local pattern, errorMessage = rsBridge.getPattern({ name = mappedCraftItem })

    -- Check if the crafting pattern was successfully retrieved
    if pattern then
        -- Determine the crafting multiplier based on the number of outputs
        local craftingMultiplier = 1
        if pattern.outputs and #pattern.outputs > 0 then
            craftingMultiplier = math.ceil(numericAmount / pattern.outputs[1].amount)
        end
        
        -- Table to store aggregated amounts for each input name
        local aggregatedInputs = {}
        
        -- Iterate over the inputs and aggregate amounts
        for _, inputList in ipairs(pattern.inputs) do
            for _, input in ipairs(inputList) do
                -- Check if the input has a name and amount property
                if input and input.name and input.amount then
                    -- Map the input name using itemMappings
                    local mappedInputName = itemMappings[input.name:lower()] or input.name
                    -- Aggregate the amounts for each input name
                    if not aggregatedInputs[mappedInputName] then
                        aggregatedInputs[mappedInputName] = input.amount
                    else
                        aggregatedInputs[mappedInputName] = aggregatedInputs[mappedInputName] + input.amount
                    end
                else
                    chatBox.sendMessage("Invalid input item found", "&lm.o.n.k.e")
                    return
                end
            end
        end
        
        -- Calculate the total required amount
        local totalRequiredAmount = 0
        for _, requiredAmount in pairs(aggregatedInputs) do
            totalRequiredAmount = totalRequiredAmount + requiredAmount * craftingMultiplier
        end
        
        -- If there are items missing, collect the details
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
                            -- Map the input name using itemMappings
                            local mappedInputName = itemMappings[input.name:lower()] or input.name
                            if mappedInputName == name then
                                displayName = input.displayName
                                break
                            end
                        end
                        if displayName then break end
                    end
                    -- Format missing amount with commas
                    local formattedMissingAmount = tostring(missingAmount):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
                    itemsMissing[name] = { displayName = displayName, amount = formattedMissingAmount, multiplier = craftingMultiplier }
                end
            else
                chatBox.sendMessage("Failed to retrieve information for " .. name, "&lm.o.n.k.e")
                return
            end
        end
        
        -- If there are items missing, print the details
        if next(itemsMissing) then
            local missingItemsMessage = "Missing items:"
            for itemName, itemData in pairs(itemsMissing) do
                missingItemsMessage = missingItemsMessage .. "\n- " .. itemData.amount .. " " .. itemData.displayName
            end
            chatBox.sendMessage(missingItemsMessage, "&lm.o.n.k.e")
        else
            -- If there are enough items, perform the craft
            rsBridge.craftItem({ name = mappedCraftItem, count = numericAmount }) -- Ensure that only <craftItem> is crafted
            chatBox.sendMessage("Crafting " .. formattedAmount .. " " .. mappedCraftItem .. ".", "&lm.o.n.k.e")
        end
    else
        if not errorMessage then
            errorMessage = "Unknown error"
        end
        chatBox.sendMessage("Missing pattern for " .. mappedCraftItem .. ".", "&lm.o.n.k.e")
    end
end

-- Function to handle the "monke d<number>" or "monke d<number>x<number>" command
local function handleDiceRollCommand(diceString, timesToRoll)
    local sides, multiplier = diceString:match("(%d+)(x?%d*)") -- Extract the number of sides and optional multiplier from the command
    
    if not sides then
        chatBox.sendMessage("monke d<number>[x<number>]", "&lm.o.n.k.e")
        return
    end
    
    sides = tonumber(sides)
    if not sides or sides <= 0 then
        chatBox.sendMessage("Invalid number of sides. Please use a positive integer.", "&lm.o.n.k.e")
        return
    end
    
    timesToRoll = tonumber(timesToRoll) or 1 -- Default to rolling once if no multiplier provided
    if timesToRoll <= 0 then
        chatBox.sendMessage("Invalid number of rolls. Please use a positive integer.", "&lm.o.n.k.e")
        return
    end
    
    local totalResult = 0
    local results = {} -- Store individual dice rolls for messaging
    
    for i = 1, timesToRoll do
        local result = math.random(1, sides) -- Generate a random number between 1 and the specified number of sides
        totalResult = totalResult + result
        table.insert(results, result)
    end
    
    local resultMessage = "Rolled " .. timesToRoll .. " d" .. sides .. "(s) "
    for i, result in ipairs(results) do
        resultMessage = resultMessage .. result
        if i < #results then
            resultMessage = resultMessage .. ", "
        end
    end
    resultMessage = resultMessage .. ". Total: " .. totalResult
    
    chatBox.sendMessage(resultMessage, "&lm.o.n.k.e")
end

-- Event listener function
local function eventListener(event, ...)
    if event == "chat" then
        local username, message = ...
        
        -- Handle chat commands here
        local command, args = message:match("^%s*([%w]+)%s*(.*)$")
        if command == "monke" then
            local subCommand, subArgs = args:match("^%s*([%w]+)%s*(.*)$")
            
            -- Check if the subCommand is a dice command
            if subCommand:match("^d%d+$") then
                local diceString = subCommand:match("^d(%d+)$")
                if diceString then
                    handleDiceRollCommand(diceString, 1)  -- Assume multiplier is 1 if not specified
                    return -- Exit the function after handling the dice command
                else
                    chatBox.sendMessage("monke d<number>[x<number>]", "&lm.o.n.k.e")
                    return
                end
            elseif subCommand:match("^d%d+[xX]%d+$") then
                local diceString, multiplier = subCommand:match("^d(%d+)[xX](%d+)$")
                if diceString and multiplier then
                    local diceNumber = tonumber(diceString)
                    local timesToRoll = tonumber(multiplier)
                    if diceNumber and diceNumber > 0 and timesToRoll and timesToRoll > 0 then
                        handleDiceRollCommand(diceString, timesToRoll)
                        return -- Exit the function after handling the dice command
                    end
                end
            end
			
            local permitted = isPermittedUser(username)
            if not permitted then
                chatBox.sendMessage("You lack the authority to command me, peasant...", "&lm.o.n.k.e")
                return
            end

            local subCommand, subArgs = args:match("^%s*([%w]+)%s*(.*)$")
            if subCommand == "find" or subCommand == "locate" then
                handleFindCommand(subArgs)
            elseif subCommand == "playermap" then
                local player, fullName = subArgs:match("([%w]+) (.+)")
                if player and fullName then
                    handlePlayerMapCommand(player, fullName)
                else
                    chatBox.sendMessage("monke playermap <player> <fullName>", "&lm.o.n.k.e")
                end
            elseif subCommand == "give" or subCommand == "send" or subCommand == "export" then
                local amount, itemName = subArgs:match("([%w%s]+) (.+)")
                if amount and itemName then
                    handleGiveCommand(amount, itemName)
                else
                    chatBox.sendMessage("monke give <amount> <item>", "&lm.o.n.k.e")
                end
			elseif subCommand == "share" then
                local amount, itemName = subArgs:match("([%w%s]+) (.+)")
                if amount and itemName then
                    handleShareCommand(amount, itemName)
                else
                    chatBox.sendMessage("monke share <amount> <item>", "&lm.o.n.k.e")
                end
			elseif subCommand == "load" then
                local amount, itemName = subArgs:match("([%w%s]+) (.+)")
                if amount and itemName then
                    handleLoadCommand(amount, itemName)
                else
                    chatBox.sendMessage("monke load <amount> <item>", "&lm.o.n.k.e")
                end
            elseif subCommand == "map" then
                local shortName, fullName = subArgs:match("(%S+)%s+(.+)")
                if shortName and fullName then
                    handleMapCommand(shortName, fullName)
                else
                    chatBox.sendMessage("monke map <shortName> <fullName>", "&lm.o.n.k.e")
                end
            elseif subCommand == "craft" or subCommand == "make" then
                local amount, itemName = subArgs:match("([%w%s]+) (.+)")
                local numericAmount = tonumber(amount)
                if numericAmount and itemName then
                    itemName = itemName:lower()
                    handleCraftCommand(itemMappings, numericAmount, itemName) -- Pass itemMappings as an argument
                else
                    chatBox.sendMessage("monke craft <amount> <item>", "&lm.o.n.k.e")
                end
            elseif subCommand == "suck" or subCommand == "import" or subCommand == "clear" then
                importAllItemsFromChest()
			elseif subCommand == "unload" then
                unloadAllItemsFromChest()
            elseif subCommand == "count" then
                local itemName = subArgs:match("^%s*(.+)$")
                if itemName then
                    countItemInSystem(itemName:lower())
                else
                    chatBox.sendMessage("monke count <item>", "&lm.o.n.k.e")
                end
            end
        end			
    elseif event == "playerJoin" then
        local username, dimension = ...
        sendWelcomeMessage(username)
    end
end

-- Main event loop
while true do
    eventListener(os.pullEvent())
end
