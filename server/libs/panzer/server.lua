Class = require "libs.hump.class"
json = require "libs.dkjson"
require "libs.LUBE.LUBE"

Server = Class {
    function(self)
		self.games		= {}
		self.players	= {}
	end
}

--[[
	Start Server
	
	port		= Port to listen on
]]--
function Server:start(port)
	self.connection = lube.tcpServer()
	self.connection.handshake = "loveTanks"
	self.connection:setPing(true, 6, "lePing\n")
	
	self.connection:listen(tonumber(port))
	print('Server started on port: ' .. port)
	
	self.connection.callbacks.recv = function(d, id) self:recv(d, id) end
	self.connection.callbacks.connect = function(id) self:connect(id) end
	self.connection.callbacks.disconnect = function(id) self:disconnect(id) end
end

--[[
	Client Connects to Server
	
	clientId		= Unique client ID
]]--
function Server:connect(clientId)
	print('Client connected: ' .. tostring(clientId))
	
	local new = json.encode({name="somegame",pass="qwerty"}) --debug
	self:newGame(new,clientId) --debug

	local str = json.encode(self.games)
	local data = string.format("%s %s", "GAMELIST", str)
	
	self.connection:send(data, clientId)
end

--[[
	Client Disconnects from Server
	
	clientId		= Unique client ID
]]--
function Server:disconnect(clientId)
	print('Client disconnected: ' .. tostring(clientId))
end

--[[
	Receive Data from Client
]]--
function Server:recv(data, clientId)
	print('Client data received from: ' .. tostring(clientId) .. ' containing: ' .. data)
	
	if data then
		cmd, params = data:match("^(%S*) (.*)")
		
		if cmd == "CHAT" then
			self:sendChat(params, clientId)
		elseif cmd == "NEWGAME" then
			self:newGame(params, clientId)
		elseif cmd == "SERVERLIST" then
			self:sendServerList(clientId)
		--[[
		elseif cmd == "MOVE" then
			local x, y = params:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
			assert(x and y)
			x, y = tonumber(x), tonumber(y)

			local ent = world[entity] or {x=0, y=0}
			world[entity] = {x=ent.x+x, y=ent.y+y}
		elseif cmd == "AT" then
			local x, y = params:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
			assert(x and y)
			x, y = tonumber(x), tonumber(y)

			world[entity] = {x=x, y=y}
		]]--
		else
			print("Unrecognized command: ", cmd)
		end
	end
end

function Server:update(dt)
	self.connection:update(dt)
end

--[[
	Send Chat Message
	
	params			= Scope, Message of chat , Nickname
	clientId		= Unique client ID
]]--
function Server:sendChat(params, clientId)
	local id = tostring(clientId)
	local chat = json.decode(params)
	local str = json.encode({
		scope = chat.scope,
		msg = chat.nickname .. ": " .. chat.msg,
	})
	local data = string.format("%s %s", "CHAT", str)
	
	self.connection:send(data)
end

--[[
	Create New Game
	
	params			= Name, Password of game
	clientId		= Unique client ID
]]--
function Server:newGame(params, clientId)
	local id = tostring(clientId)
	local str = json.decode(params)
	local count = 1
	
	while self.games[count] do
		count = count + 1
	end
	
	self.games[count] = {
		name		= str.name,
		pass		= str.pass,
		host		= id,
		players		= {
			{
				id		= id,
				name	= id,
			},
		},
	}
end

--TESTING
function Server:sendServerList(clientId)

	local str = json.encode(self.games)
	local data = string.format("%s %s", "GAMELIST", str)
	
	self.connection:send(data, clientId)
end
--//TESTING