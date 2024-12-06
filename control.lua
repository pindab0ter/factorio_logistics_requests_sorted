local inventory = require("scripts/inventory")

local function update_button(player)
    player.set_shortcut_toggled("sorted-logistic-sections-enabled", storage.sorting_enabled[player.index])
end

--- @param player LuaPlayer
--- @param entity LuaEntity
local function apply_sorting(player, entity)
    if storage.sorting_enabled[player.index] then
        inventory.sort_logistic_sections(entity)
    end
end

--- @param player LuaPlayer
local function initialize_player(player)
    storage.sorting_enabled[player.index] = true
    update_button(player)
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

    for _, player in pairs(game.players) do
        if storage.sorting_enabled[player.index] == nil then
            initialize_player(player)
        end
    end
end

--- @param event EventData.on_entity_logistic_slot_changed
local function on_entity_logistic_slot_changed(event)
    -- Only if player changed it directly
    if event.player_index == nil then
        return
    end

    local player = game.get_player(event.player_index) or error("Player " .. event.player_index .. " not found")

    apply_sorting(player, event.entity)
end

--- @param event EventData.on_lua_shortcut|EventData.CustomInputEvent
local function on_lua_shortcut(event)
    if event.prototype_name ~= "logistics-requests-sorted-enabled" then
        return
    end

    local player = game.get_player(event.player_index) or error("Player " .. event.player_index .. " not found")

    storage.sorting_enabled[player.index] = not storage.sorting_enabled[player.index]

    update_button(player)

    apply_sorting(player, player.character)
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_player_removed, on_player_removed)
script.on_event(defines.events.on_entity_logistic_slot_changed, on_entity_logistic_slot_changed)
script.on_event(defines.events.on_lua_shortcut, on_lua_shortcut)
script.on_event("sorted-logistic-sections-hotkey", on_lua_shortcut)
