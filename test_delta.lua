-- Delta 兼容性测试
local function test()
    local results = {};
    
    -- 测试 game:HttpGet
    local ok1, err1 = pcall(function()
        local r = game:HttpGet("https://httpbin.org/get");
        return r and #r > 0;
    end);
    results["game:HttpGet"] = ok1 and "OK" or ("FAIL: " .. tostring(err1));
    
    -- 测试 request
    local ok2, err2 = pcall(function()
        local req = (syn and syn.request) or (http and http.request) or request;
        if not req then return false; end
        local r = req({
            Url = "https://httpbin.org/get",
            Method = "GET"
        });
        return r and r.Body and #r.Body > 0;
    end);
    results["request"] = ok2 and "OK" or ("FAIL: " .. tostring(err2));
    
    -- 测试 writefile/readfile
    local ok3, err3 = pcall(function()
        writefile("test_delta.txt", "hello");
        local content = readfile("test_delta.txt");
        return content == "hello";
    end);
    results["writefile/readfile"] = ok3 and "OK" or ("FAIL: " .. tostring(err3));
    
    -- 测试 print
    for name, result in pairs(results) do
        print(name .. ": " .. result);
    end
    
    return results;
end

return test();
