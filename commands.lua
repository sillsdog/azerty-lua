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
	
		sandbox.m = msg
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

addCommand('dog', function(m, args)
	if #args == 1 then
		local http = require('coro-http')
		local json = require('json')
		local res, body = http.request("GET", "https://dog.ceo/api/breeds/image/random")
		local a = json.decode(body)
		m:reply(a.message)
	elseif #args == 2 then
		local http = require('coro-http')
		local json = require('json')
		local res, body = http.request("GET", "https://dog.ceo/api/breed/".. args[2] .."/images/random")
		local a = json.decode(body)
		m:reply(a.message)
	elseif #args == 3 then
		local http = require('coro-http')
		local json = require('json')
		local res, body = http.request("GET", "https://dog.ceo/api/breed/".. args[3] .. "/" .. args[2] .."/images/random")
		local a = json.decode(body)
		m:reply(a.message)
	end
end)

addCommand('8ball', function(m, args)
	math.randomseed(os.time())
	local eightball = {"It is certain.", "It is decidedly so.", "Without a doubt.", "Yes - definitely.", "You may rely on it.", "As I see it, yes.", "Most likely.", "Outlook good.", "Yes.", "Signs point to yes.", "Reply hazy, try again", "Ask again later.", "Better not tell you now.", "Cannot predict now.", "Concentrate and ask again.", "Don't count on it.", "My reply is no.", "My sources say no.", "Outlook not so good.", "Very doubtful."} 
	if #args == 1 then
		m:reply("You can't ask the magic 8-ball nothing!")
	elseif #args > 1 then
		m:reply(":8ball: "..eightball[math.random(#eightball)])
	end
end)

addCommand('avatar', function(m, args)
	if #args == 1 then
		local url = m.author.avatarURL
		local pathjoin = require('pathjoin')
		local http = require('coro-http')
		local res, body = http.request("GET", url.."?size=1024")
		assert(res.code < 300)
		local filename = table.remove(pathjoin.splitPath(url))
		m:reply{file = {filename, body}}
	elseif #args > 1 then
		if userFromMention(args[2]) then
			local url = userFromMention(args[2]).avatarURL
			local pathjoin = require('pathjoin')
			local http = require('coro-http')
			local res, body = http.request("GET", url.."?size=1024")
			assert(res.code < 300)
			local filename = table.remove(pathjoin.splitPath(url))
			m:reply{file = {filename, body}}
		end
	end
end)
