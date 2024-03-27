local version = "1.4"  -- Current version number
local updateURL = "https://raw.githubusercontent.com/Poke5555/ComputerCraftScripts/main/monke.lua"

-- Function to check for updates
local function checkForUpdates()
    local response = http.get(updateURL)
    if response then
        local latestScript = response.readAll()
        response.close()
        
        local latestVersion = latestScript:match('local version = "(.-)"')
        if latestVersion and latestVersion ~= version then
            chatBox.sendMessage("A new version (" .. latestVersion .. ") is available. Do you want to update? (yes/no)", "&lm.o.n.k.e")
            local _, message = os.pullEvent("chat")
            if message:lower() == "yes" then
                local file = fs.open(shell.getRunningProgram(), "w")
                file.write(latestScript)
                file.close()
                chatBox.sendMessage("Update successful. Please restart the program.", "&lm.o.n.k.e")
                return true
            end
        else
            chatBox.sendMessage("You are using the latest version.", "&lm.o.n.k.e")
        end
    else
        chatBox.sendMessage("Failed to check for updates.", "&lm.o.n.k.e")
    end
    return false
end

term.clear()  -- Clear the screen before displaying the next acronym
term.setCursorPos(1, 1)  -- Move cursor to the top-left corner
print("Master of Operations, Networking, and Keeping Everything")
print("hello")

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
    
    chatBox.sendMessage("Sucked " .. totalImported .. " item(s) into system", "&lm.o.n.k.e")
end

-- Function to count the number of a specific item in the RS system
local function countItemInSystem(itemName)
    local fullName = itemMappings[itemName] or itemName
    local itemInfo = rsBridge.getItem({name = fullName})
    if itemInfo then
        chatBox.sendMessage("There are " .. itemInfo.amount .. " " .. fullName .. "(s) in the system.", "&lm.o.n.k.e")
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


-- Event listener function
local function eventListener(event, ...)
    if event == "chat" then
        local username, message = ...
        local permitted = isPermittedUser(username)

        -- Handle chat commands here
        local command, args = message:match("^%s*([%w]+)%s*(.*)$")
        if command == "monke" then
            local subCommand, subArgs = args:match("^%s*([%w]+)%s*(.*)$")
            if subCommand == "give" or subCommand == "send" or subCommand == "export" then
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
                    if numericAmount and itemName then
                        itemName = itemName:lower()
                        craftItems({name = itemName}, numericAmount)
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
