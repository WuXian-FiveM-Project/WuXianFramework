Notification = exports.wx_module_system:RequestModule("Notification")
Callback = exports.wx_module_system:RequestModule("Callback")


RegisterNetEvent("wx_player_inventory:drop",function(itemShowName,amount,prop,IsItemPhysicalAfterDrop,coords,ticket)
    Citizen.CreateThread(function()
        local object = nil
        repeat
            object = CreateObject(GetHashKey(prop), coords.x, coords.y, coords.z, false, false, IsItemPhysicalAfterDrop)
        until type(object) ~= "nil"


        local isObjectPickUp = true

        -- local ScaleformHandle = RequestScaleformMovie("MP_AWARD_FREEMODE") -- The scaleform you want to use
        -- while not HasScaleformMovieLoaded(ScaleformHandle) do -- Ensure the scaleform is actually loaded before using
        --     Wait(0)
        -- end
        -- BeginScaleformMovieMethod(ScaleformHandle, "SHOW_AWARD_AND_MESSAGE") -- The function you want to call from the AS file
        -- PushScaleformMovieMethodParameterString(itemShowName) -- bigTxt
        -- PushScaleformMovieMethodParameterString("数量："..amount) -- msgText
        -- PushScaleformMovieMethodParameterInt(5) -- colId
        -- EndScaleformMovieMethod()



        local spin = 1
        local isPickedUp = false
        local handle = AddEventHandler("wx_player_inventory:pickup"..ticket,function()
            isObjectPickUp = not isObjectPickUp
            isPickedUp = true
        end)
        local ScaleformHandle = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE") --scaleform 库
        while not HasScaleformMovieLoaded(ScaleformHandle) do
            Wait(0)
            ScaleformHandle = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
        end

        while isObjectPickUp do
            ScaleformHandle = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
            BeginScaleformMovieMethod(ScaleformHandle, "SHOW_BIG_MP_MESSAGE") --开始scaleform参数堆栈
            PushScaleformMovieMethodParameterString(itemShowName .. "  数量: "..amount)  --压入参数
            EndScaleformMovieMethod() --结束scaleform堆栈
            spin = spin+1.01
            coords = GetEntityCoords(object)
            DrawScaleformMovie_3dSolid(
                ScaleformHandle --[[ integer ]], 
                coords.x --[[ number ]], 
                coords.y --[[ number ]], 
                coords.z --[[ number ]], 
                0.0 --[[ rot number ]], 
                0.0 --[[ rot number ]], 
                spin --[[ rot number ]], 
                0.0 --[[ number ]], 
                100.0 --[[sharpness   number ]], 
                0.0 --[[ number ]], 
                4.5 --[[ number ]], 
                2.5 --[[ number ]], 
                2.5 --[[ number ]], 
                false --[[ Any ]]
            )
            DrawMarker(
                1,
                coords.x, coords.y, coords.z, 
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.2, 1.2, 1.2,
                255, 255, 255, 120,
                false,
                false,
                nil, 
                false, nil, nil, false
            )
            local playerCoords = GetEntityCoords(GetPlayerPed(-1))
            if Vdist(playerCoords.x,playerCoords.y,playerCoords.z, coords.x,coords.y,coords.z) <= 1.5 then
                exports.wx_module_system:RequestModule("Notification").ShowHelpNotification("按~INPUT_PICKUP~捡起",true)
                if IsControlPressed(0 --[[ integer ]], 38 --[[ integer ]]) then
                    break
                end
            end
            Wait(0)
        end
        if isPickedUp == false then
            Notification = exports.wx_module_system:RequestModule("Notification")
            local result = Callback.TriggerServerCallback('wx_player_inventory:pickup',ticket)
            if result then
                DeleteObject(object)
                RemoveEventHandler(handle)
                Notification.ShowNotification("你捡起了"..amount.."个"..itemShowName)
            else
                Notification.ShowNotification("背包已满或已到达物品最大数量")
            end
        else
            RemoveEventHandler(handle)
            DeleteObject(object)
        end
    end)
end)

RegisterNetEvent('wx_player_inventory:global_pickup',function(ticket)
    TriggerEvent("wx_player_inventory:pickup"..ticket)
end)