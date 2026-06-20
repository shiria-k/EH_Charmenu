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
    for name, mdl in pairs(EHChar.Config.AllowedModels) do
        choices[#choices + 1] = {name = name, model = mdl}
    end
    table.SortByMember(choices, "name", true)
    return choices
end

local function createEditor(parent, slot, existing)
    parent:Clear()

    local title = vgui.Create("DLabel", parent)
    title:Dock(TOP)
    title:SetTall(32)
    title:SetText(existing and ("Slot " .. slot .. " bearbeiten") or ("Slot " .. slot .. " erstellen"))
    title:SetFont("DermaLarge")
    title:SetTextColor(color_white)

    local nameEntry = vgui.Create("DTextEntry", parent)
    nameEntry:Dock(TOP)
    nameEntry:DockMargin(0, 8, 0, 0)
    nameEntry:SetTall(30)
    nameEntry:SetPlaceholderText("Charaktername")
    nameEntry:SetValue(existing and tostring(existing.char_name or "") or "")

    local genderBox = vgui.Create("DComboBox", parent)
    genderBox:Dock(TOP)
    genderBox:DockMargin(0, 8, 0, 0)
    genderBox:SetTall(30)
    genderBox:SetValue(existing and tostring(existing.gender or "Geschlecht") or "Geschlecht")
    for _, gender in ipairs(EHChar.Config.Genders) do genderBox:AddChoice(gender) end

    local modelBox = vgui.Create("DComboBox", parent)
    modelBox:Dock(TOP)
    modelBox:DockMargin(0, 8, 0, 0)
    modelBox:SetTall(30)
    modelBox:SetValue("Model auswaehlen")

    local selectedModel = existing and tostring(existing.model or "") or nil
    for _, choice in ipairs(modelChoices()) do
        modelBox:AddChoice(choice.name, choice.model)
        if selectedModel == choice.model then modelBox:SetValue(choice.name) end
    end

    local skinSlider = vgui.Create("DNumSlider", parent)
    skinSlider:Dock(TOP)
    skinSlider:DockMargin(0, 8, 0, 0)
    skinSlider:SetTall(45)
    skinSlider:SetText("Skin")
    skinSlider:SetMin(0)
    skinSlider:SetMax(8)
    skinSlider:SetDecimals(0)
    skinSlider:SetValue(existing and tonumber(existing.skin) or 0)

    local bodygroupsEntry = vgui.Create("DTextEntry", parent)
    bodygroupsEntry:Dock(TOP)
    bodygroupsEntry:DockMargin(0, 8, 0, 0)
    bodygroupsEntry:SetTall(30)
    bodygroupsEntry:SetPlaceholderText("Bodygroups JSON, z.B. {\"1\":2,\"2\":1}")
    bodygroupsEntry:SetValue(existing and tostring(existing.bodygroups or "{}") or "{}")

    local hint = vgui.Create("DLabel", parent)
    hint:Dock(TOP)
    hint:DockMargin(0, 4, 0, 0)
    hint:SetTall(44)
    hint:SetWrap(true)
    hint:SetTextColor(Color(210, 210, 210))
    hint:SetText("Kleidung/Bodygroups funktionieren nur, wenn das Model Bodygroups hat und beide Server die gleichen Model-Addons besitzen.")

    local save = vgui.Create("DButton", parent)
    save:Dock(TOP)
    save:DockMargin(0, 12, 0, 0)
    save:SetTall(36)
    save:SetText("Speichern und auswaehlen")
    save.DoClick = function()
        local _, model = modelBox:GetSelected()
        model = model or selectedModel or ""
        local bodygroups = util.JSONToTable(bodygroupsEntry:GetValue() or "{}") or {}
        net.Start("EHChar_SaveCharacter")
            net.WriteTable({slot = slot, char_name = nameEntry:GetValue(), gender = genderBox:GetValue(), model = model, skin = math.floor(skinSlider:GetValue()), bodygroups = bodygroups})
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
    frame:SetSize(760, 520)
    frame:Center()
    frame:SetTitle("EH Character Menu")
    frame:MakePopup()

    local left = vgui.Create("DPanel", frame)
    left:Dock(LEFT)
    left:SetWide(250)
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
        edit:SetTall(24)
        edit:SetText("Slot " .. slot .. " bearbeiten")
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
