local library, env = ...

local HttpService = game:GetService("HttpService")

-- rbxthumb funciona aunque el ID sea un Decal; si no se ve, prueba "rbxassetid://109136065777940"
local ICON = "rbxthumb://type=Asset&id=109136065777940&w=150&h=150"
local PAGE_SIZE = 20

library:SetTitle("QuantumOS scripts")

-- ============================================================
-- UTILIDADES
-- ============================================================
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

local function getJson(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil end
    local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok2 then return nil end
    return data
end

-- Algunos resultados traen el código; otros traen un enlace al código
local function resolveCode(s)
    local c = s.script or s.rawScript or s.raw or ""
    if type(c) ~= "string" or c == "" then return "" end
    if c:match("^https?://") then
        local ok, body = pcall(function() return game:HttpGet(c) end)
        return ok and body or ""
    end
    return c
end

-- ============================================================
-- PÁGINA: SCRIPTS (ordenados por juego)
-- ============================================================
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

-- ============================================================
-- PÁGINA: SCRIPT HUB (ScriptBlox / Rscripts)
-- Al abrir carga los scripts más recientes; también puedes buscar
-- ============================================================
local hubPage = library:AddPage("Script Hub", ICON)

hubPage:AddCategoryTitle("Script Hub", "Todos los scripts de ScriptBlox y Rscripts")

local searchBox = hubPage:AddTextbox("Buscar...")
local sourceBox = hubPage:AddComboBox("Fuente", "Dónde buscar", { "ScriptBlox", "Rscripts" })
local searchBtn = hubPage:AddButton("Buscar")
local allBtn    = hubPage:AddButton("Ver todos")
local moreBtn   = hubPage:AddButton("Cargar más")

hubPage:AddSplitter("Resultados")

local hubButtons = {}
local currentPage = 1
local currentQuery = ""
local currentSource = "ScriptBlox"

local function clearHub()
    for _, b in ipairs(hubButtons) do
        pcall(function() b:Remove() end)
    end
    hubButtons = {}
end

local function addResult(title, s)
    local btn = hubPage:AddButton(title)
    btn.OnClick:Connect(function()
        local code = resolveCode(s)
        if code == "" then
            warn("Este script no trae código")
            return
        end
        runCode(code)
    end)
    table.insert(hubButtons, btn)
end

local function listFromScriptBlox(q, page)
    local url
    if q ~= "" then
        url = "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(q) .. "&page=" .. page
    else
        url = "https://scriptblox.com/api/script/fetch?page=" .. page
    end
    local data = getJson(url)
    if not data then return warn("No se pudo conectar a ScriptBlox") end
    local list = (data.result and data.result.scripts) or {}
    for i, s in ipairs(list) do
        if i > PAGE_SIZE then break end
        local gameName = (s.game and s.game.name) or "Universal"
        addResult(gameName .. " | " .. (s.title or "Sin título"), s)
    end
end

local function listFromRscripts(q, page)
    local url = "https://rscripts.net/api/v2/scripts?page=" .. page .. "&orderBy=date&sort=desc"
    if q ~= "" then
        url = url .. "&q=" .. HttpService:UrlEncode(q)
    end
    local data = getJson(url)
    if not data then return warn("No se pudo conectar a Rscripts") end
    local list = data.scripts or {}
    for i, s in ipairs(list) do
        if i > PAGE_SIZE then break end
        local gameName = (s.game and s.game.title) or (s.game and s.game.name) or "Universal"
        addResult(gameName .. " | " .. (s.title or "Sin título"), s)
    end
end

local function loadHub(reset)
    if reset then
        clearHub()
        currentPage = 1
    else
        currentPage = currentPage + 1
    end
    if currentSource == "Rscripts" then
        listFromRscripts(currentQuery, currentPage)
    else
        listFromScriptBlox(currentQuery, currentPage)
    end
end

searchBtn.OnClick:Connect(function()
    currentQuery = readField(searchBox)
    currentSource = readSelected(sourceBox, "ScriptBlox")
    loadHub(true)
end)

allBtn.OnClick:Connect(function()
    currentQuery = ""
    currentSource = readSelected(sourceBox, "ScriptBlox")
    loadHub(true)
end)

moreBtn.OnClick:Connect(function()
    loadHub(false)
end)

-- Carga inicial: ScriptBlox, scripts recientes
task.spawn(function()
    loadHub(true)
end)


