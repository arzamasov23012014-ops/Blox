--[[
    SAKURA FRUITS
    Pink Sakura-themed interface starter for Roblox Studio / your own experience.
    This is a UI and player-status template. It does not automate gameplay,
    teleport in someone else's game, attack players/NPCs, or bypass protections.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local ENV = (getgenv and getgenv()) or _G

-- Prevent duplicate windows when re-executed.
if ENV.SakuraFruitsUnload then
    pcall(ENV.SakuraFruitsUnload)
    ENV.SakuraFruitsUnload = nil
    task.wait(0.25)
end

local Alive = true
local Connections = {}
local function keep(connection)
    table.insert(Connections, connection)
    return connection
end

local function notify(title, message, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Sakura Fruits",
            Text = message or "",
            Duration = duration or 4
        })
    end)
end

-- Rayfield loader, matching the original Sakura script's UI framework.
local loaded, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not loaded or not Rayfield then
    warn("[Sakura Fruits] Could not load Rayfield.")
    notify("Sakura Fruits", "Не удалось загрузить интерфейс Rayfield.")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "🌸 Sakura Fruits",
    LoadingTitle = "Sakura Fruits",
    LoadingSubtitle = "Petals are falling...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SakuraFruits",
        FileName = "Settings"
    },
    Discord = { Enabled = false },
    KeySystem = false,
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true
})

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getLevel()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local level = leaderstats:FindFirstChild("Level")
            or leaderstats:FindFirstChild("Lv.")
            or leaderstats:FindFirstChild("Lvl")
        if level and (level:IsA("IntValue") or level:IsA("NumberValue") or level:IsA("StringValue")) then
            return tostring(level.Value)
        end
    end
    return "Not available"
end

-- MAIN
local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateSection("Sakura Fruits")
MainTab:CreateParagraph({
    Title = "Welcome!",
    Content = "Добро пожаловать в Sakura Fruits 🌸\nЭто безопасный интерфейс-шаблон: он показывает состояние персонажа и настройки самого меню."
})
local statusLabel = MainTab:CreateLabel("Status: loading...")
local levelLabel = MainTab:CreateLabel("Level: " .. getLevel())
local healthLabel = MainTab:CreateLabel("Health: --")
local positionLabel = MainTab:CreateLabel("Position: --")

MainTab:CreateButton({
    Name = "Refresh player info",
    Callback = function()
        levelLabel:Set("Level: " .. getLevel())
        local humanoid = getHumanoid()
        healthLabel:Set(humanoid and ("Health: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)) or "Health: character not loaded")
        notify("Sakura Fruits", "Информация обновлена.")
    end
})

-- FARM: UI placeholders only; no automatic farming or remote calls.
local FarmTab = Window:CreateTab("Farm", 4483362458)
FarmTab:CreateSection("Farm settings")
FarmTab:CreateParagraph({
    Title = "Farm module",
    Content = "Здесь можно разместить настройки тренировочного/фермерского режима для собственной игры в Roblox Studio. Автоматические атаки, сбор предметов и вызовы игровых RemoteEvent не включены."
})
local farmMode = "Off"
FarmTab:CreateDropdown({
    Name = "Profile",
    Options = {"Off", "Quest practice", "Resource practice"},
    CurrentOption = {"Off"},
    MultipleOptions = false,
    Flag = "FarmProfile",
    Callback = function(option)
        farmMode = typeof(option) == "table" and (option[1] or "Off") or tostring(option)
        statusLabel:Set("Status: UI profile = " .. farmMode)
    end
})

-- PLAYER: read-only character information.
local PlayerTab = Window:CreateTab("Player", 4483362458)
PlayerTab:CreateSection("Character")
local playerInfo = PlayerTab:CreateLabel("WalkSpeed: --")
local jumpInfo = PlayerTab:CreateLabel("JumpPower: --")
PlayerTab:CreateButton({
    Name = "Update character info",
    Callback = function()
        local h = getHumanoid()
        playerInfo:Set(h and ("WalkSpeed: " .. tostring(h.WalkSpeed)) or "WalkSpeed: --")
        jumpInfo:Set(h and ("JumpPower: " .. tostring(h.JumpPower)) or "JumpPower: --")
    end
})
PlayerTab:CreateParagraph({
    Title = "Note",
    Content = "Эта вкладка только отображает параметры персонажа. Она не меняет скорость, прыжок или физику персонажа в чужой игре."
})

-- TELEPORT: safe navigation placeholder.
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
TeleportTab:CreateSection("Navigation")
TeleportTab:CreateParagraph({
    Title = "Navigation module",
    Content = "Для собственной игры сюда можно добавить легальные точки перемещения, заданные разработчиком через систему SpawnLocation/телепортов проекта. Телепортация по координатам в чужой игре не выполняется."
})

-- FRUIT: local inventory viewer, without changing or spawning items.
local FruitTab = Window:CreateTab("Fruit", 4483362458)
FruitTab:CreateSection("Fruit inventory")
local fruitLabel = FruitTab:CreateLabel("Fruit entries: --")
FruitTab:CreateButton({
    Name = "Scan visible player containers",
    Callback = function()
        local found = {}
        local containers = {
            LocalPlayer:FindFirstChild("Backpack"),
            getCharacter()
        }
        for _, container in ipairs(containers) do
            if container then
                for _, item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") then
                        table.insert(found, item.Name)
                    end
                end
            end
        end
        fruitLabel:Set("Tools found: " .. (#found > 0 and table.concat(found, ", ") or "none"))
    end
})
FruitTab:CreateParagraph({
    Title = "Inventory note",
    Content = "Показываются только Tool-объекты, доступные клиенту в Backpack/Character. Скрипт не создаёт, не дублирует и не меняет фрукты."
})

-- MISC
local MiscTab = Window:CreateTab("Misc", 4483362458)
MiscTab:CreateSection("Utilities")
MiscTab:CreateButton({
    Name = "Show welcome notification",
    Callback = function()
        notify("🌸 Sakura Fruits", "Have a lovely adventure!")
    end
})
MiscTab:CreateButton({
    Name = "Re-check character",
    Callback = function()
        local h = getHumanoid()
        statusLabel:Set(h and "Status: character ready" or "Status: waiting for character")
        notify("Sakura Fruits", h and "Персонаж найден." or "Персонаж ещё не загружен.")
    end
})

-- SETTINGS
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Interface")
SettingsTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "SakuraToggleKey",
    Callback = function()
        pcall(function() Rayfield:Toggle() end)
    end
})
SettingsTab:CreateButton({
    Name = "Unload Sakura Fruits",
    Callback = function()
        Alive = false
        for _, connection in ipairs(Connections) do
            pcall(function() connection:Disconnect() end)
        end
        pcall(function() Rayfield:Destroy() end)
        ENV.SakuraFruitsUnload = nil
    end
})

-- Live read-only status refresh.
keep(RunService.Heartbeat:Connect(function()
    if not Alive then return end
    local root = getRoot()
    local humanoid = getHumanoid()
    if root then
        local p = root.Position
        positionLabel:Set(string.format("Position: %.0f, %.0f, %.0f", p.X, p.Y, p.Z))
    end
    if humanoid then
        healthLabel:Set(string.format("Health: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)))
        statusLabel:Set("Status: character ready")
    else
        statusLabel:Set("Status: waiting for character")
    end
end))

keep(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Alive then
        notify("Sakura Fruits", "Character loaded 🌸")
    end
end))

ENV.SakuraFruitsUnload = function()
    Alive = false
    for _, connection in ipairs(Connections) do
        pcall(function() connection:Disconnect() end)
    end
    pcall(function() Rayfield:Destroy() end)
end

notify("Sakura Fruits", "Интерфейс успешно запущен 🌸", 5)
