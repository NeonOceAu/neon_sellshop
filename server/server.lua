local Config = Config or {}

local Framework = nil

if Config.Framework == 'ESX' then
    ESX = exports['es_extended']:getSharedObject()
    Framework = ESX
elseif Config.Framework == 'QB' then
    Framework = exports['qb-core']:GetCoreObject()
end

-- Sell Material Event
RegisterNetEvent('neon_sellshop:sellMaterial', function(item, amount, totalPrice, moneyType, shopLabel)
    local xPlayer

    if Config.Framework == 'ESX' then
        xPlayer = Framework.GetPlayerFromId(source)
    elseif Config.Framework == 'QB' then
        xPlayer = Framework.Functions.GetPlayer(source)
    end

    local removed = false

    if Config.Framework == 'ESX' then
        removed = xPlayer.removeInventoryItem(item, amount)
    elseif Config.Framework == 'QB' then
        removed = xPlayer.Functions.RemoveItem(item, amount)
    end

    if removed then
        if moneyType == "dirtymoney" then
            if Config.Framework == 'ESX' then
                xPlayer.addAccountMoney('black_money', totalPrice)
            elseif Config.Framework == 'QB' then
                xPlayer.Functions.AddMoney('dirtymoney', totalPrice)
            end
        else
            if Config.Framework == 'ESX' then
                xPlayer.addMoney(totalPrice)
            elseif Config.Framework == 'QB' then
                xPlayer.Functions.AddMoney('cash', totalPrice)
            end
        end

        -- Prepare itemsSold table
        local itemsSold = { item .. ": " .. amount .. " sold" }

        -- Call the SendDiscordLog function from sv_utils.lua
        SendDiscordLog(shopLabel, itemsSold, totalPrice, source)

        TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = 'You sold ' .. amount .. 'x ' .. item .. ' for $' .. totalPrice })
    else
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Transaction failed. Please try again.' })
    end
end)
