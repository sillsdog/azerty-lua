_G.discordia = require('discordia')
_G.client = discordia.Client({cacheAllMembers = true})
_G.prefix = '!'
discordia.extensions()
_G.commands = {}
_G.ontime = os.time()

function _G.addCommand(name,func)
	local temp = function(m,func) 
		local args = m.content:split(" ")
		func(m,args)
		return true
	end
	commands[name] = function(m) temp(m,func) end
	print(string.format('Loaded command %s',name))
end

function callCommand(m)
	if string.sub(m.content,1,#prefix) == prefix then
		local ending = string.find(m.content, ' ')
		if ending then ending = ending - 1 end
		local command = string.sub(m.content, #prefix+1, ending)
		if commands[command] then
			commands[command](m) 
		end
	end
end

client:on('messageCreate',callCommand)

require("./commands.lua")

client:run('Bot BOT_TOKEN')

client:once('ready', function()
	print('Logged in as '.. client.user.tag)
end)
