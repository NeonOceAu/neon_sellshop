local Config = Config or {}

local Framework = nil

if Config.Framework == 'ESX' then
    Citizen.CreateThread(function()
        while ESX == nil do
            ESX = exports['es_extended']:getSharedObject()
            Citizen.Wait(100)
        end
        Framework = ESX
    end)
elseif Config.Framework == 'QB' then
    Framework = exports['qb-core']:GetCoreObject()
end

-- Function to set random prices for Mining Buyer
function SetRandomPrices(shop)
    if shop.label == "Mining Buyer" then
        for item, data in pairs(shop.materials) do
            if type(data.price) == "table" then
                local randomPrice = math.random(data.price.min, data.price.max)
                shop.materials[item].price = randomPrice
            end
        end
    end
end

-- Function to handle interactions (textui or target)
function SetupInteraction(shop)
    if Config.Interaction == 'target' then
        SetupTargetInteraction(shop)
    else
        SetupTextUIInteraction(shop)
    end
end

-- Function to set up target interaction (ox_target or qb-target)
function SetupTargetInteraction(shop)
    local targetFramework = Config.Target == 'ox_target' and 'ox_target' or 'qb-target'

    if targetFramework == 'ox_target' then
        exports.ox_target:addLocalEntity(shop.ped, {
            {
                name = 'neon_sellshop',
                icon = 'fa-solid fa-shop',
                label = shop.targetLabel,
                onSelect = function()
                    OpenSellMenu(shop)
                end
            }
        })
    elseif targetFramework == 'qb-target' then
        exports['qb-target']:AddTargetEntity(shop.ped, {
            options = {
                {
                    type = "client",
                    event = "neon_sellshop:sell",
                    icon = 'fa-solid fa-shop',
                    label = shop.targetLabel
                }
            },
            distance = 2.5
        })
    end
end

-- Function to set up textui interaction
function SetupTextUIInteraction(shop)
    CreateThread(function()
        while true do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local pedCoords = shop.pedCoords
            local dist = #(playerCoords - vector3(pedCoords.x, pedCoords.y, pedCoords.z))

            if dist <= 3.0 then
                lib.showTextUI(shop.targetLabel)

                if IsControlJustPressed(0, 38) then -- E key by default
                    OpenSellMenu(shop)
                end
            else
                lib.hideTextUI()
            end
            Wait(0)
        end
    end)
end

-- Create the shops and apply interaction
function CreateShop(shop)
    SetRandomPrices(shop)
    
    -- Load ped model
    local pedHash = GetHashKey(shop.pedModel)
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(1)
    end

    -- Create ped
    shop.ped = CreatePed(4, pedHash, shop.pedCoords.x, shop.pedCoords.y, shop.pedCoords.z, shop.pedCoords.w, false, true)
    FreezeEntityPosition(shop.ped, true)
    SetEntityInvincible(shop.ped, true)
    SetBlockingOfNonTemporaryEvents(shop.ped, true)

    -- Create blip if enabled
    if shop.blip then
        local blip = AddBlipForCoord(shop.pedCoords.x, shop.pedCoords.y, shop.pedCoords.z)
        SetBlipSprite(blip, shop.blipSettings.sprite)
        SetBlipDisplay(blip, shop.blipSettings.display)
        SetBlipScale(blip, shop.blipSettings.scale)
        SetBlipColour(blip, shop.blipSettings.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shop.blipSettings.label)
        EndTextCommandSetBlipName(blip)
    end

    -- Setup interaction (target or textui)
    SetupInteraction(shop)
end

-- Loop through all shops and create them
CreateThread(function()
    for _, shop in pairs(Config.Shops) do
        CreateShop(shop)
    end
end)

-- Open Sell Menu
function OpenSellMenu(shop)
    local elements = {}
    local playerInventory = exports.ox_inventory:Items() -- Fetch player inventory

    for item, data in pairs(shop.materials) do
        local count = playerInventory[item] and playerInventory[item].count or 0

        if count > 0 then
            -- Check if price is a table (dynamic) or a static value
            local price
            if type(data.price) == "table" then
                price = math.random(data.price.min, data.price.max) -- Get random price between min and max
            else
                price = data.price -- Use static price
            end

            table.insert(elements, {
                title = data.name,
                description = 'Total: ' .. count .. ' | Price: $' .. price,
                event = 'neon_sellshop:sell',
                args = {
                    item = item,
                    count = count,
                    price = price,
                    moneyType = shop.moneyType,
                    shopLabel = shop.label
                }
            })
        end
    end

    if #elements == 0 then
        Notify('You don\'t have any materials to sell.', 'error')
        return
    end

    lib.registerContext({
        id = 'sell_materials_menu',
        title = shop.label,
        options = elements,
    })

    lib.showContext('sell_materials_menu')
end

-- Notify function for both frameworks
function Notify(message, type)
    if Config.Framework == 'ESX' then
        ESX.ShowNotification(message)
    elseif Config.Framework == 'QB' then
        Framework.Functions.Notify(message, type)
    end
end

-- Handle selling material
RegisterNetEvent('neon_sellshop:sell', function(data)
    local input = lib.inputDialog('Sell Amount', {'Enter amount to sell'})

    if not input or not tonumber(input[1]) then
        Notify('Invalid amount entered.', 'error')
        return
    end

    local amountToSell = tonumber(input[1])

    if amountToSell > data.count then
        Notify('You don\'t have enough materials.', 'error')
        return
    end

    local totalPrice = amountToSell * data.price
    TriggerServerEvent('neon_sellshop:sellMaterial', data.item, amountToSell, totalPrice, data.moneyType, data.shopLabel)
end)
