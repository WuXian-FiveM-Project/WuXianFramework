local searchFequency = 10000

Citizen.CreateThread(function()
    while true do
        local object = GetGamePool("CObject")
        for _, entity in ipairs(object) do
            if string.find(GetEntityArchetypeName(entity),"atm") ~= nil then
                DrawATM(entity)
            end
        end
        Wait(searchFequency)
    end
end)

function DrawATM(entity)
    local shouldDraw = true
    local blip
    Citizen.CreateThread(function()
        local entityCoords = GetEntityCoords(entity)
        while shouldDraw do
            Wait(1)
            DrawMarker(
                1,
                entityCoords,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                2.5,
                2.5,
                1.0,
                25,
                255,
                255,
                140,
                false,
                false,
                false,
                false,
                nil,
                nil,
                false
            )
            if Vdist2(GetEntityCoords(GetPlayerPed(-1)), entityCoords) < 2.6 then
                exports.wx_module_system:RequestModule("Notification").ShowHelpNotification("按~INPUT_PICKUP~使用ATM鸡",true)
                if IsControlJustPressed(0,38) then
                    SetNuiFocus(true,true)
                    SendNUIMessage({
                        type = "openATM"
                    })
                end
            end
        end
    end)
    Citizen.SetTimeout(searchFequency, function()
        shouldDraw = false
        RemoveBlip(blip)
    end)
end

RegisterNetEvent("wx_bank:card:viewCard",function(bankCardData)
    SetNuiFocus(true,true)
    SendNUIMessage({
        type = "showBankCardView",
        cardData = bankCardData
    })
end)

RegisterNUICallback("disableCursur", function(data,cb)
    SetNuiFocus(false,false)
end)