EHChar = EHChar or {}
EHChar.Config = EHChar.Config or {}

-- Auf Server 1 Metro: "metro"
-- Auf Server 2 Stadt/DarkRP: "stadt"
EHChar.Config.ServerID = "metro"
EHChar.Config.MaxSlots = 3

-- Fuer echte 2-Server-Synchronisierung MUSS MySQL true sein.
-- SQLite ist nur fuer einen Testserver gedacht.
EHChar.Config.Database = {
    UseMySQL = false,
    Host = "127.0.0.1",
    Port = 3306,
    Database = "gmod_chars",
    Username = "gmod_user",
    Password = "change_me"
}

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

EHChar.Config.Genders = {"Maennlich", "Weiblich", "Divers"}

-- Nur auf ServerID "stadt" verwenden.
EHChar.Config.DarkRPJobs = {
    Enabled = true,
    Jobs = {
        police = {
            title = "Polizei",
            teamName = "Polizei",
            ranks = {
                ["Anwaerter"] = {model = "models/player/police.mdl", loadout = {"weapon_stunstick", "weapon_pistol"}},
                ["Officer"] = {model = "models/player/police.mdl", loadout = {"weapon_stunstick", "weapon_pistol", "arrest_stick", "unarrest_stick"}},
                ["Sergeant"] = {model = "models/player/police.mdl", loadout = {"weapon_stunstick", "weapon_pistol", "weapon_smg1", "arrest_stick", "unarrest_stick"}}
            }
        },
        military = {
            title = "Militaer",
            teamName = "Militaer",
            ranks = {
                ["Rekrut"] = {model = "models/player/riot.mdl", loadout = {"weapon_pistol"}},
                ["Soldat"] = {model = "models/player/riot.mdl", loadout = {"weapon_pistol", "weapon_smg1"}},
                ["Commander"] = {model = "models/player/riot.mdl", loadout = {"weapon_pistol", "weapon_smg1", "weapon_shotgun"}}
            }
        },
        medic = {
            title = "Medic",
            teamName = "Medic",
            ranks = {
                ["Sanitaeter"] = {model = "models/player/kleiner.mdl", loadout = {"weapon_medkit"}}
            }
        }
    }
}
