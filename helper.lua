local Helper = {}

-- helper function
function Helper.isInTable(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

function Helper.isSolidLayer(a, b)
    if (a:getUserData() and a:getUserData().layer == SolidLayer)
    or (b:getUserData() and b:getUserData().layer == SolidLayer) then
        print("not ignored")
        return true
    end
    return false
end

function Helper.ignore(a, b, object)
    if (a:getUserData() and a:getUserData().__index == object)
        or (b:getUserData() and b:getUserData().__index == object) then
        return true
    end
    return false
end

return Helper