return function(params)
  local M = {}
  M.params = params
  M.disabled = false
  M.go = nil
  M.vel = {x=0, y=0}  
  M.commands={}
  M.delay=0
  M.messages={}
  M.buttons={}

  function M:createSprite(params)
    local function lastWord(path)
      return string.match( path, '[^.]+$' )
    end
    local structure = require(params.path)
    local key = lastWord(params.path)
    self.go = display.newSprite( params.parent, gImageSheets[key], structure.sequences )
    physics.addBody( self.go, 'static', self:getColliders(params) )
    self.go.x, self.go.y = params.x, params.y
    self.go.gravityScale = 1
    self.go.isFixedRotation = true
    self.go.class = params.class
    self.go.rotation = params.props.rotation
    self.go.xScale = params.props.xScale
    self.go.yScale = params.props.yScale
    self.go.anchorX = params.props.anchorX
    self.go.anchorY = params.props.anchorY
    
    self:setSequence( params.default )
  end

  function M:getColliders(params)
    local colliders = params.colliders
    if not colliders then return end
    local relation = params.relation or {}
    local filters = {}
    for k1, col in pairs(colliders) do
      local body = {density=1, bounce=0, friction=1, filter=relation,}
      if col.data then
        if col.type == 'polygon' then
          local shapes = {}
          local length = 0
          for k2, shape in pairs(col.data) do
            length = length + 1
          end
          if length > 0 then
            for i=1,length do
              local keyName = string.format( 'key_%d', i )
              shapes[#shapes + 1] = col.data[keyName]
            end
            body.shape = shapes
            filters[#filters + 1] = body
          end
        elseif col.type == 'rect' then
          body.box = col.data
          filters[#filters + 1] = body
          break
        elseif col.type == 'circle' then
          body.radius = col.data
          filters[#filters + 1] = body
          break
        end
      end
    end
    return unpack(filters)
  end

  function M:play(sequence, delay)
    if self.go.currentSequence == sequence then
      return
    end
    self.delay = delay or 0
    self:setSequence(sequence)
    if not self.go.play then return end
    self.go:play()
  end

  function M:canExcute()
    if self.delay <= 0 then return true end
    return false
  end

  function M:pause()
    self.go:pause()
  end

  function M:setSequence(sequence)
    self.go.currentSequence = sequence
    if not self.go.setSequence then return end
    self.go:setSequence(sequence)
  end

  function M:setFrame(num)
    self.go:setFrame(num)
  end

  function M:disable()
    self.disabled = true
  end

  function M:enable()
    self.disabled = false
  end

  function M:freez()
    self:disable()
    if self.go.pause then
      self.go:pause()
    end
  end

  function M:restart()
    self:enable()
    if self.go.start then
      self.go:start()
    end
  end

  function M:raycast(names)
    for i, name in ipairs(names) do
      local halfWidth = self.go.width / 2
      local hits = physics.rayCast( 
        self.go.x + halfWidth, 
        self.go.y, 
        self.go.x + halfWidth, 
        self.go.y + self.go.height / 2 + 1, 
        "closest" )
      if hits then
        local hitFirst = hits[1]
        local class = hitFirst.object.class
        if class == name then
          return true
        end
      end
    end
    return false
  end

  function M:appear()
  end

  function M:disappear()
  end

  function M:update(event)
    if not self.go then return end
    local sequence = self.go.sequence
    self:play(sequence)
    local command = self.commands[sequence]
    if not command then return end
    self.vel.x, self.vel.y = 0, 0
    command(self)
  end

  function M:enterFrame(event)
    self:getButtonStatus()
    if self.disabled then return end
    self:update(event)
    if self.delay > 0 then
      self.delay = self.delay - 1
    end
  end

  function M:getButtonStatus()
  end

  function M:message(params)
    self.messages = 
      utils.merge(params, self.messages)
  end

  function M:addEventListeners()
    Runtime:addEventListener( 'enterFrame', M )
  end

  function M:removeEventListeners()
    Runtime:removeEventListener( 'enterFrame', M )
  end

  return M
end
