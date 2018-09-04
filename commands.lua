require("./funcs.lua")

addCommand('ping', function(m)
	local response = m:reply('Pong!')
	if response then
		response:setContent(string.format('Pong! %sms', math.ceil((response.createdAt - m.createdAt)*1000)))
	end
end)

addCommand('echo', function(m, args)
	table.remove(args, 1)
	m:reply(table.concat(args, " "))
end)

addCommand('s', function(m)
    if m.author.id == client.owner.id then
        m:reply("bye")
        client:stop()
    end
end)

addCommand('lua', function(m, args)
	local function code(str)
		return string.format('```\n%s```', str)
	end
	local function exec(arg, msg)

		if not arg then return end
		if msg.author ~= msg.client.owner then return end
	
		arg = arg:gsub('```\n?', '') -- strip markdown codeblocks
	
		local sandbox = {
			require = require, 
			discordia = discordia,
			client = client,
			math = math,
			string = string,
			io = io,
		}

		local lines = {}
	
		sandbox.message = msg
		sandbox.client = discordia.Client()
		
	
		local function printLine(...)
			local ret = {}
			for i = 1, select('#', ...) do
				local arg = tostring(select(i, ...))
				table.insert(ret, arg)
			end
			return table.concat(ret, '\t')
		end
		
		local pp = require('pretty-print')
		local function prettyLine(...)
			local ret = {}
			for i = 1, select('#', ...) do
				local arg = pp.strip(pp.dump(select(i, ...)))
				table.insert(ret, arg)
			end
			return table.concat(ret, '\t')
		end

		sandbox.p = function(...) -- intercept pretty-printed lines with this
			table.insert(lines, prettyLine(...))
		end

		sandbox.print = function(...)
			table.insert(lines, printLine(...))
		end

		local fn, syntaxError = load(arg, 'DiscordBot', 't', sandbox)
		if not fn then return msg:reply(code(syntaxError)) end
	
		local success, runtimeError = pcall(fn)
		if not success then return msg:reply(code(runtimeError)) end
	
		lines = table.concat(lines, '\n')
	
		if #lines > 1990 then -- truncate long messages
			lines = lines:sub(1, 1990)
		end
	
		return msg:reply(code(lines))
			
	end 
	
	if not args[2] then
		return m.channel:send("Incomplete command!")
	else
		if m.author.id == client.owner.id then
			table.remove(args, 1)
			args = table.concat(args, " ")
			exec(args, m)
		else
			return message.channel:send("Forbidden")
		end
	end
end)

addCommand('uptime', function(m)
	local time = os.time() - ontime
	m:reply("Uptime: `"..SecondsToClock(time).."`")
end)
