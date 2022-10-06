function GetARGB(color)
    return {
        a = color.a,
        r = color.r,
        g = color.g,
        b = color.b
    }
end

function GetPlayerINVSelectedWeapon()
    local selectedLoot = GetItem(getPlayerLoot(0).inventoryPane.selected)
    local selectedInventory = GetItem(getPlayerInventory(0).inventoryPane.selected)
    local weapon = selectedLoot or selectedInventory

    if weapon and weapon:IsWeapon() then
        return weapon
    end

    return nil
end