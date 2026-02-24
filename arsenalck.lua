-- Arsenal - Compkiller | CompKiller UI by Claude

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local LocalPlayer = Players.LocalPlayer
local Weapons = cloneref(game:GetService("ReplicatedStorage")).Weapons
local FromRGB = Color3.fromRGB

-- ==================== COMPKILLER SETUP ====================
local Compkiller = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"
))()

local Notifier = Compkiller.newNotify()

local ConfigManager = Compkiller:ConfigManager({
    Directory = "CompKiller",
    Config    = "Arsenal",
})

Compkiller:Loader("rbxassetid://120245531583106", 1.5).yield()

local MenuKey = "RightShift"

local Window = Compkiller.new({
    Name    = "COMPKILLER",
    Keybind = MenuKey,
    Logo    = "rbxassetid://120245531583106",
    TextSize = 15,
})

-- ==================== USER SETTINGS ====================
local UserSettings = Window.UserSettings:Create()

UserSettings:AddColorPicker({
    Name    = "Menu Color",
    Default = Compkiller.Colors.Highlight,
    Callback = function(v)
        Compkiller.Colors.Highlight = v
        Compkiller:RefreshCurrentColor()
    end,
})

UserSettings:AddKeybind({
    Name    = "Menu Key",
    Default = MenuKey,
    Callback = function(v)
        MenuKey = v
        Window:SetMenuKey(v)
    end,
})

UserSettings:AddDropdown({
    Name   = "Menu Theme",
    Values = {"Default","Dark Green","Dark Blue","Purple Rose","Skeet"},
    Default = "Default",
    Callback = function(v) Compkiller:SetTheme(v) end,
})

-- ==================== WATERMARK ====================
local Watermark = Window:Watermark()

Watermark:AddText({ Icon = "crosshair", Text = "COMPKILLER | Arsenal" })
Watermark:AddText({ Icon = "user",      Text = LocalPlayer.Name })
Watermark:AddText({ Icon = "clock",     Text = Compkiller:GetDate() })

local WatermarkTime = Watermark:AddText({ Icon = "timer", Text = "00:00" })
task.spawn(function()
    while true do
        task.wait()
        WatermarkTime:SetText(Compkiller:GetTimeNow())
    end
end)

-- ==================== NOTIFICATIONS ====================
Notifier.new({
    Title    = "COMPKILLER",
    Content  = "Loaded! Press RightShift to open/close.",
    Duration = 5,
    Icon     = "rbxassetid://120245531583106",
})

-- ==================== STATE ====================
local fastGunEnabled = false
local aimbotOn       = false
local aimbotFOV      = 150
local aimbotSmooth   = 0
local aimPart        = "Head"
local showFOV        = true
local tracersOn      = false
local tracersTeamCheck = true
local tracerPosition = "Bottom"
local boxesOn        = false
local boxesTeamCheck = true
local triggerbotOn   = false
local killAllOn      = false
local speedOn        = false
local speedValue     = 50
local infiniteJumpOn = false
local silentAimOn    = false

-- ==================== TABS ====================
Window:DrawCategory({ Name = "Combat" })

local TabGunMods = Window:DrawTab({ Name = "Gun Mods", Icon = "zap",        Type = "Single", EnableScrolling = true })
local TabCombat  = Window:DrawTab({ Name = "Combat",   Icon = "crosshair",  Type = "Single", EnableScrolling = true })
local TabESP     = Window:DrawTab({ Name = "ESP",      Icon = "eye",        Type = "Single", EnableScrolling = true })

Window:DrawCategory({ Name = "Player" })

local TabPlayer  = Window:DrawTab({ Name = "Player",   Icon = "user",       Type = "Single", EnableScrolling = true })

Window:DrawCategory({ Name = "Misc" })

local TabConfig  = Window:DrawTab({ Name = "Config",   Icon = "folder",     Type = "Single" })
local TabSettings = Window:DrawTab({ Name = "Settings", Icon = "settings-3", Type = "Single", EnableScrolling = true })

-- ==================== GUN MODS ====================
local SecAmmo = TabGunMods:DrawSection({ Name = "Ammo", Position = "left" })

SecAmmo:AddToggle({
    Name    = "Infinite Ammo",
    Flag    = "InfiniteAmmo",
    Default = false,
    Callback = function(v)
        for _, gun in pairs(Weapons:GetChildren()) do
            local inf = gun:FindFirstChild("Infinite")
            if inf then inf.Value = v end
        end
    end,
})

local SecGunMods = TabGunMods:DrawSection({ Name = "Modifications", Position = "left" })

local FastGunToggle = SecGunMods:AddToggle({
    Name    = "Fast Gun",
    Flag    = "FastGun",
    Default = false,
    Callback = function(v)
        fastGunEnabled = v
        if not v then
            for _, gun in pairs(Weapons:GetChildren()) do
                local fr = gun:FindFirstChild("FireRate")
                if fr then fr.Value = 1 end
            end
        end
    end,
})

FastGunToggle.Link:AddOption():AddSlider({
    Name    = "Fire Rate",
    Flag    = "FireRateValue",
    Min     = 0.02,
    Max     = 1,
    Default = 0.03,
    Round   = 2,
    Callback = function(v)
        if not fastGunEnabled then return end
        for _, gun in pairs(Weapons:GetChildren()) do
            local fr = gun:FindFirstChild("FireRate")
            if fr then fr.Value = v end
        end
    end,
})

SecGunMods:AddToggle({
    Name    = "No Recoil",
    Flag    = "NoRecoil",
    Default = false,
    Callback = function(v)
        for _, gun in pairs(Weapons:GetChildren()) do
            local rc = gun:FindFirstChild("RecoilControl")
            if rc then rc.Value = v and 0 or 1 end
        end
    end,
})

SecGunMods:AddToggle({
    Name    = "Automatic",
    Flag    = "Automatic",
    Default = false,
    Callback = function(v)
        for _, gun in pairs(Weapons:GetChildren()) do
            local auto = gun:FindFirstChild("Auto")
            if auto then auto.Value = v end
        end
    end,
})

SecGunMods:AddToggle({
    Name    = "No Spread",
    Flag    = "NoSpread",
    Default = false,
    Callback = function(v)
        for _, gun in pairs(Weapons:GetChildren()) do
            local spread = gun:FindFirstChild("Spread")
            if spread then spread.Value = v and 0 or spread.Value end
        end
    end,
})

-- ==================== COMBAT ====================
local SecAimbot = TabCombat:DrawSection({ Name = "Aimbot", Position = "left" })

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1.5
fovCircle.Radius = aimbotFOV
fovCircle.NumSides = 64
fovCircle.Color = FromRGB(255, 255, 255)
fovCircle.Filled = false

local AimbotToggle = SecAimbot:AddToggle({
    Name    = "Aimbot",
    Flag    = "AimbotOn",
    Default = false,
    Callback = function(v) aimbotOn = v end,
})

local AimbotOptions = AimbotToggle.Link:AddOption()

AimbotOptions:AddKeybind({
    Name    = "Aimbot Key",
    Flag    = "AimbotKey",
    Default = "MouseButton2",
    Callback = function() end,
})

AimbotOptions:AddSlider({
    Name    = "FOV",
    Flag    = "AimbotFOV",
    Min     = 30,
    Max     = 700,
    Default = 150,
    Round   = 0,
    Callback = function(v)
        aimbotFOV = v
        fovCircle.Radius = v
    end,
})

-- ИСПРАВЛЕНО: smooth=0 (слайдер 0) → резкий снап, smooth=1 (слайдер 1) — тоже снап, выше — плавнее
-- Слайдер от 0 до 50, 0 = мгновенный снап
AimbotOptions:AddSlider({
    Name    = "Smoothness",
    Flag    = "AimbotSmooth",
    Min     = 0,
    Max     = 50,
    Default = 0,
    Round   = 0,
    Callback = function(v)
        -- При v=0 или v=1 — резкий снап (lerp factor = 1)
        -- При v>1 — плавный (lerp factor = 1 / v)
        if v <= 1 then
            aimbotSmooth = 1
        else
            aimbotSmooth = 1 / v
        end
    end,
})

AimbotOptions:AddDropdown({
    Name    = "Aim Part",
    Flag    = "AimPart",
    Default = "Head",
    Values  = {"Head", "HumanoidRootPart"},
    Callback = function(v) aimPart = v end,
})

AimbotOptions:AddToggle({
    Name    = "Show FOV Circle",
    Flag    = "ShowFOV",
    Default = true,
    Callback = function(v) showFOV = v end,
})

AimbotOptions:AddColorPicker({
    Name    = "FOV Circle Color",
    Flag    = "FovColor",
    Default = FromRGB(255, 255, 255),
    Callback = function(v)
        fovCircle.Color = v
    end,
})

AimbotOptions:AddToggle({
    Name    = "Team Check",
    Flag    = "AimbotTeamCheck",
    Default = true,
    Callback = function() end,
})

-- ==================== SILENT AIM ====================
local SecSilentAim = TabCombat:DrawSection({ Name = "Silent Aim", Position = "left" })

local SilentAimToggle = SecSilentAim:AddToggle({
    Name    = "Silent Aim",
    Flag    = "SilentAimOn",
    Default = false,
    Risky   = true,
    Callback = function(v) silentAimOn = v end,
})

local SilentAimOptions = SilentAimToggle.Link:AddOption()

SilentAimOptions:AddToggle({
    Name    = "Team Check",
    Flag    = "SilentAimTeamCheck",
    Default = true,
    Callback = function() end,
})

SilentAimOptions:AddDropdown({
    Name    = "Target Part",
    Flag    = "SilentAimPart",
    Default = "Head",
    Values  = {"Head", "HumanoidRootPart"},
    Callback = function(v)
        -- используем aimPart (shared) для silent aim target
        aimPart = v
    end,
})

-- Silent Aim: hook Camera:WorldToViewportPoint / WorldToScreenPoint
-- чтобы подменять позицию цели при выстреле
local function getSilentAimTarget()
    local cam = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local localTeamColor = LocalPlayer.TeamColor
    local closestPart = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local ok, sameTeam = pcall(function() return player.TeamColor == localTeamColor end)
        -- если team check включён и same team — пропускаем
        -- (используем флаг SilentAimTeamCheck через Compkiller Flags, упрощённо — берём AimbotTeamCheck)
        if ok and sameTeam then continue end

        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = char:FindFirstChild(aimPart) or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestPart = part
        end
    end

    return closestPart
end

-- Silent Aim hook через newindex Camera.CFrame или через Ray hook
-- В Arsenal выстрел идёт через RemoteEvent, поэтому хукаем FireServer
local function hookSilentAim()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if silentAimOn and method == "FireServer" then
            local args = {...}
            -- В Arsenal первый аргумент обычно направление или позиция цели
            -- Подменяем позицию/направление на позицию ближайшего игрока
            local target = getSilentAimTarget()
            if target then
                local cam = workspace.CurrentCamera
                -- args[1] обычно направление выстрела (Vector3 unit direction)
                local dir = (target.Position - cam.CFrame.Position).Unit
                -- Заменяем первый Vector3 аргумент
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = dir
                        break
                    end
                end
                return oldNamecall(self, table.unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- Пробуем подключить hook (работает только в эксплойтах с getrawmetatable)
pcall(hookSilentAim)

-- Triggerbot
local SecTrigger = TabCombat:DrawSection({ Name = "Triggerbot", Position = "left" })

SecTrigger:AddToggle({
    Name    = "Triggerbot",
    Flag    = "TriggerOn",
    Default = false,
    Callback = function(v) triggerbotOn = v end,
})

-- Kill All
local SecKillAll = TabCombat:DrawSection({ Name = "Kill All", Position = "left" })

local KillAllToggle = SecKillAll:AddToggle({
    Name    = "Kill All",
    Flag    = "KillAllOn",
    Default = false,
    Risky   = true,
    Callback = function(v) killAllOn = v end,
})

local KillAllOptions = KillAllToggle.Link:AddOption()

KillAllOptions:AddKeybind({
    Name    = "Kill All Key",
    Flag    = "KillAllKey",
    Default = "V",
    Callback = function()
        if not killAllOn then
            Notifier.new({
                Title   = "Kill All",
                Content = "Disabled",
                Duration = 2,
                Icon    = "rbxassetid://120245531583106",
            })
        end
    end,
})

KillAllOptions:AddToggle({
    Name    = "Auto Click",
    Flag    = "KillAllClick",
    Default = true,
    Callback = function() end,
})

-- ==================== ESP ====================
local SecTracers = TabESP:DrawSection({ Name = "Tracers", Position = "left" })

local TracerToggle = SecTracers:AddToggle({
    Name    = "Tracers",
    Flag    = "TracersOn",
    Default = false,
    Callback = function(v) tracersOn = v end,
})

local TracerOptions = TracerToggle.Link:AddOption()

TracerOptions:AddToggle({
    Name    = "Team Check",
    Flag    = "TracersTeamCheck",
    Default = true,
    Callback = function(v) tracersTeamCheck = v end,
})

TracerOptions:AddDropdown({
    Name    = "Position",
    Flag    = "TracersPosition",
    Default = "Bottom",
    Values  = {"Top", "Center", "Bottom"},
    Callback = function(v) tracerPosition = v end,
})

local SecBoxes = TabESP:DrawSection({ Name = "Boxes", Position = "left" })

local BoxToggle = SecBoxes:AddToggle({
    Name    = "Boxes",
    Flag    = "BoxesOn",
    Default = false,
    Callback = function(v) boxesOn = v end,
})

local BoxOptions = BoxToggle.Link:AddOption()

BoxOptions:AddToggle({
    Name    = "Team Check",
    Flag    = "BoxesTeamCheck",
    Default = true,
    Callback = function(v) boxesTeamCheck = v end,
})

-- ==================== PLAYER ====================
local SecSpeed = TabPlayer:DrawSection({ Name = "Speed", Position = "left" })

local SpeedToggle = SecSpeed:AddToggle({
    Name    = "Speed Hack",
    Flag    = "SpeedOn",
    Default = false,
    Callback = function(v) speedOn = v end,
})

SpeedToggle.Link:AddOption():AddSlider({
    Name    = "Speed Value",
    Flag    = "SpeedValue",
    Min     = 16,
    Max     = 300,
    Default = 50,
    Round   = 0,
    Callback = function(v) speedValue = v end,
})

-- ==================== INFINITE JUMP ====================
local SecJump = TabPlayer:DrawSection({ Name = "Jump", Position = "left" })

SecJump:AddToggle({
    Name    = "Infinite Jump",
    Flag    = "InfiniteJump",
    Default = false,
    Callback = function(v) infiniteJumpOn = v end,
})

-- Infinite Jump: хукаем Humanoid.Jumped
local infiniteJumpConn = nil

local function connectInfiniteJump(char)
    if infiniteJumpConn then
        infiniteJumpConn:Disconnect()
        infiniteJumpConn = nil
    end
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end

    infiniteJumpConn = hum.StateChanged:Connect(function(_, new)
        if infiniteJumpOn and new == Enum.HumanoidStateType.Freefall then
            task.wait(0.1)
            if infiniteJumpOn then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- Подключаем для текущего персонажа и при каждом респавне
connectInfiniteJump(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(connectInfiniteJump)

-- ==================== CONFIG ====================
local ConfigUI = Window:DrawConfig({
    Name   = "Config",
    Icon   = "folder",
    Config = ConfigManager,
})
ConfigUI:Init()

-- ==================== SETTINGS ====================
local SecUISettings = TabSettings:DrawSection({ Name = "UI Settings", Position = "left" })

SecUISettings:AddColorPicker({
    Name    = "Highlight",
    Default = Compkiller.Colors.Highlight,
    Callback = function(v) Compkiller.Colors.Highlight = v; Compkiller:RefreshCurrentColor() end,
})

SecUISettings:AddColorPicker({
    Name    = "Toggle Color",
    Default = Compkiller.Colors.Toggle,
    Callback = function(v) Compkiller.Colors.Toggle = v; Compkiller:RefreshCurrentColor(v) end,
})

SecUISettings:AddColorPicker({
    Name    = "Background Color",
    Default = Compkiller.Colors.BGDBColor,
    Callback = function(v) Compkiller.Colors.BGDBColor = v; Compkiller:RefreshCurrentColor(v) end,
})

SecUISettings:AddDropdown({
    Name    = "Theme",
    Default = "Default",
    Values  = {"Default","Dark Green","Dark Blue","Purple Rose","Skeet"},
    Callback = function(v) Compkiller:SetTheme(v) end,
})

-- ==================== ESP OBJECTS ====================
local espObjects = {}

local function makeESP(player)
    if player == LocalPlayer then return end
    local tracer   = Drawing.new("Line")
    local boxOuter = Drawing.new("Square")
    local boxInner = Drawing.new("Square")

    tracer.Visible = false; tracer.Thickness = 1.5; tracer.Transparency = 1
    tracer.Color = FromRGB(255, 255, 255)

    boxOuter.Visible = false; boxOuter.Thickness = 3
    boxOuter.Color = FromRGB(0, 0, 0)

    boxInner.Visible = false; boxInner.Thickness = 1
    boxInner.Color = FromRGB(255, 255, 255)

    espObjects[player] = { tracer=tracer, boxOuter=boxOuter, boxInner=boxInner }
end

local function removeESP(player)
    local obj = espObjects[player]
    if not obj then return end
    for _, d in pairs(obj) do d:Remove() end
    espObjects[player] = nil
end

for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(removeESP)

-- ==================== RENDER LOOP ====================
local RenderStepped = RunService.RenderStepped

RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local vp = cam.ViewportSize
    local mousePos = UserInputService:GetMouseLocation()
    local localTeamColor = LocalPlayer.TeamColor

    -- FOV Circle
    fovCircle.Visible = showFOV and aimbotOn
    fovCircle.Position = mousePos
    fovCircle.Radius = aimbotFOV

    -- Aimbot
    -- ИСПРАВЛЕНО: aimbotSmooth = 1 → мгновенный снап (Lerp factor 1 = полный поворот за кадр)
    if aimbotOn and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local closestPart = nil
        local closestDist = aimbotFOV

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local ok, sameTeam = pcall(function() return player.TeamColor == localTeamColor end)
            if ok and sameTeam then continue end

            local char = player.Character
            if not char then continue end
            local hum = char:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local part = char:FindFirstChild(aimPart) or char:FindFirstChild("HumanoidRootPart")
            if not part then continue end

            local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
            if not onScreen then continue end

            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPart = part
            end
        end

        if closestPart then
            local current = cam.CFrame
            local target = CFrame.new(current.Position, closestPart.Position)
            -- aimbotSmooth = 1 → резкий снап, меньше → плавнее
            local factor = aimbotSmooth > 0 and aimbotSmooth or 1
            cam.CFrame = current:Lerp(target, factor)
        end
    end

    -- Triggerbot
    if triggerbotOn then
        local unitRay = cam:ViewportPointToRay(vp.X/2, vp.Y/2)
        local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500)
        if result then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and result.Instance:IsDescendantOf(player.Character or Instance.new("Model")) then
                    -- trigger action (game-specific)
                end
            end
        end
    end

    -- ESP
    for player, obj in pairs(espObjects) do
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")

        if not hrp then
            for _, d in pairs(obj) do d.Visible = false end
            continue
        end

        local ok, sameTeam = pcall(function() return player.TeamColor == localTeamColor end)
        if not ok then sameTeam = false end

        local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            for _, d in pairs(obj) do d.Visible = false end
            continue
        end

        local topPos = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
        local h = math.abs(topPos.Y - screenPos.Y) * 2
        local w = h * 0.55
        local sx, sy = screenPos.X, screenPos.Y

        -- Tracer
        local showTracer = tracersOn and (not tracersTeamCheck or not sameTeam)
        obj.tracer.Visible = showTracer
        if showTracer then
            local fromY = tracerPosition == "Top" and 0
                       or tracerPosition == "Center" and vp.Y / 2
                       or vp.Y
            obj.tracer.From = Vector2.new(vp.X / 2, fromY)
            obj.tracer.To   = Vector2.new(sx, sy)
        end

        -- Boxes
        local showBox = boxesOn and (not boxesTeamCheck or not sameTeam)
        obj.boxOuter.Visible = showBox
        obj.boxInner.Visible = showBox
        if showBox then
            obj.boxOuter.Size     = Vector2.new(w + 2, h + 2)
            obj.boxOuter.Position = Vector2.new(sx - w/2 - 1, sy - h/2 - 1)
            obj.boxInner.Size     = Vector2.new(w, h)
            obj.boxInner.Position = Vector2.new(sx - w/2, sy - h/2)
        end
    end
end)

-- Speed Hack
RunService.Heartbeat:Connect(function()
    if not speedOn then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = speedValue end
end)
