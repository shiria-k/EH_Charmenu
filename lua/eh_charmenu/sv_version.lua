EHChar = EHChar or {}
EHChar.Version = EHChar.Version or "0.1.3"
EHChar.Update = EHChar.Update or {}

local VERSION_URL = "https://raw.githubusercontent.com/shiria-k/EH_Charmenu/main/version.txt"
local CHECK_INTERVAL = 600

local function upPrint(text)
    print("[EHChar Update] " .. tostring(text))
end

local function esc(value)
    value = tostring(value or "")

    if EHChar.DB and EHChar.DB.IsMySQL and EHChar.DB.Connection and EHChar.DB.Ready then
        return EHChar.DB.Connection:escape(value)
    end

    return sql.SQLStr(value, true)
end

local function isMysql()
    return EHChar.DB and EHChar.DB.IsMySQL
end

function EHChar.Update.InitTable()
    if not EHChar.DB or not EHChar.DB.Query then return end

    if isMysql() then
        EHChar.DB.Query([[
            CREATE TABLE IF NOT EXISTS eh_charmenu_meta (
                meta_key VARCHAR(64) NOT NULL,
                meta_value TEXT NOT NULL,
                updated_at INT NOT NULL,
                PRIMARY KEY (meta_key)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
    else
        EHChar.DB.Query([[
            CREATE TABLE IF NOT EXISTS eh_charmenu_meta (
                meta_key TEXT PRIMARY KEY,
                meta_value TEXT NOT NULL,
                updated_at INTEGER NOT NULL
            );
        ]])
    end
end

function EHChar.Update.SetMeta(key, value)
    if not EHChar.DB or not EHChar.DB.Query then return end

    local k = esc(key)
    local v = esc(value)
    local now = os.time()

    if isMysql() then
        EHChar.DB.Query("INSERT INTO eh_charmenu_meta (meta_key, meta_value, updated_at) VALUES ('" .. k .. "', '" .. v .. "', " .. now .. ") ON DUPLICATE KEY UPDATE meta_value = VALUES(meta_value), updated_at = VALUES(updated_at);")
    else
        EHChar.DB.Query("REPLACE INTO eh_charmenu_meta (meta_key, meta_value, updated_at) VALUES ('" .. k .. "', '" .. v .. "', " .. now .. ");")
    end
end

function EHChar.Update.SyncInstalledVersion()
    EHChar.Update.InitTable()
    EHChar.Update.SetMeta("installed_version", EHChar.Version or "unknown")
    EHChar.Update.SetMeta("last_server_start", os.date("%Y-%m-%d %H:%M:%S"))
    upPrint("Installierte Version in SQL gespeichert: " .. tostring(EHChar.Version))
end

local function parseVersion(body)
    body = tostring(body or "")
    body = string.Trim(body)
    body = string.match(body, "([%w%._%-]+)") or body
    return body
end

function EHChar.Update.CheckRemoteVersion()
    if not http or not http.Fetch then
        upPrint("http.Fetch nicht verfuegbar, Updatecheck uebersprungen.")
        return
    end

    http.Fetch(VERSION_URL, function(body)
        local remote = parseVersion(body)
        local installed = tostring(EHChar.Version or "unknown")

        EHChar.Update.SetMeta("repo_version", remote)
        EHChar.Update.SetMeta("last_update_check", os.date("%Y-%m-%d %H:%M:%S"))

        if remote ~= "" and remote ~= installed then
            EHChar.Update.SetMeta("update_available", "1")
            upPrint("Neue Repo-Version gefunden: " .. remote .. " | installiert: " .. installed)
            upPrint("Hinweis: Pterodactyl muss die Dateien per git pull oder Neuinstallation aktualisieren. SQL wurde markiert.")
        else
            EHChar.Update.SetMeta("update_available", "0")
            upPrint("Repo-Version aktuell: " .. installed)
        end
    end, function(err)
        EHChar.Update.SetMeta("last_update_error", tostring(err))
        upPrint("Updatecheck fehlgeschlagen: " .. tostring(err))
    end)
end

hook.Add("Initialize", "EHChar_Update_Init", function()
    timer.Simple(5, function()
        if not EHChar.DB or not EHChar.DB.Query then
            upPrint("Datenbankmodul nicht geladen, Versions-Sync abgebrochen.")
            return
        end

        EHChar.Update.SyncInstalledVersion()
        EHChar.Update.CheckRemoteVersion()
    end)

    timer.Create("EHChar_Update_CheckTimer", CHECK_INTERVAL, 0, function()
        if EHChar and EHChar.Update then
            EHChar.Update.CheckRemoteVersion()
        end
    end)
end)
