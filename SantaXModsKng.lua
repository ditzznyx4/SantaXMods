--[[
╔══════════════════════════════════════════╗
║          SantaXModsKng.lua               ║
║  Developer  : SkyFlow                    ║
║  Youtube    : @Skyflowh4x               ║
║  Tiktok     : @Sky.flow77               ║
║  Version    : 1.12                       ║
╚══════════════════════════════════════════╝
]]

-- SERVICES
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenSvc     = game:GetService("TweenService")
local LP           = Players.LocalPlayer
local Cam          = workspace.CurrentCamera
local PGui         = LP:WaitForChild("PlayerGui")

-- CLEANUP OLD
for _, g in ipairs({"SantaXMain","SantaXEsp","SantaXFloat","SantaXIcon"}) do
    local old = PGui:FindFirstChild(g)
    if old then old:Destroy() end
end
for _, g in ipairs(PGui:GetChildren()) do
    if g.Name:sub(1,6) == "Float_" then g:Destroy() end
end

-- STATE
local S = {
    EnableFunction = false, EnableAim = false, EnableEsp = false,
    Aimbot=false, AimAssist=false, AimSilent=false, AimMagnet=false,
    AutoKill=false, AimVisible=false, AimFov=150,
    EspLine=false, EspBox=false, EspBox3D=false, EspHealth=false,
    EspName=false, EspDistance=false, EspSkeleton=false, EspFov=false,
    Fly=false, AutoFlyStep=0, HitFly=false,
    SpeedFly=5, HighHitFly=50, SpeedHitFly=75,
    TeleportPlayer=false, TeleKill=false, SelectedTarget=nil,
    SpeedHack=false, JumpHack=false, GhostHack=false,
    TeamCheck=true,
}

-- THEME
local T = {
    Bg0   = Color3.fromRGB(10,10,10),
    Bg1   = Color3.fromRGB(18,18,18),
    Bg2   = Color3.fromRGB(26,26,26),
    Bg3   = Color3.fromRGB(34,34,34),
    Red   = Color3.fromRGB(200,35,35),
    RedDim= Color3.fromRGB(120,20,20),
    White = Color3.fromRGB(230,230,230),
    Gray  = Color3.fromRGB(120,120,120),
    Gray2 = Color3.fromRGB(70,70,70),
    Green = Color3.fromRGB(50,200,80),
    Black = Color3.fromRGB(0,0,0),
}

-- UTIL
local function getChar() return LP.Character end
local function getRoot() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function isAim()   return S.EnableFunction and S.EnableAim end
local function isEsp()   return S.EnableFunction and S.EnableEsp end

local function corner(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 4) c.Parent=p return c end
local function stroke(p,col,th) local s=Instance.new("UIStroke") s.Color=col or T.Gray2 s.Thickness=th or 1 s.Parent=p return s end

local function newFrame(parent, sz, pos, col, trans)
    local f = Instance.new("Frame")
    f.Size = sz or UDim2.new(1,0,0,30)
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = col or T.Bg1
    f.BackgroundTransparency = trans or 0
    f.BorderSizePixel = 0
    f.Parent = parent
    return f
end

local function newText(parent, txt, sz, col, bold, xalign)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextSize = sz or 13
    l.TextColor3 = col or T.White
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function newBtn(parent, txt, sz, pos, col)
    local b = Instance.new("TextButton")
    b.Size = sz or UDim2.new(1,0,0,30)
    b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = col or T.Bg2
    b.BorderSizePixel = 0
    b.Text = txt or ""
    b.TextColor3 = T.White
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = parent
    return b
end

-- DRAG HELPER
local function makeDraggable(handle, target)
    local drag, ds, dp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag=true ds=i.Position dp=target.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            target.Position = UDim2.new(dp.X.Scale, dp.X.Offset+d.X, dp.Y.Scale, dp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end
    end)
end

-- ══════════════════════════════════════════
-- FLOATING LOGO ICON (P2077KNG style)
-- ══════════════════════════════════════════
local iconGui = Instance.new("ScreenGui")
iconGui.Name = "SantaXIcon"
iconGui.ResetOnSpawn = false
iconGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
iconGui.Parent = PGui

local iconBtn = Instance.new("ImageButton")
iconBtn.Size = UDim2.new(0,54,0,54)
iconBtn.Position = UDim2.new(0,16,0.5,-27)
iconBtn.BackgroundColor3 = T.Bg0
iconBtn.Image = "rbxassetid://104012475483632"
iconBtn.ImageColor3 = Color3.fromRGB(255,255,255)
iconBtn.BorderSizePixel = 0
iconBtn.Visible = false
iconBtn.Parent = iconGui
corner(iconBtn, 12)
stroke(iconBtn, T.Red, 2)
makeDraggable(iconBtn, iconBtn)

-- ══════════════════════════════════════════
-- MAIN WINDOW
-- ══════════════════════════════════════════
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "SantaXMain"
mainGui.ResetOnSpawn = false
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = PGui

-- Outer window
local win = newFrame(mainGui, UDim2.new(0,480,0,500), UDim2.new(0,200,0,120), T.Bg0)
corner(win,6)
stroke(win, T.Gray2, 1)

-- TITLE BAR
local titleBar = newFrame(win, UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), T.Bg0)
corner(titleBar,6)
stroke(titleBar, T.Red, 1)
makeDraggable(titleBar, win)

local arrowLbl = newText(titleBar,"▼",13,T.Red,true)
arrowLbl.Size = UDim2.new(0,20,1,0)
arrowLbl.Position = UDim2.new(0,8,0,0)
arrowLbl.TextXAlignment = Enum.TextXAlignment.Center

local titleLbl = newText(titleBar,"SantaXModsKng  1.12",13,T.White,true)
titleLbl.Size = UDim2.new(1,-60,1,0)
titleLbl.Position = UDim2.new(0,30,0,0)

local closeBtn = newBtn(titleBar,"X",UDim2.new(0,28,0,22),UDim2.new(1,-32,0.5,-11),T.RedDim)
corner(closeBtn,4)
closeBtn.TextColor3 = T.White
closeBtn.TextSize = 13

-- BODY (under title)
local body = newFrame(win, UDim2.new(1,0,1,-32), UDim2.new(0,0,0,32), T.Bg0)

-- LEFT SIDEBAR (tab list)
local sidebar = newFrame(body, UDim2.new(0,110,1,0), UDim2.new(0,0,0,0), T.Bg1)
stroke(sidebar, T.Gray2, 1)

-- RIGHT CONTENT
local content = newFrame(body, UDim2.new(1,-112,1,-2), UDim2.new(0,112,0,1), T.Bg0)

-- collapse state
local collapsed = false
local function setCollapsed(v)
    collapsed = v
    body.Visible = not v
    arrowLbl.Text = v and "▶" or "▼"
    win.Size = v and UDim2.new(0,480,0,32) or UDim2.new(0,480,0,500)
end

-- Toggle collapse
local toggleHitbar = newBtn(titleBar,"",UDim2.new(1,-60,1,0),UDim2.new(0,28,0,0),T.Bg0)
toggleHitbar.BackgroundTransparency = 1
toggleHitbar.ZIndex = 5
toggleHitbar.MouseButton1Click:Connect(function()
    setCollapsed(not collapsed)
end)

-- Close → show icon
closeBtn.MouseButton1Click:Connect(function()
    win.Visible = false
    iconBtn.Visible = true
end)
iconBtn.MouseButton1Click:Connect(function()
    iconBtn.Visible = false
    win.Visible = true
end)

-- ══════════════════════════════════════════
-- SCROLL CONTENT HELPER
-- ══════════════════════════════════════════
local function makeScroll(parent)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = T.Red
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Visible = false
    sf.Parent = parent
    local ul = Instance.new("UIListLayout")
    ul.SortOrder = Enum.SortOrder.LayoutOrder
    ul.Padding = UDim.new(0,3)
    ul.Parent = sf
    local up = Instance.new("UIPadding")
    up.PaddingLeft=UDim.new(0,6) up.PaddingRight=UDim.new(0,6)
    up.PaddingTop=UDim.new(0,6)  up.PaddingBottom=UDim.new(0,8)
    up.Parent = sf
    return sf
end

-- ══════════════════════════════════════════
-- SECTION HEADER
-- ══════════════════════════════════════════
local function secHeader(parent, txt, order)
    local f = newFrame(parent, UDim2.new(1,0,0,22), nil, T.Bg2)
    corner(f,4) f.LayoutOrder = order or 0
    local l = newText(f,"  "..txt,11,T.Red,true)
    l.TextXAlignment = Enum.TextXAlignment.Left
    return f
end

-- ══════════════════════════════════════════
-- TOGGLE ROW (FIXED - no nested buttons)
-- ══════════════════════════════════════════
local toggleCallbacks = {}

local function makeToggle(parent, labelTxt, stateKey, order)
    local row = newFrame(parent, UDim2.new(1,0,0,28), nil, T.Bg2)
    corner(row,4) row.LayoutOrder = order or 1

    local lbl = newText(row,"  "..labelTxt,12,T.White,false)
    lbl.Size = UDim2.new(1,-54,1,0)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- pill container
    local pillBg = newFrame(row, UDim2.new(0,38,0,20), UDim2.new(1,-44,0.5,-10),
        S[stateKey] and T.Red or T.Gray2)
    corner(pillBg,10)

    local pillDot = newFrame(pillBg, UDim2.new(0,14,0,14), UDim2.new(0,3,0.5,-7), T.White)
    corner(pillDot,7)

    local function refresh(val)
        TweenSvc:Create(pillBg,TweenInfo.new(0.1),{BackgroundColor3=val and T.Red or T.Gray2}):Play()
        TweenSvc:Create(pillDot,TweenInfo.new(0.1),{Position=val and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
    end

    local function doToggle()
        S[stateKey] = not S[stateKey]
        refresh(S[stateKey])
        if toggleCallbacks[stateKey] then
            for _, fn in ipairs(toggleCallbacks[stateKey]) do fn(S[stateKey]) end
        end
    end

    -- Clickable overlay on entire row
    local hitBtn = Instance.new("TextButton")
    hitBtn.Size = UDim2.new(1,0,1,0)
    hitBtn.BackgroundTransparency = 1
    hitBtn.Text = ""
    hitBtn.ZIndex = 4
    hitBtn.Parent = row
    hitBtn.MouseButton1Click:Connect(doToggle)

    toggleCallbacks[stateKey] = toggleCallbacks[stateKey] or {}
    return row, refresh
end

-- ══════════════════════════════════════════
-- SLIDER ROW
-- ══════════════════════════════════════════
local function makeSlider(parent, labelTxt, stateKey, minV, maxV, order)
    local row = newFrame(parent, UDim2.new(1,0,0,44), nil, T.Bg2)
    corner(row,4) row.LayoutOrder = order or 1

    local lbl = newText(row,"  "..labelTxt,11,T.White,false)
    lbl.Size = UDim2.new(0.65,0,0,18)
    lbl.Position = UDim2.new(0,0,0,3)

    local valL = newText(row,tostring(S[stateKey]),11,T.Red,true,Enum.TextXAlignment.Right)
    valL.Size = UDim2.new(0.3,0,0,18)
    valL.Position = UDim2.new(0.68,0,0,3)

    local trackBg = newFrame(row, UDim2.new(1,-12,0,5), UDim2.new(0,6,0,29), T.Bg3)
    corner(trackBg,3)

    local pct = (S[stateKey]-minV)/(maxV-minV)
    local fill = newFrame(trackBg, UDim2.new(pct,0,1,0), nil, T.Red)
    corner(fill,3)

    local thumb = newFrame(trackBg, UDim2.new(0,13,0,13), UDim2.new(pct,-6,0.5,-6), T.White)
    corner(thumb,7)

    local sliding = false
    local hitSlide = Instance.new("TextButton")
    hitSlide.Size = UDim2.new(1,0,0,18)
    hitSlide.Position = UDim2.new(0,0,0,22)
    hitSlide.BackgroundTransparency = 1
    hitSlide.Text = ""
    hitSlide.ZIndex = 4
    hitSlide.Parent = row

    hitSlide.MouseButton1Down:Connect(function() sliding=true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
    UIS.InputChanged:Connect(function(i)
        if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1)
            local nv = math.floor(minV + rel*(maxV-minV))
            S[stateKey] = nv
            fill.Size = UDim2.new(rel,0,1,0)
            thumb.Position = UDim2.new(rel,-6,0.5,-6)
            valL.Text = tostring(nv)
        end
    end)
    return row
end

-- ══════════════════════════════════════════
-- FLOATING UI FOR LOGO FEATURES (SEPARATE)
-- ══════════════════════════════════════════
local floatGuis = {}

local function makeFloatUI(featureName, stateKey)
    if floatGuis[stateKey] then
        floatGuis[stateKey]:Destroy()
        floatGuis[stateKey] = nil
        return
    end

    local fg = Instance.new("ScreenGui")
    fg.Name = "Float_"..stateKey
    fg.ResetOnSpawn = false
    fg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    fg.Parent = PGui
    floatGuis[stateKey] = fg

    local fw = newFrame(fg, UDim2.new(0,170,0,64), UDim2.new(0,80,0.45,0), T.Bg0)
    corner(fw,6) stroke(fw,T.Gray2,1)

    -- Header (abu-abu)
    local fhdr = newFrame(fw, UDim2.new(1,0,0,26), UDim2.new(0,0,0,0), T.Gray2)
    corner(fhdr,5)
    local fhdrL = newText(fhdr,"  "..featureName,12,T.White,true,Enum.TextXAlignment.Center)
    fhdrL.Size = UDim2.new(1,0,1,0)

    -- Toggle row (hitam)
    local frow = newFrame(fw, UDim2.new(1,0,0,34), UDim2.new(0,0,0,26), T.Bg0)

    local fLbl = newText(frow,"  "..featureName,12,T.White,false)
    fLbl.Size = UDim2.new(1,-54,1,0)
    fLbl.Position = UDim2.new(0,0,0,0)

    local fpb = newFrame(frow, UDim2.new(0,38,0,20), UDim2.new(1,-44,0.5,-10),
        S[stateKey] and T.Red or T.Gray2)
    corner(fpb,10)
    local fpd = newFrame(fpb, UDim2.new(0,14,0,14), UDim2.new(0,3,0.5,-7), T.White)
    corner(fpd,7)

    local function fRefresh(val)
        TweenSvc:Create(fpb,TweenInfo.new(0.1),{BackgroundColor3=val and T.Red or T.Gray2}):Play()
        TweenSvc:Create(fpd,TweenInfo.new(0.1),{Position=val and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
    end

    fRefresh(S[stateKey])

    local fhit = Instance.new("TextButton")
    fhit.Size = UDim2.new(1,0,1,0)
    fhit.BackgroundTransparency = 1
    fhit.Text = ""
    fhit.ZIndex = 5
    fhit.Parent = frow
    fhit.MouseButton1Click:Connect(function()
        S[stateKey] = not S[stateKey]
        fRefresh(S[stateKey])
        if toggleCallbacks[stateKey] then
            for _, fn in ipairs(toggleCallbacks[stateKey]) do fn(S[stateKey]) end
        end
    end)

    -- Register sync: main menu → float
    toggleCallbacks[stateKey] = toggleCallbacks[stateKey] or {}
    table.insert(toggleCallbacks[stateKey], fRefresh)

    makeDraggable(fhdr, fw)
end

-- ══════════════════════════════════════════
-- LOGO TOGGLE ROW (dua baris terpisah)
-- ══════════════════════════════════════════
local function makeToggleWithLogo(parent, featureName, stateKey, logoStateKey, order)
    -- Row 1: fitur toggle biasa
    makeToggle(parent, featureName, stateKey, order)

    -- Row 2: logo launcher (terpisah)
    local logoRow = newFrame(parent, UDim2.new(1,0,0,28), nil, T.Bg3)
    corner(logoRow,4) logoRow.LayoutOrder = order + 0.5

    local logoLbl = newText(logoRow,"  "..featureName.." Logo",12,T.Gray,false)
    logoLbl.Size = UDim2.new(1,-54,1,0)

    local logoBtn = newBtn(logoRow,"⊞",UDim2.new(0,38,0,20),UDim2.new(1,-44,0.5,-10),T.Bg1)
    corner(logoBtn,4) stroke(logoBtn,T.Gray2,1)
    logoBtn.TextColor3 = T.Red
    logoBtn.TextSize = 14
    logoBtn.ZIndex = 5
    logoBtn.MouseButton1Click:Connect(function()
        makeFloatUI(featureName, stateKey)
    end)
end

-- ══════════════════════════════════════════
-- DROPDOWN TARGET
-- ══════════════════════════════════════════
local ddOpen = false
local ddFrame = nil

local function makeDropdown(parent, order)
    local row = newFrame(parent, UDim2.new(1,0,0,28), nil, T.Bg2)
    corner(row,4) row.LayoutOrder = order or 1

    local lbl = newText(row,"  Select Target",12,T.White,false)
    lbl.Size = UDim2.new(0.55,0,1,0)

    local ddBtn = newBtn(row, S.SelectedTarget or "None  ▾",
        UDim2.new(0,100,0,20), UDim2.new(1,-106,0.5,-10), T.Bg3)
    corner(ddBtn,4) stroke(ddBtn,T.Gray2,1)
    ddBtn.TextColor3 = T.Gray
    ddBtn.TextSize = 11
    ddBtn.ZIndex = 5

    ddBtn.MouseButton1Click:Connect(function()
        if ddFrame then ddFrame:Destroy() ddFrame=nil ddOpen=false return end
        ddOpen = true
        ddFrame = newFrame(mainGui, UDim2.new(0,130,0,0), nil, T.Bg1)
        corner(ddFrame,4) stroke(ddFrame,T.Gray2,1)
        ddFrame.AutomaticSize = Enum.AutomaticSize.Y
        ddFrame.ZIndex = 20
        local ap = ddBtn.AbsolutePosition
        ddFrame.Position = UDim2.new(0,ap.X,0,ap.Y+24)

        local ul = Instance.new("UIListLayout")
        ul.SortOrder = Enum.SortOrder.LayoutOrder
        ul.Parent = ddFrame

        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            count = count+1
            local item = newBtn(ddFrame, "  "..p.Name,
                UDim2.new(1,0,0,24), UDim2.new(0,0,0,0), T.Bg1)
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.TextSize = 11
            item.LayoutOrder = count
            item.ZIndex = 21
            item.MouseButton1Click:Connect(function()
                S.SelectedTarget = p.Name
                ddBtn.Text = p.Name.."  ▾"
                ddBtn.TextColor3 = T.Red
                ddFrame:Destroy() ddFrame=nil ddOpen=false
            end)
        end
        if count == 0 then
            local none = newText(ddFrame,"  No players",11,T.Gray)
            none.Size = UDim2.new(1,0,0,24)
        end
    end)
end

-- ══════════════════════════════════════════
-- AUTO FLY UI (3-click)
-- ══════════════════════════════════════════
local autoFlyGui = nil
local autoFlyBV = nil

local function makeAutoFlyUI()
    if autoFlyGui then
        autoFlyGui:Destroy() autoFlyGui=nil
        S.AutoFlyStep = 0
        if autoFlyBV then autoFlyBV:Destroy() autoFlyBV=nil end
        local h=getHum() if h then h.PlatformStand=false end
        return
    end

    autoFlyGui = Instance.new("ScreenGui")
    autoFlyGui.Name = "AutoFlyUI"
    autoFlyGui.ResetOnSpawn = false
    autoFlyGui.Parent = PGui

    local aw = newFrame(autoFlyGui, UDim2.new(0,190,0,86), UDim2.new(0,80,0.65,0), T.Bg0)
    corner(aw,6) stroke(aw,T.Red,1)

    local ahdr = newFrame(aw, UDim2.new(1,0,0,26), UDim2.new(0,0,0,0), T.Gray2)
    corner(ahdr,5)
    local ahdrL = newText(ahdr,"  Auto Fly",12,T.White,true,Enum.TextXAlignment.Center)
    ahdrL.Size = UDim2.new(1,0,1,0)
    makeDraggable(ahdr,aw)

    local stepL = newText(aw,"Ready",11,T.Gray,false,Enum.TextXAlignment.Center)
    stepL.Size = UDim2.new(1,0,0,18)
    stepL.Position = UDim2.new(0,0,0,28)

    local clickBtn = newBtn(aw,"Click 1 — Set Position",
        UDim2.new(1,-16,0,24), UDim2.new(0,8,0,52), T.Red)
    corner(clickBtn,4)
    clickBtn.TextSize = 11

    local steps = {
        [0]={btn="Click 1 — Set Position", lbl="Ready"},
        [1]={btn="Click 2 — Start Flying",  lbl="Step 1: Position Set"},
        [2]={btn="Click 3 — Lock Position", lbl="Step 2: Flying Up..."},
        [3]={btn="Locked ✓",                lbl="Step 3: Locked — Can Shoot"},
    }

    local function updStep()
        local d = steps[S.AutoFlyStep]
        if d then clickBtn.Text=d.btn stepL.Text=d.lbl end
    end

    clickBtn.MouseButton1Click:Connect(function()
        local char=getChar() local root=getRoot()
        if not char or not root then return end
        if S.AutoFlyStep==0 then
            S.AutoFlyStep=1
            local h=getHum() if h then h.PlatformStand=true end
            root.CFrame = root.CFrame + Vector3.new(0,1,0)
        elseif S.AutoFlyStep==1 then
            S.AutoFlyStep=2
            if autoFlyBV then autoFlyBV:Destroy() end
            autoFlyBV = Instance.new("BodyVelocity")
            autoFlyBV.Velocity = Vector3.new(0, S.SpeedFly*6, 0)
            autoFlyBV.MaxForce = Vector3.new(0,1e6,0)
            autoFlyBV.Parent = root
        elseif S.AutoFlyStep==2 then
            S.AutoFlyStep=3
            if autoFlyBV then autoFlyBV:Destroy() autoFlyBV=nil end
            local bp = Instance.new("BodyPosition")
            bp.Position = root.Position
            bp.MaxForce = Vector3.new(1e6,1e6,1e6)
            bp.D=500 bp.P=10000
            bp.Parent = root
            autoFlyBV = bp
        end
        updStep()
    end)
end

-- ══════════════════════════════════════════
-- BUILD PAGES
-- ══════════════════════════════════════════
local pages = {}

local function makePage(name)
    local sf = makeScroll(content)
    pages[name] = sf
    return sf
end

-- PAGE: FUNCTION
local pFunc = makePage("Function")
secHeader(pFunc,"Function",1)
makeToggle(pFunc,"Enable Function","EnableFunction",2)
makeToggle(pFunc,"Enable Aim","EnableAim",3)
makeToggle(pFunc,"Enable Esp","EnableEsp",4)

-- divider
local div0 = newFrame(pFunc, UDim2.new(1,0,0,1), nil, T.Gray2)
div0.LayoutOrder = 5

-- info box
local infoF = newFrame(pFunc, UDim2.new(1,0,0,108), nil, T.Bg2)
corner(infoF,5) infoF.LayoutOrder=6
local ih1 = newText(infoF,"  Release Version Official.  | Details",11,T.Red,true)
ih1.Size=UDim2.new(1,0,0,18) ih1.Position=UDim2.new(0,0,0,4)
local ih2 = Instance.new("TextLabel")
ih2.Size=UDim2.new(1,-12,0,38) ih2.Position=UDim2.new(0,6,0,22)
ih2.BackgroundTransparency=1
ih2.Text="SantaXMods has been released with\nthe official version."
ih2.TextColor3=T.Gray ih2.TextSize=11 ih2.Font=Enum.Font.Gotham
ih2.TextXAlignment=Enum.TextXAlignment.Left ih2.TextYAlignment=Enum.TextYAlignment.Top
ih2.TextWrapped=true ih2.Parent=infoF
local ih3=newText(infoF,"  Developer: SkyFlow",10,T.Gray)
ih3.Size=UDim2.new(1,0,0,14) ih3.Position=UDim2.new(0,0,0,62)
local ih4=newText(infoF,"  Youtube: @Skyflowh4x   Tiktok: @Sky.flow77",10,T.Gray)
ih4.Size=UDim2.new(1,0,0,14) ih4.Position=UDim2.new(0,0,0,76)
local ih5=newText(infoF,"  Version: 1.12",10,T.Gray)
ih5.Size=UDim2.new(1,0,0,14) ih5.Position=UDim2.new(0,0,0,90)

-- PAGE: AIM
local pAim = makePage("Aim")
secHeader(pAim,"Aim Function",1)
makeToggle(pAim,"Aimbot","Aimbot",2)
makeToggle(pAim,"Aim Assist","AimAssist",3)
makeToggleWithLogo(pAim,"Aim Silent","AimSilent","AimSilent",4)
makeToggleWithLogo(pAim,"Aim Magnet","AimMagnet","AimMagnet",6)
makeToggleWithLogo(pAim,"AutoKill","AutoKill","AutoKill",8)
makeToggle(pAim,"Aim Visible","AimVisible",10)
makeSlider(pAim,"Aim FOV","AimFov",0,360,11)

-- PAGE: ESP
local pEsp = makePage("Esp")
secHeader(pEsp,"Esp Function",1)
makeToggle(pEsp,"Esp Line","EspLine",2)
makeToggle(pEsp,"Esp Box","EspBox",3)
makeToggle(pEsp,"Esp Box 3D","EspBox3D",4)
makeToggle(pEsp,"Esp Health","EspHealth",5)
makeToggle(pEsp,"Esp Name","EspName",6)
makeToggle(pEsp,"Esp Distance","EspDistance",7)
makeToggle(pEsp,"Esp Skeleton","EspSkeleton",8)
makeToggle(pEsp,"Esp Fov","EspFov",9)

-- PAGE: FLY/TELE
local pFly = makePage("Fly/Tele")
secHeader(pFly,"Fly Function",1)
makeToggle(pFly,"Fly","Fly",2)

-- Auto Fly row (terpisah dengan logo)
local afRow = newFrame(pFly, UDim2.new(1,0,0,28), nil, T.Bg2)
corner(afRow,4) afRow.LayoutOrder=3
local afLbl = newText(afRow,"  Auto Fly",12,T.White,false)
afLbl.Size=UDim2.new(1,-54,1,0)
local afBtnLogo = newBtn(afRow,"⊞",UDim2.new(0,38,0,20),UDim2.new(1,-44,0.5,-10),T.Bg1)
corner(afBtnLogo,4) stroke(afBtnLogo,T.Gray2,1)
afBtnLogo.TextColor3=T.Red afBtnLogo.TextSize=14 afBtnLogo.ZIndex=5
afBtnLogo.MouseButton1Click:Connect(makeAutoFlyUI)

makeToggle(pFly,"Hit Fly","HitFly",4)
makeSlider(pFly,"Speed Fly","SpeedFly",1,10,5)
makeSlider(pFly,"High Hit Fly (m)","HighHitFly",0,100,6)
makeSlider(pFly,"Speed Hit Fly (m)","SpeedHitFly",0,150,7)

local div1=newFrame(pFly,UDim2.new(1,0,0,1),nil,T.Gray2) div1.LayoutOrder=8
secHeader(pFly,"Teleport Function",9)
makeToggle(pFly,"Teleport Player","TeleportPlayer",10)
makeToggle(pFly,"TeleKill","TeleKill",11)

-- TeleKill Logo (terpisah)
local tkLogoRow = newFrame(pFly, UDim2.new(1,0,0,28), nil, T.Bg3)
corner(tkLogoRow,4) tkLogoRow.LayoutOrder=12
local tkLbl2=newText(tkLogoRow,"  TeleKill Logo",12,T.Gray,false)
tkLbl2.Size=UDim2.new(1,-54,1,0)
local tkLB=newBtn(tkLogoRow,"⊞",UDim2.new(0,38,0,20),UDim2.new(1,-44,0.5,-10),T.Bg1)
corner(tkLB,4) stroke(tkLB,T.Gray2,1)
tkLB.TextColor3=T.Red tkLB.TextSize=14 tkLB.ZIndex=5
tkLB.MouseButton1Click:Connect(function() makeFloatUI("TeleKill","TeleKill") end)

makeDropdown(pFly,13)

-- PAGE: MISC
local pMisc = makePage("Misc")
secHeader(pMisc,"Misc Function",1)
makeToggle(pMisc,"SpeedHack","SpeedHack",2)
makeToggle(pMisc,"JumpHack","JumpHack",3)
makeToggle(pMisc,"GhostHack","GhostHack",4)

-- ══════════════════════════════════════════
-- SIDEBAR TAB BUTTONS
-- ══════════════════════════════════════════
local tabList = {"Function","Aim","Esp","Fly/Tele","Misc"}
local tabBtns = {}
local activeTab = nil

local tabUL = Instance.new("UIListLayout")
tabUL.SortOrder = Enum.SortOrder.LayoutOrder
tabUL.Padding = UDim.new(0,2)
tabUL.Parent = sidebar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingTop = UDim.new(0,6)
tabPad.PaddingLeft = UDim.new(0,4)
tabPad.PaddingRight = UDim.new(0,4)
tabPad.Parent = sidebar

local function switchTab(name)
    activeTab = name
    for n, pg in pairs(pages) do pg.Visible = (n==name) end
    for n, b in pairs(tabBtns) do
        b.BackgroundColor3 = (n==name) and T.Red or T.Bg2
        b.TextColor3 = (n==name) and T.White or T.Gray
    end
end

for i, tname in ipairs(tabList) do
    local tb = newBtn(sidebar, tname,
        UDim2.new(1,0,0,30), nil, T.Bg2)
    tb.TextSize = 11
    tb.TextColor3 = T.Gray
    tb.LayoutOrder = i
    corner(tb,4)
    tabBtns[tname] = tb
    tb.MouseButton1Click:Connect(function() switchTab(tname) end)
end

switchTab("Function")

-- ══════════════════════════════════════════
-- ESP ENGINE
-- ══════════════════════════════════════════
local espGui = Instance.new("ScreenGui")
espGui.Name = "SantaXEsp"
espGui.ResetOnSpawn = false
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.Parent = PGui

local espObj = {}

local function clearEsp(p)
    if not espObj[p] then return end
    for _, o in pairs(espObj[p]) do if o and o.Parent then o:Destroy() end end
    espObj[p] = nil
end

local function drawEsp(player)
    if not player.Character then clearEsp(player) return end
    local c = player.Character
    local root = c:FindFirstChild("HumanoidRootPart")
    local head = c:FindFirstChild("Head")
    local hum  = c:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health<=0 then clearEsp(player) return end

    local sp,vis = Cam:WorldToViewportPoint(root.Position)
    if not vis then clearEsp(player) return end

    espObj[player] = espObj[player] or {}
    local o = espObj[player]

    local hp2,_ = Cam:WorldToViewportPoint((head and head.Position or root.Position) + Vector3.new(0,0.8,0))
    local fp2,_ = Cam:WorldToViewportPoint(root.Position - Vector3.new(0,2.8,0))
    local boxH  = fp2.Y - hp2.Y
    local boxW  = boxH * 0.42
    local cx    = sp.X
    local myRoot = getRoot()
    local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0

    -- ESP BOX
    if S.EspBox then
        if not o.box then
            o.box = newFrame(espGui, UDim2.new(0,1,0,1), nil, T.Bg0)
            o.box.BackgroundTransparency = 1
            o.box.BorderSizePixel = 1
            o.box.BorderColor3 = T.White
        end
        o.box.Position = UDim2.new(0,cx-boxW/2,0,hp2.Y)
        o.box.Size = UDim2.new(0,boxW,0,boxH)
    elseif o.box then o.box:Destroy() o.box=nil end

    -- ESP NAME
    if S.EspName then
        if not o.name then
            o.name = Instance.new("TextLabel")
            o.name.BackgroundTransparency=1
            o.name.TextColor3=T.Red
            o.name.TextSize=11
            o.name.Font=Enum.Font.GothamBold
            o.name.Parent=espGui
        end
        o.name.Text = player.Name
        o.name.Position = UDim2.new(0,cx-50,0,hp2.Y-15)
        o.name.Size = UDim2.new(0,100,0,14)
    elseif o.name then o.name:Destroy() o.name=nil end

    -- ESP DISTANCE
    if S.EspDistance then
        if not o.dist then
            o.dist = Instance.new("TextLabel")
            o.dist.BackgroundTransparency=1
            o.dist.TextColor3=T.Red
            o.dist.TextSize=10
            o.dist.Font=Enum.Font.Gotham
            o.dist.Parent=espGui
        end
        o.dist.Text = dist.."m"
        o.dist.Position = UDim2.new(0,cx-30,0,fp2.Y+2)
        o.dist.Size = UDim2.new(0,60,0,14)
    elseif o.dist then o.dist:Destroy() o.dist=nil end

    -- ESP HEALTH
    if S.EspHealth then
        if not o.hbg then
            o.hbg = newFrame(espGui, UDim2.new(0,4,0,1), nil, T.Bg3)
            o.hfill = newFrame(o.hbg, UDim2.new(1,0,0,1), nil, T.Green)
        end
        local hp = math.clamp(hum.Health/hum.MaxHealth,0,1)
        o.hbg.Position = UDim2.new(0,cx-boxW/2-6,0,hp2.Y)
        o.hbg.Size = UDim2.new(0,4,0,boxH)
        o.hfill.Size = UDim2.new(1,0,hp,0)
        o.hfill.Position = UDim2.new(0,0,1-hp,0)
    elseif o.hbg then o.hbg:Destroy() o.hbg=nil end

    -- ESP LINE
    if S.EspLine then
        if not o.line then
            o.line = newFrame(espGui, UDim2.new(0,1,0,1), nil, T.White)
        end
        local vp = Cam.ViewportSize
        local mx,my = vp.X/2, 0
        local dx = cx-mx  local dy = sp.Y-my
        local len = math.sqrt(dx*dx+dy*dy)
        o.line.Position = UDim2.new(0,mx,0,my)
        o.line.Size = UDim2.new(0,len,0,1)
        o.line.Rotation = math.deg(math.atan2(dy,dx))
    elseif o.line then o.line:Destroy() o.line=nil end
end

-- ESP FOV CIRCLE
local fovCircle = newFrame(espGui, UDim2.new(0,1,0,1), nil, T.Bg0)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 2
fovCircle.BorderColor3 = T.Red
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
fovCircle.Visible = false
corner(fovCircle, 999)

-- ══════════════════════════════════════════
-- AIM ENGINE
-- ══════════════════════════════════════════
local silOrig = nil
local silShoot = false
local flyBV = nil
local ghostSaved = {}
local teleRunning = false

-- AIM SILENT
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not isAim() or not S.AimSilent then return end
    local t = nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local c=p.Character if not c then continue end
        local h=c:FindFirstChild("Head") if not h then continue end
        local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
        local sp,vis=Cam:WorldToViewportPoint(h.Position) if not vis then continue end
        local m=UIS:GetMouseLocation()
        if (Vector2.new(sp.X,sp.Y)-m).Magnitude < S.AimFov then t=h break end
    end
    if not t then return end
    silOrig = Cam.CFrame silShoot=true
    Cam.CFrame = CFrame.new(Cam.CFrame.Position, t.Position)
    task.defer(function()
        task.wait()
        if silOrig and silShoot then Cam.CFrame=silOrig silOrig=nil silShoot=false end
    end)
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        if silOrig then Cam.CFrame=silOrig silOrig=nil silShoot=false end
    end
end)

-- FLY
local function enFly()
    local r=getRoot() if not r then return end
    local h=getHum() if h then h.PlatformStand=true end
    if flyBV then flyBV:Destroy() end
    flyBV=Instance.new("BodyVelocity")
    flyBV.Velocity=Vector3.zero flyBV.MaxForce=Vector3.new(1e5,1e5,1e5) flyBV.Parent=r
end
local function disFly()
    local h=getHum() if h then h.PlatformStand=false end
    if flyBV then flyBV:Destroy() flyBV=nil end
end

-- GHOST
local function applyGhost(char,on)
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if on then
                ghostSaved[p]=p.LocalTransparencyModifier
                p.LocalTransparencyModifier = p.Name=="HumanoidRootPart" and 0 or 1
            elseif ghostSaved[p]~=nil then
                p.LocalTransparencyModifier=ghostSaved[p]
            end
        end
    end
    if not on then ghostSaved={} end
end

-- TELEKILL
local function doTeleKill()
    if teleRunning then return end teleRunning=true
    task.spawn(function()
        while S.TeleKill and isAim() do
            local target
            if S.SelectedTarget then target=Players:FindFirstChild(S.SelectedTarget) end
            if not target then
                local bd,bt=999,nil
                for _,p in ipairs(Players:GetPlayers()) do
                    if p==LP then continue end
                    local c=p.Character if not c then continue end
                    local r2=c:FindFirstChild("HumanoidRootPart") if not r2 then continue end
                    local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
                    local mr=getRoot() if not mr then continue end
                    local d=(mr.Position-r2.Position).Magnitude
                    if d<bd then bd=d bt=p end
                end
                target=bt
            end
            if target then
                local tc=target.Character
                local tr=tc and tc:FindFirstChild("HumanoidRootPart")
                local mr=getRoot()
                if tr and mr then
                    mr.CFrame = tr.CFrame * CFrame.new(0,0,-1.5)
                    task.wait(0.05)
                    local hm=tc:FindFirstChildOfClass("Humanoid")
                    if hm then hm.Health=0 end
                end
            end
            task.wait(0.7)
        end
        teleRunning=false
    end)
end

-- TELEPORT PLAYER (P key)
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.P and S.TeleportPlayer then
        local target
        if S.SelectedTarget then target=Players:FindFirstChild(S.SelectedTarget) end
        if target then
            local tc=target.Character
            local tr=tc and tc:FindFirstChild("HumanoidRootPart")
            local mr=getRoot()
            if tr and mr then mr.CFrame=tr.CFrame*CFrame.new(0,0,-2) end
        end
    end
end)

-- ══════════════════════════════════════════
-- MAIN LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- AIM MAGNET
    if isAim() and S.AimMagnet and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local best,bd=nil,S.AimFov
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character if not c then continue end
            local h=c:FindFirstChild("Head") if not h then continue end
            local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
            local sp,vis=Cam:WorldToViewportPoint(h.Position) if not vis then continue end
            local m=UIS:GetMouseLocation()
            local d=(Vector2.new(sp.X,sp.Y)-m).Magnitude
            if d<bd then bd=d best=h end
        end
        if best then
            Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,best.Position),0.14)
        end
    end

    -- AIMBOT
    if isAim() and S.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local best,bd=nil,S.AimFov
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character if not c then continue end
            local h=c:FindFirstChild("Head") if not h then continue end
            local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
            local sp,vis=Cam:WorldToViewportPoint(h.Position) if not vis then continue end
            local m=UIS:GetMouseLocation()
            local d=(Vector2.new(sp.X,sp.Y)-m).Magnitude
            if d<bd then bd=d best=h end
        end
        if best then
            Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,best.Position),0.35)
        end
    end

    -- AIM ASSIST
    if isAim() and S.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local best,bd=nil,S.AimFov
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character if not c then continue end
            local r2=c:FindFirstChild("HumanoidRootPart") if not r2 then continue end
            local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
            local sp,vis=Cam:WorldToViewportPoint(r2.Position) if not vis then continue end
            local m=UIS:GetMouseLocation()
            local d=(Vector2.new(sp.X,sp.Y)-m).Magnitude
            if d<bd then bd=d best=r2 end
        end
        if best then
            Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,best.Position),0.06)
        end
    end

    -- AUTOKILL
    if isAim() and S.AutoKill then
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character if not c then continue end
            local sp,vis=Cam:WorldToViewportPoint((c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart or c:FindFirstChild("Head") or Instance.new("Part")).Position)
            if not vis then continue end
            local m=UIS:GetMouseLocation()
            if (Vector2.new(sp.X,sp.Y)-m).Magnitude < S.AimFov then
                local hm=c:FindFirstChildOfClass("Humanoid") if hm then hm.Health=0 end
            end
        end
    end

    -- TELEKILL
    if isAim() and S.TeleKill then doTeleKill() end

    -- FLY
    if S.Fly then
        if not flyBV then enFly() end
        local d=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end
        if flyBV then flyBV.Velocity = d*(S.SpeedFly*8) end
    else
        if flyBV then disFly() end
    end

    -- MISC
    local hum=getHum()
    if hum then
        hum.WalkSpeed = S.SpeedHack and 80 or 16
        hum.JumpPower = S.JumpHack  and 120 or 50
    end

    -- GHOST
    local char=getChar()
    if char then
        if S.GhostHack then applyGhost(char,true)
        elseif next(ghostSaved)~=nil then applyGhost(char,false) end
    end

    -- ESP
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if isEsp() and (S.EspBox or S.EspName or S.EspDistance or S.EspHealth or S.EspLine) then
            drawEsp(p)
        else
            clearEsp(p)
        end
    end

    -- FOV CIRCLE
    if isEsp() and S.EspFov then
        local m=UIS:GetMouseLocation()
        fovCircle.Visible=true
        fovCircle.Position=UDim2.new(0,m.X,0,m.Y)
        fovCircle.Size=UDim2.new(0,S.AimFov*2,0,S.AimFov*2)
    else
        fovCircle.Visible=false
    end
end)

Players.PlayerRemoving:Connect(function(p) clearEsp(p) end)
print("[ SantaXModsKng v1.12 ] Loaded — SkyFlow")
