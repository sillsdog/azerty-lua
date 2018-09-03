addCommand('ping', function(m)
   	local response = message:reply('Pong!')
	if response then
		response:setContent(string.format('Pong! %sms', math.abs(math.ceil((response.createdAt - message.createdAt)*1000))))
	end
end)
