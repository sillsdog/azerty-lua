function _G.wait(s)
	local ntime = os.time() + s
	repeat until os.time() > ntime
end

function _G.SecondsToClock(seconds)
	local seconds = tonumber(seconds)
	if seconds <= 1 then
		return "00:00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		return hours..":"..mins..":"..secs
	end
end

function _G.userFromMention(mention)
	local id = string.match(mention,"[^<@>!]+")
	return client:getUser(id)
end
