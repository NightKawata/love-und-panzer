require "libs.screen"
require "libs.panzer.client"

local function load(self)
	self.gui = gui()
	self.client = self.data.client
	self.id = self.data.id
	
	-- GUI Theme
	self.theme = {
		padding	= 8,
		tiny	= 16,
		small	= 32,
		medium	= 64,
		large	= 128,
		xlarge	= 256,
	}
	
	--[[ Create GUI Elements ]]--
	
	self.chat = {
		scope = "global"
	}
	
	-- Chat Group
	self.chat.group = self.gui:group(nil, {
		x = 0,
		y = windowHeight - 200,
		w = 400,
		h = 200,
	})
	
	-- Global Button
	self.chat.buttonGlobal = self.gui:button("Global", {
		x = 0,
		y = 0,
		w = 50,
		h = self.theme.tiny,
	}, self.chat.group)
	
	-- Local Button
	self.chat.buttonGame = self.gui:button("Game", {
		x = 50,
		y = 0,
		w = 50,
		h = self.theme.tiny,
	}, self.chat.group)
	
	-- Team Button
	self.chat.buttonTeam = self.gui:button("Team", {
		x = 100,
		y = 0,
		w = 50,
		h = self.theme.tiny,
	}, self.chat.group)
	
	-- Chat Text
	self.chat.global = self.gui:scrollgroup(nil, {
		x = 0,
		y = self.theme.tiny,
		w = 400 - self.theme.tiny,
		h = 200 - self.theme.tiny * 2,
	}, self.chat.group)
	
	self.chat.game = self.gui:scrollgroup(nil, {
		x = 0,
		y = self.theme.tiny,
		w = 400,
		h = 200 - self.theme.tiny * 2,
	}, self.chat.group)
	
	self.chat.team = self.gui:scrollgroup(nil, {
		x = 0,
		y = self.theme.tiny,
		w = 400,
		h = 200 - self.theme.tiny * 2,
	}, self.chat.group)
	
	-- Chat Input
	self.chat.input = self.gui:input(nil, {
		x = 0,
		y = self.chat.group.pos.h - self.theme.tiny,
		w = 350,
		h = self.theme.tiny,
	}, self.chat.group)
	
	-- Chat Button
	self.chat.send = self.gui:button("Send", {
		x = 350,
		y = self.chat.group.pos.h - self.theme.tiny,
		w = 50,
		h = self.theme.tiny,
	}, self.chat.group)

	--[[ Chat Group Properties ]]--
	self.chat.global:show()
	self.chat.game:hide()
	self.chat.team:hide()
	
	-- Chat Input Properties
	self.chat.input.keydelay = KEY_DELAY
	self.chat.input.keyrepeat = KEY_REPEAT
	
	-- Global Button Properties
	self.chat.buttonGlobal.click = function(this)
		self.chat.scope = "global"
		self.chat.global:show()
		self.chat.game:hide()
		self.chat.team:hide()
	end
	
	-- Game Button Properties
	self.chat.buttonGame.click = function(this)
		self.chat.scope = "game"
		self.chat.global:hide()
		self.chat.game:show()
		self.chat.team:hide()
	end
	
	-- Team Button Properties
	self.chat.buttonTeam.click = function(this)
		self.chat.scope = "team"
		self.chat.global:hide()
		self.chat.game:hide()
		self.chat.team:show()
	end
	
	-- Send Button Properties
	self.chat.send.click = function(this)
		sendChat()
	end

	-- Send the actual message
	function sendChat()
		if self.chat.input.value and self.chat.input.value ~= "" then
			local str = json.encode({
				scope = string.upper(self.chat.scope),
				nickname = _G.settings.name,
				msg = self.chat.input.value,
			})
			local data = string.format("%s %s", "CHAT", str)
			
			self.client.connection:send(data)
			self.chat.input.value = ""
		end
	end
	
	--TESTING
	self.serverlist = {
		server = "",
	}
	-- Serverlist
	self.serverlist.group = self.gui:group(nil, {
		x = windowWidth - 300,
		y = windowHeight - 200,
		w = 300,
		h = 200,
	})

	self.serverlist.text = self.gui:text("", {
		x = 0,
		y = 0,
		w = 300,
		h = 200 - self.theme.tiny,
	}, self.serverlist.group)
	
	self.serverlist.Refresh = self.gui:button("Refresh", {
		x = 0,
		y = self.serverlist.group.pos.h - self.theme.tiny,
		w = 300,
		h = self.theme.tiny,
	}, self.serverlist.group)
	
	-- request new serverlist from server
	self.serverlist.Refresh.click = function(this)
		local data = string.format("%s %s", "SERVERLIST", "")
		self.client.connection:send(data)
	end

	--//TESTING
end

local function update(self, dt)
	self.client:update(dt)
	
	-- Update Global Chat
	if self.client.chat.global then
		self.chat.global:addchild(self.gui:text(self.client.chat.global, {w = self.chat.group.pos.w - self.theme.tiny}), "vertical")
		self.client.chat.global = nil
		
		for k,v in pairs(self.chat.global.children) do
			for k2,v2 in pairs(v) do
				print(k2,v2)
			end
		end
	end
	
	-- Update Game Chat
	if self.client.chat.game then
		self.chat.game:addchild(self.gui:text(self.client.chat.game, {w = self.chat.group.pos.w, h = self.theme.tiny}), "vertical")
		self.client.chat.game = nil
	end
	
	-- Update Team Chat
	if self.client.chat.team then
		self.chat.team:addchild(self.gui:text(self.client.chat.team, {w = self.chat.group.pos.w, h = self.theme.tiny}), "vertical")
		self.client.chat.team = nil
	end
	
	
	if self.client.serverlist.name then
		self.serverlist.server = self.client.serverlist.name
		self.client.serverlist.name = nil
	end

	self.serverlist.text.label = self.serverlist.server
	
	self.gui:update(dt)
end

local function draw(self)
	self.gui:draw()
end

local function keypressed(self, k, unicode)
	if self.gui.focus then
		self.gui:keypress(k, unicode)

		if k == 'return' then
			sendChat()
		end

	end
end

local function mousepressed(self, x, y, button)
	self.gui:mousepress(x, y, button)
end

local function mousereleased(self, x, y, button)
	self.gui:mouserelease(x, y, button)
end

return function(data)
	return Screen {
		name			= "Title",
		load			= load,
		update			= update,
		draw			= draw,
		keypressed		= keypressed,
		mousepressed	= mousepressed,
		mousereleased	= mousereleased,
		data			= data
	}
end
