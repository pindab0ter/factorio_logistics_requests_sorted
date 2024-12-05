data:extend({
    {
        type = "custom-input",
        name = "logistics_requests_sorted-hotkey",
        key_sequence = "",
        action = "lua",
    },
    {
        type = "shortcut",
        name = "logistics_requests_sorted-enabled",
        action = "lua",
        toggleable = true,
        icon = "__logistics_requests_sorted__/graphics/shortcut_32.png",
        icon_size = 32,
        small_icon = "__logistics_requests_sorted__/graphics/shortcut_24.png",
        small_icon_size = 24
        --disabled_icon = {
        --    filename = "__logistics_requests_sorted__/graphics/shortcut_32_white.png",
        --    size = 32,
        --    scale = 0.5,
        --    mipmap_count = 2,
        --    flags = { "gui-icon" },
        --},
    },
})
