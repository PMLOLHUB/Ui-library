--[[
	NIER UI Library
	ใช้ระบบเดียวกับ library PMS ที่ส่งมา แต่ดีไซน์เป็น NieR (กระดาษเบจ แถบหัวเข้ม แท็บสี่เหลี่ยม)

	API (เหมือนเดิม)
	  local Window = Library:CreateWindow("Label", Config)
	  local Tab, Page, Btn = Window:CreateCategory("TAB 1", icon?, hidden?)
	  Tab:CreateLabel / CreateButton / CreateToggle / CreateSlider / CreateTextbox / CreateNumberTextbox
	  Tab:CreateSearchBar / CreateColorPicker / CreateDropdown / CreateMultiDropdown
	  Window:GetFlag / SetFlag / SaveConfiguration / Show / Hide / ToggleVisibility / Destroy
	  Window:OpenSettings / CloseSettings / ToggleSettings
	  Window.ApplyTeamColor / UpdateTeamColor / GetTeamColor
	  Window.UpdateBackgroundImage / UpdateBackgroundImageTransparency / UpdateBackgroundImageEnabled
	  เพิ่มใหม่: Window:Notify(text, seconds)

	Config ที่รองรับ
	  Theme ("Paper" "Dusk" "Moss" "Rose" "Slate" "Night"), ThemeColor/CategoryColor (สี Accent),
	  TextColor, BackgroundColor, ElementColor/ButtonColor (สีแถว), TeamColor, ElementTransparency,
	  FontFamily, FontScale, Language ("en" / "th"), BorderEnabled, StripAnimation,
	  BackgroundImage, BackgroundImageTransparency, BackgroundImageEnabled,
	  Logo, ToggleConfig = {Text, Image}, ToggleKey (Enum.KeyCode, false = ปิด), ToggleHint,
	  DisplayOrder, StartOpen, ShowSettingsTab
]]

local Library = {}

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ConfigFileName = "NIER_Config.json"
local EnableSave = true

local Flags = {}
local ThemeSettings = {}

local WHITE = Color3.new(1, 1, 1)

------------------------------------------------------------------ Save / Load
local function fileApiReady()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function SaveConfig(frame)
	if not EnableSave or not frame or not fileApiReady() then
		return
	end
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local pos, size = frame.AbsolutePosition, frame.AbsoluteSize

	local data = { Width = size.X, Height = size.Y }
	if pos.X < 0 or pos.Y < 0 or pos.X + size.X > viewport.X or pos.Y + size.Y > viewport.Y then
		data.PosX = viewport.X / 2 - size.X / 2
		data.PosY = viewport.Y / 2 - size.Y / 2
	else
		data.PosX, data.PosY = pos.X, pos.Y
	end

	data.Flags = {}
	for name, flag in pairs(Flags) do
		data.Flags[name] = flag.Value
	end
	data.Theme = ThemeSettings

	local ok, json = pcall(function()
		return HttpService:JSONEncode(data)
	end)
	if ok then
		pcall(writefile, ConfigFileName, json)
	end
end

local function LoadConfig()
	if not EnableSave or not fileApiReady() or not isfile(ConfigFileName) then
		return
	end
	local ok, content = pcall(readfile, ConfigFileName)
	if not ok or not content then
		return
	end
	local ok2, data = pcall(function()
		return HttpService:JSONDecode(content)
	end)
	if ok2 and type(data) == "table" and data.Width and data.Height then
		local size = UDim2.fromOffset(data.Width, data.Height)
		local pos = (data.PosX and data.PosY) and UDim2.fromOffset(data.PosX, data.PosY) or nil
		return size, pos, data.Flags, data.Theme
	end
end

------------------------------------------------------------------ Icons (ชุดย่อ — เพิ่มเองได้ที่ Library.Icons["lucide-xxx"] = "rbxassetid://...")
local Icons = {
	["lucide-activity"] = "rbxassetid://10709752035",
	["lucide-baseline"] = "rbxassetid://10709773863",
	["lucide-check"] = "rbxassetid://10709790644",
	["lucide-check-circle"] = "rbxassetid://10709790387",
	["lucide-chevron-down"] = "rbxassetid://10709790948",
	["lucide-circle"] = "rbxassetid://10709798174",
	["lucide-eye"] = "rbxassetid://10723346959",
	["lucide-flame"] = "rbxassetid://10723376114",
	["lucide-glasses"] = "rbxassetid://10723397895",
	["lucide-home"] = "rbxassetid://10723407389",
	["lucide-image"] = "rbxassetid://10723415040",
	["lucide-languages"] = "rbxassetid://10723417703",
	["lucide-layout-dashboard"] = "rbxassetid://10723424646",
	["lucide-layout-grid"] = "rbxassetid://10723424838",
	["lucide-list"] = "rbxassetid://10723433811",
	["lucide-palette"] = "rbxassetid://10734910430",
	["lucide-rotate-ccw"] = "rbxassetid://10734940376",
	["lucide-save"] = "rbxassetid://10734941499",
	["lucide-search"] = "rbxassetid://10734943674",
	["lucide-settings"] = "rbxassetid://10734950309",
	["lucide-sliders-horizontal"] = "rbxassetid://10734963191",
	["lucide-square"] = "rbxassetid://10734965702",
	["lucide-sword"] = "rbxassetid://10734975486",
	["lucide-user"] = "rbxassetid://10747373176",
	["lucide-users"] = "rbxassetid://10747373426",
	["lucide-wand-2"] = "rbxassetid://10747376349",
}
setmetatable(Icons, {
	__index = function(t, k)
		if type(k) ~= "string" then
			return nil
		end
		local v = rawget(t, "lucide-" .. k)
		if v then
			rawset(t, k, v)
		end
		return v
	end,
})
Library.Icons = Icons

local function resolveIcon(name)
	if type(name) ~= "string" or name == "" then
		return nil
	end
	if string.find(name, "rbxassetid://", 1, true) then
		return name
	end
	return Icons[name]
end

------------------------------------------------------------------ Translations
local Translations = {
	en = {
		Settings = "Settings",
		PresetHeader = "Preset Themes",
		PresetLabel = "Choose a Preset Theme",
		ColorHeader = "Colors",
		PaperLabel = "Background (Paper)",
		RowLabel = "Elements (Rows)",
		AccentLabel = "Accent (Title Bar / Selected Tab)",
		InkLabel = "Text",
		CreamLabel = "Text on Accent",
		LineLabel = "Lines / Border",
		TeamLabel = "Team Color",
		TransparencyLabel = "Transparency (%)",
		FontHeader = "Font Settings",
		FontFamilyLabel = "Font Family",
		FontSizeLabel = "Font Size (%)",
		EffectsHeader = "Other Effects",
		AnimToggle = "Open / Close Strip Animation",
		BorderToggle = "Show Border",
		BgImageHeader = "Background Image",
		BgImageEnable = "Enable Background Image",
		BgImageLabel = "Image Asset ID",
		BgImagePlaceholder = "rbxassetid://0000000000",
		BgImageTransparencyLabel = "Background Image Transparency (%)",
		LanguageHeader = "Language",
		LanguageLabel = "Select Language",
		ManageHeader = "Manage Settings",
		SaveButton = "Save Settings",
		ResetButton = "Reset to Default",
	},
	th = {
		Settings = "ตั้งค่า",
		PresetHeader = "ธีมสำเร็จรูป",
		PresetLabel = "เลือกธีมสำเร็จรูป",
		ColorHeader = "สี",
		PaperLabel = "พื้นหลัง (กระดาษ)",
		RowLabel = "สีแถว (Element)",
		AccentLabel = "สี Accent (แถบหัว / แท็บที่เลือก)",
		InkLabel = "สีตัวอักษร",
		CreamLabel = "สีตัวอักษรบน Accent",
		LineLabel = "สีเส้น / ขอบ",
		TeamLabel = "สีทีม (Team)",
		TransparencyLabel = "ความโปร่งแสง (%)",
		FontHeader = "ตั้งค่าฟอนต์",
		FontFamilyLabel = "รูปแบบฟอนต์",
		FontSizeLabel = "ขนาดตัวอักษร (%)",
		EffectsHeader = "เอฟเฟกต์อื่นๆ",
		AnimToggle = "แอนิเมชันแถบเฉียงตอนเปิด/ปิด",
		BorderToggle = "แสดงเส้นขอบ (Border)",
		BgImageHeader = "พื้นหลังรูปภาพ",
		BgImageEnable = "เปิดใช้งานพื้นหลังรูปภาพ",
		BgImageLabel = "Asset ID รูปภาพ",
		BgImagePlaceholder = "rbxassetid://0000000000",
		BgImageTransparencyLabel = "ความโปร่งแสงของพื้นหลังรูปภาพ (%)",
		LanguageHeader = "ภาษา",
		LanguageLabel = "เลือกภาษา",
		ManageHeader = "จัดการการตั้งค่า",
		SaveButton = "บันทึกการตั้งค่า",
		ResetButton = "รีเซ็ตเป็นค่าเริ่มต้น",
	},
}

------------------------------------------------------------------ Preset themes (ทุกธีมมี 7 โทนสี)
local Presets = {
	Paper = { Paper = { 211, 205, 178 }, Row = { 188, 182, 159 }, Accent = { 58, 57, 49 }, Ink = { 76, 74, 63 }, Cream = { 241, 236, 208 }, Line = { 163, 157, 133 }, Team = { 120, 110, 80 } },
	Dusk = { Paper = { 196, 184, 170 }, Row = { 172, 158, 144 }, Accent = { 70, 52, 58 }, Ink = { 70, 54, 56 }, Cream = { 244, 232, 222 }, Line = { 150, 134, 124 }, Team = { 150, 90, 100 } },
	Moss = { Paper = { 198, 202, 176 }, Row = { 172, 178, 148 }, Accent = { 46, 60, 44 }, Ink = { 52, 64, 48 }, Cream = { 236, 242, 218 }, Line = { 146, 154, 124 }, Team = { 90, 130, 80 } },
	Rose = { Paper = { 222, 200, 196 }, Row = { 200, 172, 170 }, Accent = { 92, 48, 56 }, Ink = { 86, 52, 58 }, Cream = { 250, 236, 232 }, Line = { 176, 148, 148 }, Team = { 170, 80, 100 } },
	Slate = { Paper = { 190, 196, 200 }, Row = { 164, 172, 178 }, Accent = { 44, 52, 60 }, Ink = { 48, 56, 64 }, Cream = { 232, 238, 242 }, Line = { 140, 148, 154 }, Team = { 70, 110, 150 } },
	Night = { Paper = { 52, 50, 44 }, Row = { 70, 68, 60 }, Accent = { 24, 23, 20 }, Ink = { 222, 216, 192 }, Cream = { 236, 230, 206 }, Line = { 96, 92, 80 }, Team = { 150, 140, 100 } },
}
local PresetOrder = { "Paper", "Dusk", "Moss", "Rose", "Slate", "Night" }
Library.Presets = Presets

------------------------------------------------------------------ Fonts
local FontPresets, FontPresetOrder = {}, {}
for _, fontEnum in ipairs(Enum.Font:GetEnumItems()) do
	local name = fontEnum.Name
	local okBold, boldEnum = pcall(function()
		return Enum.Font[name .. "Bold"]
	end)
	FontPresets[name] = { Regular = fontEnum, Bold = (okBold and boldEnum) or fontEnum }
	table.insert(FontPresetOrder, name)
end
table.sort(FontPresetOrder)

------------------------------------------------------------------ Helpers
local function new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function c3(t)
	return Color3.fromRGB(t[1], t[2], t[3])
end

local function arr(c)
	return { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) }
end

local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local function joinList(list)
	local t = {}
	for i, v in ipairs(list) do
		t[i] = tostring(v)
	end
	return table.concat(t, ", ")
end

local function toHex(c)
	local function b(n)
		return string.format("%02X", math.clamp(math.floor(n * 255 + 0.5), 0, 255))
	end
	return "#" .. b(c.R) .. b(c.G) .. b(c.B)
end

------------------------------------------------------------------ CreateWindow
function Library:CreateWindow(WindowName, Config)
	Config = Config or {}
	local ToggleConfig = Config.ToggleConfig or {}
	local isFirstTab = true

	local connections = {}
	local function connect(signal, fn)
		local c = signal:Connect(fn)
		table.insert(connections, c)
		return c
	end

	-------------------------------------------------------------- Theme tokens
	local Theme = {}
	local function loadPreset(p)
		for token, v in pairs(p) do
			Theme[token] = c3(v)
		end
	end
	loadPreset(Presets.Paper)
	if type(Config.Theme) == "string" and Presets[Config.Theme] then
		loadPreset(Presets[Config.Theme])
	end
	local function cfgColor(key, token)
		if typeof(Config[key]) == "Color3" then
			Theme[token] = Config[key]
		end
	end
	cfgColor("BackgroundColor", "Paper")
	cfgColor("ElementColor", "Row")
	cfgColor("ButtonColor", "Row")
	cfgColor("ThemeColor", "Accent")
	cfgColor("CategoryColor", "Accent")
	cfgColor("TextColor", "Ink")
	cfgColor("TeamColor", "Team")

	local GTrans = math.clamp(Config.ElementTransparency or 0, 0, 0.9)
	local FontScale = Config.FontScale or 1
	local FontFamily = (Config.FontFamily and FontPresets[Config.FontFamily]) and Config.FontFamily or "Gotham"
	local Language = "en"
	local cfgLang = Config.Language and string.lower(tostring(Config.Language))
	if cfgLang == "th" or cfgLang == "thai" then
		Language = "th"
	end
	local StripAnim = Config.StripAnimation ~= false
	local BorderEnabled = Config.BorderEnabled ~= false
	local BgImage = Config.BackgroundImage or ""
	local BgImageTransparency = Config.BackgroundImageTransparency or 0.5
	local BgImageEnabled = BgImage ~= ""
	if Config.BackgroundImageEnabled ~= nil then
		BgImageEnabled = Config.BackgroundImageEnabled
	end

	local savedSize, savedPos, savedFlags, savedTheme = LoadConfig()
	if type(savedTheme) == "table" then
		if type(savedTheme.Colors) == "table" then
			for token, v in pairs(savedTheme.Colors) do
				if Theme[token] and type(v) == "table" and v[3] then
					Theme[token] = c3(v)
				end
			end
		end
		if savedTheme.Transparency ~= nil then GTrans = savedTheme.Transparency end
		if savedTheme.FontScale ~= nil then FontScale = savedTheme.FontScale end
		if savedTheme.FontFamily and FontPresets[savedTheme.FontFamily] then FontFamily = savedTheme.FontFamily end
		if savedTheme.Language == "th" or savedTheme.Language == "en" then Language = savedTheme.Language end
		if savedTheme.StripAnimation ~= nil then StripAnim = savedTheme.StripAnimation end
		if savedTheme.BorderEnabled ~= nil then BorderEnabled = savedTheme.BorderEnabled end
		if savedTheme.BackgroundImage ~= nil then BgImage = savedTheme.BackgroundImage end
		if savedTheme.BackgroundImageTransparency ~= nil then BgImageTransparency = savedTheme.BackgroundImageTransparency end
		if savedTheme.BackgroundImageEnabled ~= nil then BgImageEnabled = savedTheme.BackgroundImageEnabled end
	end
	local SavedFlags = savedFlags or {}
	if SavedFlags["BackgroundImageAssetId"] == nil then
		SavedFlags["BackgroundImageAssetId"] = BgImage
	end

	-------------------------------------------------------------- Registries (theme / font / glass / hover)
	local themed, lookers, fonts, glass = {}, {}, {}, {}

	local function resolve(spec)
		if type(spec) == "function" then
			return spec(Theme)
		end
		return Theme[spec]
	end
	local function bind(inst, prop, spec)
		inst[prop] = resolve(spec)
		table.insert(themed, { inst, prop, spec })
		return inst
	end
	local function refreshTheme()
		for i = #themed, 1, -1 do
			local e = themed[i]
			if e[1].Parent == nil then
				table.remove(themed, i)
			else
				e[1][e[2]] = resolve(e[3])
			end
		end
		for i = #lookers, 1, -1 do
			local l = lookers[i]
			if l.row.Parent == nil then
				table.remove(lookers, i)
			else
				l.fn(false)
			end
		end
	end

	local function applyFont(inst, size, bold)
		local preset = FontPresets[FontFamily] or FontPresets.Gotham
		inst.Font = bold and preset.Bold or preset.Regular
		inst.TextSize = math.floor(size * FontScale + 0.5)
	end
	local function bindFont(inst, size, bold)
		applyFont(inst, size, bold)
		table.insert(fonts, { inst, size, bold })
	end
	local function refreshFonts()
		for i = #fonts, 1, -1 do
			local f = fonts[i]
			if f[1].Parent == nil then
				table.remove(fonts, i)
			else
				applyFont(f[1], f[2], f[3])
			end
		end
	end

	local function bindGlass(inst)
		inst.BackgroundTransparency = GTrans
		table.insert(glass, inst)
	end
	local function setGlass(t)
		GTrans = math.clamp(t, 0, 0.9)
		for i = #glass, 1, -1 do
			if glass[i].Parent == nil then
				table.remove(glass, i)
			else
				glass[i].BackgroundTransparency = GTrans
			end
		end
	end

	local function inputColor(t)
		return t.Row:Lerp(WHITE, 0.45)
	end
	local function listColor(t)
		return t.Row:Lerp(t.Paper, 0.5)
	end
	local function dimInk(t)
		return t.Ink:Lerp(t.Paper, 0.45)
	end

	-------------------------------------------------------------- ScreenGui + MainFrame
	local gui = new("ScreenGui", {
		Name = "NIER_UI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = Config.DisplayOrder or 999,
	})
	do
		local placed = false
		if type(gethui) == "function" then
			placed = pcall(function()
				gui.Parent = gethui()
			end)
		end
		if not placed then
			placed = pcall(function()
				gui.Parent = game:GetService("CoreGui")
			end)
		end
		if not placed or not gui.Parent then
			gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
		end
	end

	local camera = workspace.CurrentCamera
	local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local startSize = savedSize or UDim2.fromOffset(math.min(580, math.floor(vp.X * 0.94)), math.min(330, math.floor(vp.Y * 0.8)))
	local startPos = savedPos or UDim2.new(0.5, -startSize.X.Offset / 2, 0.5, -startSize.Y.Offset / 2)

	local main = new("Frame", {
		Name = "MainFrame",
		Size = startSize,
		Position = startPos,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
	}, gui)
	bind(main, "BackgroundColor3", "Paper")
	bindGlass(main)
	local mainStroke = new("UIStroke", { Thickness = 1, Enabled = BorderEnabled }, main)
	bind(mainStroke, "Color", "Line")

	local bgImageLabel = new("ImageLabel", {
		Name = "CustomBackgroundImage",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0,
		Image = BgImage,
		ImageTransparency = BgImageTransparency,
		ScaleType = Enum.ScaleType.Crop,
		Visible = BgImageEnabled and BgImage ~= "",
	}, main)
	local function UpdateBackgroundImage(id)
		BgImage = id or ""
		bgImageLabel.Image = BgImage
		bgImageLabel.Visible = BgImageEnabled and BgImage ~= ""
	end
	local function UpdateBackgroundImageTransparency(t)
		BgImageTransparency = t
		bgImageLabel.ImageTransparency = t
	end
	local function UpdateBackgroundImageEnabled(state)
		BgImageEnabled = state
		bgImageLabel.Visible = BgImageEnabled and BgImage ~= ""
	end

	-------------------------------------------------------------- Persist helpers
	local function persistTheme()
		local colors = {}
		for token, col in pairs(Theme) do
			colors[token] = arr(col)
		end
		ThemeSettings.Colors = colors
		ThemeSettings.Transparency = GTrans
		ThemeSettings.FontFamily = FontFamily
		ThemeSettings.FontScale = FontScale
		ThemeSettings.Language = Language
		ThemeSettings.StripAnimation = StripAnim
		ThemeSettings.BorderEnabled = BorderEnabled
		ThemeSettings.BackgroundImage = BgImage
		ThemeSettings.BackgroundImageTransparency = BgImageTransparency
		ThemeSettings.BackgroundImageEnabled = BgImageEnabled
	end
	persistTheme()
	local function save()
		persistTheme()
		SaveConfig(main)
	end

	-------------------------------------------------------------- Drag helpers
	local function makeDraggable(handle, target, onEnd)
		target = target or handle
		local dragging, dragStart, startP, moved = false, nil, nil, false
		connect(handle.InputBegan, function(input)
			if isPointer(input) then
				dragging, moved = true, false
				dragStart, startP = input.Position, target.Position
				local c
				c = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						c:Disconnect()
						if onEnd and moved then
							onEnd()
						end
					end
				end)
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if dragging and isMove(input) then
				local d = input.Position - dragStart
				if d.Magnitude > 4 then
					moved = true
				end
				target.Position = UDim2.new(startP.X.Scale, startP.X.Offset + d.X, startP.Y.Scale, startP.Y.Offset + d.Y)
			end
		end)
		return function()
			return moved
		end
	end

	local function makeDrag(obj, update, onEnd)
		local dragging = false
		connect(obj.InputBegan, function(input)
			if isPointer(input) then
				dragging = true
				update(input)
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if dragging and isMove(input) then
				update(input)
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if dragging and isPointer(input) then
				dragging = false
				if onEnd then
					onEnd()
				end
			end
		end)
	end

	-------------------------------------------------------------- Chrome: title bar, lines, sidebar, content
	local top = new("Frame", { Name = "TopBar", Size = UDim2.new(1, 0, 0, 24), BorderSizePixel = 0, ZIndex = 3 }, main)
	bind(top, "BackgroundColor3", "Accent")

	local titleX = 24
	if Config.Logo and Config.Logo ~= "" then
		new("ImageLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 6, 0.5, -8),
			Size = UDim2.fromOffset(16, 16),
			Image = Config.Logo,
			ZIndex = 4,
		}, top)
		titleX = 28
	else
		local dia = new("Frame", {
			Position = UDim2.new(0, 10, 0.5, -3),
			Size = UDim2.fromOffset(7, 7),
			Rotation = 45,
			BorderSizePixel = 0,
			ZIndex = 4,
		}, top)
		bind(dia, "BackgroundColor3", "Cream")
	end

	local titleLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, titleX, 0, 0),
		Size = UDim2.new(1, -titleX - 34, 1, 0),
		Text = WindowName or "NIER UI",
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 4,
	}, top)
	bindFont(titleLabel, 12, true)
	bind(titleLabel, "TextColor3", "Cream")

	local gearBtn = new("ImageButton", {
		Name = "SettingsGearBtn",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -24, 0.5, -8),
		Size = UDim2.fromOffset(16, 16),
		Image = Icons["lucide-settings"] or "",
		ZIndex = 5,
	}, top)
	bind(gearBtn, "ImageColor3", "Cream")

	local function hline(parent, pos, size)
		local f = new("Frame", { Position = pos, Size = size, BorderSizePixel = 0, ZIndex = 2 }, parent)
		bind(f, "BackgroundColor3", "Line")
		return f
	end
	hline(main, UDim2.fromOffset(0, 24), UDim2.new(1, 0, 0, 1))
	hline(main, UDim2.new(0, 0, 1, -5), UDim2.new(1, 0, 0, 1))

	local body = new("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 1, -34),
	}, main)

	local Sidebar = new("ScrollingFrame", {
		Name = "Sidebar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0.27, 0, 1, 0),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, body)
	new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7) }, Sidebar)
	new("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9), PaddingTop = UDim.new(0, 10) }, Sidebar)

	hline(body, UDim2.new(0.27, 0, 0, 0), UDim2.new(0, 1, 1, 0))
	hline(body, UDim2.new(0.27, 3, 0, 0), UDim2.new(0, 2, 1, 0))

	local ContentContainer = new("Frame", {
		Name = "ContentContainer",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0.27, 10, 0, 0),
		Size = UDim2.new(0.73, -10, 1, 0),
	}, body)
	local rail = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -9, 0, 8),
		Size = UDim2.new(0, 4, 1, -16),
		ZIndex = 5,
	}, ContentContainer)
	local railStroke = new("UIStroke", { Thickness = 1 }, rail)
	bind(railStroke, "Color", "Line")

	makeDraggable(top, main, function()
		save()
	end)

	-- ปุ่มปรับขนาด
	local resizeBtn = new("TextButton", {
		Name = "ResizeBtn",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(18, 18),
		Text = "◢",
		ZIndex = 10,
	}, main)
	bindFont(resizeBtn, 14, true)
	bind(resizeBtn, "TextColor3", "Accent")
	do
		local resizing, resizeStart, startAbs = false, nil, nil
		connect(resizeBtn.InputBegan, function(input)
			if isPointer(input) then
				resizing, resizeStart, startAbs = true, input.Position, main.AbsoluteSize
			end
		end)
		connect(UserInputService.InputChanged, function(input)
			if resizing and isMove(input) then
				local d = input.Position - resizeStart
				main.Size = UDim2.fromOffset(math.clamp(startAbs.X + d.X, 360, 900), math.clamp(startAbs.Y + d.Y, 240, 650))
			end
		end)
		connect(UserInputService.InputEnded, function(input)
			if resizing and isPointer(input) then
				resizing = false
				save()
			end
		end)
	end

	-------------------------------------------------------------- Open / close (แถบเฉียงแบบวิดีโอ)
	local strips = {}
	local overlay = new("Frame", {
		Name = "Strips",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 50,
	}, main)
	for i = 1, 9 do
		local s = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(-0.1 + (i - 1) * 0.15, 0, 0.5, 0),
			Size = UDim2.new(0.22, 0, 1.7, 0),
			Rotation = 18,
			BorderSizePixel = 0,
			ZIndex = 50,
		}, overlay)
		bind(s, "BackgroundColor3", "Paper")
		strips[i] = s
	end

	local animating = false
	local function SetWindowOpen(shouldOpen)
		if animating or shouldOpen == main.Visible then
			return
		end
		local targetY = shouldOpen and 0 or 1.7
		if not StripAnim then
			for _, s in ipairs(strips) do
				s.Size = UDim2.new(0.22, 0, targetY, 0)
			end
			main.Visible = shouldOpen
			return
		end
		animating = true
		if shouldOpen then
			main.Visible = true
		end
		for i, s in ipairs(strips) do
			task.delay((i - 1) * 0.03, function()
				TweenService:Create(
					s,
					TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{ Size = UDim2.new(0.22, 0, targetY, 0) }
				):Play()
			end)
		end
		task.delay(#strips * 0.03 + 0.34, function()
			if not shouldOpen then
				main.Visible = false
			end
			animating = false
		end)
	end

	-------------------------------------------------------------- ปุ่มลอยเปิด/ปิด
	local toggleBtn = new("ImageButton", {
		Name = "ToggleBtn",
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.fromOffset(44, 44),
		BorderSizePixel = 0,
		AutoButtonColor = true,
		ImageTransparency = 1,
	}, gui)
	bind(toggleBtn, "BackgroundColor3", "Accent")
	local tbStroke = new("UIStroke", { Thickness = 1 }, toggleBtn)
	bind(tbStroke, "Color", "Line")
	if ToggleConfig.Image and ToggleConfig.Image ~= "" then
		toggleBtn.Image = ToggleConfig.Image
		toggleBtn.ImageTransparency = 0
	end
	local tbText = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = ToggleConfig.Text or (ToggleConfig.Image and "" or "◆"),
	}, toggleBtn)
	bindFont(tbText, 16, true)
	bind(tbText, "TextColor3", "Cream")
	local tbMoved = makeDraggable(toggleBtn)
	toggleBtn.MouseButton1Click:Connect(function()
		if not tbMoved() then
			SetWindowOpen(not main.Visible)
		end
	end)

	-------------------------------------------------------------- Notify
	local toastHolder = new("Frame", {
		Name = "Toasts",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 14, 1, -14),
		Size = UDim2.fromOffset(320, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, gui)
	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, toastHolder)

	local function Notify(text, duration)
		local t = new("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.fromOffset(0, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(243, 237, 196),
			TextColor3 = Color3.fromRGB(76, 74, 63),
			Text = tostring(text),
			TextSize = 13,
			Font = Enum.Font.Gotham,
		}, toastHolder)
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9),
			PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
		}, t)
		task.delay(duration or 3, function()
			if t.Parent then
				TweenService:Create(t, TweenInfo.new(0.25), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
				task.wait(0.3)
				t:Destroy()
			end
		end)
	end

	-------------------------------------------------------------- Settings panel state
	local SettingsState = { open = false }
	local ToggleSettingsVisibility = function() end
	local OpenSettingsFn = function() end
	local CloseSettingsFn = function() end
	gearBtn.MouseButton1Click:Connect(function()
		ToggleSettingsVisibility()
	end)

	local function AnimatePageIn(page)
		if not page then return end
		local basePos = page:GetAttribute("BasePosition")
		if not basePos then
			basePos = page.Position
			page:SetAttribute("BasePosition", basePos)
		end
		page.Position = UDim2.new(basePos.X.Scale, basePos.X.Offset, basePos.Y.Scale, basePos.Y.Offset + 10)
		TweenService:Create(page, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = basePos }):Play()
	end

	-------------------------------------------------------------- Window API
	local WindowElements = {}

	function WindowElements:OpenSettings() OpenSettingsFn() end
	function WindowElements:CloseSettings() CloseSettingsFn() end
	function WindowElements:ToggleSettings() ToggleSettingsVisibility() end

	function WindowElements:CreateCategory(CategoryName, IconName, Hidden)
		local CategoryElements = {}

		---------------------------------------------------------- sidebar button
		local btn = new("TextButton", {
			Name = CategoryName,
			Size = UDim2.new(1, 0, 0, 28),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Visible = not Hidden,
		}, Sidebar)
		btn:SetAttribute("CategorySelected", false)

		local catAsset = resolveIcon(IconName)
		local catMarker
		if catAsset then
			catMarker = new("ImageLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 8, 0.5, -8),
				Size = UDim2.fromOffset(16, 16),
				Image = catAsset,
			}, btn)
		else
			catMarker = new("Frame", {
				Position = UDim2.new(0, 9, 0.5, -5),
				Size = UDim2.fromOffset(11, 11),
				BorderSizePixel = 0,
			}, btn)
		end
		local catLabel = new("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, catAsset and 32 or 30, 0, 0),
			Size = UDim2.new(1, -(catAsset and 40 or 38), 1, 0),
			Text = CategoryName,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, btn)
		bindFont(catLabel, 12, false)

		local catHover = false
		local function catLook(animate)
			local selected = btn:GetAttribute("CategorySelected") == true
			local bg
			if selected then
				bg = Theme.Accent
			elseif catHover then
				bg = Theme.Row:Lerp(Theme.Accent, 0.25)
			else
				bg = Theme.Row
			end
			if animate then
				TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = bg }):Play()
			else
				btn.BackgroundColor3 = bg
			end
			catLabel.TextColor3 = selected and Theme.Cream or Theme.Ink
			local markCol = selected and Theme.Cream or Theme.Accent
			if catAsset then
				catMarker.ImageColor3 = markCol
			else
				catMarker.BackgroundColor3 = markCol
			end
		end
		btn.MouseEnter:Connect(function() catHover = true; catLook(true) end)
		btn.MouseLeave:Connect(function() catHover = false; catLook(true) end)
		btn:GetAttributeChangedSignal("CategorySelected"):Connect(function() catLook(true) end)
		table.insert(lookers, { row = btn, fn = catLook })
		catLook(false)

		---------------------------------------------------------- page
		local CategoryPage = new("ScrollingFrame", {
			Name = CategoryName .. "Page",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ScrollBarThickness = 3,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
		}, ContentContainer)
		bind(CategoryPage, "ScrollBarImageColor3", "Accent")
		new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7) }, CategoryPage)
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 22),
			PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 14),
		}, CategoryPage)

		local heading = new("TextLabel", {
			Name = "Heading",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32),
			Text = CategoryName,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 0,
		}, CategoryPage)
		bindFont(heading, 22, false)
		bind(heading, "TextColor3", "Accent")

		local order = 0
		local function nextOrder()
			order += 1
			return order
		end

		local function SelectTab()
			SettingsState.open = false
			for _, page in ipairs(ContentContainer:GetChildren()) do
				if page:IsA("ScrollingFrame") then
					page.Visible = false
				end
			end
			for _, b in ipairs(Sidebar:GetChildren()) do
				if b:IsA("TextButton") then
					b:SetAttribute("CategorySelected", false)
				end
			end
			CategoryPage.Visible = true
			AnimatePageIn(CategoryPage)
			btn:SetAttribute("CategorySelected", true)
		end
		if not Hidden then
			btn.MouseButton1Click:Connect(SelectTab)
			if isFirstTab then
				SelectTab()
				isFirstTab = false
			end
		end

		---------------------------------------------------------- element building blocks
		local function newRow(className, height)
			local row = new(className, {
				Size = UDim2.new(1, 0, 0, height or 28),
				BorderSizePixel = 0,
				LayoutOrder = nextOrder(),
			}, CategoryPage)
			if className == "TextButton" then
				row.AutoButtonColor = false
				row.Text = ""
			end
			bind(row, "BackgroundColor3", "Row")
			bindGlass(row)
			return row
		end

		-- สี่เหลี่ยมหน้าแถว (หรือไอคอนถ้าระบุ)
		local function addMarker(parent, iconName)
			local asset = resolveIcon(iconName)
			if asset then
				local img = new("ImageLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 8, 0.5, -8),
					Size = UDim2.fromOffset(16, 16),
					Image = asset,
				}, parent)
				return img, true
			end
			local sq = new("Frame", {
				Position = UDim2.new(0, 9, 0.5, -5),
				Size = UDim2.fromOffset(11, 11),
				BorderSizePixel = 0,
			}, parent)
			local st = new("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, sq)
			bind(st, "Color", "Accent")
			return sq, false
		end

		local function addLabel(parent, text, x, scale, reserve)
			local l = new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, x, 0, 0),
				Size = UDim2.new(scale or 1, -(x + 10 + (reserve or 0)), 1, 0),
				Text = text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, parent)
			bindFont(l, 13, false)
			return l
		end

		-- hover: แถวเข้ม + ตัวอักษรครีม + เพชรชี้ด้านซ้าย
		local function hoverable(o)
			local state = { hover = false }
			local dia
			if not o.noDiamond then
				dia = new("Frame", {
					Position = UDim2.new(0, -13, 0.5, -3),
					Size = UDim2.fromOffset(7, 7),
					Rotation = 45,
					BorderSizePixel = 0,
					Visible = false,
				}, o.row)
				bind(dia, "BackgroundColor3", "Accent")
			end
			local function look(animate)
				local h = state.hover
				local bg = h and Theme.Accent or Theme.Row
				if animate then
					TweenService:Create(o.row, TweenInfo.new(0.1), { BackgroundColor3 = bg }):Play()
				else
					o.row.BackgroundColor3 = bg
				end
				for _, l in ipairs(o.labels) do
					l.TextColor3 = h and Theme.Cream or (o.color or Theme.Ink)
				end
				local active = o.active and o.active() or false
				if o.hasIcon then
					o.marker.ImageColor3 = h and Theme.Cream or Theme.Accent
				else
					o.marker.BackgroundColor3 = (h or active) and Theme.Cream or Theme.Accent
				end
				if dia then
					dia.Visible = h
				end
			end
			local target = o.target or o.row
			target.MouseEnter:Connect(function() state.hover = true; look(true) end)
			target.MouseLeave:Connect(function() state.hover = false; look(true) end)
			table.insert(lookers, { row = o.row, fn = look })
			look(false)
			return state, look
		end

		local function inputBox(row, placeholder, text, width)
			local bg = new("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(width or 150, 20),
				BorderSizePixel = 0,
			}, row)
			bind(bg, "BackgroundColor3", inputColor)
			local st = new("UIStroke", { Thickness = 1 }, bg)
			bind(st, "Color", "Line")
			local tb = new("TextBox", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(6, 0),
				Size = UDim2.new(1, -12, 1, 0),
				PlaceholderText = placeholder or "",
				Text = text or "",
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, bg)
			bindFont(tb, 12, false)
			bind(tb, "TextColor3", "Ink")
			bind(tb, "PlaceholderColor3", dimInk)
			return tb, bg
		end

		---------------------------------------------------------- CreateLabel
		function CategoryElements:CreateLabel(Text, IconName, TextColor)
			if typeof(IconName) == "Color3" then
				TextColor = IconName
				IconName = nil
			end
			local holder = new("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 26),
				LayoutOrder = nextOrder(),
			}, CategoryPage)
			local x = 0
			local asset = resolveIcon(IconName)
			if asset then
				local img = new("ImageLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.5, -8),
					Size = UDim2.fromOffset(16, 16),
					Image = asset,
				}, holder)
				bind(img, "ImageColor3", "Accent")
				x = 22
			end
			local l = new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, x, 0, 0),
				Size = UDim2.new(1, -x, 1, -2),
				Text = Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, holder)
			bindFont(l, 14, true)
			if TextColor then
				l.TextColor3 = TextColor
			else
				bind(l, "TextColor3", "Accent")
			end
			hline(holder, UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1))
			return l
		end

		---------------------------------------------------------- CreateButton
		function CategoryElements:CreateButton(ButtonText, IconName, TextColor, Callback)
			if type(IconName) == "function" then
				Callback = IconName; IconName = nil; TextColor = nil
			end
			if typeof(IconName) == "Color3" then
				Callback = TextColor; TextColor = IconName; IconName = nil
			end
			if type(TextColor) == "function" then
				Callback = TextColor; TextColor = nil
			end

			local row = newRow("TextButton")
			local marker, hasIcon = addMarker(row, IconName)
			local lbl = addLabel(row, ButtonText, hasIcon and 32 or 30)
			local state, look = hoverable({
				row = row, marker = marker, hasIcon = hasIcon, labels = { lbl }, color = TextColor,
			})

			row.MouseButton1Click:Connect(function()
				row.BackgroundColor3 = Theme.Line
				task.delay(0.1, function()
					if UserInputService.TouchEnabled then
						state.hover = false
					end
					look(true)
				end)
				if Callback then
					task.spawn(Callback)
				end
			end)
		end

		---------------------------------------------------------- CreateTextbox
		function CategoryElements:CreateTextbox(TextboxText, IconName, Placeholder, Flag, Callback)
			if type(Flag) == "function" then
				Callback = Flag; Flag = nil
			end
			local restored = nil
			if Flag and SavedFlags[Flag] ~= nil then
				restored = SavedFlags[Flag]
			end

			local row = newRow("Frame")
			local marker, hasIcon = addMarker(row, IconName)
			local lbl = addLabel(row, TextboxText, hasIcon and 32 or 30, 1, 158)
			bind(lbl, "TextColor3", "Ink")
			marker[hasIcon and "ImageColor3" or "BackgroundColor3"] = Theme.Accent
			if hasIcon then bind(marker, "ImageColor3", "Accent") else bind(marker, "BackgroundColor3", "Accent") end

			local tb = inputBox(row, Placeholder, restored or "")
			if Flag then
				Flags[Flag] = { Type = "Textbox", Value = tb.Text }
			end
			tb.FocusLost:Connect(function()
				if Flag then
					Flags[Flag].Value = tb.Text
					save()
				end
				if Callback then
					Callback(tb.Text)
				end
			end)
		end

		---------------------------------------------------------- CreateNumberTextbox
		function CategoryElements:CreateNumberTextbox(LabelText, IconName, DefaultNumber, Flag, Callback)
			if type(Flag) == "function" then
				Callback = Flag; Flag = nil
			end
			if Flag and SavedFlags[Flag] ~= nil then
				DefaultNumber = SavedFlags[Flag]
			end

			local row = newRow("Frame")
			local marker, hasIcon = addMarker(row, IconName)
			local lbl = addLabel(row, LabelText, hasIcon and 32 or 30, 1, 158)
			bind(lbl, "TextColor3", "Ink")
			if hasIcon then bind(marker, "ImageColor3", "Accent") else bind(marker, "BackgroundColor3", "Accent") end

			local tb = inputBox(row, tostring(DefaultNumber or ""), DefaultNumber and tostring(DefaultNumber) or "")
			if Flag then
				Flags[Flag] = { Type = "NumberTextbox", Value = tonumber(tb.Text) }
			end
			tb.FocusLost:Connect(function()
				local n = tonumber(tb.Text)
				if Flag then
					Flags[Flag].Value = n
					save()
				end
				if Callback then
					Callback(n)
				end
			end)
		end

		---------------------------------------------------------- CreateSearchBar
		function CategoryElements:CreateSearchBar(Placeholder, IconName, Callback)
			if type(IconName) == "function" then
				Callback = IconName; IconName = nil
			end
			IconName = IconName or "lucide-search"

			local row = newRow("Frame")
			local img = new("ImageLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 8, 0.5, -8),
				Size = UDim2.fromOffset(16, 16),
				Image = resolveIcon(IconName) or "",
			}, row)
			bind(img, "ImageColor3", "Accent")
			local tb = new("TextBox", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(32, 0),
				Size = UDim2.new(1, -42, 1, 0),
				PlaceholderText = Placeholder or "Search...",
				Text = "",
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, row)
			bindFont(tb, 13, false)
			bind(tb, "TextColor3", "Ink")
			bind(tb, "PlaceholderColor3", dimInk)
			tb:GetPropertyChangedSignal("Text"):Connect(function()
				if Callback then
					Callback(tb.Text)
				end
			end)
		end

		---------------------------------------------------------- CreateToggle
		function CategoryElements:CreateToggle(ToggleText, IconName, DefaultState, Flag, Callback)
			if type(IconName) == "boolean" then
				Callback = Flag; Flag = DefaultState; DefaultState = IconName; IconName = nil
			end
			if type(Flag) == "function" then
				Callback = Flag; Flag = nil
			end
			if Flag and SavedFlags[Flag] ~= nil then
				DefaultState = SavedFlags[Flag]
			end
			local current = DefaultState == true
			if Flag then
				Flags[Flag] = { Type = "Toggle", Value = current }
			end

			local row = newRow("TextButton")
			local marker, hasIcon = addMarker(row, IconName)
			local lbl = addLabel(row, ToggleText, hasIcon and 32 or 30, 1, 44)
			local val = new("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(40, 20),
				TextXAlignment = Enum.TextXAlignment.Right,
			}, row)
			bindFont(val, 11, true)
			local _, look = hoverable({
				row = row, marker = marker, hasIcon = hasIcon, labels = { lbl, val },
				active = function() return current end,
			})

			local function apply(fire)
				val.Text = current and "ON" or "OFF"
				look(true)
				if fire and Callback then
					task.spawn(Callback, current)
				end
			end
			apply(true)

			row.MouseButton1Click:Connect(function()
				current = not current
				if Flag then
					Flags[Flag].Value = current
					save()
				end
				apply(true)
			end)

			return {
				Set = function(v)
					current = v == true
					if Flag then Flags[Flag].Value = current end
					apply(true)
				end,
				Get = function() return current end,
			}
		end

		---------------------------------------------------------- CreateSlider
		function CategoryElements:CreateSlider(SliderText, IconName, Min, Max, Default, Flag, Callback)
			if type(IconName) == "number" then
				Callback = Flag; Flag = Default; Default = Max; Max = Min; Min = IconName; IconName = nil
			end
			if type(Flag) == "function" then
				Callback = Flag; Flag = nil
			end
			if Flag and SavedFlags[Flag] ~= nil then
				Default = SavedFlags[Flag]
			end
			local value = math.clamp(Default or Min, Min, Max)
			if Flag then
				Flags[Flag] = { Type = "Slider", Value = value }
			end

			local row = newRow("Frame")
			local badge = new("TextLabel", {
				Position = UDim2.new(0, 8, 0.5, -7),
				Size = UDim2.fromOffset(24, 14),
				BorderSizePixel = 0,
			}, row)
			bind(badge, "BackgroundColor3", "Accent")
			bind(badge, "TextColor3", "Cream")
			bindFont(badge, 9, true)

			local lx = 38
			local asset = resolveIcon(IconName)
			if asset then
				local img = new("ImageLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 38, 0.5, -8),
					Size = UDim2.fromOffset(16, 16),
					Image = asset,
				}, row)
				bind(img, "ImageColor3", "Accent")
				lx = 58
			end
			local lbl = addLabel(row, SliderText, lx, 0.6)
			bind(lbl, "TextColor3", "Ink")

			local track = new("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.new(0.4, 0, 0, 22),
				BackgroundTransparency = 1,
				Active = true,
			}, row)
			new("UISizeConstraint", { MinSize = Vector2.new(80, 22), MaxSize = Vector2.new(220, 22) }, track)
			hline(track, UDim2.new(0, 0, 0.5, 0), UDim2.new(1, 0, 0, 1))

			local N = 28
			local ticks = {}
			for i = 1, N do
				ticks[i] = new("Frame", {
					Position = UDim2.new((i - 1) / N, 0, 0.5, -4),
					Size = UDim2.fromOffset(2, 8),
					BorderSizePixel = 0,
				}, track)
			end
			local thumb = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(3, 14),
				BorderSizePixel = 0,
				ZIndex = 2,
			}, track)
			bind(thumb, "BackgroundColor3", "Accent")

			local function render()
				local f = (Max == Min) and 0 or (value - Min) / (Max - Min)
				badge.Text = tostring(value)
				thumb.Position = UDim2.new(f, 0, 0.5, 0)
				for i = 1, N do
					ticks[i].BackgroundColor3 = Theme.Ink
					ticks[i].BackgroundTransparency = ((i - 1) / N) < f and 0 or 1
				end
			end
			render()
			table.insert(lookers, { row = row, fn = render })

			makeDrag(track, function(input)
				local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				value = math.clamp(math.floor(Min + (Max - Min) * rel + 0.5), Min, Max)
				render()
				if Flag then
					Flags[Flag].Value = value
				end
				if Callback then
					Callback(value)
				end
			end, function()
				if Flag then
					save()
				end
			end)

			return {
				Set = function(v)
					value = math.clamp(v, Min, Max)
					if Flag then Flags[Flag].Value = value end
					render()
				end,
				Get = function() return value end,
			}
		end

		---------------------------------------------------------- CreateColorPicker
		function CategoryElements:CreateColorPicker(PickerText, IconName, DefaultColor, Flag, Callback)
			if typeof(IconName) == "Color3" then
				Callback = Flag; Flag = DefaultColor; DefaultColor = IconName; IconName = nil
			end
			if type(Flag) == "function" then
				Callback = Flag; Flag = nil
			end
			if Flag and SavedFlags[Flag] ~= nil then
				local sv = SavedFlags[Flag]
				if type(sv) == "table" and sv[3] then
					DefaultColor = Color3.fromRGB(sv[1], sv[2], sv[3])
				end
			end
			DefaultColor = DefaultColor or WHITE

			local Hue, Sat, Val = DefaultColor:ToHSV()
			local current = DefaultColor
			if Flag then
				Flags[Flag] = { Type = "ColorPicker", Value = arr(DefaultColor) }
			end

			local expanded = false
			local container = newRow("Frame", 28)
			container.ClipsDescendants = true
			local header = new("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 28),
			}, container)
			local marker, hasIcon = addMarker(header, IconName)
			local lbl = addLabel(header, PickerText, hasIcon and 32 or 30, 1, 100)
			local hexLbl = new("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -32, 0.5, 0),
				Size = UDim2.fromOffset(62, 20),
				TextXAlignment = Enum.TextXAlignment.Right,
			}, header)
			bindFont(hexLbl, 11, true)
			local swatch = new("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(16, 16),
				BorderSizePixel = 0,
				BackgroundColor3 = DefaultColor,
			}, header)
			local sst = new("UIStroke", { Thickness = 1 }, swatch)
			bind(sst, "Color", "Accent")

			hoverable({
				row = container, target = header, marker = marker, hasIcon = hasIcon,
				labels = { lbl, hexLbl }, noDiamond = true,
			})

			local svBox = new("Frame", {
				Position = UDim2.fromOffset(8, 34), Size = UDim2.new(1, -16, 0, 92),
				BorderSizePixel = 0, BackgroundColor3 = Color3.fromHSV(Hue, 1, 1),
				ClipsDescendants = true, Visible = false,
			}, container)
			local satO = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = WHITE }, svBox)
			new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }) }, satO)
			local valO = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0) }, svBox)
			new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }, valO)
			local svCursor = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(9, 9),
				BorderSizePixel = 0, BackgroundColor3 = WHITE, ZIndex = 5,
			}, svBox)
			new("UIStroke", { Thickness = 2, Color = Color3.new(0, 0, 0) }, svCursor)
			local svBtn = new("TextButton", {
				BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 6,
			}, svBox)

			local hueBar = new("Frame", {
				Position = UDim2.fromOffset(8, 132), Size = UDim2.new(1, -16, 0, 14),
				BorderSizePixel = 0, Visible = false,
			}, container)
			new("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(0.166, Color3.fromHSV(1 / 6, 1, 1)),
					ColorSequenceKeypoint.new(0.333, Color3.fromHSV(2 / 6, 1, 1)),
					ColorSequenceKeypoint.new(0.5, Color3.fromHSV(3 / 6, 1, 1)),
					ColorSequenceKeypoint.new(0.666, Color3.fromHSV(4 / 6, 1, 1)),
					ColorSequenceKeypoint.new(0.833, Color3.fromHSV(5 / 6, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
				}),
			}, hueBar)
			local hueCursor = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(Hue, 0, 0.5, 0),
				Size = UDim2.new(0, 5, 1, 4), BorderSizePixel = 0, BackgroundColor3 = WHITE, ZIndex = 5,
			}, hueBar)
			new("UIStroke", { Thickness = 2, Color = Color3.new(0, 0, 0) }, hueCursor)
			local hueBtn = new("TextButton", {
				BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 6,
			}, hueBar)

			local function refreshHex()
				hexLbl.Text = toHex(current)
			end
			refreshHex()
			local function commit()
				current = Color3.fromHSV(Hue, Sat, Val)
				swatch.BackgroundColor3 = current
				refreshHex()
				if Flag then
					Flags[Flag].Value = arr(current)
				end
				if Callback then
					Callback(current)
				end
			end
			svCursor.Position = UDim2.new(Sat, 0, 1 - Val, 0)

			makeDrag(svBtn, function(input)
				Sat = math.clamp((input.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
				Val = 1 - math.clamp((input.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
				svCursor.Position = UDim2.new(Sat, 0, 1 - Val, 0)
				commit()
			end, function()
				if Flag then save() end
			end)
			makeDrag(hueBtn, function(input)
				Hue = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
				hueCursor.Position = UDim2.new(Hue, 0, 0.5, 0)
				svBox.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
				commit()
			end, function()
				if Flag then save() end
			end)

			header.MouseButton1Click:Connect(function()
				expanded = not expanded
				svBox.Visible = expanded
				hueBar.Visible = expanded
				TweenService:Create(container, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
					Size = UDim2.new(1, 0, 0, expanded and 154 or 28),
				}):Play()
			end)
		end

		---------------------------------------------------------- Dropdown / MultiDropdown (ใช้ตัวสร้างเดียวกัน)
		local function buildDropdown(multi, text, icon, options, default, flag, callback)
			local selSet, selOrder, currentVal = {}, {}, nil
			if multi then
				for _, v in ipairs(default or {}) do
					if not selSet[v] then
						selSet[v] = true
						table.insert(selOrder, v)
					end
				end
			else
				currentVal = default
			end
			if flag then
				Flags[flag] = { Type = multi and "MultiDropdown" or "Dropdown", Value = multi and selOrder or currentVal }
			end

			local isOpen = false
			local container = newRow("Frame", 28)
			container.ClipsDescendants = true
			local header = new("TextButton", {
				BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 28),
			}, container)
			local marker, hasIcon = addMarker(header, icon)
			local lbl = addLabel(header, "", hasIcon and 32 or 30, 1, 22)
			local arrow = new("TextLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(16, 20),
				Text = "▼",
			}, header)
			bindFont(arrow, 10, true)
			hoverable({
				row = container, target = header, marker = marker, hasIcon = hasIcon,
				labels = { lbl, arrow }, noDiamond = true,
			})

			local function headerText()
				if multi then
					return text .. " : " .. (#selOrder == 0 and "None" or joinList(selOrder))
				end
				return text .. " : " .. (currentVal ~= nil and tostring(currentVal) or "Select Option")
			end
			lbl.Text = headerText()

			local listTop = multi and 56 or 30
			local listFrame = new("Frame", {
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 28),
				Size = UDim2.new(1, 0, 1, -28),
			}, container)
			bind(listFrame, "BackgroundColor3", listColor)

			local search = new("TextBox", {
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(4, 3),
				Size = UDim2.new(1, -8, 0, 24),
				PlaceholderText = "Search in Dropdown...",
				Text = "",
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, listFrame)
			new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, search)
			bind(search, "BackgroundColor3", inputColor)
			bind(search, "TextColor3", "Ink")
			bind(search, "PlaceholderColor3", dimInk)
			bindFont(search, 12, false)

			local scroll = new("ScrollingFrame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, listTop),
				Size = UDim2.new(1, 0, 1, -listTop),
				ScrollBarThickness = 3,
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			}, listFrame)
			bind(scroll, "ScrollBarImageColor3", "Accent")
			new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, scroll)

			local entries = {}
			local function visibleCount()
				local n = 0
				for _, e in ipairs(entries) do
					if e.btn.Visible then n += 1 end
				end
				return n
			end
			local function updateSize()
				local target = isOpen and (28 + listTop + math.min(visibleCount(), 6) * 24 + 4) or 28
				TweenService:Create(container, TweenInfo.new(0.18), { Size = UDim2.new(1, 0, 0, target) }):Play()
				arrow.Text = isOpen and "▲" or "▼"
			end
			local function paintMarks()
				for _, e in ipairs(entries) do
					local selected
					if multi then selected = selSet[e.value] == true else selected = currentVal == e.value end
					e.mark.Text = selected and "◆" or ""
				end
				lbl.Text = headerText()
			end
			local function fire()
				if flag then
					Flags[flag].Value = multi and selOrder or currentVal
					save()
				end
				if callback then
					callback(multi and selOrder or currentVal)
				end
			end
			local function setChecked(e, state, silent)
				if state and not selSet[e.value] then
					selSet[e.value] = true
					table.insert(selOrder, e.value)
				elseif (not state) and selSet[e.value] then
					selSet[e.value] = nil
					for i, v in ipairs(selOrder) do
						if v == e.value then table.remove(selOrder, i) break end
					end
				end
				if not silent then
					paintMarks()
					fire()
				end
			end

			local function addOption(opt)
				local b = new("TextButton", {
					BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false,
					Text = "", Size = UDim2.new(1, 0, 0, 24),
				}, scroll)
				local mark = new("TextLabel", {
					BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.fromOffset(16, 24),
				}, b)
				bindFont(mark, 10, true)
				bind(mark, "TextColor3", "Accent")
				local ol = new("TextLabel", {
					BackgroundTransparency = 1, Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -36, 1, 0),
					Text = tostring(opt), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
				}, b)
				bindFont(ol, 13, false)
				bind(ol, "TextColor3", "Ink")
				local entry = { btn = b, value = opt, mark = mark, text = string.lower(tostring(opt)) }
				table.insert(entries, entry)

				b.MouseEnter:Connect(function()
					b.BackgroundTransparency = 0
					b.BackgroundColor3 = Theme.Accent
					ol.TextColor3 = Theme.Cream
					mark.TextColor3 = Theme.Cream
				end)
				b.MouseLeave:Connect(function()
					b.BackgroundTransparency = 1
					ol.TextColor3 = Theme.Ink
					mark.TextColor3 = Theme.Accent
				end)
				b.MouseButton1Click:Connect(function()
					if multi then
						setChecked(entry, not selSet[opt])
					else
						currentVal = opt
						isOpen = false
						paintMarks()
						updateSize()
						fire()
					end
				end)
			end

			local function rebuild(newOptions)
				for _, e in ipairs(entries) do
					e.btn:Destroy()
				end
				table.clear(entries)
				for _, opt in ipairs(newOptions or {}) do
					addOption(opt)
				end
				paintMarks()
				updateSize()
			end

			if multi then
				local quick = new("Frame", {
					BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 0, 24),
				}, listFrame)
				local function quickBtn(txt, xScale, fn)
					local qb = new("TextButton", {
						BorderSizePixel = 0, AutoButtonColor = false, Text = txt,
						Position = UDim2.new(xScale, xScale == 0 and 4 or 2, 0, 1),
						Size = UDim2.new(0.5, -6, 0, 22),
					}, quick)
					bind(qb, "BackgroundColor3", "Row")
					bind(qb, "TextColor3", "Ink")
					bindFont(qb, 12, true)
					qb.MouseButton1Click:Connect(fn)
				end
				quickBtn("Select All", 0, function()
					for _, e in ipairs(entries) do
						if e.btn.Visible then setChecked(e, true, true) end
					end
					paintMarks()
					fire()
				end)
				quickBtn("Clear All", 0.5, function()
					for _, e in ipairs(entries) do
						if e.btn.Visible then setChecked(e, false, true) end
					end
					paintMarks()
					fire()
				end)
			end

			header.MouseButton1Click:Connect(function()
				isOpen = not isOpen
				search.Text = ""
				for _, e in ipairs(entries) do
					e.btn.Visible = true
				end
				updateSize()
			end)
			search:GetPropertyChangedSignal("Text"):Connect(function()
				local q = string.lower(search.Text or "")
				for _, e in ipairs(entries) do
					e.btn.Visible = q == "" or string.find(e.text, q, 1, true) ~= nil
				end
				updateSize()
			end)

			rebuild(options)

			local api = {}
			function api:Refresh(newOptions)
				rebuild(newOptions or options)
			end
			function api:SetOptions(newOptions)
				options = newOptions or {}
				if multi then
					selSet = {}
					table.clear(selOrder)
				end
				rebuild(options)
				if multi then fire() end
			end
			if multi then
				function api:GetSelected()
					return selOrder
				end
				function api:SetSelected(list)
					for _, e in ipairs(entries) do
						local want = false
						for _, v in ipairs(list or {}) do
							if v == e.value then want = true break end
						end
						setChecked(e, want, true)
					end
					paintMarks()
					fire()
				end
			else
				function api:SetValue(v)
					currentVal = v
					paintMarks()
					fire()
				end
			end
			return api
		end

		function CategoryElements:CreateDropdown(DropdownText, IconName, Options, Default, Flag, Callback)
			if type(IconName) == "table" then
				Callback = Flag; Flag = Default; Default = Options; Options = IconName; IconName = nil
			end
			if type(Flag) == "function" then
				Callback = Flag; Flag = nil
			end
			if type(Default) == "function" then
				Callback = Default; Default = nil; Flag = nil
			end
			if Flag and SavedFlags[Flag] ~= nil then
				Default = SavedFlags[Flag]
			end
			return buildDropdown(false, DropdownText, IconName, Options, Default, Flag, Callback)
		end

		function CategoryElements:CreateMultiDropdown(DropdownText, IconName, Options, DefaultSelected, Flag, Callback)
			if type(IconName) == "table" then
				Callback = Flag; Flag = DefaultSelected; DefaultSelected = Options; Options = IconName; IconName = nil
			end
			if type(Flag) == "function" then
				Callback = Flag; Flag = nil
			end
			if type(DefaultSelected) == "function" then
				Callback = DefaultSelected; DefaultSelected = nil; Flag = nil
			end
			if Flag and type(SavedFlags[Flag]) == "table" then
				DefaultSelected = SavedFlags[Flag]
			end
			return buildDropdown(true, DropdownText, IconName, Options, DefaultSelected, Flag, Callback)
		end

		return CategoryElements, CategoryPage, btn
	end

	-------------------------------------------------------------- Window-level API
	WindowElements.Flags = Flags
	WindowElements.ApplyTeamColor = function(instance, property)
		bind(instance, property or "BackgroundColor3", "Team")
	end
	WindowElements.UpdateTeamColor = function(color)
		Theme.Team = color
		refreshTheme()
	end
	WindowElements.GetTeamColor = function()
		return Theme.Team
	end
	WindowElements.UpdateBackgroundImage = UpdateBackgroundImage
	WindowElements.UpdateBackgroundImageTransparency = UpdateBackgroundImageTransparency
	WindowElements.UpdateBackgroundImageEnabled = UpdateBackgroundImageEnabled
	WindowElements.GetTheme = function()
		local copy = {}
		for k, v in pairs(Theme) do copy[k] = v end
		return copy
	end

	function WindowElements:Notify(text, duration) Notify(text, duration) end
	function WindowElements:GetFlag(name)
		local f = Flags[name]
		return f and f.Value or nil
	end
	function WindowElements:SetFlag(name, value)
		if Flags[name] then
			Flags[name].Value = value
			save()
		end
	end
	function WindowElements:SaveConfiguration() save() end
	function WindowElements:Show() SetWindowOpen(true) end
	function WindowElements:Hide() SetWindowOpen(false) end
	function WindowElements:ToggleVisibility() SetWindowOpen(not main.Visible) end
	function WindowElements:Destroy()
		for _, c in ipairs(connections) do
			c:Disconnect()
		end
		gui:Destroy()
	end

	-------------------------------------------------------------- Hotkey
	local toggleKey = Config.ToggleKey
	if toggleKey == nil then
		toggleKey = Enum.KeyCode.RightShift
	end
	if toggleKey then
		connect(UserInputService.InputBegan, function(input, processed)
			if not processed and input.KeyCode == toggleKey then
				SetWindowOpen(not main.Visible)
			end
		end)
	end

	-------------------------------------------------------------- Settings tab
	if Config.ShowSettingsTab ~= false then
		task.defer(function()
			local SettingsTab, SettingsPage = WindowElements:CreateCategory("Settings", "lucide-settings", true)
			local PreviousPage = nil

			local function ShowSettingsPanel()
				if SettingsState.open then return end
				PreviousPage = nil
				for _, page in ipairs(ContentContainer:GetChildren()) do
					if page:IsA("ScrollingFrame") and page ~= SettingsPage and page.Visible then
						PreviousPage = page
						page.Visible = false
					end
				end
				SettingsPage.Visible = true
				AnimatePageIn(SettingsPage)
				SettingsState.open = true
			end
			local function HideSettingsPanel()
				if not SettingsState.open then return end
				SettingsPage.Visible = false
				if PreviousPage and PreviousPage.Parent then
					PreviousPage.Visible = true
					AnimatePageIn(PreviousPage)
				end
				SettingsState.open = false
			end
			ToggleSettingsVisibility = function()
				if SettingsState.open then HideSettingsPanel() else ShowSettingsPanel() end
			end
			OpenSettingsFn = ShowSettingsPanel
			CloseSettingsFn = HideSettingsPanel

			local FontSizePercent = math.floor(FontScale * 100 + 0.5)
			local TransPercent = math.floor(GTrans * 100 + 0.5)
			local BuildSettingsUI

			local function colorChanged(token)
				return function(color)
					Theme[token] = color
					refreshTheme()
					persistTheme()
				end
			end

			local function applyPreset(name)
				if not Presets[name] then return end
				loadPreset(Presets[name])
				refreshTheme()
				persistTheme()
				BuildSettingsUI()
			end

			BuildSettingsUI = function()
				local T = Translations[Language] or Translations.en
				for _, child in ipairs(SettingsPage:GetChildren()) do
					if not (child:IsA("UIListLayout") or child:IsA("UIPadding") or child.Name == "Heading") then
						child:Destroy()
					end
				end

				SettingsTab:CreateLabel(T.PresetHeader, "lucide-palette")
				SettingsTab:CreateDropdown(T.PresetLabel, "lucide-palette", PresetOrder, nil, nil, function(selected)
					applyPreset(selected)
				end)

				SettingsTab:CreateLabel(T.ColorHeader, "lucide-palette")
				SettingsTab:CreateColorPicker(T.PaperLabel, "lucide-square", Theme.Paper, colorChanged("Paper"))
				SettingsTab:CreateColorPicker(T.RowLabel, "lucide-layout-grid", Theme.Row, colorChanged("Row"))
				SettingsTab:CreateColorPicker(T.AccentLabel, "lucide-check-circle", Theme.Accent, colorChanged("Accent"))
				SettingsTab:CreateColorPicker(T.InkLabel, "lucide-baseline", Theme.Ink, colorChanged("Ink"))
				SettingsTab:CreateColorPicker(T.CreamLabel, "lucide-baseline", Theme.Cream, colorChanged("Cream"))
				SettingsTab:CreateColorPicker(T.LineLabel, "lucide-circle", Theme.Line, colorChanged("Line"))
				SettingsTab:CreateColorPicker(T.TeamLabel, "lucide-users", Theme.Team, colorChanged("Team"))
				SettingsTab:CreateSlider(T.TransparencyLabel, "lucide-glasses", 0, 90, TransPercent, function(v)
					TransPercent = v
					setGlass(v / 100)
					persistTheme()
				end)

				SettingsTab:CreateLabel(T.FontHeader, "lucide-baseline")
				SettingsTab:CreateDropdown(T.FontFamilyLabel, "lucide-baseline", FontPresetOrder, FontFamily, nil, function(selected)
					if FontPresets[selected] then
						FontFamily = selected
						refreshFonts()
						persistTheme()
					end
				end)
				SettingsTab:CreateSlider(T.FontSizeLabel, nil, 80, 130, FontSizePercent, function(v)
					FontSizePercent = v
					FontScale = math.clamp(v / 100, 0.8, 1.3)
					refreshFonts()
					persistTheme()
				end)

				SettingsTab:CreateLabel(T.EffectsHeader, "lucide-wand-2")
				SettingsTab:CreateToggle(T.AnimToggle, "lucide-wand-2", StripAnim, function(state)
					StripAnim = state
					persistTheme()
				end)
				SettingsTab:CreateToggle(T.BorderToggle, "lucide-square", BorderEnabled, function(state)
					BorderEnabled = state
					mainStroke.Enabled = state
					persistTheme()
				end)

				SettingsTab:CreateLabel(T.BgImageHeader, "lucide-image")
				SettingsTab:CreateToggle(T.BgImageEnable, "lucide-image", BgImageEnabled, function(state)
					UpdateBackgroundImageEnabled(state)
					persistTheme()
				end)
				SettingsTab:CreateTextbox(T.BgImageLabel, "lucide-image", T.BgImagePlaceholder, "BackgroundImageAssetId", function(text)
					UpdateBackgroundImage(text)
					persistTheme()
				end)
				SettingsTab:CreateSlider(T.BgImageTransparencyLabel, "lucide-glasses", 0, 100, math.floor(BgImageTransparency * 100 + 0.5), function(v)
					UpdateBackgroundImageTransparency(v / 100)
					persistTheme()
				end)

				SettingsTab:CreateLabel(T.LanguageHeader, "lucide-languages")
				SettingsTab:CreateDropdown(T.LanguageLabel, "lucide-languages", { "English", "Thai" }, (Language == "th" and "Thai" or "English"), nil, function(selected)
					Language = (selected == "Thai") and "th" or "en"
					persistTheme()
					BuildSettingsUI()
				end)

				SettingsTab:CreateLabel(T.ManageHeader, "lucide-save")
				SettingsTab:CreateButton(T.SaveButton, "lucide-save", function()
					save()
				end)
				SettingsTab:CreateButton(T.ResetButton, "lucide-rotate-ccw", function()
					loadPreset(Presets.Paper)
					FontFamily, FontScale, FontSizePercent = "Gotham", 1, 100
					TransPercent, StripAnim, BorderEnabled, Language = 0, true, true, "en"
					setGlass(0)
					mainStroke.Enabled = true
					UpdateBackgroundImage("")
					UpdateBackgroundImageTransparency(0.5)
					UpdateBackgroundImageEnabled(false)
					SavedFlags["BackgroundImageAssetId"] = ""
					refreshTheme()
					refreshFonts()
					persistTheme()
					save()
					BuildSettingsUI()
				end)
			end

			BuildSettingsUI()
		end)
	end

	-------------------------------------------------------------- Start
	if Config.StartOpen ~= false then
		task.defer(function()
			SetWindowOpen(true)
			if toggleKey and Config.ToggleHint ~= false then
				Notify("Press [ " .. toggleKey.Name .. " ] to hide GUI", 4)
			end
		end)
	end

	return WindowElements
end

return Library
