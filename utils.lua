RegisterNetEvent('vrp_advanced_vehicles:Notify')
AddEventHandler('vrp_advanced_vehicles:Notify', function(type,msg)
    TriggerEvent("Notify",type,msg)
end)