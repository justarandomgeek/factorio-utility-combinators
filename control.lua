local new_pcomb = require('player-combinator')
local gui = require('gui')

---@param signal SignalID
---@param value int32
---@return LogisticFilter
local function signal_value(signal, value)
  value = math.min(math.max(value, -0x80000000), 0x7fffffff)
  return {
    value = {
      type = signal.type or "item",
      name = signal.name,
      quality = signal.quality or "normal",
      comparator = "=",
    },
    min = value,
  }
end

---@param target UCControl
---@param filters LogisticFilter[]
---@return boolean
local function write_control(target, filters)
  local entity = target.entity
  if not entity.valid then return false end

  local control = target.control
  if not (control and control.valid) then
    control = entity.get_or_create_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
    target.control = control
  end

  --TODO: check/force exactly one unnamed section
  control.enabled = true
  control.sections[1].filters=filters or {}
  return true
end

local function UpdateBonuses()
  for _,force in pairs(game.forces) do
    storage.bonusframe[force.index] = {
      signal_value({name="lab",type="item"},force.laboratory_productivity_bonus),
      signal_value({name="logistic-robot",type="item"},force.worker_robots_storage_bonus),
      signal_value({name="fast-inserter",type="item"},force.inserter_stack_size_bonus),
      signal_value({name="bulk-inserter",type="item"},force.bulk_inserter_capacity_bonus),
      signal_value({name="turbo-transport-belt",type="item"},force.belt_stack_size_bonus),
      signal_value({name="toolbelt-equipment",type="item"},force.character_inventory_slots_bonus),
      signal_value({name="big-mining-drill",type="item"},force.mining_drill_productivity_bonus * 100),
      signal_value({name="locomotive",type="item"},force.train_braking_force_bonus),
      signal_value({name="signal-heart",type="virtual"},force.character_health_bonus),
      signal_value({name="signal-B",type="virtual"},force.character_build_distance_bonus),
      signal_value({name="signal-D",type="virtual"},force.character_item_drop_distance_bonus),
      signal_value({name="signal-R",type="virtual"},force.character_resource_reach_distance_bonus),
      signal_value({name="signal-I",type="virtual"},force.character_item_pickup_distance_bonus),
      signal_value({name="signal-L",type="virtual"},force.character_loot_pickup_distance_bonus),
      signal_value({name="signal-F",type="virtual"},force.maximum_following_robot_count),
    }
  end
end

local function UpdateResearch()
  ---@type {[integer]:LogisticFilter[]}
  local newframes = {}
  for _,force in pairs(game.forces) do

    if force.current_research then
      ---@type LogisticFilter[]
      local frame = {
        signal_value({name="signal-info",type="virtual"},math.floor(game.forces[force.index].research_progress * 100)),
        signal_value({name="signal-stack-size",type="virtual"},force.current_research.research_unit_count),
        signal_value({name="signal-T",type="virtual"},force.current_research.research_unit_energy),
      }

      for _,item in pairs(force.current_research.research_unit_ingredients) do
        frame[#frame+1] = signal_value(item--[[@as SignalID]], item.amount)
      end
      newframes[force.index] = frame
    end
  end
  storage.researchframe = newframes
end

script.on_event({
  defines.events.on_research_started,
  defines.events.on_research_finished,
  defines.events.on_research_moved,
  defines.events.on_research_cancelled,
  defines.events.on_research_reversed,
  defines.events.on_force_created,
  defines.events.on_forces_merging
  }, function()
  UpdateBonuses()
  UpdateResearch()

  for n,rcc in pairs(storage.researchcc) do
    if not (rcc.entity.valid and write_control(rcc, storage.researchframe[rcc.entity.force.index])) then
      storage.researchcc[n] = nil
    end
  end
  for n,bcc in pairs(storage.bonuscc) do
    if not (bcc.entity.valid and write_control(bcc, storage.bonusframe[bcc.entity.force.index])) then
      storage.bonuscc[n] = nil
    end
  end
end)

---@type {[string]:fun(entity:LuaEntity)}
local onBuilt = {
  ["bonus-combinator"] = function(entity)
    entity.operable = false
    local bcc = {entity=entity}
    storage.bonuscc[entity.unit_number] = bcc
    write_control(bcc, storage.bonusframe[entity.force.index])
  end,
  ["location-combinator"] = function(entity)
    entity.operable=false
    local lcc = {entity=entity}
    write_control(lcc, {
      signal_value({name="signal-X",type="virtual"},math.floor(entity.position.x)),
      signal_value({name="signal-Y",type="virtual"},math.floor(entity.position.y)),
      signal_value({name="signal-Z",type="virtual"},entity.surface.index),
    })
  end,
  ["research-combinator"] = function(entity)
    entity.operable = false
    local rcc = {entity=entity}
    storage.researchcc[entity.unit_number] = rcc
    write_control(rcc, storage.researchframe[entity.force.index])
  end,
  ["player-combinator"] = function (entity)
    storage.playercombs[entity.unit_number] = new_pcomb(entity)
  end
}

---@class (exact) UCControl
---@field entity LuaEntity
---@field control? LuaConstantCombinatorControlBehavior

local function on_init()
  ---@class (exact) UCStorage
  ---@field bonuscc {[integer]:UCControl} unit_number -> entity,control
  ---@field bonusframe {[integer]:LogisticFilter[]} forceid -> data
  ---@field researchcc {[integer]:UCControl} unit_number -> entity,control
  ---@field researchframe {[integer]:LogisticFilter[]} forceid -> data
  ---@field playercombs {[integer]:PlayerCombinator}
  ---@field playercomb_ghosts {[integer]:PlayerCombinator}
  ---@field refs {[string]:LuaGuiElement} gui element references
  ---@field opened_combinators {[integer]:PlayerCombinator} player_index -> combinator data
  storage = {
    bonuscc = {},
    bonusframe = {},

    researchcc = {},
    researchframe = {},
    playercombs = {},
    playercomb_ghosts = {},
    refs = {},
    opened_combinators = {},
  }

  UpdateBonuses()
  UpdateResearch()

  -- index existing combinators (init and config changed to capture from deprecated mods as well)
  -- and re-index the world
  for _,surf in pairs(game.surfaces) do
    for _,entity in pairs(surf.find_entities_filtered{name = {"bonus-combinator", "location-combinator", "research-combinator", "player-combinator"}}) do
      local handler = onBuilt[entity.name]
      if handler then
        handler(entity)
      end
    end
  end
end

script.on_init(on_init)
script.on_configuration_changed(function(data)
  if __DebugAdapter or data.mod_changes and data.mod_changes["utility-combinators"] then
    on_init()
  end
end)

script.on_nth_tick(60, function()
  UpdateResearch()
  for n,rcc in pairs(storage.researchcc) do
    if not (rcc.entity.valid and write_control(rcc, storage.researchframe[rcc.entity.force.index])) then
      storage.researchcc[n] = nil
    end
  end
end)

---@param collection {[integer?]:{ valid:(fun():boolean), (on_tick:fun()), (destroy:fun())  }}
local function tick_or_cleanup(collection)
  for unit_number, obj in pairs(collection) do
    if obj:valid() then
      obj:on_tick()
    else
      obj:destroy()
      collection[unit_number] = nil
    end
  end
end

script.on_event(defines.events.on_tick, function()
  tick_or_cleanup(storage.playercombs)
  tick_or_cleanup(storage.playercomb_ghosts)
  gui.on_tick()
end)

script.on_event(defines.events.on_script_trigger_effect, function (event)
  if event.effect_id == "utility-combinator-created" then
    local entity = event.cause_entity
    if entity then
      local handler = onBuilt[entity.name]
      if handler then
        handler(entity)
      end
    end
  end
end)

---@generic T
---@param entity LuaEntity
---@param ghost_storage table<integer,T>
---@return T
local function get_or_create_ghost(entity, ghost_storage)
  local ghost = ghost_storage[entity.unit_number]
  if not ghost then
    ghost = new_pcomb(entity)
    ghost_storage[entity.unit_number] = ghost
  end
  return ghost
end

script.on_event(defines.events.on_gui_opened, function (event)
  local entity = event.entity
  if not entity then return end
  local pcomb 
  if entity.name == "player-combinator" then
    pcomb =  storage.playercombs[entity.unit_number]
  elseif entity.name == "entity-ghost" and entity.ghost_name == "player-combinator" then
    pcomb = get_or_create_ghost(entity, storage.playercomb_ghosts)
  end
  if pcomb then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    gui.open(pcomb, player)
  end
end)