local robot = require("robot")

function get_pattern_size()
    file = io.open("pattern.txt", "r")
    pattern_size = file:read("l")
    file:close()
    pattern_size_x, pattern_size_z = string.match(pattern_size, "(%d+),(%d+)")
    return tonumber(pattern_size_x), tonumber(pattern_size_z)
end

function arg_parser(arg)
    if (arg[1] == "-h" or arg[1] == "--help") then
        print("Usage: place_patternXxX.lua Front Right")
        print("\tFront and Right being the number of times")
        print("\t\tthe pattern should be repeated")
        return true
    end
    if (#arg == 2) then
        front = tonumber(arg[1])
        right = tonumber(arg[2])
        if (front == nil or right == nil) then
            print("Usage: place_patternXxX.lua Front Right")
            print("\tFront and Right being the number of times")
            print("\t\tthe pattern should be repeated")
            return false
        end
        return front, right
    else
        print("Usage: place_patternXxX.lua Front Right")
        print("\tFront and Right being the number of times")
        print("\t\tthe pattern should be repeated")
        return false
    end
end

function doMoveNumber(number, move)
    for i = 1, number do
        move()
    end
end

function main(arg)
    front, right = arg_parser(arg)
    sizeOfPatternX, sizeOfPatternZ = get_pattern_size()
    if (front == nil or right == nil or front == false or front == true) then
        return
    end
    for i = 1, right do
        for j = 1, front do
            dofile("place_pattern.lua")
            if (j ~= front) then
                doMoveNumber(sizeOfPatternX, robot.forward)
            end
        end
        if (i ~= right) then
            doMoveNumber(sizeOfPatternX * front, robot.back)
            robot.turnRight()
            doMoveNumber(sizeOfPatternZ, robot.forward)
            robot.turnLeft()
        end
    end
    doMoveNumber(sizeOfPatternX * (front - 1), robot.back)
end

local args = {...}
main(args)