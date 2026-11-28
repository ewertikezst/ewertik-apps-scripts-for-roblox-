local library, env = ...

local HttpService = game:GetService("HttpService")
local ICON = "rbxassetid://109136065777940"

library:SetTitle("QuantumOS scripts")


local function runCode(code)
    local fn, err = loadstring(code)
    if not fn then
        warn("Error de sintaxis: " .. tostring(err))
        return
    end
    local ok, e = pcall(fn)
    if not ok then
        warn("Error al ejecutar: " .. tostring(e))
    end
end

local function readField(box)
    local ok, v = pcall(function() return box.Text end)
    if ok and type(v) == "string" then return v end
    return ""
end

local function readSelected(box, default)
    local ok, v = pcall(function() return box.Selected end)
    if ok and type(v) == "string" and v ~= "" then return v end
    return default
end


local games = {
    ["Universal"] = { placeId = 0, scripts = {} },
}
local gameNames = { "Universal" }

local scriptsPage = library:AddPage("Scripts", ICON)

scriptsPage:AddCategoryTitle("Agregar script", "Nombre, juego, place id y código")

local nameBox  = scriptsPage:AddTextbox("Nombre del script")
local gameBox  = scriptsPage:AddTextbox("Juego (vacío = Universal)")
local placeBox = scriptsPage:AddTextbox("Place ID (solo juego nuevo)")
local codeBox  = scriptsPage:AddTextbox("Código Lua / Luau")
local typeBox  = scriptsPage:AddComboBox("Tipo", "Lua o Luau", { "Lua", "Luau" })

local addBtn = scriptsPage:AddButton("Agregar script")

scriptsPage:AddSplitter("Mis scripts")

local listButtons = {}

local function refreshList()
    for _, b in ipairs(listButtons) do
        pcall(function() b:Remove() end)
    end
    listButtons = {}

    for _, gameName in ipairs(gameNames) do
        for _, s in ipairs(games[gameName].scripts) do
            local btn = scriptsPage:AddButton(gameName .. " | " .. s.name)
            btn.OnClick:Connect(function()
                runCode(s.code)
            end)
            table.insert(listButtons, btn)
        end
    end
end

addBtn.OnClick:Connect(function()
    local name     = readField(nameBox)
    local gameName = readField(gameBox)
    local code     = readField(codeBox)

    if name == "" or code == "" then
        warn("Falta el nombre o el código")
        return
    end
    if gameName == "" then
        gameName = "Universal"
    end

    if not games[gameName] then
        games[gameName] = {
            placeId = tonumber(readField(placeBox)) or 0,
            scripts = {},
        }
        table.insert(gameNames, gameName)
    end

    table.insert(games[gameName].scripts, {
        name = name,
        code = code,
        kind = readSelected(typeBox, "Lua"),
    })

    refreshList()
end)


local hubPage = library:AddPage("Script Hub", ICON)

hubPage:AddCategoryTitle("Buscar scripts", "ScriptBlox o Rscripts")

local searchBox = hubPage:AddTextbox("Buscar...")
local sourceBox = hubPage:AddComboBox("Fuente", "Dónde buscar", { "ScriptBlox", "Rscripts" })
local searchBtn = hubPage:AddButton("Buscar")

hubPage:AddSplitter("Resultados")

local hubButtons = {}

local function clearHub()
    for _, b in ipairs(hubButtons) do
        pcall(function() b:Remove() end)
    end
    hubButtons = {}
end

local function addResult(title, code)
    if code == "" then return end
    local btn = hubPage:AddButton(title)
    btn.OnClick:Connect(function()
        runCode(code)
    end)
    table.insert(hubButtons, btn)
end

local function getJson(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil end
    local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok2 then return nil end
    return data
end

local function searchScriptBlox(q)
    local data = getJson("https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(q))
    if not data then return warn("No se pudo conectar a ScriptBlox") end
    for _, s in ipairs((data.result and data.result.scripts) or {}) do
        addResult(s.title or "Sin título", s.script or "")
    end
end

local function searchRscripts(q)
    local data = getJson("https://rscripts.net/api/v2/scripts?q=" .. HttpService:UrlEncode(q))
    if not data then return warn("No se pudo conectar a Rscripts") end
    for _, s in ipairs(data.scripts or {}) do
        addResult(s.title or "Sin título", s.script or "")
    end
end

searchBtn.OnClick:Connect(function()
    local q = readField(searchBox)
    if q == "" then return end
    clearHub()
    if readSelected(sourceBox, "ScriptBlox") == "Rscripts" then
        searchRscripts(q)
    else
        searchScriptBlox(q)
    end
end)


pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    local State = {
        SilentAim = false, Aimbot = false, Prediction = 0,
        AimPart = "Head", WallCheck = false, TeamCheck = false, Aimlock = false,
        Fly = false, Noclip = false, AntiFling = false, FlySpeed = 50
    }

    local function readField(box)
        local ok, v = pcall(function() return box.Text end)
        if ok and type(v) == "string" then return v end
        return ""
    end

    local function readSelected(box, default)
        local ok, v = pcall(function() return box.Selected end)
        if ok and type(v) == "string" and v ~= "" then return v end
        return default
    end

    local combatPage = library:AddPage("Combate", ICON)

    combatPage:AddCategoryTitle("Aimbot", "Configuración del apuntado")

    combatPage:AddToggle("Silent Aim", false, function(v) State.SilentAim = v end)
    combatPage:AddToggle("Aimbot", false, function(v) State.Aimbot = v end)
    combatPage:AddSlider("Predicción", 0, 90.65, 0, function(v) State.Prediction = v end)
    combatPage:AddComboBox("Parte del cuerpo", "A qué parte apuntar", {"Head", "Torso", "HumanoidRootPart"})
    combatPage:AddToggle("Wall Check", false, function(v) State.WallCheck = v end)
    combatPage:AddToggle("Team Check", false, function(v) State.TeamCheck = v end)
    combatPage:AddToggle("Aimlock", false, function(v) State.Aimlock = v end)

    local playerPage = library:AddPage("Player", ICON)

    playerPage:AddCategoryTitle("Movimiento", "Velocidad y física")

    playerPage:AddSlider("Velocidad", 16, 250, 16, function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end)
    playerPage:AddSlider("Salto", 50, 500, 50, function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end)
    playerPage:AddSlider("Gravedad", 10, 196, 196, function(v) Workspace.Gravity = v end)
    playerPage:AddSlider("Fly Speed", 10, 200, 50, function(v) State.FlySpeed = v end)
    playerPage:AddToggle("Fly", false, function(v) State.Fly = v end)
    playerPage:AddToggle("Anti-Fling", false, function(v) State.AntiFling = v end)
    playerPage:AddToggle("Noclip", false, function(v) State.Noclip = v end)

    local scriptsPage = library:AddPage("Scripts", ICON)
    local games = {
        ["Universal"] = { placeId = 0, scripts = {} },
        ["Murder Mystery 2"] = { placeId = 142823291, scripts = {} },
        ["Blox Fruits"] = { placeId = 2753915549, scripts = {} },
        ["Rivals"] = { placeId = 1401059348, scripts = {} }
    }
    local gameNames = { "Universal", "Murder Mystery 2", "Blox Fruits", "Rivals" }

    scriptsPage:AddCategoryTitle("Agregar script", "Nombre, juego, place id y código")

    local nameBox  = scriptsPage:AddTextbox("Nombre del script")
    local gameBox  = scriptsPage:AddComboBox("Juego", "Selecciona el juego", gameNames)
    local customGameBox = scriptsPage:AddTextbox("Nuevo juego (Nombre)")
    local placeBox = scriptsPage:AddTextbox("Place ID (solo juego nuevo)")
    local codeBox  = scriptsPage:AddTextbox("Código Lua / Luau")

    local addBtn = scriptsPage:AddButton("Agregar script")

    scriptsPage:AddSplitter("Mis scripts")
    local listButtons = {}

    local function refreshList()
        for _, b in ipairs(listButtons) do
            pcall(function() b:Remove() end)
        end
        listButtons = {}

        for _, gameName in ipairs(gameNames) do
            if #games[gameName].scripts > 0 then
                local btnGame = scriptsPage:AddButton(gameName .. " (" .. #games[gameName].scripts .. ")")
                btnGame.OnClick:Connect(function()
                    for _, s in ipairs(games[gameName].scripts) do
                        runCode(s.code)
                    end
                end)
                table.insert(listButtons, btnGame)
            end
        end
    end

    addBtn.OnClick:Connect(function()
        local name = readField(nameBox)
        local code = readField(codeBox)
        local selectedGame = readSelected(gameBox, "Universal")
        local customGame = readField(customGameBox)
        local placeId = tonumber(readField(placeBox))

        if name == "" or code == "" then
            warn("Falta el nombre o el código")
            return
        end

        local targetGame = selectedGame
        if customGame ~= "" then
            targetGame = customGame
            if not games[targetGame] then
                games[targetGame] = { placeId = placeId or 0, scripts = {} }
                table.insert(gameNames, targetGame)
            end
        end

        table.insert(games[targetGame].scripts, { name = name, code = code })
        refreshList()
    end)

    refreshList()

    local hubPage = library:AddPage("Script Hub", ICON)

    hubPage:AddCategoryTitle("Buscar scripts", "ScriptBlox o Rscripts")

    local searchBox = hubPage:AddTextbox("Buscar...")
    local sourceBox = hubPage:AddComboBox("Fuente", "Dónde buscar", { "ScriptBlox", "Rscripts" })
    local searchBtn = hubPage:AddButton("Buscar")

    hubPage:AddSplitter("Resultados")
    local hubButtons = {}

    local function clearHub()
        for _, b in ipairs(hubButtons) do
            pcall(function() b:Remove() end)
        end
        hubButtons = {}
    end

    local function addResult(title, code)
        if code == "" then return end
        local btn = hubPage:AddButton(title)
        btn.OnClick:Connect(function()
            runCode(code)
        end)
        table.insert(hubButtons, btn)
    end

    local function getJson(url)
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if not ok then return nil end
        local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok2 then return nil end
        return data
    end

    local function searchScriptBlox(q)
        local data = getJson("https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(q))
        if not data then return warn("No se pudo conectar a ScriptBlox") end
        for _, s in ipairs((data.result and data.result.scripts) or {}) do
            addResult(s.title or "Sin título", s.script or "")
        end
    end

    local function searchRscripts(q)
        local data = getJson("https://rscripts.net/api/v2/scripts?q=" .. HttpService:UrlEncode(q))
        if not data then return warn("No se pudo conectar a Rscripts") end
        for _, s in ipairs(data.scripts or {}) do
            addResult(s.title or "Sin título", s.script or "")
        end
    end

    searchBtn.OnClick:Connect(function()
        local q = readField(searchBox)
        if q == "" then return end
        clearHub()
        if readSelected(sourceBox, "ScriptBlox") == "Rscripts" then
            searchRscripts(q)
        else
            searchScriptBlox(q)
        end
    end)

    local function getTarget()
        local closest, dist = nil, math.huge
        local center = UserInputService.TouchEnabled and (Camera.ViewportSize / 2) or UserInputService:GetMouseLocation()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if State.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local part = p.Character:FindFirstChild(State.AimPart) or p.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local screen, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        if State.WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, part.Position - Camera.CFrame.Position)
                            local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
                            if hit then continue end
                        end
                        local d = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                        if d < dist then dist = d closest = part end
                    end
                end
            end
        end
        return closest
    end

    task.spawn(function()
        local FlyBV, FlyBG
        RunService.RenderStepped:Connect(function()
            pcall(function()
                if State.Aimbot and getTarget() then
                    local target = getTarget()
                    if target then
                        local prediction = target.Position + (target.Velocity * (State.Prediction / 100))
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, prediction), 0.2)
                    end
                end
            end)
        end)

        local oldIndex
        pcall(function()
            oldIndex = hookmetamethod(game, "__index", function(self, method)
                if self == LocalPlayer:GetMouse() and method == "Hit" and State.SilentAim then
                    local target = getTarget()
                    if target then return CFrame.new(target.Position) end
                end
                return oldIndex(self, method)
            end)
        end)

        RunService.Stepped:Connect(function()
            pcall(function()
                if LocalPlayer.Character then
                    if State.Noclip then
                        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    elseif State.AntiFling then
                        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.CanCollide = true end
                        end
                    end
                end
            end)
        end)

        RunService.RenderStepped:Connect(function()
            pcall(function()
                if State.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    if not FlyBV then
                        FlyBV = Instance.new("BodyVelocity", hrp)
                        FlyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                        FlyBG = Instance.new("BodyGyro", hrp)
                        FlyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                        FlyBG.P = 1000
                    end
                    local moveDir = Camera.CFrame.LookVector
                    FlyBV.Velocity = moveDir * State.FlySpeed
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        FlyBV.Velocity = FlyBV.Velocity + Vector3.new(0, State.FlySpeed, 0)
                    end
                else
                    if FlyBV then FlyBV:Destroy() FlyBV = nil end
                    if FlyBG then FlyBG:Destroy() FlyBG = nil end
                end
            end)
        end)
    end)
end) 

