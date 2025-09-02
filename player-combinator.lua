local sigstr = script.active_mods["signalstrings"] and require("__signalstrings__/signalstrings.lua")

---@class (exact) PlayerCombinator
---@field public entity LuaEntity
---@field private unit_number integer
---@field public control LuaDeciderCombinatorControlBehavior
---@
---@field public index_signal? SignalID
---@
---@field public mode PlayerCombinator.mode
---@
---@field public admin? SignalID
---@field public afk_time? SignalID
---@field public last_online_ticks_ago? SignalID
---@field public online_time? SignalID
---@field public color? SignalID
---@
local pcomb={}


---@type metatable
local pcomb_meta = {
    __index = pcomb,
}

script.register_metatable("PlayerCombinator", pcomb_meta)

---@param ent LuaEntity
---@return PlayerCombinator
local function new(ent)
  local control = ent.get_or_create_control_behavior() --[[@as LuaDeciderCombinatorControlBehavior]]

  local self = setmetatable({
    entity = ent,
    unit_number = ent.unit_number,
    control = control,
  }, pcomb_meta)
  control.parameters = self:load_entity_settings()
  return self
end

---@enum PlayerCombinator.mode
local modes = {
  name = 1,
  metadata = 2
}

---@type {[string]:SignalID}
local default_signal = {
  index_signal = {
    type = "virtual",
    name = "signal-info",
    quality = "normal",
  },

  admin = {
    type = "virtual",
    name = "signal-star",
    quality = "normal",
  },
  afk_time = {
    type = "virtual",
    name = "signal-hourglass",
    quality = "normal",
  },
  last_online_ticks_ago = {
    type = "virtual",
    name = "signal-moon",
    quality = "normal",
  },
  online_time = {
    type = "virtual",
    name = "signal-clock",
    quality = "normal",
  },
  color = {
    type = "virtual",
    name = "signal-white",
    quality = "normal",
  },
}

local no_wires = {red=false, green=false}

---@package
---@return DeciderCombinatorParameters
function pcomb:load_entity_settings()
  local param = self.control.parameters
  local conditions = param.conditions
  if #conditions == 5 then
    self.index_signal = conditions[2].first_signal
    self.mode = conditions[2].constant

    self.admin = conditions[3].first_signal
    self.afk_time = conditions[3].second_signal
    self.last_online_ticks_ago = conditions[4].first_signal
    self.online_time = conditions[4].second_signal
    self.color = conditions[5].first_signal
  elseif #conditions == 2 then
    self.index_signal = conditions[2].first_signal
    self.mode = conditions[2].constant

    self.admin = default_signal.admin
    self.afk_time = default_signal.afk_time
    self.last_online_ticks_ago = default_signal.last_online_ticks_ago
    self.online_time = default_signal.online_time
    self.color = default_signal.color
  else -- no config
    self.index_signal = default_signal.index_signal
    self.mode = modes.name

    self.admin = default_signal.admin
    self.afk_time = default_signal.afk_time
    self.last_online_ticks_ago = default_signal.last_online_ticks_ago
    self.online_time = default_signal.online_time
    self.color = default_signal.color
  end
  param.conditions = self:save_entity_settings()
  return param
end

---@private
---@return DeciderCombinatorCondition[]
function pcomb:save_entity_settings()
  ---@type DeciderCombinatorCondition[]
  return {
    -- always on condition to skip processing the rest...
    {
      first_signal_networks=no_wires,
      comparator="=",
      constant=0,
      second_signal_networks=no_wires,
      -- first compare_type does nothing...
    },
    -- and the rest hold config data...
    {
      comparator="=",
      first_signal = self.index_signal,
      first_signal_networks=no_wires,
      constant = self.mode,
      second_signal_networks=no_wires,
      compare_type = "or", -- how the config group combines with the first condition
    },
    {
      comparator="=",
      first_signal = self.admin,
      first_signal_networks=no_wires,
      second_signal = self.afk_time,
      second_signal_networks=no_wires,
      compare_type = "and" -- any future config rows should be plain ands to make one big config group...
    },
    {
      comparator="=",
      first_signal = self.last_online_ticks_ago,
      first_signal_networks=no_wires,
      second_signal = self.online_time,
      second_signal_networks=no_wires,
      compare_type = "and",
    },
    {
      comparator="=",
      first_signal = self.color,
      first_signal_networks=no_wires,
      second_signal = nil,
      second_signal_networks=no_wires,
      compare_type = "and",
    },
  }
end

---@public
function pcomb:on_gui_changed_settings()
  self.control.parameters = {
    conditions = self:save_entity_settings(),
    outputs = {},
  }
end

---@public
---@param from LuaEntity
function pcomb:on_entity_settings_pasted(from)
  if from.name ~= "player-combinator" then
    self.control.parameters = {
      conditions = self:save_entity_settings(),
      outputs = {},
    }
  end
end

---@type {[PlayerCombinator.mode]:fun(self:PlayerCombinator):DeciderCombinatorOutput[]?}
local mode_handlers = {
  [modes.name] = function(self)
    local entity = self.entity
    if not self.index_signal then return end
    local index = entity.get_signal(self.index_signal, defines.wire_connector_id.combinator_input_green, defines.wire_connector_id.combinator_input_red)
    if index <= 0 or index >= 65536 then return end
    local player = game.get_player(index)
    if not player then return end
    return sigstr.string_to_decider_outputs(player.name)
  end,
  [modes.metadata] = function(self)
    local entity = self.entity
    if not self.index_signal then return end
    local index = entity.get_signal(self.index_signal, defines.wire_connector_id.combinator_input_green, defines.wire_connector_id.combinator_input_red)
    local player = game.get_player(index)
    if not player then return end

    local outputs = {}
    if self.admin and player.admin then
      outputs[#outputs+1] = { signal = self.admin, copy_count_from_input = false, constant = 1 }
    end
    if self.afk_time then
      outputs[#outputs+1] = { signal = self.afk_time, copy_count_from_input = false, constant = player.afk_time }
    end
    if self.last_online_ticks_ago then
      outputs[#outputs+1] = { signal = self.last_online_ticks_ago, copy_count_from_input = false, constant = (game.ticks_played-player.last_online)-1 }
    end
    if self.online_time then
      outputs[#outputs+1] = { signal = self.online_time, copy_count_from_input = false, constant = player.online_time }
    end
    if self.color then
      outputs[#outputs+1] = { signal = self.color, copy_count_from_input = false, constant =
        math.floor(player.color.a*255)*0x1000000 +
        math.floor(player.color.r*255)*0x10000 +
        math.floor(player.color.g*255)*0x100 +
        math.floor(player.color.b*255),
      }
    end
    return outputs
  end,
}

---@public
function pcomb:on_tick()
  
  local control = self.control
  local param = self:load_entity_settings()

  local mode = self.mode

  local handler = mode_handlers[mode]
  if handler then
    param.outputs = handler(self) or {}
  else
    param.outputs = {}
  end

  control.parameters = param
end

---@public
function pcomb:valid()
  if not self.entity.valid then return false end
  if not self.control.valid then return false end
  return true
end

---@public
function pcomb:destroy()
  self.entity.destroy()
end

---@public
---@return LocalisedString
function pcomb:localised_name()
  local entity = self.entity
  if entity.type == "entity-ghost" then
    return entity.ghost_localised_name
  end
  return entity.localised_name
end

return new