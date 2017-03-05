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

local function onInit()
  global.playerframes = {}
  for i,p in pairs(game.players) do
    global.playerframes[i]=playerFrame(p)
  end
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

local function onBuilt(event)
  local entity=event.created_entity
  if entity.name == "player-combinator" then
    global.controls = global.controls or {}
    local control = entity.get_or_create_control_behavior()
    table.insert(global.controls,control)
  end
end

script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_built_entity, onBuilt)
script.on_event(defines.events.on_robot_built_entity, onBuilt)
script.on_event(defines.events.on_player_created, onPlayerCreated)
script.on_init(onInit)
