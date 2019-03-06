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
  elseif entity.name == "location-combinator" then
    local control = entity.get_or_create_control_behavior()
    control.enabled=true
    control.parameters={parameters={
      {index=1,count=math.floor(entity.position.x),signal={name="signal-X",type="virtual"}},
      {index=2,count=math.floor(entity.position.y),signal={name="signal-Y",type="virtual"}},
      {index=3,count=entity.surface.index,signal={name="signal-Z",type="virtual"}}
    }}
    entity.operable=false
  elseif entity.name == "player-combinator" then
    global.controls = global.controls or {}
    local control = entity.get_or_create_control_behavior()
    table.insert(global.controls,control)
  end
end

local function onInit()
  -- bonus combinator
  global.controls = {}
  global.bonusframe = {}
  UpdateBonuses()

  -- player combinator
  global.playerframes = {}
  for i,p in pairs(game.players) do
    global.playerframes[i]=playerFrame(p)
  end
end

local function get_signal_value(control,signal)
	local redval,greenval=0,0

	local rednetwork = control.get_circuit_network(defines.wire_type.red)
	if rednetwork then
	  redval = rednetwork.get_signal(signal)
	end

	local greennetwork = control.get_circuit_network(defines.wire_type.green)
	if greennetwork then
	  greenval = greennetwork.get_signal(signal)
	end
	return(redval + greenval)
end

local function playerFrame(player)
  return remote.call('signalstrings','string_to_signals',player.name,{
    {index=1,count=player.connected and 1 or 0 ,signal={name="signal-green",type="virtual"}},
    {index=2,count=player.admin and 1 or 0 ,signal={name="signal-red",type="virtual"}},
  })
end


local function onPlayerCreated(event)
  local i = event.player_index
  local p = game.players[i]
  global.playerframes[i]=playerFrame(p)
end

local function onTick()
  if game.tick%300==0 then
    for i,p in pairs(game.players) do
      global.playerframes[i]=playerFrame(p)
    end

    global.globalframe={
      {index=1,count=#game.connected_players,signal={name="signal-green",type="virtual"}},
      {index=2,count=#game.players,signal={name="signal-blue",type="virtual"}},
    }
  end

  if global.controls then
    if not global.controls[global.nextcontrol] then
      global.nextcontrol = nil
    end
    local control = {}
    global.nextcontrol,control = next(global.controls,global.nextcontrol)
    if control then
      if control.valid then
        local req = get_signal_value(control,{name="signal-grey",type="virtual"})
        if req == 0 then
          control.parameters={enabled=true,parameters=global.globalframe}
        else
          control.parameters={enabled=true,parameters=global.playerframes[req] or {}}
        end
      else
        table.remove(global.controls,global.nextcontrol)
        global.nextcontrol=nil
      end
    end
  end
end


script.on_event(defines.events.on_research_finished, onChange)
script.on_event(defines.events.on_force_created, onChange)
script.on_event(defines.events.on_forces_merging, onChange)
script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_built_entity, onBuilt)
script.on_event(defines.events.on_robot_built_entity, onBuilt)
script.on_event(defines.events.on_player_created, onPlayerCreated)
script.on_init(onInit)
