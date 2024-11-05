local Config = Config or {}
local Framework = nil

if Config.Framework == 'ESX' then
    ESX = exports['es_extended']:getSharedObject()
    Framework = ESX
elseif Config.Framework == 'QB' then
    Framework = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'QBX' then
    Framework = exports.qbx_core
end

local function CheckPlayerInventory(src, item, amount)
    if Config.Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(src)
        local inventoryItem = xPlayer.getInventoryItem(item)
        return inventoryItem and inventoryItem.count >= amount
    elseif Config.Framework == 'QB' then
        local xPlayer = Framework.Functions.GetPlayer(src)
        return xPlayer.Functions.GetItemByName(item) and xPlayer.Functions.GetItemByName(item).amount >= amount
    elseif Config.Framework == 'QBX' then
        local inventoryItem = exports.ox_inventory:GetItem(src, item)
        return inventoryItem and inventoryItem.count >= amount
    end
end

local function GetItemPrice(shopLabel, item)
    for _, shop in pairs(Config.Shops) do
        if shop.label == shopLabel then
            if shop.materials[item] then
                return shop.materials[item].price
            end
        end
    end
    return nil
end

RegisterNetEvent('neon_sellshop:sellMaterial', function(data)
    local src = source
    local xPlayer

    if Config.Framework == 'ESX' then
        xPlayer = Framework.GetPlayerFromId(src)
    elseif Config.Framework == 'QB' then
        xPlayer = Framework.Functions.GetPlayer(src)
    elseif Config.Framework == 'QBX' then
        xPlayer = exports.qbx_core:GetPlayer(src)
    end

    local itemPrice = GetItemPrice(data.shopLabel, data.item)
    if not itemPrice then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Invalid item or shop configuration.' })
        return
    end

    if not CheckPlayerInventory(src, data.item, data.amount) then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'You do not have enough ' .. data.item .. ' to sell.' })
        return
    end

    local totalPrice = data.amount * itemPrice
    local removed = false
    if Config.Framework == 'ESX' then
        removed = xPlayer.removeInventoryItem(data.item, data.amount)
    elseif Config.Framework == 'QB' then
        removed = xPlayer.Functions.RemoveItem(data.item, data.amount)
    elseif Config.Framework == 'QBX' then
        removed = exports.ox_inventory:RemoveItem(src, data.item, data.amount)
    end

    if removed then
        if data.moneyType == "dirtymoney" then
            local dirtyMoneyItem = Config.DirtyMoneyItem or "black_money"
            if Config.Framework == 'ESX' then
                xPlayer.addInventoryItem(dirtyMoneyItem, totalPrice)
            elseif Config.Framework == 'QB' then
                xPlayer.Functions.AddItem(dirtyMoneyItem, totalPrice)
            elseif Config.Framework == 'QBX' then
                exports.ox_inventory:AddItem(src, dirtyMoneyItem, totalPrice)
            end
        else
            if Config.Framework == 'ESX' then
                xPlayer.addMoney(totalPrice)
            elseif Config.Framework == 'QB' then
                xPlayer.Functions.AddMoney('cash', totalPrice)
            elseif Config.Framework == 'QBX' then
                exports.ox_inventory:AddItem(src, 'cash', totalPrice)
            end
        end

        local itemsSold = { data.item .. ": " .. data.amount .. " sold" }
        SendDiscordLog(data.shopLabel, itemsSold, totalPrice, src)

        TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = 'You sold ' .. data.amount .. 'x ' .. data.item .. ' for $' .. totalPrice })
    else
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Transaction failed. Please try again.' })
    end
end)