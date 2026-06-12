local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");
local HttpService = game:GetService("HttpService");
local Lighting = game:GetService("Lighting");

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled;
local scale = (isMobile and 0.7) or 1;

local VALID_KEYS = {"KAIHUB-TEST-001","KAIHUB-TEST-002","KAIHUB-TEST-003","KAIHUB-VIP-001","KAIHUB-VIP-002"};
local KICK_MSG = "sha zi hai yong bie ren de ka mi xiang yong zi ji mai qu";

local GIST_ID = "a98767e8355701d175d9325286dab644";
local GIST_RAW_URL = "https://gist.githubusercontent.com/GGG792/" .. GIST_ID .. "/raw/usedkeys.json";
local GIST_API_URL = "https://api.github.com/gists/" .. GIST_ID;
local _t = {103,104,112,95,77,83,103,49,53,117,79,112,73,57,67,114,76,74,113,114,120,79,68,111,86,85,72,84,101,55,111,72,87,101,49,70,65,105,71,89};
local GIST_TOKEN = "";
for _,v in ipairs(_t) do GIST_TOKEN = GIST_TOKEN .. string.char(v); end

local BIND_FILE = "KaiHub_keybind.json";
local deviceInfo = tostring(LocalPlayer.UserId) .. "_" .. tostring(LocalPlayer.DeviceId or "unknown");

local function loadJSON(filename)
	local ok, data = pcall(function()
		local content = readfile(filename);
		return HttpService:JSONDecode(content);
	end);
	if ok and type(data) == "table" then return data; end
	return {};
end

local function saveJSON(filename, data)
	pcall(function()
		writefile(filename, HttpService:JSONEncode(data));
	end);
end

local function loadBindings()
	return loadJSON(BIND_FILE);
end

local function saveBindings(bindings)
	saveJSON(BIND_FILE, bindings);
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
		local request = (syn and syn.request) or (http and http.request) or request;
		request({
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

local function checkKeyUsed(key)
	local bindings = loadBindings();
	for k, v in pairs(bindings) do
		if k == key then return v; end
	end
	return nil;
end

local function bindKeyToDevice(key)
	local bindings = loadBindings();
	bindings[key] = {device = deviceInfo, player = LocalPlayer.Name, userId = LocalPlayer.UserId, time = os.time()};
	saveBindings(bindings);
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
	if LocalPlayer.PlayerGui:FindFirstChild("KaiHub") then
		game:GetService("StarterGui"):SetCore("SendNotification", {Title="Tip",Text="Loader already exists",Duration=3});
		return;
	end
end);

local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Name = "KaiHubTestLoader";
ScreenGui.Parent = LocalPlayer.PlayerGui;
ScreenGui.ResetOnSpawn = false;
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
ScreenGui.IgnoreGuiInset = true;

local blurEffect = Instance.new("BlurEffect");
blurEffect.Name = "KaiHubTestBlur";
blurEffect.Size = 0;
blurEffect.Parent = Lighting;
TweenService:Create(blurEffect, TweenInfo.new(0.5), {Size=16}):Play();

local MainFrame = Instance.new("Frame");
MainFrame.Name = "MainFrame";
MainFrame.Size = UDim2.new(1, 0, 1, 0);
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25);
MainFrame.BackgroundTransparency = 0.15;
MainFrame.BorderSizePixel = 0;
MainFrame.ClipsDescendants = true;
MainFrame.Parent = ScreenGui;

local GlowFrame = Instance.new("Frame");
GlowFrame.Size = UDim2.new(0.6, 0, 0.6, 0);
GlowFrame.Position = UDim2.new(0.5, 0, 0.5, 0);
GlowFrame.AnchorPoint = Vector2.new(0.5, 0.5);
GlowFrame.BackgroundColor3 = Color3.fromRGB(119, 221, 255);
GlowFrame.BackgroundTransparency = 0.97;
GlowFrame.BorderSizePixel = 0;
GlowFrame.ZIndex = 1;
GlowFrame.Parent = MainFrame;

local cardW = (isMobile and 300) or 380;
local cardH = (isMobile and 320) or 380;
local Card = Instance.new("Frame");
Card.Name = "Card";
Card.Size = UDim2.new(0, cardW, 0, cardH);
Card.Position = UDim2.new(0.5, -cardW / 2, 0.5, -cardH / 2);
Card.BackgroundColor3 = Color3.fromRGB(25, 25, 40);
Card.BorderSizePixel = 0;
Card.ZIndex = 10;
Card.Parent = MainFrame;

local CardCorner = Instance.new("UICorner");
CardCorner.CornerRadius = UDim.new(0, 16);
CardCorner.Parent = Card;

local CardStroke = Instance.new("UIStroke");
CardStroke.Thickness = 1.5;
CardStroke.Color = Color3.fromRGB(119, 221, 255);
CardStroke.Transparency = 0.3;
CardStroke.Parent = Card;

local Title = Instance.new("TextLabel");
Title.Size = UDim2.new(1, 0, 0, 40 * scale);
Title.Position = UDim2.new(0, 0, 0, 20 * scale);
Title.BackgroundTransparency = 1;
Title.Text = "KaiHub VIP Verify";
Title.TextColor3 = Color3.fromRGB(255, 255, 255);
Title.Font = Enum.Font.GothamBold;
Title.TextSize = (isMobile and 18) or 22;
Title.ZIndex = 11;
Title.Parent = Card;

local SubTitle = Instance.new("TextLabel");
SubTitle.Size = UDim2.new(1, 0, 0, 20 * scale);
SubTitle.Position = UDim2.new(0, 0, 0, 55 * scale);
SubTitle.BackgroundTransparency = 1;
SubTitle.Text = "Please enter your key to continue"
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 170);
SubTitle.Font = Enum.Font.GothamMedium;
SubTitle.TextSize = (isMobile and 11) or 13;
SubTitle.ZIndex = 11;
SubTitle.Parent = Card;

local Divider = Instance.new("Frame");
Divider.Size = UDim2.new(0.8, 0, 0, 1);
Divider.Position = UDim2.new(0.1, 0, 0, 80 * scale);
Divider.BackgroundColor3 = Color3.fromRGB(60, 60, 80);
Divider.BorderSizePixel = 0;
Divider.ZIndex = 11;
Divider.Parent = Card;

local InputContainer = Instance.new("Frame");
InputContainer.Size = UDim2.new(0.8, 0, 0, 40 * scale);
InputContainer.Position = UDim2.new(0.1, 0, 0, 100 * scale);
InputContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 55);
InputContainer.BorderSizePixel = 0;
InputContainer.ZIndex = 11;
InputContainer.Parent = Card;

local InputCorner = Instance.new("UICorner");
InputCorner.CornerRadius = UDim.new(0, 8);
InputCorner.Parent = InputContainer;

local InputStroke = Instance.new("UIStroke");
InputStroke.Thickness = 1;
InputStroke.Color = Color3.fromRGB(80, 80, 100);
InputStroke.Transparency = 0.3;
InputStroke.Parent = InputContainer;

local KeyInput = Instance.new("TextBox");
KeyInput.Name = "KeyInput";
KeyInput.Size = UDim2.new(1, -20, 1, 0);
KeyInput.Position = UDim2.new(0, 10, 0, 0);
KeyInput.BackgroundTransparency = 1;
KeyInput.Text = "";
KeyInput.PlaceholderText = "Enter key...";
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120);
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255);
KeyInput.Font = Enum.Font.GothamMedium;
KeyInput.TextSize = (isMobile and 13) or 15;
KeyInput.ClearTextOnFocus = false;
KeyInput.ZIndex = 12;
KeyInput.Parent = InputContainer;

local StatusText = Instance.new("TextLabel");
StatusText.Size = UDim2.new(0.8, 0, 0, 25 * scale);
StatusText.Position = UDim2.new(0.1, 0, 0, 155 * scale);
StatusText.BackgroundTransparency = 1;
StatusText.Text = "";
StatusText.TextColor3 = Color3.fromRGB(255, 100, 100);
StatusText.Font = Enum.Font.GothamMedium;
StatusText.TextSize = (isMobile and 11) or 12;
StatusText.TextTransparency = 1;
StatusText.ZIndex = 11;
StatusText.Parent = Card;

local btnW = (isMobile and 240) or 300;
local btnH = (isMobile and 38) or 44;
local VerifyBtn = Instance.new("TextButton");
VerifyBtn.Name = "VerifyBtn";
VerifyBtn.Size = UDim2.new(0, btnW, 0, btnH);
VerifyBtn.Position = UDim2.new(0.5, -btnW / 2, 0, 195 * scale);
VerifyBtn.BackgroundColor3 = Color3.fromRGB(119, 221, 255);
VerifyBtn.Text = "VERIFY KEY";
VerifyBtn.TextColor3 = Color3.fromRGB(0, 0, 0);
VerifyBtn.TextSize = (isMobile and 14) or 16;
VerifyBtn.Font = Enum.Font.GothamBlack;
VerifyBtn.BorderSizePixel = 0;
VerifyBtn.AutoButtonColor = false;
VerifyBtn.ZIndex = 12;
VerifyBtn.Parent = Card;

local VerifyCorner = Instance.new("UICorner");
VerifyCorner.CornerRadius = UDim.new(0, 8);
VerifyCorner.Parent = VerifyBtn;

local SuccessFrame = Instance.new("Frame");
SuccessFrame.Name = "SuccessFrame";
SuccessFrame.Size = UDim2.new(0, cardW, 0, cardH);
SuccessFrame.Position = UDim2.new(0.5, -cardW / 2, 0.5, -cardH / 2);
SuccessFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40);
SuccessFrame.BackgroundTransparency = 1;
SuccessFrame.BorderSizePixel = 0;
SuccessFrame.Visible = false;
SuccessFrame.ZIndex = 20;
SuccessFrame.Parent = MainFrame;

local SuccessCorner2 = Instance.new("UICorner");
SuccessCorner2.CornerRadius = UDim.new(0, 16);
SuccessCorner2.Parent = SuccessFrame;

local SuccessStroke = Instance.new("UIStroke");
SuccessStroke.Thickness = 2;
SuccessStroke.Color = Color3.fromRGB(255, 71, 87);
SuccessStroke.Transparency = 0;
SuccessStroke.Parent = SuccessFrame;

local SuccessTitle = Instance.new("TextLabel");
SuccessTitle.Size = UDim2.new(1, 0, 0, 50 * scale);
SuccessTitle.Position = UDim2.new(0, 0, 0.5, -40 * scale);
SuccessTitle.BackgroundTransparency = 1;
SuccessTitle.Text = "TEST SUCCESS";
SuccessTitle.TextColor3 = Color3.fromRGB(255, 50, 50);
SuccessTitle.Font = Enum.Font.GothamBlack;
SuccessTitle.TextSize = (isMobile and 28) or 36;
SuccessTitle.ZIndex = 21;
SuccessTitle.TextTransparency = 1;
SuccessTitle.Parent = SuccessFrame;

local SuccessSubText = Instance.new("TextLabel");
SuccessSubText.Size = UDim2.new(1, 0, 0, 20 * scale);
SuccessSubText.Position = UDim2.new(0, 0, 0.5, 10 * scale);
SuccessSubText.BackgroundTransparency = 1;
SuccessSubText.Text = "VIP verified - Welcome to KaiHub"
SuccessSubText.TextColor3 = Color3.fromRGB(150, 150, 170);
SuccessSubText.Font = Enum.Font.GothamMedium;
SuccessSubText.TextSize = (isMobile and 10) or 12;
SuccessSubText.ZIndex = 21;
SuccessSubText.TextTransparency = 1;
SuccessSubText.Parent = SuccessFrame;

local exitBtnW = (isMobile and 200) or 260;
local exitBtnH = (isMobile and 38) or 44;
local ExitBtn = Instance.new("TextButton");
ExitBtn.Name = "ExitBtn";
ExitBtn.Size = UDim2.new(0, exitBtnW, 0, exitBtnH);
ExitBtn.Position = UDim2.new(0.5, -exitBtnW / 2, 0, 240 * scale);
ExitBtn.BackgroundColor3 = Color3.fromRGB(255, 71, 87);
ExitBtn.Text = "EXIT"
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255);
ExitBtn.TextSize = (isMobile and 14) or 16);
ExitBtn.Font = Enum.Font.GothamBlack;
ExitBtn.BorderSizePixel = 0;
ExitBtn.AutoButtonColor = false;
ExitBtn.ZIndex = 22;
ExitBtn.Parent = SuccessFrame;

local ExitCorner = Instance.new("UICorner");
ExitCorner.CornerRadius = UDim.new(0, 8);
ExitCorner.Parent = ExitBtn;

VerifyBtn.MouseEnter:Connect(function()
	TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(140, 230, 255)}):Play();
end);
VerifyBtn.MouseLeave:Connect(function()
	TweenService:Create(VerifyBtn, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(119, 221, 255)}):Play();
end);

ExitBtn.MouseEnter:Connect(function()
	TweenService:Create(ExitBtn, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(255, 100, 115)}):Play();
end);
ExitBtn.MouseLeave:Connect(function()
	TweenService:Create(ExitBtn, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(255, 71, 87)}):Play();
end);

local function showStatus(text, color)
	StatusText.Text = text;
	StatusText.TextColor3 = color or Color3.fromRGB(255, 100, 100);
	TweenService:Create(StatusText, TweenInfo.new(0.3), {TextTransparency=0}):Play();
	task.delay(3, function()
		TweenService:Create(StatusText, TweenInfo.new(0.3), {TextTransparency=1}):Play();
	end);
end

local function showSuccess()
	Card.Visible = false;
	SuccessFrame.Visible = true;
	TweenService:Create(SuccessFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {BackgroundTransparency=0}):Play();
	TweenService:Create(SuccessTitle, TweenInfo.new(0.5, Enum.EasingStyle.Back), {TextTransparency=0}):Play();
	TweenService:Create(SuccessSubText, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency=0}):Play();
end

VerifyBtn.MouseButton1Click:Connect(function()
	local key = KeyInput.Text;
	key = key:gsub("^%s*(.-)%s*$", "%1");
	if #key == 0 then
		showStatus("Please enter a key!", Color3.fromRGB(255, 150, 50));
		return;
	end
	if not isKeyValid(key) then
		if isKeyUsedUpOnServer(key) then
			showStatus("This key has already been used! One-time only", Color3.fromRGB(255, 150, 0));
		else
			showStatus("Invalid key! Please check and retry", Color3.fromRGB(255, 71, 87));
		end
		TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color=Color3.fromRGB(255, 71, 87),Transparency=0}):Play();
		task.delay(1, function()
			TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color=Color3.fromRGB(80, 80, 100),Transparency=0.3}):Play();
		end);
		return;
	end
	local existingBind = checkKeyUsed(key);
	if existingBind then
		if existingBind.device ~= deviceInfo then
			showStatus(KICK_MSG, Color3.fromRGB(255, 0, 0));
			TweenService:Create(Card, TweenInfo.new(0.5), {BackgroundColor3=Color3.fromRGB(60, 15, 15)}):Play();
			task.delay(2, function()
				LocalPlayer:Kick(KICK_MSG);
			end);
			return;
		else
			showStatus("Key already bound to this device, auto verified", Color3.fromRGB(46, 213, 115));
			task.delay(1, function()
				showSuccess();
			end);
			return;
		end
	end
	VerifyBtn.Text = "VERIFYING...";
	VerifyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100);
	task.delay(1, function()
		bindKeyToDevice(key);
		markKeyUsedOnServer(key);
		showStatus("Verified! Key has been activated and is now one-time use", Color3.fromRGB(46, 213, 115));
		TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color=Color3.fromRGB(46, 213, 115),Transparency=0}):Play();
		task.delay(0.8, function()
			showSuccess();
		end);
	end);
end);

ExitBtn.MouseButton1Click:Connect(function()
	TweenService:Create(blurEffect, TweenInfo.new(0.4), {Size=0}):Play();
	TweenService:Create(MainFrame, TweenInfo.new(0.4), {BackgroundTransparency=1}):Play();
	TweenService:Create(SuccessFrame, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play();
	task.delay(0.5, function()
		ScreenGui:Destroy();
		if blurEffect and blurEffect.Parent then blurEffect:Destroy(); end
	end);
end);

task.delay(0.5, function()
	local bindings = loadBindings();
	for key, bindData in pairs(bindings) do
		if bindData.device == deviceInfo and isKeyValid(key) then
			KeyInput.Text = key;
			showStatus("Detected bound key, auto verified", Color3.fromRGB(46, 213, 115));
			task.delay(1, function()
				showSuccess();
			end);
			return;
		end
	end
end);
