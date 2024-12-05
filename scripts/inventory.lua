local inventory_sort = {}

--- Use Inventory.sort_and_merge() to sort the logistic sections
--- @param entity LuaEntity
inventory_sort.sort_logistic_sections = function(entity)
    if entity == nil then
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
        if section.is_manual then
            local inventory = game.create_inventory(section.filters_count)
            local filters = {}

            for filter_index, filter in pairs(section.filters) do
                if filter.value and filter.value.name then
                    inventory.insert({ name = filter.value.name })

                    if not filters[filter.value.name] then
                        filters[filter.value.name] = {}
                    end

                    -- TODO: Sort filters by rarity and comparator
                    filters[filter.value.name][filter_index] = filter
                end
            end

            log(serpent.block(filters))
            inventory.sort_and_merge()
            -- TODO: Continue if inventory sorting changed nothing

            -- for index, _ in pairs(section.filters) do
            --     section.clear_slot(index)
            -- end

            local section_index = 1

            for _, item in pairs(inventory.get_contents()) do
                local filter = filters[item.name]
                for _, f in pairs(filter) do
                    test_section.set_slot(section_index, f)
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
