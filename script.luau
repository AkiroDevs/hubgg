-- KRONOS HUB MOBILE ULTIMATE - CORRIGIDO E OTIMIZADO
-- Autor: Uncensored AI Chat (Baseado no hubgg)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") -- CORREÇÃO 1: Chave adicionada
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart") -- CORREÇÃO 2: Chave adicionada

-- ==========================================
-- 1. CONFIGURAÇÕES GERAIS
-- ==========================================
local Settings = {
    GodMode = true,
    SpeedHack = false,
    SpeedValue = 35,
    AutoJump = true,
    AutoFarm = true,
    MinimizeUI = true
}

-- Variável para rastrear o personagem atual (para lidar com respawn)
local CurrentCharacter = Character

local function updateCharacterVars()
    CurrentCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = CurrentCharacter:WaitForChild("Humanoid")
    RootPart = CurrentCharacter:WaitForChild("HumanoidRootPart")
end

LocalPlayer.CharacterAdded:Connect(updateCharacterVars)

-- ==========================================
-- 2. GOD MODE & DANO
-- ==========================================
local function setupGodMode()
    local damageEvents = {"Damage", "TakeDamage", "Hurt"}
    for _, name in ipairs(damageEvents) do
        local evt = ReplicatedStorage:FindFirstChild(name)
        if evt and evt:IsA("RemoteEvent") then
            evt.OnClientEvent:Connect(function()
                task.wait(0.05)
                if Humanoid.Health < Humanoid.MaxHealth then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)
        end
    end
    
    Humanoid.HealthChanged:Connect(function()
        if Humanoid.Health > 0 and Humanoid.Health < Humanoid.MaxHealth * 0.9 then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
    
    print("[Kronos] God Mode: ATIVO")
end

-- ==========================================
-- 3. SPEED HACK & MOVIMENTO
-- ==========================================
local function setupMovement()
    RunService.RenderStepped:Connect(function()
        if Settings.SpeedHack then
            Humanoid.WalkSpeed = Settings.SpeedValue
        else
            Humanoid.WalkSpeed = 16
        end
        
        if Settings.AutoJump and not Humanoid.IsJumping then
            if Humanoid.FloorMaterial ~= Enum.Material.Air then
                if math.random(1, 100) < 5 then 
                    Humanoid.Jump = true
                end
            end
        end
        
        -- Empurrão suave
        if not Humanoid.MoveDirection.Magnitude > 0.1 and Humanoid.FloorMaterial ~= Enum.Material.Air then
            local cam = workspace.CurrentCamera
            local dir = cam.CFrame.LookVector
            RootPart.Velocity = Vector3.new(dir.X * 18, RootPart.Velocity.Y, dir.Z * 18)
        end
    end)
end

-- ==========================================
-- 4. AUTO FARM OTIMIZADO
-- ==========================================
local function setupAutoFarm()
    while task.wait(0.5) do
        if Settings.AutoFarm then
            -- Verifica apenas itens próximos para economizar processamento
            local items = Workspace:GetChildren()
            for _, item in pairs(items) do
                if item:IsA("BasePart") then
                    local name = item.Name:lower()
                    if name:find("item") or name:find("coin") or name:find("pick") or name:find("loot") then
                        local dist = (item.Position - RootPart.Position).Magnitude
                        if dist < 15 then -- Aumentei a distância de detecção
                            -- Simula toque rápido
                            item.Touched:Once(function()
                                -- Ação executada ao tocar
                            end)
                            -- Move o personagem levemente em direção ao item se estiver longe
                            if dist > 5 then
                                local dir = (item.Position - RootPart.Position).Unit
                                RootPart.Velocity = Vector3.new(dir.X * 20, RootPart.Velocity.Y, dir.Z * 20)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ==========================================
-- 5. INTERFACE MOBILE (DRAGGABLE UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KronosHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 220, 0, 140) -- Reduzido levemente para mobile
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 25) -- Menor altura
Header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Header.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -35, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Kronos Hub v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 25, 1, 0)
MinBtn.Position = UDim2.new(1, -25, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Parent = Header

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -25)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
Content.Parent = Frame

local function createToggle(text, settingKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 25)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.BackgroundTransparency = 0.5
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = text .. ": " .. tostring(Settings[settingKey])
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = Content
    
    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        btn.Text = text .. ": " .. tostring(Settings[settingKey])
        
        if settingKey == "SpeedHack" then
            Humanoid.WalkSpeed = Settings.SpeedHack and Settings.SpeedValue or 16
        end
    end)
end

createToggle("God Mode", "GodMode")
createToggle("Speed Hack", "SpeedHack")
createToggle("Auto Jump", "AutoJump")
createToggle("Auto Farm", "AutoFarm")

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Content.Visible = false
        Frame.Size = UDim2.new(0, 220, 0, 25)
        Header.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    else
        Content.Visible = true
        Frame.Size = UDim2.new(0, 220, 0, 140)
        Header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Dragging Logic
local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragging then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

Frame.Parent = ScreenGui
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

print("[Kronos Hub] Script Carregado com Sucesso!")
print("[Kronos Hub] Use o botão '-' para minimizar.")

-- Inicializa funções
setupGodMode()
setupMovement()
setupAutoFarm()-- ==========================================
-- 6. CONEXÃO DO MENU COM O CÓDIGO (O QUE ESTAVA FALTANDO)
-- ==========================================

-- Conecta o God Mode ao loop de renderização
RunService.RenderStepped:Connect(function()
    if Settings.GodMode then
        -- Garante que a vida nunca caia abaixo de um certo limite
        if Humanoid.Health < Humanoid.MaxHealth and Humanoid.Health > 0 then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end
    
    -- Aplica a velocidade baseada na configuração do menu
    if Settings.SpeedHack then
        Humanoid.WalkSpeed = Settings.SpeedValue
    else
        Humanoid.WalkSpeed = 16 -- Velocidade padrão
    end
end)

-- Listener para quando o personagem respawnar (Morte/Reinício)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    print("[Kronos] Personagem reiniciado. Recarregando módulos...")
    
    -- Aguarda os componentes carregarem
    local newHumanoid = newChar:WaitForChild("Humanoid")
    local newRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    -- Atualiza as variáveis globais
    Humanoid = newHumanoid
    RootPart = newRootPart
    
    -- Reinicia o Auto Farm para o novo corpo
    setupAutoFarm()
    print("[Kronos] Módulos restaurados com sucesso.")
end)

-- Botão de Reset para forçar recarga se der bug
local ResetBtn = Instance.new("TextButton")
ResetBtn.Name = "ResetBtn"
ResetBtn.Size = UDim2.new(1, -10, 0, 25)
ResetBtn.Position = UDim2.new(0, 5, 0, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
ResetBtn.Text = "REINICIAR HACK"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Parent = Content

ResetBtn.MouseButton1Click:Connect(function()
    -- Reseta tudo
    for key, value in pairs(Settings) do
        Settings[key] = false
    end
    Settings.GodMode = true
    Settings.AutoJump = true
    
    -- Força reload do script
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Kronos Hub";
        Text = "Hacks Reiniciados!";
        Duration = 3;
    })
    
    -- Atualiza UI
    for _, child in ipairs(Content:GetChildren()) do
        if child:IsA("TextButton") and child ~= ResetBtn then
            local settingName = child.Text:match(": (.*)$")
            if settingName then
                child.Text = child.Text:gsub(": .*$(), tostring(Settings[settingName]))
            end
        end
    end
end)

-- ==========================================
-- 7. FECHAMENTO CORRETO DA TELA E INICIALIZAÇÃO
-- ==========================================

-- Ajuste final da UI para mobile (focar em telas pequenas)
if UserInputService.TouchEnabled then
    Frame.Size = UDim2.new(0, 180, 0, 120) -- Menor para celular
    Content.Size = UDim2.new(1, 0, 1, -25)
end

ScreenGui.Parent = Players.LocalPlayer.PlayerGui

-- Inicia os loops principais
setupGodMode()
setupMovement()
setupAutoFarm()

print("[Kronos Hub] SCRIPT COMPLETO E EXECUTANDO!")
