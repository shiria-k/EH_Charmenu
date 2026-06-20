EHChar = EHChar or {}
EHChar.Config = EHChar.Config or {}

-- =========================================================
-- EH_Charmenu Haupt-Config
-- =========================================================

-- Server 1 Metro: "metro"
-- Server 2 Stadt / DarkRP: "stadt"
EHChar.Config.ServerID = "metro"

-- Anzahl Charakterplaetze pro Spieler
EHChar.Config.MaxSlots = 3

-- Automatisch alle registrierten Workshop-PlayerModels im Menue anzeigen
-- Funktioniert mit PlayerModel-Packs, sobald sie auf Server/Client geladen sind.
EHChar.Config.UseAllRegisteredPlayerModels = true

-- Workshop-Downloads fuer Spieler beim Joinen.
-- Hier kommen nur Steam Workshop IDs rein.
-- Beispiel-Link: https://steamcommunity.com/sharedfiles/filedetails/?id=123456789
-- Dann ist die ID: "123456789"
EHChar.Config.WorkshopDownloads = {
    Enabled = true,
    IDs = {
        -- Hier deine IDs eintragen, z.B.:
        -- "123456789",
        -- "987654321"
    }
}

-- =========================================================
-- Datenbank
-- =========================================================

-- SQLite ist nur fuer Tests auf einem einzelnen Server.
-- Fuer Server 1 + Server 2 zusammen muss UseMySQL = true sein.
EHChar.Config.Database = {
    UseMySQL = false,
    Host = "127.0.0.1",
    Port = 3306,
    Database = "gmod_chars",
    Username = "gmod_user",
    Password = "change_me"
}

-- =========================================================
-- Fallback-PlayerModels
-- =========================================================

-- Diese Models sind immer im Menue, auch wenn keine Workshop-Models geladen sind.
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

-- Geschlechter im Charakter-Menue
EHChar.Config.Genders = {
    "Maennlich",
    "Weiblich",
    "Divers"
}

-- =========================================================
-- DarkRP Jobs fuer Server 2 Stadt
-- =========================================================

-- Wichtig:
-- teamName muss genau so heissen wie dein DarkRP-Job.
-- Wenn dein Job in DarkRP z.B. "Polizist" heisst,
-- muss hier teamName = "Polizist" stehen.
EHChar.Config.DarkRPJobs = {
    Enabled = true,
    Jobs = {
        police = {
            title = "Polizei",
            teamName = "Polizei",
            ranks = {
                ["Anwaerter"] = {
                    model = "models/player/police.mdl",
                    loadout = {
                        "weapon_stunstick",
                        "weapon_pistol"
                    }
                },
                ["Officer"] = {
                    model = "models/player/police.mdl",
                    loadout = {
                        "weapon_stunstick",
                        "weapon_pistol",
                        "arrest_stick",
                        "unarrest_stick"
                    }
                },
                ["Sergeant"] = {
                    model = "models/player/police.mdl",
                    loadout = {
                        "weapon_stunstick",
                        "weapon_pistol",
                        "weapon_smg1",
                        "arrest_stick",
                        "unarrest_stick"
                    }
                }
            }
        },

        military = {
            title = "Militaer",
            teamName = "Militaer",
            ranks = {
                ["Rekrut"] = {
                    model = "models/player/riot.mdl",
                    loadout = {
                        "weapon_pistol"
                    }
                },
                ["Soldat"] = {
                    model = "models/player/riot.mdl",
                    loadout = {
                        "weapon_pistol",
                        "weapon_smg1"
                    }
                },
                ["Commander"] = {
                    model = "models/player/riot.mdl",
                    loadout = {
                        "weapon_pistol",
                        "weapon_smg1",
                        "weapon_shotgun"
                    }
                }
            }
        },

        quarantine = {
            title = "Quarantaene-Einheit",
            teamName = "Quarantaene-Einheit",
            ranks = {
                ["Helfer"] = {
                    model = "models/player/group03/male_07.mdl",
                    loadout = {
                        "weapon_pistol"
                    }
                },
                ["Seuchenschutz"] = {
                    model = "models/player/riot.mdl",
                    loadout = {
                        "weapon_pistol",
                        "weapon_smg1"
                    }
                },
                ["Einsatzleiter"] = {
                    model = "models/player/riot.mdl",
                    loadout = {
                        "weapon_pistol",
                        "weapon_smg1",
                        "weapon_shotgun"
                    }
                }
            }
        },

        medic = {
            title = "Medic",
            teamName = "Medic",
            ranks = {
                ["Sanitaeter"] = {
                    model = "models/player/kleiner.mdl",
                    loadout = {
                        "weapon_medkit"
                    }
                }
            }
        }
    }
}
