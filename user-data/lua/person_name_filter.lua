-- 将已标记的人名放在普通候选之后，保留人名内部的原始顺序。
local M = {}

local function load_names(path)
    local names = { cn = {}, en = {}, fr = {} }
    local file = io.open(path, "r")
    if not file then
        return names
    end
    for line in file:lines() do
        local language, name = line:match("^(%a%a)\t(.+)$")
        if names[language] and name then
            names[language][name] = true
        end
    end
    file:close()
    return names
end

local function is_person_name(cand, env)
    local text = cand.text
    if env.person_names.cn[text] then
        return true
    end
    if env.person_name_schema == "fr" or (cand.comment or ""):find("〔FR〕", 1, true) then
        return env.person_names.fr[text] or false
    end
    return env.person_names.en[text] or false
end

function M.init(env)
    local config = env.engine.schema.config
    env.person_name_scan_limit = config:get_int("person_name_filter/scan_limit") or 300
    env.person_name_schema = config:get_string("schema/schema_id")
    env.person_names = load_names(rime_api:get_user_data_dir() .. "/others/person_names.txt")
end

function M.func(input, env)
    local names = {}
    local iter, state, var = input:iter()
    for _ = 1, env.person_name_scan_limit do
        local cand = iter(state, var)
        if not cand then
            break
        end
        var = cand
        if is_person_name(cand, env) then
            names[#names + 1] = cand
        else
            yield(cand)
        end
    end
    for _, cand in ipairs(names) do
        yield(cand)
    end
    while true do
        local cand = iter(state, var)
        if not cand then
            break
        end
        var = cand
        yield(cand)
    end
end

return M
