local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local screenGui = Instance.new("ScreenGui")
local mouse = player:GetMouse() 
local character = player.Character or player.CharacterAdded:Wait()
local UserInputService = game:GetService("UserInputService")
local statustelep = false  
local isFPressed = false 
local initialPosition = character.HumanoidRootPart.Position 
local teleportConnection = nil  
local inputBeganConnection = nil  
local humanoid = character:WaitForChild("Humanoid")
local isSpeedOn = false
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local speed = 1
local noclipSpeed = 10
function startFlying(vflySpeed)
    if isFlying then return end
    isFlying = true
    speed2 = vflySpeed or 50
    local T = character:WaitForChild("HumanoidRootPart")
    local BG = Instance.new('BodyGyro')
    local BV = Instance.new('BodyVelocity')
    BG.P = 9e4
    BG.Parent = T
    BV.Parent = T
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.cframe = T.CFrame
    BV.velocity = Vector3.new(0, 0, 0)
    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
    task.spawn(function()
        repeat
            wait()
            if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + 
                    ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - 
                    workspace.CurrentCamera.CoordinateFrame.p)) * speed2
            else
                BV.velocity = Vector3.new(0, 0, 0)
            end
            BG.cframe = workspace.CurrentCamera.CoordinateFrame
        until not isFlying
        BG:Destroy()
        BV:Destroy()
    end)
end
function stopFlying()
    isFlying = false
    humanoid.PlatformStand = false
end
function enableNoClip()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end
function disableNoClip()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        CONTROL.F = noclipSpeed
    elseif input.KeyCode == Enum.KeyCode.S then
        CONTROL.B = -noclipSpeed
    elseif input.KeyCode == Enum.KeyCode.A then
        CONTROL.L = -noclipSpeed
    elseif input.KeyCode == Enum.KeyCode.D then
        CONTROL.R = noclipSpeed
    elseif input.KeyCode == Enum.KeyCode.Q then
        CONTROL.Q = noclipSpeed * 2 
    elseif input.KeyCode == Enum.KeyCode.E then
        CONTROL.E = -noclipSpeed * 2 
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        CONTROL.F = 0
    elseif input.KeyCode == Enum.KeyCode.S then
        CONTROL.B = 0
    elseif input.KeyCode == Enum.KeyCode.A then
        CONTROL.L = 0
    elseif input.KeyCode == Enum.KeyCode.D then
        CONTROL.R = 0
    elseif input.KeyCode == Enum.KeyCode.Q then
        CONTROL.Q = 0
    elseif input.KeyCode == Enum.KeyCode.E then
        CONTROL.E = 0
    end
end)
local function disableAnimations()
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        animator:Destroy()
    end
    humanoid:LoadAnimation(Instance.new("Animation"))
    humanoid.WalkSpeed = 0
    humanoid.JumpHeight = 0
    humanoid.AutoRotate = false
end
local function instantSpeedBoost()
    humanoid.WalkSpeed = 7500 
    humanoid.JumpPower = 7900 
    wait(0.1)  
    humanoid.WalkSpeed = 60   
    humanoid.JumpPower = 200   
end
local function applyBodyVelocity()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000) 
    bodyVelocity.Velocity = rootPart.CFrame.LookVector * 200 
    bodyVelocity.Parent = rootPart
    wait(0.1)
    bodyVelocity:Destroy()
end
local function teleportToMouseClick()
    local clickPosition = mouse.Hit.p 
    if (clickPosition - character.HumanoidRootPart.Position).magnitude < 12500 then
        character:SetPrimaryPartCFrame(CFrame.new(clickPosition))
    else
        warn("Слишком далеко для телепортации")
		info = "Слишком далеко для телепортации"
		infoMessage(info)
    end
end
local function teleportBackToInitialPosition()
    character:SetPrimaryPartCFrame(CFrame.new(initialPosition))
end
local function teleportyes(statustelep)
    if statustelep then
        teleportConnection = mouse.Button2Down:Connect(function()
            if isFPressed then
                teleportToMouseClick()
            end
        end)
        inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space and isFPressed then
                teleportBackToInitialPosition()
            end
        end)
    else
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
        if inputBeganConnection then
            inputBeganConnection:Disconnect()
            inputBeganConnection = nil
        end
        print("Телепортация отключена")
    end
end
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.F then
            isFPressed = true
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.F then
        isFPressed = false
    end
end)
screenGui.Name = "MyScreenGui"
screenGui.Enabled = false  
local teleportMessage = nil  
local infoMessaget = nil  
game.Players.PlayerAdded:Connect(function(player)
    addExclamationMarkForServerCreator(player)
end)
local function infoMessage(info)
    if infoMessaget then
        infoMessaget:Destroy() 
    end
    infoMessaget = Instance.new("Frame")
    infoMessaget.Size = UDim2.new(0, 300, 0, 50)
    infoMessaget.Position = UDim2.new(1, -310, 0, 10)
    infoMessaget.BackgroundColor3 = Color3.fromRGB(0, 255, 0) 
    infoMessaget.BackgroundTransparency = 0.5
    infoMessaget.BorderSizePixel = 0
    infoMessaget.Parent = screenGui
    local message2Label = Instance.new("TextLabel")
    message2Label.Size = UDim2.new(1, 0, 1, 0)
    message2Label.Text = info
    message2Label.BackgroundTransparency = 1
    message2Label.TextColor3 = Color3.fromRGB(255, 255, 255)  
    message2Label.Font = Enum.Font.GothamBold
    message2Label.TextSize = 18
    message2Label.TextXAlignment = Enum.TextXAlignment.Center
    message2Label.Parent = infoMessaget
    delay(7, function()
        if infoMessaget then
            infoMessaget:Destroy()
        end
    end)
end
local function showTeleportMessage(targetPlayer)
    if teleportMessage then
        teleportMessage:Destroy() 
    end
    teleportMessage = Instance.new("Frame")
    teleportMessage.Size = UDim2.new(0, 300, 0, 50)
    teleportMessage.Position = UDim2.new(1, -310, 0, 10)
    teleportMessage.BackgroundColor3 = Color3.fromRGB(0, 255, 0) 
    teleportMessage.BackgroundTransparency = 0.5
    teleportMessage.BorderSizePixel = 0
    teleportMessage.Parent = screenGui
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 1, 0)
    messageLabel.Text = "Телепортирован к: " .. targetPlayer.Name .. " (" .. targetPlayer.DisplayName .. ")"
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  
    messageLabel.Font = Enum.Font.GothamBold
    messageLabel.TextSize = 18
    messageLabel.TextXAlignment = Enum.TextXAlignment.Center
    messageLabel.Parent = teleportMessage
    delay(7, function()
        if teleportMessage then
            teleportMessage:Destroy()
        end
    end)
end
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 350)
frame.Position = UDim2.new(0.5, -250, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(255, 255, 255)  
border.Thickness = 2 
border.Parent = frame
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, -20, 0, 250)
playerListFrame.Position = UDim2.new(0, 10, 0, 20)
playerListFrame.BackgroundTransparency = 1
playerListFrame.Parent = frame
local lastTeleportedPlayer = nil  
local function teleportToPlayer(targetPlayer)
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
        player.Character:MoveTo(targetPosition)
        lastTeleportedPlayer = targetPlayer 
        showTeleportMessage(targetPlayer) 
    else
        warn("Ошибка: Персонаж не найден для телепортации")
		info = "Ошибка: Персонаж не найден"
		infoMessage(info)
    end
end
local function calculateDistance(player1, player2)
    if player1.Character and player2.Character then
        local player1Pos = player1.Character:FindFirstChild("HumanoidRootPart")
        local player2Pos = player2.Character:FindFirstChild("HumanoidRootPart")
        if player1Pos and player2Pos then
            local distance = (player1Pos.Position - player2Pos.Position).Magnitude
            return math.floor(distance)  
        end
    end
    return 0
end
local function addPlayerButtons()
    local yOffset = 0
    local playerCount = 0  
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerButton = Instance.new("Frame")
            playerButton.Size = UDim2.new(1, 0, 0, 40)
            playerButton.Position = UDim2.new(0, 0, 0, yOffset)
            playerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            playerButton.BorderSizePixel = 0
            playerButton.Parent = playerListFrame
            local nameButton = Instance.new("TextButton")
            nameButton.Size = UDim2.new(0, 250, 1, 0)
            nameButton.Position = UDim2.new(0, 40, 0, 0)
            nameButton.Text = otherPlayer.Name
            nameButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            nameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameButton.Font = Enum.Font.Gotham
            nameButton.TextSize = 16
            nameButton.TextXAlignment = Enum.TextXAlignment.Left
            nameButton.Parent = playerButton
            nameButton.MouseButton1Click:Connect(function()
                teleportToPlayer(otherPlayer)
            end)
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(0, 100, 1, 0)  
            distanceLabel.Position = UDim2.new(0, 320, 0, 0) 
            distanceLabel.Text = "0м"  
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
            distanceLabel.Font = Enum.Font.Gotham
            distanceLabel.TextSize = 16
            distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
            distanceLabel.Parent = playerButton
            local function updateDistance()
                local distance = calculateDistance(player, otherPlayer)
                distanceLabel.Text = distance .. "м"
            end
            game:GetService("RunService").Heartbeat:Connect(updateDistance)
            local avatarImage = Instance.new("ImageLabel")
            avatarImage.Size = UDim2.new(0, 30, 0, 30)
            avatarImage.Position = UDim2.new(0, 10, 0, 5)
            avatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. otherPlayer.UserId .. "&width=420&height=420&format=png"
            avatarImage.BackgroundTransparency = 1
            avatarImage.Parent = playerButton
            local glowButton = Instance.new("TextButton")
            glowButton.Size = UDim2.new(0, 60, 1, 0)
            glowButton.Position = UDim2.new(0, 400, 0, 0)
            glowButton.Text = "Glow"
            glowButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  
            glowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            glowButton.Font = Enum.Font.GothamBold
            glowButton.TextSize = 14
            glowButton.Parent = playerButton
            local selectionBox = nil  
            local isGlowing = false 
            glowButton.MouseButton1Click:Connect(function()
                if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if not isGlowing then
                        selectionBox = Instance.new("SelectionBox")
                        selectionBox.Adornee = otherPlayer.Character
                        selectionBox.Parent = playerGui
                        selectionBox.SelectionColor = Color3.fromRGB(255, 0, 0)  
                        selectionBox.LineThickness = 0.2
                        selectionBox.Transparency = 0.5
                        glowButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  
                        isGlowing = true
                    else
                        selectionBox:Destroy()
                        glowButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  
                        isGlowing = false
                    end
                else
                    warn("Ошибка: Персонаж не найден")
					info = "Ошибка: Персонаж не найден"
					infoMessage(info)
                end
            end)
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Size = UDim2.new(0, 100, 0, 50)
            billboardGui.Adornee = otherPlayer.Character:FindFirstChild("Head")  
            billboardGui.Parent = playerGui
            billboardGui.AlwaysOnTop = true
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(1, 0, 1, 0)
            local distance = calculateDistance(player, otherPlayer)
            distanceLabel.Text = distance .. "м"
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  
            distanceLabel.Font = Enum.Font.Gotham
            distanceLabel.TextSize = 24
            distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
            distanceLabel.TextStrokeTransparency = 0.1  
            distanceLabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)  
            distanceLabel.Parent = billboardGui
            local nameLabel
            if distance > 200 then
                nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 0, 20)

                nameLabel.Position = UDim2.new(0, 0, 1, 0)  
                nameLabel.Text = otherPlayer.Name
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)  
                nameLabel.TextSize = 14
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextXAlignment = Enum.TextXAlignment.Center
                nameLabel.Parent = billboardGui
            end
            game:GetService("RunService").Heartbeat:Connect(function()
                local distance = calculateDistance(player, otherPlayer)
                distanceLabel.Text = distance .. "м"
                if distance > 200 then
                    if not nameLabel then
                        nameLabel = Instance.new("TextLabel")
                        nameLabel.Size = UDim2.new(1, 0, 0, 20)
                        nameLabel.Position = UDim2.new(0, 0, 1, 0)
                        nameLabel.Text = otherPlayer.Name
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                        nameLabel.TextSize = 24
                        nameLabel.Font = Enum.Font.GothamBold
                        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
                        nameLabel.Parent = billboardGui
                    end
                else
                    if nameLabel then
                        nameLabel:Destroy()
                    end
                end
            end)
            yOffset = yOffset + 45
            playerCount = playerCount + 1  
        end
    end
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, playerCount * 45) 
end
local clearGlowButton = Instance.new("TextButton")
clearGlowButton.Size = UDim2.new(0, 500, 0, 60)
clearGlowButton.Position = UDim2.new(0, 0, 1, -60)
clearGlowButton.Text = "By nitarte:3"
clearGlowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearGlowButton.Font = Enum.Font.GothamBold
clearGlowButton.TextSize = 16
clearGlowButton.Parent = frame
local tpbut = Instance.new("TextButton")
tpbut.Size = UDim2.new(0, 150, 0, 30)
tpbut.Position = UDim2.new(0, 160, 0, -20)
tpbut.Text = "Teleport on"
tpbut.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
tpbut.TextColor3 = Color3.fromRGB(255, 255, 255)
tpbut.Font = Enum.Font.Gotham
tpbut.TextSize = 16
tpbut.TextXAlignment = Enum.TextXAlignment.Center
tpbut.Parent = frame
tpbut.MouseButton1Click:Connect(function()
teleportToPlayer(otherPlayer)
end)
local istpOn = false
local function toggletp()
    if istpOn then
        tpbut.Text = "Teleport on"
        tpbut.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        statustelep = false
		info = "Телепортации включены!"
		infoMessage(info)
    else
        tpbut.Text = "Teleport off"
        tpbut.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        statustelep = true  
		info = "Телепортации выключены!"
		infoMessage(info)
    end
    istpOn = not istpOn
    teleportyes(statustelep)
end
tpbut.MouseButton1Click:Connect(function()
    toggletp()
end)
local speedbut = Instance.new("TextButton")
speedbut.Size = UDim2.new(0, 150, 0, 30) 
speedbut.Position = UDim2.new(0, 0, 0, -20) 
speedbut.Text = "Speed on"
speedbut.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
speedbut.TextColor3 = Color3.fromRGB(255, 255, 255)
speedbut.Font = Enum.Font.Gotham
speedbut.TextSize = 16
speedbut.TextXAlignment = Enum.TextXAlignment.Center
speedbut.Parent = frame
speedbut.MouseButton1Click:Connect(function()
teleportToPlayer(otherPlayer)
end)
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 150, 0, 30)
inputBox.Position = UDim2.new(0, 0, 0, -60)
inputBox.PlaceholderText = "ВВЕДИ СКОРОСТЬ"
inputBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 16
inputBox.Parent = frame
inputBox.FocusLost:Connect(function()
    local speedValue = tonumber(inputBox.Text)
    if speedValue and speedValue > 0 then
        humanoid.WalkSpeed = speedValue
		info = "Скорость установленна на " .. speedValue
		infoMessage(info)
    else
        warn("Неверное значение скорости")
		info = "Значение не может быть меньше 0!"
		infoMessage(info)
    end
end)
local function toggleSpeed()
    if isSpeedOn then
        speedbut.Text = "Speed on"
        speedbut.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
		info = "Супер скорость включенна!"
		infoMessage(info)
    else
        speedbut.Text = "Speed off"
        speedbut.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        instantSpeedBoost()
        applyBodyVelocity()
		info = "Супер скорость отключенна!"
		infoMessage(info)
    end
    isSpeedOn = not isSpeedOn 
end
speedbut.MouseButton1Click:Connect(function()
    toggleSpeed()  
end)
local nbut = Instance.new("TextButton")
nbut.Size = UDim2.new(0, 150, 0, 30) 
nbut.Position = UDim2.new(0, 320, 0, -20) 
nbut.Text = "Noclip on"
nbut.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
nbut.TextColor3 = Color3.fromRGB(255, 255, 255)
nbut.Font = Enum.Font.Gotham
nbut.TextSize = 16
nbut.TextXAlignment = Enum.TextXAlignment.Center
nbut.Parent = frame
local isFlyAndNoClipOn = false 
local function toggleFlyAndNoClip()
    if isFlyAndNoClipOn then
        stopFlying()
        disableNoClip()
        nbut.Text = "NoClip On"
		info = "Ноуклип выключен!"
		infoMessage(info)
        nbut.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    else
        startFlying(noclipSpeed)
        enableNoClip()
        nbut.Text = "NoClip Off"
		info = "Ноуклип включен!"
		infoMessage(info)
        nbut.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    end
    isFlyAndNoClipOn = not isFlyAndNoClipOn
end
nbut.MouseButton1Click:Connect(function()
    toggleFlyAndNoClip()
end)
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 150, 0, 30)
inputBox.Position = UDim2.new(0, 320, 0, -60)
inputBox.PlaceholderText = "ВВЕДИ СКОРОСТЬ"
inputBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 16
inputBox.Parent = frame
inputBox.FocusLost:Connect(function()
    local speedValue = tonumber(inputBox.Text)
    if speedValue and speedValue > 0 then
        noclipSpeed = speedValue 
        if isFlyAndNoClipOn then
            startFlying(noclipSpeed)
			info = "Скорость установленна на " .. noclipSpeed
			infoMessage(info)
        end
    else
        warn("Invalid speed value")
		info = "Значение не может быть меньше 0!"
		infoMessage(info)
    end
end)
local function createFlagEffect(character)
    local whiteFlag = Instance.new("Part")
    whiteFlag.Size = Vector3.new(50, 20, 0.20) 
    whiteFlag.Position = character:WaitForChild("Torso").Position + Vector3.new(0, 50, 0)  
    whiteFlag.BrickColor = BrickColor.new(Color3.fromRGB(255, 255, 255)) 
    whiteFlag.Anchored = true
    whiteFlag.Parent = game.Workspace
    local blueFlag = Instance.new("Part")
    blueFlag.Size = Vector3.new(50, 20, 0.20)
    blueFlag.Position = whiteFlag.Position - Vector3.new(0, 20.1, 0)  
    blueFlag.BrickColor = BrickColor.new(Color3.fromRGB(0, 0, 255)) 
    blueFlag.Anchored = true
    blueFlag.Parent = game.Workspace
    local redFlag = Instance.new("Part")
    redFlag.Size = Vector3.new(50, 20, 0.20)  
    redFlag.Position = blueFlag.Position - Vector3.new(0, 20.1, 0)  
    redFlag.BrickColor = BrickColor.new(Color3.fromRGB(255, 0, 0))  
    redFlag.Anchored = true
    redFlag.Parent = game.Workspace
end
clearGlowButton.MouseButton1Click:Connect(function()
	createFlagEffect(player.Character)
	disableAnimations()
	info = "Вьебал русской любви!"
	infoMessage(info)
end)
clearGlowButton.MouseButton1Click:Connect(function()
    for _, selectionBox in ipairs(activeSelectionBoxes) do
        selectionBox:Destroy()
    end
    activeSelectionBoxes = {}
end)
local isOpen = false
local function toggleGui()
    if isOpen then
        screenGui.Enabled = false  
    else
        screenGui.Parent = playerGui  
        screenGui.Enabled = true
        addPlayerButtons()
    end
    isOpen = not isOpen
end
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Insert then
            toggleGui()
        elseif input.KeyCode == Enum.KeyCode.T then
            if lastTeleportedPlayer then
                teleportToPlayer(lastTeleportedPlayer)
            else
                warn("Нет последнего телепортированного игрока.")
				info = "Нет последнего телепортированного игрока!"
				infoMessage(info)
            end
        end
    end
end)
