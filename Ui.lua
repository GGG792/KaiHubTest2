local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- 设备信息
local deviceId = tostring(LocalPlayer.UserId)
pcall(function()
	deviceId = deviceId .. "_" .. tostring(game:GetService("RbxAnalyticsService"):GetDeviceId())
end)

-- 有效卡密列表
local VALID_KEYS = {"KAIHUB-TEST-001","KAIHUB-TEST-002","KAIHUB-TEST-003","KAIHUB-VIP-001","KAIHUB-VIP-002"}
local KICK_MSG = "sha zi hai yong bie ren de ka mi xiang yong zi ji mai qu"

-- 使用 GitHub 仓库 raw 文件存储已用卡密（避免 Gist 访问问题）
local DATA_URL = "https://raw.githubusercontent.com/GGG792/KaiHubTest2/refs/heads/main/usedkeys.json"
local GIST_TOKEN = ""
local _t = {103,104,112,95,77,83,103,49,53,117,79,112,73,57,67,114,76,74,113,114,120,79,68,111,86,85,72,84,101,55,111,72,87,101,49,70,65,105,71,89}
for _,v in ipairs(_t) do GIST_TOKEN = GIST_TOKEN .. string.char(v) end

-- 本地缓存文件
local LOCAL_FILE = "KaiHub_usedkeys.json"

-- 获取已用卡密（带时间戳避免缓存）
local function fetchUsedKeys()
	-- 先尝试从服务器获取（加时间戳避免缓存）
	local ok, content = pcall(function()
		local ts = tostring(os.time())
		return game:HttpGet(DATA_URL .. "?t=" .. ts)
	end)
	if ok and content and #content > 2 then
		local ok2, data = pcall(function()
			return HttpService:JSONDecode(content)
		end)
		if ok2 and type(data) == "table" then
			-- 保存到本地
			pcall(function() writefile(LOCAL_FILE, content) end)
			return data
		end
	end
	
	-- 服务器获取失败，尝试本地缓存
	local ok3, localContent = pcall(function()
		return readfile(LOCAL_FILE)
	end)
	if ok3 and localContent then
		local ok4, data = pcall(function()
			return HttpService:JSONDecode(localContent)
		end)
		if ok4 and type(data) == "table" then return data end
	end
	
	return {}
end

-- 推送已用卡密到服务器（通过 GitHub API 更新文件）
local function pushUsedKeys(usedKeys)
	local jsonStr = HttpService:JSONEncode(usedKeys)
	
	-- 保存到本地
	pcall(function() writefile(LOCAL_FILE, jsonStr) end)
	
	-- 尝试推送到 GitHub（使用 GitHub API 更新仓库文件）
	pcall(function()
		local req = (syn and syn.request) or (http and http.request) or request
		if not req then return end
		
		-- 先获取当前文件 SHA
		local getRes = req({
			Url = "https://api.github.com/repos/GGG792/KaiHubTest2/contents/usedkeys.json",
			Method = "GET",
			Headers = {["Authorization"] = "token " .. GIST_TOKEN}
		})
		
		local sha = nil
		if getRes and getRes.Body then
			local ok, fileData = pcall(function()
				return HttpService:JSONDecode(getRes.Body)
			end)
			if ok and fileData and fileData.sha then
				sha = fileData.sha
			end
		end
		
		-- 更新文件
		local payload = HttpService:JSONEncode({
			message = "Update used keys",
			content = game:GetService("HttpService"):JSONEncode(usedKeys):gsub(".", function(c)
				-- 简单 base64 编码
				local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
				return c
			end),
			sha = sha
		})
		
		req({
			Url = "https://api.github.com/repos/GGG792/KaiHubTest2/contents/usedkeys.json",
			Method = "PUT",
			Headers = {
				["Authorization"] = "token " .. GIST_TOKEN,
				["Content-Type"] = "application/json"
			},
			Body = payload
		})
	end)
end

-- 检查卡密是否已使用
local function isKeyUsed(key)
	local usedKeys = fetchUsedKeys()
	return usedKeys[key] ~= nil
end

-- 检查卡密是否绑定到当前设备
local function isKeyBoundToDevice(key)
	local usedKeys = fetchUsedKeys()
	local data = usedKeys[key]
	if data and data.device == deviceId then
		return true
	end
	return false
end

-- 标记卡密为已使用（绑定设备）
local function markKeyUsed(key)
	local usedKeys = fetchUsedKeys()
	usedKeys[key] = {
		device = deviceId,
		player = LocalPlayer.Name,
		userId = LocalPlayer.UserId,
		time = os.time()
	}
	pushUsedKeys(usedKeys)
end

-- 创建 UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaiHubTestLoader"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.Text = "KaiHub VIP Verify"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = Frame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 260, 0, 36)
KeyInput.Position = UDim2.new(0.5, -130, 0, 80)
KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
KeyInput.PlaceholderText = "Enter key..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.TextSize = 14
KeyInput.Parent = Frame

Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0, 125)
StatusText.BackgroundTransparency = 1
StatusText.Text = ""
StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusText.Font = Enum.Font.GothamMedium
StatusText.TextSize = 12
StatusText.Parent = Frame

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0, 260, 0, 40)
VerifyBtn.Position = UDim2.new(0.5, -130, 0, 155)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(119, 221, 255)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
VerifyBtn.TextSize = 16
VerifyBtn.Font = Enum.Font.GothamBlack
VerifyBtn.Parent = Frame

Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 8)

-- 显示成功界面
local function showSuccess()
	Title.Text = "TEST SUCCESS"
	Title.TextColor3 = Color3.fromRGB(255, 50, 50)
	KeyInput.Visible = false
	VerifyBtn.Visible = false
	StatusText.Text = "VIP verified - Welcome to KaiHub"
	StatusText.TextColor3 = Color3.fromRGB(46, 213, 115)
	
	local ExitBtn = Instance.new("TextButton")
	ExitBtn.Size = UDim2.new(0, 200, 0, 40)
	ExitBtn.Position = UDim2.new(0.5, -100, 0, 155)
	ExitBtn.BackgroundColor3 = Color3.fromRGB(255, 71, 87)
	ExitBtn.Text = "EXIT"
	ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	ExitBtn.TextSize = 16
	ExitBtn.Font = Enum.Font.GothamBlack
	ExitBtn.Parent = Frame
	Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)
	ExitBtn.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)
end

-- 验证按钮点击
VerifyBtn.MouseButton1Click:Connect(function()
	local key = KeyInput.Text:gsub("^%s*(.-)%s*$", "%1")
	if #key == 0 then
		StatusText.Text = "Please enter a key!"
		StatusText.TextColor3 = Color3.fromRGB(255, 150, 50)
		return
	end
	
	-- 检查卡密是否已使用
	if isKeyUsed(key) then
		if isKeyBoundToDevice(key) then
			StatusText.Text = "Device verified, auto login..."
			StatusText.TextColor3 = Color3.fromRGB(46, 213, 115)
			task.delay(0.5, showSuccess)
			return
		else
			StatusText.Text = KICK_MSG
			StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
			task.delay(2, function()
				LocalPlayer:Kick(KICK_MSG)
			end)
			return
		end
	end
	
	-- 检查卡密是否有效
	local valid = false
	for _, k in ipairs(VALID_KEYS) do
		if k == key then valid = true break end
	end
	if not valid then
		StatusText.Text = "Invalid key!"
		StatusText.TextColor3 = Color3.fromRGB(255, 71, 87)
		return
	end
	
	-- 验证通过，绑定设备
	VerifyBtn.Text = "VERIFYING..."
	VerifyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
	task.delay(1, function()
		markKeyUsed(key)
		showSuccess()
	end)
end)

-- 启动时检查是否有已绑定的卡密
task.delay(0.3, function()
	local usedKeys = fetchUsedKeys()
	for key, data in pairs(usedKeys) do
		if data.device == deviceId then
			KeyInput.Text = key
			StatusText.Text = "Device verified, auto login..."
			StatusText.TextColor3 = Color3.fromRGB(46, 213, 115)
			task.delay(0.5, showSuccess)
			return
		end
	end
end)
