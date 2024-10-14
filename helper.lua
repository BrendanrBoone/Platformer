local Helper = {}

-- helper function
function Helper.isInTable(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

return Helper