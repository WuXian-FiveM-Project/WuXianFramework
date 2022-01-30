MySql = exports.wx_module_system:RequestModule("MySql")
Item = exports.wx_module_system:RequestModule("Item")
TriggerEvent("RegisterPlayerModule","Inventory",function(self)
    self.Inventory = {}

    ---get specific item in inventory
    ---@param itemName string specific item you want to get
    ---@return table item item class with itemTable.Amount itemTable.Density itemTable.AttachData itemTable.ID
    self.Inventory.GetItem = function(itemName)
        local value = MySql.Sync.Fetch("player_items","*",{
            {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
            {Method = "AND",Operator = "=",Column = "ItemName",Value = itemName}
        })
        local itemTable = Item.GetItem(itemName)
        itemTable.Amount = value[1].ItemAmount
        itemTable.Density = value[1].ItemAmount
        itemTable.ItemAmount = value[1].ItemAmount
        itemTable.ItemAmount = value[1].ItemAmount
        itemTable.AttachData = json.decode(value[1].ItemAttachData)
        itemTable.ID = value[1].IID
        return itemTable
    end

    ---get all item in inventory
    ---@return table item table with item like {Inventory.GetItem(1),Inventory.GetItem(2),...}
    self.Inventory.GetItems = function()
        local value = MySql.Sync.Fetch("player_items","*",{
            {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
        })
        local Table = {}
        for k,v in pairs(value) do
            local itemTable = Item.GetItem(v.ItemName)
            itemTable.Amount = v.ItemAmount
            itemTable.Density = v .ItemAmount
            itemTable.AttachData = json.decode(v.ItemAttachData)
            itemTable.ID = v .IID
            table.insert(Table,itemTable)
        end
        return Table
    end
    ---get is item exist in inventory
    ---@param itemName string specific item you want to know if that exist
    ---@return boolean item item exist or not
    self.Inventory.IsItemExists = function(itemName)
        local value = MySql.Sync.Fetch("player_items","*",{
            {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
            {Method = "AND",Operator = "=",Column = "ItemName",Value = itemName}
        })
        if type(value[1]) == "table" then
            return true
        else
            return false
        end
    end

    ---get max item can player hold
    ---@return number number max item can player hold
    self.Inventory.GetMaxItemCanHold = function()
        return MySql.Sync.Fetch("player",{"MaxItemCanHold"},{
            {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
        })[1].MaxItemCanHold
    end

    ---get max density can player hold
    ---@return number item max density can player hold
    self.Inventory.GetMaxDensityCanHold = function()
        return MySql.Sync.Fetch("player",{"MaxDensityCanHold"},
            {
                {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
            }
        )[1].MaxDensityCanHold
    end

    ---get total item count
    ---@return number item item count
    self.Inventory.GetTotalItemCount = function()
        local value = MySql.Sync.Fetch("player_items","*",{
            {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
        })
        local count = 0
        for _,v in pairs(value) do
            count = count + v.ItemAmount
        end
        return count
    end

    ---get total density count
    ---@return number density total density
    self.Inventory.GetTotalDensity = function()
        local value = MySql.Sync.Fetch("player_items","*",{
            {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
        })
        local density = 0
        for _,v in pairs(value) do
            density = density + v.ItemAmount
        end
        return density
    end
    ---give item to player
    ---@param itemName string item name to give
    ---@param amount number amount to give
    ---@param isForce boolean is bypass the cheak
    ---@param attachData table attach data
    ---@return boolean isSuccess is item give success or not
    self.Inventory.GiveItem = function(itemName,amount,isForce,attachData)
        if self.Inventory.IsItemExists(itemName) then
            local iteminfo = Item.GetItem(itemName)
            local before = self.Inventory.GetItem(itemName)
            local max_density = self.Inventory.GetMaxDensityCanHold()
            local max_item = self.Inventory.GetMaxItemCanHold()
            if isForce then
                MySql.Sync.Insert("player_items",
                    {
                        {Column = "SteamID" , Value = self.SteamID.Get()},
                        {Column = "ItemName" , Value = itemName},
                        {Column = "ItemAmount" , Value = amount},
                        {Column = "ItemDensity" , Value = iteminfo.ItemDensity * amount},
                        {Column = "ItemAttachData" , Value = json.encode(attachData)},
                    }
                )
                return true
            else
                if self.Inventory.GetTotalItemCount() + amount <= max_item then
                    if self.Inventory.GetTotalDensity() + (iteminfo.ItemDensity*amount) <= max_density then
                        MySql.Sync.Update("player_items",
                            {
                                {Column = "ItemAmount", Value = before.Amount + amount},
                                {Column = "ItemAttachData", Value = json.encode(attachData)},
                                {Column = "ItemDensity", Value = ((before.Amount + amount) * iteminfo.ItemDensity)}
                            },
                            {
                                {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
                                {Method = "AND",Operator = "=",Column = "ItemName",Value = itemName}
                            }
                        )
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            end
        else
            local iteminfo = Item.GetItem(itemName)
            local max_density = self.Inventory.GetMaxDensityCanHold()
            local max_item = self.Inventory.GetMaxItemCanHold()
            if self.Inventory.GetTotalItemCount() + amount <= max_item then
                if self.Inventory.GetTotalDensity() + (iteminfo.ItemDensity*amount) <= max_density then
                    MySql.Sync.Insert("player_items",
                        {
                            {Column = "SteamID" , Value = self.SteamID.Get()},
                            {Column = "ItemName" , Value = itemName},
                            {Column = "ItemAmount" , Value = amount},
                            {Column = "ItemDensity" , Value = iteminfo.ItemDensity * amount},
                            {Column = "ItemAttachData" , Value = json.encode(attachData)},
                        }
                    )
                    return true
                else
                    return false
                end
            end
        end
    end
    
    ---remov item from inventory
    ---@param itemName string item to remove
    ---@param amount number number of items to remove
    ---@return boolean isSuccess is item remove success or not
    self.Inventory.RemoveItem = function(itemName,amount)
        if self.Inventory.IsItemExists(itemName) then
            local before = self.Inventory.GetItem(itemName)
            if before.Amount - amount < 0 then
                return false
            elseif before.Amount - amount == 0 then
                MySql.Sync.Delete("player_items",
                    {
                        {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
                        {Method = "AND",Operator = "=",Column = "ItemName",Value = itemName}
                    }
                )
                return true
            elseif before.Amount - amount > 0 then
                MySql.Sync.Update("player_items",
                    {
                        {Column = "ItemAmount", Value = before.Amount - amount},
                        {Column = "ItemDensity", Value = ((before.Amount - amount) * Item.GetItem(itemName).ItemDensity)},
                    },
                    {
                        {Method = "AND",Operator = "=",Column = "SteamID",Value = self.SteamID.Get()},
                        {Method = "AND",Operator = "=",Column = "ItemName",Value = itemName}
                    }
                )
                return true
            else
                return false
            end
        else
            return false
        end
    end

    return self
end)