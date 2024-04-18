local M = {}

function M.info(...)
	local date = os.date( "*t" )
	local strDate = string.format( '[INFO %d/%d/%d %d:%d:%d]', date.year, date.month, date.day, date.hour, date.min, date.sec)
	print(strDate)
	for i = 1, select("#", ...) do
		local arg = select(i, ...)
		if type(arg) == 'string' or type(arg) == 'number' or type(arg) == 'boolean' or arg == nil then
			print(i, ':' .. (arg or 'nil'))
		else
			print(i, ':')
			table.print(arg)
		end
	end
end

return M