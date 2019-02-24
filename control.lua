local function UpdateBonuses()
  for forcename,force in pairs(game.forces) do
    global.bonusframe[forcename] = {
      --{index=1,count=0,signal={name="signal-grey",type="virtual"}}

      {index=1,count=force.worker_robots_storage_bonus    ,signal={name="signal-R",type="virtual"}},
      {index=2,count=force.inserter_stack_size_bonus      ,signal={name="signal-I",type="virtual"}},
      {index=3,count=force.stack_inserter_capacity_bonus  ,signal={name="signal-J",type="virtual"}},
      {index=4,count=force.character_logistic_slot_count  ,signal={name="signal-L",type="virtual"}},
      {index=5,count=force.character_trash_slot_count     ,signal={name="signal-T",type="virtual"}},
      {index=6,count=force.maximum_following_robot_count  ,signal={name="signal-F",type="virtual"}},

    }
  end
end

local function onChange(event)
  UpdateBonuses()
  for forcename,controls in pairs(global.controls) do
    for _,control in pairs(controls) do
      if control.valid then
        control.parameters={enabled=true,parameters=global.bonusframe[forcename] or {}}
      else
        table.remove(global.controls[forcename],_)
      end
    end
  end
end

local function onBuilt(event)
  local entity=event.created_entity
  if entity.name == "bonus-combinator" then
    entity.operable = false
    global.controls[entity.force.name] = global.controls[entity.force.name] or {}
    local control = entity.get_or_create_control_behavior()
    table.insert(global.controls[entity.force.name],control)
    control.parameters={enabled=true,parameters=global.bonusframe[entity.force.name] or {}}
  end
end

local function onInit()
  global.controls = {}
  global.bonusframe = {}
  UpdateBonuses()
end

script.on_event(defines.events.on_built_entity, onBuilt)
script.on_event(defines.events.on_robot_built_entity, onBuilt)
script.on_event(defines.events.on_research_finished, onChange)
script.on_event(defines.events.on_force_created, onChange)
script.on_event(defines.events.on_forces_merging, onChange)

script.on_init(onInit)

remote.add_interface("bonus",{
  get_global = function() return global end,
  update = function() return onChange() end,
})
