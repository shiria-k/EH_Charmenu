EHChar = EHChar or {}
EHChar.Config = EHChar.Config or {}

hook.Add("Initialize", "EHChar_AddWorkshopDownloads", function()
    local workshop = EHChar.Config.WorkshopDownloads
    if not workshop or not workshop.Enabled then return end

    for _, workshopID in ipairs(workshop.IDs or {}) do
        workshopID = tostring(workshopID or "")
        if workshopID ~= "" and not string.find(workshopID, "WORKSHOP_ID", 1, true) then
            resource.AddWorkshop(workshopID)
            print("[EHChar] Workshop Download hinzugefuegt: " .. workshopID)
        end
    end
end)
