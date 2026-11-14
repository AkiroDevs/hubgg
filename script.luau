-- ⚔️ KRONOS HUB (Delta Mobile Fixed) ⚔️
-- Cole diretamente no Delta Executor móvel

-- ========== 1. Esperar o jogo carregar (essencial para Delta) ==========
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ========== 2. Seleção segura do parent da GUI (compatível com Delta móvel) ==========
local guiParent
do
    local ok, result = pcall(function() return gethui() end)
    if ok and result then
        guiParent = result
    else
        local ok2, result2 = pcall(function()
            return game:GetService("CoreGui")
        end)
        if ok2 and result2 then
            guiParent = result2
        else
            guiParent = player:WaitForChild("PlayerGui", 10) or player.PlayerGui
        end
    end
end

-- Limpar GUI antiga
for _, child in ipairs(guiParent:GetChildren()) do
    if child.Name == "KronosHub" then child:Destroy() end
end
pcall(function()
    for _, child in ipairs(player.PlayerGui:GetChildren()) do
        if child.Name == "KronosHub" then child:Destroy() end
    end
end)

-- ========== 3. GUI principal ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KronosHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 260)
Main.Position = UDim2.new(0.5, -160, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(140, 80, 255)
MainStroke.Thickness = 2
MainStroke.Parent = Main

-- Barra de título
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarCover = Instance.new("Frame")
TopBarCover.Size = UDim2.new(1, 0, 0, 10)
TopBarCover.Position = UDim2.new(0, 0, 1, -10)
TopBarCover.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
TopBarCover.BorderSizePixel = 0
TopBarCover.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚔️ KRONOS HUB"
Title.TextColor3 = Color3.fromRGB(220, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinimizeBtn.Text = "–"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- Container de conteúdo
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = Main

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = Content

-- ========== 4. Lógica funcional ==========
local godMode, noclip = false, false
local connections = {}

local function setGodMode(ativo)
    godMode = ativo
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if ativo then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        local conn = hum.HealthChanged:Connect(function()
            if godMode then hum.Health = hum.MaxHealth end
        end)
        table.insert(connections, conn)
    else
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

local function setNoclip(ativo)
    noclip = ativo
    if ativo then
        local conn = RunService.Stepped:Connect(function()
            if not noclip then return end
            local char = player.Character
            if char then
                for _, parte in ipairs(char:GetDescendants()) do
                    if parte:IsA("BasePart") then
                        parte.CanCollide = false
                    end
                end
            end
        end)
        table.insert(connections, conn)
    end
end

local function criarToggle(nome, ordem, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.Text = "  " .. nome .. "  [ OFF ]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.LayoutOrder = ordem
    btn.Parent = Content

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(70, 70, 90)
    s.Thickness = 1
    s.Parent = btn

    local estado = false
    btn.MouseButton1Click:Connect(function()
        estado = not estado
        if estado then
            btn.BackgroundColor3 = Color3.fromRGB(90, 60, 180)
            s.Color = Color3.fromRGB(140, 80, 255)
            btn.Text = "  " .. nome .. "  [ ON ]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            s.Color = Color3.fromRGB(70, 70, 90)
            btn.Text = "  " .. nome .. "  [ OFF ]"
        end
        callback(estado)
    end)
    return btn
end

criarToggle("🛡️ God Mode", 1, setGodMode)
criarToggle("👻 Noclip", 2, setNoclip)

-- Reiniciar estado ao respawnar
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if godMode then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
    end
end)

-- ========== 5. Arrastar (compatível com toque) ==========
local dragging = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ========== 6. Minimizar / Fechar ==========
local minimizado = false
local tamanhoOriginal = Main.Size

MinimizeBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        TweenService:Create(Main, TweenInfo.new(0.25), { Size = UDim2.new(0, 320, 0, 40) }):Play()
        Content.Visible = false
        MinimizeBtn.Text = "+"
    else
        TweenService:Create(Main, TweenInfo.new(0.25), { Size = tamanhoOriginal }):Play()
        Content.Visible = true
        MinimizeBtn.Text = "–"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    noclip = false
    godMode = false
    ScreenGui:Destroy()
end)

print("⚔️ Kronos Hub (Delta Fixed) carregado!")
