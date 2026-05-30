local M = {
    loaded = false,
    counts = {},
    path = nil,
    dirty = false,
    dirty_count = 0,
    last_save_at = 0,
    save_every = 5,
    save_interval_seconds = 15,
}

local function trim(text)
    return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function M.normalize(text)
    local word = trim(text)
    if #word < 2 or not word:match("^[A-Za-z]+$") then
        return nil
    end
    return word:lower()
end

local function sorted_keys(counts)
    local keys = {}
    for key in pairs(counts) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

function M.init()
    if M.loaded then
        return
    end

    local user_data_dir = rime_api:get_user_data_dir()
    M.path = user_data_dir .. "/english_learning.tsv"

    local file = io.open(M.path, "r")
    if file then
        for line in file:lines() do
            local word, count = line:match("^([A-Za-z]+)%t(%d+)$")
            if word and count then
                M.counts[word:lower()] = tonumber(count) or 0
            end
        end
        file:close()
    end

    M.last_save_at = os.time()
    M.loaded = true
end

function M.configure(config)
    local save_every = config:get_int("english_learning/save_every")
    if save_every and save_every > 0 then
        M.save_every = save_every
    end

    local save_interval_seconds = config:get_int("english_learning/save_interval_seconds")
    if save_interval_seconds and save_interval_seconds > 0 then
        M.save_interval_seconds = save_interval_seconds
    end
end

function M.save()
    if not M.path or not M.dirty then
        return
    end

    local tmp_path = M.path .. ".tmp"
    local file = io.open(tmp_path, "w")
    if not file then
        return
    end

    for _, key in ipairs(sorted_keys(M.counts)) do
        local count = M.counts[key]
        if count and count > 0 then
            file:write(key, "\t", tostring(count), "\n")
        end
    end
    file:close()

    local ok = os.rename(tmp_path, M.path)
    if not ok then
        os.remove(tmp_path)
        return
    end

    M.dirty = false
    M.dirty_count = 0
    M.last_save_at = os.time()
end

function M.flush()
    M.init()
    M.save()
end

function M.increment(text)
    M.init()

    local key = M.normalize(text)
    if not key then
        return nil
    end

    M.counts[key] = (M.counts[key] or 0) + 1
    M.dirty = true
    M.dirty_count = M.dirty_count + 1

    local now = os.time()
    if M.dirty_count >= M.save_every or now - M.last_save_at >= M.save_interval_seconds then
        M.save()
    end

    return key, M.counts[key]
end

function M.get(text)
    M.init()

    local key = M.normalize(text)
    if not key then
        return 0
    end
    return M.counts[key] or 0
end

return M
