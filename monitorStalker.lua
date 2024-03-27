--To use script put 6x6 monitor on right side of PC and a playerDetector on any side of PC!
local monitor = peripheral.wrap("right")  -- Assuming the monitor is on the right
local player_detector = peripheral.find("playerDetector")

local function displayPlayerInfo(playerInfo)
    monitor.clear()

    local columnNames = {" Name", " Pos", " HP", " Pitch/Yaw", " Dimension"}
    local columnWidths = {}
    local totalWidth = 0

    -- Calculate column widths based on the longest item in each column
    for _, player in ipairs(playerInfo) do
        for _, columnName in ipairs(columnNames) do
            local columnWidth = #tostring(player[columnName] or "nil")
            if not columnWidths[columnName] or columnWidth > columnWidths[columnName] then
                columnWidths[columnName] = columnWidth
                totalWidth = totalWidth + columnWidths[columnName]
            end
        end
    end

    -- Calculate starting position to align the table to the left
    local startX = 1

    -- Display column names
    local y = 1
    local x = startX
    for _, columnName in ipairs(columnNames) do
        monitor.setCursorPos(x, y)
        monitor.write(columnName .. " ") -- Add space after each column name
        x = x + columnWidths[columnName] + 3 -- Adjust cursor position for spacing
    end

    -- Display horizontal line below column names
    monitor.setCursorPos(startX, 2)
    monitor.write(string.rep("-", totalWidth + #columnNames * 1 + #columnNames)) -- Adjust width to account for vertical lines

    -- Display vertical lines and player information
    y = 3
    for _, player in ipairs(playerInfo) do
        x = startX
        for _, columnName in ipairs(columnNames) do
            monitor.setCursorPos(x, y)
            local value = player[columnName] or "nil"
            monitor.write(" " .. tostring(value) .. string.rep(" ", columnWidths[columnName] - #tostring(value)) .. " ")  -- Add space after each value
            if columnName ~= " Dimension" then
                monitor.setCursorPos(x + columnWidths[columnName] + 2, y) -- Adjust cursor position to account for spacing between columns
                monitor.write("|")
            end
            x = x + columnWidths[columnName] + 3 -- Adjust cursor position to account for vertical line and spacing
        end
        y = y + 1
    end
end

local function getOnlinePlayersInfo()
    local playerInfo = {}
    local onlinePlayers = player_detector.getOnlinePlayers()
    for _, player in ipairs(onlinePlayers) do
        local pos = player_detector.getPlayerPos(player)
        if pos then
            local x, y, z = pos.x or "nil", pos.y or "nil", pos.z or "nil"
            local hp = pos.health and string.format("%.f", pos.health) or "nil"
            local pitchYaw = (pos.pitch and pos.yaw) and (string.format("%.f", pos.pitch) .. ", " .. string.format("%.f", pos.yaw)) or "nil, nil"
            local dimension = pos.dimension and string.match(pos.dimension, ":(.+)") or "nil"
            playerInfo[#playerInfo + 1] = {
                [" Name"] = player,
                [" Pos"] = x .. ", " .. y .. ", " .. z,
                [" HP"] = hp,
                [" Pitch/Yaw"] = pitchYaw,
                [" Dimension"] = dimension,
            }
        end
    end
    return playerInfo
end

    while true do
        local playerInfo = getOnlinePlayersInfo()
        displayPlayerInfo(playerInfo)
    end
