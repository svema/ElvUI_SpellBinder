local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local addonName, addon = ...

-- Prints all the key value pairs in the given table (See python's dir() function)
function addon:dir(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end

-- Returns the length of the given table
function addon:TableLength(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

local tooltip = CreateFrame("GameTooltip", "SpellScanTooltip", UIParent, "GameTooltipTemplate")
function addon:GetSpellText(spellNum, bookType)
    tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    tooltip:ClearLines()
    tooltip:SetSpellBookItem(spellNum, bookType)
    local n = ""
    for i = 1, tooltip:NumLines() do
        local lName = "SpellScanTooltipTextLeft" .. tostring(i)
        local rName = "SpellScanTooltipTextRight" .. tostring(i)

        local r, g, b, a = _G[lName]:GetTextColor()
        local hexColor = string.format("|c%02x%02x%02x%02x", a*255, r*255, g*255, b*255)
        n = string.format("%s%s%-30s", n, hexColor, _G[lName]:GetText())

        if _G[rName]:GetText() then
            local r, g, b, a = _G[rName]:GetTextColor()
            hexColor = string.format("|c%02x%02x%02x%02x", a*255, r*255, g*255, b*255)
            n = string.format("%s%s%20s", n, hexColor, _G[rName]:GetText())
        end

        n = n .. "|r\n"
    end
    return n
end

function addon:GetBinding()
    local shift = ""
    local ctrl = ""
    local alt = ""
    local text = ""
    local button = GetMouseButtonClicked()

    if IsAltKeyDown() then
        alt = "alt"
        text = "Alt"
    end
    if IsShiftKeyDown() then
        shift = "shift"
        text = text .. (text == "" and "Shift" or "+Shift")
    end
    if IsControlKeyDown() then
        ctrl = "ctrl"
        text = text .. (text == "" and "Ctrl" or "+Ctrl")
    end

    text = text .. (text == "" and button or "+" .. button)

    return text, alt, shift, ctrl, button
end

-- Print contents of `tbl`, with indentation.
-- `indent` sets the initial level of indentation.
function addon:Dump (tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            dump(v, indent+1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        elseif type(v) == 'vector' then
            print(formatting .. v.GetPos())
        else
            print(formatting .. tostring(v))
        end
    end
end

function addon:TableKeysToSortedArray(t)
    local a = {}
    for k in pairs(t) do table.insert(a, k) end
    table.sort(a)

    return a
end

function addon:TableContains(t, key)
    if t == nil then return false end
    return t[key] ~= nil
end

local messageMap = {}

function addon:RegisterMessage(name, handler)
    assert(messageMap[name] == nil, "Attempt to re-register message: " .. tostring(name))
    messageMap[name] = handler and handler or name
end

function addon:UnregisterMessage(name)
    assert(type(event) == "string", "Invalid argument to 'UnregisterMessage'")
    messageMap[name] = nil
end

function addon:FireMessage(name, ...)
    assert(type(name) == "string", "Invalid argument to 'FireMessage'")
    local handler = messageMap[name]
    local handler_t = type(handler)
    if handler_t == "function" then
        handler(name, ...)
    elseif handler_t == "string" and addon[handler] then
        addon[handler](addon, event, ...)
    end
end