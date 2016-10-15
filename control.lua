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

  if #s>31 then
    s=s:sub(1,31)
  end

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
    {index=1,count=0,signal={name="signal-grey",type="virtual"}}
  }

  for c,i in pairs(letters) do
    txSignals[#txSignals+1]={index=#txSignals+1,count=i,signal={name=charsig(c),type="virtual"}}
  end

  return txSignals
end

local function onTick()
  if game.tick % 60 == 0 then

    for forcename,controls in pairs(global.controls) do
      global.researchframe[forcename][1].count=math.floor(game.forces[forcename].research_progress * 100)

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

local function UpdateResearch(event)
  local newframes = {}
  for forcename,force in pairs(game.forces) do

    if force.current_research then
      newframes[forcename] = stringsig(force.current_research.name)
    else
      newframes[forcename] = {
        {index=1,count=0,signal={name="signal-grey",type="virtual"}}
      }
    end
  end
  global.researchframe = newframes
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
