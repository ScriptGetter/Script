
--// Load Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/AbstractPoo/Fluent/main/source.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Zombie Attack | Frenzy Hub",
    SubTitle = "Version 0.12",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "swords" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Credits = Window:AddTab({ Title = "Credits", Icon = "heart" })
}

-- Auto Kill Zombies
local autoKill = false
Tabs.Main:AddToggle("Auto Kill Zombies", {
    Default = false,
    Callback = function(v)
        autoKill = v
        task.spawn(function()
            while autoKill do
                for _, z in ipairs(workspace.Zombies:GetChildren()) do
                    if z:FindFirstChild("Head") and z:FindFirstChild("Humanoid") and z.Humanoid.Health > 0 then
                        game:GetService("ReplicatedStorage").WeaponRemotes.Damage:FireServer(z.Head, 100)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

-- Kill Aura
local killAura = false
Tabs.Main:AddToggle("Kill Aura (Close Range)", {
    Default = false,
    Callback = function(v)
        killAura = v
        task.spawn(function()
            while killAura do
                for _, z in ipairs(workspace.Zombies:GetChildren()) do
                    local root = z:FindFirstChild("HumanoidRootPart")
                    if root and (root.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        game:GetService("ReplicatedStorage").WeaponRemotes.Damage:FireServer(z:FindFirstChild("Head"), 100)
                    end
                end
                task.wait(0.2)
            end
        end)
    end
})

-- Hitbox Expander
Tabs.Main:AddToggle("Expand Zombie Hitboxes", {
    Default = false,
    Callback = function(v)
        getgenv().BigHitbox = v
        task.spawn(function()
            while getgenv().BigHitbox do
                for _, z in pairs(workspace.Zombies:GetChildren()) do
                    local hrp = z:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(15, 15, 15)
                        hrp.Transparency = 0.5
                        hrp.Material = Enum.Material.Neon
                        hrp.Color = Color3.fromRGB(255, 0, 0)
                        hrp.CanCollide = false
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})

-- Zombie ESP
Tabs.Main:AddButton("Enable Zombie ESP", function()
    for _, z in pairs(workspace.Zombies:GetChildren()) do
        if not z:FindFirstChild("Highlight") then
            local h = Instance.new("Highlight", z)
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.FillTransparency = 0.5
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.OutlineTransparency = 0.2
        end
    end
    workspace.Zombies.ChildAdded:Connect(function(z)
        task.wait(0.2)
        if z:FindFirstChild("Humanoid") then
            local h = Instance.new("Highlight", z)
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.FillTransparency = 0.5
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.OutlineTransparency = 0.2
        end
    end)
end)

-- Auto Collect Powerups
Tabs.Main:AddToggle("Auto Collect Power-Ups", {
    Default = false,
    Callback = function(state)
        getgenv().autoCollect = state
        task.spawn(function()
            while getgenv().autoCollect do
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name:lower():find("power") and obj:IsA("Model") and obj:FindFirstChildWhichIsA("TouchTransmitter", true) then
                        firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, obj, 0)
                        task.wait()
                        firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, obj, 1)
                    end
                end
                task.wait(1)
            end
        end)
    end
})

-- WalkSpeed / JumpPower
Tabs.Misc:AddSlider("WalkSpeed", {
    Default = 16,
    Min = 16,
    Max = 100,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})

Tabs.Misc:AddSlider("JumpPower", {
    Default = 50,
    Min = 50,
    Max = 200,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
    end
})

-- Auto Equip Best Gun
Tabs.Misc:AddButton("Equip Best Gun", function()
    for _, gun in pairs(game:GetService("ReplicatedStorage").GunInventory:GetChildren()) do
        game:GetService("ReplicatedStorage").Remotes.Equip:FireServer(gun.Name)
    end
end)

-- Noclip (Hold N)
local uis = game:GetService("UserInputService")
local noclip = false

Tabs.Misc:AddToggle("Noclip (Hold N)", {
    Default = false,
    Callback = function(state)
        noclip = state
        uis.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Enum.KeyCode.N and noclip then
                while noclip and uis:IsKeyDown(Enum.KeyCode.N) do
                    game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(11)
                    task.wait()
                end
            end
        end)
    end
})

-- Anti-AFK
Tabs.Misc:AddButton("Enable Anti-AFK", function()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- Rejoin Server
Tabs.Misc:AddButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
end)

-- Mobile Toggle (Click to Hide/Show UI)
Tabs.Misc:AddButton("Toggle UI (Mobile)", function()
    Window.Visible = not Window.Visible
end)

-- Credits
Tabs.Credits:AddParagraph({
    Title = "Frenzy Hub",
    Content = "Zombie Attack Script\nCode by Frenzy
