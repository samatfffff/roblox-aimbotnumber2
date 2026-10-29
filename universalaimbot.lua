-- Подключаем профессиональную мобильную UI библиотеку
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

-- Создаем окно чита
local Window = OrionLib:MakeWindow({Name = "🔮 Anti-Cheat Research Hub (Mobile)", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

-- Главные переменные аима
getgenv().AimbotEnabled = false
getgenv().AimPart = "Head"
getgenv().FOV_Radius = 150

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Создание визуального круга FOV (для мобилок)
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = true
FOV_Circle.Color = Color3.fromRGB(255, 0, 0)
FOV_Circle.Thickness = 2
FOV_Circle.Filled = false

-- Логика поиска цели по центру экрана смартфона
local function GetClosestPlayer()
    if not getgenv().AimbotEnabled then return nil end
    local Target = nil
    local ShortestDistance = math.huge
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            local TargetPart = Player.Character:FindFirstChild(getgenv().AimPart)
            if TargetPart then
                local Vector, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                if OnScreen then
                    local Distance = (Vector2.new(Vector.X, Vector.Y) - ScreenCenter).Magnitude
                    if Distance < ShortestDistance and Distance <= getgenv().FOV_Radius then
                        ShortestDistance = Distance
                        Target = TargetPart
                    end
                end
            end
        end
    end
    return Target
end

-- Вкладка управления в меню
local MainTab = Window:MakeTab({
    Name = "Aimbot Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- 1. Переключатель ВКЛ / ВЫКЛ Аима
MainTab:AddToggle({
    Name = "Включить Аимбот (Автонаводка)",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotEnabled = Value
    end    
})

-- 2. Выбор части тела (Голова / Тело)
MainTab:AddDropdown({
    Name = "Куда целиться",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart"},
    Callback = function(Value)
        getgenv().AimPart = Value
    end    
})

-- 3. Ползунок размера FOV
MainTab:AddSlider({
    Name = "Размер FOV (Радиус)",
    Min = 50,
    Max = 500,
    Default = 150,
    Color = Color3.fromRGB(255,255,255),
    Increment = 10,
    ValueName = "px",
    Callback = function(Value)
        getgenv().FOV_Radius = Value
    end    
})

-- Цикл работы аима и обновления круга FOV
RunService.RenderStepped:Connect(function()
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV_Circle.Position = ScreenCenter
    FOV_Circle.Radius = getgenv().FOV_Radius
    FOV_Circle.Visible = getgenv().AimbotEnabled

    if getgenv().AimbotEnabled then
        local ClosestPart = GetClosestPlayer()
        if ClosestPart then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, ClosestPart.Position)
        end
    end
end)

OrionLib:Init()
