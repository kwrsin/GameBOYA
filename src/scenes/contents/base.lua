-- base.lua
local tileLoader = require 'src.libs.tileLoader'
local levelLoader = require 'src.libs.levelLoader'

local content
local selectedLevel
local actors

return function()
	local M = {}

	local function enterFrame(event)
	  if player then
	    controller:enterFrame(event)
	    virtualControlelr:enterFrame(event)
	  end
	  for i, actor in ipairs(actors) do
	    actor:enterFrame(event)
	  end
	end

	local function addEventListeners()
		Runtime:addEventListener( 'enterFrame', enterFrame )
	end

	local function removeEventListeners()
		Runtime:removeEventListener( 'enterFrame', enterFrame )
	end

	local function loadLevel()
	  content = levelLoader{
	    level=selectedLevel, 
	    register=function(obj, params)
	      if obj.isActor then
	        M:entry(obj)
	      end
	      if params.isPlayer then
	        player = obj
	      end
	    end
	  }
	end

	local function createGameObject(params)
	  if not params.gId or params.gId < 0 then return nil end
	  local goPath = selectedLevel.gos[params.gId]
	  local obj = require(goPath.class)(params)
	  M:entry(obj)
	  if goPath.isPlayer then
	    player = obj
	  end
	  return obj.go
	end

	local function tiled()
	  content = display.newGroup()
	  local tileSize = 64
	  local tiles = 8
	  content.x = (CW - tiles * tileSize) / 2
	  content.y = (CH - tiles * tileSize) / 2
	  tileLoader{
	    parent=content, 
	    level=selectedLevel, 
	    imageSheets=gImageSheets,
	    callback=createGameObject
	  }
	  content.isContent = true
	  return content  
	end

	function M:create(parent, lvlPath)
	  actors = {}
		selectedLevel = require(lvlPath)
	  if selectedLevel.edition then
	    loadLevel()
	  else
	  	tiled()
	  end
	  parent:insert(content)

		addEventListeners()
	end

	function M:entry(actor)
	  if not actor then return end
	  actors[#actors + 1] = actor
	end

	function M:disableActors()
	  for i, actor in ipairs(actors) do
	    if actor then
	      actor:disable()
	    end
	  end
	end

	function M:stopTheWorld()
	  physics.pause()
	  timer.pause(TAG_TIMER)
	  transition.pause(TAG_TRANSITION)
	  for i, actor in ipairs(actors) do
	    if actor then
	      actor:freez()
	    end
	  end
	end

	function M:restartTheWorld()
	  physics.start()
	  timer.resume(TAG_TIMER)
	  transition.resume(TAG_TRANSITION)
	  for i, actor in ipairs(actors) do
	    if actor then
	      actor:restart()
	    end
	  end
	end

	function M:disappearAll()
	  for i, actor in ipairs(actors) do
	    if actor then
	      actor:disappear()
	    end
	  end
	end

	function M:notifyToActors(event)
	  for i, actor in ipairs(actors) do
	    if actor then
	      actor:message(event)
	    end
	  end		
	end

	function M:result(params)
	end

	function M:start()
		self:notifyToActors{onContent=CONTENT_START}
	end

	function M:pause()
		self:notifyToActors{onContent=CONTENT_PAUSE}
	end

	function M:destroy()
		self:notifyToActors{onContent=CONTENT_DESTORY}
		removeEventListeners()
	  sound:reset(true)
	end

	function M:pushNextLevel(options)
	  storage:put(STORAGE_SELECTED_LEVEL, options.nextLevel)
	  storage:store()
		utils.gotoScene(INTERMID_SCENE, options)
	end

	function M:gotoNextLevel(options)
	  publisher:put(nil, PUBSUB_PARAMETERS, {nextLevel=options.nextLevel})
	  utils.gotoScene(INTERMID_SCENE, {
	    effect = options.effect or "fade",
	    time = options.time or 400,
	    params={message=options.message or '', time=1000}
	  })
	end

	return M
end

