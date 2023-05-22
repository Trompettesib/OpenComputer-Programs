local robot = require("robot")
local component = require("component")
local inv_ctrlr = component.inventory_controller
 
function doMoveNumber(number, move)
    for i = 1, number do
        ret, error = move()
        if (ret == false) then
            print(error)
            return false
        end
    end
    return true
end
 
function get_pattern()
    file = io.open("pattern.txt", "r")
    pattern_size = file:read("l")
    pattern = file:read("l")
    file:close()
    pattern_size_x, pattern_size_z = string.match(pattern_size, "(%d+),(%d+)")
    parsed_pattern = {}
    for i = 1, pattern_size_x*pattern_size_z do
        table.insert(parsed_pattern, string.match(pattern, "([%a%d_]*:[%a_]*), "))
        pattern = string.sub(pattern, string.find(pattern, ", ")+2)
    end
    return tonumber(pattern_size_x), tonumber(pattern_size_z), parsed_pattern
end
 
function get_inventory()
    inventory = {}
    for i = 1, 16 do
        data = inv_ctrlr.getStackInInternalSlot(i)
        if data ~= nil then
            table.insert(inventory, data.name)
        else
            table.insert(inventory, "nil")
        end
    end
    return inventory
end
 
function set_block(block_name)
    inventory = get_inventory()
    for i = 1, 16 do
        if inventory[i] == block_name then
            -- print("Found "..block_name.." in slot "..i)
            return i
        end
    end
    return nil
end
 
function place_block(block_name)
    slot = set_block(block_name)
    if slot == nil then
        print("No "..block_name.." in inventory")
        return false
    end
    robot.select(slot)
    ret, error = robot.placeDown()
    if (ret == false) then
        print(error)
    end
    return true
end
 
-- function place_pattern(pattern_size_x, pattern_size_z, parsed_pattern)
--     for i = 1, pattern_size_z do
--         for j = 1, pattern_size_x do
--             block_name = parsed_pattern[(i-1)*pattern_size_x+j]
--             if place_block(block_name) == false then
--                 return false
--             end
--             if (j ~= pattern_size_x - 1) then
--                 if (try_to_move("forward") == false) then
--                     return false
--                 end
--             end
--             if (j == pattern_size_x - 1) then
--                 print("Last block of line "..i)
--             end
--         end
--         for j = 1, pattern_size_x - 1 do
--             if (try_to_move("back") == false) then
--                 return false
--             end
--         end
--         if (i ~= pattern_size_z - 1) then
--             robot.turnRight()
--             if (try_to_move("forward") == false) then
--                 return false
--             end
--             robot.turnLeft()
--         end
--     end
--     robot.turnLeft()
--     for i = 1, pattern_size_z do
--         if (try_to_move("forward") == false) then
--             return false
--         end
--     end
--     robot.turnRight()
--     return true
-- end
 
function place_pattern(pattern_size_x, pattern_size_z, pattern)
    for i = 1, pattern_size_z do
        for j = 1, pattern_size_x - 1 do
            if place_block(pattern[(i-1)*pattern_size_x+j]) == false then
                return false
            end
            if doMoveNumber(1, robot.forward) == false then
                return false
            end
        end
        if place_block(pattern[(i - 1) * pattern_size_x + pattern_size_x]) == false then
            return false
        end
        if doMoveNumber(pattern_size_x - 1, robot.back) == false then
            return false
        end
        if (i ~= pattern_size_z) then
            robot.turnRight()
            if doMoveNumber(1, robot.forward) == false then
                return false
            end
            robot.turnLeft()
        end
    end
    robot.turnLeft()
    if doMoveNumber(pattern_size_z - 1, robot.forward) == false then
        return false
    end
    robot.turnRight()
    return true
end
 
function main()
    pattern_size_x, pattern_size_z, parsed_pattern = get_pattern()
    if place_pattern(pattern_size_x, pattern_size_z, parsed_pattern) == false then
        print("Error while placing pattern")
    end
end
 
main()