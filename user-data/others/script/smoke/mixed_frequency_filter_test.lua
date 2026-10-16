local filter = dofile("user-data/lua/mixed_frequency_filter.lua")

local function candidate(text, quality, comment)
    return { text = text, quality = quality, comment = comment or "" }
end

local function run(code, candidates, scan_limit)
    local config = {
        get_int = function(_, key)
            if key == "mixed_frequency/scan_limit" then return scan_limit end
        end,
        get_double = function(_, key)
            if key == "mixed_frequency/power" then return 1.6 end
            if key == "mixed_frequency/switch_bonus" then return 0.25 end
        end,
    }
    local env = { engine = { context = { input = code }, schema = { config = config } } }
    local output = {}
    _G.yield = function(cand) output[#output + 1] = cand end
    local input = {
        iter = function()
            local index = 0
            return function()
                index = index + 1
                return candidates[index]
            end
        end,
    }
    filter.init(env)
    filter.func(input, env)
    return output
end

local list = {
    candidate("你", 100), candidate("呢", 50), candidate("您", 30),
    candidate("ni", 90), candidate("nice", 60), candidate("night", 20),
    candidate("né", 99, "〔FR〕"), candidate("X光", 99), candidate("尾", 1),
}
for _, code in ipairs({ "ni", "hello" }) do
    local output = run(code, list, 8)
    assert(#output == #list)
    assert(output[1] == list[1] and output[2] == list[4])
    assert(output[3] == list[2] and output[4] == list[5])
    assert(output[7] == list[7] and output[8] == list[8] and output[9] == list[9])
end

local english_first = { list[4], list[1], list[5], list[2] }
local output = run("ni", english_first, 4)
assert(output[1] == list[4] and output[2] == list[1])

local strong_english = {
    candidate("中", 100), candidate("文", 1), candidate("词", 1),
    candidate("en", 100), candidate("end", 99), candidate("enter", 1),
}
output = run("example", strong_english, 6)
assert(output[1] == strong_english[1] and output[2] == strong_english[4])
assert(output[3] == strong_english[5]) -- 特别高频的英文可以连续出现

output = run("ni!", list, 8)
for index, cand in ipairs(list) do assert(output[index] == cand) end

print("mixed_frequency_filter: pass")
