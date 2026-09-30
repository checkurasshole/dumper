local SRC = [==[
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer
local function note(t) pcall(function() StarterGui:SetCore("SendNotification", { Title = "COMBO_WICK", Text = t, Duration = 6 }) end) end

local function dumpTree(root)
    local lines, n = {}, 0
    local function walk(inst, depth)
        n = n + 1
        if n > 1200 then return end
        local ex = ""
        if inst:IsA("ScreenGui") then ex = ex .. " Enabled=" .. tostring(inst.Enabled) end
        if inst:IsA("GuiObject") then ex = ex .. " Vis=" .. tostring(inst.Visible) end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then ex = ex .. " Text='" .. tostring(inst.Text) .. "'" end
        lines[#lines + 1] = string.rep("  ", depth) .. inst.ClassName .. ' "' .. inst.Name .. '"' .. ex
        if depth < 9 then for _, c in ipairs(inst:GetChildren()) do walk(c, depth + 1) end end
    end
    walk(root, 0)
    return table.concat(lines, "\n")
end

local function looksLoader(g)
    local n, cnt = g.Name:lower(), 0
    if n:find("load") or n:find("skip") or n:find("intro") then return true end
    for _, d in ipairs(g:GetDescendants()) do
        cnt = cnt + 1
        if cnt > 400 then break end
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local t = tostring(d.Text or ""):lower()
            if t:find("loading") or t:find("loaded") or t:find("skip") then return true end
        end
        local dn = d.Name:lower()
        if dn:find("skip") or dn:find("loadingscreen") then return true end
    end
    return false
end

local captured = false
local function tryCapture(reason)
    if captured then return end
    local pg = lp:FindFirstChild("PlayerGui")
    local roots = {}
    if pg then for _, g in ipairs(pg:GetChildren()) do if g:IsA("ScreenGui") then roots[#roots + 1] = g end end end
    pcall(function() for _, g in ipairs(CoreGui:GetChildren()) do local nn = g.Name:lower() if nn:find("load") or nn:find("skip") then roots[#roots + 1] = g end end end)
    for _, g in ipairs(roots) do
        if g.Name ~= "COMBO_WICK" and looksLoader(g) then
            captured = true
            local hdr = "== LOADER CAPTURE (" .. reason .. ")  root=" .. g.ClassName .. ' "' .. g.Name .. '"  parent=' .. tostring(g.Parent and (g.Parent.ClassName .. "." .. g.Parent.Name)) .. " ==\n"
            pcall(function() setclipboard(hdr .. dumpTree(g)) end)
            note("LOADER CAPTURED -> clipboard. Paste it to Claude.")
            return
        end
    end
end

tryCapture("immediate")
local pg = lp:WaitForChild("PlayerGui", 10)
if pg then pg.DescendantAdded:Connect(function() task.wait() tryCapture("pg") end) end
task.spawn(function()
    for _ = 1, 80 do
        if captured then break end
        tryCapture("poll")
        task.wait(0.4)
    end
    if not captured then note("No loader detected in ~30s.") end
end)
]==]

local qot = queueonteleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queueonteleport) or queue_on_teleport
local queued = false
if qot then queued = (pcall(qot, SRC)) end

local ok, fn = pcall(loadstring, SRC)
if ok and fn then task.spawn(fn) end

local StarterGui = game:GetService("StarterGui")
local function note(t) pcall(function() StarterGui:SetCore("SendNotification", { Title = "COMBO_WICK", Text = t, Duration = 6 }) end) end

if queued then
    note("Armed. Rejoining in 4s to catch the loader...")
    task.wait(4)
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, lp) end)
else
    note("No teleport-queue support. Set this script to autoexec, then rejoin to capture.")
end
