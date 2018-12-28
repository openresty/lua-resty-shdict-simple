-- Copyright (C) CloudFlare Inc.
--
-- Generate shdict cache methods, based on shared memory dictionary


local _M = {
    version = '0.01',
}


local DEBUG = ngx.config.debug
local ngx = ngx
local error = error
local tostring = tostring


function _M.gen_shdict_methods (opts)
    local dlog = opts.debug_logger
    local error_log = opts.error_logger
    local pos_ttl = opts.positive_ttl
    local neg_ttl = opts.negative_ttl
    local disable_shdict = opts.disable_shdict
    local dict_name = opts.dict_name
    local set_retries = opts.set_retries or 1
    local shdict = ngx.shared[dict_name]
    if not shdict then
        error("failed to find lua_shared_dict \""
              .. tostring(dict_name) .. "\" in your nginx.conf")
    end

    local shdict_set, shdict_get

    pos_ttl = pos_ttl / 1000  -- convert to sec
    neg_ttl = neg_ttl / 1000  -- convert to sec

    local function shdict_set(ctx, key, value, ttl)
        if disable_shdict then
            return true  -- stub
        end

        if value == "" then
            ttl = ttl or neg_ttl

        else
            ttl = ttl or pos_ttl
        end

        -- we use safe_set to avoid evicting expired items in the shm store.
        local ok, err = shdict:safe_set(key, value, ttl)
        if not ok then
            if err == "no memory" then
                if DEBUG then
                    dlog(ctx, 'shdict ', dict_name,
                         ' out of memory, and now try to set by force')
                end

                -- with force:
                local retries = 0
                while not ok and set_retries > retries do
                    ok, err = shdict:set(key, value, ttl)
                    retries = retries + 1
                    if DEBUG then
                        dlog(ctx, 'try to set by force ' .. tostring(retries) .. 'th time')
                    end
                end
            end

            if not ok then
                error_log(ctx, 'failed to set key "', key, '" to shdict "',
                          dict_name, '": ', err)
                return false
            end
        end
        return true
    end

    local function shdict_get(ctx, key)
        if disable_shdict then
            return nil  -- stub
        end

        local res, flags, stale = shdict:get_stale(key)

        if res and not stale then
            if DEBUG then
                dlog(ctx, res == "" and "negative" or "positive",
                     ' cache hit on key "', key, '"')
            end
        end

        return res, stale
    end

    return shdict_set, shdict_get
end


return _M
