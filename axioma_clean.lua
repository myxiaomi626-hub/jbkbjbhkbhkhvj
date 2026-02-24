-- Axioma.lua | Cleaned by Claude
-- Original: UnveilR V3.01 deobfuscated

local fenv = getfenv()
local Library_Lua = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local ThemeManager_Lua = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager_Lua = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"))()

local Toggles = fenv.Toggles
local Options = fenv.Options

local CurrentCamera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Weapons = ReplicatedStorage:FindFirstChild("Weapons")
local Events = ReplicatedStorage:FindFirstChild("Events")

local Vector3_New = Vector3.new
local Color3_New = Color3.new
local FromRGB = Color3.fromRGB

-- UI Setup
local Window = Library_Lua:CreateWindow({
    AutoShow = true,
    Title = "Axioma.lua | .gg/vWWUjmP9rd by robert",
    Center = true,
})

local TabCombat  = Window:AddTab("Combat")
local TabAntiAim = Window:AddTab("Anti Aim")
local TabVisuals = Window:AddTab("Visuals")
local TabMisc    = Window:AddTab("Misc")
local TabSettings = Window:AddTab("Settings")

-- Visuals groups
local GrpESP       = TabVisuals:AddLeftGroupbox("ESP Settings")
local GrpFill      = TabVisuals:AddLeftGroupbox("Box Fill")
local GrpOutlines  = TabVisuals:AddLeftGroupbox("Outlines Settings")
local GrpCamera    = TabVisuals:AddLeftGroupbox("Camera")
local GrpWorld     = TabVisuals:AddRightGroupbox("World & Fog")
local GrpChams     = TabVisuals:AddRightGroupbox("Enemy Chams")
local GrpLocalChams= TabVisuals:AddRightGroupbox("Local Chams")
local GrpTracers   = TabVisuals:AddRightGroupbox("Bullet Tracers")
local GrpHitSound  = TabVisuals:AddRightGroupbox("Hit Sound")

-- Combat groups
local GrpSilent    = TabCombat:AddLeftGroupbox("Silent Aim")
local GrpGunMod    = TabCombat:AddRightGroupbox("Gun Modifications")
local GrpAutoFire  = TabCombat:AddRightGroupbox("Auto Fire")

-- Anti Aim groups
local GrpAngle     = TabAntiAim:AddLeftGroupbox("Angle Anti-Aim")
local GrpDesync    = TabAntiAim:AddRightGroupbox("Desync")
local GrpPitch     = TabAntiAim:AddRightGroupbox("Pitch Changer")

-- Misc groups
local GrpMovement  = TabMisc:AddLeftGroupbox("Movement")
local GrpMiscRight = TabMisc:AddRightGroupbox("Miscellaneous")

-- ==================== ESP ====================
GrpESP:AddToggle("team_check",    { Default = false, Text = "Team Check" })
GrpESP:AddToggle("esp_box",       { Default = false, Text = "Enable Box" })
    :AddColorPicker("box_col",    { Default = Color3_New(1, 1, 1) })
GrpESP:AddDropdown("box_style",   { Text = "Box Style", Values = {"Full","Corner"}, Default = 1 })
GrpESP:AddToggle("esp_name",      { Default = false, Text = "Names" })
    :AddColorPicker("name_col",   { Default = Color3_New(1, 1, 1) })
GrpESP:AddToggle("esp_dist",      { Default = false, Text = "Distance" })
    :AddColorPicker("dist_col",   { Default = Color3_New(1, 1, 1) })
GrpESP:AddToggle("esp_hp",        { Default = false, Text = "Health Bar" })
    :AddColorPicker("hp_col",     { Default = FromRGB(0, 255, 0) })
GrpESP:AddToggle("esp_skel",      { Default = false, Text = "Skeleton" })
    :AddColorPicker("skel_col",   { Default = Color3_New(1, 1, 1) })

-- Box Fill
GrpFill:AddToggle("esp_fill",     { Default = false, Text = "Enable Fill" })
    :AddColorPicker("fill_col",   { Default = Color3_New(0, 0, 0) })
GrpFill:AddSlider("fill_trans",   { Min = 0, Default = 50, Max = 100, Text = "Fill Transparency", Rounding = 0 })

-- Outlines
GrpOutlines:AddToggle("esp_box_outline",  { Default = true, Text = "Box Outline" })
GrpOutlines:AddToggle("esp_name_outline", { Default = true, Text = "Name Outline" })
GrpOutlines:AddToggle("esp_dist_outline", { Default = true, Text = "Distance Outline" })
GrpOutlines:AddToggle("esp_hp_outline",   { Default = true, Text = "Health Outline" })

-- Camera
GrpCamera:AddToggle("third_person", { Default = false, Text = "Third Person" })
GrpCamera:AddSlider("tp_dist",      { Min = 0, Default = 15, Max = 50, Text = "Distance", Rounding = 1 })

-- Enemy Chams
GrpChams:AddToggle("chams_enable",  { Default = false, Text = "Enable Enemy Chams" })
    :AddColorPicker("chams_col",    { Default = FromRGB(255, 0, 0) })
GrpChams:AddSlider("chams_trans",   { Min = 0, Default = 50, Max = 100, Text = "Transparency", Rounding = 0 })

-- Local Chams
GrpLocalChams:AddToggle("local_chams",   { Default = false, Text = "Enable Local Chams" })
    :AddColorPicker("local_chams_col",   { Default = Color3_New(0, 1, 1) })
GrpLocalChams:AddDropdown("local_mat",   { Text = "Material", Values = {"Neon","ForceField"}, Default = 1 })

-- World & Fog
GrpWorld:AddToggle("world_enable",  { Default = false, Text = "World Mod" })
GrpWorld:AddSlider("world_time",    { Min = 0, Default = 12, Max = 24, Text = "Time", Rounding = 1 })
GrpWorld:AddLabel("Ambient"):AddColorPicker("amb_col",     { Default = FromRGB(127, 127, 127) })
GrpWorld:AddLabel("Outdoor"):AddColorPicker("amb_out_col", { Default = FromRGB(127, 127, 127) })
GrpWorld:AddToggle("fog_custom",    { Default = false, Text = "Custom Fog" })
GrpWorld:AddLabel("Fog Color"):AddColorPicker("fog_col",   { Default = FromRGB(192, 192, 192) })
GrpWorld:AddSlider("fog_start",     { Min = 0, Default = 0,    Max = 1000,  Text = "Fog Start", Rounding = 0 })
GrpWorld:AddSlider("fog_end",       { Min = 0, Default = 10000,Max = 100000,Text = "Fog End",   Rounding = 0 })

-- Arms/Guns Chams
TabVisuals:AddRightGroupbox("Arms / Guns Chams")
    :AddToggle("arms_chams",        { Default = false, Text = "Enable Arms Chams" })
    :AddColorPicker("arms_chams_col", { Default = FromRGB(200, 200, 200) })

-- Bullet Tracers
GrpTracers:AddToggle("bullet_tracers",  { Default = false, Text = "Enable Tracers" })
GrpTracers:AddSlider("tracer_lifetime", { Min = 0.1, Default = 1, Max = 10, Text = "Tracer Lifetime", Rounding = 1 })
GrpTracers:AddLabel("Tracer Color"):AddColorPicker("tracer_col", { Default = FromRGB(255, 0, 255) })

-- ==================== COMBAT ====================
GrpSilent:AddToggle("silent_enabled",  { Default = false, Text = "Enable Silent Aim" })
GrpSilent:AddToggle("show_fov",        { Default = false, Text = "Show FOV" })
    :AddColorPicker("fov_col",         { Default = FromRGB(255, 255, 255) })
GrpSilent:AddSlider("silent_fov",      { Min = 10, Default = 100, Max = 1500, Text = "FOV Radius", Rounding = 0 })
GrpSilent:AddSlider("silent_pred",     { Min = 0, Default = 0.12, Max = 0.5, Text = "Base Prediction", Rounding = 3 })
GrpSilent:AddToggle("advanced_pred",   { Default = true, Text = "Advanced Prediction (HvH)" })
GrpSilent:AddDropdown("silent_disablers", {
    Text = "Disablers", Multi = true,
    Values = {"Wall","ForceField","Teammates"},
    Default = {"Teammates"}
})
GrpSilent:AddDropdown("silent_target", { Text = "Aim Part", Values = {"Head","Torso"}, Default = 1 })

-- Gun Modifications
GrpGunMod:AddToggle("rapid_fire",  { Default = false, Text = "Rapid Fire" })
GrpGunMod:AddToggle("inf_ammo",    { Default = false, Text = "Infinite Ammo" })
GrpGunMod:AddToggle("no_spread",   { Default = false, Text = "No Spread" })
GrpGunMod:AddToggle("double_tap",  { Default = false, Text = "Double Tap" })

-- Auto Fire
GrpAutoFire:AddToggle("auto_fire",        { Default = false, Text = "Enable Auto Fire" })
GrpAutoFire:AddToggle("wallbang",         { Default = false, Text = "Wallbang" })
GrpAutoFire:AddSlider("auto_fire_delay",  { Min = 50, Default = 75, Max = 500, Text = "Fire Delay (ms)", Rounding = 0 })

-- ==================== MOVEMENT ====================
GrpMovement:AddToggle("bhop",        { Default = false, Text = "Bunny Hop" })
GrpMovement:AddSlider("bhop_speed",  { Min = 10, Default = 30, Max = 100, Text = "Bhop Speed", Rounding = 0 })
GrpMovement:AddSlider("bhop_smooth", { Min = 0.1, Default = 0.3, Max = 1, Text = "Bhop Smoothing", Rounding = 2 })
GrpMovement:AddToggle("jump_bug",    { Default = false, Text = "Jump Bug" })

-- ==================== ANTI AIM ====================
GrpAngle:AddToggle("spinbot_enabled", { Default = false, Text = "Spin Bot" })
GrpAngle:AddSlider("spinbot_speed",   { Min = 1, Default = 10, Max = 50, Text = "Spin Speed", Rounding = 0 })
GrpAngle:AddDivider()
GrpAngle:AddToggle("jitter_enabled",  { Default = false, Text = "Jitter" })
GrpAngle:AddSlider("jitter_from",     { Min = -180, Default = -45, Max = 180, Text = "Jitter From Angle", Rounding = 0 })
GrpAngle:AddSlider("jitter_to",       { Min = -180, Default = 45,  Max = 180, Text = "Jitter To Angle",   Rounding = 0 })
GrpAngle:AddSlider("jitter_speed",    { Min = 1, Default = 5, Max = 20, Text = "Jitter Speed", Rounding = 0 })
GrpAngle:AddDivider()
GrpAngle:AddToggle("backward_aa",    { Default = false, Text = "Backward" })
GrpAngle:AddDivider()
GrpAngle:AddToggle("custom_yaw",      { Default = false, Text = "Custom Yaw" })
GrpAngle:AddSlider("custom_yaw_angle",{ Min = -180, Default = 0, Max = 180, Text = "Yaw Angle", Rounding = 0 })

-- Desync
GrpDesync:AddToggle("desync_enabled", { Default = false, Text = "Enable Desync" })
GrpDesync:AddDropdown("desync_mode",  {
    Text = "Desync Mode",
    Values = {"Destroy Cheaters","Underground","Void Spam","Void","Rotation"},
    Default = 4
})

-- Pitch Changer
GrpPitch:AddToggle("pitch_changer",  { Default = false, Text = "Enable Pitch Changer" })
GrpPitch:AddDropdown("pitch_mode",   {
    Text = "Pitch Mode",
    Values = {"Down","Up","Custom","Half Up","Half Down"},
    Default = 1
})
GrpPitch:AddSlider("pitch_custom",   { Min = -89, Default = 0, Max = 89, Text = "Custom Pitch", Rounding = 0 })

-- Misc
GrpMiscRight:AddToggle("no_fall_damage", { Default = false, Text = "No Fall Damage" })

-- Hit Sound
GrpHitSound:AddToggle("hitsound_enabled", { Default = false, Text = "Enable Hit Sound" })
GrpHitSound:AddDropdown("hitsound_select",{ Text = "Sound", Values = {"Skeet","Neverlose","Bameware"}, Default = 1 })
GrpHitSound:AddSlider("hitsound_volume",  { Min = 0.1, Default = 3, Max = 10, Text = "Volume", Rounding = 1 })

-- ==================== HELPERS ====================

local function updateEnemyChams()
    if not Toggles.chams_enable.Value then return end

    local localTeam = LocalPlayer.Team
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local char = player.Character
        if not char then continue end

        -- Team check
        if Toggles.team_check.Value then
            if player.Team and player.Team == localTeam then continue end
        end

        local highlight = char:FindFirstChild("AxiomaChams")
        if highlight then
            highlight.Enabled = true
            highlight.FillColor = Options.chams_col.Value
            highlight.FillTransparency = (100 - Options.chams_trans.Value) / 100
        end
    end
end

local function updateLocalChams()
    local char = LocalPlayer.Character
    if not char then return end

    local highlight = char:FindFirstChild("AxiomaLocalChams")
    if not highlight then return end

    if not Toggles.local_chams.Value then
        highlight.Enabled = false
        return
    end

    highlight.Enabled = true
    highlight.FillColor = Options.local_chams_col.Value
    highlight.OutlineTransparency = 1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 1

    local color = Options.local_chams_col.Value
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.ForceField
            part.Color = color
        end
    end
end

-- ==================== CALLBACKS ====================

Toggles.chams_enable:OnChanged(updateEnemyChams)
Toggles.team_check:OnChanged(updateEnemyChams)
Options.chams_col:OnChanged(updateEnemyChams)
Options.chams_trans:OnChanged(updateEnemyChams)

Toggles.local_chams:OnChanged(updateLocalChams)
Options.local_chams_col:OnChanged(updateLocalChams)
Options.local_mat:OnChanged(updateLocalChams)

Toggles.rapid_fire:OnChanged(function(enabled)
    if not Weapons then return end
    for _, gun in ipairs(Weapons:GetChildren()) do
        local fireRate = gun:FindFirstChild("FireRate")
        if fireRate and (fireRate:IsA("NumberValue") or fireRate:IsA("IntValue")) then
            if enabled then
                fireRate.Value = 0.03
            end
        end
        local auto = gun:FindFirstChild("Auto")
        if auto and auto:IsA("BoolValue") then
            auto.Value = true
        end
    end
end)

Toggles.inf_ammo:OnChanged(function(enabled)
    if not Weapons then return end
    if not enabled then return end

    for _, gun in ipairs(Weapons:GetChildren()) do
        local ammo = gun:FindFirstChild("Ammo")
        local stored = gun:FindFirstChild("StoredAmmo")
        if ammo then ammo.Value = 999999 end
        if stored then stored.Value = 999999 end
    end

    -- Keep ammo topped up via RunService instead of repeated task.wait loops
    RunService.Heartbeat:Connect(function()
        if not Toggles.inf_ammo.Value then return end
        for _, gun in ipairs(Weapons:GetChildren()) do
            local ammo = gun:FindFirstChild("Ammo")
            local stored = gun:FindFirstChild("StoredAmmo")
            if ammo and ammo.Value < 999999 then ammo.Value = 999999 end
            if stored and stored.Value < 999999 then stored.Value = 999999 end
        end
    end)
end)
