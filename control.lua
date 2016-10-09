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

local function charsig(c)
	local charmap={
    ["0"]='signal-0',["1"]='signal-1',["2"]='signal-2',["3"]='signal-3',["4"]='signal-4',
    ["5"]='signal-5',["6"]='signal-6',["7"]='signal-7',["8"]='signal-8',["9"]='signal-9',
    ["A"]='signal-A',["B"]='signal-B',["C"]='signal-C',["D"]='signal-D',["E"]='signal-E',
		["F"]='signal-F',["G"]='signal-G',["H"]='signal-H',["I"]='signal-I',["J"]='signal-J',
		["K"]='signal-K',["L"]='signal-L',["M"]='signal-M',["N"]='signal-N',["O"]='signal-O',
		["P"]='signal-P',["Q"]='signal-Q',["R"]='signal-R',["S"]='signal-S',["T"]='signal-T',
		["U"]='signal-U',["V"]='signal-V',["W"]='signal-W',["X"]='signal-X',["Y"]='signal-Y',
		["Z"]='signal-Z'
	}
	if charmap[c] then
		return charmap[c]
	else
		return nil --'signal-blue'
	end
end

local function stringsig(s)
  local s = string.upper(s or "")
  local letters = {}
  local i=1
  while s do
    local c
    if #s > 1 then
      c,s=s:sub(1,1),s:sub(2)
    else
      c,s=s,nil
    end
    letters[c]=(letters[c] or 0)+i
    i=i*2
  end

  local txSignals = {
    {index=1,count=0,signal={name="signal-green",type="virtual"}},
    {index=2,count=0,signal={name="signal-red",type="virtual"}}
  }

  for c,i in pairs(letters) do
    txSignals[#txSignals+1]={index=#txSignals+1,count=i,signal={name=charsig(c),type="virtual"}}
  end

  return txSignals
end

local function onInit()
  global.playerframes = {}
  for i,p in pairs(game.players) do
    global.playerframes[i]=stringsig(p.name)
    global.playerframes[i][1].count= p.connected and 1 or 0
    global.playerframes[i][2].count= p.admin and 1 or 0
  end
end

local function onPlayerCreated(event)
  local i = event.player_index
  global.playerframes[i]=stringsig(p.name)
  global.playerframes[i][1].count= p.connected and 1 or 0
  global.playerframes[i][2].count= p.admin and 1 or 0
end

local function onTick()
  if game.tick%300==0 then
    for i,p in pairs(game.players) do
      global.playerframes[i][1].count= p.connected and 1 or 0
      global.playerframes[i][2].count= p.admin and 1 or 0
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
