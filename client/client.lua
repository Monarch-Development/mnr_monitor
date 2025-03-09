local InitMonitor = false

AddEventHandler("onClientResourceStart", function(resourceName)
    local scriptName = cache.resource or GetCurrentResourceName()
    if resourceName ~= scriptName then return end
    InitMonitor = true
    MainLoop()
end)

function MainLoop()
    CreateThread(function()
        while InitMonitor do
            VehMonitor:Update()
            Wait(500)
        end
    end)
end