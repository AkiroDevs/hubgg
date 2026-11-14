--[[
    ⚔️ KRONOS HUB - MOBILE ESP EDITION + INTRO ANIMATION ⚔️
    Local: StarterPlayer > StarterPlayerScripts (LocalScript)
    Ou execute via executor mobile (Delta, Fluxus, Codex, Hydrogen, Arceus X, etc.)
]]

--=============================================================
-- SERVIÇOS
--=============================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local DRAWING_OK = pcall(function() return Drawing.new("Text") end)
if not DRAWING_OK then
    warn("⚠️ Kronos Hub: seu executor NÃO suporta Drawing. O ESP não vai funcionar.")
end

if CoreGui:FindFirstChild("KronosHub") then
    CoreGui.KronosHub:Destroy()
end

--=============================================================
-- ESTADO
--=============================================================
local godMode, noclip, flyEnabled, infiniteJumpEnabled, speedHackEnabled, clickTPEnabled = false, false, false, false, false, false
local connections = {}
local flyConnection, flySpeed, speedValue = nil, 50, 16

--=============================================================
-- GUI PRINCIPAL
--=============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KronosHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 380)
Main.Position = UDim2.new(0.5, -160, 0.5, -190)
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

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 80, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 180, 255)),
})
MainGradient.Rotation = 45
MainGradient.Parent = MainStroke

--=============================================================
-- TOPBAR
--=============================================================
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
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

--=============================================================
-- CONTENT
--=============================================================
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 48)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(140, 80, 255)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = Content

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
end)

--=============================================================
-- TOGGLE
--=============================================================
local function criarToggle(nome, ordem, callback)
    local btn = Instance.new("TextButton")
    btn.Name = nome
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.Text = "  " .. nome .. "  [ OFF ]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.LayoutOrder = ordem
    btn.Parent = Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 90)
    stroke.Thickness = 1
    stroke.Parent = btn

    local estado = false
    btn.MouseButton1Click:Connect(function()
        estado = not estado
        if estado then
            btn.BackgroundColor3 = Color3.fromRGB(90, 60, 180)
            stroke.Color = Color3.fromRGB(140, 80, 255)
            btn.Text = "  " .. nome .. "  [ ON ]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            stroke.Color = Color3.fromRGB(70, 70, 90)
            btn.Text = "  " .. nome .. "  [ OFF ]"
        end
        callback(estado)
    end)
    return btn
end

--=============================================================
-- GOD MODE / NOCLIP
--=============================================================
local function setGodMode(ativo)
    godMode = ativo
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if ativo then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        table.insert(connections, hum.HealthChanged:Connect(function()
            if godMode then hum.Health = hum.MaxHealth end
        end))
    else
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

local function setNoclip(ativo)
    noclip = ativo
    if ativo then
        table.insert(connections, RunService.Stepped:Connect(function()
            if not noclip then return end
            local char = player.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end))
    end
end

--=============================================================
-- FLY
--=============================================================
local function toggleFly(ativo)
    flyEnabled = ativo
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if flyEnabled then
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = hrp
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.P = 1000
        bg.D = 50
        bg.Parent = hrp
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
            bg.CFrame = camera.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        for _, v in ipairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
    end
end

--=============================================================
-- INFINITE JUMP / SPEED / CLICK TP
--=============================================================
local function toggleInfiniteJump(ativo)
    infiniteJumpEnabled = ativo
    if ativo then
        table.insert(connections, UserInputService.JumpRequest:Connect(function()
            if not infiniteJumpEnabled then return end
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end))
    end
end

local function toggleSpeedHack(ativo)
    speedHackEnabled = ativo
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if ativo then
        hum.WalkSpeed = speedValue
        table.insert(connections, RunService.Stepped:Connect(function()
            if speedHackEnabled and hum.Parent then hum.WalkSpeed = speedValue end
        end))
    else
        hum.WalkSpeed = 16
    end
end

local function toggleClickTP(ativo)
    clickTPEnabled = ativo
    if ativo then
        table.insert(connections, UserInputService.TouchTapInWorld:Connect(function(pos, processed)
            if processed or not clickTPEnabled then return end
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
        end))
    end
end

--=============================================================
-- ESP MOBILE
--=============================================================
local ESP = { enabled = false, drawings = {}, connections = {}, updateConn = nil }

local function newDraw(class, props)
    if not DRAWING_OK then return nil end
    local ok, obj = pcall(function() return Drawing.new(class) end)
    if not ok or not obj then return nil end
    for k, v in pairs(props) do pcall(function() obj[k] = v end) end
    obj.Visible = false
    return obj
end

local function setupESP(plr)
    if plr == player or ESP.drawings[plr] or not DRAWING_OK then return end
    local d = {}
    d.name = newDraw("Text", {Center = true, Size = 16, Color = Color3.new(1,1,1), Outline = true, OutlineColor = Color3.new(0,0,0), Font = 2})
    d.team = newDraw("Text", {Center = true, Size = 13, Color = Color3.fromRGB(200, 200, 255), Outline = true, OutlineColor = Color3.new(0,0,0), Font = 2})
    d.healthBg = newDraw("Square", {Color = Color3.new(0,0,0), Filled = true, Thickness = 0})
    d.healthBar = newDraw("Square", {Color = Color3.fromRGB(0,255,0), Filled = true, Thickness = 0})
    d.healthText = newDraw("Text", {Center = true, Size = 11, Color = Color3.new(1,1,1), Outline = true, OutlineColor = Color3.new(0,0,0), Font = 2})
    d.distance = newDraw("Text", {Center = true, Size = 12, Color = Color3.fromRGB(255, 200, 100), Outline = true, OutlineColor = Color3.new(0,0,0), Font = 2})
    ESP.drawings[plr] = d
end

local function removeESP(plr)
    if ESP.drawings[plr] then
        for _, obj in pairs(ESP.drawings[plr]) do
            if obj then pcall(function() obj:Remove() end) end
        end
        ESP.drawings[plr] = nil
    end
end

local function hideDrawings(d)
    for _, obj in pairs(d) do
        if obj then pcall(function() obj.Visible = false end) end
    end
end

local function updateESP()
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position
    if not myPos then return end

    for plr, d in pairs(ESP.drawings) do
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp or hum.Health <= 0 then hideDrawings(d) continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
        if not onScreen then hideDrawings(d) continue end

        if d.name then
            local nameText = plr.DisplayName
            if plr.DisplayName ~= plr.Name then nameText = plr.DisplayName .. " (@" .. plr.Name .. ")" end
            d.name.Text = nameText
            d.name.Position = Vector2.new(screenPos.X, screenPos.Y - 55)
            d.name.Visible = true
        end
        if d.team then
            if plr.Team then
                d.team.Text = "[" .. plr.Team.Name .. "]"
                d.team.Color = plr.Team.TeamColor.Color
                d.team.Position = Vector2.new(screenPos.X, screenPos.Y - 38)
                d.team.Visible = true
            else
                d.team.Visible = false
            end
        end

        local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        local barW, barH = 80, 7
        local barX = screenPos.X - barW / 2
        local barY = screenPos.Y - 22
        if d.healthBg then
            d.healthBg.Size = Vector2.new(barW, barH)
            d.healthBg.Position = Vector2.new(barX, barY)
            d.healthBg.Visible = true
        end
        if d.healthBar then
            d.healthBar.Size = Vector2.new(barW * hp, barH)
            d.healthBar.Position = Vector2.new(barX, barY)
            d.healthBar.Color = Color3.fromRGB(math.floor(255*(1-hp)), math.floor(255*hp), 0)
            d.healthBar.Visible = true
        end
        if d.healthText then
            d.healthText.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
            d.healthText.Position = Vector2.new(screenPos.X, barY + barH + 8)
            d.healthText.Visible = true
        end
        if d.distance then
            local dist = (hrp.Position - myPos).Magnitude
            d.distance.Text = "📏 " .. math.floor(dist) .. " studs"
            d.distance.Position = Vector2.new(screenPos.X, barY + barH + 22)
            d.distance.Visible = true
        end
    end
end

local function toggleESP(ativo)
    ESP.enabled = ativo
    if ativo then
        if not DRAWING_OK then warn("⚠️ ESP: Drawing não suportado.") return end
        for _, p in ipairs(Players:GetPlayers()) do setupESP(p) end
        table.insert(ESP.connections, Players.PlayerAdded:Connect(setupESP))
        table.insert(ESP.connections, Players.PlayerRemoving:Connect(removeESP))
        ESP.updateConn = RunService.RenderStepped:Connect(updateESP)
    else
        if ESP.updateConn then ESP.updateConn:Disconnect() end
        for _, c in ipairs(ESP.connections) do c:Disconnect() end
        ESP.connections = {}
        for plr in pairs(ESP.drawings) do removeESP(plr) end
    end
end

--=============================================================
-- BOTÕES
--=============================================================
criarToggle("🛡️ God Mode", 1, setGodMode)
criarToggle("👻 Noclip", 2, setNoclip)
criarToggle("✈️ Fly (Voar)", 3, toggleFly)
criarToggle("🦘 Pulo Infinito", 4, toggleInfiniteJump)
criarToggle("⚡ Speed Hack", 5, toggleSpeedHack)
criarToggle("🖱️ Click TP (toque)", 6, toggleClickTP)
criarToggle("📱 ESP Mobile (Info)", 7, toggleESP)

--=============================================================
-- RESPAWN
--=============================================================
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if godMode then hum.MaxHealth = math.huge hum.Health = math.huge end
    if speedHackEnabled then hum.WalkSpeed = speedValue end
end)

--=============================================================
-- DRAG
--=============================================================
local dragging, dragStart, startPos = false, nil, nil
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--=============================================================
-- MINIMIZAR
--=============================================================
local minimizado, tamanhoOriginal = false, Main.Size
MinimizeBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 320, 0, 40)}):Play()
        Content.Visible = false
        MinimizeBtn.Text = "+"
    else
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = tamanhoOriginal}):Play()
        Content.Visible = true
        MinimizeBtn.Text = "–"
    end
end)

--=============================================================
-- FECHAR
--=============================================================
CloseBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    if ESP.enabled then toggleESP(false) end
    godMode, noclip, flyEnabled, infiniteJumpEnabled, speedHackEnabled, clickTPEnabled = false, false, false, false, false, false
    ScreenGui:Destroy()
end)

--=============================================================
-- 🎬 ANIMAÇÃO DE INÍCIO (INTRO ANIMATION)
--=============================================================
local function playIntro()
    -- Pop-in com UIScale (efeito "Back" = cresce passando do tamanho e volta)
    local mainScale = Instance.new("UIScale")
    mainScale.Name = "MainScale"
    mainScale.Scale = 0.55
    mainScale.Parent = Main

    -- Configura estado inicial
    MainStroke.Thickness = 8
    MainStroke.Transparency = 1
    Title.Text = ""

    -- Prepara botões para cascata
    local buttons = {}
    for _, child in ipairs(Content:GetChildren()) do
        if child:IsA("TextButton") then
            local bs = Instance.new("UIScale")
            bs.Name = "IntroScale"
            bs.Scale = 0
            bs.Parent = child
            table.insert(buttons, child)
        end
    end

    -- 1. FLASH INICIAL (branco/roxo piscando)
    local Flash = Instance.new("Frame")
    Flash.Size = UDim2.new(1, 0, 1, 0)
    Flash.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
    Flash.BackgroundTransparency = 0.6
    Flash.BorderSizePixel = 0
    Flash.ZIndex = 999
    Flash.Active = false
    Flash.Parent = ScreenGui
    TweenService:Create(Flash, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.7, function() Flash:Destroy() end)

    -- 2. POP-IN do menu (cresce com overshoot)
    TweenService:Create(mainScale, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1
    }):Play()

    -- 3. PULSE da borda (glow)
    task.delay(0.15, function()
        TweenService:Create(MainStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
            Thickness = 2,
            Transparency = 0
        }):Play()
    end)

    -- 4. GIRO do gradiente (brilho passando pela borda)
    task.spawn(function()
        local t = TweenService:Create(MainGradient, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
            Rotation = 45 + 360
        })
        t:Play()
    end)

    -- 5. TYPEWRITER no título
    task.delay(0.45, function()
        local fullText = "⚔️ KRONOS HUB"
        local len = utf8.len(fullText) or #fullText
        for i = 1, len do
            local pos = utf8.offset(fullText, i + 1) or (#fullText + 1)
            Title.Text = string.sub(fullText, 1, pos - 1)
            task.wait(0.03)
        end
    end)

    -- 6. CASCATA dos botões (um por um com pop)
    for i, btn in ipairs(buttons) do
        local bs = btn:FindFirstChild("IntroScale")
        if bs then
            task.delay(0.35 + (i - 1) * 0.06, function()
                TweenService:Create(bs, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Scale = 1
                }):Play()
            end)
        end
    end
end

-- Inicia a animação
playIntro()

--=============================================================
-- FIM DO SCRIPT
--=============================================================
print("⚔️ Kronos Hub Mobile Edition carregado com sucesso!")
print("📱 ESP: Nome, Time, Vida, Distância")
print("🎬 Animação de início executada")
