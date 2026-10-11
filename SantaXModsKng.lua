--[[
  SantaXModsKng.lua | v1.12
  Developer : SkyFlow
  Youtube   : @Skyflowh4x
  Tiktok    : @Sky.flow77
]]

-- ─── SERVICES ────────────────────────────────────────────────
local Plrs   = game:GetService("Players")
local RS     = game:GetService("RunService")
local UIS    = game:GetService("UserInputService")
local TS     = game:GetService("TweenService")
local LP     = Plrs.LocalPlayer
local Cam    = workspace.CurrentCamera
local PGui   = LP:WaitForChild("PlayerGui")

-- ─── CLEANUP ─────────────────────────────────────────────────
for _,v in ipairs(PGui:GetChildren()) do
    if v.Name:find("SantaX") or v.Name:find("Float_") or v.Name:find("AutoFly") then
        v:Destroy()
    end
end

-- ─── STATE ───────────────────────────────────────────────────
local S = {
    EnableFunction=false, EnableAim=false, EnableEsp=false,
    Aimbot=false, AimAssist=false, AimSilent=false,
    AimMagnet=false, AutoKill=false, AimVisible=false, AimFov=150,
    EspLine=false, EspBox=false, EspBox3D=false, EspHealth=false,
    EspName=false, EspDistance=false, EspSkeleton=false, EspFov=false,
    Fly=false, AutoFlyStep=0, HitFly=false,
    SpeedFly=5, HighHitFly=50, SpeedHitFly=75,
    TeleportPlayer=false, TeleKill=false, SelectedTarget=nil,
    SpeedHack=false, JumpHack=false, GhostHack=false,
    TeamCheck=true,
}

-- ─── THEME ───────────────────────────────────────────────────
local C = {
    Bg0    = Color3.fromRGB(8,8,8),
    Bg1    = Color3.fromRGB(16,16,16),
    Bg2    = Color3.fromRGB(24,24,24),
    Bg3    = Color3.fromRGB(32,32,32),
    Red    = Color3.fromRGB(220,35,35),
    RedDim = Color3.fromRGB(140,20,20),
    White  = Color3.fromRGB(235,235,235),
    Gray   = Color3.fromRGB(140,140,140),
    DGray  = Color3.fromRGB(65,65,65),
    Green  = Color3.fromRGB(45,200,75),
    Black  = Color3.fromRGB(0,0,0),
}

-- ─── SCREEN SIZE SCALE ───────────────────────────────────────
local vp       = Cam.ViewportSize
local SCALE    = math.clamp(math.min(vp.X/1080, vp.Y/1920)*2.2, 0.72, 2.0)
local W        = math.floor(500*SCALE)
local H        = math.floor(520*SCALE)
local SIDE     = math.floor(120*SCALE)
local FS_BIG   = math.floor(14*SCALE)
local FS_MED   = math.floor(12*SCALE)
local FS_SM    = math.floor(11*SCALE)
local ROW_H    = math.floor(34*SCALE)
local HDR_H    = math.floor(38*SCALE)
local TAB_W    = SIDE

-- ─── HELPERS ─────────────────────────────────────────────────
local function corner(p,r) local o=Instance.new("UICorner") o.CornerRadius=UDim.new(0,r or 4) o.Parent=p return o end
local function stroke(p,col,th) local o=Instance.new("UIStroke") o.Color=col or C.DGray o.Thickness=th or 1 o.Parent=p return o end

local function Fr(par, sz, pos, col, alpha)
    local f=Instance.new("Frame")
    f.Size=sz or UDim2.new(1,0,0,ROW_H)
    f.Position=pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3=col or C.Bg1
    f.BackgroundTransparency=alpha or 0
    f.BorderSizePixel=0
    f.ClipsDescendants=false
    f.Parent=par
    return f
end

local function Tx(par, txt, fs, col, bold, xa)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,1,0)
    l.BackgroundTransparency=1
    l.Text=txt l.TextSize=fs or FS_MED
    l.TextColor3=col or C.White
    l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.TextTruncate=Enum.TextTruncate.AtEnd
    l.Parent=par return l
end

local function Btn(par, txt, sz, pos, col)
    local b=Instance.new("TextButton")
    b.Size=sz or UDim2.new(1,0,0,ROW_H)
    b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=col or C.Bg2
    b.BorderSizePixel=0 b.Text=txt or ""
    b.TextColor3=C.White b.TextSize=FS_MED
    b.Font=Enum.Font.GothamBold
    b.AutoButtonColor=false b.Parent=par return b
end

-- DRAG
local function draggable(handle, target)
    local on,ds,dp=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            on=true ds=i.Position dp=target.Position end
    end)
    UIS.InputChanged:Connect(function(i)
        if on and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            target.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then on=false end
    end)
end

-- ─── ICON GUI (floating, bulat) ──────────────────────────────
local iconSG=Instance.new("ScreenGui")
iconSG.Name="SantaXIcon" iconSG.ResetOnSpawn=false iconSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
iconSG.Parent=PGui

local ICON_SIZE=math.floor(62*SCALE)
local iconBtn=Instance.new("ImageButton")
iconBtn.Size=UDim2.new(0,ICON_SIZE,0,ICON_SIZE)
iconBtn.Position=UDim2.new(0,18,0.5,-ICON_SIZE/2)
iconBtn.BackgroundTransparency=1
iconBtn.Image="rbxassetid://104012475483632"
iconBtn.Visible=false
iconBtn.Parent=iconSG
corner(iconBtn,ICON_SIZE)
draggable(iconBtn,iconBtn)

-- ─── MAIN GUI ─────────────────────────────────────────────────
local mainSG=Instance.new("ScreenGui")
mainSG.Name="SantaXMain" mainSG.ResetOnSpawn=false
mainSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling mainSG.Parent=PGui

-- Window
local win=Fr(mainSG,UDim2.new(0,W,0,H+HDR_H),UDim2.new(0.5,-W/2,0.5,-(H+HDR_H)/2),C.Bg0)
corner(win,8) stroke(win,C.Red,1.5)

-- ── TITLE BAR ──────────────────────────────────────────────────
local titleH=HDR_H
local tbar=Fr(win,UDim2.new(1,0,0,titleH),UDim2.new(0,0,0,0),C.Bg0)
corner(tbar,8) stroke(tbar,C.Red,1)

-- Red accent bar top
local accent=Fr(tbar,UDim2.new(1,0,0,3),UDim2.new(0,0,0,0),C.Red)
corner(accent,8)

-- arrow
local arrowL=Tx(tbar,"▼",FS_MED,C.Red,true)
arrowL.Size=UDim2.new(0,24,1,0) arrowL.Position=UDim2.new(0,10,0,0)
arrowL.TextXAlignment=Enum.TextXAlignment.Center

-- title text
local titleL=Tx(tbar,"SantaXModsKng",FS_BIG,C.White,true)
titleL.Size=UDim2.new(1,-90,1,0) titleL.Position=UDim2.new(0,36,0,0)

-- version
local verL=Tx(tbar,"v1.12",FS_SM,C.Gray,false,Enum.TextXAlignment.Right)
verL.Size=UDim2.new(0,60,1,0) verL.Position=UDim2.new(1,-96,0,0)

-- close button
local closeB=Btn(tbar,"✕",UDim2.new(0,30,0,22),UDim2.new(1,-34,0.5,-11),C.RedDim)
corner(closeB,5) closeB.TextSize=FS_MED closeB.ZIndex=6

draggable(tbar,win)

-- ── BODY ───────────────────────────────────────────────────────
local body=Fr(win,UDim2.new(1,0,1,-titleH),UDim2.new(0,0,0,titleH),C.Bg0)

-- Sidebar
local sidebar=Fr(body,UDim2.new(0,TAB_W,1,0),UDim2.new(0,0,0,0),C.Bg1)
stroke(sidebar,C.DGray,1)

-- Content
local cw=W-TAB_W-2
local contentArea=Fr(body,UDim2.new(0,cw,1,-2),UDim2.new(0,TAB_W+2,0,1),C.Bg0)

-- Collapse
local collapsed=false
local function setCollapse(v)
    collapsed=v
    body.Visible=not v
    arrowL.Text=v and "▶" or "▼"
    win.Size=v and UDim2.new(0,W,0,titleH) or UDim2.new(0,W,0,H+titleH)
end

-- Collapse click zone (not on close btn)
local colHit=Btn(tbar,"",UDim2.new(1,-38,1,0),UDim2.new(0,0,0,0))
colHit.BackgroundTransparency=1 colHit.ZIndex=5
colHit.MouseButton1Click:Connect(function() setCollapse(not collapsed) end)

-- Close action
closeB.MouseButton1Click:Connect(function()
    win.Visible=false iconBtn.Visible=true end)
iconBtn.MouseButton1Click:Connect(function()
    iconBtn.Visible=false win.Visible=true end)

-- ─── SCROLL PAGE FACTORY ──────────────────────────────────────
local function mkPage()
    local sf=Instance.new("ScrollingFrame")
    sf.Size=UDim2.new(1,0,1,0)
    sf.BackgroundTransparency=1 sf.BorderSizePixel=0
    sf.ScrollBarThickness=math.floor(4*SCALE)
    sf.ScrollBarImageColor3=C.Red
    sf.CanvasSize=UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Visible=false sf.Parent=contentArea
    local ul=Instance.new("UIListLayout")
    ul.SortOrder=Enum.SortOrder.LayoutOrder
    ul.Padding=UDim.new(0,math.floor(3*SCALE))
    ul.Parent=sf
    local up=Instance.new("UIPadding")
    local pad=math.floor(6*SCALE)
    up.PaddingLeft=UDim.new(0,pad) up.PaddingRight=UDim.new(0,pad)
    up.PaddingTop=UDim.new(0,pad) up.PaddingBottom=UDim.new(0,pad)
    up.Parent=sf return sf
end

-- ─── SECTION HEADER ──────────────────────────────────────────
local function secHdr(page, txt, order)
    local f=Fr(page,UDim2.new(1,0,0,math.floor(24*SCALE)),nil,C.Bg2)
    corner(f,4) f.LayoutOrder=order
    local line=Fr(f,UDim2.new(0,3,0.6,0),UDim2.new(0,0,0.2,0),C.Red)
    local l=Tx(f,"  "..txt,FS_SM,C.Red,true)
    l.Position=UDim2.new(0,8,0,0)
    return f
end

-- ─── TOGGLE CALLBACKS ─────────────────────────────────────────
local tCB={}
local function onToggle(key,val)
    if tCB[key] then for _,fn in ipairs(tCB[key]) do fn(val) end end
end

-- ─── PILL TOGGLE ROW ──────────────────────────────────────────
local function mkToggle(page, labelTxt, key, order)
    local row=Fr(page,UDim2.new(1,0,0,ROW_H),nil,C.Bg2)
    corner(row,4) row.LayoutOrder=order

    -- hover effect
    row.MouseEnter:Connect(function() row.BackgroundColor3=C.Bg3 end)
    row.MouseLeave:Connect(function() row.BackgroundColor3=C.Bg2 end)

    local lbl=Tx(row,"  "..labelTxt,FS_MED,C.White,false)
    lbl.Size=UDim2.new(1,-58,1,0)

    local pillW=math.floor(42*SCALE)
    local pillH=math.floor(22*SCALE)
    local dotS =math.floor(16*SCALE)

    local pillBg=Fr(row,UDim2.new(0,pillW,0,pillH),
        UDim2.new(1,-pillW-8,0.5,-pillH/2), S[key] and C.Red or C.DGray)
    corner(pillBg,pillH)

    local dotX = S[key] and pillW-dotS-3 or 3
    local dot=Fr(pillBg,UDim2.new(0,dotS,0,dotS),UDim2.new(0,dotX,0.5,-dotS/2),C.White)
    corner(dot,dotS)

    local function refresh(val)
        TS:Create(pillBg,TweenInfo.new(0.12),{BackgroundColor3=val and C.Red or C.DGray}):Play()
        TS:Create(dot,TweenInfo.new(0.12),{Position=val and UDim2.new(1,-dotS-3,0.5,-dotS/2) or UDim2.new(0,3,0.5,-dotS/2)}):Play()
    end

    local hit=Btn(row,"",UDim2.new(1,0,1,0))
    hit.BackgroundTransparency=1 hit.ZIndex=8
    hit.MouseButton1Click:Connect(function()
        S[key]=not S[key] refresh(S[key]) onToggle(key,S[key])
    end)

    tCB[key]=tCB[key] or {}
    table.insert(tCB[key],refresh)
    return row,refresh
end

-- ─── SLIDER ───────────────────────────────────────────────────
local function mkSlider(page, labelTxt, key, mn, mx, order)
    local rowH=math.floor(48*SCALE)
    local row=Fr(page,UDim2.new(1,0,0,rowH),nil,C.Bg2)
    corner(row,4) row.LayoutOrder=order

    local lbl=Tx(row,"  "..labelTxt,FS_SM,C.White,false)
    lbl.Size=UDim2.new(0.65,0,0,math.floor(18*SCALE))
    lbl.Position=UDim2.new(0,0,0,4)

    local valL=Tx(row,tostring(S[key]),FS_SM,C.Red,true,Enum.TextXAlignment.Right)
    valL.Size=UDim2.new(0.32,0,0,math.floor(18*SCALE))
    valL.Position=UDim2.new(0.67,-4,0,4)

    local pad=math.floor(8*SCALE)
    local trackH=math.floor(5*SCALE)
    local trkBg=Fr(row,UDim2.new(1,-pad*2,0,trackH),
        UDim2.new(0,pad,0,rowH-math.floor(14*SCALE)),C.Bg3)
    corner(trkBg,trackH)

    local pct=(S[key]-mn)/(mx-mn)
    local fill=Fr(trkBg,UDim2.new(pct,0,1,0),nil,C.Red) corner(fill,trackH)

    local dotS=math.floor(14*SCALE)
    local thm=Fr(trkBg,UDim2.new(0,dotS,0,dotS),UDim2.new(pct,-dotS/2,0.5,-dotS/2),C.White)
    corner(thm,dotS)

    local sliding=false
    local hitZ=Btn(row,"",UDim2.new(1,0,0,math.floor(20*SCALE)),
        UDim2.new(0,0,1,-math.floor(22*SCALE)))
    hitZ.BackgroundTransparency=1 hitZ.ZIndex=8
    hitZ.MouseButton1Down:Connect(function() sliding=true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
    UIS.InputChanged:Connect(function(i)
        if not sliding or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local rel=math.clamp((i.Position.X-trkBg.AbsolutePosition.X)/trkBg.AbsoluteSize.X,0,1)
        local nv=math.floor(mn+rel*(mx-mn))
        S[key]=nv
        fill.Size=UDim2.new(rel,0,1,0)
        thm.Position=UDim2.new(rel,-dotS/2,0.5,-dotS/2)
        valL.Text=tostring(nv)
    end)
end

-- ─── FLOATING UI (Logo popup) ─────────────────────────────────
local floats={}
local function mkFloat(featName, key)
    if floats[key] then floats[key]:Destroy() floats[key]=nil return end
    local fg=Instance.new("ScreenGui")
    fg.Name="Float_"..key fg.ResetOnSpawn=false
    fg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling fg.Parent=PGui
    floats[key]=fg

    local fw_w=math.floor(180*SCALE)
    local fw=Fr(fg,UDim2.new(0,fw_w,0,math.floor(68*SCALE)),
        UDim2.new(0,90,0.42,0),C.Bg0)
    corner(fw,6) stroke(fw,C.DGray,1)

    -- grey header
    local fhdr=Fr(fw,UDim2.new(1,0,0,math.floor(26*SCALE)),nil,C.DGray)
    corner(fhdr,5)
    local fhl=Tx(fhdr,"  "..featName,FS_SM,C.White,true,Enum.TextXAlignment.Center)
    fhl.Size=UDim2.new(1,0,1,0)
    draggable(fhdr,fw)

    -- black toggle row
    local frow=Fr(fw,UDim2.new(1,0,0,math.floor(36*SCALE)),
        UDim2.new(0,0,0,math.floor(26*SCALE)),C.Bg0)

    local fl=Tx(frow,"  "..featName,FS_SM,C.White,false)
    fl.Size=UDim2.new(1,-54,1,0)

    local pillW=math.floor(40*SCALE) local pillH=math.floor(20*SCALE)
    local dotS=math.floor(14*SCALE)
    local fpb=Fr(frow,UDim2.new(0,pillW,0,pillH),
        UDim2.new(1,-pillW-6,0.5,-pillH/2),S[key] and C.Red or C.DGray)
    corner(fpb,pillH)
    local fpd=Fr(fpb,UDim2.new(0,dotS,0,dotS),
        UDim2.new(0,3,0.5,-dotS/2),C.White) corner(fpd,dotS)

    local function fref(val)
        TS:Create(fpb,TweenInfo.new(0.12),{BackgroundColor3=val and C.Red or C.DGray}):Play()
        TS:Create(fpd,TweenInfo.new(0.12),{Position=val and UDim2.new(1,-dotS-3,0.5,-dotS/2) or UDim2.new(0,3,0.5,-dotS/2)}):Play()
    end
    fref(S[key])

    local fhit=Btn(frow,"",UDim2.new(1,0,1,0)) fhit.BackgroundTransparency=1 fhit.ZIndex=9
    fhit.MouseButton1Click:Connect(function()
        S[key]=not S[key] fref(S[key]) onToggle(key,S[key])
    end)
    tCB[key]=tCB[key] or {} table.insert(tCB[key],fref)
end

-- Logo sub-row builder
local function mkLogoRow(page, featName, key, order)
    local row=Fr(page,UDim2.new(1,0,0,ROW_H),nil,C.Bg3)
    corner(row,4) row.LayoutOrder=order
    row.MouseEnter:Connect(function() row.BackgroundColor3=Fr(nil).BackgroundColor3 end)

    local lbl=Tx(row,"  "..featName.." Logo",FS_SM,C.Gray,false)
    lbl.Size=UDim2.new(1,-50,1,0)

    local logoB=Btn(row,"⊞",UDim2.new(0,math.floor(36*SCALE),0,math.floor(22*SCALE)),
        UDim2.new(1,-42,0.5,-11),C.Bg1)
    corner(logoB,4) stroke(logoB,C.DGray,1)
    logoB.TextColor3=C.Red logoB.TextSize=math.floor(15*SCALE) logoB.ZIndex=9
    logoB.MouseButton1Click:Connect(function() mkFloat(featName,key) end)
end

-- ─── DROPDOWN ─────────────────────────────────────────────────
local ddFrame=nil
local function mkDropdown(page, order)
    local row=Fr(page,UDim2.new(1,0,0,ROW_H),nil,C.Bg2)
    corner(row,4) row.LayoutOrder=order

    local lbl=Tx(row,"  Select Target",FS_SM,C.White,false)
    lbl.Size=UDim2.new(0.52,0,1,0)

    local ddW=math.floor(110*SCALE)
    local ddB=Btn(row,S.SelectedTarget or "None  ▾",
        UDim2.new(0,ddW,0,math.floor(22*SCALE)),
        UDim2.new(1,-ddW-6,0.5,-11),C.Bg3)
    corner(ddB,4) stroke(ddB,C.DGray,1)
    ddB.TextColor3=C.Gray ddB.TextSize=FS_SM ddB.ZIndex=8

    ddB.MouseButton1Click:Connect(function()
        if ddFrame then ddFrame:Destroy() ddFrame=nil return end
        ddFrame=Fr(mainSG,UDim2.new(0,ddW+10,0,0),nil,C.Bg1)
        corner(ddFrame,4) stroke(ddFrame,C.DGray,1)
        ddFrame.AutomaticSize=Enum.AutomaticSize.Y ddFrame.ZIndex=20
        local ap=ddB.AbsolutePosition
        ddFrame.Position=UDim2.new(0,ap.X,0,ap.Y+math.floor(26*SCALE))

        local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder ul.Parent=ddFrame
        local ct=0
        for _,p in ipairs(Plrs:GetPlayers()) do
            if p==LP then continue end ct=ct+1
            local ib=Btn(ddFrame,"  "..p.Name,UDim2.new(1,0,0,math.floor(26*SCALE)))
            ib.TextXAlignment=Enum.TextXAlignment.Left ib.TextSize=FS_SM ib.LayoutOrder=ct ib.ZIndex=21
            ib.MouseButton1Click:Connect(function()
                S.SelectedTarget=p.Name ddB.Text=p.Name.."  ▾" ddB.TextColor3=C.Red
                ddFrame:Destroy() ddFrame=nil end)
        end
        if ct==0 then local n=Tx(ddFrame,"  No players",FS_SM,C.Gray) n.Size=UDim2.new(1,0,0,math.floor(26*SCALE)) end
    end)
end

-- ─── AUTO FLY UI ──────────────────────────────────────────────
local afGui=nil local afBV=nil
local function mkAutoFlyUI()
    if afGui then afGui:Destroy() afGui=nil S.AutoFlyStep=0
        if afBV then afBV:Destroy() afBV=nil end
        local h=getHum and getHum() if h then h.PlatformStand=false end return end

    afGui=Instance.new("ScreenGui") afGui.Name="AutoFlyUI"
    afGui.ResetOnSpawn=false afGui.Parent=PGui

    local afw=Fr(afGui,UDim2.new(0,math.floor(200*SCALE),0,math.floor(90*SCALE)),
        UDim2.new(0,90,0.65,0),C.Bg0)
    corner(afw,6) stroke(afw,C.Red,1)

    local ahdr=Fr(afw,UDim2.new(1,0,0,math.floor(28*SCALE)),nil,C.DGray) corner(ahdr,5)
    local ahl=Tx(ahdr,"  Auto Fly",FS_SM,C.White,true,Enum.TextXAlignment.Center)
    ahl.Size=UDim2.new(1,0,1,0) draggable(ahdr,afw)

    local stepL=Tx(afw,"Ready",FS_SM,C.Gray,false,Enum.TextXAlignment.Center)
    stepL.Size=UDim2.new(1,0,0,math.floor(20*SCALE))
    stepL.Position=UDim2.new(0,0,0,math.floor(30*SCALE))

    local cb=Btn(afw,"Click 1 — Set Position",
        UDim2.new(1,-12,0,math.floor(26*SCALE)),
        UDim2.new(0,6,0,math.floor(56*SCALE)),C.Red)
    corner(cb,4) cb.TextSize=FS_SM

    local steps={
        [0]={b="Click 1 — Set Position",l="Ready"},
        [1]={b="Click 2 — Start Flying",l="Step 1: Position Set"},
        [2]={b="Click 3 — Lock Position",l="Step 2: Flying Up..."},
        [3]={b="Locked ✓",l="Step 3: Locked"},
    }
    local function upd() local d=steps[S.AutoFlyStep] if d then cb.Text=d.b stepL.Text=d.l end end

    cb.MouseButton1Click:Connect(function()
        local char=LP.Character local root=char and char:FindFirstChild("HumanoidRootPart")
        if not char or not root then return end
        if S.AutoFlyStep==0 then
            S.AutoFlyStep=1
            local h=char:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=true end
            root.CFrame=root.CFrame+Vector3.new(0,1.2,0)
        elseif S.AutoFlyStep==1 then
            S.AutoFlyStep=2
            if afBV then afBV:Destroy() end
            afBV=Instance.new("BodyVelocity")
            afBV.Velocity=Vector3.new(0,S.SpeedFly*6,0) afBV.MaxForce=Vector3.new(0,1e6,0)
            afBV.Parent=root
        elseif S.AutoFlyStep==2 then
            S.AutoFlyStep=3
            if afBV then afBV:Destroy() afBV=nil end
            local bp=Instance.new("BodyPosition")
            bp.Position=root.Position bp.MaxForce=Vector3.new(1e6,1e6,1e6)
            bp.D=600 bp.P=12000 bp.Parent=root afBV=bp
        end
        upd()
    end)
end

-- ─── BUILD SIDEBAR + PAGES ────────────────────────────────────
local tabUL=Instance.new("UIListLayout") tabUL.SortOrder=Enum.SortOrder.LayoutOrder
tabUL.Padding=UDim.new(0,2) tabUL.Parent=sidebar
local tabPad=Instance.new("UIPadding")
tabPad.PaddingTop=UDim.new(0,6) tabPad.PaddingLeft=UDim.new(0,4) tabPad.PaddingRight=UDim.new(0,4)
tabPad.Parent=sidebar

local pages={} local tabBtns={} local activeTab=""

local function switchTab(name)
    activeTab=name
    for n,pg in pairs(pages) do pg.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        if n==name then
            b.BackgroundColor3=C.Red b.TextColor3=C.White
        else
            b.BackgroundColor3=C.Bg2 b.TextColor3=C.Gray
        end
    end
end

local tabDefs={"Function","Aim","Esp","Fly/Tele","Misc"}
for i,tname in ipairs(tabDefs) do
    local pg=mkPage() pages[tname]=pg
    local tb=Btn(sidebar,tname,UDim2.new(1,0,0,math.floor(36*SCALE)),nil,C.Bg2)
    corner(tb,4) tb.TextSize=FS_SM tb.TextColor3=C.Gray tb.LayoutOrder=i
    tabBtns[tname]=tb
    tb.MouseButton1Click:Connect(function() switchTab(tname) end)
end

-- ─── PAGE: FUNCTION ───────────────────────────────────────────
local pF=pages["Function"]
secHdr(pF,"Function",1)
mkToggle(pF,"Enable Function","EnableFunction",2)
mkToggle(pF,"Enable Aim","EnableAim",3)
mkToggle(pF,"Enable Esp","EnableEsp",4)

local div0=Fr(pF,UDim2.new(1,0,0,1),nil,C.DGray) div0.LayoutOrder=5

local infoF=Fr(pF,UDim2.new(1,0,0,math.floor(108*SCALE)),nil,C.Bg2)
corner(infoF,5) infoF.LayoutOrder=6
local ip=Instance.new("UIPadding") ip.PaddingLeft=UDim.new(0,8) ip.PaddingTop=UDim.new(0,6) ip.PaddingRight=UDim.new(0,8) ip.Parent=infoF
local i1=Tx(infoF,"Release Version Official.  | Details",FS_SM,C.Red,true)
i1.Size=UDim2.new(1,0,0,math.floor(16*SCALE)) i1.Position=UDim2.new(0,0,0,0)
local i2=Instance.new("TextLabel") i2.Size=UDim2.new(1,0,0,math.floor(34*SCALE)) i2.Position=UDim2.new(0,0,0,math.floor(20*SCALE))
i2.BackgroundTransparency=1 i2.Text="SantaXMods has been released with the official version."
i2.TextColor3=C.Gray i2.TextSize=FS_SM i2.Font=Enum.Font.Gotham
i2.TextXAlignment=Enum.TextXAlignment.Left i2.TextYAlignment=Enum.TextYAlignment.Top
i2.TextWrapped=true i2.Parent=infoF
local function irow(txt,y) local l=Tx(infoF,txt,FS_SM-1,C.Gray) l.Size=UDim2.new(1,0,0,math.floor(14*SCALE)) l.Position=UDim2.new(0,0,0,math.floor(y*SCALE)) return l end
irow("Developer: SkyFlow",58) irow("Youtube: @Skyflowh4x   Tiktok: @Sky.flow77",72) irow("Version: 1.12",86)

-- ─── PAGE: AIM ────────────────────────────────────────────────
local pA=pages["Aim"]
secHdr(pA,"Aim Function",1)
mkToggle(pA,"Aimbot","Aimbot",2)
mkToggle(pA,"Aim Assist","AimAssist",3)
mkToggle(pA,"Aim Silent","AimSilent",4)
mkLogoRow(pA,"Aim Silent","AimSilent",5)
mkToggle(pA,"Aim Magnet","AimMagnet",6)
mkLogoRow(pA,"Aim Magnet","AimMagnet",7)
mkToggle(pA,"AutoKill","AutoKill",8)
mkLogoRow(pA,"AutoKill","AutoKill",9)
mkToggle(pA,"Aim Visible","AimVisible",10)
mkSlider(pA,"Aim FOV","AimFov",0,360,11)

-- ─── PAGE: ESP ────────────────────────────────────────────────
local pE=pages["Esp"]
secHdr(pE,"Esp Function",1)
mkToggle(pE,"Esp Line","EspLine",2)
mkToggle(pE,"Esp Box","EspBox",3)
mkToggle(pE,"Esp Box 3D","EspBox3D",4)
mkToggle(pE,"Esp Health","EspHealth",5)
mkToggle(pE,"Esp Name","EspName",6)
mkToggle(pE,"Esp Distance","EspDistance",7)
mkToggle(pE,"Esp Skeleton","EspSkeleton",8)
mkToggle(pE,"Esp Fov","EspFov",9)

-- ─── PAGE: FLY/TELE ───────────────────────────────────────────
local pFT=pages["Fly/Tele"]
secHdr(pFT,"Fly Function",1)
mkToggle(pFT,"Fly","Fly",2)
-- Auto Fly row (logo style)
local afRow=Fr(pFT,UDim2.new(1,0,0,ROW_H),nil,C.Bg3) corner(afRow,4) afRow.LayoutOrder=3
local afL=Tx(afRow,"  Auto Fly",FS_MED,C.White,false) afL.Size=UDim2.new(1,-50,1,0)
local afLB=Btn(afRow,"⊞",UDim2.new(0,math.floor(36*SCALE),0,math.floor(22*SCALE)),
    UDim2.new(1,-42,0.5,-11),C.Bg1)
corner(afLB,4) stroke(afLB,C.DGray,1) afLB.TextColor3=C.Red
afLB.TextSize=math.floor(15*SCALE) afLB.ZIndex=9
afLB.MouseButton1Click:Connect(mkAutoFlyUI)
mkToggle(pFT,"Hit Fly","HitFly",4)
mkSlider(pFT,"Speed Fly","SpeedFly",1,10,5)
mkSlider(pFT,"High Hit Fly (m)","HighHitFly",0,100,6)
mkSlider(pFT,"Speed Hit Fly (m)","SpeedHitFly",0,150,7)
local dv1=Fr(pFT,UDim2.new(1,0,0,1),nil,C.DGray) dv1.LayoutOrder=8
secHdr(pFT,"Teleport Function",9)
mkToggle(pFT,"Teleport Player","TeleportPlayer",10)
mkToggle(pFT,"TeleKill","TeleKill",11)
mkLogoRow(pFT,"TeleKill","TeleKill",12)
mkDropdown(pFT,13)

-- ─── PAGE: MISC ───────────────────────────────────────────────
local pM=pages["Misc"]
secHdr(pM,"Misc Function",1)
mkToggle(pM,"SpeedHack","SpeedHack",2)
mkToggle(pM,"JumpHack","JumpHack",3)
mkToggle(pM,"GhostHack","GhostHack",4)

switchTab("Function")

-- ─── ESP SYSTEM ───────────────────────────────────────────────
local espSG=Instance.new("ScreenGui")
espSG.Name="SantaXEsp" espSG.ResetOnSpawn=false
espSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling espSG.Parent=PGui

local eObj={}
local function clrEsp(p) if eObj[p] then for _,o in pairs(eObj[p]) do if o and o.Parent then o:Destroy() end end eObj[p]=nil end end

-- LINE BETWEEN 2 SCREEN POINTS
local function drawLine(parent, x0,y0, x1,y1, col, thick)
    local dx=x1-x0 local dy=y1-y0
    local len=math.sqrt(dx*dx+dy*dy)
    local ang=math.deg(math.atan2(dy,dx))
    local f=Instance.new("Frame")
    f.BackgroundColor3=col or C.White f.BorderSizePixel=0
    f.Size=UDim2.new(0,len,0,thick or 1)
    f.Position=UDim2.new(0,x0,0,y0)
    f.Rotation=ang f.AnchorPoint=Vector2.new(0,0.5)
    f.Parent=parent return f
end

local function drawEsp(player)
    if not player.Character then clrEsp(player) return end
    local c=player.Character
    local root=c:FindFirstChild("HumanoidRootPart")
    local head=c:FindFirstChild("Head")
    local hum=c:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health<=0 then clrEsp(player) return end

    local sp,vis=Cam:WorldToViewportPoint(root.Position)
    if not vis then clrEsp(player) return end

    eObj[player]=eObj[player] or {}
    local o=eObj[player]

    -- Get 2D bounding corners via head+feet
    local hpos=(head and Cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.75,0))) or sp
    local fpos=Cam:WorldToViewportPoint(root.Position-Vector3.new(0,2.8,0))
    local boxH=math.abs(fpos.Y-hpos.Y)
    local boxW=boxH*0.45
    local cx=sp.X
    local top=math.min(hpos.Y,fpos.Y)

    local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local dist=mr and math.floor((mr.Position-root.Position).Magnitude) or 0

    -- ESP BOX
    if S.EspBox then
        if not o.box then
            o.box=Instance.new("Frame")
            o.box.BackgroundTransparency=1 o.box.BorderSizePixel=2
            o.box.BorderColor3=C.White o.box.Parent=espSG end
        o.box.Position=UDim2.new(0,cx-boxW/2,0,top)
        o.box.Size=UDim2.new(0,boxW,0,boxH)
    elseif o.box then o.box:Destroy() o.box=nil end

    -- ESP NAME
    if S.EspName then
        if not o.name then
            o.name=Instance.new("TextLabel") o.name.BackgroundTransparency=1
            o.name.TextColor3=C.Red o.name.TextSize=math.floor(12*SCALE)
            o.name.Font=Enum.Font.GothamBold o.name.Parent=espSG end
        o.name.Text=player.Name
        o.name.Size=UDim2.new(0,120,0,16)
        o.name.Position=UDim2.new(0,cx-60,0,top-18)
    elseif o.name then o.name:Destroy() o.name=nil end

    -- ESP DISTANCE
    if S.EspDistance then
        if not o.dist then
            o.dist=Instance.new("TextLabel") o.dist.BackgroundTransparency=1
            o.dist.TextColor3=C.Red o.dist.TextSize=math.floor(11*SCALE)
            o.dist.Font=Enum.Font.Gotham o.dist.Parent=espSG end
        o.dist.Text=dist.."m"
        o.dist.Size=UDim2.new(0,60,0,14)
        o.dist.Position=UDim2.new(0,cx-30,0,top+boxH+3)
    elseif o.dist then o.dist:Destroy() o.dist=nil end

    -- ESP HEALTH BAR (side)
    if S.EspHealth then
        if not o.hbg then
            o.hbg=Instance.new("Frame") o.hbg.BackgroundColor3=Color3.fromRGB(30,30,30)
            o.hbg.BorderSizePixel=0 o.hbg.Parent=espSG
            o.hfill=Instance.new("Frame") o.hfill.BackgroundColor3=C.Green
            o.hfill.BorderSizePixel=0 o.hfill.Parent=o.hbg end
        local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
        o.hbg.Size=UDim2.new(0,4,0,boxH)
        o.hbg.Position=UDim2.new(0,cx-boxW/2-7,0,top)
        o.hfill.Size=UDim2.new(1,0,hp,0)
        o.hfill.Position=UDim2.new(0,0,1-hp,0)
    elseif o.hbg then o.hbg:Destroy() o.hbg=nil end

    -- ESP LINE (screen center top → enemy)
    if S.EspLine then
        if o.line then o.line:Destroy() o.line=nil end
        local vp2=Cam.ViewportSize
        local mx=vp2.X/2 local my=0
        o.line=drawLine(espSG, mx,my, cx,sp.Y, C.White,1)
    elseif o.line then o.line:Destroy() o.line=nil end

    -- ESP SKELETON
    if S.EspSkeleton then
        if not o.skel then o.skel={} end
        local bones={
            {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
            {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
            {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
            {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
            {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
        }
        for bi,bone in ipairs(bones) do
            local p0=c:FindFirstChild(bone[1]) local p1=c:FindFirstChild(bone[2])
            if p0 and p1 then
                local s0,v0=Cam:WorldToViewportPoint(p0.Position)
                local s1,v1=Cam:WorldToViewportPoint(p1.Position)
                if v0 and v1 then
                    if o.skel[bi] then o.skel[bi]:Destroy() end
                    o.skel[bi]=drawLine(espSG,s0.X,s0.Y,s1.X,s1.Y,C.Red,1)
                end
            end
        end
    elseif o.skel then
        for _,l in ipairs(o.skel) do if l and l.Parent then l:Destroy() end end
        o.skel=nil
    end
end

-- ESP FOV circle
local fovCircle=Instance.new("Frame")
fovCircle.BackgroundTransparency=1 fovCircle.BorderSizePixel=2
fovCircle.BorderColor3=C.Red fovCircle.AnchorPoint=Vector2.new(0.5,0.5)
fovCircle.Visible=false fovCircle.Parent=espSG
corner(fovCircle,999)

-- ─── AIM FUNCTIONS ────────────────────────────────────────────
local function isAim() return S.EnableFunction and S.EnableAim end
local function isEsp() return S.EnableFunction and S.EnableEsp end

-- Get closest enemy in FOV
local function getEnemy(fov,part)
    local best,bd=nil,fov
    local mouse=UIS:GetMouseLocation()
    for _,p in ipairs(Plrs:GetPlayers()) do
        if p==LP then continue end
        if S.TeamCheck and p.Team==LP.Team then continue end
        local c=p.Character if not c then continue end
        local t=c:FindFirstChild(part or "Head") or c:FindFirstChild("HumanoidRootPart")
        if not t then continue end
        local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
        if S.AimVisible then
            local ray=Ray.new(Cam.CFrame.Position,(t.Position-Cam.CFrame.Position).Unit*800)
            local hit=workspace:FindPartOnRayWithIgnoreList(ray,{LP.Character,workspace.Terrain})
            if not (hit and hit:IsDescendantOf(c)) then continue end
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
    local t=getEnemy(S.AimFov,"Head") if not t then return end
    silOrig=Cam.CFrame silShot=true
    Cam.CFrame=CFrame.new(Cam.CFrame.Position,t.Position)
    task.defer(function()
        task.wait()
        if silOrig and silShot then Cam.CFrame=silOrig silOrig=nil silShot=false end
    end)
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        if silOrig then Cam.CFrame=silOrig silOrig=nil silShot=false end end
end)

-- Fly engine
local flyBV=nil
local function enFly()
    local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") if not root then return end
    local h=LP.Character:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=true end
    if flyBV then flyBV:Destroy() end
    flyBV=Instance.new("BodyVelocity")
    flyBV.Velocity=Vector3.zero flyBV.MaxForce=Vector3.new(1e5,1e5,1e5) flyBV.Parent=root
end
local function disFly()
    local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand=false end
    if flyBV then flyBV:Destroy() flyBV=nil end
end

-- Ghost engine
local gSaved={}
local function applyGhost(char,on)
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if on then gSaved[p]=p.LocalTransparencyModifier p.LocalTransparencyModifier=p.Name=="HumanoidRootPart" and 0 or 1
            elseif gSaved[p]~=nil then p.LocalTransparencyModifier=gSaved[p] end
        end
    end
    if not on then gSaved={} end
end

-- TeleKill loop
local tkRunning=false
local function doTK()
    if tkRunning then return end tkRunning=true
    task.spawn(function()
        while S.TeleKill and isAim() do
            local target
            if S.SelectedTarget then target=Plrs:FindFirstChild(S.SelectedTarget) end
            if not target then
                local bd,bt=9999,nil
                for _,p in ipairs(Plrs:GetPlayers()) do
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
            task.wait(0.6)
        end
        tkRunning=false
    end)
end

-- ─── MAIN LOOP ────────────────────────────────────────────────
RS.RenderStepped:Connect(function()
    local aim=isAim() local esp=isEsp()
    local mouse=UIS:GetMouseLocation()
    local char=LP.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")

    -- AIM MAGNET
    if aim and S.AimMagnet and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=getEnemy(S.AimFov,"Head")
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.18) end
    end

    -- AIMBOT
    if aim and S.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=getEnemy(S.AimFov,"Head")
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.45) end
    end

    -- AIM ASSIST
    if aim and S.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=getEnemy(S.AimFov,"HumanoidRootPart")
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.07) end
    end

    -- AUTOKILL (all in FOV)
    if aim and S.AutoKill then
        for _,p in ipairs(Plrs:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character if not c then continue end
            local r2=c:FindFirstChild("HumanoidRootPart") if not r2 then continue end
            local sp,vis=Cam:WorldToViewportPoint(r2.Position) if not vis then continue end
            if (Vector2.new(sp.X,sp.Y)-mouse).Magnitude<=S.AimFov then
                local hm=c:FindFirstChildOfClass("Humanoid") if hm then hm.Health=0 end
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
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
        if flyBV then flyBV.Velocity=dir*(S.SpeedFly*9) end
    else
        if flyBV then disFly() end
    end

    -- MISC
    if hum then
        hum.WalkSpeed=S.SpeedHack and 90 or 16
        hum.JumpPower=S.JumpHack and 130 or 50
    end

    -- GHOST
    if char then
        if S.GhostHack then applyGhost(char,true)
        elseif next(gSaved)~=nil then applyGhost(char,false) end
    end

    -- ESP
    for _,p in ipairs(Plrs:GetPlayers()) do
        if p==LP then continue end
        if esp and (S.EspBox or S.EspName or S.EspDistance or S.EspHealth or S.EspLine or S.EspSkeleton) then
            drawEsp(p)
        else clrEsp(p) end
    end

    -- FOV CIRCLE
    if esp and S.EspFov then
        fovCircle.Visible=true
        fovCircle.Position=UDim2.new(0,mouse.X,0,mouse.Y)
        fovCircle.Size=UDim2.new(0,S.AimFov*2,0,S.AimFov*2)
    else fovCircle.Visible=false end
end)

-- Teleport Player key (P)
UIS.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode==Enum.KeyCode.P and S.TeleportPlayer then
        local target=S.SelectedTarget and Plrs:FindFirstChild(S.SelectedTarget)
        if target then
            local tc=target.Character
            local tr=tc and tc:FindFirstChild("HumanoidRootPart")
            local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if tr and mr then mr.CFrame=tr.CFrame*CFrame.new(0,0,-2) end
        end
    end
end)

Plrs.PlayerRemoving:Connect(clrEsp)

print("[ SantaXModsKng v1.12 ] Loaded — SkyFlow")
