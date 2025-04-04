-- Function to load the fluid drawer ID from a file
local function loadTankID()
    local file = fs.open("tank.txt", "r")
    if file then
        local id = file.readLine()
        file.close()
        return id
    end
    return nil
end

-- Function to save the fluid drawer ID to a file
local function saveTankID(id)
    local file = fs.open("tank.txt", "w")
    file.writeLine(id)
    file.close()
end

-- Function to wrap the fluid drawer
local function wrapFluidDrawer(id)
    local drawer = peripheral.wrap(id)
    if not drawer then
        return nil
    end
    return drawer
end

-- Check if we already have the fluid drawer ID saved
local tankID = loadTankID()

-- If the fluid drawer ID is not saved, ask the user to input it
if not tankID then
    print("Please enter the full block ID of the fluid drawer (e.g. 'modid:blockid_69')")
	print("Please enter the correct full block ID of the tank (e.g. 'modid:blockid_69')")
    print("You can find this ID by right-clicking the modem.")
    tankID = read()  -- User input for the full ID
    saveTankID(tankID)  -- Save the ID for future use
end

-- Attempt to wrap the peripheral to access the fluid drawer
local drawer = wrapFluidDrawer(tankID)

-- If the fluid drawer is not found, prompt the user again until it is detected
while not drawer do
    print("No fluid storage drawer found with ID: " .. tankID)
    print("Please enter the correct full block ID of the tank (e.g. 'modid:blockid_69')")
    print("You can find this ID by right-clicking the modem.")
    tankID = read()  -- User input for the correct ID
    saveTankID(tankID)  -- Save the ID for future use
    drawer = wrapFluidDrawer(tankID)  -- Try wrapping the fluid drawer again
end

-- Function to get the fluid amount in the first tank
local function getFluidAmount()
    local tanks = drawer.tanks()  -- Get the tanks in the drawer
    if tanks and tanks[1] then  -- Check if the first tank exists
        return tanks[1].amount  -- Return the fluid amount in the first tank
    end
    return 0  -- If no fluid is found, return 0
end

term.clear()

-- Initialize the starting fluid amount and cycle count
local startFluidAmount = getFluidAmount()
local lastTime = os.clock()  -- Time of the first reading
local cycleCount = 0  -- Initialize cycle count

while true do
    -- Track time and update every second
    local currentTime = os.clock()  -- Get current time
    local elapsedTime = currentTime - lastTime  -- Time elapsed since last check

    if elapsedTime >= 1 then  -- If 1 second has passed
        -- Increment the cycle count every second
        cycleCount = cycleCount + 1
        lastTime = currentTime  -- Reset the last time to current time
        
        -- Get the current fluid amount
        local fluidAmount = getFluidAmount()
        
        -- Calculate the fluid rate in mB/t (adjusting for elapsed time)
        local fluidRate = (fluidAmount - startFluidAmount) / cycleCount / 20  -- 20 ticks per second
        local formattedFluidRate = string.format("%.3f", fluidRate)
        
        -- Print the current statistics
        term.setCursorPos(1, 1)
        print("Average fluid rate: " .. formattedFluidRate .. " mB/t")
        print("Elapsed time: " .. cycleCount .. " seconds")
        print("Starting fluid amount: " .. startFluidAmount .. " mB")
        print("Current fluid amount: " .. fluidAmount .. " mB")
    end
end
