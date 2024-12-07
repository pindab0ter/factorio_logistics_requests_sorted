local inventory = require("scripts/inventory")

--- @param player LuaPlayer
--- @param entity LuaEntity
local function apply_sorting(player, entity)
    if storage.sorting_enabled[player.index] then
        inventory.sort_logistic_sections(entity)
    end
end

--- @param player LuaPlayer
--- @param enabled boolean
local function set_button(player, enabled)
    player.set_shortcut_toggled("sorted-logistic-sections-toggle", storage.sorting_enabled[player.index])
end

--- @param player LuaPlayer
local function initialize_player(player)
    storage.sorting_enabled[player.index] = true
    set_button(player, true)
    apply_sorting(player, player.character)
end

--- @param event EventData.on_player_created
local function on_player_created(event)
    local player = game.players[event.player_index] or error("Player " .. event.player_index .. " not found")
    initialize_player(player)
end

--- @param event EventData.on_player_removed
local function on_player_removed(event)
    storage.sorting_enabled[event.player_index] = nil
end

local function on_configuration_changed()
    if storage.sorting_enabled == nil then
        storage.sorting_enabled = {}
    end
    storage.last_sorted_on_tick = {}

    for _, player in pairs(game.players) do
        if storage.sorting_enabled[player.index] == nil then
            initialize_player(player)
        end
    end
end

--- @param player LuaPlayer
--- @return boolean
local function toggle_sorting_enabled(player)
    local sorting_enabled = not storage.sorting_enabled[player.index]

    storage.sorting_enabled[player.index] = sorting_enabled
    set_button(player, sorting_enabled)

    return sorting_enabled
end

--- For some reason the event is always triggered twice, so we ignore the second one
--- @param entity LuaEntity
--- @return boolean
local function was_sorted_this_tick(entity)
    if storage.last_sorted_on_tick == nil then
        storage.last_sorted_on_tick = {}
    end

    if storage.last_sorted_on_tick[entity.unit_number] == game.tick then
        return true
    else
        storage.last_sorted_on_tick[entity.unit_number] = game.tick
    end
end

--------------------
-- Event Handlers --
--------------------

--- @param event EventData.on_entity_logistic_slot_changed
local function on_entity_logistic_slot_changed(event)
    if was_sorted_this_tick(event.entity) or event.player_index == nil then
        return
    end

    local player = game.get_player(event.player_index) or error("Player " .. event.player_index .. " not found")

    apply_sorting(player, event.entity)
end

--- @param event EventData.on_lua_shortcut
local function on_lua_shortcut(event)
    if event.prototype_name ~= "sorted-logistic-sections-toggle" then
        return
    end

    local player = game.get_player(event.player_index) or error("Player " .. event.player_index .. " not found")

    local sorting_enabled = toggle_sorting_enabled(player)

    if sorting_enabled then
        apply_sorting(player, player.character)
    end
end

--- @param event EventData.CustomInputEvent
local function on_sorted_logistic_section_hotkey(event)
    local player = game.get_player(event.player_index) or error("Player " .. event.player_index .. " not found")

    local sorting_enabled = toggle_sorting_enabled(player)

    if sorting_enabled then
        apply_sorting(player, player.character)
    end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_player_removed, on_player_removed)
script.on_event(defines.events.on_entity_logistic_slot_changed, on_entity_logistic_slot_changed)
script.on_event(defines.events.on_lua_shortcut, on_lua_shortcut)
script.on_event("sorted-logistic-sections-hotkey", on_sorted_logistic_section_hotkey)
