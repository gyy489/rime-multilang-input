-- 暴力 GC
-- 详情 https://github.com/hchunhui/librime-lua/issues/307
-- 每次按键都会经过 translator，按次调用 GC step 会增加热路径开销。
local DEFAULT_INTERVAL = 8
local ticks = 0

local function force_gc(_, _, env)
  local interval = DEFAULT_INTERVAL
  if env then
    if env.force_gc_interval == nil then
      local config = env.engine.schema.config
      env.force_gc_interval = config:get_int("force_gc/interval") or DEFAULT_INTERVAL
    end
    interval = env.force_gc_interval
  end

  if interval <= 0 then
    return
  end

  if env then
    env.force_gc_ticks = (env.force_gc_ticks or 0) + 1
    ticks = env.force_gc_ticks
  else
    ticks = ticks + 1
  end

  if ticks < interval then
    return
  end

  ticks = 0
  if env then
    env.force_gc_ticks = 0
  end
  collectgarbage("step")
end

return force_gc
