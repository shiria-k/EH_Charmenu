EHChar = EHChar or {}
EHChar.ClientCharacters = EHChar.ClientCharacters or {}

local function notify(text)
    chat.AddText(Color(80, 180, 255), "[EHChar] ", Color(255, 255, 255), text)
end

net.Receive("EHChar_Notify", function() notify(net.ReadString()) end)
net.Receive("EHChar_SendCharacters", function() EHChar.ClientCharacters = net.ReadTable() or {} end)

local function getCharacterBySlot(slot)
    for _, char in ipairs(EHChar.ClientCharacters or {}) do
        if tonumber(char.slot) == tonumber(slot) then return char end
    end
    return nil
end

local function modelChoices()
    local choices = {}
    local used = {}

    local function addChoice(name, mdl)
        name = tostring(name or "Unbenannt")
        mdl = tostring(mdl or "")
        if mdl == "" then return end

        local key = string.lower(mdl)
        if used[key] then return end
        used[key] = true

        choices[#choices + 1] = {name = name, model = mdl}
    end

    for name, mdl in pairs(EHChar.Config.AllowedModels or {}) do
        addChoice(name, mdl)
    end

    if EHChar.Config.UseAllRegisteredPlayerModels and player_manager and player_manager.AllValidModels then
        for name, mdl in pairs(player_manager.AllValidModels()) do
            addChoice(name, mdl)
        end
    end

    table.SortByMember(choices, "name", true)
    return choices
end

local function decodeBodygroups(value)
    if istable(value) then return value end
    return util.JSONToTable(tostring(value or "{}")) or {}
end

local function getBodygroupName(ent, id)
    if not IsValid(ent) then return "Bodygroup " .. id end
    local name = ent:GetBodygroupName(id)
    if not name or name == "" then return "Bodygroup " .. id end
    return name
end

local function applyBodygroupsToPreview(ent, bodygroups)
    if not IsValid(ent) then return end
    for id, value in pairs(bodygroups or {}) do
        ent:SetBodygroup(tonumber(id) or 0, tonumber(value) or 0)
    end
end

local function buildClothingControls(parent, preview, bodygroups, onChanged)
    parent:Clear()

    if not IsValid(preview) or not IsValid(preview.Entity) then
        local label = vgui.Create("DLabel", parent)
        label:Dock(TOP)
        label:SetTall(30)
        label:SetTextColor(Color(230, 230, 230))
        label:SetText("Kein Model geladen.")
        return
    end

    local ent = preview.Entity
    local found = false

    for id = 0, ent:GetNumBodyGroups() - 1 do
        local count = ent:GetBodygroupCount(id)
        if count and count > 1 then
            found = true

            local slider = vgui.Create("DNumSlider", parent)
            slider:Dock(TOP)
            slider:DockMargin(0, 4, 0, 0)
            slider:SetTall(42)
            slider:SetText(getBodygroupName(ent, id))
            slider:SetMin(0)
            slider:SetMax(count - 1)
            slider:SetDecimals(0)
            slider:SetValue(tonumber(bodygroups[tostring(id)] or bodygroups[id] or 0) or 0)

            slider.OnValueChanged = function(_, value)
                local rounded = math.floor(value)
                bodygroups[tostring(id)] = rounded
                ent:SetBodygroup(id, rounded)
                if onChanged then onChanged(bodygroups) end
            end
        end
    end

    if not found then
        local label = vgui.Create("DLabel", parent)
        label:Dock(TOP)
        label:SetTall(50)
        label:SetWrap(true)
        label:SetTextColor(Color(230, 230, 230))
        label:SetText("Dieses Model hat keine Bodygroups/Kleidungsteile. Nimm ein anderes Model oder fuege Clothing-/Bodygroup-Models hinzu.")
    end
end

local function createEditor(parent, slot, existing)
    parent:Clear()

    local root = vgui.Create("DPanel", parent)
    root:Dock(FILL)
    root:DockMargin(8, 8, 8, 8)
    root.Paint = nil

    local title = vgui.Create("DLabel", root)
    title:Dock(TOP)
    title:SetTall(32)
    title:SetText(existing and ("Slot " .. slot .. " bearbeiten") or ("Slot " .. slot .. " erstellen"))
    title:SetFont("DermaLarge")
    title:SetTextColor(color_white)

    local content = vgui.Create("DPanel", root)
    content:Dock(FILL)
    content.Paint = nil

    local left = vgui.Create("DScrollPanel", content)
    left:Dock(LEFT)
    left:SetWide(310)
    left:DockMargin(0, 8, 10, 0)

    local right = vgui.Create("DPanel", content)
    right:Dock(FILL)
    right:DockMargin(0, 8, 0, 0)
    right.Paint = nil

    local nameEntry = vgui.Create("DTextEntry", left)
    nameEntry:Dock(TOP)
    nameEntry:DockMargin(0, 0, 0, 8)
    nameEntry:SetTall(30)
    nameEntry:SetPlaceholderText("Charaktername")
    nameEntry:SetValue(existing and tostring(existing.char_name or "") or "")

    local genderBox = vgui.Create("DComboBox", left)
    genderBox:Dock(TOP)
    genderBox:DockMargin(0, 0, 0, 8)
    genderBox:SetTall(30)
    genderBox:SetValue(existing and tostring(existing.gender or "Geschlecht") or "Geschlecht")
    for _, gender in ipairs(EHChar.Config.Genders) do genderBox:AddChoice(gender) end

    local modelBox = vgui.Create("DComboBox", left)
    modelBox:Dock(TOP)
    modelBox:DockMargin(0, 0, 0, 8)
    modelBox:SetTall(30)
    modelBox:SetValue("Model / Grundkoerper auswaehlen")

    local selectedModel = existing and tostring(existing.model or "") or nil
    local choices = modelChoices()
    for _, choice in ipairs(choices) do
        modelBox:AddChoice(choice.name, choice.model)
        if selectedModel == choice.model then modelBox:SetValue(choice.name) end
    end

    if not selectedModel or selectedModel == "" then
        local first = choices[1]
        selectedModel = first and first.model or "models/player/group01/male_01.mdl"
    end

    local preview = vgui.Create("DModelPanel", right)
    preview:Dock(TOP)
    preview:SetTall(300)
    preview:SetModel(selectedModel)
    preview:SetFOV(38)
    preview:SetCamPos(Vector(60, 0, 62))
    preview:SetLookAt(Vector(0, 0, 45))
    preview.LayoutEntity = function(_, ent)
        ent:SetAngles(Angle(0, RealTime() * 20 % 360, 0))
    end

    local skinSlider = vgui.Create("DNumSlider", left)
    skinSlider:Dock(TOP)
    skinSlider:DockMargin(0, 0, 0, 8)
    skinSlider:SetTall(45)
    skinSlider:SetText("Skin / Variante")
    skinSlider:SetMin(0)
    skinSlider:SetMax(8)
    skinSlider:SetDecimals(0)
    skinSlider:SetValue(existing and tonumber(existing.skin) or 0)

    local bodygroups = decodeBodygroups(existing and existing.bodygroups or "{}")

    local clothingTitle = vgui.Create("DLabel", left)
    clothingTitle:Dock(TOP)
    clothingTitle:DockMargin(0, 8, 0, 4)
    clothingTitle:SetTall(24)
    clothingTitle:SetText("Kleidung / Bodygroups")
    clothingTitle:SetTextColor(color_white)
    clothingTitle:SetFont("DermaDefaultBold")

    local clothingPanel = vgui.Create("DScrollPanel", left)
    clothingPanel:Dock(TOP)
    clothingPanel:SetTall(210)

    local function refreshPreview()
        if IsValid(preview.Entity) then
            preview.Entity:SetSkin(math.floor(skinSlider:GetValue()))
            applyBodygroupsToPreview(preview.Entity, bodygroups)
        end
    end

    local function rebuildClothing()
        timer.Simple(0, function()
            if not IsValid(clothingPanel) or not IsValid(preview) then return end
            buildClothingControls(clothingPanel, preview, bodygroups, refreshPreview)
            refreshPreview()
        end)
    end

    skinSlider.OnValueChanged = function(_, value)
        if IsValid(preview.Entity) then preview.Entity:SetSkin(math.floor(value)) end
    end

    modelBox.OnSelect = function(_, _, _, model)
        selectedModel = model
        bodygroups = {}
        preview:SetModel(model)
        rebuildClothing()
    end

    rebuildClothing()

    local hint = vgui.Create("DLabel", left)
    hint:Dock(TOP)
    hint:DockMargin(0, 8, 0, 8)
    hint:SetTall(60)
    hint:SetWrap(true)
    hint:SetTextColor(Color(210, 210, 210))
    hint:SetText("Die Kleidung wird ueber Skin und Bodygroups gespeichert. Beide Server brauchen dieselben Player-Models und Clothing-Addons.")

    local save = vgui.Create("DButton", left)
    save:Dock(TOP)
    save:DockMargin(0, 4, 0, 0)
    save:SetTall(38)
    save:SetText("Charakter + Kleidung speichern")
    save.DoClick = function()
        local _, model = modelBox:GetSelected()
        model = model or selectedModel or ""
        net.Start("EHChar_SaveCharacter")
            net.WriteTable({
                slot = slot,
                char_name = nameEntry:GetValue(),
                gender = genderBox:GetValue(),
                model = model,
                skin = math.floor(skinSlider:GetValue()),
                bodygroups = bodygroups
            })
        net.SendToServer()
    end
end

local function createJobPanel(parent)
    parent:Clear()
    local title = vgui.Create("DLabel", parent)
    title:Dock(TOP)
    title:SetTall(32)
    title:SetFont("DermaLarge")
    title:SetTextColor(color_white)
    title:SetText("Stadt-Jobdaten")

    if EHChar.Config.ServerID ~= "stadt" then
        local label = vgui.Create("DLabel", parent)
        label:Dock(TOP)
        label:SetTall(40)
        label:SetTextColor(Color(220, 220, 220))
        label:SetText("Jobdaten sind nur auf dem Stadt-/DarkRP-Server aktiv.")
        return
    end

    local jobBox = vgui.Create("DComboBox", parent)
    jobBox:Dock(TOP)
    jobBox:DockMargin(0, 8, 0, 0)
    jobBox:SetTall(30)
    jobBox:SetValue("Job auswaehlen")
    for id, job in pairs(EHChar.Config.DarkRPJobs.Jobs or {}) do jobBox:AddChoice(job.title or id, id) end

    local rankBox = vgui.Create("DComboBox", parent)
    rankBox:Dock(TOP)
    rankBox:DockMargin(0, 8, 0, 0)
    rankBox:SetTall(30)
    rankBox:SetValue("Rang auswaehlen")

    jobBox.OnSelect = function(_, _, _, jobID)
        rankBox:Clear()
        rankBox:SetValue("Rang auswaehlen")
        local job = EHChar.Config.DarkRPJobs.Jobs[jobID]
        if not job then return end
        for rankName in pairs(job.ranks or {}) do rankBox:AddChoice(rankName, rankName) end
    end

    local apply = vgui.Create("DButton", parent)
    apply:Dock(TOP)
    apply:DockMargin(0, 12, 0, 0)
    apply:SetTall(36)
    apply:SetText("Job / Rang anwenden")
    apply.DoClick = function()
        local _, jobID = jobBox:GetSelected()
        local _, rankName = rankBox:GetSelected()
        if not jobID or not rankName then notify("Bitte Job und Rang auswaehlen.") return end
        net.Start("EHChar_SaveJobData")
            net.WriteString(jobID)
            net.WriteString(rankName)
        net.SendToServer()
    end
end

function EHChar.OpenMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(900, 620)
    frame:Center()
    frame:SetTitle("EH Character Menu")
    frame:MakePopup()

    local left = vgui.Create("DPanel", frame)
    left:Dock(LEFT)
    left:SetWide(260)
    left:DockMargin(8, 8, 8, 8)

    local right = vgui.Create("DPanel", frame)
    right:Dock(FILL)
    right:DockMargin(0, 8, 8, 8)
    right.Paint = function(_, w, h) surface.SetDrawColor(35, 35, 35, 240) surface.DrawRect(0, 0, w, h) end

    local header = vgui.Create("DLabel", left)
    header:Dock(TOP)
    header:SetTall(36)
    header:SetFont("DermaLarge")
    header:SetText("Charaktere")
    header:SetTextColor(color_white)

    for slot = 1, EHChar.Config.MaxSlots do
        local char = getCharacterBySlot(slot)
        local btn = vgui.Create("DButton", left)
        btn:Dock(TOP)
        btn:DockMargin(0, 8, 0, 0)
        btn:SetTall(52)
        btn:SetText(char and ("Slot " .. slot .. ": " .. tostring(char.char_name)) or ("Slot " .. slot .. ": leer"))
        btn.DoClick = function()
            if char then
                net.Start("EHChar_SelectCharacter")
                    net.WriteUInt(slot, 3)
                net.SendToServer()
            else
                createEditor(right, slot, nil)
            end
        end

        local edit = vgui.Create("DButton", left)
        edit:Dock(TOP)
        edit:DockMargin(0, 2, 0, 0)
        edit:SetTall(26)
        edit:SetText(char and ("Kleidung / Aussehen bearbeiten") or ("Slot " .. slot .. " erstellen"))
        edit.DoClick = function() createEditor(right, slot, getCharacterBySlot(slot)) end
    end

    local refresh = vgui.Create("DButton", left)
    refresh:Dock(BOTTOM)
    refresh:SetTall(32)
    refresh:SetText("Aktualisieren")
    refresh.DoClick = function()
        net.Start("EHChar_RequestCharacters")
        net.SendToServer()
        timer.Simple(0.3, function()
            if IsValid(frame) then frame:Close() EHChar.OpenMenu() end
        end)
    end

    local jobs = vgui.Create("DButton", left)
    jobs:Dock(BOTTOM)
    jobs:DockMargin(0, 8, 0, 0)
    jobs:SetTall(32)
    jobs:SetText("Jobdaten Stadt")
    jobs.DoClick = function() createJobPanel(right) end

    createEditor(right, 1, getCharacterBySlot(1))
end

net.Receive("EHChar_OpenMenu", function() EHChar.OpenMenu() end)
concommand.Add("eh_chars", function()
    net.Start("EHChar_RequestCharacters")
    net.SendToServer()
    timer.Simple(0.2, EHChar.OpenMenu)
end)
