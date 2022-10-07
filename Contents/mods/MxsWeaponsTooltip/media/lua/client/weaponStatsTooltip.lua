require "WSTUtils"

local iconTexture = getTexture("media/ui/Panel_Icon_Gear.png");
local fontConfig = {
    Small  = { y = 15, iconY = 2 },
    Medium = { y = 20, iconY = 4 },
    Large  = { y = 20, iconY = 6 },
}

local function injectTooltip(stats, self, compared)
    local fontSize = getCore():getOptionTooltipFont();
    local tooltipHeight = self.tooltip:getHeight();
    local height = fontConfig[fontSize].y * (#stats + 1)
    self:setY(self.tooltip:getY() + tooltipHeight);
    self:setHeight(height);
    local hDiff = self.height + 9
    local bgARGB = GetARGB(self.backgroundColor)
    local borderARGB = GetARGB(self.borderColor)
    self:drawRect(0, 0, self.width, hDiff, bgARGB.a, bgARGB.r, bgARGB.g, bgARGB.b);
    self:drawRectBorder(0, 0, self.width, hDiff, borderARGB.a, borderARGB.r, borderARGB.g, borderARGB.b);
    local x = 5
    local y = tooltipHeight + 5
    local marginCurrent = 40
    local marginCompare = 90
    self.tooltip:DrawText(self.tooltip:getFont(), "Stats", x + marginCurrent, y, 1, 1, 0.8, borderARGB.a);
    if compared then
        self.tooltip:DrawText(self.tooltip:getFont(), compared, x + marginCompare, y, 1, 1, 0.8, borderARGB.a);
    end

    for _, statsRow in ipairs(stats) do
        y = y + fontConfig[fontSize].y
        -- self.tooltip:DrawTextureScaledAspect(iconTexture, x - 10, y + fontConfig[fontSize].iconY, 10, 10, 1, 1, 1, 1)
        self.tooltip:DrawText(self.tooltip:getFont(), statsRow[1] .. ":", x, y, 1, 1, 0.8, 1);
        self.tooltip:DrawText(self.tooltip:getFont(), tostring(statsRow[2]), x + marginCurrent, y, 1, 1, 1, 1);
        self.tooltip:DrawText(self.tooltip:getFont(), tostring(statsRow[3] or ''), x + marginCompare, y, 1, 1, 1, 1);
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
    local damageStat  = Tofixed(minDamage) .. " - " .. Tofixed(maxDamage)
    local critDmgStat = (critDmg * 100) .. '%'
    local accStat     = math.min(hitChance + (hitChanceModifier * perkLevel), ACCMax)
    local range       = Tofixed(minRange) .. " - " .. Tofixed(maxRange)
    local soundVolume = item:getSoundVolume()
    local soundRadius = item:getSoundRadius()

    return {
        { "DMG", damageStat },
        { "ACC", accStat .. '%' },
        { "RAN", range },
        { "CHC", Tofixed(CHCCalc) .. '%' },
        { "CHD", critDmgStat },
        { "TRG", maxHit },
        { "SNR", soundRadius },
        { "SNV", soundVolume },
    }
end

local function injectFireArmsStats(item, self)
    local stats = GetFirearmsStats(item)
    local compareWeapon = GetPlayerINVSelectedWeapon()
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
