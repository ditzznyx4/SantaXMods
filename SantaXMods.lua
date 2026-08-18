-- ╔══════════════════════════════════════════╗
-- ║         SantaX Mods - Roblox Executor    ║
-- ║  Created By : Astra                      ║
-- ║  Game       : Arsenal                    ║
-- ║  SantaX Mods - Ludo ad oblectationem     ║
-- ║  utendo, omnia pericula ab ipso          ║
-- ║  usore feruntur.                         ║
-- ╚══════════════════════════════════════════╝

-- ══════════════════════════════════════════
--              SERVICES
-- ══════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local HttpService      = game:GetService("HttpService")
local StarterGui       = game:GetService("StarterGui")

local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera
local Mouse            = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════
--              STATE TABLE
-- ══════════════════════════════════════════
local State = {
    -- Main
    EnableFeature   = false,
    EnableAim       = false,
    EnableEsp       = false,

    -- Aim
    AimbotFire      = false,
    AimbotLegit     = false,
    AimAssist       = false,
    AimSilent       = false,
    AimVisible      = false,
    AimMagnet       = false,   -- Testing
    AimKill         = false,   -- Testing
    AimTarget       = "Body",  -- Body | Head | Random
    AimFov          = 90,

    -- Visual
    EspLine         = false,
    EspBox          = false,
    EspHitbox3D     = false,
    EspHealth       = false,
    EspDistance     = false,
    EspName         = false,
    EspSkeleton     = false,

    -- Exploits
    SpeedHack       = false,
    JumpBoost       = false,
    DoubleJump      = false,
    TeleportToggle  = false,
    FlyAuto         = false,
    FlyToPlayer     = false,
    FastReload      = false,
    SpeedFire       = false,

    TeleportTarget  = nil,
    FlyConn         = nil,
    FlyHeight       = 15,
    MagnetDist      = 7,
    JumpCount       = 0,
}

-- ══════════════════════════════════════════
--              UTILITY
-- ══════════════════════════════════════════
local function getCharacter(player)
    return player and player.Character
end

local function getRootPart(player)
    local char = getCharacter(player)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function getHumanoid(player)
    local char = getCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getHead(player)
    local char = getCharacter(player)
    return char and char:FindFirstChild("Head")
end

local function isAlive(player)
    local hum = getHumanoid(player)
    return hum and hum.Health > 0
end

local function isEnemy(player)
    -- Cek bukan LocalPlayer dan bukan satu tim
    if player == LocalPlayer then return false end
    if LocalPlayer.Team and player.Team then
        if LocalPlayer.Team == player.Team then return false end
    end
    return true
end

local function getEnemies()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and isAlive(p) then
            table.insert(list, p)
        end
    end
    return list
end

local function getTargetPart(player)
    local target = State.AimTarget
    if target == "Random" then
        local r = math.random(1, 2)
        target = r == 1 and "Head" or "Body"
    end
    local char = getCharacter(player)
    if not char then return nil end
    if target == "Head" then
        return char:FindFirstChild("Head")
    else
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    end
end

local function getClosestEnemy()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local fovRadius = (State.AimFov / 360) * Camera.ViewportSize.X * 0.5

    local closest, closestDist, closestPart = nil, math.huge, nil
    for _, p in ipairs(getEnemies()) do
        local part = getTargetPart(p)
        if part then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local sp2 = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (sp2 - center).Magnitude
                if dist < fovRadius and dist < closestDist then
                    closest     = p
                    closestDist = dist
                    closestPart = part
                end
            end
        end
    end
    return closest, closestPart
end

-- ══════════════════════════════════════════
--              AIM LOGIC
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not State.EnableFeature then return end
    if not State.EnableAim then return end

    local enemy, part = getClosestEnemy()
    if not enemy or not part then return end

    -- Aimbot Fire / Legit / Assist: arahkan kamera ke target
    if State.AimbotFire or State.AimbotLegit or State.AimAssist then
        local targetPos = part.Position
        if State.AimbotFire then
            -- Snap langsung
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        elseif State.AimbotLegit then
            -- Smooth lerp
            local lookCF = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(lookCF, 0.2)
        elseif State.AimAssist then
            local lookCF = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(lookCF, 0.1)
        end
    end

    -- Aim Silent: arahkan peluru ke target tanpa gerak kamera (manipulasi CF root)
    if State.AimSilent then
        local root = getRootPart(LocalPlayer)
        if root then
            root.CFrame = CFrame.new(root.Position, Vector3.new(part.Position.X, root.Position.Y, part.Position.Z))
        end
    end

    -- Aim Magnet: tarik musuh dalam 7m ke crosshair view
    if State.AimMagnet then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local fovRadius = (State.AimFov / 360) * Camera.ViewportSize.X * 0.5
        for _, p in ipairs(getEnemies()) do
            local rootPart = getRootPart(p)
            if rootPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local sp2 = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (sp2 - center).Magnitude
                    -- Jika dalam radius fov & jarak world <= 7 stud dari crosshair ray
                    local myRoot = getRootPart(LocalPlayer)
                    if myRoot then
                        local worldDist = (rootPart.Position - myRoot.Position).Magnitude
                        if dist < fovRadius then
                            -- Tarik ke posisi crosshair dunia (ray dari kamera ke forward)
                            local unitRay = Camera:ScreenPointToRay(center.X, center.Y)
                            local targetWorld = unitRay.Origin + unitRay.Direction * worldDist
                            -- Pindahkan musuh ke sana (server-side hanya bisa via RemoteEvent exploit)
                            rootPart.CFrame = CFrame.new(targetWorld, targetWorld + unitRay.Direction)
                        end
                    end
                end
            end
        end
    end

    -- Aim Kill: instant kill musuh dalam FoV (no visual)
    if State.AimKill then
        for _, p in ipairs(getEnemies()) do
            local part2 = getTargetPart(p)
            if part2 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part2.Position)
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local fovRadius = (State.AimFov / 360) * Camera.ViewportSize.X * 0.5
                    local sp2 = Vector2.new(screenPos.X, screenPos.Y)
                    if (sp2 - center).Magnitude < fovRadius then
                        -- Aim Visible check: skip jika dibelakang tembok
                        if State.AimVisible then
                            local myRoot = getRootPart(LocalPlayer)
                            if myRoot then
                                local rayOrigin    = myRoot.Position
                                local rayDirection = (part2.Position - rayOrigin)
                                local raycastParams = RaycastParams.new()
                                raycastParams.FilterDescendantsInstances = {getCharacter(LocalPlayer), getCharacter(p)}
                                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                                local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                                if result then
                                    -- Ada tembok, skip
                                    goto continue
                                end
                            end
                        end
                        -- Instant damage via Humanoid
                        local hum = getHumanoid(p)
                        if hum then
                            hum.Health = 0
                        end
                        ::continue::
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════
--              EXPLOIT LOGIC
-- ══════════════════════════════════════════

-- Speed Hack
local walkSpeedConn
local function applySpeedHack(active)
    local hum = getHumanoid(LocalPlayer)
    if not hum then return end
    if active then
        hum.WalkSpeed = 32 -- 2x default 16
        walkSpeedConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if State.SpeedHack then hum.WalkSpeed = 32 end
        end)
    else
        hum.WalkSpeed = 16
        if walkSpeedConn then walkSpeedConn:Disconnect() walkSpeedConn = nil end
    end
end

-- Jump Boost
local function applyJumpBoost(active)
    local hum = getHumanoid(LocalPlayer)
    if not hum then return end
    hum.JumpPower = active and 100 or 50
end

-- Double Jump
local jumpConn
local function applyDoubleJump(active)
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    State.JumpCount = 0
    if active then
        local hum = getHumanoid(LocalPlayer)
        if not hum then return end
        jumpConn = hum.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Jumping then
                State.JumpCount = State.JumpCount + 1
            elseif new == Enum.HumanoidStateType.Landed then
                State.JumpCount = 0
            end
        end)
        UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Space and State.DoubleJump and State.JumpCount == 1 then
                local root = getRootPart(LocalPlayer)
                if root then
                    root.Velocity = Vector3.new(root.Velocity.X, 60, root.Velocity.Z)
                    State.JumpCount = 2
                end
            end
        end)
    end
end

-- Fly Auto (15m tinggi)
local function applyFlyAuto(active)
    if State.FlyConn then State.FlyConn:Disconnect() State.FlyConn = nil end
    local root = getRootPart(LocalPlayer)
    local hum  = getHumanoid(LocalPlayer)
    if not root or not hum then return end

    if active then
        hum.PlatformStand = true
        local bodyPos = Instance.new("BodyPosition")
        bodyPos.Name     = "SantaXFly"
        bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyPos.P        = 1e4
        bodyPos.Position = root.Position + Vector3.new(0, State.FlyHeight, 0)
        bodyPos.Parent   = root

        State.FlyConn = RunService.Heartbeat:Connect(function()
            if not State.FlyAuto then
                bodyPos:Destroy()
                hum.PlatformStand = false
                State.FlyConn:Disconnect()
                State.FlyConn = nil
                return
            end
            bodyPos.Position = Vector3.new(root.Position.X, root.Position.Y + State.FlyHeight, root.Position.Z)
        end)
    else
        local existing = root:FindFirstChild("SantaXFly")
        if existing then existing:Destroy() end
        hum.PlatformStand = false
    end
end

-- Fly To Player (terbang ke semua musuh satu per satu)
local function flyToPlayer()
    local enemies = getEnemies()
    local myRoot  = getRootPart(LocalPlayer)
    local hum     = getHumanoid(LocalPlayer)
    if not myRoot or not hum then return end

    hum.PlatformStand = true
    for _, p in ipairs(enemies) do
        if not State.FlyToPlayer then break end
        local tRoot = getRootPart(p)
        if tRoot then
            local bodyPos = Instance.new("BodyPosition")
            bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyPos.P        = 1e4
            bodyPos.Position = tRoot.Position
            bodyPos.Parent   = myRoot
            task.wait(0.8)
            bodyPos:Destroy()
        end
    end
    hum.PlatformStand = false
end

-- Teleport to Enemy
local function teleportToTarget()
    if not State.TeleportTarget then return end
    local target = Players:FindFirstChild(State.TeleportTarget)
    if not target then return end
    local tRoot = getRootPart(target)
    local myRoot = getRootPart(LocalPlayer)
    if tRoot and myRoot then
        myRoot.CFrame = tRoot.CFrame + Vector3.new(2, 0, 0)
    end
end

-- Fast Reload (100x)
local function applyFastReload(active)
    local char = getCharacter(LocalPlayer)
    if not char then return end
    -- Cari animasi reload dan percepat
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.Name:lower():find("reload") then
            track:AdjustSpeed(active and 100 or 1)
        end
    end
    -- Hook ke animasi baru
    if active then
        animator.AnimationPlayed:Connect(function(track)
            if track.Name:lower():find("reload") and State.FastReload then
                track:AdjustSpeed(100)
            end
        end)
    end
end

-- Speed Fire (100x)
local function applySpeedFire(active)
    local char = getCharacter(LocalPlayer)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    if active then
        animator.AnimationPlayed:Connect(function(track)
            if track.Name:lower():find("fire") or track.Name:lower():find("shoot") then
                if State.SpeedFire then track:AdjustSpeed(100) end
            end
        end)
    end
end

-- ══════════════════════════════════════════
--              ESP DRAWING
-- ══════════════════════════════════════════
local ESPFolder = {}

local function clearESP()
    for _, d in pairs(ESPFolder) do
        if d and typeof(d) == "table" then
            for _, obj in pairs(d) do
                if typeof(obj) == "Instance" then obj:Remove() end
            end
        end
    end
    ESPFolder = {}
end

local function drawESP()
    clearESP()
    RunService.RenderStepped:Connect(function()
        if not State.EnableFeature or not State.EnableEsp then
            clearESP()
            return
        end

        for _, p in ipairs(getEnemies()) do
            local char  = getCharacter(p)
            local root  = getRootPart(p)
            local head  = getHead(p)
            local hum   = getHumanoid(p)
            if not char or not root or not head or not hum then continue end

            local rootScreen, visible = Camera:WorldToViewportPoint(root.Position)
            if not visible then continue end

            ESPFolder[p] = ESPFolder[p] or {}
            local draw   = ESPFolder[p]

            local headScreen = Camera:WorldToViewportPoint(head.Position)
            local scale      = 1 / (rootScreen.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * Camera.ViewportSize.Y
            local boxH       = math.abs(rootScreen.Y - headScreen.Y) * 2
            local boxW       = boxH * 0.6
            local bx         = rootScreen.X - boxW / 2
            local by         = rootScreen.Y - boxH / 2

            -- Box ESP
            if State.EspBox then
                if not draw.Box then
                    local b = Drawing.new("Square")
                    b.Visible   = true
                    b.Color     = Color3.fromRGB(255, 50, 50)
                    b.Thickness = 1.5
                    b.Filled    = false
                    draw.Box    = b
                end
                draw.Box.Size     = Vector2.new(boxW, boxH)
                draw.Box.Position = Vector2.new(bx, by)
                draw.Box.Visible  = true
            elseif draw.Box then
                draw.Box.Visible = false
            end

            -- Line ESP
            if State.EspLine then
                if not draw.Line then
                    local l = Drawing.new("Line")
                    l.Color     = Color3.fromRGB(255, 50, 50)
                    l.Thickness = 1.5
                    draw.Line   = l
                end
                draw.Line.From    = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                draw.Line.To      = Vector2.new(rootScreen.X, rootScreen.Y)
                draw.Line.Visible = true
            elseif draw.Line then
                draw.Line.Visible = false
            end

            -- Name ESP
            if State.EspName then
                if not draw.Name then
                    local n = Drawing.new("Text")
                    n.Color   = Color3.fromRGB(255, 255, 255)
                    n.Size    = 13
                    n.Center  = true
                    draw.Name = n
                end
                draw.Name.Text     = p.Name
                draw.Name.Position = Vector2.new(rootScreen.X, by - 14)
                draw.Name.Visible  = true
            elseif draw.Name then
                draw.Name.Visible = false
            end

            -- Health ESP
            if State.EspHealth then
                if not draw.Health then
                    local h = Drawing.new("Text")
                    h.Color     = Color3.fromRGB(100, 255, 100)
                    h.Size      = 12
                    h.Center    = true
                    draw.Health = h
                end
                draw.Health.Text     = string.format("HP: %d", math.floor(hum.Health))
                draw.Health.Position = Vector2.new(rootScreen.X, by + boxH + 2)
                draw.Health.Visible  = true
            elseif draw.Health then
                draw.Health.Visible = false
            end

            -- Distance ESP
            if State.EspDistance then
                local myRoot2 = getRootPart(LocalPlayer)
                local dist    = myRoot2 and math.floor((root.Position - myRoot2.Position).Magnitude) or 0
                if not draw.Dist then
                    local d = Drawing.new("Text")
                    d.Color   = Color3.fromRGB(255, 200, 0)
                    d.Size    = 12
                    d.Center  = true
                    draw.Dist = d
                end
                draw.Dist.Text     = dist .. "m"
                draw.Dist.Position = Vector2.new(rootScreen.X, by + boxH + 14)
                draw.Dist.Visible  = true
            elseif draw.Dist then
                draw.Dist.Visible = false
            end

            -- Skeleton ESP
            if State.EspSkeleton then
                local bones = {
                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
                    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
                    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
                    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},
                }
                draw.Skeleton = draw.Skeleton or {}
                for i, pair in ipairs(bones) do
                    local p1 = char:FindFirstChild(pair[1])
                    local p2 = char:FindFirstChild(pair[2])
                    if p1 and p2 then
                        local s1, v1 = Camera:WorldToViewportPoint(p1.Position)
                        local s2, v2 = Camera:WorldToViewportPoint(p2.Position)
                        if v1 and v2 then
                            if not draw.Skeleton[i] then
                                local l = Drawing.new("Line")
                                l.Color     = Color3.fromRGB(255, 60, 60)
                                l.Thickness = 1
                                draw.Skeleton[i] = l
                            end
                            draw.Skeleton[i].From    = Vector2.new(s1.X, s1.Y)
                            draw.Skeleton[i].To      = Vector2.new(s2.X, s2.Y)
                            draw.Skeleton[i].Visible = true
                        end
                    end
                end
            else
                if draw.Skeleton then
                    for _, l in pairs(draw.Skeleton) do l.Visible = false end
                end
            end
        end
    end)
end

drawESP()

-- ══════════════════════════════════════════
--              AIM FOV CIRCLE DRAWING
-- ══════════════════════════════════════════
local fovCircle = Drawing.new("Circle")
fovCircle.Visible   = true
fovCircle.Filled    = false
fovCircle.Color     = Color3.fromRGB(255, 50, 50)
fovCircle.Thickness = 1.5
fovCircle.NumSides  = 64

-- Crosshair tetap ditengah
local crossH1 = Drawing.new("Line")
local crossH2 = Drawing.new("Line")
local crossV1 = Drawing.new("Line")
local crossV2 = Drawing.new("Line")
for _, c in ipairs({crossH1, crossH2, crossV1, crossV2}) do
    c.Color     = Color3.fromRGB(255, 255, 255)
    c.Thickness = 1.5
    c.Visible   = true
end

RunService.RenderStepped:Connect(function()
    local cx  = Camera.ViewportSize.X / 2
    local cy  = Camera.ViewportSize.Y / 2
    local rad = (State.AimFov / 360) * Camera.ViewportSize.X * 0.5

    -- FoV Circle (radius bisa besar, crosshair tetap center, tidak ikut bergeser)
    fovCircle.Radius   = rad
    fovCircle.Position = Vector2.new(cx, cy)
    fovCircle.Visible  = State.EnableFeature and State.EnableAim

    -- Crosshair selalu ditengah, ukuran tetap 8px
    local cs = 8
    crossH1.From = Vector2.new(cx - cs, cy) crossH1.To = Vector2.new(cx - 2, cy)
    crossH2.From = Vector2.new(cx + 2, cy)  crossH2.To = Vector2.new(cx + cs, cy)
    crossV1.From = Vector2.new(cx, cy - cs) crossV1.To = Vector2.new(cx, cy - 2)
    crossV2.From = Vector2.new(cx, cy + 2)  crossV2.To = Vector2.new(cx, cy + cs)
    for _, c in ipairs({crossH1, crossH2, crossV1, crossV2}) do c.Visible = true end
end)

-- ══════════════════════════════════════════
--              GUI BUILDER
-- ══════════════════════════════════════════
local ScreenGui      = Instance.new("ScreenGui")
ScreenGui.Name       = "SantaXMods"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent     = game:GetService("CoreGui")

-- Warna tema SantaX
local RED    = Color3.fromRGB(200, 40, 40)
local WHITE  = Color3.fromRGB(255, 255, 255)
local DARK   = Color3.fromRGB(15, 15, 15)
local PANEL  = Color3.fromRGB(22, 22, 22)
local TABSEL = Color3.fromRGB(30, 30, 30)
local ACCENT = Color3.fromRGB(200, 40, 40)
local DIM    = Color3.fromRGB(120, 120, 120)

-- ══ Main Frame ══
local MainFrame = Instance.new("Frame")
MainFrame.Name          = "MainFrame"
MainFrame.Size          = UDim2.new(0, 380, 0, 480)
MainFrame.Position      = UDim2.new(0.5, -190, 0.5, -240)
MainFrame.BackgroundColor3 = DARK
MainFrame.BorderSizePixel  = 0
MainFrame.Active        = true
MainFrame.Draggable     = true
MainFrame.Parent        = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Stroke
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color     = RED
stroke.Thickness = 1.5

-- ══ Title Bar ══
local TitleBar = Instance.new("Frame")
TitleBar.Size   = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = DARK
TitleBar.BorderSizePixel  = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size  = UDim2.new(1, -12, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font  = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextColor3  = WHITE
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.RichText    = true
TitleLabel.Text        = '<font color="#C82828">SantaX</font> Mods'
TitleLabel.Parent      = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size   = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Font   = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = WHITE
CloseBtn.Text   = "✕"
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ══ Info Banner ══
local InfoBanner = Instance.new("Frame")
InfoBanner.Size   = UDim2.new(1, -16, 0, 36)
InfoBanner.Position = UDim2.new(0, 8, 0, 40)
InfoBanner.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
InfoBanner.BorderSizePixel  = 0
InfoBanner.Parent = MainFrame
Instance.new("UICorner", InfoBanner).CornerRadius = UDim.new(0, 6)

local InfoText = Instance.new("TextLabel")
InfoText.Size   = UDim2.new(1, -10, 1, 0)
InfoText.Position = UDim2.new(0, 6, 0, 0)
InfoText.BackgroundTransparency = 1
InfoText.Font   = Enum.Font.Gotham
InfoText.TextSize = 10.5
InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.RichText = true
InfoText.Text   = '<font color="#C82828">Created By</font> : Astra  |  <font color="#C82828">Game</font> : Arsenal'
InfoText.Parent = InfoBanner

local SubText = Instance.new("TextLabel")
SubText.Size   = UDim2.new(1, 0, 0, 12)
SubText.Position = UDim2.new(0, 0, 1, 0)
SubText.BackgroundTransparency = 1
SubText.Font   = Enum.Font.Gotham
SubText.TextSize = 9
SubText.TextColor3 = DIM
SubText.TextXAlignment = Enum.TextXAlignment.Center
SubText.Text   = "Ludo ad oblectationem utendo, omnia pericula ab ipso usore feruntur."
SubText.Parent = InfoBanner

-- ══ Tab Bar ══
local TabBar = Instance.new("Frame")
TabBar.Size   = UDim2.new(0, 90, 1, -100)
TabBar.Position = UDim2.new(0, 8, 0, 92)
TabBar.BackgroundColor3 = PANEL
TabBar.BorderSizePixel  = 0
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 6)

local tabLayout = Instance.new("UIListLayout", TabBar)
tabLayout.SortOrder  = Enum.SortOrder.LayoutOrder
tabLayout.Padding     = UDim.new(0, 2)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ══ Content Frame ══
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size   = UDim2.new(1, -110, 1, -100)
ContentFrame.Position = UDim2.new(0, 106, 0, 92)
ContentFrame.BackgroundColor3 = PANEL
ContentFrame.BorderSizePixel  = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = RED
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 6)

local contentLayout = Instance.new("UIListLayout", ContentFrame)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding   = UDim.new(0, 4)

local contentPad = Instance.new("UIPadding", ContentFrame)
contentPad.PaddingLeft   = UDim.new(0, 8)
contentPad.PaddingRight  = UDim.new(0, 8)
contentPad.PaddingTop    = UDim.new(0, 8)
contentPad.PaddingBottom = UDim.new(0, 8)

-- ══════════════════════════════════════════
--           COMPONENT FACTORY
-- ══════════════════════════════════════════

-- Section Header
local function makeSection(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.LayoutOrder = order or 0
    lbl.Size   = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Font   = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = RED
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text   = text:upper()
    lbl.Parent = ContentFrame
    return lbl
end

-- Toggle / Checkbox
local function makeToggle(labelText, stateKey, order, callback)
    local row = Instance.new("Frame")
    row.LayoutOrder = order or 0
    row.Size   = UDim2.new(1, 0, 0, 28)
    row.BackgroundColor3 = TABSEL
    row.BorderSizePixel  = 0
    row.Parent = ContentFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local box = Instance.new("Frame")
    box.Size   = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(0, 6, 0.5, -8)
    box.BackgroundColor3 = DARK
    box.BorderSizePixel  = 0
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
    local boxStroke = Instance.new("UIStroke", box)
    boxStroke.Color     = RED
    boxStroke.Thickness = 1

    local check = Instance.new("TextLabel")
    check.Size   = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Font   = Enum.Font.GothamBold
    check.TextSize = 12
    check.TextColor3 = RED
    check.Text   = ""
    check.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.Size   = UDim2.new(1, -32, 1, 0)
    lbl.Position = UDim2.new(0, 28, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font   = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text   = labelText
    lbl.Parent = row

    -- Testing badge
    if labelText:find("%(Testing%)") then
        local badge = Instance.new("TextLabel")
        badge.Size  = UDim2.new(0, 52, 0, 14)
        badge.Position = UDim2.new(1, -58, 0.5, -7)
        badge.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
        badge.Font  = Enum.Font.GothamBold
        badge.TextSize = 9
        badge.TextColor3 = WHITE
        badge.Text  = "TESTING"
        badge.Parent = row
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 3)
    end

    local function updateVisual()
        local on = State[stateKey]
        check.Text = on and "✓" or ""
        box.BackgroundColor3 = on and Color3.fromRGB(30, 10, 10) or DARK
    end
    updateVisual()

    local btn = Instance.new("TextButton")
    btn.Size   = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text   = ""
    btn.Parent = row
    btn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        updateVisual()
        if callback then callback(State[stateKey]) end
    end)
    return row
end

-- Slider
local function makeSlider(labelText, stateKey, minV, maxV, order, callback)
    local row = Instance.new("Frame")
    row.LayoutOrder = order or 0
    row.Size   = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = TABSEL
    row.BorderSizePixel  = 0
    row.Parent = ContentFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local top = Instance.new("Frame")
    top.Size   = UDim2.new(1, 0, 0, 22)
    top.BackgroundTransparency = 1
    top.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size   = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font   = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text   = labelText
    lbl.Parent = top

    local valLbl = Instance.new("TextLabel")
    valLbl.Size  = UDim2.new(0.4, -8, 1, 0)
    valLbl.Position = UDim2.new(0.6, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Font  = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextColor3 = RED
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text  = tostring(State[stateKey])
    valLbl.Parent = top

    local track = Instance.new("Frame")
    track.Size   = UDim2.new(1, -16, 0, 6)
    track.Position = UDim2.new(0, 8, 0, 30)
    track.BackgroundColor3 = DARK
    track.BorderSizePixel  = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = RED
    fill.BorderSizePixel  = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local knob = Instance.new("Frame")
    knob.Size   = UDim2.new(0, 12, 0, 12)
    knob.BackgroundColor3 = WHITE
    knob.BorderSizePixel  = 0
    knob.ZIndex = 2
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

    local function updateSlider(v)
        local pct = (v - minV) / (maxV - minV)
        fill.Size     = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -6, 0.5, -6)
        valLbl.Text   = tostring(v)
        State[stateKey] = v
        if callback then callback(v) end
    end
    updateSlider(State[stateKey])

    local dragging = false
    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local absPos  = track.AbsolutePosition
            local absSize = track.AbsoluteSize
            local rx = math.clamp(inp.Position.X - absPos.X, 0, absSize.X)
            local pct = rx / absSize.X
            local val = math.floor(minV + (maxV - minV) * pct)
            updateSlider(val)
        end
    end)
    return row
end

-- Dropdown
local function makeDropdown(labelText, options, stateKey, order, callback)
    local row = Instance.new("Frame")
    row.LayoutOrder = order or 0
    row.Size   = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = TABSEL
    row.BorderSizePixel  = 0
    row.ClipsDescendants = false
    row.ZIndex = 5
    row.Parent = ContentFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel")
    lbl.Size   = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font   = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = WHITE
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text   = labelText
    lbl.Parent = row

    local selBtn = Instance.new("TextButton")
    selBtn.Size  = UDim2.new(0.5, -8, 0.8, 0)
    selBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
    selBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
    selBtn.Font  = Enum.Font.GothamBold
    selBtn.TextSize = 11
    selBtn.TextColor3 = RED
    selBtn.Text  = State[stateKey] .. " ▾"
    selBtn.Parent = row
    Instance.new("UICorner", selBtn).CornerRadius = UDim.new(0, 4)

    local dropFrame = Instance.new("Frame")
    dropFrame.Size   = UDim2.new(0.5, -8, 0, #options * 26)
    dropFrame.Position = UDim2.new(0.5, 0, 1, 2)
    dropFrame.BackgroundColor3 = Color3.fromRGB(25, 5, 5)
    dropFrame.BorderSizePixel  = 0
    dropFrame.ZIndex = 10
    dropFrame.Visible = false
    dropFrame.Parent = row
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 4)

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size  = UDim2.new(1, 0, 0, 26)
        optBtn.Position = UDim2.new(0, 0, 0, (i-1)*26)
        optBtn.BackgroundTransparency = 1
        optBtn.Font  = Enum.Font.Gotham
        optBtn.TextSize = 11
        optBtn.TextColor3 = WHITE
        optBtn.Text  = opt
        optBtn.ZIndex = 11
        optBtn.Parent = dropFrame
        optBtn.MouseButton1Click:Connect(function()
            State[stateKey] = opt
            selBtn.Text = opt .. " ▾"
            dropFrame.Visible = false
            if callback then callback(opt) end
        end)
    end

    selBtn.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
    end)
    return row
end

-- Teleport row (dropdown musuh + tombol)
local function makeTeleportRow(order)
    local row = Instance.new("Frame")
    row.LayoutOrder = order or 0
    row.Size   = UDim2.new(1, 0, 0, 56)
    row.BackgroundColor3 = TABSEL
    row.BorderSizePixel  = 0
    row.ClipsDescendants = false
    row.ZIndex = 5
    row.Parent = ContentFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    -- Toggle
    local toggleRow = Instance.new("Frame")
    toggleRow.Size   = UDim2.new(1, 0, 0, 28)
    toggleRow.BackgroundTransparency = 1
    toggleRow.Parent = row

    local box = Instance.new("Frame")
    box.Size   = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(0, 6, 0.5, -8)
    box.BackgroundColor3 = DARK
    box.BorderSizePixel  = 0
    box.Parent = toggleRow
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
    local boxStroke2 = Instance.new("UIStroke", box)
    boxStroke2.Color = RED boxStroke2.Thickness = 1
    local check2 = Instance.new("TextLabel")
    check2.Size  = UDim2.new(1, 0, 1, 0) check2.BackgroundTransparency = 1
    check2.Font  = Enum.Font.GothamBold check2.TextSize = 12 check2.TextColor3 = RED
    check2.Text  = "" check2.Parent = box

    local lbl2 = Instance.new("TextLabel")
    lbl2.Size  = UDim2.new(0.5, -28, 1, 0) lbl2.Position = UDim2.new(0, 28, 0, 0)
    lbl2.BackgroundTransparency = 1 lbl2.Font = Enum.Font.Gotham
    lbl2.TextSize = 12 lbl2.TextColor3 = WHITE lbl2.TextXAlignment = Enum.TextXAlignment.Left
    lbl2.Text  = "Teleport Toggle" lbl2.Parent = toggleRow

    -- Dropdown enemies
    local selBtn2 = Instance.new("TextButton")
    selBtn2.Size  = UDim2.new(0.45, -4, 0.8, 0)
    selBtn2.Position = UDim2.new(0.55, 0, 0.1, 0)
    selBtn2.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
    selBtn2.Font  = Enum.Font.GothamBold selBtn2.TextSize = 10
    selBtn2.TextColor3 = RED selBtn2.Text = "Target ▾" selBtn2.Parent = toggleRow
    Instance.new("UICorner", selBtn2).CornerRadius = UDim.new(0, 4)

    -- Dropdown frame
    local dropFrame2 = Instance.new("ScrollingFrame")
    dropFrame2.Size  = UDim2.new(0.45, -4, 0, 80)
    dropFrame2.Position = UDim2.new(0.55, 0, 1, 2)
    dropFrame2.BackgroundColor3 = Color3.fromRGB(25, 5, 5)
    dropFrame2.BorderSizePixel  = 0 dropFrame2.ZIndex = 10 dropFrame2.Visible = false
    dropFrame2.CanvasSize = UDim2.new(0,0,0,0) dropFrame2.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dropFrame2.ScrollBarThickness = 2 dropFrame2.Parent = row
    Instance.new("UICorner", dropFrame2).CornerRadius = UDim.new(0, 4)
    local dl = Instance.new("UIListLayout", dropFrame2) dl.SortOrder = Enum.SortOrder.LayoutOrder

    -- Teleport button
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size   = UDim2.new(1, -12, 0, 22)
    tpBtn.Position = UDim2.new(0, 6, 0, 30)
    tpBtn.BackgroundColor3 = RED
    tpBtn.Font   = Enum.Font.GothamBold tpBtn.TextSize = 11
    tpBtn.TextColor3 = WHITE tpBtn.Text = "⚡ Teleport Now" tpBtn.Parent = row
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)

    local function refreshEnemies()
        for _, c in ipairs(dropFrame2:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, p in ipairs(getEnemies()) do
            local ob = Instance.new("TextButton")
            ob.Size  = UDim2.new(1, 0, 0, 22) ob.BackgroundTransparency = 1
            ob.Font  = Enum.Font.Gotham ob.TextSize = 10 ob.TextColor3 = WHITE ob.Text = p.Name
            ob.ZIndex = 11 ob.Parent = dropFrame2
            ob.MouseButton1Click:Connect(function()
                State.TeleportTarget = p.Name
                selBtn2.Text = p.Name .. " ▾"
                dropFrame2.Visible = false
            end)
        end
    end

    selBtn2.MouseButton1Click:Connect(function()
        refreshEnemies()
        dropFrame2.Visible = not dropFrame2.Visible
    end)

    tpBtn.MouseButton1Click:Connect(function()
        teleportToTarget()
    end)

    local btn3 = Instance.new("TextButton")
    btn3.Size  = UDim2.new(0.5, -28, 1, 0)
    btn3.Position = UDim2.new(0, 6, 0, 0)
    btn3.BackgroundTransparency = 1 btn3.Text = "" btn3.Parent = toggleRow
    btn3.MouseButton1Click:Connect(function()
        State.TeleportToggle = not State.TeleportToggle
        check2.Text = State.TeleportToggle and "✓" or ""
        box.BackgroundColor3 = State.TeleportToggle and Color3.fromRGB(30, 10, 10) or DARK
    end)
    return row
end

-- ══════════════════════════════════════════
--           TAB SYSTEM
-- ══════════════════════════════════════════
local tabPages = {}
local tabBtns  = {}
local tabNames = {"Main", "Aim", "Visual", "Exploits"}

local function buildTabBtn(name, idx)
    local btn = Instance.new("TextButton")
    btn.LayoutOrder = idx
    btn.Size   = UDim2.new(0.9, 0, 0, 38)
    btn.BackgroundColor3 = DARK
    btn.Font   = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = DIM
    btn.Text   = name
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    tabBtns[name] = btn
    return btn
end

local function activateTab(name)
    for _, existing in ipairs(ContentFrame:GetChildren()) do
        if existing:IsA("Frame") or existing:IsA("TextLabel") or existing:IsA("ScrollingFrame") then
            existing:Destroy()
        end
    end

    for n, b in pairs(tabBtns) do
        b.TextColor3 = n == name and WHITE or DIM
        b.BackgroundColor3 = n == name and TABSEL or DARK
        local leftBar = b:FindFirstChild("LeftBar")
        if leftBar then leftBar:Destroy() end
        if n == name then
            local lb = Instance.new("Frame")
            lb.Name  = "LeftBar"
            lb.Size  = UDim2.new(0, 3, 0.7, 0)
            lb.Position = UDim2.new(0, 0, 0.15, 0)
            lb.BackgroundColor3 = RED
            lb.BorderSizePixel  = 0
            lb.Parent = b
            Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 2)
        end
    end

    if name == "Main" then
        makeSection("MAIN SETTINGS", 1)
        makeToggle("Enable Feature", "EnableFeature", 2)
        makeToggle("Enable Aim",     "EnableAim",     3)
        makeToggle("Enable ESP",     "EnableEsp",     4)

    elseif name == "Aim" then
        makeSection("AIM SETTINGS", 1)
        makeToggle("Aimbot Fire",          "AimbotFire",    2)
        makeToggle("Aimbot Legit",         "AimbotLegit",   3)
        makeToggle("Aim Assist",           "AimAssist",     4)
        makeToggle("Aim Silent",           "AimSilent",     5)
        makeToggle("Aim Visible",          "AimVisible",    6)
        makeToggle("Aim Magnet (Testing)", "AimMagnet",     7)
        makeToggle("Aim Kill (Testing)",   "AimKill",       8)
        makeDropdown("Aim Target", {"Body", "Head", "Random"}, "AimTarget", 9)
        makeSlider("Aim FoV", "AimFov", 1, 360, 10)

    elseif name == "Visual" then
        makeSection("VISUAL SETTINGS", 1)
        makeToggle("Esp Line",     "EspLine",     2)
        makeToggle("Esp Box",      "EspBox",      3)
        makeToggle("Esp Hitbox 3D","EspHitbox3D", 4)
        makeToggle("Esp Health",   "EspHealth",   5)
        makeToggle("Esp Distance", "EspDistance", 6)
        makeToggle("Esp Name",     "EspName",     7)
        makeToggle("Esp Skeleton", "EspSkeleton", 8)

    elseif name == "Exploits" then
        makeSection("EXPLOIT SETTINGS", 1)
        makeToggle("Speed Hack (2x)",   "SpeedHack",   2, function(v) applySpeedHack(v) end)
        makeToggle("Jump Boost (2x)",   "JumpBoost",   3, function(v) applyJumpBoost(v) end)
        makeToggle("Double Jump",       "DoubleJump",  4, function(v) applyDoubleJump(v) end)
        makeTeleportRow(5)
        makeToggle("Fly Auto Toggle",   "FlyAuto",     6, function(v) applyFlyAuto(v) end)
        makeToggle("Fly to Player Toggle","FlyToPlayer",7, function(v)
            if v then task.spawn(flyToPlayer) end
        end)
        makeToggle("Fast Reload (100x)","FastReload",  8, function(v) applyFastReload(v) end)
        makeToggle("Speed Fire (100x)", "SpeedFire",   9, function(v) applySpeedFire(v) end)
    end
end

for i, name in ipairs(tabNames) do
    local btn = buildTabBtn(name, i)
    btn.MouseButton1Click:Connect(function()
        activateTab(name)
    end)
end

activateTab("Main")

-- Notify
StarterGui:SetCore("SendNotification", {
    Title    = "SantaX Mods",
    Text     = "Loaded — Created by Astra",
    Duration = 4,
})

print("[SantaX Mods] Loaded by Astra — Arsenal & FPS Ready")
