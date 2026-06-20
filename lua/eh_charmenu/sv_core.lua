EHChar = EHChar or {}

local function notify(ply, text)
    net.Start("EHChar_Notify")
        net.WriteString(text)
    net.Send(ply)
end

function EHChar.GetRegisteredPlayerModels()
    local result = {}

    for name, mdl in pairs(EHChar.Config.AllowedModels or {}) do
        result[name] = mdl
    end

    if EHChar.Config.UseAllRegisteredPlayerModels and player_manager and player_manager.AllValidModels then
        for name, mdl in pairs(player_manager.AllValidModels()) do
            result[name] = mdl
        end
    end

    return result
end

local function isAllowedModel(model)
    model = tostring(model or "")

    for _, mdl in pairs(EHChar.Config.AllowedModels or {}) do
        if string.lower(mdl) == string.lower(model) then return true end
    end

    if EHChar.Config.UseAllRegisteredPlayerModels and player_manager and player_manager.AllValidModels then
        for _, mdl in pairs(player_manager.AllValidModels()) do
            if string.lower(mdl) == string.lower(model) then return true end
        end
    end

    return false
end

local function isAllowedGender(gender)
    for _, value in ipairs(EHChar.Config.Genders) do
        if value == gender then return true end
    end
    return false
end

function EHChar.ApplyCharacter(ply, char)
    if not IsValid(ply) or not char then return end

    ply.EHCharID = tonumber(char.id)
    ply.EHCharSlot = tonumber(char.slot)

    local rpName = tostring(char.char_name or "Unbekannt")
    ply:SetNWString("EHChar_Name", rpName)
    ply:SetNWString("EHChar_Gender", tostring(char.gender or ""))
    ply:SetNWInt("EHChar_ID", ply.EHCharID or 0)

    if DarkRP and ply.setDarkRPVar then
        ply:setDarkRPVar("rpname", rpName)
    end

    local model = tostring(char.model or "")
    if util.IsValidModel(model) then ply:SetModel(model) end
    ply:SetSkin(tonumber(char.skin) or 0)

    local bodygroups = util.JSONToTable(char.bodygroups or "{}") or {}
    for id, value in pairs(bodygroups) do
        ply:SetBodygroup(tonumber(id) or 0, tonumber(value) or 0)
    end
end

function EHChar.OpenMenu(ply)
    if not IsValid(ply) then return end
    EHChar.DB.GetCharacters(ply, function(chars)
        net.Start("EHChar_SendCharacters")
            net.WriteTable(chars or {})
        net.Send(ply)
        net.Start("EHChar_OpenMenu")
        net.Send(ply)
    end)
end

concommand.Add("eh_chars", function(ply)
    EHChar.OpenMenu(ply)
end)

hook.Add("PlayerSay", "EHChar_ChatCommand", function(ply, text)
    text = string.lower(string.Trim(text or ""))
    if text == "/chars" or text == "!chars" or text == "/char" then
        EHChar.OpenMenu(ply)
        return ""
    end
end)

hook.Add("PlayerInitialSpawn", "EHChar_OpenOnJoin", function(ply)
    timer.Simple(3, function()
        if IsValid(ply) then EHChar.OpenMenu(ply) end
    end)
end)

hook.Add("PlayerSpawn", "EHChar_ReapplyCharacter", function(ply)
    if not ply.EHCharSlot then return end
    timer.Simple(0.2, function()
        if not IsValid(ply) then return end
        EHChar.DB.GetCharacterBySlot(ply, ply.EHCharSlot, function(char)
            EHChar.ApplyCharacter(ply, char)
        end)
    end)
end)

net.Receive("EHChar_RequestCharacters", function(_, ply)
    EHChar.DB.GetCharacters(ply, function(chars)
        net.Start("EHChar_SendCharacters")
            net.WriteTable(chars or {})
        net.Send(ply)
    end)
end)

net.Receive("EHChar_SaveCharacter", function(_, ply)
    local data = net.ReadTable() or {}
    data.slot = math.Clamp(tonumber(data.slot) or 1, 1, EHChar.Config.MaxSlots)
    data.char_name = string.Trim(tostring(data.char_name or ""))
    data.gender = tostring(data.gender or "")
    data.model = tostring(data.model or "")
    data.skin = tonumber(data.skin) or 0
    data.bodygroups = istable(data.bodygroups) and data.bodygroups or {}

    if #data.char_name < 3 or #data.char_name > 32 then notify(ply, "Name muss 3 bis 32 Zeichen haben.") return end
    if not isAllowedGender(data.gender) then notify(ply, "Ungueltiges Geschlecht.") return end
    if not isAllowedModel(data.model) then notify(ply, "Dieses Model ist nicht erlaubt oder auf dem Server nicht installiert.") return end

    EHChar.DB.SaveCharacter(ply, data, function()
        notify(ply, "Charakter gespeichert.")
        EHChar.DB.GetCharacterBySlot(ply, data.slot, function(char)
            EHChar.ApplyCharacter(ply, char)
            EHChar.OpenMenu(ply)
        end)
    end)
end)

net.Receive("EHChar_SelectCharacter", function(_, ply)
    local slot = math.Clamp(net.ReadUInt(3) or 1, 1, EHChar.Config.MaxSlots)
    EHChar.DB.GetCharacterBySlot(ply, slot, function(char)
        if not char then notify(ply, "Dieser Slot ist leer.") return end
        EHChar.ApplyCharacter(ply, char)
        notify(ply, "Charakter ausgewaehlt: " .. tostring(char.char_name))
    end)
end)

net.Receive("EHChar_SaveJobData", function(_, ply)
    if EHChar.Config.ServerID ~= "stadt" then notify(ply, "Jobdaten sind nur auf dem Stadtserver aktiv.") return end
    if not EHChar.Config.DarkRPJobs.Enabled then notify(ply, "Jobdaten sind deaktiviert.") return end
    if not ply.EHCharID then notify(ply, "Bitte zuerst Charakter auswaehlen.") return end

    local jobID = net.ReadString()
    local rankName = net.ReadString()
    local job = EHChar.Config.DarkRPJobs.Jobs[jobID]
    if not job then notify(ply, "Ungueltiger Job.") return end
    local rank = job.ranks[rankName]
    if not rank then notify(ply, "Ungueltiger Rang.") return end

    if DarkRP and job.teamName then
        for teamID, teamData in pairs(RPExtraTeams or {}) do
            if teamData.name == job.teamName then
                ply:changeTeam(teamID, true, true)
                break
            end
        end
    end

    if rank.model and util.IsValidModel(rank.model) then ply:SetModel(rank.model) end
    for _, weaponClass in ipairs(rank.loadout or {}) do
        if weaponClass and weaponClass ~= "" then ply:Give(weaponClass) end
    end

    EHChar.DB.SaveJobData(ply.EHCharID, jobID, rankName, rank.model or "", rank.loadout or {})
    notify(ply, "Job gesetzt: " .. tostring(job.title) .. " - " .. tostring(rankName))
end)
