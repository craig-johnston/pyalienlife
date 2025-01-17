Mounts = {}
Mounts.events = {}

local transfer_efficiency = 2

Mounts.events.on_init = function()
	global.mounts = global.mounts or {}
end

Mounts.events[239] = function(event)
	for id, spider in pairs(global.mounts) do
		if spider.valid then
			local grid = spider.grid
			for _, equipment in pairs(grid.equipment) do
				local missing = equipment.max_energy - equipment.energy
				if missing > 0 then
					if spider.burner.remaining_burning_fuel < missing / transfer_efficiency then
						equipment.energy = equipment.energy + spider.burner.remaining_burning_fuel * transfer_efficiency
						spider.burner.remaining_burning_fuel = 0
						break
					else
						spider.burner.remaining_burning_fuel = spider.burner.remaining_burning_fuel - missing / transfer_efficiency
						equipment.energy = equipment.energy + missing
					end
				end
			end
		else
			global.mounts[id] = nil
			return
		end
	end
end

local mounts = {
	['crawdad'] = true,
	['dingrido'] = true,
	['spidertron'] = true,
	['phadaisus'] = true,
}

Mounts.events.on_built = function(event)
	local entity = event.created_entity or event.entity
	if not mounts[entity.name] then return end
	entity.grid.put{
		name = 'py-mount-generator',
		position = {3, 0},
	}
	global.mounts[entity.unit_number] = entity
end

Mounts.events.on_destroyed = function(event)
    local entity = event.entity
	local unit_number = entity.unit_number
	if unit_number then global.mounts[unit_number] = nil end
end

Mounts.events.on_player_removed_equipment = function(event)
	if event.equipment == 'py-mount-generator' then
		event.grid.put{
			name = 'py-mount-generator',
			position = {3, 0},
		}
		game.players[event.player_index].remove_item{name = 'py-mount-generator', count = 100}
	end
end