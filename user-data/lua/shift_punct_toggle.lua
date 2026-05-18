local processor = {}

-- Tap Shift to toggle ASCII/Chinese punctuation, while preserving normal
-- Shift chords such as Shift+comma and Shift+letters.
local shift_keys = {
    Shift_L = true,
    Shift_R = true,
}

local function toggle_ascii_punct(context)
    context:set_option("ascii_punct", not context:get_option("ascii_punct"))
end

function processor.func(key, env)
    local context = env.engine.context
    local repr = key:repr():gsub("^Release%+", ""):gsub("^Shift%+", "")

    if key:ctrl() or key:alt() or key:super() then
        return 2
    end

    if shift_keys[repr] then
        if key:release() then
            if env.shift_pending and not env.shift_used then
                toggle_ascii_punct(context)
                env.shift_pending = false
                env.shift_used = false
                return 1
            end
            env.shift_pending = false
            env.shift_used = false
            return 2
        end

        env.shift_pending = true
        env.shift_used = false
        return 2
    end

    if env.shift_pending and key:shift() and not key:release() then
        env.shift_used = true
    end

    return 2
end

return processor
