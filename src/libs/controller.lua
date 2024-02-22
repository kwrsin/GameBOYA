-- controller.lua
local utils = require 'src.libs.utils'

local M = {}

M.keysKeeping = {
	up=0,
	down=0,
	left=0,
	right=0,
	space=0
}

M.callback = nil

function M:enterFrame(event)
	if M.callback then
		event.target = M.target
		M.callback(event, M.keysKeeping)
	end
	for k, v in pairs(M.keysKeeping) do
		if M.keysKeeping[k] > 0 then
			M.keysKeeping[k] = M.keysKeeping[k] + 1
		end
	end
end 

function M:key(event)
	for k, v in pairs(M.keysKeeping) do
		if event.keyName == k then
			if event.phase == 'down' then
				if M.keysKeeping[k] == 0 then
					M.keysKeeping[k] = 1
				end
			elseif event.phase == 'up' then
				M.keysKeeping[k] = 0
			end	
		end
	end

  if ( event.keyName == "back" ) then
    if ( system.getInfo("platform") == "android" ) then
        return true
    end
  end

  return false		
end 

function M.keyInput(target, callback, options)
	M.keysKeeping = utils.merge(options or {}, M.keysKeeping)
	-- M.keysKeeping = options or M.keysKeeping
	if not M.callback then
		M.callback = callback
		M.target = target
		Runtime:addEventListener("key", M)
	end
end

function M.stopKeyInput()
	Runtime:removeEventListener("key", M)
end


return M