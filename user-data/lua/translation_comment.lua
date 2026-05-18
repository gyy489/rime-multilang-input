local M = {}

local function read_tsv(path)
    local map = {}
    local file = io.open(path, "r")
    if not file then
        return map
    end

    for line in file:lines() do
        local key, value = line:match("^(.-)\t(.+)$")
        if key and value and key ~= "" and value ~= "" then
            map[key] = value
        end
    end
    file:close()
    return map
end

local function has_cjk(text)
    -- Most common CJK code points are encoded as UTF-8 bytes E4-E9.
    return text:find("[\228-\233]") ~= nil
end

local function is_single_cjk_candidate(text)
    return has_cjk(text) and utf8.len(text) == 1
end

local function append_comment(comment, addition)
    comment = comment or ""
    if comment:find(addition, 1, true) then
        return comment
    end
    if comment == "" then
        return addition
    end
    return comment .. " " .. addition
end

function M.init(env)
    local user_data_dir = rime_api:get_user_data_dir()
    M.en_zh = read_tsv(user_data_dir .. "/translations/en_zh.tsv")
    M.zh_en = read_tsv(user_data_dir .. "/translations/zh_en.tsv")

    local config = env.engine.schema.config
    M.enabled = config:get_bool("translation_comment/enabled")
    if M.enabled == nil then
        M.enabled = true
    end
end

function M.func(input)
    if not M.enabled then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    for cand in input:iter() do
        local text = cand.text
        local addition = nil

        if text:find("[A-Za-z]") and not has_cjk(text) then
            local translation = M.en_zh[text:lower()]
            if translation then
                addition = "〔" .. translation .. "〕"
            end
        elseif has_cjk(text) and not is_single_cjk_candidate(text) then
            local translation = M.zh_en[text]
            if translation then
                addition = "〔" .. translation .. "〕"
            end
        end

        if addition then
            yield(ShadowCandidate(cand, cand.type, text, append_comment(cand.comment, addition)))
        else
            yield(cand)
        end
    end
end

return M
