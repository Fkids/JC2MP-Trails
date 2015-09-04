class "sTrails"

function sTrails:__init()
	self:initMessages()
	Events:Subscribe("PlayerChat", self, self.onPlayerChat)
end

function sTrails:initMessages()
	self.messages = {}
	self.messages["Not In Vehicle"] = "You need to be in a vehicle to change trail."
	self.messages["Incorrect Usage"] = "Usage: /trail 0-255 0-255 0-255 | /trail off."
	self.messages["Trail Disabled"] = "Trail has been disabled."
	self.messages["Trail Updated"] = "Trail color has been set to %d %d %d."
end

-- Events
function sTrails:onPlayerChat(args)
	local words = {}
	for word in string.gmatch(args.text, "[^%s]+") do
		table.insert(words, word)
	end
	if not words[1] then return end
	if words[1] ~= "/trail" then return end
	local vehicle = args.player:GetVehicle()
	if not vehicle then
		Chat:Send(args.player, self.messages["Not In Vehicle"], Color.DarkGray)
		return false
	end
	if #words < 2 then
		Chat:Send(args.player, self.messages["Incorrect Usage"], Color.DarkGray)
		return false
	end
	if words[2] == "off" then
		vehicle:SetNetworkValue("Trail", nil)
		Chat:Send(args.player, self.messages["Trail Disabled"], Color.DodgerBlue)
		return false
	end
	if #words < 4 then
		Chat:Send(args.player, self.messages["Incorrect Usage"], Color.DarkGray)
		return false
	end
	local color = {}
	for wordId = 2, 4 do
		local value = tonumber(words[wordId])
		if not value then
			Chat:Send(args.player, self.messages["Incorrect Usage"], Color.DarkGray)
			return false
		end
		table.insert(color, math.clamp(value, 0, 255))
	end
	vehicle:SetNetworkValue("Trail", Color(color[1], color[2], color[3]))
	Chat:Send(args.player, string.format(self.messages["Trail Updated"], color[1], color[2], color[3]), Color.DodgerBlue)
	return false
end

sTrails = sTrails()