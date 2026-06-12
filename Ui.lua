local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- 测试：直接创建最简单的 UI
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

-- 卡密验证逻辑
local VALID_KEYS = {"KAIHUB-TEST-001","KAIHUB-TEST-002","KAIHUB-TEST-003","KAIHUB-VIP-001","KAIHUB-VIP-002"}
local KICK_MSG = "sha zi hai yong bie ren de ka mi xiang yong zi ji mai qu"
local GIST_ID = "a98767e8355701d175d9325286dab644"
local GIST_RAW_URL = "https://gist.githubusercontent.com/GGG792/" .. GIST_ID .. "/raw/usedkeys.json"
local GIST_API_URL = "https://api.github.com/gists/" .. GIST_ID

local _t = {103,104,112,95,77,83,103,49,53,117,79,112,73,57,67,114,76,74,113,114,120,79,68,111,86,85,72,84,101,55,111,72,87,101,49,70,65,105,71,89}
local GIST_TOKEN = ""
for _,v in ipairs(_t) do GIST_TOKEN = GIST_TOKEN .. string.char(v) end

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

local function isKeyUsed(key)
	local usedKeys = fetchUsedKeys()
	return usedKeys[key] ~= nil
end

local function isKeyValid(key)
	if isKeyUsed(key) then return false end
	for _, k in ipairs(VALID_KEYS) do
		if k == key then return true end
	end
	return false
end

local function markKeyUsed(key)
	local usedKeys = fetchUsedKeys()
	usedKeys[key] = {time = os.time()}
	pushUsedKeys(usedKeys)
end

VerifyBtn.MouseButton1Click:Connect(function()
	local key = KeyInput.Text:gsub("^%s*(.-)%s*$", "%1")
	if #key == 0 then
		StatusText.Text = "Please enter a key!"
		StatusText.TextColor3 = Color3.fromRGB(255, 150, 50)
		return
	end
	if not isKeyValid(key) then
		if isKeyUsed(key) then
			StatusText.Text = "Key already used!"
			StatusText.TextColor3 = Color3.fromRGB(255, 150, 0)
		else
			StatusText.Text = "Invalid key!"
			StatusText.TextColor3 = Color3.fromRGB(255, 71, 87)
		end
		return
	end
	VerifyBtn.Text = "VERIFYING..."
	VerifyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
	task.delay(1, function()
		markKeyUsed(key)
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
	end)
end)
