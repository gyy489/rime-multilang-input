local filter = dofile("user-data/lua/person_name_filter.lua")

rime_api = { get_user_data_dir = function() return "user-data" end }

local function candidate(text, comment)
    return { text = text, comment = comment or "" }
end

local function run(schema, candidates, scan_limit)
    local config = {
        get_int = function(_, key)
            if key == "person_name_filter/scan_limit" then return scan_limit end
        end,
        get_string = function(_, key)
            if key == "schema/schema_id" then return schema end
        end,
    }
    local env = { engine = { schema = { config = config } } }
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
    candidate("张伟"), candidate("天气"), candidate("Alice"), candidate("May"),
    candidate("jean", "〔FR〕"), candidate("bonjour", "〔FR〕"), candidate("王伟"),
}
local output = run("rime_ice", list, 7)
local expected = { list[2], list[4], list[6], list[1], list[3], list[5], list[7] }
assert(#output == #expected)
for index, cand in ipairs(expected) do assert(output[index] == cand) end

local french = { candidate("jean"), candidate("pierre"), candidate("bonjour") }
output = run("fr", french, 3)
assert(output[1] == french[2] and output[2] == french[3] and output[3] == french[1])

local bounded = { candidate("张伟"), candidate("天气"), candidate("王伟"), candidate("你好") }
output = run("rime_ice", bounded, 2)
assert(output[1] == bounded[2] and output[2] == bounded[1])
assert(output[3] == bounded[3] and output[4] == bounded[4])

print("person_name_filter: pass")
