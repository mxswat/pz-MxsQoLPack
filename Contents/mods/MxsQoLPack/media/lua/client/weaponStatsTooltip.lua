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

local function injectTooltip(stats, self)
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
    -- self.tooltip:DrawText(self.tooltip:getFont(), "Calc", x + marginCalc, y, 1, 1, 0.8, borderARGB.a);
    for _, tuple in ipairs(stats) do
        y = y + fontConfig[fontSize].y
        self.tooltip:DrawText(self.tooltip:getFont(), tuple[1] .. ":", x, y, 1, 1, 0.8, 1);
        self.tooltip:DrawText(self.tooltip:getFont(), tostring(tuple[2]), x + marginBase, y, 1, 1, 1, 1);
        -- self.tooltip:DrawText(self.tooltip:getFont(), tostring(tuple[3]), x + marginCalc, y, 1, 1, 1, 1);
    end
end

-- From java\characters\IsoPlayer.java:calculateCritChance()
function GetFirearmsCHC(item)
    local CHC = 0

    return CHC
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
    -- 
    local CHCCalc     = math.min(critChance + (critModifier * perkLevel), CHCMax)
    local damageStat  = tofixed(minDamage) .. " - " .. tofixed(maxDamage)
    local critDmgStat = (critDmg * 100) .. '%'
    local accStat     = math.min(hitChance + (hitChanceModifier * perkLevel), ACCMax)
    local range       = tofixed(minRange) .. " - " .. tofixed(maxRange)

    local selectedLoot = GetFirst(getPlayerLoot(0).inventoryPane.selected)
    local selectedInventory = GetFirst(getPlayerInventory(0).inventoryPane.selected)

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

    injectTooltip(stats, self)
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

-- NOTE 1 -- java\ai\states\SwipeStatePlayer.java
-- Games limits accuracy to 95%

function GetFirst(selected)
    for k, v in pairs(selected) do
        if k and v then
            return selected
        end
    end

    return nil
end
