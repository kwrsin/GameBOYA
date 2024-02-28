return function(params)
  local M = {}
  M.params = params
  M.currentSequence = nil

  function M:play(sequence)
    if self.go.currentSequence == sequence then
      return
    end
    self.go:setSequence(sequence)
    self.go.currentSequence = sequence
    self.go:play()
  end

  function M:pause()
    self.go:pause()
  end

  function M:setSequence(sequence)
    self.go:setSequence(sequence)
  end

  function M:setFrame(num)
    self.go:setFrame(num)
  end

  return M
end
