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

  function M:play(sequence, delay)
    if self.go.currentSequence == sequence then
      return
    end
    self.delay = delay or 0
    self:setSequence(sequence)
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
