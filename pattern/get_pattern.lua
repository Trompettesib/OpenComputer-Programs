local robot = require("robot")
local component = require("component")
local geolyzer = component.geolyzer
 
function get_pattern_length()
    patternLength = 0
    while robot.forward() do
        patternLength = patternLength + 1
    end
    for i = 1, patternLength do
        robot.back()
    end
    return patternLength
end
 
function get_full_pattern(sizeX, sizeZ)
    fullpattern = {}
    for i = 1, sizeZ + 1 do
        for j = 1, sizeX do
            block = geolyzer.analyze(0)
            table.insert(fullpattern, block.name)
            robot.forward()
        end
        block = geolyzer.analyze(0)
        table.insert(fullpattern, block.name)
        for j = 1, sizeX do
            robot.back()
        end
        if (i ~= sizeZ + 1) then
            robot.turnRight()
            robot.forward()
            robot.turnLeft()
        end
    end
    robot.turnLeft()
    for i = 1, sizeZ do
        robot.forward()
    end
    robot.turnRight()
    return fullpattern
end
 
print("Get pattern X length")
patternXLength = get_pattern_length()
 
robot.turnRight()
 
print("Get pattern Z length")
patternZLength = get_pattern_length()
 
robot.turnLeft()
 
print("Get full pattern")
fullpattern = get_full_pattern(patternXLength, patternZLength)
 
patternXLength = patternXLength + 1
patternZLength = patternZLength + 1
 
file = io.open("pattern.txt", "w")
file:write(patternXLength .. "," .. patternZLength .. "\n")
for i = 1, patternXLength do
    for j = 1, patternZLength do
        file:write(fullpattern[(i - 1) * patternZLength + j] .. ", ")
    end
end
file:flush()
file:close()