--[[
  SantaXModsKng.lua | v1.12
  Developer : SkyFlow | Youtube: @Skyflowh4x | Tiktok: @Sky.flow77
  UI Style  : P2077KNG exact clone
]]

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TS         = game:GetService("TweenService")
local LP         = Players.LocalPlayer
local Cam        = workspace.CurrentCamera
local PGui       = LP:WaitForChild("PlayerGui")

for _,g in ipairs(PGui:GetChildren()) do
    if g.Name:find("SantaX") or g.Name:find("Float_") or g.Name:find("AutoFly") then g:Destroy() end
end

-- ── STATE ─────────────────────────────────────────────────
local S = {
    EnableFunction=false, EnableAim=false, EnableEsp=false,
    AimTarget="Head", AimFov=150,
    Aimbot=false, AimAssist=false, AimSilent=false,
    AutoFire=false, AutoKillFix=false, AutoKillToggle=false,
    AimSilentToggle=false, AimVisible=false, AimMagnet=false,
    EspLine=false, EspBox=false, EspBox3D=false, EspHealth=false,
    EspName=false, EspDistance=false, EspSkeleton=false, EspFov=false,
    Fly=false, AutoFlyStep=0, HitFly=false,
    SpeedFly=5, HighHitFly=50, SpeedHitFly=75,
    TeleportPlayer=false, TeleKill=false, SelectedTarget=nil,
    SpeedHack=false, JumpHack=false, GhostHack=false,
    TeamCheck=true,
}

-- ── P2077KNG EXACT COLORS ─────────────────────────────────
local RED      = Color3.fromRGB(212, 30, 30)   -- merah P2077KNG
local RED_DIM  = Color3.fromRGB(160, 18, 18)
local BG_WIN   = Color3.fromRGB(10,  10,  10)  -- hitam utama
local BG_SIDE  = Color3.fromRGB(16,  16,  16)  -- sidebar gelap
local BG_ROW   = Color3.fromRGB(20,  20,  20)  -- baris konten
local BG_ROW_H = Color3.fromRGB(28,  28,  28)  -- hover
local BG_DD    = Color3.fromRGB(22,  22,  22)  -- dropdown bg
local BG_TRACK = Color3.fromRGB(48,  48,  48)  -- slider track kosong
local COL_WHITE= Color3.fromRGB(238, 238, 238)
local COL_GRAY = Color3.fromRGB(148, 148, 148)
local COL_DGRAY= Color3.fromRGB(64,  64,  64)
local COL_GREEN= Color3.fromRGB(42,  200, 72)

-- ── SCALE ─────────────────────────────────────────────────
local VP    = Cam.ViewportSize
local BASE  = math.max(VP.X, VP.Y)
local SC    = math.clamp(BASE / 1366, 0.78, 1.55)
-- Box dimensions — lebih compact seperti P2077KNG
local BW    = math.floor(420 * SC)
local BH    = math.floor(480 * SC)
local SW    = math.floor(105 * SC)   -- sidebar width
local TH    = math.floor(34  * SC)   -- title bar height
local RH    = math.floor(30  * SC)   -- row height
local FST   = math.floor(12  * SC)   -- font title
local FSM   = math.floor(11  * SC)   -- font medium
local FSS   = math.floor(10  * SC)   -- font small
local PW    = math.floor(36  * SC)   -- pill width
local PH    = math.floor(18  * SC)   -- pill height
local PD    = math.floor(13  * SC)   -- pill dot size
local PAD   = math.floor(6   * SC)

-- ── BASE HELPERS ──────────────────────────────────────────
local function Rnd(p,r) local o=Instance.new("UICorner") o.CornerRadius=UDim.new(0,r or 3) o.Parent=p end
local function Str(p,c,t)
    local o=Instance.new("UIStroke") o.Color=c o.Thickness=t or 1
    o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border o.Parent=p
end
local function Fr(par,sz,pos,bg,alpha)
    local f=Instance.new("Frame")
    f.Size=sz or UDim2.new(1,0,0,RH) f.Position=pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3=bg or BG_ROW f.BackgroundTransparency=alpha or 0
    f.BorderSizePixel=0 f.ClipsDescendants=false f.Parent=par return f
end
local function Tx(par,txt,fs,col,bold,xa)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
    l.Text=txt or "" l.TextSize=fs or FSM
    l.TextColor3=col or COL_WHITE
    l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.TextTruncate=Enum.TextTruncate.AtEnd l.Parent=par return l
end
local function Btn(par,txt,sz,pos,bg)
    local b=Instance.new("TextButton")
    b.Size=sz or UDim2.new(1,0,0,RH) b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=bg or BG_ROW b.BorderSizePixel=0
    b.Text=txt or "" b.TextColor3=COL_WHITE b.TextSize=FSM
    b.Font=Enum.Font.GothamBold b.AutoButtonColor=false b.Parent=par return b
end

-- ── DRAG ──────────────────────────────────────────────────
local function MakeDrag(handle, target)
    local on,ds,dp=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            on=true ds=Vector2.new(i.Position.X,i.Position.Y) dp=target.Position end
    end)
    UIS.InputChanged:Connect(function(i)
        if not on then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=Vector2.new(i.Position.X,i.Position.Y)-ds
            target.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=false end
    end)
end

-- ── TOGGLE SYNC ───────────────────────────────────────────
local TCB={}
local function Fire(k,v) if TCB[k] then for _,fn in ipairs(TCB[k]) do pcall(fn,v) end end end
local function Reg(k,fn) TCB[k]=TCB[k] or {} table.insert(TCB[k],fn) end

-- ── FLOATING ICON ─────────────────────────────────────────
local iconSG=Instance.new("ScreenGui")
iconSG.Name="SantaXIcon" iconSG.ResetOnSpawn=false
iconSG.DisplayOrder=1000 iconSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling iconSG.Parent=PGui
local ISIZ=math.floor(54*SC)
local iconImg=Instance.new("ImageButton")
iconImg.Size=UDim2.new(0,ISIZ,0,ISIZ) iconImg.Position=UDim2.new(0,14,0.5,-ISIZ/2)
iconImg.BackgroundTransparency=1 iconImg.Image="rbxassetid://104012475483632"
iconImg.Visible=false iconImg.ZIndex=10 iconImg.Parent=iconSG
Rnd(iconImg,ISIZ) MakeDrag(iconImg,iconImg)

-- ── MAIN WINDOW ───────────────────────────────────────────
local mainSG=Instance.new("ScreenGui")
mainSG.Name="SantaXMain" mainSG.ResetOnSpawn=false
mainSG.DisplayOrder=999 mainSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling mainSG.Parent=PGui

local win=Fr(mainSG,UDim2.new(0,BW,0,BH+TH),UDim2.new(0.5,-BW/2,0.5,-(BH+TH)/2),BG_WIN)
Rnd(win,5)
-- Border merah tipis seperti P2077KNG
Str(win,RED,1)

-- ── TITLE BAR (persis P2077KNG) ───────────────────────────
local tbar=Fr(win,UDim2.new(1,0,0,TH),UDim2.new(0,0,0,0),BG_WIN)
Rnd(tbar,5)
-- Garis merah di bawah title bar
local tline=Fr(tbar,UDim2.new(1,0,0,math.floor(2*SC)),UDim2.new(0,0,1,-math.floor(2*SC)),RED)

-- Arrow ▼
local arrowB=Btn(tbar,"▼",UDim2.new(0,math.floor(22*SC),1,-math.floor(4*SC)),
    UDim2.new(0,math.floor(6*SC),0,math.floor(2*SC)),BG_WIN)
arrowB.TextColor3=RED arrowB.TextSize=FSM arrowB.ZIndex=6

-- Title text
local titleTx=Tx(tbar,"SantaXModsKng  v1.12",FST,COL_WHITE,true)
titleTx.Size=UDim2.new(1,-math.floor(70*SC),1,0)
titleTx.Position=UDim2.new(0,math.floor(28*SC),0,0)

-- Close X
local closeX=Btn(tbar,"X",UDim2.new(0,math.floor(28*SC),0,math.floor(22*SC)),
    UDim2.new(1,-math.floor(32*SC),0.5,-math.floor(11*SC)),BG_WIN)
closeX.TextColor3=COL_WHITE closeX.TextSize=FST closeX.ZIndex=7

-- Drag
MakeDrag(tbar,win)

-- ── BODY ──────────────────────────────────────────────────
local body=Fr(win,UDim2.new(1,0,1,-TH),UDim2.new(0,0,0,TH),BG_WIN)

-- Sidebar
local sidebar=Fr(body,UDim2.new(0,SW,1,0),nil,BG_SIDE)
-- Garis kanan sidebar
local sline=Fr(sidebar,UDim2.new(0,math.floor(1*SC),1,0),UDim2.new(1,0,0,0),RED)

-- Content
local CW=BW-SW-1
local contArea=Fr(body,UDim2.new(0,CW,1,0),UDim2.new(0,SW+1,0,0),BG_WIN)

-- Collapse
local collapsed=false
local function setCollapse(v)
    collapsed=v body.Visible=not v
    arrowB.Text=v and "▶" or "▼"
    win.Size=v and UDim2.new(0,BW,0,TH) or UDim2.new(0,BW,0,BH+TH)
end
arrowB.MouseButton1Click:Connect(function() setCollapse(not collapsed) end)
closeX.MouseButton1Click:Connect(function() win.Visible=false iconImg.Visible=true end)
iconImg.MouseButton1Click:Connect(function() iconImg.Visible=false win.Visible=true end)

-- ── SCROLL PAGE ───────────────────────────────────────────
local function MkPage()
    local sf=Instance.new("ScrollingFrame")
    sf.Size=UDim2.new(1,0,1,0) sf.BackgroundTransparency=1 sf.BorderSizePixel=0
    sf.ScrollBarThickness=math.floor(3*SC) sf.ScrollBarImageColor3=RED
    sf.CanvasSize=UDim2.new(0,0,0,0) sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Visible=false sf.Parent=contArea
    local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder
    ul.Padding=UDim.new(0,0) ul.Parent=sf  -- ZERO padding antar row seperti P2077KNG
    local up=Instance.new("UIPadding")
    up.PaddingLeft=UDim.new(0,0) up.PaddingRight=UDim.new(0,0)
    up.PaddingTop=UDim.new(0,math.floor(4*SC)) up.PaddingBottom=UDim.new(0,4)
    up.Parent=sf return sf
end

-- ── SECTION HEADER (P2077KNG style: left red bar thick) ───
local function SecHdr(page,txt,order)
    local h=Fr(page,UDim2.new(1,0,0,math.floor(28*SC)),nil,BG_WIN) h.LayoutOrder=order
    -- LEFT RED BAR tebal (ciri khas P2077KNG)
    local bar=Fr(h,UDim2.new(0,math.floor(4*SC),0.7,0),UDim2.new(0,math.floor(6*SC),0.15,0),RED)
    local lbl=Tx(h,"  "..txt,FST,COL_WHITE,true)
    lbl.Position=UDim2.new(0,math.floor(16*SC),0,0) lbl.Size=UDim2.new(1,0,1,0)
    return h
end

-- ── PILL TOGGLE (P2077KNG exact) ──────────────────────────
local function MkToggle(page,lTxt,key,order)
    local row=Fr(page,UDim2.new(1,0,0,RH),nil,BG_WIN) row.LayoutOrder=order

    row.MouseEnter:Connect(function() row.BackgroundColor3=BG_ROW_H end)
    row.MouseLeave:Connect(function() row.BackgroundColor3=BG_WIN end)

    -- Teks label
    local lbl=Tx(row,"  "..lTxt,FSM,COL_WHITE,false)
    lbl.Size=UDim2.new(1,-(PW+12),1,0) lbl.Position=UDim2.new(0,0,0,0)

    -- Pill bg
    local pillBg=Fr(row,UDim2.new(0,PW,0,PH),
        UDim2.new(1,-(PW+6),0.5,-PH/2), S[key] and RED or COL_DGRAY)
    Rnd(pillBg,PH)

    -- Pill dot
    local dot=Fr(pillBg,UDim2.new(0,PD,0,PD),
        UDim2.new(0,math.floor(2*SC),0.5,-PD/2),COL_WHITE)
    Rnd(dot,PD)

    local function Refresh(val)
        TS:Create(pillBg,TweenInfo.new(0.1),{BackgroundColor3=val and RED or COL_DGRAY}):Play()
        TS:Create(dot,TweenInfo.new(0.1),{
            Position=val and UDim2.new(1,-(PD+2),0.5,-PD/2) or UDim2.new(0,math.floor(2*SC),0.5,-PD/2)
        }):Play()
    end

    local hit=Btn(row,"",UDim2.new(1,0,1,0)) hit.BackgroundTransparency=1 hit.ZIndex=10
    hit.MouseButton1Click:Connect(function()
        S[key]=not S[key] Refresh(S[key]) Fire(key,S[key])
    end)

    Reg(key,Refresh) return row,Refresh
end

-- ── SMOOTH SLIDER (P2077KNG: track tebal merah solid) ─────
local function MkSlider(page,lTxt,key,mn,mx,order)
    local RHS=math.floor(44*SC)
    local row=Fr(page,UDim2.new(1,0,0,RHS),nil,BG_WIN) row.LayoutOrder=order
    row.MouseEnter:Connect(function() row.BackgroundColor3=BG_ROW_H end)
    row.MouseLeave:Connect(function() row.BackgroundColor3=BG_WIN end)

    -- Label kiri
    local lbl=Tx(row,"  "..lTxt,FSM,COL_WHITE,false)
    lbl.Size=UDim2.new(0.58,0,0,math.floor(18*SC)) lbl.Position=UDim2.new(0,0,0,math.floor(3*SC))

    -- Nilai kanan (P2077KNG: "800.0°")
    local valL=Tx(row,tostring(S[key]).."°",FSM,COL_WHITE,true,Enum.TextXAlignment.Right)
    valL.Size=UDim2.new(0.38,0,0,math.floor(18*SC))
    valL.Position=UDim2.new(0.61,-PAD,0,math.floor(3*SC))

    -- Track bg (P2077KNG: track tebal ~7px, abu gelap)
    local TH2=math.floor(7*SC)
    local padH=math.floor(6*SC)
    local trkBg=Fr(row,UDim2.new(1,-padH*2,0,TH2),
        UDim2.new(0,padH,0,RHS-math.floor(13*SC)),BG_TRACK)
    Rnd(trkBg,TH2)

    -- Fill merah
    local pct=math.clamp((S[key]-mn)/(mx-mn),0,1)
    local fill=Fr(trkBg,UDim2.new(pct,0,1,0),nil,RED) Rnd(fill,TH2)

    -- Thumb bulat putih
    local DT=math.floor(16*SC)
    local thm=Fr(trkBg,UDim2.new(0,DT,0,DT),
        UDim2.new(pct,-DT/2,0.5,-DT/2),COL_WHITE) Rnd(thm,DT)
    Str(thm,COL_DGRAY,1)

    local sliding=false
    local function updateSlider(px)
        local ap=trkBg.AbsolutePosition local as=trkBg.AbsoluteSize
        if as.X==0 then return end
        local rel=math.clamp((px-ap.X)/as.X,0,1)
        local nv=math.floor(mn+rel*(mx-mn))
        S[key]=nv fill.Size=UDim2.new(rel,0,1,0)
        thm.Position=UDim2.new(rel,-DT/2,0.5,-DT/2)
        valL.Text=tostring(nv).."°"
    end

    local function onB(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true updateSlider(i.Position.X) end
    end
    local function onC(i)
        if not sliding then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            updateSlider(i.Position.X) end
    end
    local function onE(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=false end
    end

    local hitZ=Btn(row,"",UDim2.new(1,0,1,0)) hitZ.BackgroundTransparency=1 hitZ.ZIndex=10
    hitZ.InputBegan:Connect(onB) trkBg.InputBegan:Connect(onB)
    thm.InputBegan:Connect(onB) fill.InputBegan:Connect(onB)
    UIS.InputChanged:Connect(onC) UIS.InputEnded:Connect(onE)
end

-- ── DROPDOWN (P2077KNG: full width kotak gelap + ▼ merah) ─
local ddFr=nil
local function MkDropdown(page,key,opts,order)
    local row=Fr(page,UDim2.new(1,0,0,math.floor(28*SC)),nil,BG_WIN)
    row.LayoutOrder=order

    local DDW=math.floor(160*SC)
    local ddB=Btn(row,S[key].."  ▼",
        UDim2.new(0,DDW,0,math.floor(22*SC)),
        UDim2.new(0,math.floor(6*SC),0.5,-math.floor(11*SC)),BG_DD)
    Rnd(ddB,3) Str(ddB,COL_DGRAY,1)
    ddB.TextColor3=COL_WHITE ddB.TextSize=FSM ddB.Font=Enum.Font.GothamBold ddB.ZIndex=10

    ddB.MouseButton1Click:Connect(function()
        if ddFr then ddFr:Destroy() ddFr=nil return end
        ddFr=Fr(mainSG,UDim2.new(0,DDW,0,0),nil,BG_DD)
        Rnd(ddFr,3) Str(ddFr,COL_DGRAY,1)
        ddFr.AutomaticSize=Enum.AutomaticSize.Y ddFr.ZIndex=30
        local ap=ddB.AbsolutePosition
        ddFr.Position=UDim2.new(0,ap.X,0,ap.Y+math.floor(26*SC))
        local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder ul.Parent=ddFr
        for i,opt in ipairs(opts) do
            local ib=Btn(ddFr,"  "..opt,UDim2.new(1,0,0,math.floor(28*SC))) ib.LayoutOrder=i
            ib.TextXAlignment=Enum.TextXAlignment.Left ib.TextSize=FSM ib.BackgroundColor3=BG_DD ib.ZIndex=31
            ib.MouseEnter:Connect(function() ib.BackgroundColor3=BG_ROW_H end)
            ib.MouseLeave:Connect(function() ib.BackgroundColor3=BG_DD end)
            ib.MouseButton1Click:Connect(function()
                S[key]=opt ddB.Text=opt.."  ▼"
                ddFr:Destroy() ddFr=nil end)
        end
    end)
end

-- ── FLOATING LOGO (Logo popup) ────────────────────────────
local floats={}
local function MkFloat(featName,key)
    if floats[key] then floats[key]:Destroy() floats[key]=nil return end
    local fg=Instance.new("ScreenGui") fg.Name="Float_"..key
    fg.ResetOnSpawn=false fg.DisplayOrder=1001 fg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling fg.Parent=PGui
    floats[key]=fg
    local FW=math.floor(175*SC)
    local fw=Fr(fg,UDim2.new(0,FW,0,math.floor(62*SC)),UDim2.new(0,90,0.42,0),BG_WIN)
    Rnd(fw,4) Str(fw,RED,1)
    local fhdr=Fr(fw,UDim2.new(1,0,0,math.floor(24*SC)),nil,BG_SIDE) Rnd(fhdr,4)
    local fhl=Tx(fhdr,"  "..featName,FSS,COL_WHITE,true,Enum.TextXAlignment.Center)
    fhl.Size=UDim2.new(1,0,1,0) MakeDrag(fhdr,fw)
    local frow=Fr(fw,UDim2.new(1,0,0,math.floor(34*SC)),UDim2.new(0,0,0,math.floor(24*SC)),BG_WIN)
    local fl=Tx(frow,"  "..featName,FSS,COL_WHITE,false) fl.Size=UDim2.new(1,-(PW+12),1,0)
    local fpb=Fr(frow,UDim2.new(0,PW,0,PH),UDim2.new(1,-(PW+6),0.5,-PH/2),S[key] and RED or COL_DGRAY) Rnd(fpb,PH)
    local fpd=Fr(fpb,UDim2.new(0,PD,0,PD),UDim2.new(0,2,0.5,-PD/2),COL_WHITE) Rnd(fpd,PD)
    local function Fsync(val)
        TS:Create(fpb,TweenInfo.new(0.1),{BackgroundColor3=val and RED or COL_DGRAY}):Play()
        TS:Create(fpd,TweenInfo.new(0.1),{Position=val and UDim2.new(1,-(PD+2),0.5,-PD/2) or UDim2.new(0,2,0.5,-PD/2)}):Play()
    end
    Fsync(S[key]) Reg(key,Fsync)
    local fhit=Btn(frow,"",UDim2.new(1,0,1,0)) fhit.BackgroundTransparency=1 fhit.ZIndex=11
    fhit.MouseButton1Click:Connect(function()
        S[key]=not S[key] Fsync(S[key]) Fire(key,S[key]) end)
end

local function MkLogoRow(page,featName,key,order)
    local row=Fr(page,UDim2.new(1,0,0,RH),nil,BG_WIN) row.LayoutOrder=order
    row.MouseEnter:Connect(function() row.BackgroundColor3=BG_ROW_H end)
    row.MouseLeave:Connect(function() row.BackgroundColor3=BG_WIN end)
    local lbl=Tx(row,"  "..featName.." Logo",FSS,COL_GRAY,false) lbl.Size=UDim2.new(1,-50,1,0)
    local lb=Btn(row,"⊞",UDim2.new(0,math.floor(34*SC),0,math.floor(20*SC)),
        UDim2.new(1,-40,0.5,-10),BG_DD)
    Rnd(lb,3) Str(lb,COL_DGRAY,1) lb.TextColor3=RED lb.TextSize=math.floor(14*SC) lb.ZIndex=10
    lb.MouseButton1Click:Connect(function() MkFloat(featName,key) end)
end

-- ── DROPDOWN PLAYER (Select Target) ───────────────────────
local ddTgtFr=nil
local function MkTargetDD(page,order)
    local row=Fr(page,UDim2.new(1,0,0,RH),nil,BG_WIN) row.LayoutOrder=order
    local lbl=Tx(row,"  Select Target",FSS,COL_WHITE,false) lbl.Size=UDim2.new(0.5,0,1,0)
    local DDW=math.floor(110*SC)
    local ddB=Btn(row,S.SelectedTarget or "None  ▼",
        UDim2.new(0,DDW,0,math.floor(20*SC)),UDim2.new(1,-DDW-6,0.5,-10),BG_DD)
    Rnd(ddB,3) Str(ddB,COL_DGRAY,1) ddB.TextColor3=COL_GRAY ddB.TextSize=FSS ddB.ZIndex=10
    ddB.MouseButton1Click:Connect(function()
        if ddTgtFr then ddTgtFr:Destroy() ddTgtFr=nil return end
        ddTgtFr=Fr(mainSG,UDim2.new(0,DDW+10,0,0),nil,BG_DD)
        Rnd(ddTgtFr,3) Str(ddTgtFr,COL_DGRAY,1)
        ddTgtFr.AutomaticSize=Enum.AutomaticSize.Y ddTgtFr.ZIndex=30
        local ap=ddB.AbsolutePosition ddTgtFr.Position=UDim2.new(0,ap.X,0,ap.Y+math.floor(24*SC))
        local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder ul.Parent=ddTgtFr
        local ct=0
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end ct=ct+1
            local ib=Btn(ddTgtFr,"  "..p.Name,UDim2.new(1,0,0,math.floor(26*SC)))
            ib.TextXAlignment=Enum.TextXAlignment.Left ib.TextSize=FSS ib.LayoutOrder=ct ib.BackgroundColor3=BG_DD ib.ZIndex=31
            ib.MouseEnter:Connect(function() ib.BackgroundColor3=BG_ROW_H end)
            ib.MouseLeave:Connect(function() ib.BackgroundColor3=BG_DD end)
            ib.MouseButton1Click:Connect(function()
                S.SelectedTarget=p.Name ddB.Text=p.Name.."  ▼" ddB.TextColor3=RED
                ddTgtFr:Destroy() ddTgtFr=nil end)
        end
        if ct==0 then local n=Tx(ddTgtFr,"  No players",FSS,COL_GRAY) n.Size=UDim2.new(1,0,0,math.floor(24*SC)) end
    end)
end

-- ── AUTO FLY UI ───────────────────────────────────────────
local afGui=nil local afBV=nil
local function MkAutoFlyUI()
    if afGui then afGui:Destroy() afGui=nil S.AutoFlyStep=0
        if afBV then afBV:Destroy() afBV=nil end
        local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand=false end return
    end
    afGui=Instance.new("ScreenGui") afGui.Name="AutoFlyUI" afGui.ResetOnSpawn=false
    afGui.DisplayOrder=1001 afGui.Parent=PGui
    local afw=Fr(afGui,UDim2.new(0,math.floor(185*SC),0,math.floor(86*SC)),UDim2.new(0,90,0.65,0),BG_WIN)
    Rnd(afw,4) Str(afw,RED,1)
    local ahdr=Fr(afw,UDim2.new(1,0,0,math.floor(26*SC)),nil,BG_SIDE) Rnd(ahdr,4)
    local ahl=Tx(ahdr,"  Auto Fly",FSS,COL_WHITE,true,Enum.TextXAlignment.Center) ahl.Size=UDim2.new(1,0,1,0)
    MakeDrag(ahdr,afw)
    local stepL=Tx(afw,"Ready",FSS,COL_GRAY,false,Enum.TextXAlignment.Center)
    stepL.Size=UDim2.new(1,0,0,math.floor(18*SC)) stepL.Position=UDim2.new(0,0,0,math.floor(28*SC))
    local cb=Btn(afw,"Click 1 — Set",UDim2.new(1,-10,0,math.floor(24*SC)),UDim2.new(0,5,0,math.floor(54*SC)),RED)
    Rnd(cb,3) cb.TextSize=FSS
    local steps={[0]={b="Click 1 — Set",l="Ready"},[1]={b="Click 2 — Fly",l="Set ✓"},[2]={b="Click 3 — Lock",l="Flying..."},[3]={b="Locked ✓",l="Locked"}}
    local function upd() local d=steps[S.AutoFlyStep] if d then cb.Text=d.b stepL.Text=d.l end end
    cb.MouseButton1Click:Connect(function()
        local char=LP.Character local root=char and char:FindFirstChild("HumanoidRootPart")
        if not char or not root then return end
        if S.AutoFlyStep==0 then
            S.AutoFlyStep=1 local h2=char:FindFirstChildOfClass("Humanoid") if h2 then h2.PlatformStand=true end
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

-- ── SIDEBAR + PAGES ───────────────────────────────────────
local sUL=Instance.new("UIListLayout") sUL.SortOrder=Enum.SortOrder.LayoutOrder
sUL.Padding=UDim.new(0,math.floor(2*SC)) sUL.Parent=sidebar
local sPad=Instance.new("UIPadding")
sPad.PaddingTop=UDim.new(0,math.floor(6*SC))
sPad.PaddingLeft=UDim.new(0,math.floor(4*SC))
sPad.PaddingRight=UDim.new(0,math.floor(4*SC)) sPad.Parent=sidebar

local pages={} local tabBtns={} local activeTab=""
local TAB_H=math.floor(32*SC)

local function switchTab(name)
    activeTab=name
    for n,pg in pairs(pages) do pg.Visible=(n==name) end
    for n,tb in pairs(tabBtns) do
        -- P2077KNG: tab aktif = BG MERAH SOLID
        if n==name then
            tb.BackgroundColor3=RED tb.TextColor3=COL_WHITE
        else
            tb.BackgroundColor3=BG_SIDE tb.TextColor3=COL_GRAY
        end
    end
end

for i,tname in ipairs({"Function","AimBot","Esp","Fly/Tele","Misc"}) do
    local pg=MkPage() pages[tname]=pg
    local tb=Btn(sidebar,tname,UDim2.new(1,0,0,TAB_H),nil,BG_SIDE)
    Rnd(tb,3) tb.TextSize=FSS tb.TextColor3=COL_GRAY tb.LayoutOrder=i
    tabBtns[tname]=tb
    tb.MouseButton1Click:Connect(function() switchTab(tname) end)
end

-- ── PAGE: FUNCTION ────────────────────────────────────────
local pFn=pages["Function"]
SecHdr(pFn,"Function",1)
MkToggle(pFn,"Enable Function","EnableFunction",2)
MkToggle(pFn,"Enable Aim","EnableAim",3)
MkToggle(pFn,"Enable Esp","EnableEsp",4)

-- Divider
local div0=Fr(pFn,UDim2.new(1,0,0,math.floor(1*SC)),nil,COL_DGRAY) div0.LayoutOrder=5

-- Info box (P2077KNG style)
local infoF=Fr(pFn,UDim2.new(1,0,0,math.floor(102*SC)),nil,BG_ROW) infoF.LayoutOrder=6
local ipad=Instance.new("UIPadding") ipad.PaddingLeft=UDim.new(0,8) ipad.PaddingTop=UDim.new(0,6) ipad.Parent=infoF
local function irow(txt,y,col,bold)
    local l=Tx(infoF,txt,FSS,col or COL_GRAY,bold or false)
    l.Size=UDim2.new(1,-8,0,math.floor(14*SC)) l.Position=UDim2.new(0,0,0,math.floor(y*SC)) return l
end
irow("Release Version Official.  | Details",2,RED,true)
irow("SantaXMods has been released with the official version.",18)
irow("Developer: SkyFlow",40) irow("Youtube: @Skyflowh4x   Tiktok: @Sky.flow77",54) irow("Version: 1.12",68)

-- ── PAGE: AIMBOT (layout P2077KNG) ────────────────────────
local pA=pages["AimBot"]
SecHdr(pA,"Aimbot Player",1)

-- "• Aim Target:" label (abu kecil persis P2077KNG)
local tgtRow=Fr(pA,UDim2.new(1,0,0,math.floor(20*SC)),nil,BG_WIN) tgtRow.LayoutOrder=2
local tgtL=Tx(tgtRow,"  • Aim Target:",FSS,COL_GRAY,false) tgtL.Size=UDim2.new(1,0,1,0)

MkDropdown(pA,"AimTarget",{"Head","Body","Random"},3)
MkSlider(pA,"Aim Fov","AimFov",0,1000,4)

local div1=Fr(pA,UDim2.new(1,0,0,1),nil,COL_DGRAY) div1.LayoutOrder=5

MkToggle(pA,"Aimbot",           "Aimbot",          6)
MkToggle(pA,"Aim Assist",       "AimAssist",       7)
MkToggle(pA,"Aim Silent",       "AimSilent",       8)
MkToggle(pA,"Auto Fire",        "AutoFire",        9)
MkToggle(pA,"Auto Kill [FIX]",  "AutoKillFix",    10)
MkToggle(pA,"Auto Kill Toggle", "AutoKillToggle", 11)
MkToggle(pA,"Aim Silent Toggle","AimSilentToggle",12)
MkToggle(pA,"Aim Visible",      "AimVisible",     13)
MkToggle(pA,"Aim Magnet",       "AimMagnet",      14)

local div2=Fr(pA,UDim2.new(1,0,0,1),nil,COL_DGRAY) div2.LayoutOrder=15
MkLogoRow(pA,"Aim Silent","AimSilent",16)
MkLogoRow(pA,"Aim Magnet","AimMagnet",17)
MkLogoRow(pA,"AutoKill","AutoKillFix",18)

-- ── PAGE: ESP ─────────────────────────────────────────────
local pE=pages["Esp"]
SecHdr(pE,"Esp Function",1)
MkToggle(pE,"Esp Line",     "EspLine",    2)
MkToggle(pE,"Esp Box",      "EspBox",     3)
MkToggle(pE,"Esp Box 3D",   "EspBox3D",   4)
MkToggle(pE,"Esp Health",   "EspHealth",  5)
MkToggle(pE,"Esp Name",     "EspName",    6)
MkToggle(pE,"Esp Distance", "EspDistance",7)
MkToggle(pE,"Esp Skeleton", "EspSkeleton",8)
MkToggle(pE,"Esp Fov",      "EspFov",     9)

-- ── PAGE: FLY/TELE ────────────────────────────────────────
local pFT=pages["Fly/Tele"]
SecHdr(pFT,"Fly Function",1)
MkToggle(pFT,"Fly","Fly",2)
local afRow=Fr(pFT,UDim2.new(1,0,0,RH),nil,BG_WIN) afRow.LayoutOrder=3
afRow.MouseEnter:Connect(function() afRow.BackgroundColor3=BG_ROW_H end)
afRow.MouseLeave:Connect(function() afRow.BackgroundColor3=BG_WIN end)
local afL=Tx(afRow,"  Auto Fly",FSM,COL_WHITE,false) afL.Size=UDim2.new(1,-46,1,0)
local afLB=Btn(afRow,"⊞",UDim2.new(0,math.floor(34*SC),0,math.floor(20*SC)),UDim2.new(1,-40,0.5,-10),BG_DD)
Rnd(afLB,3) Str(afLB,COL_DGRAY,1) afLB.TextColor3=RED afLB.TextSize=math.floor(14*SC) afLB.ZIndex=10
afLB.MouseButton1Click:Connect(MkAutoFlyUI)
MkToggle(pFT,"Hit Fly","HitFly",4)
MkSlider(pFT,"Speed Fly","SpeedFly",1,10,5)
MkSlider(pFT,"High Hit Fly (m)","HighHitFly",0,100,6)
MkSlider(pFT,"Speed Hit Fly (m)","SpeedHitFly",0,150,7)
local dv1=Fr(pFT,UDim2.new(1,0,0,1),nil,COL_DGRAY) dv1.LayoutOrder=8
SecHdr(pFT,"Teleport Function",9)
MkToggle(pFT,"Teleport Player","TeleportPlayer",10)
MkToggle(pFT,"TeleKill","TeleKill",11)
MkLogoRow(pFT,"TeleKill","TeleKill",12)
MkTargetDD(pFT,13)

-- ── PAGE: MISC ────────────────────────────────────────────
local pM=pages["Misc"]
SecHdr(pM,"Misc Function",1)
MkToggle(pM,"SpeedHack","SpeedHack",2)
MkToggle(pM,"JumpHack","JumpHack",3)
MkToggle(pM,"GhostHack","GhostHack",4)

switchTab("Function")

-- ── ESP ENGINE (Drawing API) ──────────────────────────────
local eObj={}
local function clrEsp(p)
    if not eObj[p] then return end
    for _,obj in pairs(eObj[p]) do
        if type(obj)=="table" then for _,o2 in pairs(obj) do pcall(function() o2:Remove() end) end
        else pcall(function() obj:Remove() end) end
    end eObj[p]=nil
end
local function DLine(fr,to,col,thick)
    local d=Drawing.new("Line") d.From=fr d.To=to d.Color=col or Color3.new(1,1,1)
    d.Thickness=thick or 2 d.Transparency=1 d.Visible=true return d
end
local function DText(pos,txt,size,col)
    local d=Drawing.new("Text") d.Position=pos d.Text=txt d.Size=size or 13
    d.Color=col or RED d.Outline=true d.Center=true d.Visible=true return d
end
local function DQuad(a,b,c2,d2,col,thick)
    local q=Drawing.new("Quad") q.PointA=a q.PointB=b q.PointC=c2 q.PointD=d2
    q.Color=col or Color3.new(1,1,1) q.Thickness=thick or 2 q.Filled=false q.Transparency=1 q.Visible=true return q
end
local fovDraw=Drawing.new("Circle")
fovDraw.Radius=150 fovDraw.Color=RED fovDraw.Thickness=1
fovDraw.Filled=false fovDraw.Transparency=1 fovDraw.Visible=false

local function drawEsp(player)
    if not player.Character then clrEsp(player) return end
    local c=player.Character
    local root=c:FindFirstChild("HumanoidRootPart")
    local head=c:FindFirstChild("Head")
    local hum=c:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health<=0 then clrEsp(player) return end
    local myRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and (myRoot.Position-root.Position).Magnitude>400 then clrEsp(player) return end
    local headP=head and (head.Position+Vector3.new(0,head.Size.Y*0.5+0.1,0)) or (root.Position+Vector3.new(0,3.1,0))
    local feetP=root.Position-Vector3.new(0,3.1,0)
    local htSC=Cam:WorldToScreenPoint(headP)
    local ftSC=Cam:WorldToScreenPoint(feetP)
    local rootSC=Cam:WorldToScreenPoint(root.Position)
    if rootSC.Z<=0 then clrEsp(player) return end
    eObj[player]=eObj[player] or {}
    local o=eObj[player]
    local topY=math.min(htSC.Y,ftSC.Y) local botY=math.max(htSC.Y,ftSC.Y)
    local boxH=math.max(botY-topY,8) local boxW=boxH*0.48 local cx=rootSC.X
    local L=cx-boxW*0.5 local R=cx+boxW*0.5 local T=topY local B=botY
    local vTL=Vector2.new(L,T) local vTR=Vector2.new(R,T) local vBR=Vector2.new(R,B) local vBL=Vector2.new(L,B)
    local dist=myRoot and math.floor((myRoot.Position-root.Position).Magnitude) or 0
    if S.EspLine then
        if not o.line then o.line=DLine(Vector2.new(0,0),Vector2.new(0,0),Color3.new(1,1,1),2) end
        local vp=Cam.ViewportSize o.line.From=Vector2.new(vp.X*0.5,0) o.line.To=Vector2.new(rootSC.X,rootSC.Y) o.line.Visible=true
    elseif o.line then o.line.Visible=false end
    if S.EspBox then
        if not o.box then o.box=DQuad(vTL,vTR,vBR,vBL,Color3.new(1,1,1),2)
        else o.box.PointA=vTL o.box.PointB=vTR o.box.PointC=vBR o.box.PointD=vBL o.box.Visible=true end
    elseif o.box then o.box.Visible=false end
    if S.EspBox3D then
        if not o.box3d then o.box3d={} end
        local hw=1.0 local hh=3.0 local rp=root.Position
        local c3={rp+Vector3.new(-hw,hh,-hw),rp+Vector3.new(hw,hh,-hw),rp+Vector3.new(hw,hh,hw),rp+Vector3.new(-hw,hh,hw),rp+Vector3.new(-hw,-hh,-hw),rp+Vector3.new(hw,-hh,-hw),rp+Vector3.new(hw,-hh,hw),rp+Vector3.new(-hw,-hh,hw)}
        local sc3={} local ok3=true
        for i,v3 in ipairs(c3) do local sv=Cam:WorldToScreenPoint(v3) if sv.Z<=0 then ok3=false end sc3[i]=Vector2.new(sv.X,sv.Y) end
        local edges={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
        for ei,e in ipairs(edges) do
            if not o.box3d[ei] then o.box3d[ei]=DLine(Vector2.new(0,0),Vector2.new(0,0),Color3.new(1,1,1),1) end
            if ok3 then o.box3d[ei].From=sc3[e[1]] o.box3d[ei].To=sc3[e[2]] o.box3d[ei].Visible=true
            else o.box3d[ei].Visible=false end
        end
    elseif o.box3d then for _,l in ipairs(o.box3d) do pcall(function() l.Visible=false end) end end
    if S.EspName then
        if not o.name then o.name=DText(Vector2.new(0,0),"",math.floor(13*SC),RED) end
        o.name.Position=Vector2.new(cx,T-17) o.name.Text=player.Name o.name.Visible=true
    elseif o.name then o.name.Visible=false end
    if S.EspDistance then
        if not o.dist then o.dist=DText(Vector2.new(0,0),"",math.floor(11*SC),RED) end
        o.dist.Position=Vector2.new(cx,B+4) o.dist.Text=dist.."m" o.dist.Visible=true
    elseif o.dist then o.dist.Visible=false end
    if S.EspHealth then
        if not o.hbg then
            o.hbg=DLine(Vector2.new(0,0),Vector2.new(0,0),Color3.fromRGB(20,20,20),4)
            o.hfill=DLine(Vector2.new(0,0),Vector2.new(0,0),COL_GREEN,4) end
        local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
        local bx=L-7 o.hbg.From=Vector2.new(bx,T) o.hbg.To=Vector2.new(bx,B) o.hbg.Visible=true
        o.hfill.From=Vector2.new(bx,B) o.hfill.To=Vector2.new(bx,B-boxH*hp) o.hfill.Visible=true
    elseif o.hbg then o.hbg.Visible=false if o.hfill then o.hfill.Visible=false end end
    if S.EspSkeleton then
        if not o.skel then o.skel={} end
        local bones={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"}}
        for bi,bone in ipairs(bones) do
            local p0=c:FindFirstChild(bone[1]) local p1=c:FindFirstChild(bone[2])
            if p0 and p1 then
                local s0=Cam:WorldToScreenPoint(p0.Position) local s1=Cam:WorldToScreenPoint(p1.Position)
                if s0.Z>0 and s1.Z>0 then
                    if not o.skel[bi] then o.skel[bi]=DLine(Vector2.new(0,0),Vector2.new(0,0),RED,1) end
                    o.skel[bi].From=Vector2.new(s0.X,s0.Y) o.skel[bi].To=Vector2.new(s1.X,s1.Y) o.skel[bi].Visible=true
                end
            else if o.skel[bi] then o.skel[bi].Visible=false end end
        end
    elseif o.skel then for _,l in ipairs(o.skel) do pcall(function() l.Visible=false end) end end
end

-- ── AIM ENGINE ────────────────────────────────────────────
local function isAim() return S.EnableFunction and S.EnableAim end
local function isEsp()  return S.EnableFunction and S.EnableEsp  end

local function GetTargetPart(c,pn)
    if pn=="Body" then return c:FindFirstChild("HumanoidRootPart")
    elseif pn=="Random" then return math.random()<0.5 and c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
    else return c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart") end
end

local function IsVisible(fromPos,tp)
    local ray=Ray.new(fromPos,(tp.Position-fromPos).Unit*1000)
    local hit=workspace:FindPartOnRayWithIgnoreList(ray,{LP.Character,workspace.Terrain})
    return hit and hit:IsDescendantOf(tp.Parent)
end

local function GetEnemy(fov,pn)
    local best,bd=nil,fov
    local mouse=UIS:GetMouseLocation()
    local camPos=Cam.CFrame.Position
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if S.TeamCheck and p.Team==LP.Team then continue end
        local c=p.Character if not c then continue end
        local tp=GetTargetPart(c,pn) if not tp then continue end
        local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
        if S.AimVisible and not IsVisible(camPos,tp) then continue end
        local sp,vis=Cam:WorldToViewportPoint(tp.Position) if not vis then continue end
        local d=(Vector2.new(sp.X,sp.Y)-mouse).Magnitude
        if d<bd then bd=d best=tp end
    end
    return best
end

-- AimSilent sync dua arah
Reg("AimSilent",function(val) if S.AimSilentToggle~=val then S.AimSilentToggle=val Fire("AimSilentToggle",val) end end)
Reg("AimSilentToggle",function(val) if S.AimSilent~=val then S.AimSilent=val Fire("AimSilent",val) end end)
Reg("AutoKillFix",function(val) if S.AutoKillToggle~=val then S.AutoKillToggle=val Fire("AutoKillToggle",val) end end)
Reg("AutoKillToggle",function(val) if S.AutoKillFix~=val then S.AutoKillFix=val Fire("AutoKillFix",val) end end)

-- Silent aim engine
local silOrig=nil local silShot=false local silActive=false
UIS.InputBegan:Connect(function(i,gpe)
    if gpe or i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    if not isAim() or not(S.AimSilent or S.AimSilentToggle) then return end
    local t=GetEnemy(S.AimFov,S.AimTarget) if not t then return end
    silOrig=Cam.CFrame silShot=true silActive=true
    Cam.CFrame=CFrame.new(Cam.CFrame.Position,t.Position)
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        task.defer(function() task.wait() if silOrig and silShot then Cam.CFrame=silOrig silOrig=nil silShot=false silActive=false end end) end
end)

-- AutoFire
local afireRun=false
local function startAutoFire()
    if afireRun then return end afireRun=true
    task.spawn(function()
        while S.AutoFire and isAim() do
            local t=GetEnemy(S.AimFov,S.AimTarget)
            if t then
                local saved=Cam.CFrame
                Cam.CFrame=CFrame.new(Cam.CFrame.Position,t.Position)
                pcall(function()
                    local vim=game:GetService("VirtualInputManager")
                    local m=UIS:GetMouseLocation()
                    vim:SendMouseButtonEvent(m.X,m.Y,0,true,game,0)
                    task.wait(0.002)
                    vim:SendMouseButtonEvent(m.X,m.Y,0,false,game,0)
                end)
                Cam.CFrame=saved
            end
            task.wait(0.01)
        end
        afireRun=false
    end)
end

-- AutoKill ghost damage
local akRun=false
local function ghostKill(tc)
    if not tc then return end
    local hm=tc:FindFirstChildOfClass("Humanoid") if not hm or hm.Health<=0 then return end
    pcall(function() hm.Health=0 end)
    pcall(function()
        local mt=getrawmetatable(game)
        local old=mt.__namecall setreadonly(mt,false)
        mt.__namecall=newcclosure(function(self,...) return old(self,...) end)
        setreadonly(mt,true)
    end)
end
local function startAutoKill()
    if akRun then return end akRun=true
    task.spawn(function()
        while(S.AutoKillFix or S.AutoKillToggle) and isAim() do
            local t=GetEnemy(S.AimFov,S.AimTarget)
            if t then ghostKill(t.Parent)
            else
                local m=UIS:GetMouseLocation()
                for _,p in ipairs(Players:GetPlayers()) do
                    if p==LP then continue end
                    local c=p.Character if not c then continue end
                    local r2=c:FindFirstChild("HumanoidRootPart") if not r2 then continue end
                    local sp,vis=Cam:WorldToViewportPoint(r2.Position)
                    if vis and (Vector2.new(sp.X,sp.Y)-m).Magnitude<=S.AimFov then ghostKill(c) end
                end
            end
            task.wait(0.05)
        end
        akRun=false
    end)
end

-- Fly
local flyBV=nil
local function enFly()
    local char=LP.Character local root=char and char:FindFirstChild("HumanoidRootPart") if not root then return end
    local h=char:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=true end
    if flyBV then flyBV:Destroy() end
    flyBV=Instance.new("BodyVelocity") flyBV.Velocity=Vector3.zero flyBV.MaxForce=Vector3.new(1e5,1e5,1e5) flyBV.Parent=root
end
local function disFly()
    local char=LP.Character local h=char and char:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=false end
    if flyBV then flyBV:Destroy() flyBV=nil end
end

-- Ghost
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
                    local d=(mr.Position-r2.Position).Magnitude if d<bd then bd=d bt=p end
                end
                target=bt
            end
            if target then
                local tc=target.Character local tr=tc and tc:FindFirstChild("HumanoidRootPart")
                local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if tr and mr then mr.CFrame=tr.CFrame*CFrame.new(0,0,-1.5) task.wait(0.05)
                    local hm=tc:FindFirstChildOfClass("Humanoid") if hm then hm.Health=0 end end
            end
            task.wait(0.55)
        end
        tkRun=false
    end)
end

UIS.InputBegan:Connect(function(i,gpe)
    if gpe or i.KeyCode~=Enum.KeyCode.P then return end
    if not S.TeleportPlayer then return end
    local target=S.SelectedTarget and Players:FindFirstChild(S.SelectedTarget)
    if target then
        local tc=target.Character local tr=tc and tc:FindFirstChild("HumanoidRootPart")
        local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if tr and mr then mr.CFrame=tr.CFrame*CFrame.new(0,0,-2) end
    end
end)

-- ── MAIN LOOP ─────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local aim=isAim() local esp=isEsp()
    local char=LP.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local mouse=UIS:GetMouseLocation()

    if aim and S.Aimbot and not silActive then
        local t=GetEnemy(S.AimFov,S.AimTarget)
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.6) end
    end
    if aim and S.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,"Body")
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.07) end
    end
    if aim and S.AimMagnet and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,S.AimTarget)
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.18) end
    end
    if aim and(S.AutoKillFix or S.AutoKillToggle) then startAutoKill() end
    if aim and S.AutoFire then startAutoFire() end
    if aim and S.TeleKill then doTK() end

    if S.Fly then
        if not flyBV then enFly() end
        local dir=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
        if flyBV then flyBV.Velocity=dir*(S.SpeedFly*10) end
    else if flyBV then disFly() end end

    if hum then hum.WalkSpeed=S.SpeedHack and 95 or 16 hum.JumpPower=S.JumpHack and 135 or 50 end
    if char then
        if S.GhostHack then applyGhost(char,true)
        elseif next(gSaved)~=nil then applyGhost(char,false) end
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if esp and(S.EspBox or S.EspBox3D or S.EspName or S.EspDistance or S.EspHealth or S.EspLine or S.EspSkeleton) then
            drawEsp(p) else clrEsp(p) end
    end

    if esp and S.EspFov then
        local vp=Cam.ViewportSize
        fovDraw.Position=Vector2.new(vp.X*0.5,vp.Y*0.5)
        fovDraw.Radius=S.AimFov fovDraw.Visible=true
    else fovDraw.Visible=false end
end)

Players.PlayerRemoving:Connect(function(p) clrEsp(p) end)
print("[ SantaXModsKng v1.12 ] — SkyFlow")
