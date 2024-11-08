Config = {
    Version = true, -- This will print new updates in server console.
    Framework = 'QB', -- Options: 'QB', 'QBX' 'ESX'. Default is 'QB'.
    Inventory = 'OX', -- 'OX', 'QB', or 'PS'
    Interaction = 'target', -- Options: 'target', 'textui'. Default is 'target'.
    Target = 'ox_target', -- Options: 'ox_target', 'qb-target'. Default is 'ox_target'.
    DirtyMoneyItem = 'marked_bills', -- Set your dirty money item here
    InputType = 'slider', -- Options: 'input', 'slider'.
    Shops = {
        {
            label = "Material Buyer",
            pedModel = 's_m_m_autoshop_02',
            pedCoords = vector4(-350.09, -1570.02, 24.22, 297),
            blip = true,  -- Enable or disable blip
            blipSettings = {
                sprite = 478,
                display = 4,
                scale = 0.8,
                color = 2,
                label = "Material Buyer"
            },
            moneyType = "cash",  -- 'cash' for clean money, 'dirtymoney' for dirty money (Make sure to set item up in DirtyMoneyItem (Above^))
            targetLabel = "Sell Materials", -- Label for ox_target/qb-target interaction
            materials = {
                ['steel'] = { name = 'Scrap Metal', price = {min = 12, max = 18} },
                ['copper_wire'] = { name = 'Copper Wire', price = {min = 12, max = 18} }, -- Price range
            }
        },
        {
            label = "Illegal Item Buyer",
            pedModel = 's_m_y_dealer_01',
            pedCoords = vector4(100.0, 200.0, 300.0, 50.0),
            blip = false,
            moneyType = "dirtymoney",
            targetLabel = "Sell Illegal Goods",
            materials = {
                ['gold_bar'] = { name = 'Gold Bar', price = 100 },
                ['diamond'] = { name = 'Diamond', price = 200 },
            }
        }
    }
}
