--[[
        WIRESHARK ON ROBLOX!
    HOW TO USE;
        1) INJECT YOUR CLIENT.
        2) EXECUTE WIRESHARK SCRIPT.
        3) WAIT FOR LOADING.
        4) EXECUTE THE TARGET SCRIPT.
        5) LOOK AT YOUR ROBLOX OUTPUT AND SEND IT TO GLM 5.2 TO ANALYZE ALL PACKETS.


    This script is designed to analyze all outgoing HTTP requests from your client.
]]
local G = getgenv()

local function is_url(s)
    return type(s) == "string" and s:find("^https?://") ~= nil
end
local N = 0
local function report(src, url, body, headers)
    if type(url) == "table" then
        local t = url
        body    = body    or t.Body    or t.body
        headers = headers or t.Headers or t.headers
        url     = t.Url or t.url or t.URL
    end
    N = N + 1
    print("")
    print(">>> C2 #" .. N .. "  [" .. tostring(src) .. "]")
    print(">>> URL  : " .. tostring(url))
    if is_url(body) then url, body = body, url end
    if body ~= nil and not is_url(body) then
        print(">>> BODY : " .. tostring(body):sub(1, 400))
    end
    if type(headers) == "table" then
        local q = {}
        for k, v in pairs(headers) do q[#q+1] = tostring(k) .. "=" .. tostring(v) end
        if #q > 0 then print(">>> HDR  : " .. table.concat(q, " | ")) end
    end
    print("")
end
local function findfn(name)
    if type(G[name]) == "function" then return name, G[name] end
    for k, v in pairs(G) do
        if type(v) == "function" and tostring(k):lower() == name:lower() then
            return k, v
        end
    end
    return nil, nil
end
local hooked = 0
for _, name in ipairs({ "request", "http_request" }) do
    local key, orig = findfn(name)
    if orig then
        G[key] = function(a, b, c, d, ...)
            local u  = (type(a) == "table") and (a.Url or a.url or a.URL) or a
            local bd = (type(a) == "table") and (a.Body or a.body) or b
            local hd = (type(a) == "table") and (a.Headers or a.headers) or nil
            report(key, u, bd, hd)
            return orig(a, b, c, d, ...)
        end
        hooked = hooked + 1
        print("[OK] getgenv()." .. key .. "  hooked")
    else
        print("[-] " .. name .. " not found")
    end
end
-- game:HttpGet
pcall(function()
    if type(hookmetamethod) == "function" then
        pcall(hookmetamethod, game, "HttpGet", function(self, url, ...)
            print(">>> [game.HttpGet] " .. tostring(url))
            local f = rawget(game, "HttpGet")
            if type(f) == "function" then return f(self, url, ...) end
            return ""
        end)
        print("[OK] game.HttpGet hook attempted")
    end
end)
print("")
print("HOOK INSTALLED: " .. hooked .. "/2 request functions")
print("Now run the Target Script. C2 output will appear on screen.")
print("============================================")
