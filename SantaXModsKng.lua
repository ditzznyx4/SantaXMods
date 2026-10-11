--[[
  ╔══════════════════════════════════╗
  ║     SantaXModsKng  v1.12        ║
  ║  Developer : SkyFlow             ║
  ║  Youtube   : @Skyflowh4x        ║
  ║  Tiktok    : @Sky.flow77        ║
  ╚══════════════════════════════════╝
  Delta Executor | Roblox FPS
]]

-- ═══════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TweenSvc   = game:GetService("TweenService")
local LP         = Players.LocalPlayer
local Cam        = workspace.CurrentCamera
local PGui       = LP:WaitForChild("PlayerGui")

-- ═══════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════
for _, g in ipairs(PGui:GetChildren()) do
    if g.Name:find("SantaX") or g.Name:find("Float_") or g.Name:find("AutoFly") then
        g:Destroy()
    end
end

-- ═══════════════════════════════════
-- STATE
-- ═══════════════════════════════════
local S = {
    -- Master
    EnableFunction  = false,
    EnableAim       = false,
    EnableEsp       = false,
    -- Aim
    Aimbot          = false,
    AimAssist       = false,
    AimSilent       = false,
    AimMagnet       = false,
    AutoKill        = false,
    AimVisible      = false,
    AimFov          = 150,
    -- Esp
    EspLine         = false,
    EspBox          = false,
    EspBox3D        = false,
    EspHealth       = false,
    EspName         = false,
    EspDistance     = false,
    EspSkeleton     = false,
    EspFov          = false,
    -- Fly
    Fly             = false,
    AutoFlyStep     = 0,
    HitFly          = false,
    SpeedFly        = 5,
    HighHitFly      = 50,
    SpeedHitFly     = 75,
    -- Tele
    TeleportPlayer  = false,
    TeleKill        = false,
    SelectedTarget  = nil,
    -- Misc
    SpeedHack       = false,
    JumpHack        = false,
    GhostHack       = false,
    -- Internal
    TeamCheck       = true,
}

-- ═══════════════════════════════════
-- THEME  (P2077KNG palette)
-- ═══════════════════════════════════
local RED       = Color3.fromRGB(210, 30, 30)
local RED2      = Color3.fromRGB(160, 20, 20)
local BG_MAIN   = Color3.fromRGB(10, 10, 10)
local BG_SIDE   = Color3.fromRGB(18, 18, 18)
local BG_ROW    = Color3.fromRGB(24, 24, 24)
local BG_ROW2   = Color3.fromRGB(30, 30, 30)
local BG_HDR    = Color3.fromRGB(14, 14, 14)
local COL_WHITE = Color3.fromRGB(240, 240, 240)
local COL_GRAY  = Color3.fromRGB(150, 150, 150)
local COL_DGRAY = Color3.fromRGB(60,  60,  60)
local COL_GREEN = Color3.fromRGB(40, 200, 70)

-- ═══════════════════════════════════
-- RESPONSIVE SCALE
-- ═══════════════════════════════════
local VP     = Cam.ViewportSize
-- Scale berdasarkan lebar layar agar pas di HP/iPad/PC
local BASE   = math.max(VP.X, VP.Y) -- landscape reference
local SCALE  = math.clamp(BASE / 1366, 0.72, 1.45)
local W      = math.floor(440 * SCALE)
local H      = math.floor(420 * SCALE)
local SIDE_W = math.floor(105 * SCALE)
local TITLE_H= math.floor(36  * SCALE)
local ROW_H  = math.floor(30  * SCALE)
local FS_L   = math.floor(13  * SCALE)
local FS_M   = math.floor(12  * SCALE)
local FS_S   = math.floor(10  * SCALE)
local PAD    = math.floor(6   * SCALE)
local PILL_W = math.floor(38  * SCALE)
local PILL_H = math.floor(20  * SCALE)
local DOT_S  = math.floor(14  * SCALE)

-- ═══════════════════════════════════
-- BASE HELPERS
-- ═══════════════════════════════════
local function Rnd(p, r)
    local o = Instance.new("UICorner")
    o.CornerRadius = UDim.new(0, r or 5)
    o.Parent = p
end

local function Str(p, c, t)
    local o = Instance.new("UIStroke")
    o.Color = c or COL_DGRAY
    o.Thickness = t or 1
    o.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    o.Parent = p
end

local function F(par, size, pos, bg, alpha)
    local f = Instance.new("Frame")
    f.Size              = size or UDim2.new(1,0,0,ROW_H)
    f.Position          = pos  or UDim2.new(0,0,0,0)
    f.BackgroundColor3  = bg   or BG_ROW
    f.BackgroundTransparency = alpha or 0
    f.BorderSizePixel   = 0
    f.ClipsDescendants  = false
    f.Parent = par
    return f
end

local function L(par, txt, fs, col, bold, xa)
    local l = Instance.new("TextLabel")
    l.Size              = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text              = txt   or ""
    l.TextSize          = fs    or FS_M
    l.TextColor3        = col   or COL_WHITE
    l.Font              = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment    = xa    or Enum.TextXAlignment.Left
    l.TextTruncate      = Enum.TextTruncate.AtEnd
    l.Parent = par
    return l
end

local function B(par, txt, size, pos, bg)
    local b = Instance.new("TextButton")
    b.Size              = size or UDim2.new(1,0,0,ROW_H)
    b.Position          = pos  or UDim2.new(0,0,0,0)
    b.BackgroundColor3  = bg   or BG_ROW2
    b.BorderSizePixel   = 0
    b.Text              = txt  or ""
    b.TextColor3        = COL_WHITE
    b.TextSize          = FS_M
    b.Font              = Enum.Font.GothamBold
    b.AutoButtonColor   = false
    b.Parent = par
    return b
end

-- ═══════════════════════════════════
-- DRAG HELPER
-- ═══════════════════════════════════
local function MakeDraggable(handle, target)
    local on, ds, dp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            on = true
            ds = i.Position
            dp = target.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if on and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            target.Position = UDim2.new(
                dp.X.Scale, dp.X.Offset + d.X,
                dp.Y.Scale, dp.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            on = false
        end
    end)
end

-- ═══════════════════════════════════
-- TOGGLE SYNC
-- ═══════════════════════════════════
local TCB = {}
local function FireCB(key, val)
    if TCB[key] then
        for _, fn in ipairs(TCB[key]) do
            pcall(fn, val)
        end
    end
end
local function RegCB(key, fn)
    TCB[key] = TCB[key] or {}
    table.insert(TCB[key], fn)
end

-- ═══════════════════════════════════
-- FLOATING ICON
-- ═══════════════════════════════════
local iconSG = Instance.new("ScreenGui")
iconSG.Name = "SantaXIcon"
iconSG.ResetOnSpawn = false
iconSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
iconSG.Parent = PGui

local ICON_SIZE = math.floor(64 * SCALE)
local iconImg = Instance.new("ImageButton")
iconImg.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
iconImg.Position = UDim2.new(0, 16, 0.5, -ICON_SIZE/2)
iconImg.BackgroundTransparency = 1
iconImg.Image = "rbxassetid://104012475483632"
iconImg.ImageColor3 = COL_WHITE
iconImg.Visible = false
iconImg.ZIndex = 10
iconImg.Parent = iconSG
Rnd(iconImg, ICON_SIZE)
MakeDraggable(iconImg, iconImg)

-- ═══════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════
local mainSG = Instance.new("ScreenGui")
mainSG.Name = "SantaXMain"
mainSG.ResetOnSpawn = false
mainSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainSG.Parent = PGui

local win = F(mainSG,
    UDim2.new(0, W, 0, H + TITLE_H),
    UDim2.new(0.5, -W/2, 0.5, -(H+TITLE_H)/2),
    BG_MAIN)
Rnd(win, 7)
Str(win, RED, 1.5)

-- ── TITLE BAR ───────────────────────────────────────────────
local tBar = F(win, UDim2.new(1,0,0,TITLE_H), UDim2.new(0,0,0,0), BG_HDR)
Rnd(tBar, 7)
Str(tBar, RED, 1)

-- Red top accent line
local accentLine = F(tBar, UDim2.new(1,0,0, math.floor(3*SCALE)), UDim2.new(0,0,0,0), RED)

-- Arrow toggle
local arrowBtn = B(tBar, "▼",
    UDim2.new(0, math.floor(28*SCALE), 1, -math.floor(6*SCALE)),
    UDim2.new(0, math.floor(8*SCALE), 0, math.floor(3*SCALE)), BG_HDR)
arrowBtn.TextColor3 = RED
arrowBtn.TextSize = FS_L
arrowBtn.ZIndex = 6

-- Title  + version TOGETHER (no gap)
local titleL = Instance.new("TextLabel")
titleL.Size = UDim2.new(1, -math.floor(90*SCALE), 1, 0)
titleL.Position = UDim2.new(0, math.floor(40*SCALE), 0, 0)
titleL.BackgroundTransparency = 1
titleL.Text = "SantaXModsKng  v1.12"
titleL.TextSize = FS_L
titleL.TextColor3 = COL_WHITE
titleL.Font = Enum.Font.GothamBold
titleL.TextXAlignment = Enum.TextXAlignment.Left
titleL.TextTruncate = Enum.TextTruncate.AtEnd
titleL.Parent = tBar

-- Close button  (text X, no box background visible)
local closeBtn = B(tBar, "✕",
    UDim2.new(0, math.floor(32*SCALE), 0, math.floor(26*SCALE)),
    UDim2.new(1, -math.floor(38*SCALE), 0.5, -math.floor(13*SCALE)),
    BG_HDR)
closeBtn.TextColor3 = COL_WHITE
closeBtn.TextSize = FS_M
closeBtn.ZIndex = 7
Rnd(closeBtn, 4)

-- Drag by title bar (not overlapping arrow or close)
MakeDraggable(tBar, win)

-- ── BODY ────────────────────────────────────────────────────
local body = F(win, UDim2.new(1,0,1,-TITLE_H), UDim2.new(0,0,0,TITLE_H), BG_MAIN)

-- Sidebar
local sidebar = F(body, UDim2.new(0, SIDE_W, 1, 0), UDim2.new(0,0,0,0), BG_SIDE)
Str(sidebar, COL_DGRAY, 1)

-- Content area
local CONT_W = W - SIDE_W - 2
local contArea = F(body, UDim2.new(0, CONT_W, 1, -2), UDim2.new(0, SIDE_W+2, 0, 1), BG_MAIN)

-- ── COLLAPSE ────────────────────────────────────────────────
local collapsed = false
local function setCollapse(v)
    collapsed = v
    body.Visible = not v
    arrowBtn.Text = v and "▶" or "▼"
    win.Size = v
        and UDim2.new(0, W, 0, TITLE_H)
        or  UDim2.new(0, W, 0, H + TITLE_H)
end

arrowBtn.MouseButton1Click:Connect(function()
    setCollapse(not collapsed)
end)

-- ── CLOSE / ICON ────────────────────────────────────────────
closeBtn.MouseButton1Click:Connect(function()
    win.Visible = false
    iconImg.Visible = true
end)
iconImg.MouseButton1Click:Connect(function()
    iconImg.Visible = false
    win.Visible = true
end)

-- ═══════════════════════════════════
-- SCROLL PAGE FACTORY
-- ═══════════════════════════════════
local function MkPage()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = math.floor(4*SCALE)
    sf.ScrollBarImageColor3 = RED
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    sf.Parent = contArea
    local ul = Instance.new("UIListLayout")
    ul.SortOrder = Enum.SortOrder.LayoutOrder
    ul.Padding = UDim.new(0, math.floor(3*SCALE))
    ul.Parent = sf
    local up = Instance.new("UIPadding")
    up.PaddingLeft   = UDim.new(0, PAD)
    up.PaddingRight  = UDim.new(0, PAD)
    up.PaddingTop    = UDim.new(0, PAD)
    up.PaddingBottom = UDim.new(0, PAD)
    up.Parent = sf
    return sf
end

-- ═══════════════════════════════════
-- SECTION HEADER
-- ═══════════════════════════════════
local function SecHdr(page, txt, order)
    local h = F(page, UDim2.new(1,0,0, math.floor(26*SCALE)), nil, BG_HDR)
    Rnd(h, 4)
    h.LayoutOrder = order
    -- left red bar
    local bar = F(h, UDim2.new(0, math.floor(3*SCALE), 0.7, 0), UDim2.new(0,0,0.15,0), RED)
    local lbl = L(h, "   "..txt, FS_S, RED, true)
    lbl.Position = UDim2.new(0, math.floor(6*SCALE), 0, 0)
    lbl.Size = UDim2.new(1, -math.floor(10*SCALE), 1, 0)
    return h
end

-- ═══════════════════════════════════
-- PILL TOGGLE
-- ═══════════════════════════════════
local function MkToggle(page, labelTxt, key, order)
    local row = F(page, UDim2.new(1,0,0,ROW_H), nil, BG_ROW)
    Rnd(row, 4)
    row.LayoutOrder = order

    -- hover
    row.MouseEnter:Connect(function() row.BackgroundColor3 = BG_ROW2 end)
    row.MouseLeave:Connect(function() row.BackgroundColor3 = BG_ROW end)

    -- label  (pure white, Gotham)
    local lbl = L(row, "  "..labelTxt, FS_M, COL_WHITE, false)
    lbl.Size = UDim2.new(1, -(PILL_W + 16), 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)

    -- pill bg
    local pillBg = F(row,
        UDim2.new(0, PILL_W, 0, PILL_H),
        UDim2.new(1, -(PILL_W + 8), 0.5, -PILL_H/2),
        S[key] and RED or COL_DGRAY)
    Rnd(pillBg, PILL_H)

    -- dot
    local dot = F(pillBg,
        UDim2.new(0, DOT_S, 0, DOT_S),
        UDim2.new(0, 3, 0.5, -DOT_S/2),
        COL_WHITE)
    Rnd(dot, DOT_S)

    local function Refresh(val)
        TweenSvc:Create(pillBg, TweenInfo.new(0.12), {
            BackgroundColor3 = val and RED or COL_DGRAY
        }):Play()
        TweenSvc:Create(dot, TweenInfo.new(0.12), {
            Position = val
                and UDim2.new(1, -(DOT_S+3), 0.5, -DOT_S/2)
                or  UDim2.new(0, 3, 0.5, -DOT_S/2)
        }):Play()
    end

    -- FULL ROW CLICK ZONE  (Z=10 so it's on top of everything)
    local hit = B(row, "", UDim2.new(1,0,1,0))
    hit.BackgroundTransparency = 1
    hit.ZIndex = 10
    hit.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        Refresh(S[key])
        FireCB(key, S[key])
    end)

    RegCB(key, Refresh)
    return row, Refresh
end

-- ═══════════════════════════════════
-- SLIDER
-- ═══════════════════════════════════
local function MkSlider(page, labelTxt, key, mn, mx, order)
    local RH = math.floor(50 * SCALE)
    local row = F(page, UDim2.new(1,0,0,RH), nil, BG_ROW)
    Rnd(row, 4)
    row.LayoutOrder = order

    local lbl = L(row, "  "..labelTxt, FS_S, COL_WHITE, false)
    lbl.Size = UDim2.new(0.65, 0, 0, math.floor(20*SCALE))
    lbl.Position = UDim2.new(0, 0, 0, math.floor(4*SCALE))

    local valL = L(row, tostring(S[key]), FS_S, RED, true, Enum.TextXAlignment.Right)
    valL.Size = UDim2.new(0.32, 0, 0, math.floor(20*SCALE))
    valL.Position = UDim2.new(0.67, -PAD, 0, math.floor(4*SCALE))

    local TH = math.floor(5*SCALE)
    local trkBg = F(row,
        UDim2.new(1, -PAD*2, 0, TH),
        UDim2.new(0, PAD, 0, RH - math.floor(14*SCALE)),
        BG_HDR)
    Rnd(trkBg, TH)

    local pct = (S[key]-mn)/(mx-mn)
    local fill = F(trkBg, UDim2.new(pct, 0, 1, 0), nil, RED)
    Rnd(fill, TH)

    local DTH = math.floor(14*SCALE)
    local thumb = F(trkBg,
        UDim2.new(0, DTH, 0, DTH),
        UDim2.new(pct, -DTH/2, 0.5, -DTH/2),
        COL_WHITE)
    Rnd(thumb, DTH)

    local sliding = false

    -- Klik pada track langsung
    local hitZ = B(row, "",
        UDim2.new(1, -PAD*2, 1, -math.floor(8*SCALE)),
        UDim2.new(0, PAD, 0, math.floor(8*SCALE)))
    hitZ.BackgroundTransparency = 1
    hitZ.ZIndex = 10

    local function updateSlider(inputPos)
        local relX = (inputPos.X - trkBg.AbsolutePosition.X) / trkBg.AbsoluteSize.X
        relX = math.clamp(relX, 0, 1)
        local nv = math.floor(mn + relX * (mx - mn))
        S[key] = nv
        fill.Size      = UDim2.new(relX, 0, 1, 0)
        thumb.Position = UDim2.new(relX, -DTH/2, 0.5, -DTH/2)
        valL.Text = tostring(nv)
    end

    hitZ.MouseButton1Down:Connect(function()
        sliding = true
        updateSlider(UIS:GetMouseLocation())
    end)
    trkBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateSlider(i.Position)
        end
    end)
    thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if not sliding or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        updateSlider(i.Position)
    end)
end

-- ═══════════════════════════════════
-- LOGO ROW  (separate, opens float UI)
-- ═══════════════════════════════════
local floatGuis = {}

local function MkFloat(featName, key)
    if floatGuis[key] then
        floatGuis[key]:Destroy()
        floatGuis[key] = nil
        return
    end
    local fg = Instance.new("ScreenGui")
    fg.Name = "Float_"..key
    fg.ResetOnSpawn = false
    fg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    fg.Parent = PGui
    floatGuis[key] = fg

    local FW = math.floor(185*SCALE)
    local FH = math.floor(70*SCALE)
    local fw = F(fg, UDim2.new(0,FW,0,FH), UDim2.new(0,90,0.42,0), BG_MAIN)
    Rnd(fw, 6)
    Str(fw, COL_DGRAY, 1)

    -- grey header
    local fhdr = F(fw, UDim2.new(1,0,0, math.floor(28*SCALE)), nil, COL_DGRAY)
    Rnd(fhdr, 5)
    local fhl = L(fhdr, "  "..featName, FS_S, COL_WHITE, true, Enum.TextXAlignment.Center)
    fhl.Size = UDim2.new(1,0,1,0)
    MakeDraggable(fhdr, fw)

    -- black toggle row
    local frow = F(fw, UDim2.new(1,0,0, math.floor(38*SCALE)),
        UDim2.new(0,0,0, math.floor(28*SCALE)), BG_MAIN)

    local fl = L(frow, "  "..featName, FS_S, COL_WHITE, false)
    fl.Size = UDim2.new(1, -(PILL_W+12), 1, 0)

    local fpb = F(frow,
        UDim2.new(0, PILL_W, 0, PILL_H),
        UDim2.new(1, -(PILL_W+8), 0.5, -PILL_H/2),
        S[key] and RED or COL_DGRAY)
    Rnd(fpb, PILL_H)
    local fpd = F(fpb, UDim2.new(0,DOT_S,0,DOT_S), UDim2.new(0,3,0.5,-DOT_S/2), COL_WHITE)
    Rnd(fpd, DOT_S)

    local function Fsync(val)
        TweenSvc:Create(fpb,TweenInfo.new(0.12),{BackgroundColor3=val and RED or COL_DGRAY}):Play()
        TweenSvc:Create(fpd,TweenInfo.new(0.12),{
            Position=val and UDim2.new(1,-(DOT_S+3),0.5,-DOT_S/2) or UDim2.new(0,3,0.5,-DOT_S/2)
        }):Play()
    end
    Fsync(S[key])
    RegCB(key, Fsync)

    local fhit = B(frow,"",UDim2.new(1,0,1,0))
    fhit.BackgroundTransparency=1 fhit.ZIndex=11
    fhit.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        Fsync(S[key])
        FireCB(key, S[key])
    end)
end

local function MkLogoRow(page, featName, key, order)
    local row = F(page, UDim2.new(1,0,0,ROW_H), nil, BG_SIDE)
    Rnd(row, 4)
    row.LayoutOrder = order
    local lbl = L(row, "  "..featName.." Logo", FS_S, COL_GRAY, false)
    lbl.Size = UDim2.new(1,-50,1,0)
    local lb = B(row, "⊞",
        UDim2.new(0,math.floor(38*SCALE),0,math.floor(24*SCALE)),
        UDim2.new(1,-44,0.5,-12), BG_ROW2)
    Rnd(lb,4) Str(lb,COL_DGRAY,1)
    lb.TextColor3=RED lb.TextSize=math.floor(16*SCALE) lb.ZIndex=10
    lb.MouseButton1Click:Connect(function() MkFloat(featName, key) end)
end

-- ═══════════════════════════════════
-- DROPDOWN (Select Target)
-- ═══════════════════════════════════
local ddFrame = nil
local function MkDropdown(page, order)
    local row = F(page, UDim2.new(1,0,0,ROW_H), nil, BG_ROW)
    Rnd(row,4) row.LayoutOrder=order
    local lbl = L(row, "  Select Target", FS_S, COL_WHITE, false)
    lbl.Size = UDim2.new(0.5,0,1,0)
    local DDW = math.floor(115*SCALE)
    local ddB = B(row, S.SelectedTarget or "None  ▾",
        UDim2.new(0,DDW,0,math.floor(24*SCALE)),
        UDim2.new(1,-DDW-6,0.5,-12), BG_ROW2)
    Rnd(ddB,4) Str(ddB,COL_DGRAY,1)
    ddB.TextColor3=COL_GRAY ddB.TextSize=FS_S ddB.ZIndex=10

    ddB.MouseButton1Click:Connect(function()
        if ddFrame then ddFrame:Destroy() ddFrame=nil return end
        ddFrame = F(mainSG, UDim2.new(0,DDW+10,0,0), nil, BG_SIDE)
        Rnd(ddFrame,4) Str(ddFrame,COL_DGRAY,1)
        ddFrame.AutomaticSize=Enum.AutomaticSize.Y ddFrame.ZIndex=20
        local ap=ddB.AbsolutePosition
        ddFrame.Position=UDim2.new(0,ap.X,0,ap.Y+math.floor(28*SCALE))
        local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder ul.Parent=ddFrame
        local ct=0
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end ct=ct+1
            local ib=B(ddFrame,"  "..p.Name,UDim2.new(1,0,0,math.floor(28*SCALE)))
            ib.TextXAlignment=Enum.TextXAlignment.Left ib.TextSize=FS_S ib.LayoutOrder=ct ib.ZIndex=21
            ib.MouseButton1Click:Connect(function()
                S.SelectedTarget=p.Name ddB.Text=p.Name.."  ▾" ddB.TextColor3=RED
                ddFrame:Destroy() ddFrame=nil end)
        end
        if ct==0 then
            local n=L(ddFrame,"  No players",FS_S,COL_GRAY)
            n.Size=UDim2.new(1,0,0,math.floor(28*SCALE)) end
    end)
end

-- ═══════════════════════════════════
-- AUTO FLY UI
-- ═══════════════════════════════════
local afGui=nil local afBV=nil
local function MkAutoFlyUI()
    if afGui then
        afGui:Destroy() afGui=nil S.AutoFlyStep=0
        if afBV then afBV:Destroy() afBV=nil end
        local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand=false end
        return
    end
    afGui=Instance.new("ScreenGui") afGui.Name="AutoFlyUI" afGui.ResetOnSpawn=false afGui.Parent=PGui
    local afw=F(afGui,UDim2.new(0,math.floor(200*SCALE),0,math.floor(92*SCALE)),UDim2.new(0,90,0.65,0),BG_MAIN)
    Rnd(afw,6) Str(afw,RED,1)
    local ahdr=F(afw,UDim2.new(1,0,0,math.floor(28*SCALE)),nil,COL_DGRAY) Rnd(ahdr,5)
    local ahl=L(ahdr,"  Auto Fly",FS_S,COL_WHITE,true,Enum.TextXAlignment.Center) ahl.Size=UDim2.new(1,0,1,0)
    MakeDraggable(ahdr,afw)
    local stepL=L(afw,"Ready",FS_S,COL_GRAY,false,Enum.TextXAlignment.Center)
    stepL.Size=UDim2.new(1,0,0,math.floor(20*SCALE)) stepL.Position=UDim2.new(0,0,0,math.floor(30*SCALE))
    local cb=B(afw,"Click 1 — Set Position",UDim2.new(1,-12,0,math.floor(26*SCALE)),UDim2.new(0,6,0,math.floor(58*SCALE)),RED)
    Rnd(cb,4) cb.TextSize=FS_S
    local steps={[0]={b="Click 1 — Set Position",l="Ready"},[1]={b="Click 2 — Start Flying",l="Step 1: Set"},[2]={b="Click 3 — Lock Position",l="Step 2: Flying..."},[3]={b="Locked ✓",l="Step 3: Locked"}}
    local function upd() local d=steps[S.AutoFlyStep] if d then cb.Text=d.b stepL.Text=d.l end end
    cb.MouseButton1Click:Connect(function()
        local char=LP.Character local root=char and char:FindFirstChild("HumanoidRootPart")
        if not char or not root then return end
        if S.AutoFlyStep==0 then
            S.AutoFlyStep=1
            local h2=char:FindFirstChildOfClass("Humanoid") if h2 then h2.PlatformStand=true end
            root.CFrame=root.CFrame+Vector3.new(0,1.2,0)
        elseif S.AutoFlyStep==1 then
            S.AutoFlyStep=2
            if afBV then afBV:Destroy() end
            afBV=Instance.new("BodyVelocity") afBV.Velocity=Vector3.new(0,S.SpeedFly*7,0)
            afBV.MaxForce=Vector3.new(0,1e6,0) afBV.Parent=root
        elseif S.AutoFlyStep==2 then
            S.AutoFlyStep=3
            if afBV then afBV:Destroy() afBV=nil end
            local bp=Instance.new("BodyPosition") bp.Position=root.Position
            bp.MaxForce=Vector3.new(1e6,1e6,1e6) bp.D=600 bp.P=12000 bp.Parent=root afBV=bp
        end
        upd()
    end)
end

-- ═══════════════════════════════════
-- BUILD SIDEBAR TABS + PAGES
-- ═══════════════════════════════════
local tabUL=Instance.new("UIListLayout") tabUL.SortOrder=Enum.SortOrder.LayoutOrder
tabUL.Padding=UDim.new(0,2) tabUL.Parent=sidebar
local tabPad=Instance.new("UIPadding")
tabPad.PaddingTop=UDim.new(0,6) tabPad.PaddingLeft=UDim.new(0,4)
tabPad.PaddingRight=UDim.new(0,4) tabPad.Parent=sidebar

local pages={} local tabBtns={} local activeTab=""
local function switchTab(name)
    activeTab=name
    for n,pg in pairs(pages) do pg.Visible=(n==name) end
    for n,tb in pairs(tabBtns) do
        tb.BackgroundColor3 = n==name and RED or BG_ROW2
        tb.TextColor3       = n==name and COL_WHITE or COL_GRAY
    end
end

for i,tname in ipairs({"Function","Aim","Esp","Fly/Tele","Misc"}) do
    local pg=MkPage() pages[tname]=pg
    local TAB_H=math.floor(36*SCALE)
    local tb=B(sidebar, tname, UDim2.new(1,0,0,TAB_H), nil, BG_ROW2)
    Rnd(tb,4) tb.TextSize=FS_S tb.TextColor3=COL_GRAY tb.LayoutOrder=i
    tabBtns[tname]=tb
    tb.MouseButton1Click:Connect(function() switchTab(tname) end)
end

-- ═══════════════════════════════════
-- PAGE: FUNCTION
-- ═══════════════════════════════════
local pFn = pages["Function"]
SecHdr(pFn,"Function",1)
MkToggle(pFn,"Enable Function","EnableFunction",2)
MkToggle(pFn,"Enable Aim",     "EnableAim",     3)
MkToggle(pFn,"Enable Esp",     "EnableEsp",     4)

local div0=F(pFn,UDim2.new(1,0,0,1),nil,COL_DGRAY) div0.LayoutOrder=5

-- Info box
local infoBox=F(pFn,UDim2.new(1,0,0,math.floor(108*SCALE)),nil,BG_ROW)
Rnd(infoBox,5) infoBox.LayoutOrder=6
local ipad=Instance.new("UIPadding") ipad.PaddingLeft=UDim.new(0,8) ipad.PaddingTop=UDim.new(0,6) ipad.Parent=infoBox
local function irow(txt,yoff,col,bold)
    local il=L(infoBox,txt,FS_S,col or COL_GRAY,bold or false)
    il.Size=UDim2.new(1,-8,0,math.floor(15*SCALE))
    il.Position=UDim2.new(0,0,0,math.floor(yoff*SCALE))
    return il
end
irow("Release Version Official.  | Details",2,RED,true)
irow("SantaXMods has been released with the official version.",20)
irow("Developer: SkyFlow",46)
irow("Youtube: @Skyflowh4x   Tiktok: @Sky.flow77",61)
irow("Version: 1.12",76)

-- ═══════════════════════════════════
-- PAGE: AIM
-- ═══════════════════════════════════
local pA=pages["Aim"]
SecHdr(pA,"Aim Function",1)
MkToggle(pA,"Aimbot",     "Aimbot",     2)
MkToggle(pA,"Aim Assist", "AimAssist",  3)
MkToggle(pA,"Aim Silent", "AimSilent",  4)
MkLogoRow(pA,"Aim Silent","AimSilent",  5)
MkToggle(pA,"Aim Magnet", "AimMagnet",  6)
MkLogoRow(pA,"Aim Magnet","AimMagnet",  7)
MkToggle(pA,"AutoKill",   "AutoKill",   8)
MkLogoRow(pA,"AutoKill",  "AutoKill",   9)
MkToggle(pA,"Aim Visible","AimVisible", 10)
MkSlider(pA,"Aim FOV","AimFov",0,360,11)

-- ═══════════════════════════════════
-- PAGE: ESP
-- ═══════════════════════════════════
local pE=pages["Esp"]
SecHdr(pE,"Esp Function",1)
MkToggle(pE,"Esp Line",     "EspLine",     2)
MkToggle(pE,"Esp Box",      "EspBox",      3)
MkToggle(pE,"Esp Box 3D",   "EspBox3D",    4)
MkToggle(pE,"Esp Health",   "EspHealth",   5)
MkToggle(pE,"Esp Name",     "EspName",     6)
MkToggle(pE,"Esp Distance", "EspDistance", 7)
MkToggle(pE,"Esp Skeleton", "EspSkeleton", 8)
MkToggle(pE,"Esp Fov",      "EspFov",      9)

-- ═══════════════════════════════════
-- PAGE: FLY/TELE
-- ═══════════════════════════════════
local pFT=pages["Fly/Tele"]
SecHdr(pFT,"Fly Function",1)
MkToggle(pFT,"Fly",     "Fly",     2)

-- Auto Fly row (no toggle, logo only)
local afRow=F(pFT,UDim2.new(1,0,0,ROW_H),nil,BG_SIDE) Rnd(afRow,4) afRow.LayoutOrder=3
local afL=L(afRow,"  Auto Fly",FS_M,COL_WHITE,false) afL.Size=UDim2.new(1,-50,1,0)
local afLB=B(afRow,"⊞",UDim2.new(0,math.floor(38*SCALE),0,math.floor(24*SCALE)),UDim2.new(1,-44,0.5,-12),BG_ROW2)
Rnd(afLB,4) Str(afLB,COL_DGRAY,1) afLB.TextColor3=RED afLB.TextSize=math.floor(16*SCALE) afLB.ZIndex=10
afLB.MouseButton1Click:Connect(MkAutoFlyUI)

MkToggle(pFT,"Hit Fly","HitFly",4)
MkSlider(pFT,"Speed Fly","SpeedFly",1,10,5)
MkSlider(pFT,"High Hit Fly (m)","HighHitFly",0,100,6)
MkSlider(pFT,"Speed Hit Fly (m)","SpeedHitFly",0,150,7)
local dv1=F(pFT,UDim2.new(1,0,0,1),nil,COL_DGRAY) dv1.LayoutOrder=8
SecHdr(pFT,"Teleport Function",9)
MkToggle(pFT,"Teleport Player","TeleportPlayer",10)
MkToggle(pFT,"TeleKill","TeleKill",11)
MkLogoRow(pFT,"TeleKill","TeleKill",12)
MkDropdown(pFT,13)

-- ═══════════════════════════════════
-- PAGE: MISC
-- ═══════════════════════════════════
local pM=pages["Misc"]
SecHdr(pM,"Misc Function",1)
MkToggle(pM,"SpeedHack", "SpeedHack", 2)
MkToggle(pM,"JumpHack",  "JumpHack",  3)
MkToggle(pM,"GhostHack", "GhostHack", 4)

switchTab("Function")

-- ═══════════════════════════════════
-- ESP ENGINE
-- ═══════════════════════════════════
local espSG=Instance.new("ScreenGui")
espSG.Name="SantaXEsp" espSG.ResetOnSpawn=false
espSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling espSG.Parent=PGui

local eObj={}
local function clrEsp(p)
    if not eObj[p] then return end
    for _,o in pairs(eObj[p]) do
        if type(o)=="table" then for _,oo in pairs(o) do if oo and oo.Parent then oo:Destroy() end end
        elseif o and o.Parent then o:Destroy() end
    end
    eObj[p]=nil
end

local function Line2D(x0,y0,x1,y1,col,thick)
    local dx=x1-x0 local dy=y1-y0
    local len=math.sqrt(dx*dx+dy*dy)
    local ang=math.deg(math.atan2(dy,dx))
    local f=Instance.new("Frame")
    f.BackgroundColor3=col or COL_WHITE f.BorderSizePixel=0
    f.Size=UDim2.new(0,len,0,thick or 1)
    f.Position=UDim2.new(0,x0,0,y0)
    f.Rotation=ang f.AnchorPoint=Vector2.new(0,0.5)
    f.Parent=espSG return f
end

local function drawEsp(player)
    if not player.Character then clrEsp(player) return end
    local c = player.Character
    local root = c:FindFirstChild("HumanoidRootPart")
    local head = c:FindFirstChild("Head")
    local hum  = c:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then clrEsp(player) return end

    -- Project head top & feet to screen
    local headTop = head and (head.Position + Vector3.new(0, head.Size.Y/2 + 0.15, 0)) or (root.Position + Vector3.new(0, 2.8, 0))
    local feetBot = root.Position - Vector3.new(0, 3.0, 0)

    local htSP, htVis = Cam:WorldToViewportPoint(headTop)
    local ftSP, ftVis = Cam:WorldToViewportPoint(feetBot)
    local rootSP, rootVis = Cam:WorldToViewportPoint(root.Position)

    if not rootVis then clrEsp(player) return end

    eObj[player] = eObj[player] or {}
    local o = eObj[player]

    local top  = math.min(htSP.Y, ftSP.Y)
    local bot  = math.max(htSP.Y, ftSP.Y)
    local boxH = math.max(bot - top, 10)
    local boxW = boxH * 0.5
    local cx   = rootSP.X

    local mr   = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local dist = mr and math.floor((mr.Position - root.Position).Magnitude) or 0

    -- ── ESP BOX ──────────────────────────────────────────────
    if S.EspBox then
        if not o.box then
            o.box = Instance.new("Frame")
            o.box.BackgroundTransparency = 1
            o.box.BorderSizePixel = 2
            o.box.BorderColor3 = COL_WHITE
            o.box.ZIndex = 2
            o.box.Parent = espSG
        end
        o.box.Position = UDim2.new(0, cx - boxW/2, 0, top)
        o.box.Size     = UDim2.new(0, boxW, 0, boxH)
    elseif o.box then o.box:Destroy() o.box = nil end

    -- ── ESP BOX 3D ───────────────────────────────────────────
    if S.EspBox3D then
        -- destroy old lines
        if o.box3d then
            for _, l in ipairs(o.box3d) do if l and l.Parent then l:Destroy() end end
        end
        o.box3d = {}
        -- 8 corners based on character bounding box
        local hw = 1.0   -- half width
        local ht = 3.0   -- half height
        local corners = {
            root.Position + Vector3.new(-hw,  ht, -hw),
            root.Position + Vector3.new( hw,  ht, -hw),
            root.Position + Vector3.new( hw,  ht,  hw),
            root.Position + Vector3.new(-hw,  ht,  hw),
            root.Position + Vector3.new(-hw, -ht, -hw),
            root.Position + Vector3.new( hw, -ht, -hw),
            root.Position + Vector3.new( hw, -ht,  hw),
            root.Position + Vector3.new(-hw, -ht,  hw),
        }
        local sc = {}
        local allVis = true
        for i, v3 in ipairs(corners) do
            local sv, vis2 = Cam:WorldToViewportPoint(v3)
            sc[i] = {sv.X, sv.Y}
            if not vis2 then allVis = false end
        end
        if allVis then
            local edges = {
                {1,2},{2,3},{3,4},{4,1},
                {5,6},{6,7},{7,8},{8,5},
                {1,5},{2,6},{3,7},{4,8}
            }
            for _, e in ipairs(edges) do
                local ln = Line2D(sc[e[1]][1],sc[e[1]][2],sc[e[2]][1],sc[e[2]][2],COL_WHITE,1)
                ln.ZIndex = 2
                table.insert(o.box3d, ln)
            end
        end
    elseif o.box3d then
        for _, l in ipairs(o.box3d) do if l and l.Parent then l:Destroy() end end
        o.box3d = nil
    end

    -- ── ESP NAME ─────────────────────────────────────────────
    if S.EspName then
        if not o.name then
            o.name = Instance.new("TextLabel")
            o.name.BackgroundTransparency = 1
            o.name.TextColor3 = RED
            o.name.TextSize   = math.floor(12*SCALE)
            o.name.Font       = Enum.Font.GothamBold
            o.name.ZIndex     = 3
            o.name.Parent     = espSG
        end
        o.name.Text     = player.Name
        o.name.Size     = UDim2.new(0, 120, 0, 16)
        o.name.Position = UDim2.new(0, cx-60, 0, top-17)
    elseif o.name then o.name:Destroy() o.name = nil end

    -- ── ESP DISTANCE ──────────────────────────────────────────
    if S.EspDistance then
        if not o.dist then
            o.dist = Instance.new("TextLabel")
            o.dist.BackgroundTransparency = 1
            o.dist.TextColor3 = RED
            o.dist.TextSize   = math.floor(11*SCALE)
            o.dist.Font       = Enum.Font.Gotham
            o.dist.ZIndex     = 3
            o.dist.Parent     = espSG
        end
        o.dist.Text     = dist.."m"
        o.dist.Size     = UDim2.new(0, 60, 0, 14)
        o.dist.Position = UDim2.new(0, cx-30, 0, bot+3)
    elseif o.dist then o.dist:Destroy() o.dist = nil end

    -- ── ESP HEALTH ────────────────────────────────────────────
    if S.EspHealth then
        if not o.hbg then
            o.hbg = Instance.new("Frame")
            o.hbg.BackgroundColor3 = Color3.fromRGB(20,20,20)
            o.hbg.BorderSizePixel  = 0
            o.hbg.ZIndex = 2
            o.hbg.Parent = espSG
            o.hfill = Instance.new("Frame")
            o.hfill.BackgroundColor3 = COL_GREEN
            o.hfill.BorderSizePixel  = 0
            o.hfill.ZIndex = 3
            o.hfill.Parent = o.hbg
        end
        local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        o.hbg.Size     = UDim2.new(0, 4, 0, boxH)
        o.hbg.Position = UDim2.new(0, cx - boxW/2 - 7, 0, top)
        o.hfill.Size   = UDim2.new(1, 0, hp, 0)
        o.hfill.Position = UDim2.new(0, 0, 1-hp, 0)
    elseif o.hbg then o.hbg:Destroy() o.hbg = nil end

    -- ── ESP LINE (screen bottom-center → enemy feet) ──────────
    if S.EspLine then
        if o.line then o.line:Destroy() o.line = nil end
        local vp2 = Cam.ViewportSize
        -- garis dari bawah tengah layar ke posisi kaki musuh
        local sx0 = vp2.X / 2
        local sy0 = vp2.Y       -- bawah layar
        local sx1 = ftSP.X
        local sy1 = ftSP.Y
        o.line = Line2D(sx0, sy0, sx1, sy1, COL_WHITE, 1)
        if o.line then o.line.ZIndex = 2 end
    elseif o.line then o.line:Destroy() o.line = nil end

    -- ── ESP SKELETON ──────────────────────────────────────────
    if S.EspSkeleton then
        if o.skel then
            for _, l in ipairs(o.skel) do if l and l.Parent then l:Destroy() end end
        end
        o.skel = {}
        local bones = {
            {"Head","UpperTorso"},
            {"UpperTorso","LowerTorso"},
            {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
            {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"},  {"LeftLowerArm","LeftHand"},
            {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
            {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"},  {"LeftLowerLeg","LeftFoot"},
        }
        for _, bone in ipairs(bones) do
            local p0 = c:FindFirstChild(bone[1])
            local p1 = c:FindFirstChild(bone[2])
            if p0 and p1 then
                local s0, v0 = Cam:WorldToViewportPoint(p0.Position)
                local s1, v1 = Cam:WorldToViewportPoint(p1.Position)
                if v0 and v1 then
                    local ln = Line2D(s0.X, s0.Y, s1.X, s1.Y, RED, 1)
                    ln.ZIndex = 2
                    table.insert(o.skel, ln)
                end
            end
        end
    elseif o.skel then
        for _, l in ipairs(o.skel) do if l and l.Parent then l:Destroy() end end
        o.skel = nil
    end
end

-- FOV Circle
local fovCircle = Instance.new("Frame")
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 2
fovCircle.BorderColor3 = RED
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.ZIndex = 5
fovCircle.Visible = false
fovCircle.Parent = espSG
Rnd(fovCircle, 999)

-- ═══════════════════════════════════
-- AIM ENGINE
-- ═══════════════════════════════════
local function isAim() return S.EnableFunction and S.EnableAim end
local function isEsp()  return S.EnableFunction and S.EnableEsp  end

local function GetEnemy(fov, part)
    local best,bd=nil,fov
    local mouse=UIS:GetMouseLocation()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if S.TeamCheck and p.Team==LP.Team then continue end
        local c=p.Character if not c then continue end
        local t=c:FindFirstChild(part or "Head") or c:FindFirstChild("HumanoidRootPart")
        if not t then continue end
        local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
        if S.AimVisible then
            local ray=Ray.new(Cam.CFrame.Position,(t.Position-Cam.CFrame.Position).Unit*1000)
            local hit=workspace:FindPartOnRayWithIgnoreList(ray,{LP.Character,workspace.Terrain})
            if not(hit and hit:IsDescendantOf(c)) then continue end
        end
        local sp,vis=Cam:WorldToViewportPoint(t.Position)
        if not vis then continue end
        local d=(Vector2.new(sp.X,sp.Y)-mouse).Magnitude
        if d<bd then bd=d best=t end
    end
    return best
end

-- AimSilent
local silOrig=nil local silShot=false
UIS.InputBegan:Connect(function(i,gpe)
    if gpe or i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    if not isAim() or not S.AimSilent then return end
    local t=GetEnemy(S.AimFov,"Head") if not t then return end
    silOrig=Cam.CFrame silShot=true
    Cam.CFrame=CFrame.new(Cam.CFrame.Position,t.Position)
    task.defer(function()
        task.wait()
        if silOrig and silShot then Cam.CFrame=silOrig silOrig=nil silShot=false end
    end)
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 and silOrig then
        Cam.CFrame=silOrig silOrig=nil silShot=false end
end)

-- Fly engine
local flyBV=nil
local function enFly()
    local char=LP.Character local root=char and char:FindFirstChild("HumanoidRootPart") if not root then return end
    local h=char:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=true end
    if flyBV then flyBV:Destroy() end
    flyBV=Instance.new("BodyVelocity") flyBV.Velocity=Vector3.zero
    flyBV.MaxForce=Vector3.new(1e5,1e5,1e5) flyBV.Parent=root
end
local function disFly()
    local char=LP.Character local h=char and char:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand=false end
    if flyBV then flyBV:Destroy() flyBV=nil end
end

-- Ghost engine
local gSaved={}
local function applyGhost(char,on)
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if on then
                gSaved[p]=p.LocalTransparencyModifier
                p.LocalTransparencyModifier=p.Name=="HumanoidRootPart" and 0 or 1
            elseif gSaved[p]~=nil then
                p.LocalTransparencyModifier=gSaved[p]
            end
        end
    end
    if not on then gSaved={} end
end

-- TeleKill
local tkRun=false
local function doTK()
    if tkRun then return end tkRun=true
    task.spawn(function()
        while S.TeleKill and isAim() do
            local target
            if S.SelectedTarget then target=Players:FindFirstChild(S.SelectedTarget) end
            if not target then
                local bd,bt=9999,nil
                for _,p in ipairs(Players:GetPlayers()) do
                    if p==LP then continue end
                    local c=p.Character if not c then continue end
                    local r2=c:FindFirstChild("HumanoidRootPart") if not r2 then continue end
                    local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
                    local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not mr then continue end
                    local d=(mr.Position-r2.Position).Magnitude
                    if d<bd then bd=d bt=p end
                end
                target=bt
            end
            if target then
                local tc=target.Character
                local tr=tc and tc:FindFirstChild("HumanoidRootPart")
                local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if tr and mr then
                    mr.CFrame=tr.CFrame*CFrame.new(0,0,-1.5)
                    task.wait(0.05)
                    local hm=tc:FindFirstChildOfClass("Humanoid") if hm then hm.Health=0 end
                end
            end
            task.wait(0.55)
        end
        tkRun=false
    end)
end

-- Teleport Player (P key)
UIS.InputBegan:Connect(function(i,gpe)
    if gpe or i.KeyCode~=Enum.KeyCode.P then return end
    if not S.TeleportPlayer then return end
    local target=S.SelectedTarget and Players:FindFirstChild(S.SelectedTarget)
    if target then
        local tc=target.Character
        local tr=tc and tc:FindFirstChild("HumanoidRootPart")
        local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if tr and mr then mr.CFrame=tr.CFrame*CFrame.new(0,0,-2) end
    end
end)

-- ═══════════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════════
RunService.RenderStepped:Connect(function()
    local aim=isAim()
    local esp=isEsp()
    local char=LP.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local mouse=UIS:GetMouseLocation()

    -- AIM MAGNET (RMB)
    if aim and S.AimMagnet and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,"Head")
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.18) end
    end

    -- AIMBOT (RMB)
    if aim and S.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,"Head")
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.50) end
    end

    -- AIM ASSIST (RMB, softer)
    if aim and S.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,"HumanoidRootPart")
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.07) end
    end

    -- AUTOKILL (all enemies in FOV radius)
    if aim and S.AutoKill then
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character if not c then continue end
            local r2=c:FindFirstChild("HumanoidRootPart") if not r2 then continue end
            local sp2,vis2=Cam:WorldToViewportPoint(r2.Position) if not vis2 then continue end
            if (Vector2.new(sp2.X,sp2.Y)-mouse).Magnitude<=S.AimFov then
                local hm2=c:FindFirstChildOfClass("Humanoid") if hm2 then hm2.Health=0 end
            end
        end
    end

    -- TELEKILL
    if aim and S.TeleKill then doTK() end

    -- FLY
    if S.Fly then
        if not flyBV then enFly() end
        local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir=dir+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
        if flyBV then flyBV.Velocity=dir*(S.SpeedFly*10) end
    else
        if flyBV then disFly() end
    end

    -- MISC
    if hum then
        hum.WalkSpeed = S.SpeedHack and 95  or 16
        hum.JumpPower = S.JumpHack  and 135 or 50
    end

    -- GHOST
    if char then
        if S.GhostHack then applyGhost(char,true)
        elseif next(gSaved)~=nil then applyGhost(char,false) end
    end

    -- ESP
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if esp and (S.EspBox or S.EspBox3D or S.EspName or S.EspDistance or
                    S.EspHealth or S.EspLine or S.EspSkeleton) then
            drawEsp(p)
        else clrEsp(p) end
    end

    -- FOV CIRCLE  (ikut cursor, radius = AimFov pixel)
    if S.EspFov and isEsp() then
        local mpos = UIS:GetMouseLocation()
        local rad  = S.AimFov
        fovCircle.Visible  = true
        fovCircle.Size     = UDim2.new(0, rad*2, 0, rad*2)
        fovCircle.Position = UDim2.new(0, mpos.X, 0, mpos.Y)
    else
        fovCircle.Visible = false
    end
end)

Players.PlayerRemoving:Connect(clrEsp)
print("[ SantaXModsKng v1.12 ] OK — SkyFlow")
