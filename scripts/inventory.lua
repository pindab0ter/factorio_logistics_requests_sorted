local inventory_sort = {}

local quality_order = {
    ["normal"] = 1,
    ["uncommon"] = 2,
    ["rare"] = 3,
    ["epic"] = 4,
    ["legendary"] = 5,
}

local comparator_order = {
    ["<"] = 1,
    ["≤"] = 2,
    ["<="] = 3,
    ["="] = 4,
    ["≠"] = 5,
    ["!="] = 6,
    [">="] = 7,
    ["≥"] = 8,
    [">"] = 9,
}

--- @param a LogisticFilter?
--- @param b LogisticFilter?
--- @return boolean
local logistic_filter_comparator = function(a, b)
    if a == nil or a.value == nil or b == nil or b.value == nil then
        return false
    end

    return quality_order[a.value.quality] < quality_order[b.value.quality]
        or comparator_order[a.value.comparator] < comparator_order[b.value.comparator]
end

--- Sorts the filter item order using a `LuaInventory` and then sorts the filters with the same items by quality and
--- comparator.
--- TODO: Find out why sometomes the sorting doesn't go well the first time.
--- @param section LuaLogisticSection
local function sort_section(section)
    local inventory = game.create_inventory(section.filters_count)
    --- @type table<string, table<number, LogisticFilter>>
    local filter_sets = {}

    local i = 1
    for _, filter in pairs(section.filters) do
        if filter.value and filter.value.name then
            inventory.insert({ name = filter.value.name })

            if not filter_sets[filter.value.name] then
                filter_sets[filter.value.name] = {}
            end

            filter_sets[filter.value.name][i] = filter
            i = i + 1
        end
    end

    -- TODO: Skip further processing if the inventory order has not changed?
    inventory.sort_and_merge()

    -- Clear all filters from the section so we can re-add them in the correct order without running into conflicts
    for index, _ in pairs(section.filters) do
        section.clear_slot(index)
    end

    -- Manually track where we should add the next filter, as each item can have multiple filters
    local section_index = 1

    -- Insert the filters back in, in the order of the sorted inventory
    for _, item in pairs(inventory.get_contents()) do
        local filters = filter_sets[item.name]
        table.sort(filters, logistic_filter_comparator)

        for _, filter in pairs(filters) do
            section.set_slot(section_index, filter)
            section_index = section_index + 1
        end
    end
    inventory.destroy()
end

--- @param entity LuaEntity
inventory_sort.sort_logistic_sections = function(entity)
    if entity == nil or not entity.valid then
        return
    end

    local logistic_sections = entity.get_logistic_sections()

    if logistic_sections == nil then
        return
    end

    for _, section in pairs(logistic_sections.sections) do
        if section.is_manual then
            sort_section(section)
        end
    end
end

return inventory_sort
