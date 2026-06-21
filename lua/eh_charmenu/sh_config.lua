EHChar = EHChar or {}
EHChar.Config = EHChar.Config or {}

-- =========================================================
-- EH_Charmenu Haupt-Config
-- =========================================================

EHChar.Config.ServerID = "metro"
EHChar.Config.MaxSlots = 3
EHChar.Config.UseAllRegisteredPlayerModels = true

EHChar.Config.WorkshopDownloads = {
    Enabled = true,
    IDs = {
        "504945881",
        "3307292172"
    }
}

-- =========================================================
-- Datenbank
-- =========================================================

-- WICHTIG: Dieses Repo ist oeffentlich.
-- Trage echte SQL-Daten erst nach dem Upload auf dem Server ein.
EHChar.Config.Database = {
    UseMySQL = true,
    Host = "DEINE_SQL_IP_ODER_HOST",
    Port = 3306,
    Database = "DEINE_DATENBANK",
    Username = "DEIN_SQL_USER",
    Password = "DEIN_SQL_PASSWORT",

    AutoReconnect = true,
    ReconnectDelay = 10,
    StrictMySQL = true
}

EHChar.Config.DarkRPJobs = EHChar.Config.DarkRPJobs or {
    Enabled = false,
    Jobs = {}
}

-- =========================================================
-- Fallback-PlayerModels
-- =========================================================

EHChar.Config.AllowedModels = {
    ["Mann 01"] = "models/player/group01/male_01.mdl",
    ["Mann 02"] = "models/player/group01/male_02.mdl",
    ["Mann 03"] = "models/player/group01/male_03.mdl",
    ["Mann 04"] = "models/player/group01/male_04.mdl",
    ["Mann 05"] = "models/player/group01/male_05.mdl",
    ["Mann 06"] = "models/player/group01/male_06.mdl",
    ["Mann 07"] = "models/player/group01/male_07.mdl",
    ["Mann 08"] = "models/player/group01/male_08.mdl",
    ["Mann 09"] = "models/player/group01/male_09.mdl",
    ["Frau 01"] = "models/player/group01/female_01.mdl",
    ["Frau 02"] = "models/player/group01/female_02.mdl",
    ["Frau 03"] = "models/player/group01/female_03.mdl",
    ["Frau 04"] = "models/player/group01/female_04.mdl",
    ["Frau 06"] = "models/player/group01/female_06.mdl",
    ["Frau 07"] = "models/player/group01/female_07.mdl"
}

EHChar.Config.Genders = {
    "Maennlich",
    "Weiblich",
    "Divers"
}
