class "cTrails"

function cTrails:__init()
	self:initVars()
	Events:Subscribe("GameRender", self, self.onGameRender)
end

function cTrails:initVars()
	self.particles = {}
	self.sideways = math.pi / 2
end

-- Events
function cTrails:onGameRender()
	local players = {LocalPlayer}
	for player in Client:GetStreamedPlayers() do
		table.insert(players, player)
	end
	for _, player in pairs(players) do
		if player:GetState() == PlayerState.InVehicle then
			local vehicle = player:GetVehicle()
			if IsValid(vehicle) then
				local color = vehicle:GetValue("Trail")
				if color then
					local vehicleId = vehicle:GetId() + 1
					local angle = vehicle:GetAngle()
					local position = vehicle:GetPosition() + angle * Vector3(0, 0.8, 2)
					if not self.particles[vehicleId] then self.particles[vehicleId] = {} end
					local smooth = Vector3.Dot(vehicle:GetLinearVelocity():Normalized(), angle * Vector3.Forward) > 0.9997
					local speed = vehicle:GetLinearVelocity():Length() / 15
					if smooth and speed > 1 then
						table.insert(self.particles[vehicleId], {position + angle * Vector3(-0.8, 0, 0), angle, speed, 255})
						table.insert(self.particles[vehicleId], {position + angle * Vector3(0.8, 0, 0), angle, speed, 255})
					end
					local unused = {}
					local alpha = math.min(speed - 1, 1)
					for particleId, data in pairs(self.particles[vehicleId]) do
						local transform = Transform3()
						transform:Translate(data[1])
						transform:Rotate(data[2] * Angle(self.sideways, self.sideways, 0))
						transform:Scale(0.5)
						Render:SetTransform(transform)
						Render:FillArea(Vector3.Zero, Vector3(data[3], 0.05, 0.05), Color(color.r, color.g, color.b, data[4] * alpha))
						data[4] = data[4] - 3
						if data[4] < 5 then unused[particleId] = true end
						Render:ResetTransform()
					end
					for particleId in pairs(unused) do
						self.particles[vehicleId][particleId] = nil
					end
				end
			end
		end
	end
end

cTrails = cTrails()