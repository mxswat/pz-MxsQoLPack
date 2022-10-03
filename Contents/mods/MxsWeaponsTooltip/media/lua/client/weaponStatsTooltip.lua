local fontConfig = {
    Small  = { y = 15 },
    Medium = { y = 20 },
    Large  = { y = 20 },
}

local function tofixed(v)
    return string.format("%g", string.format("%.1f", v))
end

---@diagnostic disable-next-line: lowercase-global
function getARGB(color)
    return {
        a = color.a,
        r = color.r,
        g = color.g,
        b = color.b
    }
end

local function injectTooltip(stats, self, compared)
    local fontSize = getCore():getOptionTooltipFont();
    local tooltipHeight = self.tooltip:getHeight();
    local height = fontConfig[fontSize].y * (#stats + 1)
    self:setY(self.tooltip:getY() + tooltipHeight);
    self:setHeight(height);
    local hDiff = self.height + 9
    local bgARGB = getARGB(self.backgroundColor)
    local borderARGB = getARGB(self.borderColor)
    self:drawRect(0, 0, self.width, hDiff, bgARGB.a, bgARGB.r, bgARGB.g, bgARGB.b);
    self:drawRectBorder(0, 0, self.width, hDiff, borderARGB.a, borderARGB.r, borderARGB.g, borderARGB.b);
    local x = 5
    local y = tooltipHeight + 5
    local marginBase = 40
    local marginCalc = 90
    self.tooltip:DrawText(self.tooltip:getFont(), "Stats", x + marginBase, y, 1, 1, 0.8, borderARGB.a);
    if compared then
        self.tooltip:DrawText(self.tooltip:getFont(), compared, x + marginCalc, y, 1, 1, 0.8, borderARGB.a);
    end
    for _, statsRow in ipairs(stats) do
        y = y + fontConfig[fontSize].y
        self.tooltip:DrawText(self.tooltip:getFont(), statsRow[1] .. ":", x, y, 1, 1, 0.8, 1);
        self.tooltip:DrawText(self.tooltip:getFont(), tostring(statsRow[2]), x + marginBase, y, 1, 1, 1, 1);
        self.tooltip:DrawText(self.tooltip:getFont(), tostring(statsRow[3] or ''), x + marginCalc, y, 1, 1, 1, 1);
    end
end

-- 10 is minimum -- java\characters\IsoPlayer.java:calculateCritChance
local CHCMax = 90
-- java\ai\states\SwipeStatePlayer.java:CalcHitChance
local ACCMax = 95

function GetFirearmsStats(item)
    local player            = getPlayer()
    local minDamage         = item:getMinDamage() or 0
    local maxDamage         = item:getMaxDamage() or 0
    local minRange          = item:getMinRange()
    local maxRange          = item:getMaxRange()
    local critChance        = item:getCriticalChance() or 0
    local critDmg           = item:getCritDmgMultiplier()
    local maxHit            = item:getMaxHitCount()
    local perkLevel         = player:getPerkLevel(Perks.Aiming) or 0
    local hitChance         = item:getHitChance()
    local critModifier      = item:getAimingPerkCritModifier() or 0
    local hitChanceModifier = item:getAimingPerkHitChanceModifier()

    local CHCCalc     = math.min(critChance + (critModifier * perkLevel), CHCMax)
    local damageStat  = tofixed(minDamage) .. " - " .. tofixed(maxDamage)
    local critDmgStat = (critDmg * 100) .. '%'
    local accStat     = math.min(hitChance + (hitChanceModifier * perkLevel), ACCMax)
    local range       = tofixed(minRange) .. " - " .. tofixed(maxRange)

    return {
        { "DMG", damageStat },
        { "ACC", accStat .. '%' },
        { "RAN", range },
        { "CHC", tofixed(CHCCalc) .. '%' },
        { "CHD", critDmgStat },
        { "TRG", maxHit },
    }
end

local function injectFireArmsStats(item, self)
    local stats = GetFirearmsStats(item)
    local compareWeapon = GetSelectedWeapon()
    if not compareWeapon or compareWeapon == item then
        injectTooltip(stats, self)
        return
    end

    local CompareStats = GetFirearmsStats(compareWeapon)

    for i, stat in ipairs(stats) do
        stat[3] = CompareStats[i][2]
    end

    injectTooltip(stats, self, compareWeapon:getDisplayName())
end

local old_ISToolTipInv_render = ISToolTipInv.render
function ISToolTipInv:render()
    if not (not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck) then
        return
    end
    local item = self.item
    if not item:IsWeapon() then
        old_ISToolTipInv_render(self)
        return
    end
    if item:getSubCategory() == "Firearm" then
        injectFireArmsStats(item, self)
    end
    old_ISToolTipInv_render(self)
end

function GetItem(selected)
    for _, value in pairs(selected) do
        if value and value.items then
            for _, item in pairs(value.items) do
                return item
            end
        end
    end

    return nil
end

function GetSelectedWeapon()
    local selectedLoot = GetItem(getPlayerLoot(0).inventoryPane.selected)
    local selectedInventory = GetItem(getPlayerInventory(0).inventoryPane.selected)
    local weapon = selectedLoot or selectedInventory

    if weapon and weapon:IsWeapon() then
        return weapon
    end

    return nil
end
