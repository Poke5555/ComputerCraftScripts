local version = "1.13"  -- Current version number
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

-- Function to export items to a chest above the RS Bridge
local function exportItemsToChest(item, amount)
    local direction = "up"
    local fullName = itemMappings[item.name] or item.name
    local itemInfo = rsBridge.getItem({name = fullName})
    
    if itemInfo then
        local exportedAmount = rsBridge.exportItem({name = fullName, count = amount}, direction)
        local message = (exportedAmount > 0) and ("Sent " .. exportedAmount .. " " .. fullName .. "(s)") or ("Error " .. itemInfo.amount .. " " .. fullName .. "(s) in system.")
        chatBox.sendMessage(message, "&lm.o.n.k.e")
    else
        chatBox.sendMessage("Error: Item " .. fullName .. " does not exist in the system.", "&lm.o.n.k.e")
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
    else
        chatBox.sendMessage("Error: Invalid amount.", "&lm.o.n.k.e")
    end
end

-- Function to import all items from the chest above the RS Bridge into the RS system
local function importAllItemsFromChest()
    local direction = "up"
    local totalImported = 0 
    
    repeat
        local importedAmount = rsBridge.importItem({}, direction)
        totalImported = totalImported + importedAmount
    until importedAmount == 0 
    
    chatBox.sendMessage("Imported " .. totalImported .. " item(s) into system", "&lm.o.n.k.e")
end

-- Function to count the number of a specific item in the RS system
local function countItemInSystem(itemName)
    local fullName = itemMappings[itemName] or itemName
    local itemInfo = rsBridge.getItem({name = fullName})
    if itemInfo then
        chatBox.sendMessage("There is " .. itemInfo.amount .. " " .. fullName .. "(s) in the system.", "&lm.o.n.k.e")
    else
        chatBox.sendMessage("Error: Item " .. fullName .. " not found in the system.", "&lm.o.n.k.e")
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

-- Function to craft items in the RS system
local function craftItems(item, amount)
    local fullName = itemMappings[item.name] or item.name
    local craftedAmount = rsBridge.craftItem({name = fullName, count = amount})
    
    if craftedAmount then
        chatBox.sendMessage("Making " .. amount .. " " .. fullName .. "(s)", "&lm.o.n.k.e")
    elseif rsBridge.isItemCraftable({name = fullName}) then
        chatBox.sendMessage("Error: Insufficient resources to craft " .. amount .. " " .. fullName .. "(s).", "&lm.o.n.k.e")
    else
        chatBox.sendMessage("Error: Crafting pattern missing for " .. fullName .. ".", "&lm.o.n.k.e")
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
                message = message .. "at (" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ") in the " .. dimension .. "."
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

-- Function to handle the "craft" command
local function handleCraftCommand(itemMappings, craftAmount, craftItem)
    -- Convert words to numbers if necessary
    local numericAmount = tonumber(craftAmount)
    if not numericAmount then
        numericAmount = wordsToNumber(craftAmount)
    end
    
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
                    itemsMissing[name] = { displayName = displayName, amount = missingAmount, multiplier = craftingMultiplier }
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
            chatBox.sendMessage("Crafting " .. numericAmount .. " " .. mappedCraftItem .. ".", "&lm.o.n.k.e")
        end
    else
        if not errorMessage then
            errorMessage = "Unknown error"
        end
        chatBox.sendMessage("Missing pattern for " .. mappedCraftItem .. ".", "&lm.o.n.k.e")
    end
end

-- Function to handle the "craft" command
local function handleCraftCommandMessage(itemMappings, amount, itemName)
    local numericAmount = tonumber(amount)
    if numericAmount then
        itemName = itemName:lower()
        handleCraftCommand(itemMappings, numericAmount, itemName)
    else
        chatBox.sendMessage("Error: Invalid amount.", "&lm.o.n.k.e")
    end
end

-- Event listener function
local function eventListener(event, ...)
    if event == "chat" then
        local username, message = ...
        local permitted = isPermittedUser(username)

        -- Handle chat commands here
        local command, args = message:match("^%s*([%w]+)%s*(.*)$")
        if command == "monke" then
            local subCommand, subArgs = args:match("^%s*([%w]+)%s*(.*)$")
            if subCommand == "find" or subCommand == "locate" then
                if permitted then
                    handleFindCommand(subArgs)
                else
                    chatBox.sendMessage("You lack the authority to command me, peasant...", "&lm.o.n.k.e")
                end
            elseif subCommand == "playermap" then
                local player, fullName = subArgs:match("([%w]+) (.+)")
                if player and permitted and fullName then
                    handlePlayerMapCommand(player, fullName)
                else
                    chatBox.sendMessage("Usage: monke playermap <player> <fullName>", "&lm.o.n.k.e")
                end
            elseif subCommand == "give" or subCommand == "send" or subCommand == "export" then
                local amount, itemName = subArgs:match("([%w%s]+) (.+)")
                if amount and itemName and permitted then
                    handleGiveCommand(amount, itemName)
                else
                    chatBox.sendMessage("Usage: monke give <amount> <item>", "&lm.o.n.k.e")
                end
            elseif subCommand == "map" then
                if permitted then
                    local shortName, fullName = subArgs:match("([%w%s]+) (.+)")
                    if shortName and fullName then
                        handleMapCommand(shortName, fullName)
                    else
                        chatBox.sendMessage("Usage: monke map <shortName> <fullName>", "&lm.o.n.k.e")
                    end
                end
            elseif subCommand == "craft" or subCommand == "make" then
    if permitted then
        local amount, itemName = subArgs:match("([%w%s]+) (.+)")
        local numericAmount = tonumber(amount)
        if not numericAmount then
            numericAmount = wordsToNumber(amount)
        end
        if numericAmount and itemName then
            itemName = itemName:lower()
            handleCraftCommand(itemMappings, numericAmount, itemName) -- Pass itemMappings as an argument
        else
            chatBox.sendMessage("Usage: monke craft <amount> <item>", "&lm.o.n.k.e")
        end
    end

            elseif subCommand == "suck" or subCommand == "import" or subCommand == "clear" then
                if permitted then
                    importAllItemsFromChest()
                end
            elseif subCommand == "count" then
                if permitted then
                    local itemName = subArgs:match("^%s*(.+)$")
                    if itemName then
                        countItemInSystem(itemName:lower())
                    else
                        chatBox.sendMessage("Usage: monke count <item>", "&lm.o.n.k.e")
                    end
                end
            end
            
            if not permitted then
                chatBox.sendMessage("You lack the authority to command me, peasant...", "&lm.o.n.k.e")
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
