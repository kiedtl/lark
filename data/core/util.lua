local util = {}

function util.format(...)
	return string.format(...)
end

function util.printf(fmt, ...)
	io.write(string.format(fmt, ...))
end

function util.getHostname()
	-- TODO: get this function to work
	-- on Winbl^H^Hdows-based systems
	local fallback = "lolcathost"
	local hostname = ""

	if not io.open('/etc/hostname') then
		hostname = fallback
	end

	hostname = io.lines('/etc/hostname')
	if hostname == "" then
		hostname = fallback
	end

	return hostname
end

return util
