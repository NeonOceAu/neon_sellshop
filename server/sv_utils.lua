local webhookUrl = 'Replace_With_Your_Webhook' -- Replace with your actual Discord Webhook URL

function SendDiscordLog(shopLabel, itemsSold, totalAmount, player)
    local playerName = GetPlayerName(player)

    local embed = {
        {
            ["title"] = shopLabel,
            ["color"] = 16711680,
            ["fields"] = {
                {
                    ["name"] = "Total Amount",
                    ["value"] = "$" .. totalAmount,
                    ["inline"] = true
                },
                {
                    ["name"] = "Items Sold",
                    ["value"] = table.concat(itemsSold, "\n"),
                    ["inline"] = false
                },
                {
                    ["name"] = "Seller Name",
                    ["value"] = playerName,
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(webhookUrl, function(err, text, headers)
    end, 'POST', json.encode({username = "Sell Shop Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

