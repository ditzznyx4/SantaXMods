--[[
╔══════════════════════════════════════════╗
║          SantaXModsKng.lua               ║
║  Developer  : SkyFlow                    ║
║  Youtube    : @Skyflowh4x               ║
║  Tiktok     : @Sky.flow77               ║
║  Version    : 1.12                       ║
║  Executor   : Delta Executor             ║
║  Target     : Roblox FPS (Arsenal, dll)  ║
╚══════════════════════════════════════════╝
]]

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local LP            = Players.LocalPlayer
local Cam           = workspace.CurrentCamera
local PlayerGui     = LP:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════
-- CORE STATE
-- ══════════════════════════════════════════
local State = {
    EnableFunction  = false,
    EnableAim       = false,
    EnableEsp       = false,

    Aimbot          = false,
    AimAssist       = false,
    AimSilent       = false,
    AimMagnet       = false,
    AutoKill        = false,
    AimVisible      = false,
    AimFov          = 150,

    EspLine         = false,
    EspBox          = false,
    EspBox3D        = false,
    EspHealth       = false,
    EspName         = false,
    EspDistance     = false,
    EspSkeleton     = false,
    EspFov          = false,

    Fly             = false,
    AutoFlyStep     = 0,
    HitFly          = false,
    SpeedFly        = 5,
    HighHitFly      = 50,
    SpeedHitFly     = 75,

    TeleportPlayer  = false,
    TeleKill        = false,
    SelectedTarget  = nil,

    SpeedHack       = false,
    JumpHack        = false,
    GhostHack       = false,

    TeamCheck       = true,
}

-- ══════════════════════════════════════════
-- THEME
-- ══════════════════════════════════════════
local T = {
    BgDark      = Color3.fromRGB(12, 12, 12),
    BgMid       = Color3.fromRGB(20, 20, 20),
    BgLight     = Color3.fromRGB(28, 28, 28),
    Accent      = Color3.fromRGB(210, 40, 40),
    AccentDim   = Color3.fromRGB(130, 25, 25),
    TextWhite   = Color3.fromRGB(235, 235, 235),
    TextGray    = Color3.fromRGB(130, 130, 130),
    ToggleOn    = Color3.fromRGB(210, 40, 40),
    ToggleOff   = Color3.fromRGB(50, 50, 50),
    TabActive   = Color3.fromRGB(210, 40, 40),
    TabInactive = Color3.fromRGB(30, 30, 30),
    Green       = Color3.fromRGB(50, 200, 80),
    White       = Color3.fromRGB(255, 255, 255),
    Border      = Color3.fromRGB(40, 40, 40),
    Gray        = Color3.fromRGB(80, 80, 80),
}

-- ══════════════════════════════════════════
-- UTILITY
-- ══════════════════════════════════════════
local function getChar() return LP.Character end
local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function isAimActive()
    return State.EnableFunction and State.EnableAim
end
local function isEspActive()
    return State.EnableFunction and State.EnableEsp
end

local function getClosestEnemy(fov, part)
    local best, bestDist = nil, fov or 300
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if State.TeamCheck and p.Team == LP.Team then continue end
        local c = p.Character
        if not c then continue end
        local tp = c:FindFirstChild(part or "Head") or c:FindFirstChild("HumanoidRootPart")
        if not tp then continue end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then continue end
        local screen, vis = Cam:WorldToViewportPoint(tp.Position)
        if not vis and State.AimVisible then continue end
        if not vis and not State.AimVisible then
            -- wallbang: skip vis check
        end
        local mouse = UIS:GetMouseLocation()
        local dist = (Vector2.new(screen.X, screen.Y) - mouse).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = p
        end
    end
    return best
end

local function killPlayer(target)
    local c = target and target.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end

-- ══════════════════════════════════════════
-- UI HELPERS
-- ══════════════════════════════════════════
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = p
    return c
end

local function stroke(p, c, t)
    local s = Instance.new("UIStroke")
    s.Color = c or T.Border
    s.Thickness = t or 1
    s.Parent = p
    return s
end

local function label(p, txt, size, color, bold, align)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextSize = size or 13
    l.TextColor3 = color or T.TextWhite
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.Size = UDim2.new(1, 0, 0, size and size + 4 or 17)
    l.Parent = p
    return l
end

local function frame(p, size, pos, color, trans)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1, 0, 0, 30)
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = color or T.BgMid
    f.BackgroundTransparency = trans or 0
    f.BorderSizePixel = 0
    f.Parent = p
    return f
end

-- ══════════════════════════════════════════
-- FLOATING LOGO UI FACTORY
-- ══════════════════════════════════════════
local floatingUIs = {}

local function makeFloatingUI(featureName, stateKey, toggleCallback)
    if floatingUIs[stateKey] then
        floatingUIs[stateKey]:Destroy()
        floatingUIs[stateKey] = nil
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Float_" .. stateKey
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui

    -- Header box (abu-abu)
    local headerBox = frame(gui, UDim2.new(0, 180, 0, 28), UDim2.new(0, 10, 0.4, 0), T.Gray)
    corner(headerBox, 5)
    stroke(headerBox, T.Border, 1)
    headerBox.Position = UDim2.new(0, 10, 0.38, 0)

    local headerLabel = label(headerBox, "  " .. featureName, 12, T.TextWhite, true, Enum.TextXAlignment.Center)
    headerLabel.Size = UDim2.new(1, 0, 1, 0)

    -- Toggle box (hitam)
    local toggleBox = frame(gui, UDim2.new(0, 180, 0, 36), nil, T.BgDark)
    corner(toggleBox, 5)
    stroke(toggleBox, T.Border, 1)
    toggleBox.Position = UDim2.new(0, 10, 0.38, 32)

    -- Toggle row
    local row = frame(toggleBox, UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 0, 6), T.BgDark)

    local rowLabel = label(row, featureName, 12, T.TextWhite, false)
    rowLabel.Size = UDim2.new(0.7, 0, 1, 0)

    -- Toggle pill
    local pillBg = frame(row, UDim2.new(0, 36, 0, 18), UDim2.new(1, -40, 0.5, -9),
        State[stateKey] and T.ToggleOn or T.ToggleOff)
    corner(pillBg, 9)

    local pillDot = frame(pillBg, UDim2.new(0, 14, 0, 14), UDim2.new(0, 2, 0.5, -7), T.TextWhite)
    corner(pillDot, 7)

    local function syncPill(val)
        pillBg.BackgroundColor3 = val and T.ToggleOn or T.ToggleOff
        TweenService:Create(pillDot, TweenInfo.new(0.12), {
            Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
    end

    -- Drag
    local dragging, dragStart, startPos = false, nil, nil
    headerBox.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = headerBox.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            headerBox.Position = newPos
            toggleBox.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset, newPos.Y.Scale, newPos.Y.Offset + 32)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Click toggle
    pillBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleCallback(not State[stateKey])
            syncPill(State[stateKey])
        end
    end)
    row.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleCallback(not State[stateKey])
            syncPill(State[stateKey])
        end
    end)

    floatingUIs[stateKey] = gui

    -- Return sync function so main menu can sync
    return function(val)
        syncPill(val)
    end
end

-- ══════════════════════════════════════════
-- AUTO FLY FLOATING UI (3-click)
-- ══════════════════════════════════════════
local autoFlyUI = nil
local autoFlyBody = nil
local autoFlyLocked = false
local autoFlySyncFn = nil

local function makeAutoFlyUI()
    if autoFlyUI then
        autoFlyUI:Destroy()
        autoFlyUI = nil
        State.AutoFlyStep = 0
        autoFlyLocked = false
        if autoFlyBody then autoFlyBody:Destroy() autoFlyBody = nil end
        local hum = getHum()
        if hum then hum.PlatformStand = false end
        return
    end

    autoFlyUI = Instance.new("ScreenGui")
    autoFlyUI.Name = "AutoFlyUI"
    autoFlyUI.ResetOnSpawn = false
    autoFlyUI.Parent = PlayerGui

    local box = frame(autoFlyUI, UDim2.new(0, 200, 0, 90), nil, T.BgDark)
    box.Position = UDim2.new(0, 10, 0.55, 0)
    corner(box, 6)
    stroke(box, T.Accent, 1)

    local hdr = frame(box, UDim2.new(1, 0, 0, 26), UDim2.new(0,0,0,0), T.Gray)
    corner(hdr, 6)
    local hdrTxt = label(hdr, "  Auto Fly", 12, T.TextWhite, true, Enum.TextXAlignment.Center)
    hdrTxt.Size = UDim2.new(1,0,1,0)

    local stepLabel = label(box, "", 12, T.Accent, true, Enum.TextXAlignment.Center)
    stepLabel.Position = UDim2.new(0, 0, 0, 30)
    stepLabel.Size = UDim2.new(1, 0, 0, 20)

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, -16, 0, 26)
    clickBtn.Position = UDim2.new(0, 8, 0, 56)
    clickBtn.BackgroundColor3 = T.Accent
    clickBtn.Text = "Click 1 — Set Position"
    clickBtn.TextColor3 = T.TextWhite
    clickBtn.TextSize = 12
    clickBtn.Font = Enum.Font.GothamBold
    clickBtn.BorderSizePixel = 0
    clickBtn.Parent = box
    corner(clickBtn, 4)

    local stepTexts = {
        [0] = "Click 1 — Set Position",
        [1] = "Click 2 — Start Flying",
        [2] = "Click 3 — Lock Position",
    }

    local function updateStep()
        local s = State.AutoFlyStep
        clickBtn.Text = stepTexts[s] or "Done"
        stepLabel.Text = s == 0 and "Ready" or s == 1 and "Step 1: Position Set" or s == 2 and "Step 2: Flying..." or "Step 3: Locked"
    end
    updateStep()

    -- Drag
    local dragging2, dragStart2, startPos2 = false, nil, nil
    hdr.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging2 = true
            dragStart2 = inp.Position
            startPos2 = box.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging2 and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart2
            box.Position = UDim2.new(
                startPos2.X.Scale, startPos2.X.Offset + delta.X,
                startPos2.Y.Scale, startPos2.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging2 = false end
    end)

    clickBtn.MouseButton1Click:Connect(function()
        local char = getChar()
        local root = getRoot()
        if not char or not root then return end

        if State.AutoFlyStep == 0 then
            -- Step 1: set posisi, avatar diam naik 1m
            State.AutoFlyStep = 1
            local hum = getHum()
            if hum then hum.PlatformStand = true end
            root.CFrame = root.CFrame + Vector3.new(0, 1, 0)
            updateStep()

        elseif State.AutoFlyStep == 1 then
            -- Step 2: terbang keatas terus
            State.AutoFlyStep = 2
            if autoFlyBody then autoFlyBody:Destroy() end
            autoFlyBody = Instance.new("BodyVelocity")
            autoFlyBody.Velocity = Vector3.new(0, State.SpeedFly * 5, 0)
            autoFlyBody.MaxForce = Vector3.new(0, 1e6, 0)
            autoFlyBody.Parent = root
            updateStep()

        elseif State.AutoFlyStep == 2 then
            -- Step 3: lock posisi, bisa aim & shoot
            State.AutoFlyStep = 3
            autoFlyLocked = true
            if autoFlyBody then autoFlyBody:Destroy() end
            -- Lock dengan BodyPosition
            local bp = Instance.new("BodyPosition")
            bp.Position = root.Position
            bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bp.D = 500
            bp.P = 10000
            bp.Parent = root
            autoFlyBody = bp
            updateStep()
        end
    end)
end

-- ══════════════════════════════════════════
-- MAIN GUI
-- ══════════════════════════════════════════
-- Hapus gui lama kalau ada
if PlayerGui:FindFirstChild("SantaXModsKng") then
    PlayerGui:FindFirstChild("SantaXModsKng"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SantaXModsKng"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main window
local MainFrame = frame(ScreenGui, UDim2.new(0, 290, 0, 440), UDim2.new(0.5, -145, 0.5, -220), T.BgDark)
corner(MainFrame, 8)
stroke(MainFrame, T.Accent, 1.5)

-- ── TITLE BAR ──
local TitleBar = frame(MainFrame, UDim2.new(1, 0, 0, 36), UDim2.new(0,0,0,0), T.BgDark)
corner(TitleBar, 8)
stroke(TitleBar, T.Accent, 1)

local TitleTxt = label(TitleBar, "  SantaXMods", 14, T.Accent, true)
TitleTxt.Size = UDim2.new(0.7, 0, 1, 0)
TitleTxt.Position = UDim2.new(0, 0, 0, 0)

local VersionTxt = label(TitleBar, "v1.12  ", 11, T.TextGray, false, Enum.TextXAlignment.Right)
VersionTxt.Size = UDim2.new(1, -8, 1, 0)

-- DRAG
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = inp.Position
        startPos = MainFrame.AbsolutePosition
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = inp.Position - dragStart
        MainFrame.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ── TAB BAR ──
local TabBar = frame(MainFrame, UDim2.new(1, 0, 0, 28), UDim2.new(0,0,0,36), T.BgMid)
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local tabNames = {"Function", "Aim", "Esp", "Fly/Tele", "Misc"}
local tabButtons = {}
local tabPages = {}
local activeTab = "Function"

-- ── CONTENT AREA ──
local ContentArea = frame(MainFrame, UDim2.new(1, 0, 1, -64), UDim2.new(0,0,0,64), T.BgDark)

-- ══════════════════════════════════════════
-- SCROLL FRAME HELPER
-- ══════════════════════════════════════════
local function makeScrollPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = T.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = page

    return page
end

-- ══════════════════════════════════════════
-- WIDGET BUILDERS
-- ══════════════════════════════════════════

-- Section Header
local function makeHeader(parent, txt)
    local hdr = frame(parent, UDim2.new(1, 0, 0, 24), nil, T.BgMid)
    corner(hdr, 4)
    hdr.LayoutOrder = 0
    local lbl = label(hdr, "  " .. txt, 12, T.Accent, true)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    return hdr
end

-- Toggle Row
local syncFns = {}

local function makeToggle(parent, txt, stateKey, order, logoCallback)
    local row = frame(parent, UDim2.new(1, 0, 0, 30), nil, T.BgLight)
    corner(row, 4)
    row.LayoutOrder = order or 1

    local lbl = label(row, "  " .. txt, 12, T.TextWhite, false)
    lbl.Size = UDim2.new(1, -90, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)

    -- Logo button (jika ada)
    local logoBtn = nil
    if logoCallback then
        logoBtn = Instance.new("TextButton")
        logoBtn.Size = UDim2.new(0, 36, 0, 20)
        logoBtn.Position = UDim2.new(1, -84, 0.5, -10)
        logoBtn.BackgroundColor3 = T.Gray
        logoBtn.Text = "⊞"
        logoBtn.TextColor3 = T.TextWhite
        logoBtn.TextSize = 11
        logoBtn.Font = Enum.Font.GothamBold
        logoBtn.BorderSizePixel = 0
        logoBtn.Parent = row
        corner(logoBtn, 3)
    end

    -- Toggle pill
    local pillBg = frame(row, UDim2.new(0, 36, 0, 18),
        UDim2.new(1, logoCallback and -44 or -44, 0.5, -9),
        State[stateKey] and T.ToggleOn or T.ToggleOff)
    corner(pillBg, 9)

    local pillDot = frame(pillBg, UDim2.new(0, 14, 0, 14), UDim2.new(0, 2, 0.5, -7), T.TextWhite)
    corner(pillDot, 7)

    local floatSyncFn = nil

    local function setPill(val)
        TweenService:Create(pillBg, TweenInfo.new(0.12), {
            BackgroundColor3 = val and T.ToggleOn or T.ToggleOff
        }):Play()
        TweenService:Create(pillDot, TweenInfo.new(0.12), {
            Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if floatSyncFn then floatSyncFn(val) end
    end

    local function doToggle()
        local newVal = not State[stateKey]
        State[stateKey] = newVal
        setPill(newVal)
        -- Sync float UI if open
        if floatSyncFn then floatSyncFn(newVal) end
    end

    pillBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then doToggle() end
    end)

    if logoBtn and logoCallback then
        logoBtn.MouseButton1Click:Connect(function()
            floatSyncFn = logoCallback(txt, stateKey, function(val)
                State[stateKey] = val
                setPill(val)
            end)
        end)
    end

    syncFns[stateKey] = setPill
    return row, setPill
end

-- Slider Row
local function makeSlider(parent, txt, stateKey, minVal, maxVal, order)
    local row = frame(parent, UDim2.new(1, 0, 0, 46), nil, T.BgLight)
    corner(row, 4)
    row.LayoutOrder = order or 1

    local lbl = label(row, "  " .. txt, 12, T.TextWhite, false)
    lbl.Size = UDim2.new(0.7, 0, 0, 20)
    lbl.Position = UDim2.new(0, 0, 0, 2)

    local valLbl = label(row, tostring(State[stateKey]), 12, T.Accent, true, Enum.TextXAlignment.Right)
    valLbl.Size = UDim2.new(0.3, -8, 0, 20)
    valLbl.Position = UDim2.new(0.7, 0, 0, 2)

    local track = frame(row, UDim2.new(1, -16, 0, 4), UDim2.new(0, 8, 0, 30), T.BgMid)
    corner(track, 2)

    local pct = math.clamp((State[stateKey] - minVal) / (maxVal - minVal), 0, 1)
    local fill = frame(track, UDim2.new(pct, 0, 1, 0), nil, T.Accent)
    corner(fill, 2)

    local thumb = frame(track, UDim2.new(0, 12, 0, 12), UDim2.new(pct, -6, 0.5, -6), T.TextWhite)
    corner(thumb, 6)

    local sliding = false
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UIS.InputChanged:Connect(function(inp)
        if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local newVal = math.floor(minVal + rel * (maxVal - minVal))
            State[stateKey] = newVal
            fill.Size = UDim2.new(rel, 0, 1, 0)
            thumb.Position = UDim2.new(rel, -6, 0.5, -6)
            valLbl.Text = tostring(newVal)
        end
    end)

    return row
end

-- Divider
local function makeDivider(parent, order)
    local d = frame(parent, UDim2.new(1, 0, 0, 1), nil, T.Border)
    d.LayoutOrder = order or 99
    return d
end

-- Dropdown for target select
local dropdownOpen = false
local dropdownFrame = nil

local function makeDropdown(parent, order)
    local row = frame(parent, UDim2.new(1, 0, 0, 30), nil, T.BgLight)
    corner(row, 4)
    row.LayoutOrder = order or 1

    local lbl = label(row, "  Select Target", 12, T.TextWhite, false)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.48, -4, 0, 22)
    btn.Position = UDim2.new(0.52, 0, 0.5, -11)
    btn.BackgroundColor3 = T.BgMid
    btn.Text = State.SelectedTarget or "None ▾"
    btn.TextColor3 = T.TextGray
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = row
    corner(btn, 4)
    stroke(btn, T.Border, 1)

    btn.MouseButton1Click:Connect(function()
        if dropdownFrame then
            dropdownFrame:Destroy()
            dropdownFrame = nil
            dropdownOpen = false
            return
        end
        dropdownOpen = true

        dropdownFrame = frame(ScreenGui, UDim2.new(0, 140, 0, 0), nil, T.BgMid)
        corner(dropdownFrame, 4)
        stroke(dropdownFrame, T.Border, 1)
        dropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
        dropdownFrame.ZIndex = 20

        local absPos = btn.AbsolutePosition
        dropdownFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + 26)

        local ddLayout = Instance.new("UIListLayout")
        ddLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ddLayout.Parent = dropdownFrame

        local ddPad = Instance.new("UIPadding")
        ddPad.PaddingTop = UDim.new(0, 4)
        ddPad.PaddingBottom = UDim.new(0, 4)
        ddPad.Parent = dropdownFrame

        local found = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            found = found + 1
            local item = Instance.new("TextButton")
            item.Size = UDim2.new(1, 0, 0, 24)
            item.BackgroundTransparency = 1
            item.Text = "  " .. p.Name
            item.TextColor3 = T.TextWhite
            item.TextSize = 11
            item.Font = Enum.Font.Gotham
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.LayoutOrder = found
            item.Parent = dropdownFrame

            item.MouseButton1Click:Connect(function()
                State.SelectedTarget = p.Name
                btn.Text = p.Name .. " ▾"
                btn.TextColor3 = T.Accent
                dropdownFrame:Destroy()
                dropdownFrame = nil
                dropdownOpen = false
            end)
        end

        if found == 0 then
            local none = label(dropdownFrame, "  No players", 11, T.TextGray)
            none.Size = UDim2.new(1, 0, 0, 24)
        end
    end)

    return row
end

-- ══════════════════════════════════════════
-- PAGES BUILD
-- ══════════════════════════════════════════

-- ── PAGE 1: FUNCTION ──
local pageFunction = makeScrollPage("Function")
makeHeader(pageFunction, "Function").LayoutOrder = 1

-- Master toggles
local masterRow1 = frame(pageFunction, UDim2.new(1, 0, 0, 30), nil, T.BgLight)
corner(masterRow1, 4)
masterRow1.LayoutOrder = 2
local ml1 = label(masterRow1, "  Enable Function", 12, T.TextWhite, true)
ml1.Size = UDim2.new(0.7, 0, 1, 0)
local p1bg = frame(masterRow1, UDim2.new(0, 36, 0, 18), UDim2.new(1, -44, 0.5, -9), T.ToggleOff)
corner(p1bg, 9)
local p1dot = frame(p1bg, UDim2.new(0,14,0,14), UDim2.new(0,2,0.5,-7), T.TextWhite)
corner(p1dot, 7)
p1bg.InputBegan:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    State.EnableFunction = not State.EnableFunction
    TweenService:Create(p1bg, TweenInfo.new(0.12), {BackgroundColor3 = State.EnableFunction and T.ToggleOn or T.ToggleOff}):Play()
    TweenService:Create(p1dot, TweenInfo.new(0.12), {Position = State.EnableFunction and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
end)

local masterRow2 = frame(pageFunction, UDim2.new(1, 0, 0, 30), nil, T.BgLight)
corner(masterRow2, 4)
masterRow2.LayoutOrder = 3
local ml2 = label(masterRow2, "  Enable Aim", 12, T.TextWhite, false)
ml2.Size = UDim2.new(0.7, 0, 1, 0)
local p2bg = frame(masterRow2, UDim2.new(0, 36, 0, 18), UDim2.new(1, -44, 0.5, -9), T.ToggleOff)
corner(p2bg, 9)
local p2dot = frame(p2bg, UDim2.new(0,14,0,14), UDim2.new(0,2,0.5,-7), T.TextWhite)
corner(p2dot, 7)
p2bg.InputBegan:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    State.EnableAim = not State.EnableAim
    TweenService:Create(p2bg, TweenInfo.new(0.12), {BackgroundColor3 = State.EnableAim and T.ToggleOn or T.ToggleOff}):Play()
    TweenService:Create(p2dot, TweenInfo.new(0.12), {Position = State.EnableAim and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
end)

local masterRow3 = frame(pageFunction, UDim2.new(1, 0, 0, 30), nil, T.BgLight)
corner(masterRow3, 4)
masterRow3.LayoutOrder = 4
local ml3 = label(masterRow3, "  Enable Esp", 12, T.TextWhite, false)
ml3.Size = UDim2.new(0.7, 0, 1, 0)
local p3bg = frame(masterRow3, UDim2.new(0, 36, 0, 18), UDim2.new(1, -44, 0.5, -9), T.ToggleOff)
corner(p3bg, 9)
local p3dot = frame(p3bg, UDim2.new(0,14,0,14), UDim2.new(0,2,0.5,-7), T.TextWhite)
corner(p3dot, 7)
p3bg.InputBegan:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    State.EnableEsp = not State.EnableEsp
    TweenService:Create(p3bg, TweenInfo.new(0.12), {BackgroundColor3 = State.EnableEsp and T.ToggleOn or T.ToggleOff}):Play()
    TweenService:Create(p3dot, TweenInfo.new(0.12), {Position = State.EnableEsp and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
end)

makeDivider(pageFunction, 5)

-- Info box
local infoBox = frame(pageFunction, UDim2.new(1, 0, 0, 110), nil, T.BgMid)
corner(infoBox, 6)
infoBox.LayoutOrder = 6

local infoPad = Instance.new("UIPadding")
infoPad.PaddingLeft = UDim.new(0, 8)
infoPad.PaddingTop = UDim.new(0, 6)
infoPad.PaddingRight = UDim.new(0, 8)
infoPad.Parent = infoBox

local releaseHdr = label(infoBox, "Release Version Official.  | Details", 11, T.Accent, true)
releaseHdr.Size = UDim2.new(1, -16, 0, 16)
releaseHdr.Position = UDim2.new(0, 8, 0, 6)

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, -16, 0, 52)
desc.Position = UDim2.new(0, 8, 0, 24)
desc.BackgroundTransparency = 1
desc.Text = "SantaXMods has been released with\nthe official version."
desc.TextColor3 = T.TextGray
desc.TextSize = 11
desc.Font = Enum.Font.Gotham
desc.TextXAlignment = Enum.TextXAlignment.Left
desc.TextYAlignment = Enum.TextYAlignment.Top
desc.TextWrapped = true
desc.Parent = infoBox

local devInfo = label(infoBox, "Developer: SkyFlow", 10, T.TextGray)
devInfo.Size = UDim2.new(1,-16,0,14)
devInfo.Position = UDim2.new(0,8,0,78)

local ytInfo = label(infoBox, "Youtube: @Skyflowh4x  |  Tiktok: @Sky.flow77", 10, T.TextGray)
ytInfo.Size = UDim2.new(1,-16,0,14)
ytInfo.Position = UDim2.new(0,8,0,92)

-- ── PAGE 2: AIM ──
local pageAim = makeScrollPage("Aim")
makeHeader(pageAim, "Aim Function").LayoutOrder = 1

local aimFeatures = {
    {"Aimbot",       "Aimbot",    false},
    {"Aim Assist",   "AimAssist", false},
    {"Aim Silent",   "AimSilent", true},
    {"Aim Magnet",   "AimMagnet", true},
    {"AutoKill",     "AutoKill",  true},
    {"Aim Visible",  "AimVisible",false},
}

for i, feat in ipairs(aimFeatures) do
    makeToggle(pageAim, feat[1], feat[2], i+1,
        feat[3] and makeFloatingUI or nil)
end

makeSlider(pageAim, "Aim FOV", "AimFov", 0, 360, 20)

-- ── PAGE 3: ESP ──
local pageEsp = makeScrollPage("Esp")
makeHeader(pageEsp, "Esp Function").LayoutOrder = 1

local espFeatures = {
    {"Esp Line",     "EspLine"},
    {"Esp Box",      "EspBox"},
    {"Esp Box 3D",   "EspBox3D"},
    {"Esp Health",   "EspHealth"},
    {"Esp Name",     "EspName"},
    {"Esp Distance", "EspDistance"},
    {"Esp Skeleton", "EspSkeleton"},
    {"Esp Fov",      "EspFov"},
}

for i, feat in ipairs(espFeatures) do
    makeToggle(pageEsp, feat[1], feat[2], i+1, nil)
end

-- ── PAGE 4: FLY/TELE ──
local pageFly = makeScrollPage("Fly/Tele")
makeHeader(pageFly, "Fly Function").LayoutOrder = 1

makeToggle(pageFly, "Fly", "Fly", 2, nil)

-- Auto Fly (logo-style button)
local afRow = frame(pageFly, UDim2.new(1, 0, 0, 30), nil, T.BgLight)
corner(afRow, 4)
afRow.LayoutOrder = 3
local afLbl = label(afRow, "  Auto Fly", 12, T.TextWhite, false)
afLbl.Size = UDim2.new(0.6, 0, 1, 0)
local afBtn = Instance.new("TextButton")
afBtn.Size = UDim2.new(0, 36, 0, 20)
afBtn.Position = UDim2.new(1, -44, 0.5, -10)
afBtn.BackgroundColor3 = T.Gray
afBtn.Text = "⊞"
afBtn.TextColor3 = T.TextWhite
afBtn.TextSize = 11
afBtn.Font = Enum.Font.GothamBold
afBtn.BorderSizePixel = 0
afBtn.Parent = afRow
corner(afBtn, 3)
afBtn.MouseButton1Click:Connect(function()
    makeAutoFlyUI()
end)

makeToggle(pageFly, "Hit Fly", "HitFly", 4, nil)
makeSlider(pageFly, "Speed Fly", "SpeedFly", 1, 10, 5)
makeSlider(pageFly, "High Hit Fly (m)", "HighHitFly", 0, 100, 6)
makeSlider(pageFly, "Speed Hit Fly (m)", "SpeedHitFly", 0, 150, 7)

makeDivider(pageFly, 8)
makeHeader(pageFly, "Teleport Function").LayoutOrder = 9

makeToggle(pageFly, "Teleport Player", "TeleportPlayer", 10, nil)
makeToggle(pageFly, "TeleKill", "TeleKill", 11, makeFloatingUI)
makeDropdown(pageFly, 12)

-- ── PAGE 5: MISC ──
local pageMisc = makeScrollPage("Misc")
makeHeader(pageMisc, "Misc Function").LayoutOrder = 1
makeToggle(pageMisc, "SpeedHack",  "SpeedHack",  2, nil)
makeToggle(pageMisc, "JumpHack",   "JumpHack",   3, nil)
makeToggle(pageMisc, "GhostHack",  "GhostHack",  4, nil)

-- ══════════════════════════════════════════
-- TAB BUTTONS BUILD
-- ══════════════════════════════════════════
local pageMap = {
    ["Function"] = pageFunction,
    ["Aim"]      = pageAim,
    ["Esp"]      = pageEsp,
    ["Fly/Tele"] = pageFly,
    ["Misc"]     = pageMisc,
}

local function switchTab(name)
    activeTab = name
    for _, pg in pairs(pageMap) do pg.Visible = false end
    if pageMap[name] then pageMap[name].Visible = true end
    for n, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = n == name and T.TabActive or T.TabInactive
        btn.TextColor3 = n == name and T.TextWhite or T.TextGray
    end
end

for i, tabName in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 54, 1, 0)
    btn.BackgroundColor3 = i == 1 and T.TabActive or T.TabInactive
    btn.Text = tabName == "Fly/Tele" and "Fly" or tabName == "Function" and "Func" or tabName
    btn.TextColor3 = i == 1 and T.TextWhite or T.TextGray
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder = i
    btn.Parent = TabBar
    corner(btn, 0)
    tabButtons[tabName] = btn
    btn.MouseButton1Click:Connect(function() switchTab(tabName) end)
end

switchTab("Function")

-- ══════════════════════════════════════════
-- ESP DRAW ENGINE
-- ══════════════════════════════════════════
local espObjects = {}

local function clearEsp(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            if obj and obj.Parent then obj:Destroy() end
        end
        espObjects[player] = nil
    end
end

local espGui = Instance.new("ScreenGui")
espGui.Name = "SantaXEsp"
espGui.ResetOnSpawn = false
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.Parent = PlayerGui

local function drawEsp(player)
    local c = player.Character
    if not c then clearEsp(player) return end
    local root = c:FindFirstChild("HumanoidRootPart")
    local hum  = c:FindFirstChildOfClass("Humanoid")
    if not root or not hum then clearEsp(player) return end
    if hum.Health <= 0 then clearEsp(player) return end

    local screenPos, vis = Cam:WorldToViewportPoint(root.Position)
    if not vis then clearEsp(player) return end

    if not espObjects[player] then espObjects[player] = {} end
    local obj = espObjects[player]

    -- distance
    local dist = math.floor((LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        and (LP.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0)

    -- top/bottom screen pos
    local headPos  = c:FindFirstChild("Head") and Cam:WorldToViewportPoint(c.Head.Position + Vector3.new(0,0.7,0))
    local feetPos  = Cam:WorldToViewportPoint(root.Position - Vector3.new(0,2.5,0))

    if not headPos then return end

    local topY    = headPos.Y
    local botY    = feetPos.Y
    local boxH    = botY - topY
    local boxW    = boxH * 0.45
    local centerX = screenPos.X

    -- ESP BOX
    if State.EspBox then
        if not obj.box then
            obj.box = Instance.new("Frame")
            obj.box.BackgroundTransparency = 1
            obj.box.BorderSizePixel = 1
            obj.box.BorderColor3 = T.White
            obj.box.Parent = espGui
        end
        obj.box.Position = UDim2.new(0, centerX - boxW/2, 0, topY)
        obj.box.Size = UDim2.new(0, boxW, 0, boxH)
    elseif obj.box then obj.box:Destroy() obj.box = nil end

    -- ESP NAME
    if State.EspName then
        if not obj.name then
            obj.name = Instance.new("TextLabel")
            obj.name.BackgroundTransparency = 1
            obj.name.TextColor3 = T.Accent
            obj.name.TextSize = 11
            obj.name.Font = Enum.Font.GothamBold
            obj.name.Parent = espGui
        end
        obj.name.Text = player.Name
        obj.name.Position = UDim2.new(0, centerX - 50, 0, topY - 16)
        obj.name.Size = UDim2.new(0, 100, 0, 14)
    elseif obj.name then obj.name:Destroy() obj.name = nil end

    -- ESP DISTANCE
    if State.EspDistance then
        if not obj.dist then
            obj.dist = Instance.new("TextLabel")
            obj.dist.BackgroundTransparency = 1
            obj.dist.TextColor3 = T.Accent
            obj.dist.TextSize = 10
            obj.dist.Font = Enum.Font.Gotham
            obj.dist.Parent = espGui
        end
        obj.dist.Text = dist .. "m"
        obj.dist.Position = UDim2.new(0, centerX - 30, 0, botY + 2)
        obj.dist.Size = UDim2.new(0, 60, 0, 14)
    elseif obj.dist then obj.dist:Destroy() obj.dist = nil end

    -- ESP HEALTH BAR
    if State.EspHealth then
        if not obj.healthBg then
            obj.healthBg = Instance.new("Frame")
            obj.healthBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
            obj.healthBg.BorderSizePixel = 0
            obj.healthBg.Parent = espGui

            obj.healthFill = Instance.new("Frame")
            obj.healthFill.BackgroundColor3 = T.Green
            obj.healthFill.BorderSizePixel = 0
            obj.healthFill.Parent = obj.healthBg
        end
        local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        obj.healthBg.Position = UDim2.new(0, centerX - boxW/2 - 6, 0, topY)
        obj.healthBg.Size = UDim2.new(0, 4, 0, boxH)
        obj.healthFill.Size = UDim2.new(1, 0, hp, 0)
        obj.healthFill.Position = UDim2.new(0, 0, 1 - hp, 0)
    elseif obj.healthBg then
        obj.healthBg:Destroy() obj.healthBg = nil
        if obj.healthFill then obj.healthFill:Destroy() obj.healthFill = nil end
    end

    -- ESP LINE
    if State.EspLine then
        if not obj.line then
            obj.line = Instance.new("Frame")
            obj.line.BackgroundColor3 = T.White
            obj.line.BorderSizePixel = 0
            obj.line.Parent = espGui
        end
        local vp = Cam.ViewportSize
        local midX = vp.X / 2
        local midY = 0
        local dx = centerX - midX
        local dy = screenPos.Y - midY
        local len = math.sqrt(dx*dx + dy*dy)
        local angle = math.atan2(dy, dx)
        obj.line.Position = UDim2.new(0, midX, 0, midY)
        obj.line.Size = UDim2.new(0, len, 0, 1)
        obj.line.Rotation = math.deg(angle)
    elseif obj.line then obj.line:Destroy() obj.line = nil end
end

-- ESP FOV CIRCLE
local espFovCircle = Instance.new("Frame")
espFovCircle.BackgroundTransparency = 1
espFovCircle.BorderSizePixel = 2
espFovCircle.BorderColor3 = T.Accent
espFovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
espFovCircle.Visible = false
espFovCircle.Parent = espGui
corner(espFovCircle, 999)

-- ══════════════════════════════════════════
-- AIM ENGINE
-- ══════════════════════════════════════════
local silentOrigCF = nil
local silentShooting = false

-- AimSilent: redirect kamera saat klik
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not isAimActive() or not State.AimSilent then return end

    local target = getClosestEnemy(State.AimFov, "Head")
    if not target then return end

    silentOrigCF = Cam.CFrame
    silentShooting = true
    local tc = CFrame.new(Cam.CFrame.Position, target.Character.Head.Position)
    Cam.CFrame = tc

    task.defer(function()
        task.wait()
        if silentOrigCF and silentShooting then
            Cam.CFrame = silentOrigCF
            silentShooting = false
            silentOrigCF = nil
        end
    end)
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        if silentOrigCF then
            Cam.CFrame = silentOrigCF
            silentOrigCF = nil
            silentShooting = false
        end
    end
end)

-- FLY ENGINE
local flyBody = nil

local function enableFly()
    local char = getChar()
    local root = getRoot()
    if not char or not root then return end
    local hum = getHum()
    if hum then hum.PlatformStand = true end
    if flyBody then flyBody:Destroy() end
    flyBody = Instance.new("BodyVelocity")
    flyBody.Velocity = Vector3.zero
    flyBody.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBody.Parent = root
end

local function disableFly()
    local char = getChar()
    if char then
        local hum = getHum()
        if hum then hum.PlatformStand = false end
    end
    if flyBody then flyBody:Destroy() flyBody = nil end
end

-- GHOST ENGINE
local ghostOriginals = {}

local function applyGhost(char, on)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if on then
                ghostOriginals[p] = p.LocalTransparencyModifier
                p.LocalTransparencyModifier = p.Name == "HumanoidRootPart" and 0 or 1
            else
                if ghostOriginals[p] ~= nil then
                    p.LocalTransparencyModifier = ghostOriginals[p]
                end
            end
        end
    end
    if not on then ghostOriginals = {} end
end

-- TELEKILL ENGINE
local teleKillRunning = false

local function doTeleKill()
    if teleKillRunning then return end
    teleKillRunning = true
    task.spawn(function()
        while State.TeleKill and isAimActive() do
            local target = nil
            if State.SelectedTarget then
                target = Players:FindFirstChild(State.SelectedTarget)
            end
            if not target then
                target = getClosestEnemy(9999, "HumanoidRootPart")
            end
            if target then
                local tc = target.Character
                local tr = tc and tc:FindFirstChild("HumanoidRootPart")
                local mr = getRoot()
                if tr and mr then
                    mr.CFrame = tr.CFrame * CFrame.new(0, 0, -2)
                    task.wait(0.05)
                    killPlayer(target)
                end
            end
            task.wait(0.8)
        end
        teleKillRunning = false
    end)
end

-- TELEPORT PLAYER ENGINE
local function doTeleportPlayer()
    local target = nil
    if State.SelectedTarget then
        target = Players:FindFirstChild(State.SelectedTarget)
    end
    if not target then
        target = getClosestEnemy(9999, "HumanoidRootPart")
    end
    if not target then return end
    local tc = target.Character
    local tr = tc and tc:FindFirstChild("HumanoidRootPart")
    local mr = getRoot()
    if tr and mr then
        mr.CFrame = tr.CFrame * CFrame.new(0, 0, -2)
    end
end

UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.P and State.TeleportPlayer then
        doTeleportPlayer()
    end
end)

-- ══════════════════════════════════════════
-- MAIN LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- AIM MAGNET
    if isAimActive() and State.AimMagnet and
       UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestEnemy(State.AimFov, "Head")
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local tc = CFrame.new(Cam.CFrame.Position, target.Character.Head.Position)
            Cam.CFrame = Cam.CFrame:Lerp(tc, 0.15)
        end
    end

    -- AIMBOT
    if isAimActive() and State.Aimbot and
       UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestEnemy(State.AimFov, "Head")
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local tc = CFrame.new(Cam.CFrame.Position, target.Character.Head.Position)
            Cam.CFrame = Cam.CFrame:Lerp(tc, 0.35)
        end
    end

    -- AIM ASSIST (softer)
    if isAimActive() and State.AimAssist and
       UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestEnemy(State.AimFov, "HumanoidRootPart")
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local tc = CFrame.new(Cam.CFrame.Position, target.Character.HumanoidRootPart.Position)
            Cam.CFrame = Cam.CFrame:Lerp(tc, 0.06)
        end
    end

    -- AUTOKILL
    if isAimActive() and State.AutoKill then
        local target = getClosestEnemy(State.AimFov, "Head")
        if target then killPlayer(target) end
    end

    -- TELEKILL TRIGGER
    if isAimActive() and State.TeleKill then
        doTeleKill()
    end

    -- FLY
    if State.Fly then
        if not flyBody then enableFly() end
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        if flyBody then flyBody.Velocity = dir * (State.SpeedFly * 8) end
    else
        if flyBody then disableFly() end
    end

    -- SPEEDHACK
    local hum = getHum()
    if hum then
        hum.WalkSpeed  = State.SpeedHack  and 80  or (State.Fly and 16 or 16)
        hum.JumpPower  = State.JumpHack   and 120 or 50
    end

    -- GHOST
    local char = getChar()
    if char then
        if State.GhostHack then
            applyGhost(char, true)
        else
            if next(ghostOriginals) ~= nil then
                applyGhost(char, false)
            end
        end
    end

    -- ESP RENDER
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LP then continue end
        if isEspActive() and (State.EspBox or State.EspName or State.EspDistance
            or State.EspHealth or State.EspLine) then
            drawEsp(player)
        else
            clearEsp(player)
        end
    end

    -- ESP FOV CIRCLE
    if isEspActive() and State.EspFov then
        local mouse = UIS:GetMouseLocation()
        espFovCircle.Visible = true
        espFovCircle.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
        espFovCircle.Size = UDim2.new(0, State.AimFov*2, 0, State.AimFov*2)
    else
        espFovCircle.Visible = false
    end
end)

-- Cleanup on player remove
Players.PlayerRemoving:Connect(function(p)
    clearEsp(p)
end)

print("[ SantaXModsKng v1.12 ] Loaded — Developer: SkyFlow")
