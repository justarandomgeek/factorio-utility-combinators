local function UpdateResearch(event)
  local newframes = {}
  for forcename,force in pairs(game.forces) do

    if force.current_research then
      local extras = {
        {index=1,
        count=math.floor(game.forces[forcename].research_progress * 100),
        signal={name="signal-grey",type="virtual"}},
        {index=2,
        count=force.current_research.research_unit_count,
        signal={name="signal-white",type="virtual"}},

      }

      for i,item in pairs(force.current_research.research_unit_ingredients) do
        extras[#extras+1] = {
          index  = #extras+1,
          count  = item.amount,
          signal = {name=item.name,type=item.type},
        }
      end

      if remote.interfaces['signalstrings'] then
        newframes[forcename] = remote.call('signalstrings','string_to_signals',force.current_research.name, extras)
      else
        newframes[forcename] = extras
      end

    else
      newframes[forcename] = {
        {index=1,count=0,signal={name="signal-grey",type="virtual"}}
      }
    end
  end
  global.researchframe = newframes
end

local function onTick()
  if game.tick % 60 == 0 then

    UpdateResearch()

    for forcename,controls in pairs(global.controls) do
      --global.researchframe[forcename][1].count=math.floor(game.forces[forcename].research_progress * 100)

      for _,control in pairs(controls) do
        if control.valid then
          control.parameters={enabled=true,parameters=global.researchframe[forcename] or {}}
        else
          table.remove(global.controls[forcename],_)
        end
      end
    end
  end
end

local function onBuilt(event)
  local entity=event.created_entity
  if entity.name == "research-combinator" then
    entity.operable = false
    global.controls[entity.force.name] = global.controls[entity.force.name] or {}
    local control = entity.get_or_create_control_behavior()
    table.insert(global.controls[entity.force.name],control)
  end
end

local function onInit()
  global.controls = {}
  UpdateResearch()
end

script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_built_entity, onBuilt)
script.on_event(defines.events.on_robot_built_entity, onBuilt)
script.on_event(defines.events.on_research_started, UpdateResearch)
script.on_event(defines.events.on_research_finished, UpdateResearch)
script.on_event(defines.events.on_force_created, UpdateResearch)
script.on_event(defines.events.on_forces_merging, UpdateResearch)

script.on_init(onInit)
