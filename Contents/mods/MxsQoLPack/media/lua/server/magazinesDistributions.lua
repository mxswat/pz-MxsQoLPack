require "Items/Distributions"
require "Items/ProceduralDistributions"

local ItemsMap = {
    ["CookingMag1"] = "MxsQoLPack.NutritionistMag1",
    ["ElectronicsMag1"] = "MxsQoLPack.EngineerMag1",
    ["ElectronicsMag2"] = "MxsQoLPack.EngineerMag2",
}

local function insertMagazine(items)
    for i, item in ipairs(items) do
        if ItemsMap[item] then
            table.insert(items, ItemsMap[item])
            table.insert(items, items[i + 1])
            break
        end
    end
end

local function insertMagazineRecursive(room)
    for key, value in pairs(room) do
        if key == "items" then
            insertMagazine(value)
            break
        elseif type(value) == "table" then
            insertMagazineRecursive(value)
        end
    end
end

insertMagazineRecursive(Distributions[1])

for _, room in pairs(ProceduralDistributions["list"]) do
    insertMagazine(room["items"])
end
