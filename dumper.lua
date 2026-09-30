local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local out = {}
local function add(s) out[#out + 1] = s end
local function attrs(inst)
    local t = {}
    local ok, a = pcall(function() return inst:GetAttributes() end)
    if ok and type(a) == "table" then for k, v in pairs(a) do t[#t + 1] = k .. "=" .. tostring(v) end end
    table.sort(t)
    return table.concat(t, ", ")
end
local function walk(inst, depth, maxDepth, lines)
    local extra = ""
    if inst:IsA("ScreenGui") then extra = " Enabled=" .. tostring(inst.Enabled) end
    if inst:IsA("GuiObject") then extra = extra .. " Visible=" .. tostring(inst.Visible) end
    lines[#lines + 1] = string.rep("  ", depth) .. inst.ClassName .. ' "' .. inst.Name .. '"' .. extra
    if depth < maxDepth then for _, c in ipairs(inst:GetChildren()) do walk(c, depth + 1, maxDepth, lines) end end
end

add("== PLAYERGUI TOP-LEVEL ==")
local pg = lp:WaitForChild("PlayerGui")
for _, g in ipairs(pg:GetChildren()) do
    local en = g:IsA("ScreenGui") and (" Enabled=" .. tostring(g.Enabled)) or ""
    add(g.ClassName .. ' "' .. g.Name .. '" (' .. #g:GetChildren() .. " children)" .. en)
end

add("")
add("== CANDIDATE LOADER SCREENS (full tree) ==")
local words = { "load", "intro", "splash", "cutscene", "cinematic", "transition", "fade", "preload", "title", "start", "black", "cover", "begin", "enter" }
for _, g in ipairs(pg:GetChildren()) do
    local n = g.Name:lower()
    local hit = false
    for _, w in ipairs(words) do if n:find(w, 1, true) then hit = true break end end
    if hit then
        local lines = {}
        walk(g, 0, 4, lines)
        add(table.concat(lines, "\n"))
        add("")
    end
end

add("== COREGUI SCREENS ==")
local ok, cg = pcall(function() return game:GetService("CoreGui"):GetChildren() end)
if ok then for _, g in ipairs(cg) do pcall(function() add(g.ClassName .. ' "' .. g.Name .. '"') end) end end

add("")
add("== REPLICATEDFIRST ==")
for _, c in ipairs(game:GetService("ReplicatedFirst"):GetChildren()) do add(c.ClassName .. ' "' .. c.Name .. '"') end

add("")
add("== STAT BUTTONS (Menu StatsInfo) ==")
local si = pg:FindFirstChild("StatsInfo", true)
if si then
    for _, stat in ipairs(si:GetChildren()) do
        local point = stat:FindFirstChild("Point")
        if point then
            local bs = {}
            for _, b in ipairs(point:GetChildren()) do
                if b:IsA("TextButton") then bs[#bs + 1] = b.Name .. "='" .. tostring(b.Text) .. "'" end
            end
            add(stat.Name .. ": " .. table.concat(bs, ", "))
        end
    end
else
    add("StatsInfo not found (open the Menu once, then rerun)")
end

add("")
add("== CHARACTER ATTRS ==")
local char = lp.Character or (workspace:FindFirstChild("Live") and workspace.Live:FindFirstChild(lp.Name))
add(char and ('char "' .. char.Name .. '": ' .. attrs(char)) or "no character")

pcall(function() setclipboard(table.concat(out, "\n")) end)
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "COMBO_WICK", Text = "GUI capture copied to clipboard", Duration = 5 })
end)
