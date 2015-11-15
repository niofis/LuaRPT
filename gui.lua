local SDL = require("SDL")

local ret, err = SDL.init { SDL.flags.Video }
if not ret then
  error(err)
end


