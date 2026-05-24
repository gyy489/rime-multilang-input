local processor = {}

-- Tap Shift briefly to toggle ASCII/Chinese punctuation, while preserving
-- normal Shift chords such as Shift+comma and Shift+letters. Holding Shift
-- alone past the tap threshold does nothing.
local default_tap_threshold_ms = 300

local shift_keys = {
    Shift_L = true,
    Shift_R = true,
}

local function now_ms()
    if rime_api and rime_api.get_time_ms then
        return rime_api.get_time_ms()
    end
    return os.time() * 1000
end

local function toggle_ascii_punct(context)
    context:set_option("ascii_punct", not context:get_option("ascii_punct"))
end

function processor.init(env)
    local config = env.engine.schema.config
    local threshold = config:get_int("shift_punct_toggle/tap_threshold_ms")
    env.tap_threshold_ms = threshold and threshold > 0 and threshold or default_tap_threshold_ms
end

function processor.func(key, env)
    local context = env.engine.context
    local repr = key:repr():gsub("^Release%+", ""):gsub("^Shift%+", "")

    if key:ctrl() or key:alt() or key:super() then
        return 2
    end

    if shift_keys[repr] then
        if key:release() then
            local was_pending = env.shift_pending
            local was_used = env.shift_used
            local is_shift_tap = env.shift_pending
                and not env.shift_used
                and env.shift_pressed_at
                and now_ms() - env.shift_pressed_at <= (env.tap_threshold_ms or default_tap_threshold_ms)

            env.shift_pending = false
            env.shift_used = false
            env.shift_pressed_at = nil
            env.shift_key = nil

            if is_shift_tap then
                toggle_ascii_punct(context)
                return 1
            end

            if was_pending and not was_used then
                return 1
            end

            return 2
        end

        if not env.shift_pending then
            env.shift_pending = true
            env.shift_used = false
            env.shift_pressed_at = now_ms()
            env.shift_key = repr
        elseif env.shift_key ~= repr then
            env.shift_used = true
        end

        return 2
    end

    if env.shift_pending and key:shift() and not key:release() then
        env.shift_used = true
    end

    return 2
end

return processor
