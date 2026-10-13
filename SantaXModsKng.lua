--[[
  SantaXModsKng.lua | v1.12
  Developer : SkyFlow
  Youtube   : @Skyflowh4x
  Tiktok    : @Sky.flow77
  P2077KNG Style UI — Full Rebuild
]]

-- ═══════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TS         = game:GetService("TweenService")
local LP         = Players.LocalPlayer
local Cam        = workspace.CurrentCamera
local PGui       = LP:WaitForChild("PlayerGui")

-- CLEANUP
for _, g in ipairs(PGui:GetChildren()) do
    if g.Name:find("SantaX") or g.Name:find("Float_") or g.Name:find("AutoFly") then g:Destroy() end
end

-- ═══════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════
local S = {
    EnableFunction=false, EnableAim=false, EnableEsp=false,
    AimTarget="Head", AimFov=150,
    Aimbot=false, AimAssist=false, AimSilent=false,
    AutoFire=false, AutoKillFix=false, AutoKillToggle=false,
    AimSilentToggle=false, AimVisible=false,
    AimMagnet=false, AutoKill=false,
    EspLine=false, EspBox=false, EspBox3D=false, EspHealth=false,
    EspName=false, EspDistance=false, EspSkeleton=false, EspFov=false,
    Fly=false, AutoFlyStep=0, HitFly=false,
    SpeedFly=5, HighHitFly=50, SpeedHitFly=75,
    TeleportPlayer=false, TeleKill=false, SelectedTarget=nil,
    SpeedHack=false, JumpHack=false, GhostHack=false,
    TeamCheck=true,
}

-- ═══════════════════════════════════════════════
-- THEME  — P2077KNG palette
-- ═══════════════════════════════════════════════
local RED     = Color3.fromRGB(215,32,32)
local RED2    = Color3.fromRGB(160,18,18)
local BG0     = Color3.fromRGB(10,10,10)
local BG1     = Color3.fromRGB(17,17,17)
local BG2     = Color3.fromRGB(24,24,24)
local BG3     = Color3.fromRGB(32,32,32)
local BG4     = Color3.fromRGB(40,40,40)
local WHITE   = Color3.fromRGB(235,235,235)
local GRAY    = Color3.fromRGB(155,155,155)
local DGRAY   = Color3.fromRGB(62,62,62)
local GREEN   = Color3.fromRGB(42,200,72)
local ACCENT  = Color3.fromRGB(215,32,32)

-- ═══════════════════════════════════════════════
-- RESPONSIVE SCALE
-- ═══════════════════════════════════════════════
local VP      = Cam.ViewportSize
local BASE    = math.max(VP.X, VP.Y)
local SC      = math.clamp(BASE / 1366, 0.75, 1.5)
local W       = math.floor(460 * SC)
local H       = math.floor(500 * SC)
local SIDEW   = math.floor(110 * SC)
local TITLEH  = math.floor(38  * SC)
local ROWH    = math.floor(32  * SC)
local FSL     = math.floor(13  * SC)
local FSM     = math.floor(12  * SC)
local FSS     = math.floor(10  * SC)
local PAD     = math.floor(7   * SC)
local PW      = math.floor(40  * SC)
local PH      = math.floor(21  * SC)
local DOTS    = math.floor(15  * SC)

-- ═══════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════
local function Rnd(p,r) local o=Instance.new("UICorner") o.CornerRadius=UDim.new(0,r or 4) o.Parent=p end
local function Str(p,c,t) local o=Instance.new("UIStroke") o.Color=c or DGRAY o.Thickness=t or 1 o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border o.Parent=p end

local function Fr(par,sz,pos,bg,alpha)
    local f=Instance.new("Frame")
    f.Size=sz or UDim2.new(1,0,0,ROWH) f.Position=pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3=bg or BG2 f.BackgroundTransparency=alpha or 0
    f.BorderSizePixel=0 f.ClipsDescendants=false f.Parent=par return f
end

local function Tx(par,txt,fs,col,bold,xa)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
    l.Text=txt or "" l.TextSize=fs or FSM
    l.TextColor3=col or WHITE l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.TextTruncate=Enum.TextTruncate.AtEnd l.Parent=par return l
end

local function Btn(par,txt,sz,pos,bg)
    local b=Instance.new("TextButton")
    b.Size=sz or UDim2.new(1,0,0,ROWH) b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=bg or BG3 b.BorderSizePixel=0
    b.Text=txt or "" b.TextColor3=WHITE b.TextSize=FSM
    b.Font=Enum.Font.GothamBold b.AutoButtonColor=false b.Parent=par return b
end

-- ═══════════════════════════════════════════════
-- DRAG
-- ═══════════════════════════════════════════════
local function MakeDrag(handle, target)
    local on,ds,dp=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            on=true ds=Vector2.new(i.Position.X,i.Position.Y) dp=target.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not on then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=Vector2.new(i.Position.X,i.Position.Y)-ds
            target.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then on=false end
    end)
end

-- ═══════════════════════════════════════════════
-- TOGGLE CALLBACKS
-- ═══════════════════════════════════════════════
local TCB={}
local function Fire(key,val) if TCB[key] then for _,fn in ipairs(TCB[key]) do pcall(fn,val) end end end
local function Reg(key,fn) TCB[key]=TCB[key] or {} table.insert(TCB[key],fn) end

-- ═══════════════════════════════════════════════
-- FLOATING ICON (bulat transparan)
-- ═══════════════════════════════════════════════
local iconSG=Instance.new("ScreenGui")
iconSG.Name="SantaXIcon" iconSG.ResetOnSpawn=false iconSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling iconSG.Parent=PGui
local ICONS=math.floor(58*SC)
local iconImg=Instance.new("ImageButton")
iconImg.Size=UDim2.new(0,ICONS,0,ICONS) iconImg.Position=UDim2.new(0,14,0.5,-ICONS/2)
iconImg.BackgroundTransparency=1 iconImg.Image="rbxassetid://104012475483632"
iconImg.Visible=false iconImg.ZIndex=10 iconImg.Parent=iconSG
Rnd(iconImg,ICONS) MakeDrag(iconImg,iconImg)

-- ═══════════════════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════════════════
local mainSG=Instance.new("ScreenGui")
mainSG.Name="SantaXMain" mainSG.ResetOnSpawn=false
mainSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling mainSG.Parent=PGui

local win=Fr(mainSG,UDim2.new(0,W,0,H+TITLEH),UDim2.new(0.5,-W/2,0.5,-(H+TITLEH)/2),BG0)
Rnd(win,7) Str(win,RED,1.5)

-- ── TITLE BAR ─────────────────────────────────
local tbar=Fr(win,UDim2.new(1,0,0,TITLEH),UDim2.new(0,0,0,0),BG0)
Rnd(tbar,7) Str(tbar,RED,1)

-- top red accent
local acLine=Fr(tbar,UDim2.new(1,0,0,math.floor(3*SC)),UDim2.new(0,0,0,0),RED)

-- arrow ▼/▶
local arrowB=Btn(tbar,"▼",UDim2.new(0,math.floor(26*SC),1,-math.floor(6*SC)),UDim2.new(0,math.floor(8*SC),0,math.floor(3*SC)),BG0)
arrowB.TextColor3=RED arrowB.TextSize=FSL arrowB.ZIndex=6

-- title (붙어있게)
local titleTx=Tx(tbar,"SantaXModsKng  v1.12",FSL,WHITE,true)
titleTx.Size=UDim2.new(1,-math.floor(80*SC),1,0)
titleTx.Position=UDim2.new(0,math.floor(36*SC),0,0)

-- close
local closeB=Btn(tbar,"✕",UDim2.new(0,math.floor(30*SC),0,math.floor(24*SC)),UDim2.new(1,-math.floor(36*SC),0.5,-math.floor(12*SC)),BG0)
closeB.TextColor3=WHITE closeB.TextSize=FSM closeB.ZIndex=7 Rnd(closeB,4)

-- Drag dari title bar (seluruh area kecuali tombol)
MakeDrag(tbar, win)

-- collapse
local collapsed=false
local function setCollapse(v)
    collapsed=v body.Visible=not v
    arrowB.Text=v and "▶" or "▼"
    win.Size=v and UDim2.new(0,W,0,TITLEH) or UDim2.new(0,W,0,H+TITLEH)
end

-- ── BODY ──────────────────────────────────────
local body=Fr(win,UDim2.new(1,0,1,-TITLEH),UDim2.new(0,0,0,TITLEH),BG0)

-- Sidebar
local sidebar=Fr(body,UDim2.new(0,SIDEW,1,0),UDim2.new(0,0,0,0),BG1)
Str(sidebar,DGRAY,1)

-- Content
local CONTW=W-SIDEW-2
local contArea=Fr(body,UDim2.new(0,CONTW,1,-2),UDim2.new(0,SIDEW+2,0,1),BG0)

arrowB.MouseButton1Click:Connect(function() setCollapse(not collapsed) end)
closeB.MouseButton1Click:Connect(function() win.Visible=false iconImg.Visible=true end)
iconImg.MouseButton1Click:Connect(function() iconImg.Visible=false win.Visible=true end)

-- ═══════════════════════════════════════════════
-- SCROLL PAGE
-- ═══════════════════════════════════════════════
local function MkPage()
    local sf=Instance.new("ScrollingFrame")
    sf.Size=UDim2.new(1,0,1,0) sf.BackgroundTransparency=1 sf.BorderSizePixel=0
    sf.ScrollBarThickness=math.floor(4*SC) sf.ScrollBarImageColor3=RED
    sf.CanvasSize=UDim2.new(0,0,0,0) sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Visible=false sf.Parent=contArea
    local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder
    ul.Padding=UDim.new(0,math.floor(3*SC)) ul.Parent=sf
    local up=Instance.new("UIPadding")
    up.PaddingLeft=UDim.new(0,PAD) up.PaddingRight=UDim.new(0,PAD)
    up.PaddingTop=UDim.new(0,PAD) up.PaddingBottom=UDim.new(0,PAD)
    up.Parent=sf return sf
end

-- ═══════════════════════════════════════════════
-- SECTION HEADER  (left red bar style P2077KNG)
-- ═══════════════════════════════════════════════
local function SecHdr(page,txt,order)
    local h=Fr(page,UDim2.new(1,0,0,math.floor(26*SC)),nil,BG1) Rnd(h,4) h.LayoutOrder=order
    local bar=Fr(h,UDim2.new(0,math.floor(3*SC),0.65,0),UDim2.new(0,0,0.175,0),RED)
    local lbl=Tx(h,"  "..txt,FSS,RED,true) lbl.Position=UDim2.new(0,math.floor(7*SC),0,0)
    lbl.Size=UDim2.new(1,0,1,0) return h
end

-- ═══════════════════════════════════════════════
-- PILL TOGGLE  (P2077KNG style)
-- ═══════════════════════════════════════════════
local function MkToggle(page,lTxt,key,order)
    local row=Fr(page,UDim2.new(1,0,0,ROWH),nil,BG2) Rnd(row,4) row.LayoutOrder=order

    -- subtle hover
    row.MouseEnter:Connect(function() row.BackgroundColor3=BG3 end)
    row.MouseLeave:Connect(function() row.BackgroundColor3=BG2 end)

    -- bullet dot  (P2077KNG style — kotak merah kecil di kiri)
    local dot=Fr(row,UDim2.new(0,math.floor(3*SC),0,math.floor(14*SC)),
        UDim2.new(0,math.floor(6*SC),0.5,-math.floor(7*SC)),RED)

    local lbl=Tx(row,"   "..lTxt,FSM,WHITE,false)
    lbl.Size=UDim2.new(1,-(PW+18),1,0)
    lbl.Position=UDim2.new(0,math.floor(14*SC),0,0)

    -- pill
    local pillBg=Fr(row,UDim2.new(0,PW,0,PH),
        UDim2.new(1,-(PW+7),0.5,-PH/2), S[key] and RED or DGRAY) Rnd(pillBg,PH)
    local pillDot=Fr(pillBg,UDim2.new(0,DOTS,0,DOTS),
        UDim2.new(0,3,0.5,-DOTS/2),WHITE) Rnd(pillDot,DOTS)

    local function Refresh(val)
        TS:Create(pillBg,TweenInfo.new(0.12),{BackgroundColor3=val and RED or DGRAY}):Play()
        TS:Create(pillDot,TweenInfo.new(0.12),{
            Position=val and UDim2.new(1,-(DOTS+3),0.5,-DOTS/2) or UDim2.new(0,3,0.5,-DOTS/2)
        }):Play()
    end

    local hit=Btn(row,"",UDim2.new(1,0,1,0)) hit.BackgroundTransparency=1 hit.ZIndex=10
    hit.MouseButton1Click:Connect(function()
        S[key]=not S[key] Refresh(S[key]) Fire(key,S[key])
    end)

    Reg(key,Refresh) return row,Refresh
end

-- ═══════════════════════════════════════════════
-- SMOOTH SLIDER  (P2077KNG style — tebal, merah)
-- ═══════════════════════════════════════════════
local function MkSlider(page,lTxt,key,mn,mx,order)
    local RH=math.floor(52*SC)
    local row=Fr(page,UDim2.new(1,0,0,RH),nil,BG2) Rnd(row,4) row.LayoutOrder=order

    local lbl=Tx(row,"  "..lTxt,FSS,WHITE,false)
    lbl.Size=UDim2.new(0.62,0,0,math.floor(20*SC)) lbl.Position=UDim2.new(0,0,0,math.floor(4*SC))

    local valL=Tx(row,tostring(S[key]).."°",FSS,WHITE,true,Enum.TextXAlignment.Right)
    valL.Size=UDim2.new(0.35,0,0,math.floor(20*SC))
    valL.Position=UDim2.new(0.64,-PAD,0,math.floor(4*SC))

    -- Track
    local TH=math.floor(6*SC)
    local trkBg=Fr(row,UDim2.new(1,-PAD*2,0,TH),
        UDim2.new(0,PAD,0,RH-math.floor(16*SC)),BG4) Rnd(trkBg,TH)

    local pct=math.clamp((S[key]-mn)/(mx-mn),0,1)
    local fill=Fr(trkBg,UDim2.new(pct,0,1,0),nil,RED) Rnd(fill,TH)

    -- Thumb (bulat, putih)
    local DTH=math.floor(16*SC)
    local thm=Fr(trkBg,UDim2.new(0,DTH,0,DTH),
        UDim2.new(pct,-DTH/2,0.5,-DTH/2),WHITE) Rnd(thm,DTH) Str(thm,DGRAY,1)

    local sliding=false

    local function updateSlider(px)
        local ap=trkBg.AbsolutePosition local as=trkBg.AbsoluteSize
        if as.X==0 then return end
        local rel=math.clamp((px-ap.X)/as.X,0,1)
        local nv=math.floor(mn+rel*(mx-mn))
        S[key]=nv
        fill.Size=UDim2.new(rel,0,1,0)
        thm.Position=UDim2.new(rel,-DTH/2,0.5,-DTH/2)
        valL.Text=tostring(nv).."°"
    end

    local function onBegan(i)
        local ut=i.UserInputType
        if ut==Enum.UserInputType.MouseButton1 or ut==Enum.UserInputType.Touch then
            sliding=true updateSlider(i.Position.X)
        end
    end
    local function onChanged(i)
        if not sliding then return end
        local ut=i.UserInputType
        if ut==Enum.UserInputType.MouseMovement or ut==Enum.UserInputType.Touch then
            updateSlider(i.Position.X) end
    end
    local function onEnded(i)
        local ut=i.UserInputType
        if ut==Enum.UserInputType.MouseButton1 or ut==Enum.UserInputType.Touch then sliding=false end
    end

    -- Hit zone seluruh baris
    local hitZ=Btn(row,"",UDim2.new(1,0,1,0)) hitZ.BackgroundTransparency=1 hitZ.ZIndex=10
    hitZ.InputBegan:Connect(onBegan)
    trkBg.InputBegan:Connect(onBegan)
    thm.InputBegan:Connect(onBegan)
    fill.InputBegan:Connect(onBegan)
    UIS.InputChanged:Connect(onChanged)
    UIS.InputEnded:Connect(onEnded)
end

-- ═══════════════════════════════════════════════
-- DROPDOWN  (P2077KNG style — Head/Body/Random)
-- ═══════════════════════════════════════════════
local ddOpen=false local ddFr=nil

local function MkDropdown(page,lTxt,key,opts,order)
    local row=Fr(page,UDim2.new(1,0,0,ROWH),nil,BG2) Rnd(row,4) row.LayoutOrder=order

    local lbl=Tx(row,"  "..lTxt,FSS,GRAY,false)
    lbl.Size=UDim2.new(0.45,0,1,0)

    local DDW=math.floor(130*SC)
    local ddB=Btn(row,S[key].."  ▼",
        UDim2.new(0,DDW,0,math.floor(24*SC)),
        UDim2.new(1,-DDW-6,0.5,-12),BG3)
    Rnd(ddB,4) Str(ddB,DGRAY,1)
    ddB.TextColor3=WHITE ddB.TextSize=FSS ddB.ZIndex=10

    ddB.MouseButton1Click:Connect(function()
        if ddFr then ddFr:Destroy() ddFr=nil ddOpen=false return end
        ddOpen=true
        ddFr=Fr(mainSG,UDim2.new(0,DDW,0,0),nil,BG1)
        Rnd(ddFr,4) Str(ddFr,DGRAY,1)
        ddFr.AutomaticSize=Enum.AutomaticSize.Y ddFr.ZIndex=30
        local ap=ddB.AbsolutePosition
        ddFr.Position=UDim2.new(0,ap.X,0,ap.Y+math.floor(28*SC))

        local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder ul.Parent=ddFr
        for i,opt in ipairs(opts) do
            local ib=Btn(ddFr,"  "..opt,UDim2.new(1,0,0,math.floor(28*SC)))
            ib.TextXAlignment=Enum.TextXAlignment.Left ib.TextSize=FSS ib.LayoutOrder=i ib.ZIndex=31
            ib.BackgroundColor3=BG1
            ib.MouseEnter:Connect(function() ib.BackgroundColor3=BG3 end)
            ib.MouseLeave:Connect(function() ib.BackgroundColor3=BG1 end)
            ib.MouseButton1Click:Connect(function()
                S[key]=opt ddB.Text=opt.."  ▼"
                ddFr:Destroy() ddFr=nil ddOpen=false end)
        end
    end)
end

-- ═══════════════════════════════════════════════
-- FLOATING LOGO UI
-- ═══════════════════════════════════════════════
local floats={}
local function MkFloat(featName,key)
    if floats[key] then floats[key]:Destroy() floats[key]=nil return end
    local fg=Instance.new("ScreenGui")
    fg.Name="Float_"..key fg.ResetOnSpawn=false fg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling fg.Parent=PGui
    floats[key]=fg

    local FW=math.floor(180*SC)
    local fw=Fr(fg,UDim2.new(0,FW,0,math.floor(66*SC)),UDim2.new(0,90,0.42,0),BG0)
    Rnd(fw,6) Str(fw,DGRAY,1)

    local fhdr=Fr(fw,UDim2.new(1,0,0,math.floor(26*SC)),nil,DGRAY) Rnd(fhdr,5)
    local fhl=Tx(fhdr,"  "..featName,FSS,WHITE,true,Enum.TextXAlignment.Center) fhl.Size=UDim2.new(1,0,1,0)
    MakeDrag(fhdr,fw)

    local frow=Fr(fw,UDim2.new(1,0,0,math.floor(36*SC)),UDim2.new(0,0,0,math.floor(26*SC)),BG0)
    local fl=Tx(frow,"  "..featName,FSS,WHITE,false) fl.Size=UDim2.new(1,-(PW+14),1,0)

    local fpb=Fr(frow,UDim2.new(0,PW,0,PH),UDim2.new(1,-(PW+7),0.5,-PH/2),S[key] and RED or DGRAY) Rnd(fpb,PH)
    local fpd=Fr(fpb,UDim2.new(0,DOTS,0,DOTS),UDim2.new(0,3,0.5,-DOTS/2),WHITE) Rnd(fpd,DOTS)

    local function Fsync(val)
        TS:Create(fpb,TweenInfo.new(0.12),{BackgroundColor3=val and RED or DGRAY}):Play()
        TS:Create(fpd,TweenInfo.new(0.12),{Position=val and UDim2.new(1,-(DOTS+3),0.5,-DOTS/2) or UDim2.new(0,3,0.5,-DOTS/2)}):Play()
    end
    Fsync(S[key]) Reg(key,Fsync)

    local fhit=Btn(frow,"",UDim2.new(1,0,1,0)) fhit.BackgroundTransparency=1 fhit.ZIndex=11
    fhit.MouseButton1Click:Connect(function()
        S[key]=not S[key] Fsync(S[key]) Fire(key,S[key]) end)
end

local function MkLogoRow(page,featName,key,order)
    local row=Fr(page,UDim2.new(1,0,0,ROWH),nil,BG1) Rnd(row,4) row.LayoutOrder=order
    local lbl=Tx(row,"  "..featName.." Logo",FSS,GRAY,false) lbl.Size=UDim2.new(1,-50,1,0)
    local lb=Btn(row,"⊞",UDim2.new(0,math.floor(36*SC),0,math.floor(22*SC)),UDim2.new(1,-42,0.5,-11),BG2)
    Rnd(lb,4) Str(lb,DGRAY,1) lb.TextColor3=RED lb.TextSize=math.floor(15*SC) lb.ZIndex=10
    lb.MouseButton1Click:Connect(function() MkFloat(featName,key) end)
end

-- ═══════════════════════════════════════════════
-- DIVIDER
-- ═══════════════════════════════════════════════
local function MkDiv(page,order)
    local d=Fr(page,UDim2.new(1,0,0,1),nil,DGRAY) d.LayoutOrder=order return d
end

-- ═══════════════════════════════════════════════
-- TARGET DROPDOWN (Select Player)
-- ═══════════════════════════════════════════════
local ddTgtOpen=false local ddTgtFr=nil
local function MkTargetDD(page,order)
    local row=Fr(page,UDim2.new(1,0,0,ROWH),nil,BG2) Rnd(row,4) row.LayoutOrder=order
    local lbl=Tx(row,"  Select Target",FSS,WHITE,false) lbl.Size=UDim2.new(0.5,0,1,0)
    local DDW=math.floor(115*SC)
    local ddB=Btn(row,S.SelectedTarget or "None  ▼",UDim2.new(0,DDW,0,math.floor(24*SC)),UDim2.new(1,-DDW-6,0.5,-12),BG3)
    Rnd(ddB,4) Str(ddB,DGRAY,1) ddB.TextColor3=GRAY ddB.TextSize=FSS ddB.ZIndex=10
    ddB.MouseButton1Click:Connect(function()
        if ddTgtFr then ddTgtFr:Destroy() ddTgtFr=nil ddTgtOpen=false return end
        ddTgtOpen=true ddTgtFr=Fr(mainSG,UDim2.new(0,DDW+10,0,0),nil,BG1)
        Rnd(ddTgtFr,4) Str(ddTgtFr,DGRAY,1) ddTgtFr.AutomaticSize=Enum.AutomaticSize.Y ddTgtFr.ZIndex=30
        local ap=ddB.AbsolutePosition ddTgtFr.Position=UDim2.new(0,ap.X,0,ap.Y+math.floor(28*SC))
        local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder ul.Parent=ddTgtFr
        local ct=0
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end ct=ct+1
            local ib=Btn(ddTgtFr,"  "..p.Name,UDim2.new(1,0,0,math.floor(28*SC)))
            ib.TextXAlignment=Enum.TextXAlignment.Left ib.TextSize=FSS ib.LayoutOrder=ct ib.ZIndex=31 ib.BackgroundColor3=BG1
            ib.MouseEnter:Connect(function() ib.BackgroundColor3=BG3 end)
            ib.MouseLeave:Connect(function() ib.BackgroundColor3=BG1 end)
            ib.MouseButton1Click:Connect(function()
                S.SelectedTarget=p.Name ddB.Text=p.Name.."  ▼" ddB.TextColor3=RED
                ddTgtFr:Destroy() ddTgtFr=nil ddTgtOpen=false end)
        end
        if ct==0 then local n=Tx(ddTgtFr,"  No players",FSS,GRAY) n.Size=UDim2.new(1,0,0,math.floor(26*SC)) end
    end)
end

-- ═══════════════════════════════════════════════
-- AUTO FLY UI (3-click)
-- ═══════════════════════════════════════════════
local afGui=nil local afBV=nil
local function MkAutoFlyUI()
    if afGui then
        afGui:Destroy() afGui=nil S.AutoFlyStep=0
        if afBV then afBV:Destroy() afBV=nil end
        local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand=false end return
    end
    afGui=Instance.new("ScreenGui") afGui.Name="AutoFlyUI" afGui.ResetOnSpawn=false afGui.Parent=PGui
    local afw=Fr(afGui,UDim2.new(0,math.floor(195*SC),0,math.floor(90*SC)),UDim2.new(0,90,0.65,0),BG0)
    Rnd(afw,6) Str(afw,RED,1)
    local ahdr=Fr(afw,UDim2.new(1,0,0,math.floor(28*SC)),nil,DGRAY) Rnd(ahdr,5)
    local ahl=Tx(ahdr,"  Auto Fly",FSS,WHITE,true,Enum.TextXAlignment.Center) ahl.Size=UDim2.new(1,0,1,0)
    MakeDrag(ahdr,afw)
    local stepL=Tx(afw,"Ready",FSS,GRAY,false,Enum.TextXAlignment.Center)
    stepL.Size=UDim2.new(1,0,0,math.floor(20*SC)) stepL.Position=UDim2.new(0,0,0,math.floor(30*SC))
    local cb=Btn(afw,"Click 1 — Set Position",UDim2.new(1,-12,0,math.floor(26*SC)),UDim2.new(0,6,0,math.floor(56*SC)),RED)
    Rnd(cb,4) cb.TextSize=FSS
    local steps={[0]={b="Click 1 — Set Position",l="Ready"},[1]={b="Click 2 — Start Flying",l="Step 1: Set"},[2]={b="Click 3 — Lock Position",l="Step 2: Flying..."},[3]={b="Locked ✓",l="Step 3: Locked"}}
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

-- ═══════════════════════════════════════════════
-- BUILD SIDEBAR + PAGES
-- ═══════════════════════════════════════════════
local tabUL=Instance.new("UIListLayout") tabUL.SortOrder=Enum.SortOrder.LayoutOrder
tabUL.Padding=UDim.new(0,2) tabUL.Parent=sidebar
local tabPad=Instance.new("UIPadding")
tabPad.PaddingTop=UDim.new(0,8) tabPad.PaddingLeft=UDim.new(0,4)
tabPad.PaddingRight=UDim.new(0,4) tabPad.Parent=sidebar

local pages={} local tabBtns={} local activeTab=""
local function switchTab(name)
    activeTab=name
    for n,pg in pairs(pages) do pg.Visible=(n==name) end
    for n,tb in pairs(tabBtns) do
        tb.BackgroundColor3=n==name and RED or BG3
        tb.TextColor3=n==name and WHITE or GRAY
    end
end

for i,tname in ipairs({"Function","AimBot","Esp","Fly/Tele","Misc"}) do
    local pg=MkPage() pages[tname]=pg
    local TAB_H=math.floor(34*SC)
    local tb=Btn(sidebar,tname,UDim2.new(1,0,0,TAB_H),nil,BG3)
    Rnd(tb,5) tb.TextSize=FSS tb.TextColor3=GRAY tb.LayoutOrder=i
    tabBtns[tname]=tb
    tb.MouseButton1Click:Connect(function() switchTab(tname) end)
end

-- ═══════════════════════════════════════════════
-- PAGE: FUNCTION
-- ═══════════════════════════════════════════════
local pFn=pages["Function"]
SecHdr(pFn,"Function",1)
MkToggle(pFn,"Enable Function","EnableFunction",2)
MkToggle(pFn,"Enable Aim",     "EnableAim",     3)
MkToggle(pFn,"Enable Esp",     "EnableEsp",     4)
MkDiv(pFn,5)

local infoBox=Fr(pFn,UDim2.new(1,0,0,math.floor(106*SC)),nil,BG2)
Rnd(infoBox,5) infoBox.LayoutOrder=6
local ipad=Instance.new("UIPadding") ipad.PaddingLeft=UDim.new(0,8) ipad.PaddingTop=UDim.new(0,6) ipad.Parent=infoBox
local function irow(txt,y,col,bold)
    local l=Tx(infoBox,txt,FSS,col or GRAY,bold or false)
    l.Size=UDim2.new(1,-8,0,math.floor(15*SC)) l.Position=UDim2.new(0,0,0,math.floor(y*SC)) return l
end
irow("Release Version Official.  | Details",2,RED,true)
irow("SantaXMods has been released with the official version.",20)
irow("Developer: SkyFlow",44)
irow("Youtube: @Skyflowh4x   Tiktok: @Sky.flow77",59)
irow("Version: 1.12",74)

-- ═══════════════════════════════════════════════
-- PAGE: AIMBOT  (P2077KNG layout)
-- ═══════════════════════════════════════════════
local pA=pages["AimBot"]
SecHdr(pA,"Aimbot Player",1)

-- Aim Target label
local tgtLabel=Fr(pA,UDim2.new(1,0,0,math.floor(22*SC)),nil,BG0) Rnd(tgtLabel,4) tgtLabel.LayoutOrder=2
local tgtL=Tx(tgtLabel,"  • Aim Target:",FSS,GRAY,false) tgtL.Size=UDim2.new(1,0,1,0)

-- Dropdown Head/Body/Random
MkDropdown(pA,"",        "AimTarget",{"Head","Body","Random"},3)

-- AimFov Slider (P2077KNG style — prominent)
MkSlider(pA,"Aim Fov","AimFov",0,1000,4)

MkDiv(pA,5)

-- Toggles
MkToggle(pA,"Aimbot",           "Aimbot",         6)
MkToggle(pA,"Aim Assist",       "AimAssist",      7)
MkToggle(pA,"Aim Silent",       "AimSilent",      8)
MkToggle(pA,"Auto Fire",        "AutoFire",       9)
MkToggle(pA,"Auto Kill [FIX]",  "AutoKillFix",    10)
MkToggle(pA,"Auto Kill Toggle", "AutoKillToggle", 11)
MkToggle(pA,"Aim Silent Toggle","AimSilentToggle",12)
MkToggle(pA,"Aim Visible",      "AimVisible",     13)
MkToggle(pA,"Aim Magnet",       "AimMagnet",      14)

MkDiv(pA,15)
MkLogoRow(pA,"Aim Silent","AimSilent",16)
MkLogoRow(pA,"Aim Magnet","AimMagnet",17)
MkLogoRow(pA,"AutoKill",  "AutoKillFix",18)

-- ═══════════════════════════════════════════════
-- PAGE: ESP
-- ═══════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════
-- PAGE: FLY/TELE
-- ═══════════════════════════════════════════════
local pFT=pages["Fly/Tele"]
SecHdr(pFT,"Fly Function",1)
MkToggle(pFT,"Fly","Fly",2)

local afRow=Fr(pFT,UDim2.new(1,0,0,ROWH),nil,BG1) Rnd(afRow,4) afRow.LayoutOrder=3
local afL=Tx(afRow,"  Auto Fly",FSM,WHITE,false) afL.Size=UDim2.new(1,-50,1,0)
local afLB=Btn(afRow,"⊞",UDim2.new(0,math.floor(36*SC),0,math.floor(22*SC)),UDim2.new(1,-42,0.5,-11),BG2)
Rnd(afLB,4) Str(afLB,DGRAY,1) afLB.TextColor3=RED afLB.TextSize=math.floor(15*SC) afLB.ZIndex=10
afLB.MouseButton1Click:Connect(MkAutoFlyUI)

MkToggle(pFT,"Hit Fly","HitFly",4)
MkSlider(pFT,"Speed Fly","SpeedFly",1,10,5)
MkSlider(pFT,"High Hit Fly (m)","HighHitFly",0,100,6)
MkSlider(pFT,"Speed Hit Fly (m)","SpeedHitFly",0,150,7)
MkDiv(pFT,8)
SecHdr(pFT,"Teleport Function",9)
MkToggle(pFT,"Teleport Player","TeleportPlayer",10)
MkToggle(pFT,"TeleKill","TeleKill",11)
MkLogoRow(pFT,"TeleKill","TeleKill",12)
MkTargetDD(pFT,13)

-- ═══════════════════════════════════════════════
-- PAGE: MISC
-- ═══════════════════════════════════════════════
local pM=pages["Misc"]
SecHdr(pM,"Misc Function",1)
MkToggle(pM,"SpeedHack", "SpeedHack",2)
MkToggle(pM,"JumpHack",  "JumpHack", 3)
MkToggle(pM,"GhostHack", "GhostHack",4)

switchTab("Function")

-- ═══════════════════════════════════════════════
-- ESP ENGINE  (Drawing API)
-- ═══════════════════════════════════════════════
local eObj={}

local function clrEsp(p)
    if not eObj[p] then return end
    for _,obj in pairs(eObj[p]) do
        if type(obj)=="table" then
            for _,o2 in pairs(obj) do pcall(function() o2:Remove() end) end
        else pcall(function() obj:Remove() end) end
    end
    eObj[p]=nil
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
    q.Color=col or Color3.new(1,1,1) q.Thickness=thick or 2 q.Filled=false
    q.Transparency=1 q.Visible=true return q
end

-- FOV Circle
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

    local headTopPos=head and (head.Position+Vector3.new(0,head.Size.Y*0.5+0.1,0)) or (root.Position+Vector3.new(0,3.1,0))
    local feetPos=root.Position-Vector3.new(0,3.1,0)

    local htSC=Cam:WorldToScreenPoint(headTopPos)
    local ftSC=Cam:WorldToScreenPoint(feetPos)
    local rootSC=Cam:WorldToScreenPoint(root.Position)
    if rootSC.Z<=0 then clrEsp(player) return end

    eObj[player]=eObj[player] or {}
    local o=eObj[player]

    local topY=math.min(htSC.Y,ftSC.Y)
    local botY=math.max(htSC.Y,ftSC.Y)
    local boxH=math.max(botY-topY,8)
    local boxW=boxH*0.48
    local cx=rootSC.X
    local L=cx-boxW*0.5 local R=cx+boxW*0.5
    local T=topY local B=botY

    local vTL=Vector2.new(L,T) local vTR=Vector2.new(R,T)
    local vBR=Vector2.new(R,B) local vBL=Vector2.new(L,B)
    local dist=myRoot and math.floor((myRoot.Position-root.Position).Magnitude) or 0

    -- ESP LINE
    if S.EspLine then
        if not o.line then o.line=DLine(Vector2.new(0,0),Vector2.new(0,0),Color3.new(1,1,1),2) end
        local vp=Cam.ViewportSize
        o.line.From=Vector2.new(vp.X*0.5,0) o.line.To=Vector2.new(rootSC.X,rootSC.Y) o.line.Visible=true
    elseif o.line then o.line.Visible=false end

    -- ESP BOX
    if S.EspBox then
        if not o.box then o.box=DQuad(vTL,vTR,vBR,vBL,Color3.new(1,1,1),2)
        else o.box.PointA=vTL o.box.PointB=vTR o.box.PointC=vBR o.box.PointD=vBL o.box.Visible=true end
    elseif o.box then o.box.Visible=false end

    -- ESP BOX 3D
    if S.EspBox3D then
        if not o.box3d then o.box3d={} end
        local hw=1.0 local hh=3.0 local rp=root.Position
        local c3={
            rp+Vector3.new(-hw,hh,-hw),rp+Vector3.new(hw,hh,-hw),rp+Vector3.new(hw,hh,hw),rp+Vector3.new(-hw,hh,hw),
            rp+Vector3.new(-hw,-hh,-hw),rp+Vector3.new(hw,-hh,-hw),rp+Vector3.new(hw,-hh,hw),rp+Vector3.new(-hw,-hh,hw),
        }
        local sc3={} local ok3=true
        for i,v3 in ipairs(c3) do local sv=Cam:WorldToScreenPoint(v3) if sv.Z<=0 then ok3=false end sc3[i]=Vector2.new(sv.X,sv.Y) end
        local edges={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
        for ei,e in ipairs(edges) do
            if not o.box3d[ei] then o.box3d[ei]=DLine(Vector2.new(0,0),Vector2.new(0,0),Color3.new(1,1,1),1) end
            if ok3 then o.box3d[ei].From=sc3[e[1]] o.box3d[ei].To=sc3[e[2]] o.box3d[ei].Visible=true
            else o.box3d[ei].Visible=false end
        end
    elseif o.box3d then for _,l in ipairs(o.box3d) do pcall(function() l.Visible=false end) end end

    -- ESP NAME
    if S.EspName then
        if not o.name then o.name=DText(Vector2.new(0,0),"",math.floor(13*SC),RED) end
        o.name.Position=Vector2.new(cx,T-17) o.name.Text=player.Name o.name.Visible=true
    elseif o.name then o.name.Visible=false end

    -- ESP DISTANCE
    if S.EspDistance then
        if not o.dist then o.dist=DText(Vector2.new(0,0),"",math.floor(11*SC),RED) end
        o.dist.Position=Vector2.new(cx,B+4) o.dist.Text=dist.."m" o.dist.Visible=true
    elseif o.dist then o.dist.Visible=false end

    -- ESP HEALTH
    if S.EspHealth then
        if not o.hbg then
            o.hbg=DLine(Vector2.new(0,0),Vector2.new(0,0),Color3.fromRGB(20,20,20),4)
            o.hfill=DLine(Vector2.new(0,0),Vector2.new(0,0),GREEN,4) end
        local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
        local bx=L-7
        o.hbg.From=Vector2.new(bx,T) o.hbg.To=Vector2.new(bx,B) o.hbg.Visible=true
        o.hfill.From=Vector2.new(bx,B) o.hfill.To=Vector2.new(bx,B-boxH*hp) o.hfill.Visible=true
    elseif o.hbg then o.hbg.Visible=false if o.hfill then o.hfill.Visible=false end end

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
                local s0=Cam:WorldToScreenPoint(p0.Position) local s1=Cam:WorldToScreenPoint(p1.Position)
                if s0.Z>0 and s1.Z>0 then
                    if not o.skel[bi] then o.skel[bi]=DLine(Vector2.new(0,0),Vector2.new(0,0),RED,1) end
                    o.skel[bi].From=Vector2.new(s0.X,s0.Y) o.skel[bi].To=Vector2.new(s1.X,s1.Y) o.skel[bi].Visible=true
                end
            else if o.skel[bi] then o.skel[bi].Visible=false end end
        end
    elseif o.skel then for _,l in ipairs(o.skel) do pcall(function() l.Visible=false end) end end
end

-- ═══════════════════════════════════════════════
-- AIM ENGINE
-- ═══════════════════════════════════════════════
local function isAim() return S.EnableFunction and S.EnableAim end
local function isEsp()  return S.EnableFunction and S.EnableEsp  end

local function GetEnemy(fov,part)
    local best,bd=nil,fov
    local mouse=UIS:GetMouseLocation()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if S.TeamCheck and p.Team==LP.Team then continue end
        local c=p.Character if not c then continue end
        local targetPart=part=="Body" and (c:FindFirstChild("HumanoidRootPart")) or
                         part=="Random" and (math.random()<0.5 and c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")) or
                         c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
        if not targetPart then continue end
        local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
        if S.AimVisible then
            local ray=Ray.new(Cam.CFrame.Position,(targetPart.Position-Cam.CFrame.Position).Unit*1000)
            local hit=workspace:FindPartOnRayWithIgnoreList(ray,{LP.Character,workspace.Terrain})
            if not(hit and hit:IsDescendantOf(c)) then continue end
        end
        local sp,vis=Cam:WorldToViewportPoint(targetPart.Position) if not vis then continue end
        local d=(Vector2.new(sp.X,sp.Y)-mouse).Magnitude
        if d<bd then bd=d best=targetPart end
    end
    return best
end

-- AimSilent
local silOrig=nil local silShot=false
UIS.InputBegan:Connect(function(i,gpe)
    if gpe or i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    if not isAim() or not (S.AimSilent or S.AimSilentToggle) then return end
    local t=GetEnemy(S.AimFov,S.AimTarget) if not t then return end
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

-- Fly
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
                    local d=(mr.Position-r2.Position).Magnitude
                    if d<bd then bd=d bt=p end
                end
                target=bt
            end
            if target then
                local tc=target.Character
                local tr=tc and tc:FindFirstChild("HumanoidRootPart")
                local mr=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if tr and mr then mr.CFrame=tr.CFrame*CFrame.new(0,0,-1.5) task.wait(0.05)
                    local hm=tc:FindFirstChildOfClass("Humanoid") if hm then hm.Health=0 end end
            end
            task.wait(0.55)
        end
        tkRun=false
    end)
end

-- Teleport P key
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

-- AutoFire
local autoFireConn=nil

-- ═══════════════════════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    local aim=isAim()
    local esp=isEsp()
    local char=LP.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local mouse=UIS:GetMouseLocation()

    -- AIM MAGNET (RMB)
    if aim and S.AimMagnet and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,S.AimTarget)
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.18) end
    end

    -- AIMBOT (RMB)
    if aim and S.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,S.AimTarget)
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.50) end
    end

    -- AIM ASSIST (RMB)
    if aim and S.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,"Body")
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.07) end
    end

    -- AUTO KILL [FIX] (dalam FOV)
    if aim and S.AutoKillFix then
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local c=p.Character if not c then continue end
            local r2=c:FindFirstChild("HumanoidRootPart") if not r2 then continue end
            local sp,vis=Cam:WorldToViewportPoint(r2.Position) if not vis then continue end
            if (Vector2.new(sp.X,sp.Y)-mouse).Magnitude<=S.AimFov then
                local hm=c:FindFirstChildOfClass("Humanoid") if hm then hm.Health=0 end
            end
        end
    end

    -- AUTO KILL TOGGLE (closest)
    if aim and S.AutoKillToggle then
        local t=GetEnemy(S.AimFov,S.AimTarget)
        if t then
            local hm=t.Parent:FindFirstChildOfClass("Humanoid") if hm then hm.Health=0 end
        end
    end

    -- TELEKILL
    if aim and S.TeleKill then doTK() end

    -- AUTO FIRE (simulate LMB)
    if aim and S.AutoFire then
        local t=GetEnemy(S.AimFov,S.AimTarget)
        if t then
            local vMouseEvent=game:GetService("VirtualInputManager")
            pcall(function()
                vMouseEvent:SendMouseButtonEvent(mouse.X,mouse.Y,0,true,game,0)
                vMouseEvent:SendMouseButtonEvent(mouse.X,mouse.Y,0,false,game,0)
            end)
        end
    end

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
        if flyBV then flyBV.Velocity=dir*(S.SpeedFly*10) end
    else if flyBV then disFly() end end

    -- MISC
    if hum then
        hum.WalkSpeed=S.SpeedHack and 95 or 16
        hum.JumpPower=S.JumpHack  and 135 or 50
    end

    -- GHOST
    if char then
        if S.GhostHack then applyGhost(char,true)
        elseif next(gSaved)~=nil then applyGhost(char,false) end
    end

    -- ESP
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if esp and (S.EspBox or S.EspBox3D or S.EspName or S.EspDistance or S.EspHealth or S.EspLine or S.EspSkeleton) then
            drawEsp(p)
        else clrEsp(p) end
    end

    -- FOV CIRCLE (tengah layar)
    if esp and S.EspFov then
        local vp=Cam.ViewportSize
        fovDraw.Position=Vector2.new(vp.X*0.5,vp.Y*0.5)
        fovDraw.Radius=S.AimFov fovDraw.Visible=true
    else fovDraw.Visible=false end
end)

Players.PlayerRemoving:Connect(function(p) clrEsp(p) end)
print("[ SantaXModsKng v1.12 ] Loaded — SkyFlow")
