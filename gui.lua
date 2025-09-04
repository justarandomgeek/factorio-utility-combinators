local glib = require("__glib__.glib")

local gui = {}

---@type table<defines.entity_status, LocalisedString>
local status_names = {}
for k, v in pairs(defines.entity_status) do
    status_names[v] = {"entity-status."..string.gsub(k, "_", "-")}
end

local status_diode_sprites = {
    [defines.entity_status_diode.green] = "utility.status_working",
    [defines.entity_status_diode.yellow] = "utility.status_yellow",
    [defines.entity_status_diode.red] = "utility.status_not_working",
}
local status_sprites = {
    [defines.entity_status.working] = "utility.status_working",
    [defines.entity_status.frozen] = "utility.status_not_working",
    [defines.entity_status.ghost] = "utility.status_yellow",
}

local handlers = {}

---@param player LuaPlayer
local function update_gui(player)
    local pcomb = storage.opened_combinators[player.index]
    if not pcomb then return end
    if not pcomb:valid() then
        storage.opened_combinators[player.index] = nil
        local window = player.gui.screen.player_combinator_window
        if window then
            window.destroy()
        end
        return
    end
    local refs = storage.refs[player.index]
    local control = pcomb.control

    refs.mode_dropdown.selected_index = pcomb.mode

    refs.metadata_signals_flow.visible = pcomb.mode == 2

    refs.player_index_signal.elem_value = pcomb.index_signal
    refs.is_admin_signal.elem_value = pcomb.admin
    refs.ticks_afk_signal.elem_value = pcomb.afk_time
    refs.ticks_since_last_online_signal.elem_value = pcomb.last_online_ticks_ago
    refs.total_ticks_online_signal.elem_value = pcomb.online_time
    refs.player_color_signal.elem_value = pcomb.color

    do
        local cf = refs.connections_frame
        cf.clear()
        cf.add{type = "label", style = "subheader_caption_label", caption = {"", {"gui-arithmetic.input"}, ":"}}
        local input_connector_red = control.get_circuit_network(defines.wire_connector_id.combinator_input_red)
        local input_connector_green = control.get_circuit_network(defines.wire_connector_id.combinator_input_green)
        if not input_connector_red and not input_connector_green then
            cf.add{type = "label", style = "label", caption = {"gui-control-behavior.not-connected"}}
        else
            cf.add{type = "label", style = "label", caption = {"gui-control-behavior.connected-to-network"}}
            if input_connector_red then
                cf.add{type = "label", style = "label", caption = {"gui-control-behavior.red-network-id", input_connector_red.network_id}}
            end
            if input_connector_green then
                cf.add{type = "label", style = "label", caption = {"gui-control-behavior.green-network-id", input_connector_green.network_id}}
            end
        end

        local e = cf.add{type = "empty-widget"}
        e.style.horizontally_stretchable = true

        cf.add{type = "label", style = "subheader_caption_label", caption = {"", {"gui-arithmetic.input"}, ":"}}
        local output_connector_red = control.get_circuit_network(defines.wire_connector_id.combinator_output_red)
        local output_connector_green = control.get_circuit_network(defines.wire_connector_id.combinator_output_green)
        if not output_connector_red and not output_connector_green then
            cf.add{type = "label", style = "label", caption = {"gui-control-behavior.not-connected"}}
        else
            cf.add{type = "label", style = "label", caption = {"gui-control-behavior.connected-to-network"}}
            if output_connector_red then
                cf.add{type = "label", style = "label", caption = {"gui-control-behavior.red-network-id", output_connector_red.network_id}}
            end
            if output_connector_green then
                cf.add{type = "label", style = "label", caption = {"gui-control-behavior.green-network-id", output_connector_green.network_id}}
            end
        end
    end
    
    local custom_status = pcomb.entity.custom_status
    if custom_status then
        refs.status_sprite.sprite = status_diode_sprites[custom_status.diode]
        refs.status_label.caption = custom_status.label
    else
        local status = pcomb.entity.status
        if not status and pcomb.is_ghost then
            status = defines.entity_status.ghost
        end
        refs.status_label.caption = status_names[status]
        refs.status_sprite.sprite = status_sprites[status] or "utility.status_blue"
    end

    if #pcomb.entity.combinator_description > 0 then
        refs.description_subheader.visible = true
        refs.description_label.visible = true
        refs.description_scroll_pane.visible = true
        refs.description_label.caption = pcomb.entity.combinator_description
        refs.description_button.style = "mini_button_aligned_to_text_vertically"
        refs.description_button.caption = ""
        refs.description_button.sprite = "utility.rename_icon"
    else
        refs.description_subheader.visible = false
        refs.description_label.visible = false
        refs.description_scroll_pane.visible = false
        refs.description_button.style = "button"
        refs.description_button.caption = {"gui-edit-label.add-description"}
        refs.description_button.sprite = nil
    end
end

local function signal_flow(name)
    return {
        args = {type = "flow", direction = "horizontal"},
        style_mods = {vertical_align = "center"},
        {
            args = {type = "choose-elem-button", name = name, style = "slot_button_in_shallow_frame", elem_type = "signal"},
            _elem_changed = handlers[name.."_changed"]
        },
        {
            args = {type = "flow"},
            {
                args = {type = "label", style = "subheader_semibold_label", caption = {"player-combinator-gui."..name}, tooltip = {"?", {"player-combinator-gui-tooltip."..name}, ""} },
            },
        },
    }
end

---@param pcomb PlayerCombinator
---@param player LuaPlayer
function gui.open(pcomb, player)
    local refs = storage.refs[player.index]
    if not refs then
        storage.refs[player.index] = {}
        refs = storage.refs[player.index]
    end
    glib.add(player.gui.screen, {
        args = {type = "frame", name = "player_combinator_window", direction = "vertical"},
        style_mods = {width = 448, maximal_height = 867},
        elem_mods = {auto_center = true},
        _closed = handlers.close_window,
        children = {
            {
                args = {type = "flow"},
                style_mods = {horizontal_spacing = 8},
                drag_target = "player_combinator_window",
                {
                    args = {type = "label", caption = pcomb:localised_name(), style = "frame_title", ignored_by_interaction = true},
                    style_mods = {top_margin = -3, bottom_margin = 3},
                },
                {
                    args = {type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true},
                    style_mods = {height = 24, right_margin = 4, horizontally_stretchable = true},
                },
                {
                    args = {type = "sprite-button", style = "close_button", sprite = "utility/close"},
                    _click = handlers.close_window,
                }
            },
            {
                args = {type = "frame", style = "entity_frame", direction = "vertical"},
                {
                    args = {type = "frame", name = "connections_frame", style = "subheader_frame_with_text_on_the_right"},
                    style_mods = {top_margin = -8, left_margin = -12, right_margin = -12, horizontally_stretchable = true, vertically_stretchable = true},
                    {
                        args = {type = "label", style = "subheader_caption_label", caption = {"", {"gui-arithmetic.input"}, ":"}},
                    },
                    {
                        args = {type = "empty-widget"},
                        style_mods = {horizontally_stretchable = true},
                    },
                    {
                        args = {type = "label", style = "caption_label", caption = {"", {"gui-arithmetic.output"}, ":"}},
                    },
                },
                {
                    args = {type = "flow"},
                    style_mods = {vertical_align = "center"},
                    {
                        args = {type = "sprite", name = "status_sprite", sprite = "utility.status_working"},
                    },
                    {
                        args = {type = "label", name = "status_label", caption = {"entity-status.working"}}
                    }
                },
                {
                    args = {type = "frame", style = "deep_frame_in_shallow_frame"},
                    {
                        args = {type = "entity-preview", style = "wide_entity_button"},
                        elem_mods = {entity = pcomb.entity},
                    },
                },
                {
                    args = {type = "flow", style = "player_input_horizontal_flow"},
                    {
                        args = {type = "label", style = "caption_label", caption = {"gui-control-behavior.mode-of-operation"}}
                    },
                    {
                        args = {
                            type = "drop-down",
                            name = "mode_dropdown",
                            items = {
                                {"player-combinator-gui.name_mode"},
                                {"player-combinator-gui.metadata_mode"},
                            },
                        },
                        style_mods = {horizontally_stretchable = true},
                        _selection_state_changed = handlers.mode_changed,
                    },
                },
                {
                    args = {type = "label", name = "mode_description", caption = {"player-combinator-gui.name_mode_description"}},
                    style_mods = {horizontally_stretchable = true, horizontally_squashable = true, single_line = false},
                },
                {
                    args = {type = "line"},
                    style_mods = {horizontally_stretchable = true},
                },
                signal_flow("player_index_signal"),
                {
                    args = {type = "line"},
                    style_mods = {horizontally_stretchable = true},
                },
                {
                    args = {type = "flow", name = "metadata_signals_flow", direction = "vertical", style = "two_module_spacing_vertical_flow"},
                    children = {
                        signal_flow("is_admin_signal"),
                        signal_flow("ticks_afk_signal"),
                        signal_flow("ticks_since_last_online_signal"),
                        signal_flow("total_ticks_online_signal"),
                        signal_flow("player_color_signal"),
                        {
                            args = {type = "line"},
                            style_mods = {horizontally_stretchable = true},
                        },
                    }
                },
                {
                    args = {type = "flow", direction = "vertical"},
                    {
                        args = {type = "flow", direction = "horizontal"},
                        {
                            args = {type = "label", style = "semibold_label", name = "description_subheader", caption = {"description.player-description"}}
                        },
                        {
                            args = {type = "sprite-button", name = "description_button", style = "mini_button_aligned_to_text_vertically",
                                caption = {"gui-edit-label.add-description"}},
                            _click = handlers.edit_description,
                        },
                    },
                    {
                        args = {type = "scroll-pane", style = "shallow_scroll_pane", name = "description_scroll_pane"},
                        style_mods = {minimal_height = 100},
                        {
                            args = {type = "label", name = "description_label", caption = pcomb.entity.combinator_description},
                            style_mods = {horizontally_squashable = true, single_line = false},
                        },
                    },
                },
            }
        }
    }, refs)
    storage.opened_combinators[player.index] = pcomb
    player.opened = refs.player_combinator_window
    update_gui(player)
end

function handlers.close_window(event)
    if storage.do_not_close_gui then return end
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    player.gui.screen.player_combinator_window.destroy()
    storage.opened_combinators[event.player_index] = nil
end

function handlers.mode_changed(event)
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local dropdown = event.element
    local pcomb = storage.opened_combinators[player.index]
    local param = pcomb.control.parameters

    pcomb.mode = dropdown.selected_index
    pcomb:on_gui_changed_settings()
    update_gui(player)
end

local signal_name_to_field = {
    player_index_signal = "index_signal",
    is_admin_signal = "admin",
    ticks_afk_signal = "afk_time",
    ticks_since_last_online_signal = "last_online_ticks_ago",
    total_ticks_online_signal = "online_time",
    player_color_signal = "color",
}

for name, field in pairs(signal_name_to_field) do
    ---@param event EventData.on_gui_elem_changed
    handlers[name.."_changed"] = function(event)
        local pcomb = storage.opened_combinators[event.player_index]
        if not pcomb then return end
        local refs = storage.refs[event.player_index]
        pcomb[field] = event.element.elem_value --[[@as SignalID]]
        pcomb:on_gui_changed_settings()
    end
end

---@param event EventData.on_gui_click
function handlers.edit_description(event)
    local player = game.get_player(event.player_index)
    ---@cast player -?
    local pcomb = storage.opened_combinators[player.index]
    local refs = storage.refs[event.player_index]
    glib.add(player.gui.screen, {
        args = {type = "frame", name = "description_window", style = "inset_frame_container_frame", direction = "vertical"},
        style_mods = {width = 400, maximal_height = 867},
        elem_mods = {auto_center = true},
        _closed = handlers.close_description_window,
        {
            args = {type = "flow", direction = "vertical"},
            style_mods = {vertical_spacing = 0},
            {
                args = {type = "flow", style = "frame_header_flow"},
                style_mods = {horizontal_spacing = 8},
                drag_target = "description_window",
                {
                    args = {type = "label", caption = {"gui-edit-label.edit-description"}, style = "frame_title", ignored_by_interaction = true},
                    style_mods = {top_margin = -3, bottom_margin = 3},
                },
                {
                    args = {type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true},
                    style_mods = {height = 24, right_margin = 4, horizontally_stretchable = true},
                },
                {
                    args = {type = "sprite-button", style = "cancel_close_button", sprite = "utility/close"},
                    _click = handlers.close_description_window,
                }
            },
            {
                args = {type = "flow", direction = "vertical", style = "inset_frame_container_vertical_flow"},
                style_mods = {horizontal_align = "right"},
                {
                    args = {type = "text-box", name = "description_textbox", style = "edit_blueprint_description_textbox",
                        icon_selector = true, text = pcomb.entity.combinator_description},
                    elem_mods = {word_wrap = true},
                },
            },
            {
                args = {type = "flow"},
                style_mods = {top_margin = 12}, -- easiest solution to not add another flow
                {
                    args = {type = "empty-widget", style = "draggable_space"},
                    style_mods = {horizontally_stretchable = true, vertically_stretchable = true, left_margin = 0},
                },
                {
                    args = {type = "button", style = "confirm_button", caption = {"gui-edit-label.save-description"}},
                    _click = handlers.save_description,
                    _confirm = handlers.save_description,
                },
            }
        },
    }, refs)
    refs.description_textbox.focus()
    storage.do_not_close_gui = true
    player.opened = refs.description_window
    storage.do_not_close_gui = nil
end

function handlers.save_description(event)
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local pcomb = storage.opened_combinators[player.index]
    local refs = storage.refs[event.player_index]
    local new_description_text
    if player.gui.screen.description_window then
        new_description_text = refs.description_textbox.text
        player.gui.screen.description_window.destroy()
        player.opened = player.gui.screen.player_combinator_window
    end
    pcomb.entity.combinator_description = new_description_text
    update_gui(player)
end

function handlers.close_description_window(event)
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    player.gui.screen.description_window.destroy()
    player.opened = player.gui.screen.player_combinator_window
end

function gui.on_tick()
    for _, player in pairs(game.connected_players) do
        update_gui(player)
    end
end

glib.register_handlers(handlers)

return gui