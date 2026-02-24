-- [[ SolittaSoftware v3.0 - Admin Key System & All Features Maintained ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "SolittaSoftware | Counter Blox",
   LoadingTitle = "Solitta v3.0 Yükleniyor...",
   LoadingSubtitle = "Admin Key System Aktif!",
   ConfigurationSaving = {Enabled = true, FolderName = "SolittaConfigs"},
   KeySystem = true,
   KeySettings = {
      Title = "Solitta Admin Girişi",
      Subtitle = "Lütfen Admin Keyini Giriniz",
      Note = "DC Null_.zz", 
      FileName = "SolittaKey",
      SaveKey = true, 
      GrabKeyFromSite = false,
      Key = {"SolittaAdmin2026"}
   }
})

-- DEĞİŞKENLER
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

_G.Aimbot = false
_G.SilentAim = false
_G.TriggerBot = false
_G.AimbotFOV = 100
_G.ESPEnabled = false
_G.RainbowHands = false
_G.Tracers = false
_G.Bhop = false
_G.Mevlana = false
_G.Fly = false
_G.Noclip = false
_G.FieldOfView = 70
_G.ThirdPerson = false
_G.KillEffect = false

-- FOV ÇEMBERİ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness, FOVCircle.Color, FOVCircle.Transparency, FOVCircle.Visible = 1.5, Color3.fromRGB(255, 0, 0), 0.7, false

-- SEKMELER
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483345998)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- KILL EFFECT & TRACERS
local function CreateSkullEffect(pos)
    if not _G.KillEffect then return end
    local part = Instance.new("Part", workspace)
    part.Position, part.Anchored, part.CanCollide, part.Transparency = pos + Vector3.new(0, 3, 0), true, false, 1
    local att = Instance.new("Attachment", part)
    local bill = Instance.new("BillboardGui", att)
    bill.Size, bill.AlwaysOnTop = UDim2.new(2, 0, 2, 0), true
    local lbl = Instance.new("TextLabel", bill)
    lbl.BackgroundTransparency, lbl.Size, lbl.Text, lbl.TextSize = 1, UDim2.new(1, 0, 1, 0), "💀", 50
    task.spawn(function()
        for i = 1, 20 do part.CFrame = part.CFrame * CFrame.new(0, 0.1, 0) task.wait(0.05) end
        part:Destroy()
    end)
end

local function CreateCylinderTracer(from, to)
    if not _G.Tracers then return end
    local dist = (from - to).Magnitude
    local tracer = Instance.new("Part", workspace)
    tracer.Anchored, tracer.CanCollide, tracer.Shape = true, false, Enum.PartType.Cylinder
    tracer.Material, tracer.Size = Enum.Material.Neon, Vector3.new(dist, 0.15, 0.15)
    tracer.CFrame = CFrame.new(from:Lerp(to, 0.5), to) * CFrame.Angles(0, math.rad(90), 0)
    task.spawn(function()
        local t = 0
        while t < 1 do
            t = t + 0.1
            tracer.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            tracer.Transparency = t
            task.wait(0.05)
        end
        tracer:Destroy()
    end)
end

-- UI KONTROLLERİ
CombatTab:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) _G.SilentAim = v FOVCircle.Visible = v end})
CombatTab:CreateToggle({Name = "Hard Aimbot (Lock)", CurrentValue = false, Callback = function(v) _G.Aimbot = v end})
CombatTab:CreateKeybind({Name = "Triggerbot (T)", CurrentKeybind = "T", HoldToInteract = false, Callback = function() _G.TriggerBot = not _G.TriggerBot end})
CombatTab:CreateSlider({Name = "FOV Mesafesi", Range = {0, 250}, Increment = 5, CurrentValue = 100, Callback = function(v) _G.AimbotFOV = v FOVCircle.Radius = v end})

VisualsTab:CreateSlider({Name = "POV", Range = {70, 120}, Increment = 1, CurrentValue = 70, Callback = function(v) _G.FieldOfView = v end})
VisualsTab:CreateToggle({Name = "Third Person", CurrentValue = false, Callback = function(v) _G.ThirdPerson = v end})
VisualsTab:CreateToggle({Name = "Wired Rainbow Hands", CurrentValue = false, Callback = function(v) _G.RainbowHands = v end})
VisualsTab:CreateToggle({Name = "Rainbow Tracers", CurrentValue = false, Callback = function(v) _G.Tracers = v end})
VisualsTab:CreateToggle({Name = "Smart ESP", CurrentValue = false, Callback = function(v) _G.ESPEnabled = v end})
VisualsTab:CreateToggle({Name = "Skull Kill Effect", CurrentValue = false, Callback = function(v) _G.KillEffect = v end})

MiscTab:CreateKeybind({Name = "Fly (F)", CurrentKeybind = "F", HoldToInteract = false, Callback = function() _G.Fly = not _G.Fly end})
MiscTab:CreateKeybind({Name = "Noclip (N)", CurrentKeybind = "N", HoldToInteract = false, Callback = function() _G.Noclip = not _G.Noclip end})
MiscTab:CreateKeybind({Name = "Spinbot (V)", CurrentKeybind = "V", HoldToInteract = false, Callback = function() _G.Mevlana = not _G.Mevlana end})
MiscTab:CreateKeybind({Name = "Bhop (B)", CurrentKeybind = "B", HoldToInteract = false, Callback = function() _G.Bhop = not _G.Bhop end})

-- MOTOR OBJELERİ
local spin = Instance.new("BodyAngularVelocity")
spin.MaxTorque = Vector3.new(0, math.huge, 0)
spin.P = 50000 

local flyVelocity = Instance.new("BodyVelocity")
flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

-- EN YAKIN OYUNCU
local function GetClosest()
    local target, dist = nil, _G.AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local mDist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mDist < dist then dist = mDist target = p.Character end
            end
        end
    end
    return target
end

-- ANA DÖNGÜ
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    Camera.FieldOfView = _G.FieldOfView
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    -- NOCLIP (FIXED)
    if _G.Noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- SPINBOT (FLY/HILL FIX)
    if _G.Mevlana and hrp and hum then
        hum.AutoRotate = false
        spin.Parent = hrp
        spin.AngularVelocity = Vector3.new(0, 150, 0)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), math.rad(45), 0)
        hrp.Velocity = Vector3.new(hrp.Velocity.X, math.clamp(hrp.Velocity.Y, -0.5, 0), hrp.Velocity.Z)
    else
        if hum then hum.AutoRotate = true end
        spin.Parent = nil
    end

    -- FLY ENGINE
    if _G.Fly and hrp then
        flyVelocity.Parent = hrp
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        flyVelocity.Velocity = moveDir * 100
    else
        flyVelocity.Parent = nil
    end

    -- BHOP & SPEED
    if _G.Bhop and hum and hrp then
        hum.WalkSpeed = 28
        if hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    elseif hum and not _G.Fly then
        hum.WalkSpeed = 16
    end

    -- TRIGGERBOT + AUTO AIMLOCK (Tek Atma Modu)
    if _G.TriggerBot then
        local target = GetClosest()
        if target and target:FindFirstChild("Head") then
            local tPart = Mouse.Target
            if tPart and (tPart:IsDescendantOf(target) or tPart.Parent == target) then
                -- Kafaya kilitle ve ateş et
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
                mouse1press() task.wait(0.01) mouse1release()
            end
        end
    end

    -- AIMBOT (Sağ Tık)
    if _G.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosest()
        if target and target:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Head.Position)
        end
    end

    -- RAINBOW HANDS
    if _G.RainbowHands then
        for _, v in pairs(Camera:GetChildren()) do
            if v:IsA("Model") and (v.Name:find("Arm") or v.Name == "Arms") then
                for _, part in pairs(v:GetDescendants()) do
                    if part:IsA("BasePart") then part.Material = Enum.Material.ForceField part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
                end
            end
        end
    end

    -- ESP
    if _G.ESPEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("SolittaHL") or Instance.new("Highlight", p.Character)
                hl.Name = "SolittaHL"
                hl.FillColor = (p.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                hl.Enabled = true
            end
        end
    end
end)

-- INPUT (TRACERS & SILENT AIM)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = GetClosest()
        local endPos = (target and _G.SilentAim) and target.Head.Position or Mouse.Hit.p
        if _G.Tracers then CreateCylinderTracer(Camera.CFrame.Position - Vector3.new(0,1,0), endPos) end
        if target and _G.KillEffect then
            task.spawn(function() repeat task.wait() until target.Humanoid.Health <= 0 CreateSkullEffect(target.Head.Position) end)
        end
    end
end)

Rayfield:Notify({Title = "SolittaSoftware", Content = "TriggerLock, Noclip ve Motorlar Aktif!", Duration = 5})