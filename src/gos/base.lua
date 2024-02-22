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

  return M
end
