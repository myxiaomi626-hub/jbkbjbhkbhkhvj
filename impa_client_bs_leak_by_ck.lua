-- Impa Client | Cleaned by Compkiller

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local Mouse1click = getfenv().mouse1click

-- Keybinds
local AimbotKey = Enum.KeyCode.LeftAlt
local TriggerKey = Enum.KeyCode.E

-- State
local Connections = {}
local PlayerDrawings = {}
local Heartbeat = RunService.Heartbeat

-- Tabs (ScrollingFrame references, filled after UI creation)
local AimbotTab, TriggerTab, SpinTab, VisualsTab, MiscTab, UtilTab, InfoTab

-- ===================== UI =====================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ImpaClient_" .. math.random(1000, 9999)
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main window frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 420)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(35, 38, 48)
MainStroke.Thickness = 1

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)

local HeaderLine = Instance.new("Frame", Header)
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BorderSizePixel = 0
HeaderLine.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
HeaderLine.BackgroundTransparency = 0.3

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Impa Client"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

-- Sidebar (tab buttons)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 85, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

-- Content area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -95, 1, -50)
ContentArea.Position = UDim2.new(0, 90, 0, 45)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- ===================== TAB SYSTEM =====================

local AllTabButtons = {}
local AllTabFrames = {}

local function updateCanvasSize(scrollFrame)
    local layout = scrollFrame:FindFirstChildOfClass("UIListLayout")
    if not layout then return end
    task.wait()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
end

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 30)
    btn.Position = UDim2.new(0, 4, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(140, 145, 160)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.Parent = Sidebar
    btn.BorderSizePixel = 0
    btn.ZIndex = 3
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local accent = Instance.new("Frame", btn)
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 3, 0.6, 0)
    accent.Position = UDim2.new(0, 0, 0.2, 0)
    accent.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
    accent.Visible = false

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.Visible = false
    scroll.ScrollBarThickness = 2
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = ContentArea
    scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 50, 50)
    scroll.BorderSizePixel = 0
    scroll.ZIndex = 3

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function refreshCanvas()
        updateCanvasSize(scroll)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas)
    scroll.ChildAdded:Connect(refreshCanvas)
    scroll.ChildRemoved:Connect(refreshCanvas)

    table.insert(AllTabButtons, btn)
    table.insert(AllTabFrames, scroll)

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(AllTabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
            b.TextColor3 = Color3.fromRGB(140, 145, 160)
            local a = b:FindFirstChild("Accent")
            if a then a.Visible = false end
        end
        for _, f in ipairs(AllTabFrames) do
            f.Visible = false
        end
        btn.BackgroundColor3 = Color3.fromRGB(32, 28, 30)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        accent.Visible = true
        scroll.Visible = true
        updateCanvasSize(scroll)
    end)

    return scroll
end

AimbotTab  = createTab("Aimbot")
TriggerTab = createTab("Trigger")
SpinTab    = createTab("Spin")
VisualsTab = createTab("Visuals")
MiscTab    = createTab("Misc")
UtilTab    = createTab("Util")
InfoTab    = createTab("Info")

-- ===================== UI COMPONENTS =====================

local function createToggle(parent, labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    btn.Text = labelText .. " · OFF"
    btn.TextColor3 = Color3.fromRGB(180, 185, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(40, 44, 55)
    stroke.Thickness = 1

    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.Text = labelText .. " · ON"
            btn.BackgroundColor3 = Color3.fromRGB(40, 30, 32)
            stroke.Color = Color3.fromRGB(180, 50, 50)
        else
            btn.Text = labelText .. " · OFF"
            btn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
            stroke.Color = Color3.fromRGB(40, 44, 55)
        end
        if callback then callback(enabled) end
    end)

    return btn, function() return enabled end
end

local function createSlider(parent, labelText, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 48)
    frame.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    frame.Parent = parent
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(40, 44, 55)
    stroke.Thickness = 1

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 16)
    label.Position = UDim2.new(0, 8, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. defaultVal
    label.TextColor3 = Color3.fromRGB(200, 205, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 5)
    track.Position = UDim2.new(0, 8, 0, 26)
    track.BackgroundColor3 = Color3.fromRGB(38, 42, 55)
    track.Parent = frame
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    fill.Parent = track
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + relX * (maxVal - minVal) + 0.5)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        label.Text = labelText .. ": " .. value
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    fill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMove then
            updateSlider(input)
        end
    end))

    return frame
end

local function createKeybind(parent, labelText, defaultKey, onKeyChanged)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    frame.Parent = parent
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(40, 44, 55)
    stroke.Thickness = 1

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, -10, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 205, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0.38, -10, 0, 24)
    keyBtn.Position = UDim2.new(0.6, 0, 0.5, -12)
    keyBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    keyBtn.Text = defaultKey.Name
    keyBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
    keyBtn.Font = Enum.Font.GothamSemibold
    keyBtn.TextSize = 11
    keyBtn.Parent = frame
    keyBtn.BorderSizePixel = 0
    keyBtn.ZIndex = 5
    keyBtn.AutoButtonColor = false
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 5)

    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        keyBtn.Text = "..."
        task.delay(5, function()
            if listening then
                listening = false
                keyBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
                keyBtn.Text = defaultKey.Name
            end
        end)
    end)

    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            listening = false
            defaultKey = input.KeyCode
            keyBtn.Text = defaultKey.Name
            keyBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
            if onKeyChanged then onKeyChanged(defaultKey) end
        end
    end))

    return frame, function() return defaultKey end
end

local function createDropdown(parent, labelText, options, defaultOption, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -12, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    frame.Parent = parent
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(40, 44, 55)
    stroke.Thickness = 1

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, -10, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 205, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == defaultOption then currentIndex = i end
    end

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.38, -10, 0, 24)
    dropBtn.Position = UDim2.new(0.6, 0, 0.5, -12)
    dropBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    dropBtn.Text = options[currentIndex]
    dropBtn.TextColor3 = Color3.fromRGB(200, 80, 80)
    dropBtn.Font = Enum.Font.GothamSemibold
    dropBtn.TextSize = 11
    dropBtn.Parent = frame
    dropBtn.BorderSizePixel = 0
    dropBtn.ZIndex = 5
    dropBtn.AutoButtonColor = false
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 5)

    dropBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        dropBtn.Text = options[currentIndex]
        if callback then callback(options[currentIndex]) end
    end)

    return frame
end

-- ===================== FEATURE STATE =====================

local Settings = {
    Aimbot      = false,
    AimbotSmooth = 5,
    AimbotFOV   = 120,
    AimbotTarget = "Head",
    WallCheck   = false,
    ShowFOV     = false,
    AutoShoot   = false,
    Triggerbot  = false,
    TriggerDelay = 50,
    Spinbot     = false,
    SpinSpeed   = 8,
    Chams       = false,
    FPSCounter  = false,
    BunnyHop    = false,
    Flash       = false,
    Smoke       = false,
    FPSBoost    = false,
}

-- ===================== POPULATE TABS =====================

-- AIMBOT TAB
createToggle(AimbotTab, "Aimbot", function(v) Settings.Aimbot = v end)
createKeybind(AimbotTab, "Keybind", AimbotKey, function(k) AimbotKey = k end)
createSlider(AimbotTab, "Smooth", 1, 20, 5, function(v) Settings.AimbotSmooth = v end)
createSlider(AimbotTab, "FOV", 10, 440, 120, function(v) Settings.AimbotFOV = v end)
createDropdown(AimbotTab, "Target", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(v) Settings.AimbotTarget = v end)
createToggle(AimbotTab, "Wall Check", function(v) Settings.WallCheck = v end)
createToggle(AimbotTab, "Show FOV", function(v) Settings.ShowFOV = v end)
createToggle(AimbotTab, "Auto Shoot", function(v) Settings.AutoShoot = v end)

-- TRIGGER TAB
createToggle(TriggerTab, "Triggerbot", function(v) Settings.Triggerbot = v end)
createKeybind(TriggerTab, "Keybind", TriggerKey, function(k) TriggerKey = k end)
createSlider(TriggerTab, "Delay", 0, 500, 50, function(v) Settings.TriggerDelay = v end)

-- SPIN TAB
createToggle(SpinTab, "Spinbot", function(v) Settings.Spinbot = v end)
createSlider(SpinTab, "Speed", 1, 20, 8, function(v) Settings.SpinSpeed = v end)

local spinInfo = Instance.new("TextLabel")
spinInfo.Size = UDim2.new(1, -12, 0, 50)
spinInfo.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
spinInfo.Text = "SPINBOT\nWalk & shoot normally"
spinInfo.TextColor3 = Color3.fromRGB(200, 100, 100)
spinInfo.Font = Enum.Font.Gotham
spinInfo.TextSize = 11
spinInfo.TextWrapped = true
spinInfo.Parent = SpinTab
spinInfo.BorderSizePixel = 0
Instance.new("UICorner", spinInfo).CornerRadius = UDim.new(0, 6)

-- VISUALS TAB
createToggle(VisualsTab, "Chams", function(v) Settings.Chams = v end)
createToggle(VisualsTab, "FPS Counter", function(v)
    Settings.FPSCounter = v
    FPSFrame.Visible = v
end)

-- MISC TAB
createToggle(MiscTab, "Bunny Hop", function(v) Settings.BunnyHop = v end)
createToggle(MiscTab, "Flash", function(v) Settings.Flash = v end)
createToggle(MiscTab, "Smoke", function(v) Settings.Smoke = v end)

-- UTIL TAB
createToggle(UtilTab, "FPS Boost", function(v)
    if v then
        task.spawn(function()
            for _, obj in ipairs(game:GetDescendants()) do
                pcall(function()
                    if obj:IsA("BasePart") then
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Color = Color3.fromRGB(140, 140, 140)
                    end
                end)
            end
            game:GetService("Lighting").GlobalShadows = false
        end)
    end
end)

-- INFO TAB
local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, -12, 0, 140)
infoFrame.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
infoFrame.Parent = InfoTab
infoFrame.BorderSizePixel = 0
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 8)

local infoTitle = Instance.new("TextLabel")
infoTitle.Size = UDim2.new(1, 0, 0, 30)
infoTitle.Position = UDim2.new(0, 0, 0, 10)
infoTitle.BackgroundTransparency = 1
infoTitle.Text = "Impa Client"
infoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
infoTitle.Font = Enum.Font.GothamBold
infoTitle.TextSize = 16
infoTitle.Parent = infoFrame

local infoAuthor = Instance.new("TextLabel")
infoAuthor.Size = UDim2.new(1, 0, 0, 25)
infoAuthor.Position = UDim2.new(0, 0, 0, 40)
infoAuthor.BackgroundTransparency = 1
infoAuthor.Text = "Made by Impadin.no"
infoAuthor.TextColor3 = Color3.fromRGB(200, 80, 80)
infoAuthor.Font = Enum.Font.GothamSemibold
infoAuthor.TextSize = 13
infoAuthor.Parent = infoFrame

local infoDiscord = Instance.new("TextLabel")
infoDiscord.Size = UDim2.new(1, 0, 0, 25)
infoDiscord.Position = UDim2.new(0, 0, 0, 65)
infoDiscord.BackgroundTransparency = 1
infoDiscord.Text = "Discord: impadinno1q"
infoDiscord.TextColor3 = Color3.fromRGB(180, 185, 200)
infoDiscord.Font = Enum.Font.Gotham
infoDiscord.TextSize = 11
infoDiscord.Parent = infoFrame

-- ===================== DRAG HEADER =====================

local draggingWindow, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWindow = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end))
table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWindow = false
    end
end))

-- ===================== BHOP LABEL =====================

local BhopLabel = Instance.new("TextLabel")
BhopLabel.Size = UDim2.new(0, 70, 0, 24)
BhopLabel.Position = UDim2.new(0, 10, 0, 10)
BhopLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BhopLabel.BackgroundTransparency = 0.3
BhopLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
BhopLabel.Text = "BHOP: OFF"
BhopLabel.Font = Enum.Font.GothamBold
BhopLabel.TextSize = 12
BhopLabel.Parent = ScreenGui
BhopLabel.ZIndex = 10
Instance.new("UICorner", BhopLabel).CornerRadius = UDim.new(0, 5)

-- ===================== FPS COUNTER =====================

FPSFrame = Instance.new("Frame")
FPSFrame.Size = UDim2.new(0, 65, 0, 24)
FPSFrame.Position = UDim2.new(1, -75, 0, 45)
FPSFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FPSFrame.BackgroundTransparency = 0.3
FPSFrame.BorderSizePixel = 0
FPSFrame.Active = true
FPSFrame.Draggable = true
FPSFrame.Visible = false
FPSFrame.Parent = ScreenGui
Instance.new("UICorner", FPSFrame).CornerRadius = UDim.new(0, 5)

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(1, 0, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: 0"
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = 12
FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
FPSLabel.Parent = FPSFrame

-- ===================== FOV CIRCLE =====================

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.6
FOVCircle.Color = Color3.fromRGB(180, 50, 50)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.NumSides = 60
FOVCircle.Visible = false

-- ===================== PLAYER DRAWINGS =====================

local function createPlayerDrawing(player)
    local label = Drawing.new("Text")
    label.Text = player.Name
    label.Color = Color3.fromRGB(255, 255, 255)
    label.Size = 12
    label.Center = true
    label.Outline = true
    label.OutlineColor = Color3.fromRGB(0, 0, 0)
    label.Font = 2
    label.Visible = false
    PlayerDrawings[player] = label
end

local function removePlayerDrawing(player)
    if PlayerDrawings[player] then
        PlayerDrawings[player]:Remove()
        PlayerDrawings[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        pcall(createPlayerDrawing, player)
    end
end

table.insert(Connections, Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        pcall(createPlayerDrawing, player)
    end
end))

table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
    removePlayerDrawing(player)
end))

-- ===================== CHAMS =====================

local function applyChams(enable)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local myChar = LocalPlayer.Character
            if myChar and myChar.Parent.Name == player.Character.Parent.Name then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if enable then
                            part.Material = Enum.Material.Neon
                            part.Color = Color3.fromRGB(255, 0, 0)
                        else
                            part.Material = Enum.Material.SmoothPlastic
                        end
                    end
                end
            end
        end
    end
end

-- ===================== MAIN LOOP =====================

local lastFPSTick = tick()
local frameCount = 0
local ViewportSize = CurrentCamera.ViewportSize
local ViewportCenter = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)

table.insert(Connections, RunService.RenderStepped:Connect(function()
    -- Update viewport center
    ViewportSize = CurrentCamera.ViewportSize
    ViewportCenter = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)

    -- FPS counter
    frameCount = frameCount + 1
    if Settings.FPSCounter then
        local now = tick()
        if now - lastFPSTick >= 0.5 then
            FPSLabel.Text = "FPS: " .. math.floor(frameCount / (now - lastFPSTick))
            frameCount = 0
            lastFPSTick = now
        end
    end

    -- FOV circle
    FOVCircle.Position = ViewportCenter
    FOVCircle.Radius = Settings.AimbotFOV / 2
    FOVCircle.Visible = Settings.ShowFOV

    -- Aimbot
    if Settings.Aimbot and UserInputService:IsKeyDown(AimbotKey) then
        local bestTarget, bestDist = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = char:FindFirstChild(Settings.AimbotTarget) or char:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        -- Wall check
                        local visible = true
                        if Settings.WallCheck then
                            local origin = CurrentCamera.CFrame.Position
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Blacklist
                            params.FilterDescendantsInstances = {LocalPlayer.Character}
                            local ray = workspace:Raycast(origin, (targetPart.Position - origin).Unit * 1000, params)
                            visible = ray and ray.Instance and ray.Instance:IsDescendantOf(char)
                        end

                        if visible then
                            local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - ViewportCenter).Magnitude
                                if dist < Settings.AimbotFOV / 2 and dist < bestDist then
                                    bestDist = dist
                                    bestTarget = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end

        if bestTarget then
            local targetScreen = CurrentCamera:WorldToViewportPoint(bestTarget.Position)
            local smooth = Settings.AimbotSmooth
            local currentX = ViewportCenter.X
            local currentY = ViewportCenter.Y
            local moveX = (targetScreen.X - currentX) / smooth
            local moveY = (targetScreen.Y - currentY) / smooth
            mousemoverel(moveX, moveY)

            if Settings.AutoShoot and Mouse1click then
                Mouse1click()
            end
        end
    end

    -- Triggerbot
    if Settings.Triggerbot and UserInputService:IsKeyDown(TriggerKey) then
        pcall(function()
            local ray = CurrentCamera:ViewportPointToRay(ViewportCenter.X, ViewportCenter.Y)
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)
            if result and result.Instance then
                local model = result.Instance:FindFirstAncestorOfClass("Model")
                if model then
                    local targetPlayer = Players:GetPlayerFromCharacter(model)
                    if targetPlayer and targetPlayer ~= LocalPlayer then
                        local myChar = LocalPlayer.Character
                        if myChar and myChar.Parent.Name == targetPlayer.Character.Parent.Name then
                            task.delay(Settings.TriggerDelay / 1000, function()
                                if Mouse1click then Mouse1click() end
                            end)
                        end
                    end
                end
            end
        end)
    end

    -- Chams (apply once on toggle, not every frame — handled in toggle callback)
end))

-- Spinbot
local spinConnection
local function updateSpinbot(enabled)
    if spinConnection then
        spinConnection:Disconnect()
        spinConnection = nil
    end
    if enabled then
        spinConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
                end
            end
        end)
    end
end

-- Patch Spinbot toggle (hook into existing toggle)
-- We already created the toggle above; patch it by wrapping callback
for _, child in ipairs(SpinTab:GetChildren()) do
    if child:IsA("TextButton") and child.Text:find("Spinbot") then
        child.MouseButton1Click:Connect(function()
            updateSpinbot(Settings.Spinbot)
            BhopLabel.Text = "BHOP: " .. (Settings.BunnyHop and "ON" or "OFF")
        end)
    end
end

-- Bunny Hop
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if Settings.BunnyHop then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp and hrp.Velocity.Y < 1 then
                humanoid.Jump = UserInputService:IsKeyDown(Enum.KeyCode.Space)
            end
        end
    end
    BhopLabel.Text = "BHOP: " .. (Settings.BunnyHop and "ON" or "OFF")
end))

-- Chams toggle (apply on change)
local chamToggle = createToggle(VisualsTab, "Chams", function(v)
    Settings.Chams = v
    applyChams(v)
end)

-- Flash/Smoke remover loop
task.spawn(function()
    while task.wait(0.5) do
        if Settings.Flash then
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            if gui then
                local flash = gui:FindFirstChild("FlashbangEffect")
                if flash then flash:Destroy() end
            end
        end
        if Settings.Smoke then
            local debris = workspace:FindFirstChild("Debris")
            if debris then
                for _, obj in ipairs(debris:GetChildren()) do
                    if obj.Name:match("Smoke") then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end)

-- ===================== CLEANUP ON GUI REMOVED =====================

CoreGui.ChildRemoved:Connect(function(child)
    if child == ScreenGui then
        for _, conn in ipairs(Connections) do
            conn:Disconnect()
        end
        if spinConnection then spinConnection:Disconnect() end
        FOVCircle:Remove()
        for _, drawing in pairs(PlayerDrawings) do
            drawing:Remove()
        end
    end
end)

-- Open Aimbot tab by default
AllTabButtons[1]:FindFirstChild("Accent").Visible = true
AllTabFrames[1].Visible = true
AllTabButtons[1].BackgroundColor3 = Color3.fromRGB(32, 28, 30)
AllTabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
