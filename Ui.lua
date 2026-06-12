local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local TweenService = game:GetService("TweenService");
local HttpService = game:GetService("HttpService");

local GIST_ID = "a98767e8355701d175d9325286dab644";
local GIST_RAW_URL = "https://gist.githubusercontent.com/GGG792/" .. GIST_ID .. "/raw/usedkeys.json";
local GIST_API_URL = "https://api.github.com/gists/" .. GIST_ID;
local _t = {103,104,112,95,77,83,103,49,53,117,79,112,73,57,67,114,76,74,113,114,120,79,68,111,86,85,72,84,101,55,111,72,87,101,49,70,65,105,71,89};
local GIST_TOKEN = "";
for _,v in ipairs(_t) do GIST_TOKEN = GIST_TOKEN .. string.char(v); end

local VALID_KEYS = {"KAIHUB-TEST-001","KAIHUB-TEST-002","KAIHUB-TEST-003","KAIHUB-VIP-001","KAIHUB-VIP-002"};
local KICK_MSG = "sha zi hai yong bie ren de ka mi xiang yong zi ji mai qu";
local BIND_FILE = "KaiHub_keybind.json";
local deviceInfo = tostring(LocalPlayer.UserId) .. "_" .. tostring(LocalPlayer.DeviceId or "unknown");

local function loadJSON(filename)
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(filename));
	end);
	if ok and type(data) == "table" then return data; end
	return {};
end

local function saveJSON(filename, data)
	pcall(function()
		writefile(filename, HttpService:JSONEncode(data));
	end);
end

local function fetchUsedKeysFromServer()
	local ok, content = pcall(function()
		return game:HttpGet(GIST_RAW_URL);
	end);
	if ok and content then
		local ok2, data = pcall(function()
			return HttpService:JSONDecode(content);
		end);
		if ok2 and type(data) == "table" then return data; end
	end
	return {};
end

local function pushUsedKeysToServer(usedKeys)
	pcall(function()
		local payload = HttpService:JSONEncode({
			description = "KaiHub Key Verification",
			public = false,
			files = {["usedkeys.json"] = {content = HttpService:JSONEncode(usedKeys)}}
		});
		local req = (syn and syn.request) or (http and http.request) or request;
		req({
			Url = GIST_API_URL,
			Method = "PATCH",
			Headers = {
				["Authorization"] = "token " .. GIST_TOKEN,
				["Content-Type"] = "application/json",
				["Accept"] = "application/vnd.github.v3+json"
			},
			Body = payload
		});
	end);
end

local function markKeyUsedOnServer(key)
	local usedKeys = fetchUsedKeysFromServer();
	usedKeys[key] = {usedBy = LocalPlayer.Name, userId = LocalPlayer.UserId, device = deviceInfo, time = os.time()};
	pushUsedKeysToServer(usedKeys);
end

local function isKeyUsedUpOnServer(key)
	local usedKeys = fetchUsedKeysFromServer();
	return usedKeys[key] ~= nil;
end

local function isKeyValid(key)
	if isKeyUsedUpOnServer(key) then return false; end
	for _, k in ipairs(VALID_KEYS) do
		if k == key then return true; end
	end
	return false;
end

pcall(function()
	if LocalPlayer.PlayerGui:FindFirstChild("KaiHubTestLoader") then
		LocalPlayer.PlayerGui.KaiHubTestLoader:Destroy();
	end
end);

local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Name = "KaiHubTestLoader";
ScreenGui.Parent = LocalPlayer.PlayerGui;
ScreenGui.ResetOnSpawn = false;
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
ScreenGui.IgnoreGuiInset = true;

local MainFrame = Instance.new("Frame");
MainFrame.Size = UDim2.new(1, 0, 1, 0);
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25);
MainFrame.BackgroundTransparency = 0.2;
MainFrame.BorderSizePixel = 0;
MainFrame.Parent = ScreenGui;

local Card = Instance.new("Frame");
Card.Size = UDim2.new(0, 350, 0, 280);
Card.Position = UDim2.new(0.5, -175, 0.5, -140);
Card.BackgroundColor3 = Color3.fromRGB(30, 30, 45);
Card.BorderSizePixel = 0;
Card.Parent = MainFrame;

Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12);

local Title = Instance.new("TextLabel");
Title.Size = UDim2.new(1, 0, 0, 40);
Title.Position = UDim2.new(0, 0, 0, 20);
Title.BackgroundTransparency = 1;
Title.Text = "KaiHub VIP Verify";
Title.TextColor3 = Color3.fromRGB(255, 255, 255);
Title.Font = Enum.Font.GothamBold;
Title.TextSize = 22;
Title.Parent = Card;

local SubTitle = Instance.new("TextLabel");
SubTitle.Size = UDim2.new(1, 0, 0, 20);
SubTitle.Position = UDim2.new(0, 0, 0, 55);
SubTitle.BackgroundTransparency = 1;
SubTitle.Text = "Enter your key to continue";
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 170);
SubTitle.Font = Enum.Font.GothamMedium;
SubTitle.TextSize = 13;
SubTitle.Parent = Card;

local KeyInput = Instance.new("TextBox");
KeyInput.Size = UDim2.new(0, 280, 0, 38);
KeyInput.Position = UDim2.new(0.5, -140, 0, 100);
KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 65);
KeyInput.Text = "";
KeyInput.PlaceholderText = "Enter key...";
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120);
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255);
KeyInput.Font = Enum.Font.GothamMedium;
KeyInput.TextSize = 14;
KeyInput.ClearTextOnFocus = false;
KeyInput.Parent = Card;

Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8);

local StatusText = Instance.new("TextLabel");
StatusText.Size = UDim2.new(1, 0, 0, 20);
StatusText.Position = UDim2.new(0, 0, 0, 148);
StatusText.BackgroundTransparency = 1;
StatusText.Text = "";
StatusText.TextColor3 = Color3.fromRGB(255, 100, 100);
StatusText.Font = Enum.Font.GothamMedium;
StatusText.TextSize = 12;
StatusText.Parent = Card;

local VerifyBtn = Instance.new("TextButton");
VerifyBtn.Size = UDim2.new(0, 280, 0, 42);
VerifyBtn.Position = UDim2.new(0.5, -140, 0, 180);
VerifyBtn.BackgroundColor3 = Color3.fromRGB(119, 221, 255);
VerifyBtn.Text = "VERIFY KEY";
VerifyBtn.TextColor3 = Color3.fromRGB(0, 0, 0);
VerifyBtn.TextSize = 16;
VerifyBtn.Font = Enum.Font.GothamBlack;
VerifyBtn.BorderSizePixel = 0;
VerifyBtn.AutoButtonColor = false;
VerifyBtn.Parent = Card;

Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 8);

local SuccessFrame = Instance.new("Frame");
SuccessFrame.Size = UDim2.new(0, 350, 0, 280);
SuccessFrame.Position = UDim2.new(0.5, -175, 0.5, -140);
SuccessFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45);
SuccessFrame.Visible = false;
SuccessFrame.Parent = MainFrame;

Instance.new("UICorner", SuccessFrame).CornerRadius = UDim.new(0, 12);

local SuccessTitle = Instance.new("TextLabel");
SuccessTitle.Size = UDim2.new(1, 0, 0, 50);
SuccessTitle.Position = UDim2.new(0, 0, 0.5, -60);
SuccessTitle.BackgroundTransparency = 1;
SuccessTitle.Text = "TEST SUCCESS";
SuccessTitle.TextColor3 = Color3.fromRGB(255, 50, 50);
SuccessTitle.Font = Enum.Font.GothamBlack;
SuccessTitle.TextSize = 32;
SuccessTitle.Parent = SuccessFrame;

local SuccessSubText = Instance.new("TextLabel");
SuccessSubText.Size = UDim2.new(1, 0, 0, 20);
SuccessSubText.Position = UDim2.new(0, 0, 0.5, 0);
SuccessSubText.BackgroundTransparency = 1;
SuccessSubText.Text = "VIP verified - Welcome to KaiHub";
SuccessSubText.TextColor3 = Color3.fromRGB(150, 150, 170);
SuccessSubText.Font = Enum.Font.GothamMedium;
SuccessSubText.TextSize = 12;
SuccessSubText.Parent = SuccessFrame;

local ExitBtn = Instance.new("TextButton");
ExitBtn.Size = UDim2.new(0, 240, 0, 42);
ExitBtn.Position = UDim2.new(0.5, -120, 0, 200);
ExitBtn.BackgroundColor3 = Color3.fromRGB(255, 71, 87);
ExitBtn.Text = "EXIT";
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255);
ExitBtn.TextSize = 16;
ExitBtn.Font = Enum.Font.GothamBlack;
ExitBtn.BorderSizePixel = 0;
ExitBtn.AutoButtonColor = false;
ExitBtn.Parent = SuccessFrame;

Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8);

VerifyBtn.MouseButton1Click:Connect(function()
	local key = KeyInput.Text:gsub("^%s*(.-)%s*$", "%1");
	if #key == 0 then
		StatusText.Text = "Please enter a key!";
		StatusText.TextColor3 = Color3.fromRGB(255, 150, 50);
		return;
	end
	if not isKeyValid(key) then
		if isKeyUsedUpOnServer(key) then
			StatusText.Text = "This key has already been used!";
			StatusText.TextColor3 = Color3.fromRGB(255, 150, 0);
		else
			StatusText.Text = "Invalid key!";
			StatusText.TextColor3 = Color3.fromRGB(255, 71, 87);
		end
		return;
	end
	VerifyBtn.Text = "VERIFYING...";
	VerifyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100);
	task.delay(1, function()
		local bindings = loadJSON(BIND_FILE);
		bindings[key] = {device = deviceInfo, player = LocalPlayer.Name, userId = LocalPlayer.UserId, time = os.time()};
		saveJSON(BIND_FILE, bindings);
		markKeyUsedOnServer(key);
		Card.Visible = false;
		SuccessFrame.Visible = true;
	end);
end);

ExitBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy();
end);

task.delay(0.3, function()
	local bindings = loadJSON(BIND_FILE);
	for key, bindData in pairs(bindings) do
		if bindData.device == deviceInfo and isKeyValid(key) then
			KeyInput.Text = key;
			Card.Visible = false;
			SuccessFrame.Visible = true;
			return;
		end
	end
end);
