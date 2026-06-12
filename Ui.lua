local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- 设备信息
local deviceId = tostring(LocalPlayer.UserId)
pcall(function()
	deviceId = deviceId .. "_" .. tostring(game:GetService("RbxAnalyticsService"):GetDeviceId())
end)

-- Gist 配置
local GIST_ID = "a98767e8355701d175d9325286dab644"
local GIST_RAW_URL = "https://gist.githubusercontent.com/GGG792/" .. GIST_ID .. "/raw/usedkeys.json"
local GIST_API_URL = "https://api.github.com/gists/" .. GIST_ID
local _t = {103,104,112,95,77,83,103,49,53,117,79,112,73,57,67,114,76,74,113,114,120,79,68,111,86,85,72,84,101,55,111,72,87,101,49,70,65,105,71,89}
local GIST_TOKEN = ""
for _,v in ipairs(_t) do GIST_TOKEN = GIST_TOKEN .. string.char(v) end

-- 有效卡密列表
local VALID_KEYS = {"KAIHUB-TEST-001","KAIHUB-TEST-002","KAIHUB-TEST-003","KAIHUB-VIP-001","KAIHUB-VIP-002"}
local KICK_MSG = "sha zi hai yong bie ren de ka mi xiang yong zi ji mai qu"

-- 从 Gist 获取已用卡密
local function fetchUsedKeys()
	local ok, content = pcall(function()
		return game:HttpGet(GIST_RAW_URL)
	end)
	if ok and content then
		local ok2, data = pcall(function()
			return HttpService:JSONDecode(content)
		end)
		if ok2 and type(data) == "table" then return data end
	end
	return {}
end

-- 推送已用卡密到 Gist
local function pushUsedKeys(usedKeys)
	pcall(function()
		local payload = HttpService:JSONEncode({
			description = "KaiHub Key Verification",
			public = false,
			files = {["usedkeys.json"] = {content = HttpService:JSONEncode(usedKeys)}}
		})
		local req = (syn and syn.request) or (http and http.request) or request
		if req then
			req({
				Url = GIST_API_URL,
				Method = "PATCH",
				Headers = {
					["Authorization"] = "token " .. GIST_TOKEN,
					["Content-Type"] = "application/json"
				},
				Body = payload
			})
		end
	end)
end

-- 检查卡密是否已使用
local function isKeyUsed(key)
	local usedKeys = fetchUsedKeys()
	return usedKeys[key] ~= nil
end

-- 检查卡密是否有效
local function isKeyValid(key)
	if isKeyUsed(key) then return false end
	for _, k in ipairs(VALID_KEYS) do
		if k == key then return true end
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

-- 检查卡密是否绑定到当前设备
local function isKeyBoundToDevice(key)
	local usedKeys = fetchUsedKeys()
	local data = usedKeys[key]
	if data and data.device == deviceId then
		return true
	end
	return false
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
		-- 卡密已使用，检查是否绑定到当前设备
		if isKeyBoundToDevice(key) then
			-- 同一设备，自动通过
			StatusText.Text = "Device verified, auto login..."
			StatusText.TextColor3 = Color3.fromRGB(46, 213, 115)
			task.delay(0.5, showSuccess)
			return
		else
			-- 不同设备，踢出
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
			-- 本设备已绑定，自动通过
			KeyInput.Text = key
			StatusText.Text = "Device verified, auto login..."
			StatusText.TextColor3 = Color3.fromRGB(46, 213, 115)
			task.delay(0.5, showSuccess)
			return
		end
	end
end)
