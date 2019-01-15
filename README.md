Name
====

lua-resty-shdict-simple - Simple application-oriented interface to OpenResty's shared dictionary API

Table of Contents
=================

* [Name](#name)
* [Synopsis](#synopsis)
* [TODO](#todo)
* [Author](#author)
* [Copyright and License](#copyright-and-license)
* [See Also](#see-also)

Synopsis
========

```lua
local shdict_simple = require "resty.shdict.simple"

local function dlog(ctx, ...)
    ngx.log(ngx.DEBUG, "my app: ", ...)
end

local function error_log(ctx, ...)
    ngx.log(ngx.ERR, "my app: ", ...)
end

local pos_ttl = 20000  -- in ms
local neg_ttl = 10000  -- in ms

local my_shdict_set, my_shdict_get
                  = shdict_simple.gen_shdict_methods{
                       dict_name = "my_lua_shared_dict_name",
                       debug_logger = dlog,
                       error_logger = error_log,
                       positive_ttl = pos_ttl,
                       negative_ttl = neg_ttl,
                       max_tries = 10, -- default is 1
                    }

-- on hot code paths:

local ctx = ngx.ctx

local key = "name"
local value = "John Green"

-- when value == "", negative ttl is used; otherwise positive ttl is used.
my_shdict_set(ctx, key, value)

-- it is also possible to override the default ttl for a single method call:
my_shdict_set(ctx, key, value, my_temp_ttl)

local res, stale = my_shdict_get(ctx, key)
if not res then
    if stale then
        -- use the stale data in the cache...
    end
end
```

TODO
====


Author
======

Yichun "agentzh" Zhang (章亦春) <agentzh@gmail.com>, CloudFlare Inc.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2016, by CloudFlare Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)

See Also
========

* [lua-resty-memcached-shdict](https://github.com/openresty/lua-resty-memcached-shdict)
* [lua-resty-lrucache](https://github.com/openresty/lua-resty-lrucache)
* [lua-resty-memcached](https://github.com/openresty/lua-resty-memcached)
* [lua_shared_dict](https://github.com/openresty/lua-nginx-module#lua_shared_dict)

[Back to TOC](#table-of-contents)

