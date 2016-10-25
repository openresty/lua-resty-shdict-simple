-- Copyright (C) CloudFlare Inc.
--
-- Generate shdict cache methods, based on shared memory dictionary


local _M = {
    version = '0.01',
}


local DEBUG = ngx.config.debug


function _M.gen_shdict_methods (opts)
    local dlog = opts.debug_logger
    local error_log = opts.error_logger
    local pos_ttl = opts.positive_ttl
    local neg_ttl = opts.negative_ttl
    local disable_shdict = opts.disable_shdict
    local dict_name = opts.dict_name
    local shdict = ngx.shared[dict_name]
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

        local ok, err = shdict:safe_set(key, value, ttl)
        if not ok then
            if err == "no memory" then
                -- with force:
                ok, err = shdict:set(key, value, ttl)
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
