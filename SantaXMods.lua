-- ╔══════════════════════════════════════════════╗
-- ║           SantaX Mods — Arsenal FPS         ║
-- ║  Created By : Astra                         ║
-- ║  Game       : Arsenal (& FPS Roblox)        ║
-- ╚══════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local StarterGui       = game:GetService("StarterGui")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end
local Camera = Workspace.CurrentCamera

-- ══════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════
local State = {
    EnableFeature=false, EnableAim=false, EnableEsp=false,
    AimbotFire=false, AimbotLegit=false, AimAssist=false,
    AimSilent=false, AimVisible=false,
    AimMagnet=false, AimKill=false,
    AimTarget="Body", AimFov=90,
    EspLine=false, EspBox=false, EspHitbox3D=false,
    EspHealth=false, EspDistance=false, EspName=false, EspSkeleton=false,
    SpeedHack=false, JumpBoost=false, DoubleJump=false,
    TeleportToggle=false, FlyAuto=false, FlyToPlayer=false,
    FastReload=false, SpeedFire=false,
    TeleportTarget=nil,
    _flyAutoConn=nil, _flyTpConn=nil,
    JumpCount=0,
}

-- ══════════════════════════════════════════════
-- UTILITY
-- ══════════════════════════════════════════════
local function getChar(p)   return p and p.Character end
local function getRoot(p)
    local c=getChar(p)
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end
local function getHum(p)
    local c=getChar(p)
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getHead(p)
    local c=getChar(p)
    return c and c:FindFirstChild("Head")
end
local function isAlive(p)
    local h=getHum(p) return h and h.Health>0
end
local function isEnemy(p)
    if p==LocalPlayer then return false end
    if LocalPlayer.Team and p.Team and LocalPlayer.Team==p.Team then return false end
    return true
end
local function getEnemies()
    local t={}
    for _,p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and isAlive(p) then t[#t+1]=p end
    end
    return t
end

-- Visibility check: apakah part bisa dilihat dari kamera (tidak diblok tembok)
-- Return true = bisa dilihat, false = diblok
local function isVisible(part)
    local origin = Camera.CFrame.Position
    local dir    = part.Position - origin
    local rp     = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local excl = {}
    for _,p in ipairs(Players:GetPlayers()) do
        local c=getChar(p) if c then table.insert(excl,c) end
    end
    rp.FilterDescendantsInstances = excl
    local result = Workspace:Raycast(origin, dir, rp)
    return result == nil  -- nil = tidak kena apapun = terlihat
end

local function getTargetPart(p)
    local t=State.AimTarget
    if t=="Random" then t=math.random(1,2)==1 and "Head" or "Body" end
    local c=getChar(p) if not c then return nil end
    if t=="Head" then return c:FindFirstChild("Head")
    else return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") end
end

-- Closest enemy dalam FoV radius
-- visibleOnly=true → hanya yang bisa dilihat kamera (AimVisible logic)
local function getClosest(visibleOnly)
    local cx=Camera.ViewportSize.X/2
    local cy=Camera.ViewportSize.Y/2
    local center=Vector2.new(cx,cy)
    local radius=(State.AimFov/360)*Camera.ViewportSize.X*0.5
    local best,bestD,bestPart=nil,math.huge,nil
    for _,p in ipairs(getEnemies()) do
        local part=getTargetPart(p) if not part then continue end
        local sp,vis=Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end
        local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d>=radius or d>=bestD then continue end
        if visibleOnly and not isVisible(part) then continue end
        best=p bestD=d bestPart=part
    end
    return best,bestPart
end

-- ══════════════════════════════════════════════
-- AIM LOOP
-- ══════════════════════════════════════════════
-- Aim Silent: simpan last target untuk redirect peluru
local aimSilentTarget = nil

RunService.RenderStepped:Connect(function()
    if not State.EnableFeature or not State.EnableAim then
        aimSilentTarget=nil return
    end

    local visOnly = State.AimVisible
    local enemy, part = getClosest(visOnly)

    -- Update AimSilent target — arahkan root kita ke musuh diam-diam
    if State.AimSilent then
        aimSilentTarget = part  -- bisa nil kalau tidak ada target
        if part then
            local myRoot=getRoot(LocalPlayer)
            if myRoot then
                -- Putar root ke arah musuh tanpa gerak kamera
                -- Ini membuat server menerima arah tembak yang berbeda dari visual
                local lookAt = Vector3.new(part.Position.X, myRoot.Position.Y, part.Position.Z)
                myRoot.CFrame = CFrame.new(myRoot.Position, lookAt)
            end
        end
    else
        aimSilentTarget=nil
    end

    if not enemy or not part then return end

    if State.AimbotFire then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
    elseif State.AimbotLegit then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), 0.18)
    elseif State.AimAssist then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), 0.09)
    end

    if State.AimMagnet then
        local cx2=Camera.ViewportSize.X/2 local cy2=Camera.ViewportSize.Y/2
        local center2=Vector2.new(cx2,cy2)
        local radius2=(State.AimFov/360)*Camera.ViewportSize.X*0.5
        local myRoot=getRoot(LocalPlayer)
        for _,ep in ipairs(getEnemies()) do
            local rp=getRoot(ep) if not rp then continue end
            local sp2,vis2=Camera:WorldToViewportPoint(rp.Position)
            if not vis2 then continue end
            local d2=(Vector2.new(sp2.X,sp2.Y)-center2).Magnitude
            if myRoot and d2<radius2 then
                local worldD=(rp.Position-myRoot.Position).Magnitude
                local ray=Camera:ScreenPointToRay(cx2,cy2)
                rp.CFrame=CFrame.new(ray.Origin+ray.Direction*worldD,
                    ray.Origin+ray.Direction*(worldD+1))
            end
        end
    end

    if State.AimKill then
        local cx3=Camera.ViewportSize.X/2 local cy3=Camera.ViewportSize.Y/2
        local center3=Vector2.new(cx3,cy3)
        local radius3=(State.AimFov/360)*Camera.ViewportSize.X*0.5
        for _,ep in ipairs(getEnemies()) do
            local pt=getTargetPart(ep) if not pt then continue end
            local sp3,vis3=Camera:WorldToViewportPoint(pt.Position)
            if not vis3 then continue end
            if (Vector2.new(sp3.X,sp3.Y)-center3).Magnitude>=radius3 then continue end
            if State.AimVisible and not isVisible(pt) then continue end
            local hum=getHum(ep) if hum then hum.Health=0 end
        end
    end
end)

-- ══════════════════════════════════════════════
-- EXPLOITS
-- ══════════════════════════════════════════════

-- Speed Hack
local wsConn
local function applySpeed(v)
    local h=getHum(LocalPlayer) if not h then return end
    if wsConn then wsConn:Disconnect() wsConn=nil end
    h.WalkSpeed = v and 32 or 16
    if v then
        wsConn=h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if State.SpeedHack then h.WalkSpeed=32 end
        end)
    end
end

-- Jump Boost 2x — set JumpHeight via Humanoid property
local jumpConn
local function applyJump(v)
    local h=getHum(LocalPlayer) if not h then return end
    if jumpConn then jumpConn:Disconnect() jumpConn=nil end
    -- JumpPower untuk R6, JumpHeight untuk R15
    if v then
        h.JumpPower  = 100   -- R6
        h.JumpHeight = 10    -- R15 (default 7.2)
        -- lock agar tidak di-reset game
        jumpConn=h:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if State.JumpBoost then h.JumpPower=100 end
        end)
    else
        h.JumpPower  = 50
        h.JumpHeight = 7.2
    end
end

-- Double Jump — benar-benar 2 lompatan
local djStateConn, djInputConn
local function applyDoubleJump(v)
    if djStateConn then djStateConn:Disconnect() djStateConn=nil end
    if djInputConn then djInputConn:Disconnect() djInputConn=nil end
    State.JumpCount=0
    if not v then return end
    local h=getHum(LocalPlayer) if not h then return end

    djStateConn=h.StateChanged:Connect(function(_,newState)
        if newState==Enum.HumanoidStateType.Jumping then
            State.JumpCount = State.JumpCount + 1
        elseif newState==Enum.HumanoidStateType.Landed
            or newState==Enum.HumanoidStateType.Running then
            State.JumpCount = 0
        end
    end)

    djInputConn=UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if not State.DoubleJump then return end
        if inp.KeyCode ~= Enum.KeyCode.Space then return end
        if State.JumpCount == 1 then
            -- Lompatan kedua: langsung beri velocity ke atas
            local root=getRoot(LocalPlayer)
            if root then
                root.AssemblyLinearVelocity = Vector3.new(
                    root.AssemblyLinearVelocity.X,
                    80,  -- kekuatan lompatan kedua
                    root.AssemblyLinearVelocity.Z
                )
                State.JumpCount = 2
            end
        end
    end)
end

-- ══ FLY AUTO — tween speed 350, max 15m, no clip ══
local flyAutoBodyPos, flyAutoConn2
local function stopFlyAuto()
    if flyAutoConn2 then flyAutoConn2:Disconnect() flyAutoConn2=nil end
    local root=getRoot(LocalPlayer)
    if root then
        local e=root:FindFirstChild("SXFlyBP") if e then e:Destroy() end
        local e2=root:FindFirstChild("SXFlyBG") if e2 then e2:Destroy() end
    end
    local h=getHum(LocalPlayer)
    if h then
        h.PlatformStand=false
        h.WalkSpeed = State.SpeedHack and 32 or 16
    end
    -- Matikan no clip jika aktif
    local char=getChar(LocalPlayer)
    if char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=true end
        end
    end
end

local function startFlyAuto()
    stopFlyAuto()
    local root=getRoot(LocalPlayer)
    local h=getHum(LocalPlayer)
    if not root or not h then return end

    -- NoClip: matikan collision karakter kita
    local char=getChar(LocalPlayer)
    if char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end

    h.PlatformStand=true

    -- BodyPosition untuk float di 15m
    local bp=Instance.new("BodyPosition")
    bp.Name="SXFlyBP"
    bp.MaxForce=Vector3.new(1e6,1e6,1e6)
    bp.D=200
    bp.P=10000
    bp.Position=root.Position+Vector3.new(0,15,0)
    bp.Parent=root

    -- BodyGyro untuk stabilitas orientasi
    local bg=Instance.new("BodyGyro")
    bg.Name="SXFlyBG"
    bg.MaxTorque=Vector3.new(1e6,1e6,1e6)
    bg.D=100
    bg.CFrame=root.CFrame
    bg.Parent=root

    -- Tween posisi ke target 15m di atas posisi awal
    local targetY = root.Position.Y + 15
    local startTime = tick()
    local tweenDuration = 15/350  -- speed 350 stud/s

    flyAutoConn2=RunService.Heartbeat:Connect(function()
        if not State.FlyAuto then stopFlyAuto() return end
        local elapsed=tick()-startTime
        local frac=math.min(elapsed/tweenDuration,1)
        -- easing smooth
        local ease=1-(1-frac)^3
        local currentRoot=getRoot(LocalPlayer)
        if currentRoot then
            local currentY=currentRoot.Position.Y
            local newY=currentY + (targetY-currentY)*0.15  -- smooth approach
            bp.Position=Vector3.new(currentRoot.Position.X, math.min(newY, root.Position.Y+15), currentRoot.Position.Z)
        end
        -- Maintain no clip setiap frame
        if char then
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end
    end)
end

local function applyFlyAuto(v)
    if v then startFlyAuto()
    else stopFlyAuto() end
end

-- ══ FLY TO PLAYER — tween speed 350, no clip ══
local flyTpRunning=false
local flyTpConn2
local function stopFlyToPlayer()
    flyTpRunning=false
    if flyTpConn2 then flyTpConn2:Disconnect() flyTpConn2=nil end
    local root=getRoot(LocalPlayer)
    if root then
        local e=root:FindFirstChild("SXFlyTPBP") if e then e:Destroy() end
        local e2=root:FindFirstChild("SXFlyTPBG") if e2 then e2:Destroy() end
    end
    local h=getHum(LocalPlayer)
    if h then h.PlatformStand=false end
    local char=getChar(LocalPlayer)
    if char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=true end
        end
    end
end

local function startFlyToPlayer()
    if flyTpRunning then stopFlyToPlayer() end
    flyTpRunning=true
    local root=getRoot(LocalPlayer)
    local h=getHum(LocalPlayer)
    if not root or not h then return end

    h.PlatformStand=true
    local char=getChar(LocalPlayer)

    -- NoClip
    if char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end

    local bp=Instance.new("BodyPosition")
    bp.Name="SXFlyTPBP"
    bp.MaxForce=Vector3.new(1e6,1e6,1e6)
    bp.D=100 bp.P=15000
    bp.Position=root.Position bp.Parent=root

    local bg=Instance.new("BodyGyro")
    bg.Name="SXFlyTPBG"
    bg.MaxTorque=Vector3.new(1e6,1e6,1e6)
    bg.D=100 bg.CFrame=root.CFrame bg.Parent=root

    local targetIdx=1
    local enemies=getEnemies()

    flyTpConn2=RunService.Heartbeat:Connect(function(dt)
        if not State.FlyToPlayer then stopFlyToPlayer() return end

        -- NoClip maintenance
        if char then
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=false end
            end
        end

        -- Refresh enemy list tiap siklus
        if targetIdx > #enemies then
            enemies=getEnemies()
            targetIdx=1
            if #enemies==0 then return end
        end

        local target=enemies[targetIdx]
        local tr=target and getRoot(target)
        if not tr then targetIdx=targetIdx+1 return end

        local currentRoot=getRoot(LocalPlayer)
        if not currentRoot then return end

        -- Gerak ke target dengan speed 350 stud/s (smooth lerp per frame)
        local dist=(tr.Position-currentRoot.Position).Magnitude
        local speed=350
        local step=speed*dt
        local alpha=math.min(step/math.max(dist,0.01),1)
        bp.Position=currentRoot.Position:Lerp(tr.Position, alpha*0.6)

        -- Kalau sudah dekat, pindah ke enemy berikutnya
        if dist < 5 then targetIdx=targetIdx+1 end
    end)
end

local function applyFlyToPlayer(v)
    if v then startFlyToPlayer()
    else stopFlyToPlayer() end
end

local function doTeleport()
    if not State.TeleportTarget then return end
    local tp=Players:FindFirstChild(State.TeleportTarget) if not tp then return end
    local tr=getRoot(tp) local mr=getRoot(LocalPlayer)
    if tr and mr then mr.CFrame=tr.CFrame+Vector3.new(2,0,0) end
end

local function hookAnimSpeed(kw,spd)
    local c=getChar(LocalPlayer) if not c then return end
    local hh=c:FindFirstChildOfClass("Humanoid") if not hh then return end
    local a=hh:FindFirstChildOfClass("Animator") if not a then return end
    for _,t in ipairs(a:GetPlayingAnimationTracks()) do
        if t.Name:lower():find(kw) then t:AdjustSpeed(spd) end
    end
    a.AnimationPlayed:Connect(function(t)
        if t.Name:lower():find(kw) then t:AdjustSpeed(spd) end
    end)
end

-- ══════════════════════════════════════════════
-- ESP — fix ghost + fix box posisi
-- ══════════════════════════════════════════════
local espCache={}
local function destroyESP(p)
    local d=espCache[p] if not d then return end
    local function kill(obj)
        if type(obj)=="table" then for _,v in pairs(obj) do kill(v) end
        else pcall(function() obj:Remove() end) end
    end
    kill(d) espCache[p]=nil
end
local function hideESP(p)
    local d=espCache[p] if not d then return end
    local function hide(obj)
        if type(obj)=="table" then for _,v in pairs(obj) do hide(v) end
        else pcall(function() obj.Visible=false end) end
    end
    hide(d)
end

Players.PlayerRemoving:Connect(destroyESP)
Players.PlayerAdded:Connect(function(p)
    p.CharacterRemoving:Connect(function() destroyESP(p) end)
end)
for _,p in ipairs(Players:GetPlayers()) do
    if p~=LocalPlayer then
        p.CharacterRemoving:Connect(function() destroyESP(p) end)
    end
end

RunService.RenderStepped:Connect(function()
    if not State.EnableFeature or not State.EnableEsp then
        for p in pairs(espCache) do hideESP(p) end return
    end
    local active={}
    for _,p in ipairs(getEnemies()) do active[p]=true end
    for p in pairs(espCache) do
        if not active[p] then destroyESP(p) end
    end
    for _,p in ipairs(getEnemies()) do
        local c=getChar(p) local root=getRoot(p)
        local head=getHead(p) local hum=getHum(p)
        if not c or not root or not head or not hum then hideESP(p) continue end
        local rs,visR=Camera:WorldToViewportPoint(root.Position)
        local hs=Camera:WorldToViewportPoint(head.Position)
        local footPos=root.Position-Vector3.new(0,3,0)
        local fs=Camera:WorldToViewportPoint(footPos)
        if not visR then hideESP(p) continue end
        espCache[p]=espCache[p] or {}
        local d=espCache[p]
        local topY=hs.Y-4
        local bottomY=fs.Y+2
        local boxH=math.max(bottomY-topY,10)
        local boxW=boxH*0.5
        local bx=rs.X-boxW/2
        local by=topY
        if State.EspBox then
            if not d.Box then
                local b=Drawing.new("Square")
                b.Color=Color3.fromRGB(220,50,50) b.Thickness=1.5 b.Filled=false d.Box=b
            end
            d.Box.Size=Vector2.new(boxW,boxH)
            d.Box.Position=Vector2.new(bx,by)
            d.Box.Visible=true
        elseif d.Box then d.Box.Visible=false end
        if State.EspLine then
            if not d.Line then
                local l=Drawing.new("Line")
                l.Color=Color3.fromRGB(220,50,50) l.Thickness=1.5 d.Line=l
            end
            d.Line.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
            d.Line.To=Vector2.new(rs.X,rs.Y) d.Line.Visible=true
        elseif d.Line then d.Line.Visible=false end
        if State.EspName then
            if not d.NameD then
                local n=Drawing.new("Text")
                n.Color=Color3.fromRGB(255,255,255) n.Size=13 n.Center=true d.NameD=n
            end
            d.NameD.Text=p.Name
            d.NameD.Position=Vector2.new(rs.X,by-16)
            d.NameD.Visible=true
        elseif d.NameD then d.NameD.Visible=false end
        if State.EspHealth then
            if not d.Hp then
                local h2=Drawing.new("Text")
                h2.Color=Color3.fromRGB(80,255,80) h2.Size=12 h2.Center=true d.Hp=h2
            end
            d.Hp.Text=string.format("HP: %d",math.floor(hum.Health))
            d.Hp.Position=Vector2.new(rs.X,bottomY+4)
            d.Hp.Visible=true
        elseif d.Hp then d.Hp.Visible=false end
        if State.EspDistance then
            local mr=getRoot(LocalPlayer)
            local dist=mr and math.floor((root.Position-mr.Position).Magnitude) or 0
            if not d.Dist then
                local dd=Drawing.new("Text")
                dd.Color=Color3.fromRGB(255,200,0) dd.Size=12 dd.Center=true d.Dist=dd
            end
            d.Dist.Text=dist.."m"
            d.Dist.Position=Vector2.new(rs.X,bottomY+16)
            d.Dist.Visible=true
        elseif d.Dist then d.Dist.Visible=false end
        if State.EspSkeleton then
            local bones={
                {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
                {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
                {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
                {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
            }
            d.Sk=d.Sk or {}
            for i,pair in ipairs(bones) do
                local b1=c:FindFirstChild(pair[1]) local b2=c:FindFirstChild(pair[2])
                if b1 and b2 then
                    local s1,v1=Camera:WorldToViewportPoint(b1.Position)
                    local s2,v2=Camera:WorldToViewportPoint(b2.Position)
                    if v1 and v2 then
                        if not d.Sk[i] then
                            local l=Drawing.new("Line")
                            l.Color=Color3.fromRGB(220,60,60) l.Thickness=1 d.Sk[i]=l
                        end
                        d.Sk[i].From=Vector2.new(s1.X,s1.Y)
                        d.Sk[i].To=Vector2.new(s2.X,s2.Y)
                        d.Sk[i].Visible=true
                    end
                end
            end
        else
            if d.Sk then for _,l in pairs(d.Sk) do pcall(function() l.Visible=false end) end end
        end
    end
end)

-- ══════════════════════════════════════════════
-- FOV CIRCLE + CROSSHAIR
-- ══════════════════════════════════════════════
local fovCircle=Drawing.new("Circle")
fovCircle.Filled=false fovCircle.Color=Color3.fromRGB(200,40,40)
fovCircle.Thickness=1.5 fovCircle.NumSides=64
local cross={}
for i=1,4 do
    local l=Drawing.new("Line")
    l.Color=Color3.fromRGB(255,255,255) l.Thickness=1.5 l.Visible=true cross[i]=l
end
RunService.RenderStepped:Connect(function()
    local cx=Camera.ViewportSize.X/2 local cy=Camera.ViewportSize.Y/2
    local radius=(State.AimFov/360)*Camera.ViewportSize.X*0.5
    fovCircle.Radius=radius fovCircle.Position=Vector2.new(cx,cy)
    fovCircle.Visible=State.EnableFeature and State.EnableAim
    local cs=8
    cross[1].From=Vector2.new(cx-cs,cy) cross[1].To=Vector2.new(cx-2,cy)
    cross[2].From=Vector2.new(cx+2,cy)  cross[2].To=Vector2.new(cx+cs,cy)
    cross[3].From=Vector2.new(cx,cy-cs) cross[3].To=Vector2.new(cx,cy-2)
    cross[4].From=Vector2.new(cx,cy+2)  cross[4].To=Vector2.new(cx,cy+cs)
    for i=1,4 do cross[i].Visible=true end
end)

-- ══════════════════════════════════════════════
-- GUI
-- ══════════════════════════════════════════════
local oldGui=CoreGui:FindFirstChild("SantaXMods")
if oldGui then oldGui:Destroy() end

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="SantaXMods" ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset=true ScreenGui.Parent=CoreGui

-- WARNA TEMA
local RED   = Color3.fromRGB(200,40,40)
local WHITE = Color3.fromRGB(255,255,255)
local DARK  = Color3.fromRGB(13,13,13)
local PANEL = Color3.fromRGB(20,20,20)
local ROW   = Color3.fromRGB(26,26,26)
local DIM   = Color3.fromRGB(100,100,100)
local GRAY  = Color3.fromRGB(60,60,60)

-- ══ ICON BUTTON ══
local IconBtn=Instance.new("TextButton",ScreenGui)
IconBtn.Name="SantaXIcon"
IconBtn.Size=UDim2.new(0,46,0,46)
IconBtn.Position=UDim2.new(0,20,0.5,-23)
IconBtn.BackgroundColor3=DARK IconBtn.BorderSizePixel=0
IconBtn.Text="" IconBtn.Active=true IconBtn.Draggable=true IconBtn.ZIndex=20
Instance.new("UICorner",IconBtn).CornerRadius=UDim.new(0.5,0)
local ics=Instance.new("UIStroke",IconBtn) ics.Color=RED ics.Thickness=2.2
local icLbl=Instance.new("TextLabel",IconBtn)
icLbl.Size=UDim2.new(1,0,1,0) icLbl.BackgroundTransparency=1
icLbl.Font=Enum.Font.GothamBold icLbl.TextSize=15 icLbl.RichText=true icLbl.ZIndex=21
icLbl.Text='<font color="#C82828">S</font><font color="#ffffff">M</font>'

-- ══ MAIN FRAME — diperkecil ══
local MainFrame=Instance.new("Frame",ScreenGui)
MainFrame.Name="MainFrame"
MainFrame.Size=UDim2.new(0,340,0,430)     -- lebih kecil dari sebelumnya
MainFrame.Position=UDim2.new(0.5,-170,0.5,-215)
MainFrame.BackgroundColor3=DARK MainFrame.BorderSizePixel=0
MainFrame.Active=true MainFrame.Draggable=true
MainFrame.Visible=false MainFrame.ZIndex=10
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,7)
local ms=Instance.new("UIStroke",MainFrame) ms.Color=RED ms.Thickness=1.2

-- Title Bar
local TitleBar=Instance.new("Frame",MainFrame)
TitleBar.Size=UDim2.new(1,0,0,32) TitleBar.BackgroundColor3=DARK TitleBar.BorderSizePixel=0
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,7)
local TitleLbl=Instance.new("TextLabel",TitleBar)
TitleLbl.Size=UDim2.new(1,-44,1,0) TitleLbl.Position=UDim2.new(0,10,0,0)
TitleLbl.BackgroundTransparency=1 TitleLbl.Font=Enum.Font.GothamBold
TitleLbl.TextSize=13 TitleLbl.TextColor3=WHITE
TitleLbl.TextXAlignment=Enum.TextXAlignment.Left TitleLbl.RichText=true
TitleLbl.Text='<font color="#C82828">SantaX</font> Mods'
local CloseBtn=Instance.new("TextButton",TitleBar)
CloseBtn.Size=UDim2.new(0,22,0,22) CloseBtn.Position=UDim2.new(1,-26,0,5)
CloseBtn.BackgroundColor3=Color3.fromRGB(160,25,25) CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.TextSize=11 CloseBtn.TextColor3=WHITE CloseBtn.Text="✕" CloseBtn.BorderSizePixel=0
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,4)

local menuOpen=false
local function toggleMenu() menuOpen=not menuOpen MainFrame.Visible=menuOpen end
IconBtn.MouseButton1Click:Connect(toggleMenu)
CloseBtn.MouseButton1Click:Connect(function() menuOpen=false MainFrame.Visible=false end)

-- Info Banner
local InfoBanner=Instance.new("Frame",MainFrame)
InfoBanner.Size=UDim2.new(1,-12,0,34) InfoBanner.Position=UDim2.new(0,6,0,36)
InfoBanner.BackgroundColor3=Color3.fromRGB(30,7,7) InfoBanner.BorderSizePixel=0
Instance.new("UICorner",InfoBanner).CornerRadius=UDim.new(0,5)
local IL1=Instance.new("TextLabel",InfoBanner)
IL1.Size=UDim2.new(1,-8,0,16) IL1.Position=UDim2.new(0,6,0,2)
IL1.BackgroundTransparency=1 IL1.Font=Enum.Font.Gotham IL1.TextSize=10
IL1.TextColor3=Color3.fromRGB(210,210,210) IL1.TextXAlignment=Enum.TextXAlignment.Left
IL1.RichText=true IL1.Text='<font color="#C82828">Created By</font> : Astra   <font color="#C82828">Game</font> : Arsenal'
local IL2=Instance.new("TextLabel",InfoBanner)
IL2.Size=UDim2.new(1,-8,0,13) IL2.Position=UDim2.new(0,6,0,18)
IL2.BackgroundTransparency=1 IL2.Font=Enum.Font.Gotham IL2.TextSize=8
IL2.TextColor3=DIM IL2.TextXAlignment=Enum.TextXAlignment.Left
IL2.Text="Ludo ad oblectationem utendo, omnia pericula ab ipso usore feruntur."

-- Tab Bar
local TabBar=Instance.new("Frame",MainFrame)
TabBar.Size=UDim2.new(0,78,1,-82) TabBar.Position=UDim2.new(0,6,0,76)
TabBar.BackgroundColor3=PANEL TabBar.BorderSizePixel=0
Instance.new("UICorner",TabBar).CornerRadius=UDim.new(0,5)
local tbL=Instance.new("UIListLayout",TabBar)
tbL.SortOrder=Enum.SortOrder.LayoutOrder tbL.Padding=UDim.new(0,2)
tbL.HorizontalAlignment=Enum.HorizontalAlignment.Center
local tbP=Instance.new("UIPadding",TabBar) tbP.PaddingTop=UDim.new(0,5)

-- Content Frame
local ContentFrame=Instance.new("ScrollingFrame",MainFrame)
ContentFrame.Size=UDim2.new(1,-92,1,-82)
ContentFrame.Position=UDim2.new(0,90,0,76)
ContentFrame.BackgroundColor3=PANEL ContentFrame.BorderSizePixel=0
ContentFrame.ScrollBarThickness=2 ContentFrame.ScrollBarImageColor3=RED
ContentFrame.CanvasSize=UDim2.new(0,0,0,0) ContentFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UICorner",ContentFrame).CornerRadius=UDim.new(0,5)
local cL=Instance.new("UIListLayout",ContentFrame)
cL.SortOrder=Enum.SortOrder.LayoutOrder cL.Padding=UDim.new(0,2)
local cP=Instance.new("UIPadding",ContentFrame)
cP.PaddingLeft=UDim.new(0,6) cP.PaddingRight=UDim.new(0,6)
cP.PaddingTop=UDim.new(0,6) cP.PaddingBottom=UDim.new(0,6)

-- ══════════════════════════════════════════════
-- COMPONENT FACTORY
-- ══════════════════════════════════════════════
local function section(txt,order)
    local f=Instance.new("TextLabel",ContentFrame)
    f.LayoutOrder=order f.Size=UDim2.new(1,0,0,18)
    f.BackgroundTransparency=1 f.Font=Enum.Font.GothamBold
    f.TextSize=10 f.TextColor3=RED f.TextXAlignment=Enum.TextXAlignment.Left
    f.Text=txt:upper()
end

local function toggle(label,key,order,cb)
    local row=Instance.new("Frame",ContentFrame)
    row.LayoutOrder=order row.Size=UDim2.new(1,0,0,25)
    row.BackgroundColor3=ROW row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)
    local box=Instance.new("Frame",row)
    box.Size=UDim2.new(0,14,0,14) box.Position=UDim2.new(0,6,0.5,-7)
    box.BackgroundColor3=DARK box.BorderSizePixel=0
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,3)
    local bs=Instance.new("UIStroke",box) bs.Color=RED bs.Thickness=1
    local chk=Instance.new("TextLabel",box)
    chk.Size=UDim2.new(1,0,1,0) chk.BackgroundTransparency=1
    chk.Font=Enum.Font.GothamBold chk.TextSize=11 chk.TextColor3=RED chk.Text=""
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-28,1,0) lbl.Position=UDim2.new(0,25,0,0)
    lbl.BackgroundTransparency=1 lbl.Font=Enum.Font.Gotham
    lbl.TextSize=11 lbl.TextColor3=WHITE lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Text=label
    if label:find("%(Testing%)") then
        local b2=Instance.new("TextLabel",row)
        b2.Size=UDim2.new(0,44,0,12) b2.Position=UDim2.new(1,-50,0.5,-6)
        b2.BackgroundColor3=Color3.fromRGB(100,15,15) b2.Font=Enum.Font.GothamBold
        b2.TextSize=8 b2.TextColor3=WHITE b2.Text="TESTING" b2.BorderSizePixel=0
        Instance.new("UICorner",b2).CornerRadius=UDim.new(0,3)
    end
    local function upd()
        chk.Text=State[key] and "✓" or ""
        box.BackgroundColor3=State[key] and Color3.fromRGB(35,8,8) or DARK
    end
    upd()
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    btn.MouseButton1Click:Connect(function()
        State[key]=not State[key] upd()
        if cb then cb(State[key]) end
    end)
end

-- ══ FLY TOGGLE ROW — abu-abu bg, outline merah, text di kiri ══
local function flyToggleRow(labelText, key, order, cb)
    local row=Instance.new("Frame",ContentFrame)
    row.LayoutOrder=order row.Size=UDim2.new(1,0,0,28)
    row.BackgroundColor3=GRAY row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)
    local rowStroke=Instance.new("UIStroke",row) rowStroke.Color=RED rowStroke.Thickness=1

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(0.7,0,1,0) lbl.Position=UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency=1 lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=10 lbl.TextColor3=WHITE lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Text=labelText

    -- Toggle switch di kanan
    local switchBg=Instance.new("Frame",row)
    switchBg.Size=UDim2.new(0,32,0,16) switchBg.Position=UDim2.new(1,-38,0.5,-8)
    switchBg.BackgroundColor3=Color3.fromRGB(40,40,40) switchBg.BorderSizePixel=0
    Instance.new("UICorner",switchBg).CornerRadius=UDim.new(0.5,0)
    local swStroke=Instance.new("UIStroke",switchBg) swStroke.Color=RED swStroke.Thickness=1

    local knob=Instance.new("Frame",switchBg)
    knob.Size=UDim2.new(0,12,0,12) knob.Position=UDim2.new(0,2,0.5,-6)
    knob.BackgroundColor3=DIM knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0.5,0)

    local function upd()
        local on=State[key]
        switchBg.BackgroundColor3 = on and Color3.fromRGB(35,8,8) or Color3.fromRGB(40,40,40)
        knob.BackgroundColor3     = on and RED or DIM
        -- slide knob
        knob.Position = on and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
    end
    upd()

    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    btn.MouseButton1Click:Connect(function()
        State[key]=not State[key] upd()
        if cb then cb(State[key]) end
    end)
end

local function slider(label,key,minV,maxV,order,cb)
    local row=Instance.new("Frame",ContentFrame)
    row.LayoutOrder=order row.Size=UDim2.new(1,0,0,44)
    row.BackgroundColor3=ROW row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)
    local top=Instance.new("Frame",row)
    top.Size=UDim2.new(1,0,0,22) top.BackgroundTransparency=1
    local lbl=Instance.new("TextLabel",top)
    lbl.Size=UDim2.new(0.6,0,1,0) lbl.Position=UDim2.new(0,7,0,0)
    lbl.BackgroundTransparency=1 lbl.Font=Enum.Font.Gotham lbl.TextSize=11
    lbl.TextColor3=WHITE lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Text=label
    local valLbl=Instance.new("TextLabel",top)
    valLbl.Size=UDim2.new(0.4,-7,1,0) valLbl.Position=UDim2.new(0.6,0,0,0)
    valLbl.BackgroundTransparency=1 valLbl.Font=Enum.Font.GothamBold
    valLbl.TextSize=11 valLbl.TextColor3=RED valLbl.TextXAlignment=Enum.TextXAlignment.Right
    valLbl.Text=tostring(State[key])
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-14,0,7) track.Position=UDim2.new(0,7,0,28)
    track.BackgroundColor3=DARK track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(0,3)
    local fill=Instance.new("Frame",track)
    fill.BackgroundColor3=RED fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,3)
    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,14,0,14) knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.BackgroundColor3=WHITE knob.BorderSizePixel=0 knob.ZIndex=3
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0.5,0)
    local ks=Instance.new("UIStroke",knob) ks.Color=RED ks.Thickness=1.2
    local function setValue(v)
        v=math.clamp(math.floor(v),minV,maxV)
        local pct=(v-minV)/(maxV-minV)
        fill.Size=UDim2.new(pct,0,1,0)
        knob.Position=UDim2.new(pct,0,0.5,0)
        valLbl.Text=tostring(v)
        State[key]=v if cb then cb(v) end
    end
    setValue(State[key])
    local drag=false
    local function processDrag(ix)
        if not drag then return end
        local ap=track.AbsolutePosition local as=track.AbsoluteSize
        local rx=math.clamp(ix-ap.X,0,as.X)
        setValue(minV+(maxV-minV)*(rx/as.X))
    end
    knob.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then drag=true end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then drag=true processDrag(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement or
           i.UserInputType==Enum.UserInputType.Touch then processDrag(i.Position.X) end
    end)
end

local function dropdown(label,opts,key,order,cb)
    local row=Instance.new("Frame",ContentFrame)
    row.LayoutOrder=order row.Size=UDim2.new(1,0,0,26)
    row.BackgroundColor3=ROW row.BorderSizePixel=0 row.ClipsDescendants=false row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(0.5,0,1,0) lbl.Position=UDim2.new(0,7,0,0)
    lbl.BackgroundTransparency=1 lbl.Font=Enum.Font.Gotham lbl.TextSize=11
    lbl.TextColor3=WHITE lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Text=label
    local sel=Instance.new("TextButton",row)
    sel.Size=UDim2.new(0.48,-4,0.78,0) sel.Position=UDim2.new(0.52,0,0.11,0)
    sel.BackgroundColor3=Color3.fromRGB(35,7,7) sel.Font=Enum.Font.GothamBold
    sel.TextSize=10 sel.TextColor3=RED sel.Text=State[key].." ▾" sel.BorderSizePixel=0
    Instance.new("UICorner",sel).CornerRadius=UDim.new(0,3)
    local df=Instance.new("Frame",row)
    df.Size=UDim2.new(0.48,-4,0,#opts*24) df.Position=UDim2.new(0.52,0,1,2)
    df.BackgroundColor3=Color3.fromRGB(20,5,5) df.BorderSizePixel=0 df.ZIndex=10 df.Visible=false
    Instance.new("UICorner",df).CornerRadius=UDim.new(0,3)
    for i,opt in ipairs(opts) do
        local ob=Instance.new("TextButton",df)
        ob.Size=UDim2.new(1,0,0,24) ob.Position=UDim2.new(0,0,0,(i-1)*24)
        ob.BackgroundTransparency=1 ob.Font=Enum.Font.Gotham ob.TextSize=10
        ob.TextColor3=WHITE ob.Text=opt ob.ZIndex=11
        ob.MouseButton1Click:Connect(function()
            State[key]=opt sel.Text=opt.." ▾" df.Visible=false
            if cb then cb(opt) end
        end)
    end
    sel.MouseButton1Click:Connect(function() df.Visible=not df.Visible end)
end

local function teleportRow(order)
    local row=Instance.new("Frame",ContentFrame)
    row.LayoutOrder=order row.Size=UDim2.new(1,0,0,52)
    row.BackgroundColor3=ROW row.BorderSizePixel=0 row.ClipsDescendants=false row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,4)
    local top=Instance.new("Frame",row) top.Size=UDim2.new(1,0,0,26) top.BackgroundTransparency=1
    local box=Instance.new("Frame",top)
    box.Size=UDim2.new(0,14,0,14) box.Position=UDim2.new(0,6,0.5,-7)
    box.BackgroundColor3=DARK box.BorderSizePixel=0
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,3)
    local bs2=Instance.new("UIStroke",box) bs2.Color=RED bs2.Thickness=1
    local chk2=Instance.new("TextLabel",box)
    chk2.Size=UDim2.new(1,0,1,0) chk2.BackgroundTransparency=1
    chk2.Font=Enum.Font.GothamBold chk2.TextSize=11 chk2.TextColor3=RED chk2.Text=""
    local lbl2=Instance.new("TextLabel",top)
    lbl2.Size=UDim2.new(0.45,0,1,0) lbl2.Position=UDim2.new(0,24,0,0)
    lbl2.BackgroundTransparency=1 lbl2.Font=Enum.Font.Gotham
    lbl2.TextSize=11 lbl2.TextColor3=WHITE lbl2.TextXAlignment=Enum.TextXAlignment.Left lbl2.Text="Teleport Toggle"
    local sel2=Instance.new("TextButton",top)
    sel2.Size=UDim2.new(0.42,0,0.78,0) sel2.Position=UDim2.new(0.57,0,0.11,0)
    sel2.BackgroundColor3=Color3.fromRGB(35,7,7) sel2.Font=Enum.Font.GothamBold
    sel2.TextSize=9 sel2.TextColor3=RED sel2.Text="Target ▾" sel2.BorderSizePixel=0
    Instance.new("UICorner",sel2).CornerRadius=UDim.new(0,3)
    local df2=Instance.new("ScrollingFrame",row)
    df2.Size=UDim2.new(0.42,0,0,72) df2.Position=UDim2.new(0.57,0,0,26)
    df2.BackgroundColor3=Color3.fromRGB(20,5,5) df2.BorderSizePixel=0
    df2.ZIndex=10 df2.Visible=false df2.ScrollBarThickness=2
    df2.CanvasSize=UDim2.new(0,0,0,0) df2.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Instance.new("UICorner",df2).CornerRadius=UDim.new(0,3)
    Instance.new("UIListLayout",df2).SortOrder=Enum.SortOrder.LayoutOrder
    local tpBtn=Instance.new("TextButton",row)
    tpBtn.Size=UDim2.new(1,-10,0,20) tpBtn.Position=UDim2.new(0,5,0,28)
    tpBtn.BackgroundColor3=RED tpBtn.Font=Enum.Font.GothamBold
    tpBtn.TextSize=10 tpBtn.TextColor3=WHITE tpBtn.Text="⚡ Teleport Now" tpBtn.BorderSizePixel=0
    Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,3)
    local function refresh()
        for _,cc in ipairs(df2:GetChildren()) do if cc:IsA("TextButton") then cc:Destroy() end end
        for _,p in ipairs(getEnemies()) do
            local ob=Instance.new("TextButton",df2)
            ob.Size=UDim2.new(1,0,0,20) ob.BackgroundTransparency=1
            ob.Font=Enum.Font.Gotham ob.TextSize=9 ob.TextColor3=WHITE ob.Text=p.Name ob.ZIndex=11
            ob.MouseButton1Click:Connect(function()
                State.TeleportTarget=p.Name sel2.Text=p.Name.." ▾" df2.Visible=false
            end)
        end
    end
    sel2.MouseButton1Click:Connect(function() refresh() df2.Visible=not df2.Visible end)
    tpBtn.MouseButton1Click:Connect(doTeleport)
    local togBtn=Instance.new("TextButton",top)
    togBtn.Size=UDim2.new(0.5,0,1,0) togBtn.BackgroundTransparency=1 togBtn.Text=""
    togBtn.MouseButton1Click:Connect(function()
        State.TeleportToggle=not State.TeleportToggle
        chk2.Text=State.TeleportToggle and "✓" or ""
        box.BackgroundColor3=State.TeleportToggle and Color3.fromRGB(35,8,8) or DARK
    end)
end

-- ══════════════════════════════════════════════
-- TAB SYSTEM
-- ══════════════════════════════════════════════
local tabs={"Main","Aim","Visual","Exploits"}
local tabBtns={} local activeTab=""

local function clearContent()
    for _,cc in ipairs(ContentFrame:GetChildren()) do
        if cc:IsA("UIListLayout") or cc:IsA("UIPadding") then continue end
        cc:Destroy()
    end
end

local function setTab(name)
    if activeTab==name then return end
    activeTab=name clearContent()
    for n,b in pairs(tabBtns) do
        local on=n==name
        b.TextColor3=on and WHITE or DIM
        b.BackgroundColor3=on and ROW or PANEL
        local lb=b:FindFirstChild("LB") if lb then lb:Destroy() end
        if on then
            local lb2=Instance.new("Frame",b) lb2.Name="LB"
            lb2.Size=UDim2.new(0,3,0.65,0) lb2.Position=UDim2.new(0,0,0.175,0)
            lb2.BackgroundColor3=RED lb2.BorderSizePixel=0
            Instance.new("UICorner",lb2).CornerRadius=UDim.new(0,2)
        end
    end
    if name=="Main" then
        section("MAIN SETTINGS",1)
        toggle("Enable Feature","EnableFeature",2)
        toggle("Enable Aim","EnableAim",3)
        toggle("Enable ESP","EnableEsp",4)
    elseif name=="Aim" then
        section("AIM SETTINGS",1)
        toggle("Aimbot Fire","AimbotFire",2)
        toggle("Aimbot Legit","AimbotLegit",3)
        toggle("Aim Assist","AimAssist",4)
        toggle("Aim Silent","AimSilent",5)
        toggle("Aim Visible","AimVisible",6)
        toggle("Aim Magnet (Testing)","AimMagnet",7)
        toggle("Aim Kill (Testing)","AimKill",8)
        dropdown("Aim Target",{"Body","Head","Random"},"AimTarget",9)
        slider("Aim FoV","AimFov",1,360,10)
    elseif name=="Visual" then
        section("VISUAL SETTINGS",1)
        toggle("Esp Line","EspLine",2)
        toggle("Esp Box","EspBox",3)
        toggle("Esp Hitbox 3D","EspHitbox3D",4)
        toggle("Esp Health","EspHealth",5)
        toggle("Esp Distance","EspDistance",6)
        toggle("Esp Name","EspName",7)
        toggle("Esp Skeleton","EspSkeleton",8)
    elseif name=="Exploits" then
        section("EXPLOIT SETTINGS",1)
        toggle("Speed Hack (2x)","SpeedHack",2,applySpeed)
        toggle("Jump Boost (2x)","JumpBoost",3,applyJump)
        toggle("Double Jump","DoubleJump",4,applyDoubleJump)
        teleportRow(5)
        -- Fly Auto dengan toggle khusus
        flyToggleRow("Auto Fly (15m)",   "FlyAuto",     6, applyFlyAuto)
        flyToggleRow("Fly to Player",    "FlyToPlayer", 7, applyFlyToPlayer)
        toggle("Fast Reload (100x)","FastReload",8,function(v)
            hookAnimSpeed("reload",v and 100 or 1)
        end)
        toggle("Speed Fire (100x)","SpeedFire",9,function(v)
            hookAnimSpeed("fire",v and 100 or 1)
        end)
    end
end

for i,name in ipairs(tabs) do
    local btn=Instance.new("TextButton",TabBar)
    btn.LayoutOrder=i btn.Size=UDim2.new(0.88,0,0,34)
    btn.BackgroundColor3=PANEL btn.Font=Enum.Font.GothamBold
    btn.TextSize=11 btn.TextColor3=DIM btn.Text=name btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
    tabBtns[name]=btn
    btn.MouseButton1Click:Connect(function() setTab(name) end)
end

setTab("Main")

pcall(function()
    StarterGui:SetCore("SendNotification",{
        Title="SantaX Mods", Text="Loaded — Astra ✓", Duration=4,
    })
end)
print("[SantaX Mods] ✓ Loaded")
