EHChar = EHChar or {}
EHChar.DB = EHChar.DB or {}
EHChar.DB.Pending = EHChar.DB.Pending or {}
EHChar.DB.Ready = false
EHChar.DB.Connecting = false

util.AddNetworkString("EHChar_OpenMenu")
util.AddNetworkString("EHChar_RequestCharacters")
util.AddNetworkString("EHChar_SendCharacters")
util.AddNetworkString("EHChar_SaveCharacter")
util.AddNetworkString("EHChar_SelectCharacter")
util.AddNetworkString("EHChar_SaveJobData")
util.AddNetworkString("EHChar_Notify")

local function dbPrint(text)
    print("[EHChar SQL] " .. tostring(text))
end

local function esc(value)
    value = tostring(value or "")

    if EHChar.DB.IsMySQL and EHChar.DB.Connection and EHChar.DB.Ready then
        return EHChar.DB.Connection:escape(value)
    end

    return sql.SQLStr(value, true)
end

local function mysqlReady()
    return EHChar.DB.IsMySQL and EHChar.DB.Connection and EHChar.DB.Ready
end

local function runMysqlQuery(query, onSuccess, onError)
    local q = EHChar.DB.Connection:query(query)

    function q:onSuccess(data)
        if onSuccess then onSuccess(data or {}) end
    end

    function q:onError(err)
        dbPrint("MySQL Fehler: " .. tostring(err))
        dbPrint("Query: " .. tostring(query))
        if onError then onError(err) end
    end

    q:start()
end

function EHChar.DB.FlushPending()
    if not mysqlReady() then return end

    local pending = EHChar.DB.Pending or {}
    EHChar.DB.Pending = {}

    if #pending > 0 then
        dbPrint("Fuehre wartende Queries aus: " .. #pending)
    end

    for _, item in ipairs(pending) do
        runMysqlQuery(item.query, item.onSuccess, item.onError)
    end
end

function EHChar.DB.Query(query, onSuccess, onError)
    if EHChar.DB.IsMySQL then
        if not mysqlReady() then
            EHChar.DB.Pending[#EHChar.DB.Pending + 1] = {
                query = query,
                onSuccess = onSuccess,
                onError = onError
            }
            dbPrint("Query wartet, MySQL ist noch nicht bereit.")
            return
        end

        runMysqlQuery(query, onSuccess, onError)
        return
    end

    local result = sql.Query(query)

    if result == false then
        local err = sql.LastError()
        dbPrint("SQLite Fehler: " .. tostring(err))
        dbPrint("Query: " .. tostring(query))
        if onError then onError(err) end
        return
    end

    if onSuccess then onSuccess(result or {}) end
end

function EHChar.DB.InitTables()
    if EHChar.DB.IsMySQL then
        EHChar.DB.Query([[
            CREATE TABLE IF NOT EXISTS eh_characters (
                id INT NOT NULL AUTO_INCREMENT,
                steamid64 VARCHAR(32) NOT NULL,
                slot INT NOT NULL,
                char_name VARCHAR(64) NOT NULL,
                gender VARCHAR(32) NOT NULL,
                model TEXT NOT NULL,
                skin INT NOT NULL DEFAULT 0,
                bodygroups TEXT NOT NULL,
                created_at INT NOT NULL,
                updated_at INT NOT NULL,
                PRIMARY KEY (id),
                UNIQUE KEY unique_player_slot (steamid64, slot)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])

        EHChar.DB.Query([[
            CREATE TABLE IF NOT EXISTS eh_character_jobs (
                id INT NOT NULL AUTO_INCREMENT,
                character_id INT NOT NULL,
                server_id VARCHAR(64) NOT NULL,
                job_id VARCHAR(64) NOT NULL,
                rank_name VARCHAR(64) NOT NULL,
                job_model TEXT NOT NULL,
                loadout TEXT NOT NULL,
                updated_at INT NOT NULL,
                PRIMARY KEY (id),
                UNIQUE KEY unique_character_server (character_id, server_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])

        return
    end

    EHChar.DB.Query([[
        CREATE TABLE IF NOT EXISTS eh_characters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid64 VARCHAR(32) NOT NULL,
            slot INTEGER NOT NULL,
            char_name TEXT NOT NULL,
            gender TEXT NOT NULL,
            model TEXT NOT NULL,
            skin INTEGER NOT NULL DEFAULT 0,
            bodygroups TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
        );
    ]])

    EHChar.DB.Query([[
        CREATE TABLE IF NOT EXISTS eh_character_jobs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL,
            server_id VARCHAR(64) NOT NULL,
            job_id VARCHAR(64) NOT NULL,
            rank_name VARCHAR(64) NOT NULL,
            job_model TEXT NOT NULL,
            loadout TEXT NOT NULL,
            updated_at INTEGER NOT NULL
        );
    ]])
end

function EHChar.DB.Connect()
    local cfg = EHChar.Config.Database or {}
    EHChar.DB.Ready = false

    if EHChar.DB.Connecting then
        dbPrint("Verbindung laeuft bereits.")
        return
    end

    if not cfg.UseMySQL then
        EHChar.DB.IsMySQL = false
        EHChar.DB.Ready = true
        dbPrint("Nutze SQLite Testdatenbank.")
        EHChar.DB.InitTables()
        return
    end

    if not cfg.Host or cfg.Host == "" or string.find(tostring(cfg.Host), "DEINE_SQL", 1, true) then
        dbPrint("FEHLER: SQL-Host ist nicht eingetragen. Bitte sv_config.lua ausfuellen.")
        return
    end

    if not cfg.Password or cfg.Password == "" or string.find(tostring(cfg.Password), "PASSWORT", 1, true) then
        dbPrint("FEHLER: SQL-Passwort ist nicht eingetragen. Bitte sv_config.lua ausfuellen.")
        return
    end

    local ok, err = pcall(require, "mysqloo")
    if not ok or not mysqloo then
        EHChar.DB.IsMySQL = false
        EHChar.DB.Ready = false
        dbPrint("mysqloo konnte nicht geladen werden: " .. tostring(err))
        dbPrint("Loesung: mysqloo Modul in garrysmod/lua/bin installieren und Server neu starten.")
        return
    end

    EHChar.DB.IsMySQL = true
    EHChar.DB.Connecting = true

    dbPrint("Verbinde zu MySQL: " .. tostring(cfg.Host) .. ":" .. tostring(cfg.Port or 3306) .. " / DB " .. tostring(cfg.Database) .. " / User " .. tostring(cfg.Username))

    EHChar.DB.Connection = mysqloo.connect(
        tostring(cfg.Host),
        tostring(cfg.Username or ""),
        tostring(cfg.Password or ""),
        tostring(cfg.Database or ""),
        tonumber(cfg.Port) or 3306
    )

    if EHChar.DB.Connection.setAutoReconnect then
        pcall(function() EHChar.DB.Connection:setAutoReconnect(cfg.AutoReconnect ~= false) end)
    end

    function EHChar.DB.Connection:onConnected()
        EHChar.DB.Ready = true
        EHChar.DB.Connecting = false
        dbPrint("MySQL verbunden.")
        EHChar.DB.InitTables()
        EHChar.DB.FlushPending()
    end

    function EHChar.DB.Connection:onConnectionFailed(errorText)
        EHChar.DB.Ready = false
        EHChar.DB.Connecting = false
        dbPrint("MySQL Verbindung fehlgeschlagen: " .. tostring(errorText))
        dbPrint("Pruefe Host, Port 3306, Datenbank, User, Passwort und externe Freigabe.")

        if cfg.AutoReconnect then
            local delay = tonumber(cfg.ReconnectDelay) or 10
            timer.Simple(delay, function()
                if EHChar and EHChar.DB and not EHChar.DB.Ready then
                    EHChar.DB.Connect()
                end
            end)
        end
    end

    function EHChar.DB.Connection:onDisconnected()
        EHChar.DB.Ready = false
        EHChar.DB.Connecting = false
        dbPrint("MySQL Verbindung verloren.")

        if cfg.AutoReconnect then
            local delay = tonumber(cfg.ReconnectDelay) or 10
            timer.Simple(delay, function()
                if EHChar and EHChar.DB and not EHChar.DB.Ready then
                    EHChar.DB.Connect()
                end
            end)
        end
    end

    EHChar.DB.Connection:connect()
end

function EHChar.DB.GetCharacters(ply, callback)
    if EHChar.DB.IsMySQL and not mysqlReady() then
        if callback then callback({}) end
        return
    end

    local sid = esc(ply:SteamID64())

    EHChar.DB.Query("SELECT * FROM eh_characters WHERE steamid64 = '" .. sid .. "' ORDER BY slot ASC;", function(data)
        if callback then callback(data or {}) end
    end)
end

function EHChar.DB.GetCharacterBySlot(ply, slot, callback)
    if EHChar.DB.IsMySQL and not mysqlReady() then
        if callback then callback(nil) end
        return
    end

    local sid = esc(ply:SteamID64())
    slot = math.Clamp(tonumber(slot) or 1, 1, EHChar.Config.MaxSlots)

    EHChar.DB.Query("SELECT * FROM eh_characters WHERE steamid64 = '" .. sid .. "' AND slot = " .. slot .. " LIMIT 1;", function(data)
        if callback then callback(data and data[1] or nil) end
    end)
end

function EHChar.DB.SaveCharacter(ply, data, callback)
    if EHChar.DB.IsMySQL and not mysqlReady() then
        dbPrint("Charakter kann nicht gespeichert werden: MySQL ist nicht bereit.")
        if callback then callback(nil) end
        return
    end

    local sid = esc(ply:SteamID64())
    local slot = math.Clamp(tonumber(data.slot) or 1, 1, EHChar.Config.MaxSlots)
    local name = esc(data.char_name)
    local gender = esc(data.gender)
    local model = esc(data.model)
    local skin = math.Clamp(tonumber(data.skin) or 0, 0, 32)
    local bodygroups = esc(util.TableToJSON(data.bodygroups or {}, false) or "{}")
    local now = os.time()

    EHChar.DB.GetCharacterBySlot(ply, slot, function(existing)
        if existing then
            local id = tonumber(existing.id)
            EHChar.DB.Query("UPDATE eh_characters SET char_name = '" .. name .. "', gender = '" .. gender .. "', model = '" .. model .. "', skin = " .. skin .. ", bodygroups = '" .. bodygroups .. "', updated_at = " .. now .. " WHERE id = " .. id .. ";", function()
                if callback then callback(id) end
            end)
        else
            EHChar.DB.Query("INSERT INTO eh_characters (steamid64, slot, char_name, gender, model, skin, bodygroups, created_at, updated_at) VALUES ('" .. sid .. "', " .. slot .. ", '" .. name .. "', '" .. gender .. "', '" .. model .. "', " .. skin .. ", '" .. bodygroups .. "', " .. now .. ", " .. now .. ");", function()
                EHChar.DB.GetCharacterBySlot(ply, slot, function(newChar)
                    if callback then callback(newChar and tonumber(newChar.id) or nil) end
                end)
            end)
        end
    end)
end

function EHChar.DB.SaveJobData(characterID, jobID, rankName, jobModel, loadout)
    if EHChar.DB.IsMySQL and not mysqlReady() then
        dbPrint("Jobdaten koennen nicht gespeichert werden: MySQL ist nicht bereit.")
        return
    end

    characterID = tonumber(characterID)
    if not characterID then return end

    local serverID = esc(EHChar.Config.ServerID)
    jobID = esc(jobID)
    rankName = esc(rankName)
    jobModel = esc(jobModel)
    loadout = esc(util.TableToJSON(loadout or {}, false) or "[]")
    local now = os.time()

    EHChar.DB.Query("SELECT * FROM eh_character_jobs WHERE character_id = " .. characterID .. " AND server_id = '" .. serverID .. "' LIMIT 1;", function(data)
        local existing = data and data[1]

        if existing then
            EHChar.DB.Query("UPDATE eh_character_jobs SET job_id = '" .. jobID .. "', rank_name = '" .. rankName .. "', job_model = '" .. jobModel .. "', loadout = '" .. loadout .. "', updated_at = " .. now .. " WHERE id = " .. tonumber(existing.id) .. ";")
        else
            EHChar.DB.Query("INSERT INTO eh_character_jobs (character_id, server_id, job_id, rank_name, job_model, loadout, updated_at) VALUES (" .. characterID .. ", '" .. serverID .. "', '" .. jobID .. "', '" .. rankName .. "', '" .. jobModel .. "', '" .. loadout .. "', " .. now .. ");")
        end
    end)
end

function EHChar.DB.StartConnectTimer()
    timer.Simple(2, function()
        if EHChar and EHChar.DB then
            EHChar.DB.Connect()
        end
    end)
end

hook.Add("Initialize", "EHChar_DB_Connect", function()
    EHChar.DB.StartConnectTimer()
end)

-- Wichtig fuer Force-Loader: Falls diese Datei nach Initialize geladen wird,
-- startet die SQL-Verbindung trotzdem.
EHChar.DB.StartConnectTimer()
