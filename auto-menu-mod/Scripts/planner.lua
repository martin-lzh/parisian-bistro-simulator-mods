local Planner = {}
Planner.courses = {
    { field = 'Starter', kind = 3 }, { field = 'MainDish', kind = 4 },
    { field = 'Dessert', kind = 5 }, { field = 'Aperitif', kind = 2 },
    { field = 'EndDrink', kind = 6 },
}

function Planner.copy(menu)
    local result = { Period = menu.Period, bIsActive = menu.bIsActive }
    for _, course in ipairs(Planner.courses) do result[course.field] = menu[course.field] end
    return result
end

return Planner
