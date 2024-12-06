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

--- Use Inventory.sort_and_merge() to sort the logistic sections
--- @param entity LuaEntity
inventory_sort.sort_logistic_sections = function(entity)
    if entity == nil or not entity.valid then
        return
    end

    local logistic_sections = entity.get_logistic_sections()

    if logistic_sections == nil then
        return
    end

    local test_section = nil
    local sections = {}

    for _, section in pairs(logistic_sections.sections) do
        if section.is_manual then
            if (section.group == "TEST") then
                test_section = section
            else
                sections[#sections] = section
            end
        end
    end

    if test_section then
        for index, _ in pairs(test_section.filters) do
            test_section.clear_slot(index)
        end
    end

    -- Record each request section's filters into an inventory and save the filters into a table
    for _, section in pairs(sections) do
        -- TODO: Refactor into `sort_section`
        if section.is_manual then
            local inventory = game.create_inventory(section.filters_count)
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

            inventory.sort_and_merge()
            -- TODO: Continue if inventory sorting changed nothing

            -- for index, _ in pairs(section.filters) do
            --     section.clear_slot(index)
            -- end

            local section_index = 1

            for _, item in pairs(inventory.get_contents()) do
                local filters = filter_sets[item.name]
                table.sort(filters, logistic_filter_comparator)

                print("Filters: ", serpent.block(filters))

                for _, filter in pairs(filters) do
                    test_section.set_slot(section_index, filter)
                    section_index = section_index + 1
                end
            end
        end
    end

    ----record request items into inventory, counts into counts
    --local inventory = game.create_inventory(entity.request_slot_count)
    --local counts = {}
    --
    ----record and remove all old requests
    --for i = 1, entity.request_slot_count do
    --    local old_value = inventory.get_slot(entity, i)
    --    if old_value.name ~= nil then
    --        inventory.insert({ name = old_value.name })
    --        counts[old_value.name] = old_value
    --    end
    --    inventory.clear_slot(entity, i)
    --end


    -- inventory.sort_and_merge()

    --put them back, now in sorted order
    -- local slotIndex = 0
    -- for i = 1, #inventory - inventory.count_empty_stacks() do
    --     local invitem = inventory[i]
    --     slotIndex = slotIndex + 1
    --     inventory.set_slot(entity, slotIndex,
    --             { name = invitem.name, min = counts[invitem.name].min, max = counts[invitem.name].max })
    -- end

    -- inventory.destroy()
end

return inventory_sort
