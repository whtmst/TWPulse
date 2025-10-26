local TWP = CreateFrame("Frame")

TWP:RegisterEvent("ADDON_LOADED")

TWP:SetScript("OnEvent", function()
    if event then
        if event == "ADDON_LOADED" and arg1 == 'TWPulse' then
            TWPulse:EnableMouse(false)
            TWP.scan:Show()
        end
    end
end)

TWP.tracked = {}

TWP.scan = CreateFrame("Frame")
TWP.scan:Hide()
TWP.scan:SetScript("OnShow", function()
    this.startTime = GetTime()
end)
TWP.scan:SetScript("OnUpdate", function()
    local plus = 0.1 --seconds
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
    if gt >= st then

        local maxSpells = 500;
        local id = 0;
        while (id <= maxSpells) do
            id = id + 1;
            local spellName = GetSpellName(id, BOOKTYPE_SPELL);

            if (spellName) then

                local start, duration, enabled = GetSpellCooldown(id, BOOKTYPE_SPELL);
                local cd = start + duration - GetTime()
                if cd > 1.7 then
                    TWP.tracked[spellName] = id
                end
            end
        end

        for name, spellId in next, TWP.tracked do
            if spellId then
                local start, duration, enabled = GetSpellCooldown(spellId, BOOKTYPE_SPELL);
                local cd = start + duration - GetTime()

                if cd <= 0 then
                    TWP.tracked[name] = nil
                    local tEx = string.split(GetSpellTexture(spellId, BOOKTYPE_SPELL), '\\')
                    local tex = tEx[table.getn(tEx)]
                    TWP.animateQueue[tex] = 1
                    TWP.animation:Show()
                end
            end
        end

        this.startTime = GetTime()
    end
end)

TWP.animationFrames = {}
TWP.animateQueue = {}

TWP.animation = CreateFrame("Frame")
TWP.animation:Hide()

TWP.animation:SetScript("OnShow", function()
    this.startTime = GetTime()
end)
TWP.animation:SetScript("OnHide", function()
end)

TWP.animation:SetScript("OnUpdate", function()
    local plus = 0.01 --seconds
    local gt = GetTime() * 1000
    local st = (this.startTime + plus) * 1000
    if gt >= st then

        for tex, alpha in next, TWP.animateQueue do
            if alpha then

                if not TWP.animationFrames[tex] then
                    TWP.animationFrames[tex] = CreateFrame("Frame", "TWP_" .. tex, TWPulse, "TWPulseTemplate")
                end

                getglobal("TWP_" .. tex .. "Icon"):SetTexture("Interface\\Icons\\" .. tex)
                getglobal("TWP_" .. tex):Show()
                getglobal("TWP_" .. tex):SetAlpha(alpha)
                getglobal("TWP_" .. tex .. "Icon"):SetWidth(getglobal("TWP_" .. tex .. "Icon"):GetWidth() + 0.5)
                getglobal("TWP_" .. tex .. "Icon"):SetHeight(getglobal("TWP_" .. tex .. "Icon"):GetHeight() + 0.5)

                TWP.animateQueue[tex] = TWP.animateQueue[tex] - 0.02

                if TWP.animateQueue[tex] <= 0 then
                    getglobal("TWP_" .. tex):SetAlpha(alpha)
                    getglobal("TWP_" .. tex .. "Icon"):SetWidth(96)
                    getglobal("TWP_" .. tex .. "Icon"):SetHeight(96)
                    getglobal("TWP_" .. tex):SetAlpha(0)
                    TWP.animateQueue[tex] = nil
                end
            end
        end

        if TWP.locked then
            if _tablesize(TWP.animateQueue) > 0 then
                TWPulse:Show()
            else
                TWPulse:Hide()
            end
        end

        this.startTime = GetTime()

    end
end)

TWP.locked = true

SLASH_TWPLOCK1 = "/twplock"
SlashCmdList["TWPLOCK"] = function(cmd)
    if cmd then
        TWP.locked = true
        TWPulseUnlock:Hide()
        TWPulse:Hide()
        TWPulse:EnableMouse(false)
    end
end

SLASH_TWPUNLOCK1 = "/twpunlock"
SlashCmdList["TWPUNLOCK"] = function(cmd)
    if cmd then
        TWP.locked = false
        TWPulseUnlock:Show()
        TWPulse:Show()
        TWPulse:EnableMouse(true)
    end
end

function _tablesize(t)
    local size = 0
    for i in t do
        size = size + 1
    end
    return size
end

function string:split(delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end



