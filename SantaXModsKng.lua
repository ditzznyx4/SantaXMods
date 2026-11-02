--[[
  ╔══════════════════════════════════════════╗
  ║       SantaXMods Client  v1.12          ║
  ║   Developer : SkyFlow                   ║
  ║   Youtube   : @Skyflowh4x              ║
  ║   Tiktok    : @Sky.flow77              ║
  ║   Style     : Aerix Client             ║
  ╚══════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
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

-- ═══════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════
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

-- ═══════════════════════════════════════════
-- AERIX PALETTE
-- ═══════════════════════════════════════════
local RED       = Color3.fromRGB(210, 30,  30)
local RED_GLOW  = Color3.fromRGB(180, 20,  20)
local BG_MAIN   = Color3.fromRGB(15,  15,  15)
local BG_SIDE   = Color3.fromRGB(22,  22,  22)
local BG_CARD   = Color3.fromRGB(28,  28,  28)
local BG_ITEM   = Color3.fromRGB(34,  34,  34)
local BG_HOVER  = Color3.fromRGB(42,  42,  42)
local BG_TRACK  = Color3.fromRGB(50,  50,  50)
local WHITE     = Color3.fromRGB(235, 235, 235)
local GRAY      = Color3.fromRGB(150, 150, 150)
local DGRAY     = Color3.fromRGB(70,  70,  70)
local GREEN     = Color3.fromRGB(42,  200, 72)

-- ═══════════════════════════════════════════
-- SCALE (responsive)
-- ═══════════════════════════════════════════
local VP   = Cam.ViewportSize
local BASE = math.max(VP.X, VP.Y)
local SC   = math.clamp(BASE / 1366, 0.78, 1.55)
local BW   = math.floor(560 * SC)
local BH   = math.floor(480 * SC)
local SW   = math.floor(160 * SC)
local TH   = math.floor(54  * SC)
local RH   = math.floor(36  * SC)
local FSL  = math.floor(14  * SC)
local FSM  = math.floor(12  * SC)
local FSS  = math.floor(10  * SC)
local PW   = math.floor(38  * SC)
local PH   = math.floor(20  * SC)
local PDS  = math.floor(14  * SC)
local PAD  = math.floor(8   * SC)
local CARD = math.floor(10  * SC)

-- ═══════════════════════════════════════════
-- BASE HELPERS
-- ═══════════════════════════════════════════
local function Rnd(p,r)
    local o=Instance.new("UICorner") o.CornerRadius=UDim.new(0,r or 6) o.Parent=p end

local function Str(p,c,t)
    local o=Instance.new("UIStroke") o.Color=c o.Thickness=t or 1
    o.ApplyStrokeMode=Enum.ApplyStrokeMode.Border o.Parent=p end

-- Glow simulasi: frame merah besar transparan di belakang
local function MkGlow(parent, size, pos, intensity)
    intensity = intensity or 0.88
    local g=Instance.new("Frame")
    g.Size=UDim2.new(0,size,0,size) g.Position=pos or UDim2.new(0.5,-size/2,0.5,-size/2)
    g.BackgroundColor3=RED_GLOW g.BackgroundTransparency=intensity
    g.BorderSizePixel=0 g.ZIndex=0 g.Parent=parent
    Rnd(g,size) return g
end

local function Fr(par,sz,pos,bg,alpha)
    local f=Instance.new("Frame")
    f.Size=sz or UDim2.new(1,0,0,RH) f.Position=pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3=bg or BG_ITEM f.BackgroundTransparency=alpha or 0
    f.BorderSizePixel=0 f.ClipsDescendants=false f.Parent=par return f
end

local function Tx(par,txt,fs,col,bold,xa)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
    l.Text=txt or "" l.TextSize=fs or FSM
    l.TextColor3=col or WHITE
    l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.TextTruncate=Enum.TextTruncate.AtEnd l.Parent=par return l
end

local function Btn(par,txt,sz,pos,bg)
    local b=Instance.new("TextButton")
    b.Size=sz or UDim2.new(1,0,0,RH) b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=bg or BG_ITEM b.BorderSizePixel=0
    b.Text=txt or "" b.TextColor3=WHITE b.TextSize=FSM
    b.Font=Enum.Font.GothamBold b.AutoButtonColor=false b.Parent=par return b
end

-- Icon button (ImageButton dengan ikon)
local function IconBtn(par,img,sz,pos)
    local b=Instance.new("ImageButton")
    b.Size=sz b.Position=pos
    b.BackgroundTransparency=1 b.Image=img b.Parent=par return b
end

-- ═══════════════════════════════════════════
-- DRAG
-- ═══════════════════════════════════════════
local function MakeDrag(handle,target)
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

-- ═══════════════════════════════════════════
-- TOGGLE SYNC
-- ═══════════════════════════════════════════
local TCB={}
local function Fire(k,v) if TCB[k] then for _,fn in ipairs(TCB[k]) do pcall(fn,v) end end end
local function Reg(k,fn) TCB[k]=TCB[k] or {} table.insert(TCB[k],fn) end

-- ═══════════════════════════════════════════
-- FLOATING ICON (bisa digeser, ada logo)
-- ═══════════════════════════════════════════
local iconSG=Instance.new("ScreenGui")
iconSG.Name="SantaXIcon" iconSG.ResetOnSpawn=false
iconSG.DisplayOrder=1000 iconSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling iconSG.Parent=PGui

-- Container icon (bisa digeser)
local ISIZ=math.floor(62*SC)
local iconWrap=Fr(iconSG,UDim2.new(0,ISIZ,0,ISIZ),UDim2.new(0,14,0.5,-ISIZ/2),BG_MAIN)
iconWrap.Visible=false Rnd(iconWrap,ISIZ) Str(iconWrap,RED,2)
-- Glow merah di belakang icon
MkGlow(iconWrap,ISIZ*2,UDim2.new(0.5,-ISIZ,0.5,-ISIZ),0.82)
-- Logo image
local iconImg=Instance.new("ImageButton")
iconImg.Size=UDim2.new(1,0,1,0) iconImg.BackgroundTransparency=1
iconImg.Image="rbxassetid://104012475483632" iconImg.ZIndex=2 iconImg.Parent=iconWrap
Rnd(iconImg,ISIZ)
MakeDrag(iconWrap,iconWrap)

-- ═══════════════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════════════
local mainSG=Instance.new("ScreenGui")
mainSG.Name="SantaXMain" mainSG.ResetOnSpawn=false
mainSG.DisplayOrder=999 mainSG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling mainSG.Parent=PGui

local win=Fr(mainSG,UDim2.new(0,BW,0,BH+TH),UDim2.new(0.5,-BW/2,0.5,-(BH+TH)/2),BG_MAIN)
Rnd(win,CARD) Str(win,RED,1.5)
-- Ambient red glow di belakang window
MkGlow(mainSG,math.floor(BW*1.2),UDim2.new(0.5,-BW*0.6,0.5,-(BH+TH)*0.6),0.9)

-- ── TITLE BAR (Aerix style) ───────────────────────────────
local tbar=Fr(win,UDim2.new(1,0,0,TH),UDim2.new(0,0,0,0),BG_SIDE)
tbar.ClipsDescendants=true Rnd(tbar,CARD)
-- Garis merah bawah title
local tline=Fr(tbar,UDim2.new(1,0,0,math.floor(1.5*SC)),UDim2.new(0,0,1,-math.floor(1.5*SC)),RED)

-- LOGO ICON di title (ImageLabel)
local logoIcon=Instance.new("ImageLabel")
logoIcon.Size=UDim2.new(0,math.floor(32*SC),0,math.floor(32*SC))
logoIcon.Position=UDim2.new(0,math.floor(10*SC),0.5,-math.floor(16*SC))
logoIcon.BackgroundTransparency=1 logoIcon.Image="rbxassetid://104012475483632"
logoIcon.ZIndex=3 logoIcon.Parent=tbar
Rnd(logoIcon,math.floor(16*SC))

-- Title teks (Aerix: nama produk 2 baris)
local titleWrap=Fr(tbar,
    UDim2.new(0,math.floor(130*SC),1,0),
    UDim2.new(0,math.floor(46*SC),0,0),BG_SIDE)
titleWrap.BackgroundTransparency=1
local titleLine1=Tx(titleWrap,"SantaXMods",math.floor(15*SC),WHITE,true)
titleLine1.Size=UDim2.new(1,0,0,math.floor(18*SC)) titleLine1.Position=UDim2.new(0,0,0,math.floor(6*SC))
local titleLine2=Tx(titleWrap,"Client",math.floor(11*SC),RED,true)
titleLine2.Size=UDim2.new(1,0,0,math.floor(14*SC)) titleLine2.Position=UDim2.new(0,0,0,math.floor(24*SC))
-- versi kecil
local verTx=Tx(titleWrap,"v1.12",FSS,GRAY,false)
verTx.Size=UDim2.new(0,math.floor(30*SC),0,math.floor(12*SC))
verTx.Position=UDim2.new(0,math.floor(60*SC),0,math.floor(26*SC))

-- Kanan title: MINIMIZE + CLOSE icon
local closeS=math.floor(26*SC)

-- Minimize button (icon garis)
local minBtn=Btn(tbar,"—",
    UDim2.new(0,closeS,0,closeS),
    UDim2.new(1,-closeS*2-math.floor(10*SC),0.5,-closeS/2),BG_CARD)
minBtn.TextColor3=GRAY minBtn.TextSize=FSM minBtn.ZIndex=6 Rnd(minBtn,4)

-- Close button (icon X merah)
local closeBtn=Btn(tbar,"✕",
    UDim2.new(0,closeS,0,closeS),
    UDim2.new(1,-closeS-math.floor(6*SC),0.5,-closeS/2),RED2)
closeBtn.TextColor3=WHITE closeBtn.TextSize=FSM closeBtn.ZIndex=6 Rnd(closeBtn,4)
-- Glow merah kecil di close button
MkGlow(tbar,closeS*3,UDim2.new(1,-closeS*2.5,0.5,-closeS*1.5),0.90)

-- Drag dari tbar
MakeDrag(tbar,win)

-- ── BODY ─────────────────────────────────────────────────
local body=Fr(win,UDim2.new(1,0,1,-TH),UDim2.new(0,0,0,TH),BG_MAIN)

-- ── SIDEBAR (Aerix: kategori + sub-items dengan icon) ────
local sidebar=Fr(body,UDim2.new(0,SW,1,0),nil,BG_SIDE)
-- Garis kanan sidebar merah tipis
Fr(sidebar,UDim2.new(0,1,1,0),UDim2.new(1,-1,0,0),RED)

-- ── CONTENT ──────────────────────────────────────────────
local CW=BW-SW-1
local contArea=Fr(body,UDim2.new(0,CW,1,0),UDim2.new(0,SW+1,0,0),BG_MAIN)

-- COLLAPSE/CLOSE logic
local collapsed=false
local function setCollapse(v)
    collapsed=v body.Visible=not v
    win.Size=v and UDim2.new(0,BW,0,TH) or UDim2.new(0,BW,0,BH+TH)
end
minBtn.MouseButton1Click:Connect(function() setCollapse(not collapsed) end)
closeBtn.MouseButton1Click:Connect(function()
    win.Visible=false iconWrap.Visible=true
end)
iconImg.MouseButton1Click:Connect(function()
    iconWrap.Visible=false win.Visible=true
end)

-- ═══════════════════════════════════════════
-- SCROLL PAGE
-- ═══════════════════════════════════════════
local function MkPage()
    local sf=Instance.new("ScrollingFrame")
    sf.Size=UDim2.new(1,0,1,0) sf.BackgroundTransparency=1 sf.BorderSizePixel=0
    sf.ScrollBarThickness=math.floor(3*SC) sf.ScrollBarImageColor3=RED
    sf.CanvasSize=UDim2.new(0,0,0,0) sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Visible=false sf.Parent=contArea
    local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder
    ul.Padding=UDim.new(0,math.floor(4*SC)) ul.Parent=sf
    local up=Instance.new("UIPadding")
    up.PaddingLeft=UDim.new(0,PAD) up.PaddingRight=UDim.new(0,PAD)
    up.PaddingTop=UDim.new(0,PAD) up.PaddingBottom=UDim.new(0,PAD)
    up.Parent=sf return sf
end

-- ═══════════════════════════════════════════
-- AERIX CARD WRAPPER
-- ═══════════════════════════════════════════
local function MkCard(page,order)
    local card=Fr(page,UDim2.new(1,0,0,0),nil,BG_CARD)
    Rnd(card,CARD) Str(card,DGRAY,0.5)
    card.AutomaticSize=Enum.AutomaticSize.Y card.LayoutOrder=order
    local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder
    ul.Padding=UDim.new(0,0) ul.Parent=card
    local up=Instance.new("UIPadding")
    up.PaddingLeft=UDim.new(0,0) up.PaddingRight=UDim.new(0,0)
    up.PaddingTop=UDim.new(0,0) up.PaddingBottom=UDim.new(0,math.floor(4*SC))
    up.Parent=card return card
end

-- ═══════════════════════════════════════════
-- CARD HEADER (Aerix: icon + title + toggle kanan)
-- ═══════════════════════════════════════════
local function MkCardHdr(card,iconTxt,title,key)
    local h=Fr(card,UDim2.new(1,0,0,math.floor(36*SC)),nil,BG_CARD) h.LayoutOrder=0
    Rnd(h,CARD)
    -- Garis merah kiri (Aerix ciri khas)
    Fr(h,UDim2.new(0,math.floor(3*SC),0.65,0),UDim2.new(0,0,0.175,0),RED)
    -- Icon lingkaran merah
    local iconCircle=Fr(h,UDim2.new(0,math.floor(22*SC),0,math.floor(22*SC)),
        UDim2.new(0,math.floor(10*SC),0.5,-math.floor(11*SC)),RED)
    Rnd(iconCircle,math.floor(11*SC))
    local iconL=Tx(iconCircle,iconTxt,FSS,WHITE,true,Enum.TextXAlignment.Center) iconL.Size=UDim2.new(1,0,1,0)
    -- Title
    local titleL=Tx(h,title,FSM,WHITE,true)
    titleL.Size=UDim2.new(1,-math.floor(80*SC),1,0)
    titleL.Position=UDim2.new(0,math.floor(38*SC),0,0)

    if key then
        -- Toggle pill kanan
        local PW2=math.floor(38*SC) local PH2=math.floor(20*SC) local PD2=math.floor(14*SC)
        local pillBg=Fr(h,UDim2.new(0,PW2,0,PH2),
            UDim2.new(1,-(PW2+8),0.5,-PH2/2),S[key] and RED or DGRAY) Rnd(pillBg,PH2)
        local dot=Fr(pillBg,UDim2.new(0,PD2,0,PD2),UDim2.new(0,3,0.5,-PD2/2),WHITE) Rnd(dot,PD2)
        local function RefHdr(val)
            TS:Create(pillBg,TweenInfo.new(0.1),{BackgroundColor3=val and RED or DGRAY}):Play()
            TS:Create(dot,TweenInfo.new(0.1),{Position=val and UDim2.new(1,-(PD2+3),0.5,-PD2/2) or UDim2.new(0,3,0.5,-PD2/2)}):Play()
        end
        local hit=Btn(h,"",UDim2.new(1,0,1,0)) hit.BackgroundTransparency=1 hit.ZIndex=10
        hit.MouseButton1Click:Connect(function() S[key]=not S[key] RefHdr(S[key]) Fire(key,S[key]) end)
        Reg(key,RefHdr)
    end
    return h
end

-- ═══════════════════════════════════════════
-- TOGGLE ROW (Aerix: checkbox style + pill)
-- ═══════════════════════════════════════════
local function MkToggle(parent,lTxt,key,order,isCard)
    local bg=isCard and BG_CARD or BG_ITEM
    local row=Fr(parent,UDim2.new(1,0,0,RH),nil,bg) row.LayoutOrder=order
    row.MouseEnter:Connect(function() row.BackgroundColor3=BG_HOVER end)
    row.MouseLeave:Connect(function() row.BackgroundColor3=bg end)

    -- Label
    local lbl=Tx(row,"   "..lTxt,FSM,WHITE,false) lbl.Size=UDim2.new(1,-(PW+14),1,0)

    -- Pill toggle
    local pillBg=Fr(row,UDim2.new(0,PW,0,PH),
        UDim2.new(1,-(PW+7),0.5,-PH/2),S[key] and RED or DGRAY) Rnd(pillBg,PH)
    local dot=Fr(pillBg,UDim2.new(0,PDS,0,PDS),UDim2.new(0,3,0.5,-PDS/2),WHITE) Rnd(dot,PDS)

    local function Refresh(val)
        TS:Create(pillBg,TweenInfo.new(0.1),{BackgroundColor3=val and RED or DGRAY}):Play()
        TS:Create(dot,TweenInfo.new(0.1),{Position=val and UDim2.new(1,-(PDS+3),0.5,-PDS/2) or UDim2.new(0,3,0.5,-PDS/2)}):Play()
    end
    local hit=Btn(row,"",UDim2.new(1,0,1,0)) hit.BackgroundTransparency=1 hit.ZIndex=10
    hit.MouseButton1Click:Connect(function() S[key]=not S[key] Refresh(S[key]) Fire(key,S[key]) end)
    Reg(key,Refresh) return row,Refresh
end

-- ═══════════════════════════════════════════
-- SLIDER (Aerix style)
-- ═══════════════════════════════════════════
local function MkSlider(parent,lTxt,key,mn,mx,order,isCard)
    local bg=isCard and BG_CARD or BG_ITEM
    local RHS=math.floor(46*SC)
    local row=Fr(parent,UDim2.new(1,0,0,RHS),nil,bg) row.LayoutOrder=order
    row.MouseEnter:Connect(function() row.BackgroundColor3=BG_HOVER end)
    row.MouseLeave:Connect(function() row.BackgroundColor3=bg end)
    local lbl=Tx(row,"   "..lTxt,FSM,WHITE,false)
    lbl.Size=UDim2.new(0.55,0,0,math.floor(18*SC)) lbl.Position=UDim2.new(0,0,0,math.floor(4*SC))
    local valL=Tx(row,tostring(S[key]),FSM,RED,true,Enum.TextXAlignment.Right)
    valL.Size=UDim2.new(0.35,0,0,math.floor(18*SC)) valL.Position=UDim2.new(0.64,-PAD,0,math.floor(4*SC))
    local TH2=math.floor(6*SC)
    local trkBg=Fr(row,UDim2.new(1,-PAD*4,0,TH2),UDim2.new(0,PAD*2,0,RHS-math.floor(12*SC)),BG_TRACK) Rnd(trkBg,TH2)
    local pct=math.clamp((S[key]-mn)/(mx-mn),0,1)
    local fill=Fr(trkBg,UDim2.new(pct,0,1,0),nil,RED) Rnd(fill,TH2)
    local DT=math.floor(15*SC)
    local thm=Fr(trkBg,UDim2.new(0,DT,0,DT),UDim2.new(pct,-DT/2,0.5,-DT/2),WHITE) Rnd(thm,DT)
    Str(thm,DGRAY,1)
    local sliding=false
    local function updateSlider(px)
        local ap=trkBg.AbsolutePosition local as=trkBg.AbsoluteSize
        if as.X==0 then return end
        local rel=math.clamp((px-ap.X)/as.X,0,1)
        local nv=math.floor(mn+rel*(mx-mn))
        S[key]=nv fill.Size=UDim2.new(rel,0,1,0)
        thm.Position=UDim2.new(rel,-DT/2,0.5,-DT/2) valL.Text=tostring(nv)
    end
    local function onB(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true updateSlider(i.Position.X) end
    end
    local function onC(i)
        if not sliding then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then updateSlider(i.Position.X) end
    end
    local function onE(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
    end
    local hitZ=Btn(row,"",UDim2.new(1,0,1,0)) hitZ.BackgroundTransparency=1 hitZ.ZIndex=10
    hitZ.InputBegan:Connect(onB) trkBg.InputBegan:Connect(onB) thm.InputBegan:Connect(onB) fill.InputBegan:Connect(onB)
    UIS.InputChanged:Connect(onC) UIS.InputEnded:Connect(onE)
end

-- ═══════════════════════════════════════════
-- DROPDOWN
-- ═══════════════════════════════════════════
local ddFr=nil
local function MkDropdown(parent,lTxt,key,opts,order,isCard)
    local bg=isCard and BG_CARD or BG_ITEM
    local row=Fr(parent,UDim2.new(1,0,0,RH),nil,bg) row.LayoutOrder=order
    local lbl=Tx(row,"   "..lTxt,FSS,GRAY,false) lbl.Size=UDim2.new(0.42,0,1,0)
    local DDW=math.floor(140*SC)
    local ddB=Btn(row,S[key].."  ▼",UDim2.new(0,DDW,0,math.floor(24*SC)),
        UDim2.new(1,-DDW-6,0.5,-12),BG_ITEM)
    Rnd(ddB,5) Str(ddB,DGRAY,1)
    ddB.TextColor3=WHITE ddB.TextSize=FSS ddB.ZIndex=10
    ddB.MouseButton1Click:Connect(function()
        if ddFr then ddFr:Destroy() ddFr=nil return end
        ddFr=Fr(mainSG,UDim2.new(0,DDW,0,0),nil,BG_CARD)
        Rnd(ddFr,6) Str(ddFr,DGRAY,1)
        ddFr.AutomaticSize=Enum.AutomaticSize.Y ddFr.ZIndex=30
        local ap=ddB.AbsolutePosition
        ddFr.Position=UDim2.new(0,ap.X,0,ap.Y+math.floor(28*SC))
        local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder ul.Parent=ddFr
        for i,opt in ipairs(opts) do
            local ib=Btn(ddFr,"  "..opt,UDim2.new(1,0,0,math.floor(28*SC))) ib.LayoutOrder=i
            ib.TextXAlignment=Enum.TextXAlignment.Left ib.TextSize=FSM ib.BackgroundColor3=BG_CARD ib.ZIndex=31
            ib.MouseEnter:Connect(function() ib.BackgroundColor3=BG_HOVER end)
            ib.MouseLeave:Connect(function() ib.BackgroundColor3=BG_CARD end)
            ib.MouseButton1Click:Connect(function()
                S[key]=opt ddB.Text=opt.."  ▼" ddFr:Destroy() ddFr=nil end)
        end
    end)
end

-- ═══════════════════════════════════════════
-- SIDEBAR (Aerix: kategori label + tab items dengan icon)
-- ═══════════════════════════════════════════
local sUL=Instance.new("UIListLayout") sUL.SortOrder=Enum.SortOrder.LayoutOrder
sUL.Padding=UDim.new(0,2) sUL.Parent=sidebar
local sPad=Instance.new("UIPadding")
sPad.PaddingTop=UDim.new(0,math.floor(8*SC)) sPad.PaddingLeft=UDim.new(0,math.floor(6*SC))
sPad.PaddingRight=UDim.new(0,math.floor(6*SC)) sPad.Parent=sidebar

local pages={} local tabBtns={} local activeTab=""

-- Kategori label (Aerix style: teks abu kecil)
local function MkCatLabel(txt,order)
    local row=Fr(sidebar,UDim2.new(1,0,0,math.floor(22*SC)),nil,BG_SIDE) row.LayoutOrder=order
    local lbl=Tx(row,"  "..txt,FSS,GRAY,false) lbl.Size=UDim2.new(1,0,1,0) return row
end

-- Tab item (Aerix: icon + teks, aktif = putih + garis merah kiri)
local function MkTabItem(txt,iconTxt,order)
    local pg=MkPage() pages[txt]=pg
    local TAB_H=math.floor(34*SC)
    local tb=Fr(sidebar,UDim2.new(1,0,0,TAB_H),nil,BG_SIDE) tb.LayoutOrder=order
    Rnd(tb,5)
    tb.MouseEnter:Connect(function() if activeTab~=txt then tb.BackgroundColor3=BG_CARD end end)
    tb.MouseLeave:Connect(function() if activeTab~=txt then tb.BackgroundColor3=BG_SIDE end end)
    -- Garis merah kiri (aktif)
    local leftBar=Fr(tb,UDim2.new(0,math.floor(3*SC),0.6,0),UDim2.new(0,0,0.2,0),RED)
    leftBar.Visible=false
    -- Icon bulat kecil
    local iconC=Fr(tb,UDim2.new(0,math.floor(20*SC),0,math.floor(20*SC)),
        UDim2.new(0,math.floor(8*SC),0.5,-math.floor(10*SC)),DGRAY)
    Rnd(iconC,math.floor(10*SC))
    local iconL=Tx(iconC,iconTxt,FSS,WHITE,true,Enum.TextXAlignment.Center) iconL.Size=UDim2.new(1,0,1,0)
    -- Label
    local lbl=Tx(tb,txt,FSS,GRAY,false) lbl.Position=UDim2.new(0,math.floor(32*SC),0,0)
    lbl.Size=UDim2.new(1,-math.floor(36*SC),1,0)

    local hit=Btn(tb,"",UDim2.new(1,0,1,0)) hit.BackgroundTransparency=1 hit.ZIndex=10
    hit.MouseButton1Click:Connect(function()
        activeTab=txt
        for n,pg2 in pairs(pages) do pg2.Visible=(n==txt) end
        for n,data in pairs(tabBtns) do
            local isActive=(n==txt)
            data.bar.Visible=isActive
            data.iconC.BackgroundColor3=isActive and RED or DGRAY
            data.lbl.TextColor3=isActive and WHITE or GRAY
            data.lbl.Font=isActive and Enum.Font.GothamBold or Enum.Font.Gotham
            data.tb.BackgroundColor3=isActive and BG_CARD or BG_SIDE
        end
    end)

    tabBtns[txt]={tb=tb,bar=leftBar,iconC=iconC,lbl=lbl}
    return pg
end

-- Build sidebar
MkCatLabel("General",1)
local pFn=MkTabItem("Function","F",2)
MkCatLabel("Combat",10)
local pA=MkTabItem("AimBot","A",11)
MkCatLabel("Visuals",20)
local pE=MkTabItem("Esp","E",21)
MkCatLabel("Movement",30)
local pFT=MkTabItem("Fly/Tele","M",31)
MkCatLabel("Extra",40)
local pM=MkTabItem("Misc","X",41)

-- ═══════════════════════════════════════════
-- PAGE: FUNCTION
-- ═══════════════════════════════════════════
-- Card 1: Master Switches
local card1=MkCard(pFn,1)
MkCardHdr(card1,"S","Function",nil)
MkToggle(card1,"Enable Function","EnableFunction",1,true)
MkToggle(card1,"Enable Aim","EnableAim",2,true)
MkToggle(card1,"Enable Esp","EnableEsp",3,true)

-- Card 2: Info
local card2=MkCard(pFn,2)
MkCardHdr(card2,"i","About",nil)
local infoRow=Fr(card2,UDim2.new(1,0,0,math.floor(80*SC)),nil,BG_CARD) infoRow.LayoutOrder=1
local ipad=Instance.new("UIPadding") ipad.PaddingLeft=UDim.new(0,10) ipad.PaddingTop=UDim.new(0,6) ipad.Parent=infoRow
local function irow(txt,y,col,bold)
    local l=Tx(infoRow,txt,FSS,col or GRAY,bold or false)
    l.Size=UDim2.new(1,-10,0,math.floor(13*SC)) l.Position=UDim2.new(0,0,0,math.floor(y*SC)) return l
end
irow("Release Version Official  |  Details",2,RED,true)
irow("SantaXMods has been released with official version.",18)
irow("Developer: SkyFlow  |  v1.12",42) irow("Youtube: @Skyflowh4x   TikTok: @Sky.flow77",56)

-- ═══════════════════════════════════════════
-- PAGE: AIMBOT
-- ═══════════════════════════════════════════
-- Card Aimbot
local aimCard=MkCard(pA,1)
MkCardHdr(aimCard,"A","Aimbot",nil)
-- Aim Target label
local tgtRow=Fr(aimCard,UDim2.new(1,0,0,math.floor(20*SC)),nil,BG_CARD) tgtRow.LayoutOrder=1
local tgtL=Tx(tgtRow,"   • Aim Target:",FSS,GRAY,false) tgtL.Size=UDim2.new(1,0,1,0)
MkDropdown(aimCard,"","AimTarget",{"Head","Body","Random"},2,true)
MkSlider(aimCard,"Aim Distance","AimFov",0,1000,3,true)

local div1=Fr(aimCard,UDim2.new(1,-PAD*2,0,1),UDim2.new(0,PAD,0,0),DGRAY) div1.LayoutOrder=4

MkToggle(aimCard,"Aimbot",           "Aimbot",         5,true)
MkToggle(aimCard,"Aim Assist",       "AimAssist",      6,true)
MkToggle(aimCard,"Aim Silent",       "AimSilent",      7,true)
MkToggle(aimCard,"Auto Fire",        "AutoFire",       8,true)
MkToggle(aimCard,"Auto Kill [FIX]",  "AutoKillFix",    9,true)
MkToggle(aimCard,"Auto Kill Toggle", "AutoKillToggle", 10,true)
MkToggle(aimCard,"Aim Silent Toggle","AimSilentToggle",11,true)
MkToggle(aimCard,"Aim Visible",      "AimVisible",     12,true)
MkToggle(aimCard,"Aim Magnet",       "AimMagnet",      13,true)

-- ═══════════════════════════════════════════
-- PAGE: ESP
-- ═══════════════════════════════════════════
local espCard=MkCard(pE,1)
MkCardHdr(espCard,"E","Esp Function",nil)
MkToggle(espCard,"Esp Line",     "EspLine",    1,true)
MkToggle(espCard,"Esp Box",      "EspBox",     2,true)
MkToggle(espCard,"Esp Box 3D",   "EspBox3D",   3,true)
MkToggle(espCard,"Esp Health",   "EspHealth",  4,true)
MkToggle(espCard,"Esp Name",     "EspName",    5,true)
MkToggle(espCard,"Esp Distance", "EspDistance",6,true)
MkToggle(espCard,"Esp Skeleton", "EspSkeleton",7,true)
MkToggle(espCard,"Esp Fov",      "EspFov",     8,true)

-- ═══════════════════════════════════════════
-- PAGE: FLY/TELE
-- ═══════════════════════════════════════════
local flyCard=MkCard(pFT,1)
MkCardHdr(flyCard,"F","Fly Function",nil)
MkToggle(flyCard,"Fly","Fly",1,true)

local afRow=Fr(flyCard,UDim2.new(1,0,0,RH),nil,BG_CARD) afRow.LayoutOrder=2
local afL=Tx(afRow,"   Auto Fly",FSM,WHITE,false) afL.Size=UDim2.new(1,-50,1,0)
local afLB=Btn(afRow,"⊞",UDim2.new(0,math.floor(34*SC),0,math.floor(22*SC)),UDim2.new(1,-40,0.5,-11),BG_ITEM)
Rnd(afLB,4) Str(afLB,DGRAY,1) afLB.TextColor3=RED afLB.ZIndex=10

MkToggle(flyCard,"Hit Fly","HitFly",3,true)
MkSlider(flyCard,"Speed Fly","SpeedFly",1,10,4,true)
MkSlider(flyCard,"High Hit Fly","HighHitFly",0,100,5,true)
MkSlider(flyCard,"Speed Hit Fly","SpeedHitFly",0,150,6,true)

local teleCard=MkCard(pFT,2)
MkCardHdr(teleCard,"T","Teleport Function",nil)
MkToggle(teleCard,"Teleport Player","TeleportPlayer",1,true)
MkToggle(teleCard,"TeleKill","TeleKill",2,true)

-- Target Dropdown
local ddTgtFr=nil
local tgtRow2=Fr(teleCard,UDim2.new(1,0,0,RH),nil,BG_CARD) tgtRow2.LayoutOrder=3
local tgtL2=Tx(tgtRow2,"   Select Target",FSS,WHITE,false) tgtL2.Size=UDim2.new(0.5,0,1,0)
local DDW=math.floor(110*SC)
local ddB2=Btn(tgtRow2,S.SelectedTarget or "None  ▼",UDim2.new(0,DDW,0,math.floor(22*SC)),UDim2.new(1,-DDW-6,0.5,-11),BG_ITEM)
Rnd(ddB2,4) Str(ddB2,DGRAY,1) ddB2.TextColor3=GRAY ddB2.TextSize=FSS ddB2.ZIndex=10
ddB2.MouseButton1Click:Connect(function()
    if ddTgtFr then ddTgtFr:Destroy() ddTgtFr=nil return end
    ddTgtFr=Fr(mainSG,UDim2.new(0,DDW+10,0,0),nil,BG_CARD)
    Rnd(ddTgtFr,5) Str(ddTgtFr,DGRAY,1) ddTgtFr.AutomaticSize=Enum.AutomaticSize.Y ddTgtFr.ZIndex=30
    local ap=ddB2.AbsolutePosition ddTgtFr.Position=UDim2.new(0,ap.X,0,ap.Y+math.floor(26*SC))
    local ul=Instance.new("UIListLayout") ul.SortOrder=Enum.SortOrder.LayoutOrder ul.Parent=ddTgtFr
    local ct=0
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end ct=ct+1
        local ib=Btn(ddTgtFr,"  "..p.Name,UDim2.new(1,0,0,math.floor(26*SC)))
        ib.TextXAlignment=Enum.TextXAlignment.Left ib.TextSize=FSS ib.LayoutOrder=ct ib.BackgroundColor3=BG_CARD ib.ZIndex=31
        ib.MouseEnter:Connect(function() ib.BackgroundColor3=BG_HOVER end)
        ib.MouseLeave:Connect(function() ib.BackgroundColor3=BG_CARD end)
        ib.MouseButton1Click:Connect(function()
            S.SelectedTarget=p.Name ddB2.Text=p.Name.."  ▼" ddB2.TextColor3=RED
            ddTgtFr:Destroy() ddTgtFr=nil end)
    end
    if ct==0 then local n=Tx(ddTgtFr,"  No players",FSS,GRAY) n.Size=UDim2.new(1,0,0,math.floor(24*SC)) end
end)

-- Auto Fly UI
local afGui=nil local afBV=nil
afLB.MouseButton1Click:Connect(function()
    if afGui then afGui:Destroy() afGui=nil S.AutoFlyStep=0
        if afBV then afBV:Destroy() afBV=nil end
        local c=LP.Character local h=c and c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=false end return
    end
    afGui=Instance.new("ScreenGui") afGui.Name="AutoFlyUI" afGui.ResetOnSpawn=false afGui.DisplayOrder=1001 afGui.Parent=PGui
    local afw=Fr(afGui,UDim2.new(0,math.floor(185*SC),0,math.floor(88*SC)),UDim2.new(0,90,0.65,0),BG_MAIN)
    Rnd(afw,8) Str(afw,RED,1.5)
    MkGlow(afw,math.floor(100*SC),UDim2.new(0.5,-50*SC,0.5,-50*SC),0.88)
    local ahdr=Fr(afw,UDim2.new(1,0,0,math.floor(28*SC)),nil,BG_SIDE) Rnd(ahdr,8)
    Fr(ahdr,UDim2.new(0,3,0.6,0),UDim2.new(0,0,0.2,0),RED)
    local ahl=Tx(ahdr,"  Auto Fly",FSS,WHITE,true,Enum.TextXAlignment.Center) ahl.Size=UDim2.new(1,0,1,0)
    MakeDrag(ahdr,afw)
    local stepL=Tx(afw,"Ready",FSS,GRAY,false,Enum.TextXAlignment.Center)
    stepL.Size=UDim2.new(1,0,0,math.floor(18*SC)) stepL.Position=UDim2.new(0,0,0,math.floor(30*SC))
    local cb=Btn(afw,"Click 1 — Set",UDim2.new(1,-10,0,math.floor(24*SC)),UDim2.new(0,5,0,math.floor(56*SC)),RED)
    Rnd(cb,5) cb.TextSize=FSS
    local steps={[0]={b="Click 1 — Set",l="Ready"},[1]={b="Click 2 — Fly",l="Set ✓"},[2]={b="Click 3 — Lock",l="Flying..."},[3]={b="Locked ✓",l="Locked"}}
    local function upd() local d=steps[S.AutoFlyStep] if d then cb.Text=d.b stepL.Text=d.l end end
    cb.MouseButton1Click:Connect(function()
        local char=LP.Character local root=char and char:FindFirstChild("HumanoidRootPart") if not char or not root then return end
        if S.AutoFlyStep==0 then
            S.AutoFlyStep=1 local h2=char:FindFirstChildOfClass("Humanoid") if h2 then h2.PlatformStand=true end root.CFrame=root.CFrame+Vector3.new(0,1.2,0)
        elseif S.AutoFlyStep==1 then
            S.AutoFlyStep=2 if afBV then afBV:Destroy() end
            afBV=Instance.new("BodyVelocity") afBV.Velocity=Vector3.new(0,S.SpeedFly*7,0) afBV.MaxForce=Vector3.new(0,1e6,0) afBV.Parent=root
        elseif S.AutoFlyStep==2 then
            S.AutoFlyStep=3 if afBV then afBV:Destroy() afBV=nil end
            local bp=Instance.new("BodyPosition") bp.Position=root.Position bp.MaxForce=Vector3.new(1e6,1e6,1e6) bp.D=600 bp.P=12000 bp.Parent=root afBV=bp
        end upd()
    end)
end)

-- ═══════════════════════════════════════════
-- PAGE: MISC
-- ═══════════════════════════════════════════
local miscCard=MkCard(pM,1)
MkCardHdr(miscCard,"X","Misc Function",nil)
MkToggle(miscCard,"SpeedHack","SpeedHack",1,true)
MkToggle(miscCard,"JumpHack","JumpHack",2,true)
MkToggle(miscCard,"GhostHack","GhostHack",3,true)

-- Aktifkan tab pertama
do
    activeTab="Function" pages["Function"].Visible=true
    local d=tabBtns["Function"]
    d.bar.Visible=true d.iconC.BackgroundColor3=RED d.lbl.TextColor3=WHITE
    d.lbl.Font=Enum.Font.GothamBold d.tb.BackgroundColor3=BG_CARD
end

-- ═══════════════════════════════════════════
-- ESP ENGINE (Drawing API)
-- ═══════════════════════════════════════════
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
local function DText(pos,txt,sz,col)
    local d=Drawing.new("Text") d.Position=pos d.Text=txt d.Size=sz or 13
    d.Color=col or RED d.Outline=true d.Center=true d.Visible=true return d
end
local function DQuad(a,b,c2,d2,col,thick)
    local q=Drawing.new("Quad") q.PointA=a q.PointB=b q.PointC=c2 q.PointD=d2
    q.Color=col or Color3.new(1,1,1) q.Thickness=thick or 2 q.Filled=false q.Transparency=1 q.Visible=true return q
end
local fovDraw=Drawing.new("Circle")
fovDraw.Radius=150 fovDraw.Color=RED fovDraw.Thickness=1 fovDraw.Filled=false fovDraw.Transparency=1 fovDraw.Visible=false

local function drawEsp(player)
    if not player.Character then clrEsp(player) return end
    local c=player.Character
    local root=c:FindFirstChild("HumanoidRootPart") local head=c:FindFirstChild("Head")
    local hum=c:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health<=0 then clrEsp(player) return end
    local myRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and (myRoot.Position-root.Position).Magnitude>400 then clrEsp(player) return end
    local headP=head and (head.Position+Vector3.new(0,head.Size.Y*0.5+0.1,0)) or (root.Position+Vector3.new(0,3.1,0))
    local htSC=Cam:WorldToScreenPoint(headP)
    local ftSC=Cam:WorldToScreenPoint(root.Position-Vector3.new(0,3.1,0))
    local rootSC=Cam:WorldToScreenPoint(root.Position)
    if rootSC.Z<=0 then clrEsp(player) return end
    eObj[player]=eObj[player] or {}
    local o=eObj[player]
    local topY=math.min(htSC.Y,ftSC.Y) local botY=math.max(htSC.Y,ftSC.Y)
    local boxH=math.max(botY-topY,8) local boxW=boxH*0.48 local cx=rootSC.X
    local L=cx-boxW*0.5 local R=cx+boxW*0.5 local T=topY local B=botY
    local dist=myRoot and math.floor((myRoot.Position-root.Position).Magnitude) or 0
    if S.EspLine then
        if not o.line then o.line=DLine(Vector2.new(0,0),Vector2.new(0,0),Color3.new(1,1,1),2) end
        local vp=Cam.ViewportSize o.line.From=Vector2.new(vp.X*0.5,0) o.line.To=Vector2.new(cx,rootSC.Y) o.line.Visible=true
    elseif o.line then o.line.Visible=false end
    if S.EspBox then
        if not o.box then o.box=DQuad(Vector2.new(L,T),Vector2.new(R,T),Vector2.new(R,B),Vector2.new(L,B),Color3.new(1,1,1),2)
        else o.box.PointA=Vector2.new(L,T) o.box.PointB=Vector2.new(R,T) o.box.PointC=Vector2.new(R,B) o.box.PointD=Vector2.new(L,B) o.box.Visible=true end
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
            o.hfill=DLine(Vector2.new(0,0),Vector2.new(0,0),GREEN,4) end
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

-- ═══════════════════════════════════════════
-- AIM ENGINE
-- ═══════════════════════════════════════════
local function isAim() return S.EnableFunction and S.EnableAim end
local function isEsp()  return S.EnableFunction and S.EnableEsp  end

local function GetTP(c,pn)
    if pn=="Body" then return c:FindFirstChild("HumanoidRootPart")
    elseif pn=="Random" then return math.random()<0.5 and c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
    else return c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart") end
end
local function IsVis(fp,tp)
    local ray=Ray.new(fp,(tp.Position-fp).Unit*1000)
    local hit=workspace:FindPartOnRayWithIgnoreList(ray,{LP.Character,workspace.Terrain})
    return hit and hit:IsDescendantOf(tp.Parent)
end
local function GetEnemy(fov,pn)
    local best,bd=nil,fov local mouse=UIS:GetMouseLocation() local camPos=Cam.CFrame.Position
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end if S.TeamCheck and p.Team==LP.Team then continue end
        local c=p.Character if not c then continue end
        local tp=GetTP(c,pn) if not tp then continue end
        local hm=c:FindFirstChildOfClass("Humanoid") if hm and hm.Health<=0 then continue end
        if S.AimVisible and not IsVis(camPos,tp) then continue end
        local sp,vis=Cam:WorldToViewportPoint(tp.Position) if not vis then continue end
        local d=(Vector2.new(sp.X,sp.Y)-mouse).Magnitude if d<bd then bd=d best=tp end
    end
    return best
end

-- Sync
Reg("AimSilent",function(v) if S.AimSilentToggle~=v then S.AimSilentToggle=v Fire("AimSilentToggle",v) end end)
Reg("AimSilentToggle",function(v) if S.AimSilent~=v then S.AimSilent=v Fire("AimSilent",v) end end)
Reg("AutoKillFix",function(v) if S.AutoKillToggle~=v then S.AutoKillToggle=v Fire("AutoKillToggle",v) end end)
Reg("AutoKillToggle",function(v) if S.AutoKillFix~=v then S.AutoKillFix=v Fire("AutoKillFix",v) end end)

-- Silent
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
                local saved=Cam.CFrame Cam.CFrame=CFrame.new(Cam.CFrame.Position,t.Position)
                pcall(function()
                    local vim=game:GetService("VirtualInputManager") local m=UIS:GetMouseLocation()
                    vim:SendMouseButtonEvent(m.X,m.Y,0,true,game,0) task.wait(0.002) vim:SendMouseButtonEvent(m.X,m.Y,0,false,game,0)
                end)
                Cam.CFrame=saved
            end
            task.wait(0.01)
        end
        afireRun=false
    end)
end

-- AutoKill
local akRun=false
local function ghostKill(tc)
    if not tc then return end local hm=tc:FindFirstChildOfClass("Humanoid") if not hm or hm.Health<=0 then return end
    pcall(function() hm.Health=0 end)
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
                    if p==LP then continue end local c=p.Character if not c then continue end
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
                    if p==LP then continue end local c=p.Character if not c then continue end
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

-- ═══════════════════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    local aim=isAim() local esp=isEsp()
    local char=LP.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
    local mouse=UIS:GetMouseLocation()

    if aim and S.Aimbot and not silActive then
        local t=GetEnemy(S.AimFov,S.AimTarget)
        if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.6) end
    end
    if aim and S.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,"Body") if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.07) end
    end
    if aim and S.AimMagnet and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetEnemy(S.AimFov,S.AimTarget) if t then Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,t.Position),0.18) end
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
        fovDraw.Position=Vector2.new(vp.X*0.5,vp.Y*0.5) fovDraw.Radius=S.AimFov fovDraw.Visible=true
    else fovDraw.Visible=false end
end)

Players.PlayerRemoving:Connect(function(p) clrEsp(p) end)
print("[ SantaXMods Client v1.12 ] — SkyFlow")
