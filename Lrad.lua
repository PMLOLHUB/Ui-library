local Library = {}

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ConfigFileName = "UNIT_Config.json"
local EnableSave = true

local Flags = {}
local ThemeSettings = {}

local WHITE = Color3.new(1, 1, 1)

local function getExecutorFunction(name)
  local ok, value = pcall(function()
    return _G and _G[name] or nil
  end)
  if ok and type(value) == "function" then
    return value
  end
  ok, value = pcall(function()
    return getfenv and getfenv(0)[name] or nil
  end)
  if ok and type(value) == "function" then
    return value
  end
  return nil
end

local function fileApiReady()
  return getExecutorFunction("writefile") ~= nil
  and getExecutorFunction("readfile") ~= nil
  and getExecutorFunction("isfile") ~= nil
end

local function SaveConfig(frame)
  if not EnableSave or not frame or not fileApiReady() then
    return
  end
  local camera = workspace.CurrentCamera
  local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
  local pos = frame.AbsolutePosition
  local baseSize = frame.Size
  local absoluteSize = frame.AbsoluteSize

  local data = {
    Width = baseSize.X.Scale == 0 and baseSize.X.Offset or absoluteSize.X,
    Height = baseSize.Y.Scale == 0 and baseSize.Y.Offset or absoluteSize.Y,
  }
if pos.X < 0 or pos.Y < 0 or pos.X + absoluteSize.X > viewport.X or pos.Y + absoluteSize.Y > viewport.Y then
  data.PosScaleX, data.PosScaleY = 0.5, 0.5
  data.PosX = -(baseSize.X.Offset / 2)
  data.PosY = -(baseSize.Y.Offset / 2)
else
  data.PosScaleX, data.PosScaleY = frame.Position.X.Scale, frame.Position.Y.Scale
  data.PosX, data.PosY = frame.Position.X.Offset, frame.Position.Y.Offset
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
  local write = getExecutorFunction("writefile")
  if write then
    pcall(write, ConfigFileName, json)
  end
end
end

local function LoadConfig()
  if not EnableSave or not fileApiReady() then
    return
  end
  local isFile = getExecutorFunction("isfile")
  local read = getExecutorFunction("readfile")
  if not isFile or not read then
    return
  end
  local existsOk, exists = pcall(isFile, ConfigFileName)
  if not existsOk or not exists then
    return
  end
  local ok, content = pcall(read, ConfigFileName)
  if not ok or not content then
    return
  end
  local ok2, data = pcall(function()
    return HttpService:JSONDecode(content)
  end)
  if ok2 and type(data) == "table" and data.Width and data.Height then
    local size = UDim2.fromOffset(data.Width, data.Height)
    local pos
    if data.PosX ~= nil and data.PosY ~= nil then
      pos = UDim2.new(
      tonumber(data.PosScaleX) or 0,
      tonumber(data.PosX) or 0,
      tonumber(data.PosScaleY) or 0,
      tonumber(data.PosY) or 0
      )
    end
    return size, pos, data.Flags, data.Theme
  end
end

local Icons = {}
local NIER_ICON_URL = "https://github.com/PMLOLHUB/assets-library-/raw/refs/heads/main/Icon"

do
  local okSource, source = pcall(function()
    return game:HttpGet(NIER_ICON_URL)
  end)
  if okSource and type(source) == "string" and source ~= "" then
    local compiler = getExecutorFunction("loadstring")
    if not compiler then
      local ok, value = pcall(function() return loadstring end)
      if ok and type(value) == "function" then
        compiler = value
      end
    end
    if compiler then
      local okChunk, chunk = pcall(compiler, source)
      if okChunk and type(chunk) == "function" then
        local okIcons, remoteIcons = pcall(chunk)
        if okIcons and type(remoteIcons) == "table" then
          Icons = remoteIcons
        end
      end
    end
  end
end

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

local Translations = {
  en = {
    PresetHeader = "Theme",
    InterfaceHeader = "Interface",
    PresetLabel = "Preset Theme",
    TransparencyLabel = "Transparency (%)",
    OverallScaleLabel = "UI Scale (%)",
    ToggleButtonScaleLabel = "Toggle Button Size (%)",
    ToggleKeyLabel = "Toggle Key",
    PressKey = "Press a key... (Esc = cancel)",
    MobileStyleLabel = "UI Button",
    SoundVolumeLabel = "Sound Volume (%)",
    PageAnimationLabel = "Page Transition",
    OpenCloseAnimationLabel = "Window",
  },
th = {
  PresetHeader = "ธีม",
  InterfaceHeader = "ส่วนติดต่อผู้ใช้",
  PresetLabel = "ธีมสำเร็จรูป",
  TransparencyLabel = "ความโปร่งแสง (%)",
  OverallScaleLabel = "ขนาด UI (%)",
  ToggleButtonScaleLabel = "ขนาดปุ่มเปิด/ปิด (%)",
  ToggleKeyLabel = "ปุ่มเปิด/ปิด",
  PressKey = "กดปุ่มบนคีย์บอร์ด... (Esc = ยกเลิก)",
  MobileStyleLabel = "รูปแบบปุ่ม UI",
  SoundVolumeLabel = "ระดับเสียง (%)",
  PageAnimationLabel = "แอนิเมชันเปลี่ยนหน้า",
  OpenCloseAnimationLabel = "แอนิเมชันหน้าต่าง",
},
}

local Presets = {
  Unit = { Paper = { 34, 34, 30 }, Row = { 40, 40, 36 }, Input = { 26, 26, 23 }, Accent = { 217, 211, 184 }, Ink = { 217, 211, 184 }, Cream = { 30, 30, 27 }, Line = { 112, 108, 88 }, Team = { 217, 211, 184 } },
  Paper = { Paper = { 204, 198, 174 }, Row = { 172, 166, 149 }, Input = { 226, 220, 198 }, Accent = { 54, 50, 44 }, Ink = { 72, 66, 52 }, Cream = { 252, 248, 220 }, Line = { 158, 152, 129 }, Team = { 120, 110, 80 } },
  Dusk = { Paper = { 196, 184, 170 }, Row = { 172, 158, 144 }, Input = { 228, 216, 204 }, Accent = { 70, 52, 58 }, Ink = { 70, 54, 56 }, Cream = { 244, 232, 222 }, Line = { 150, 134, 124 }, Team = { 150, 90, 100 } },
  Moss = { Paper = { 198, 202, 176 }, Row = { 172, 178, 148 }, Input = { 224, 230, 200 }, Accent = { 46, 60, 44 }, Ink = { 52, 64, 48 }, Cream = { 236, 242, 218 }, Line = { 146, 154, 124 }, Team = { 90, 130, 80 } },
  Gold = { Paper = { 222, 205, 158 }, Row = { 204, 181, 123 }, Input = { 244, 232, 194 }, Accent = { 132, 91, 20 }, Ink = { 86, 62, 24 }, Cream = { 255, 247, 215 }, Line = { 184, 151, 79 }, Team = { 218, 165, 32 } },
  Sakura = { Paper = { 236, 208, 212 }, Row = { 214, 184, 190 }, Input = { 248, 230, 232 }, Accent = { 92, 52, 62 }, Ink = { 96, 56, 66 }, Cream = { 255, 244, 244 }, Line = { 190, 150, 158 }, Team = { 200, 100, 120 } },
  Lavender = { Paper = { 212, 204, 230 }, Row = { 184, 174, 210 }, Input = { 234, 228, 246 }, Accent = { 58, 46, 90 }, Ink = { 66, 54, 98 }, Cream = { 248, 244, 255 }, Line = { 164, 152, 194 }, Team = { 130, 100, 190 } },
  Graphite = { Paper = { 36, 38, 42 }, Row = { 52, 55, 60 }, Input = { 24, 25, 28 }, Accent = { 206, 116, 40 }, Ink = { 236, 238, 242 }, Cream = { 250, 250, 252 }, Line = { 76, 80, 88 }, Team = { 240, 150, 60 } },
  Forest = { Paper = { 16, 32, 22 }, Row = { 26, 52, 36 }, Input = { 10, 21, 14 }, Accent = { 46, 140, 78 }, Ink = { 226, 246, 230 }, Cream = { 242, 255, 244 }, Line = { 50, 92, 64 }, Team = { 120, 220, 130 } },
  Matrix = { Paper = { 6, 14, 8 }, Row = { 12, 30, 16 }, Input = { 3, 8, 4 }, Accent = { 0, 150, 52 }, Ink = { 150, 255, 170 }, Cream = { 214, 255, 224 }, Line = { 20, 84, 36 }, Team = { 0, 255, 90 } },
  Twilight = { Paper = { 30, 16, 36 }, Row = { 50, 28, 60 }, Input = { 19, 10, 23 }, Accent = { 190, 84, 146 }, Ink = { 250, 230, 246 }, Cream = { 255, 242, 252 }, Line = { 104, 56, 112 }, Team = { 255, 150, 200 } },
  Cyberpunk = { Paper = { 16, 12, 28 }, Row = { 32, 20, 52 }, Input = { 9, 7, 18 }, Accent = { 210, 30, 140 }, Ink = { 236, 226, 255 }, Cream = { 250, 240, 255 }, Line = { 84, 40, 116 }, Team = { 255, 222, 40 } },
  Sunset = { Paper = { 34, 18, 32 }, Row = { 58, 30, 48 }, Input = { 22, 11, 20 }, Accent = { 220, 92, 78 }, Ink = { 255, 230, 220 }, Cream = { 255, 240, 230 }, Line = { 110, 56, 84 }, Team = { 255, 170, 90 } },
  Ember = { Paper = { 26, 18, 16 }, Row = { 48, 30, 26 }, Input = { 16, 10, 9 }, Accent = { 206, 84, 32 }, Ink = { 252, 232, 220 }, Cream = { 255, 244, 234 }, Line = { 96, 56, 46 }, Team = { 255, 140, 60 } },
  Obsidian = { Paper = { 18, 18, 20 }, Row = { 32, 32, 36 }, Input = { 10, 10, 12 }, Accent = { 150, 150, 162 }, Ink = { 235, 235, 240 }, Cream = { 250, 250, 252 }, Line = { 62, 62, 70 }, Team = { 230, 230, 236 } },
  Noir = { Paper = { 12, 12, 12 }, Row = { 26, 24, 22 }, Input = { 6, 6, 6 }, Accent = { 176, 138, 54 }, Ink = { 240, 232, 214 }, Cream = { 252, 246, 232 }, Line = { 70, 62, 48 }, Team = { 222, 184, 80 } },
  Olive = { Paper = { 24, 26, 14 }, Row = { 42, 46, 24 }, Input = { 15, 17, 8 }, Accent = { 112, 126, 36 }, Ink = { 240, 244, 220 }, Cream = { 252, 255, 236 }, Line = { 80, 88, 44 }, Team = { 186, 204, 70 } },
  Wine = { Paper = { 32, 12, 24 }, Row = { 56, 22, 42 }, Input = { 20, 7, 15 }, Accent = { 150, 32, 80 }, Ink = { 250, 226, 236 }, Cream = { 255, 240, 246 }, Line = { 100, 42, 72 }, Team = { 230, 90, 140 } },
  Crimson = { Paper = { 28, 14, 18 }, Row = { 50, 24, 30 }, Input = { 18, 8, 11 }, Accent = { 190, 36, 60 }, Ink = { 250, 228, 230 }, Cream = { 255, 242, 242 }, Line = { 104, 44, 54 }, Team = { 255, 90, 110 } },
  Amethyst = { Paper = { 26, 18, 40 }, Row = { 44, 32, 68 }, Input = { 16, 11, 26 }, Accent = { 140, 90, 220 }, Ink = { 240, 230, 255 }, Cream = { 248, 242, 255 }, Line = { 88, 66, 128 }, Team = { 190, 140, 255 } },
  Mocha = { Paper = { 30, 22, 18 }, Row = { 52, 38, 30 }, Input = { 19, 13, 10 }, Accent = { 168, 118, 72 }, Ink = { 250, 236, 220 }, Cream = { 255, 246, 232 }, Line = { 96, 72, 54 }, Team = { 222, 170, 110 } },
  Christmas = { Paper = { 24, 52, 38 }, Row = { 36, 72, 54 }, Input = { 15, 36, 27 }, Accent = { 214, 40, 48 }, Ink = { 244, 248, 238 }, Cream = { 255, 250, 238 }, Line = { 74, 118, 92 }, Team = { 255, 214, 92 } },
  Halloween = { Paper = { 28, 20, 32 }, Row = { 48, 30, 48 }, Input = { 18, 13, 23 }, Accent = { 255, 112, 28 }, Ink = { 245, 221, 255 }, Cream = { 255, 239, 214 }, Line = { 112, 62, 102 }, Team = { 173, 255, 66 } },
}
local PresetOrder = { "Unit", "Paper", "Gold", "Dusk", "Sakura", "Lavender", "Moss", "Obsidian", "Graphite", "Noir", "Forest", "Olive", "Matrix", "Twilight", "Amethyst", "Cyberpunk", "Wine", "Crimson", "Sunset", "Ember", "Mocha", "Halloween", "Christmas" }
Library.Presets = Presets

local FontPresets = {}
for _, fontEnum in ipairs(Enum.Font:GetEnumItems()) do
  local name = fontEnum.Name
  local okBold, boldEnum = pcall(function()
    return Enum.Font[name .. "Bold"]
  end)
  FontPresets[name] = { Regular = fontEnum, Bold = (okBold and boldEnum) or fontEnum }
end

local function new(class, props, parent)
  local inst = Instance.new(class)
  for k, v in pairs(props) do
    inst[k] = v
  end
  if parent then
    inst.Parent = parent
  end
  if Library._onNew then
    Library._onNew(inst, class, props)
  end
  return inst
end

local function tw(inst, dur, props)
  if not dur or dur <= 0 then
    for k, v in pairs(props) do
      inst[k] = v
    end
    return
  end
  TweenService:Create(inst, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
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

local function U(s)
  return string.upper(tostring(s))
end

local function offsetUDim2(position, dx, dy)
  return UDim2.new(position.X.Scale, position.X.Offset + dx, position.Y.Scale, position.Y.Offset + dy)
end

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

  local Theme = {}
  local function loadPreset(p)
    for token, v in pairs(p) do
      Theme[token] = c3(v)
    end
  end
  loadPreset(Presets.Unit)
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
  cfgColor("InputColor", "Input")
  cfgColor("ThemeColor", "Accent")
  cfgColor("CategoryColor", "Accent")
  cfgColor("TextColor", "Ink")
  cfgColor("TeamColor", "Team")

  local GTrans = math.clamp(Config.ElementTransparency or 0, 0, 0.9)
  local FontScale = Config.FontScale or 1
  local OverallScalePercent = math.clamp(tonumber(Config.OverallScale) or 100, 70, 130)
  local ToggleButtonScalePercent = math.clamp(tonumber(Config.ToggleButtonScale) or 100, 50, 180)
  local mainUIScale, stripUIScale, toggleUIScale

  local DefaultFont = FontPresets.Arcade and "Arcade" or "Gotham"
  local FontFamily = (Config.FontFamily and FontPresets[Config.FontFamily]) and Config.FontFamily or DefaultFont
  local Language = "en"
  local cfgLang = Config.Language and string.lower(tostring(Config.Language))
  if cfgLang == "th" or cfgLang == "thai" then
    Language = "th"
  end
  local StripAnim = true
  local NumberSections = Config.NumberSections ~= false

  local PageAnimationOrder = { "Pop", "Cascade", "Glitch", "Slide Left" }
  local OpenCloseAnimationOrder = { "Classic", "Shutter", "Pinstripe", "Crosscut" }

  local function containsOption(options, value)
    for _, option in ipairs(options) do
      if option == value then return true end
    end
    return false
  end
  local PageAnimation = "Pop"
  local OpenCloseAnimation = "Classic"
  local CurrentPreset = (type(Config.Theme) == "string" and Presets[Config.Theme]) and Config.Theme or "Unit"
  local BorderEnabled = Config.BorderEnabled ~= false
  local BgImage = Config.BackgroundImage or ""
  local BgImageTransparency = Config.BackgroundImageTransparency or 0.5
  local BgImageEnabled = BgImage ~= ""
  if Config.BackgroundImageEnabled ~= nil then
    BgImageEnabled = Config.BackgroundImageEnabled
  end

  local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
  local MobileStyleOrder = { "Classic", "Circle", "Diamond", "Pill", "Bracket" }
  local function validStyle(name)
    for _, n in ipairs(MobileStyleOrder) do
      if n == name then return true end
    end
    return false
  end
  local MobileStyle = validStyle(Config.MobileButtonStyle) and Config.MobileButtonStyle or "Classic"

  local toggleKey = Config.ToggleKey
  if toggleKey == nil then
    toggleKey = Enum.KeyCode.RightShift
  end
  local listeningKey = false

  local savedSize, savedPos, savedFlags, savedTheme = LoadConfig()
  if type(savedTheme) == "table" then
    if validStyle(savedTheme.MobileStyle) then MobileStyle = savedTheme.MobileStyle end
    if type(savedTheme.PresetName) == "string" and Presets[savedTheme.PresetName] then CurrentPreset = savedTheme.PresetName end
    if containsOption(PageAnimationOrder, savedTheme.PageAnimation) then PageAnimation = savedTheme.PageAnimation end
    if containsOption(OpenCloseAnimationOrder, savedTheme.OpenCloseAnimation) then OpenCloseAnimation = savedTheme.OpenCloseAnimation end
    if toggleKey ~= false and type(savedTheme.ToggleKey) == "string" then
      local okK, keyEnum = pcall(function()
        return Enum.KeyCode[savedTheme.ToggleKey]
      end)
      if okK and keyEnum then toggleKey = keyEnum end
    end
    if type(savedTheme.Colors) == "table" then
      for token, v in pairs(savedTheme.Colors) do
        if Theme[token] and type(v) == "table" and v[3] then
          Theme[token] = c3(v)
        end
      end
    end
    if savedTheme.Transparency ~= nil then GTrans = savedTheme.Transparency end
    if savedTheme.FontScale ~= nil then FontScale = savedTheme.FontScale end
    if savedTheme.OverallScalePercent ~= nil then
      OverallScalePercent = math.clamp(tonumber(savedTheme.OverallScalePercent) or 100, 70, 130)
    end
    if savedTheme.ToggleButtonScalePercent ~= nil then
      ToggleButtonScalePercent = math.clamp(tonumber(savedTheme.ToggleButtonScalePercent) or 100, 50, 180)
    end
    if savedTheme.FontFamily and FontPresets[savedTheme.FontFamily] then FontFamily = savedTheme.FontFamily end
    if savedTheme.Language == "th" or savedTheme.Language == "en" then Language = savedTheme.Language end
    if savedTheme.BorderEnabled ~= nil then BorderEnabled = savedTheme.BorderEnabled end
    if savedTheme.BackgroundImage ~= nil then BgImage = savedTheme.BackgroundImage end
    if savedTheme.BackgroundImageTransparency ~= nil then BgImageTransparency = savedTheme.BackgroundImageTransparency end
    if savedTheme.BackgroundImageEnabled ~= nil then BgImageEnabled = savedTheme.BackgroundImageEnabled end
    if savedTheme.SoundVolume ~= nil then
      Library.SoundVolume = math.clamp(tonumber(savedTheme.SoundVolume) or 1, 0, 1)
    end
  end
  local SavedFlags = savedFlags or {}

  local themed, lookers, glass = {}, {}, {}

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
  end
  local function measure(text, size)
    local preset = FontPresets[FontFamily] or FontPresets.Gotham
    local ok, sz = pcall(function()
      return TextService:GetTextSize(text, math.floor(size * FontScale + 0.5), preset.Bold, Vector2.new(1000, 40))
    end)
    return ok and sz.X or (#text * size * 0.75)
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
    return t.Input
  end
  local function dimInk(t)
    return t.Ink:Lerp(t.Paper, 0.45)
  end

  local gui = new("ScreenGui", {
    Name = "UNIT_UI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = Config.DisplayOrder or 999,
  })

do
  local placed = false
  local getHiddenUI = getExecutorFunction("gethui")
  if getHiddenUI then
    local ok, hiddenUI = pcall(getHiddenUI)
    if ok and hiddenUI then
      placed = pcall(function()
        gui.Parent = hiddenUI
      end) and gui.Parent ~= nil
    end
  end
  if not placed then
    local ok, coreGui = pcall(function()
      return game:GetService("CoreGui")
    end)
    if ok and coreGui then
      placed = pcall(function()
        gui.Parent = coreGui
      end) and gui.Parent ~= nil
    end
  end
  if not placed then
    local ok, playerGui = pcall(function()
      return LocalPlayer and (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10))
    end)
    if ok and playerGui then
      placed = pcall(function()
        gui.Parent = playerGui
      end) and gui.Parent ~= nil
    end
  end
  if not placed then
    error("[UnitLibrary] Unable to parent ScreenGui. This executor may restrict GUI access.")
  end
end

local camera = workspace.CurrentCamera
local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
local startSize = savedSize or UDim2.fromOffset(math.min(700, math.floor(vp.X * 0.94)), math.min(420, math.floor(vp.Y * 0.82)))
local startPos = savedPos or UDim2.new(0.5, -startSize.X.Offset / 2, 0.5, -startSize.Y.Offset / 2)
local ColumnCount = tonumber(Config.Columns) or (startSize.X.Offset < 520 and 1 or 2)
ColumnCount = math.clamp(math.floor(ColumnCount), 1, 3)
local COL_GAP = 16

local main = new("Frame", {
  Name = "MainFrame",
  Size = startSize,
  Position = startPos,
  BorderSizePixel = 0,
  ClipsDescendants = true,
  Visible = false,
}, gui)
mainUIScale = new("UIScale", { Scale = OverallScalePercent / 100 }, main)
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

local function persistTheme()
  local colors = {}
  for token, col in pairs(Theme) do
    colors[token] = arr(col)
  end
  ThemeSettings.Colors = colors
  ThemeSettings.PresetName = CurrentPreset
  ThemeSettings.PageAnimation = PageAnimation
  ThemeSettings.OpenCloseAnimation = OpenCloseAnimation
  ThemeSettings.Transparency = GTrans
  ThemeSettings.FontFamily = FontFamily
  ThemeSettings.FontScale = FontScale
  ThemeSettings.Language = Language
  ThemeSettings.StripAnimation = StripAnim
  ThemeSettings.BorderEnabled = BorderEnabled
  ThemeSettings.BackgroundImage = BgImage
  ThemeSettings.BackgroundImageTransparency = BgImageTransparency
  ThemeSettings.BackgroundImageEnabled = BgImageEnabled
  ThemeSettings.MobileStyle = MobileStyle
  ThemeSettings.ToggleKey = toggleKey and toggleKey.Name or nil
  ThemeSettings.OverallScalePercent = OverallScalePercent
  ThemeSettings.ToggleButtonScalePercent = ToggleButtonScalePercent
  ThemeSettings.SoundVolume = Library.SoundVolume
end
persistTheme()
local function save()
  persistTheme()
  SaveConfig(main)
end

local function makeDraggable(handle, target, onEnd, scaleProvider)
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
      local scaleFactor = scaleProvider and scaleProvider() or 1
      scaleFactor = math.max(tonumber(scaleFactor) or 1, 0.01)
      local dx, dy = d.X / scaleFactor, d.Y / scaleFactor
      target.Position = UDim2.new(startP.X.Scale, startP.X.Offset + dx, startP.Y.Scale, startP.Y.Offset + dy)
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

local function hline(parent, pos, size)
  local f = new("Frame", { Position = pos, Size = size, BorderSizePixel = 0, ZIndex = 2 }, parent)
  bind(f, "BackgroundColor3", "Line")
  return f
end

local TOP_H = 38
local top = new("Frame", { Name = "TopBar", Size = UDim2.new(1, 0, 0, TOP_H), BorderSizePixel = 0, ZIndex = 3 }, main)
bind(top, "BackgroundColor3", "Paper")
bindGlass(top)
hline(main, UDim2.fromOffset(0, TOP_H), UDim2.new(1, 0, 0, 1))

local function vline(parent, pos)
  local f = new("Frame", { Position = pos, Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, ZIndex = 5 }, parent)
  bind(f, "BackgroundColor3", "Line")
  return f
end

local logoCell = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(TOP_H, TOP_H), ZIndex = 4 }, top)
if Config.Logo and Config.Logo ~= "" then
  new("ImageLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(20, 20),
    Image = Config.Logo,
    ZIndex = 5,
  }, logoCell)
else
  local dia = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(13, 13),
    Rotation = 45,
    BorderSizePixel = 0,
    ZIndex = 5,
  }, logoCell)
bind(dia, "BackgroundColor3", "Accent")
end
vline(top, UDim2.fromOffset(TOP_H - 1, 0))

local titleText = U(WindowName or "UNIT UI")
local titleW = math.clamp(measure(titleText, 12) + 36, 90, 260)
local titleLabel = new("TextLabel", {
  BackgroundTransparency = 1,
  Position = UDim2.fromOffset(TOP_H + 18, 0),
  Size = UDim2.fromOffset(titleW - 36, TOP_H),
  Text = titleText,
  TextXAlignment = Enum.TextXAlignment.Left,
  TextTruncate = Enum.TextTruncate.AtEnd,
  ZIndex = 4,
}, top)
bindFont(titleLabel, 12, true)
bind(titleLabel, "TextColor3", "Ink")
vline(top, UDim2.fromOffset(TOP_H + titleW - 1, 0))

local function cellButton(indexFromRight)
  local b = new("TextButton", {
    BackgroundTransparency = 1,
    AutoButtonColor = false,
    BorderSizePixel = 0,
    Text = "",
    Size = UDim2.fromOffset(TOP_H, TOP_H),
    Position = UDim2.new(1, -TOP_H * indexFromRight, 0, 0),
    ZIndex = 4,
  }, top)
b.BackgroundColor3 = Theme.Accent
table.insert(lookers, { row = b, fn = function() b.BackgroundColor3 = Theme.Accent end })
local parts = {}
b.MouseEnter:Connect(function()
  tw(b, 0.12, { BackgroundTransparency = 0 })
  for _, p in ipairs(parts) do tw(p[1], 0.12, { [p[2]] = Theme.Cream }) end
end)
b.MouseLeave:Connect(function()
  tw(b, 0.12, { BackgroundTransparency = 1 })
  for _, p in ipairs(parts) do tw(p[1], 0.12, { [p[2]] = Theme.Ink }) end
end)
vline(b, UDim2.fromOffset(0, 0))
return b, parts
end

local gearBtn, gearParts = cellButton(1)
gearBtn.Name = "SettingsGearBtn"
if Icons["lucide-settings"] then
  local gi = new("ImageLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(16, 16),
    Image = Icons["lucide-settings"],
    ZIndex = 5,
  }, gearBtn)
bind(gi, "ImageColor3", "Ink")
table.insert(gearParts, { gi, "ImageColor3" })
else
  local gl = new("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Text = "CFG",
    ZIndex = 5,
  }, gearBtn)
bindFont(gl, 10, true)
bind(gl, "TextColor3", "Ink")
table.insert(gearParts, { gl, "TextColor3" })
end

local tabsHolder = new("ScrollingFrame", {
  Name = "Tabs",
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Position = UDim2.fromOffset(TOP_H + titleW, 0),
  Size = UDim2.new(1, -(TOP_H + titleW + TOP_H), 1, 0),
  ScrollBarThickness = 0,
  CanvasSize = UDim2.new(),
  AutomaticCanvasSize = Enum.AutomaticSize.X,
  ScrollingDirection = Enum.ScrollingDirection.X,
  ZIndex = 4,
}, top)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }, tabsHolder)

local body = new("Frame", {
  Name = "Body",
  BackgroundTransparency = 1,
  Position = UDim2.fromOffset(0, TOP_H + 1),
  Size = UDim2.new(1, 0, 1, -(TOP_H + 1)),
}, main)
local ContentContainer = new("Frame", {
  Name = "ContentContainer",
  BackgroundTransparency = 1,
  ClipsDescendants = true,
  Size = UDim2.fromScale(1, 1),
}, body)

makeDraggable(top, main, function()
  save()
end, function()
return OverallScalePercent / 100
end)

local resizeBtn = new("TextButton", {
  Name = "ResizeBtn",
  BackgroundTransparency = 1,
  Text = "",
  Position = UDim2.new(1, -18, 1, -18),
  Size = UDim2.fromOffset(18, 18),
  ZIndex = 10,
}, main)
local resizeClip = new("Frame", {
  Name = "ResizeTriangle",
  BackgroundTransparency = 1,
  ClipsDescendants = true,
  Active = false,
  Position = UDim2.fromOffset(4, 4),
  Size = UDim2.fromOffset(14, 14),
  ZIndex = 11,
}, resizeBtn)
-- diamond centred on the corner of the clip box => only the lower-right triangle stays visible
local resizeDot = new("Frame", {
  AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.fromOffset(14, 14),
  Size = UDim2.fromOffset(19.8, 19.8),
  Rotation = 45,
  BorderSizePixel = 0,
  ZIndex = 11,
}, resizeClip)
bind(resizeDot, "BackgroundColor3", "Accent")
do
  local resizing, resizeStart, startAbs = false, nil, nil
  connect(resizeBtn.InputBegan, function(input)
    if isPointer(input) then
      resizing = true
      resizeStart = input.Position
      startAbs = Vector2.new(main.Size.X.Offset, main.Size.Y.Offset)
    end
  end)
  connect(UserInputService.InputChanged, function(input)
    if resizing and isMove(input) then
      local d = input.Position - resizeStart
      local scaleFactor = math.max(OverallScalePercent / 100, 0.01)
      main.Size = UDim2.fromOffset(
      math.clamp(startAbs.X + d.X / scaleFactor, 400, 1000),
      math.clamp(startAbs.Y + d.Y / scaleFactor, 260, 700)
      )
    end
  end)
  connect(UserInputService.InputEnded, function(input)
    if resizing and isPointer(input) then
      resizing = false
      save()
    end
  end)
end

local stripHost = new("Frame", {
  Name = "Strips",
  BackgroundTransparency = 1,
  ClipsDescendants = true,
  Visible = false,
  ZIndex = 60,
}, gui)
stripUIScale = new("UIScale", { Scale = OverallScalePercent / 100 }, stripHost)
local rng = Random.new()
local animating = false
local pendingThemeAction = nil
local runThemeTransition
local SetWindowOpen

local StripVariants = {
  Classic = { n = 9, angle = -13, barW = 0.22 },
  Shutter = { n = 12, angle = 0, barW = 0.2, fixedR = 0.5, step = 0.018, dynamicPad = true },
  Slash = { n = 7, angle = 24, barW = 0.3, dynamicPad = true },
  Pinstripe = { n = 16, angle = 0, barW = 0.095, step = 0.012, dynamicPad = true },
  ["Reverse Slash"] = { n = 8, angle = -27, barW = 0.27, dynamicPad = true },
  Crosscut = { n = 22, angle = 35, alternateAngle = -35, barW = 1.08, step = 0.010, dynamicPad = true },
}

local function flushPendingThemeAction()
  local action = pendingThemeAction
  pendingThemeAction = nil
  if action then
    task.defer(function()
      if runThemeTransition then
        runThemeTransition(action)
      end
    end)
  end
end

local function buildStrips(W, H, collapsed, variant)
  variant = variant or StripVariants.Classic
  local n = variant.n

  for _, child in ipairs(stripHost:GetChildren()) do
    if child ~= stripUIScale then
      child:Destroy()
    end
  end

  local x0, x1
  if variant.dynamicPad then
    local maxAngle = math.max(math.abs(variant.angle or 0), math.abs(variant.alternateAngle or 0))
    local angleRad = math.rad(maxAngle)
    local pad = 0.9 * H * math.abs(math.sin(angleRad))
    + 0.5 * W * (variant.barW or 0) * math.abs(math.cos(angleRad))
    + 0.16 * W
    x0, x1 = -pad, W + pad
  else
    x0, x1 = -0.08 * W, 1.12 * W
  end

  local spacing = (x1 - x0) / math.max(n - 1, 1)
  local barWidth = W * variant.barW
  if not variant.alternateAngle then
    barWidth = math.max(barWidth, spacing * math.cos(math.rad(variant.angle or 0)) * 1.45)
  end
  local stepDelay = variant.step and math.min(variant.step, 0.22 / math.max(n - 1, 1)) or nil

  local list = {}
  for i = 1, n do
    local r
    if variant.fixedR then
      r = variant.fixedR
    else
      r = rng:NextNumber(0.1, 0.9)
    end
    local xc = x0 + (i - 1) * ((x1 - x0) / math.max(n - 1, 1))
    local stripAngle = variant.alternateAngle and (i % 2 == 0 and variant.alternateAngle or variant.angle) or variant.angle

    local band = new("Frame", {
      BackgroundTransparency = 1,
      ClipsDescendants = true,
      ZIndex = 60,
      Position = collapsed and UDim2.fromOffset(0, r * H) or UDim2.fromOffset(0, 0),
      Size = collapsed and UDim2.fromOffset(W, 0) or UDim2.fromOffset(W, H),
    }, stripHost)
  local bar = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    BorderSizePixel = 0,
    ZIndex = 60,
    Position = UDim2.fromOffset(xc, H / 2 - (collapsed and r * H or 0)),
    Size = UDim2.fromOffset(barWidth, H * 1.8),
    Rotation = stripAngle,
    BackgroundColor3 = Theme.Paper,
    BackgroundTransparency = collapsed and 0 or 1,
  }, band)
local stroke = new("UIStroke", {
  Thickness = 1,
  Color = Theme.Line,
  Transparency = collapsed and 0.4 or 1,
}, bar)
local delay = stepDelay and ((i - 1) * stepDelay) or rng:NextNumber(0, 0.22)
list[i] = { band = band, bar = bar, stroke = stroke, r = r, xc = xc, delay = delay }
end
return list
end

local function playStrips(opening, variant)
  local W, H = main.Size.X.Offset, main.Size.Y.Offset
  stripHost.Position = main.Position
  stripHost.Size = main.Size
  local list = buildStrips(W, H, opening, variant)
  stripHost.Visible = true

  local grow = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
  local fade = TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
  local quick = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
  local maxDelay = 0
  for _, s in ipairs(list) do
    maxDelay = math.max(maxDelay, s.delay)
  end
  local fadeSpread = 0.315
  local coverSpread = 0.27
  local fadeStep = fadeSpread / math.max(#list, 1)
  local coverStep = coverSpread / math.max(#list, 1)
  local strokeT = mainStroke.Transparency

  local function finish()
    stripHost.Visible = false
    mainStroke.Transparency = strokeT
    for _, child in ipairs(stripHost:GetChildren()) do
      if child ~= stripUIScale then
        child:Destroy()
      end
    end
    animating = false
    flushPendingThemeAction()
  end

  if opening then
    mainStroke.Transparency = 1
    for _, s in ipairs(list) do
      task.delay(s.delay, function()
        TweenService:Create(s.band, grow, { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(W, H) }):Play()
        TweenService:Create(s.bar, grow, { Position = UDim2.fromOffset(s.xc, H / 2) }):Play()
      end)
    end
    task.delay(maxDelay + 0.33, function()
      main.Visible = true
      TweenService:Create(mainStroke, fade, { Transparency = strokeT }):Play()
      for i, s in ipairs(list) do
        task.delay((i - 1) * fadeStep, function()
          TweenService:Create(s.bar, fade, { BackgroundTransparency = 1 }):Play()
          TweenService:Create(s.stroke, fade, { Transparency = 1 }):Play()
        end)
      end
      task.delay(fadeSpread + 0.36, finish)
    end)
  else
    local backing = new("Frame", {
      Name = "CloseCover",
      Size = UDim2.fromOffset(W, H),
      BackgroundColor3 = Theme.Paper,
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      ZIndex = 59,
    }, stripHost)
  TweenService:Create(mainStroke, TweenInfo.new(coverSpread + 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
  task.delay(coverSpread * 0.8, function()
    if backing.Parent then
      TweenService:Create(backing, quick, { BackgroundTransparency = 0 }):Play()
    end
  end)
  for i, s in ipairs(list) do
    task.delay((#list - i) * coverStep, function()
      TweenService:Create(s.bar, quick, { BackgroundTransparency = 0 }):Play()
      TweenService:Create(s.stroke, quick, { Transparency = 0.4 }):Play()
    end)
  end
  task.delay(coverSpread + 0.3, function()
    main.Visible = false
    mainStroke.Transparency = strokeT
    if backing.Parent then
      TweenService:Create(backing, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
    end
    for _, s in ipairs(list) do
      task.delay(s.delay, function()
        TweenService:Create(s.band, grow, { Position = UDim2.fromOffset(0, s.r * H), Size = UDim2.fromOffset(W, 0) }):Play()
        TweenService:Create(s.bar, grow, { Position = UDim2.fromOffset(s.xc, H / 2 - s.r * H) }):Play()
      end)
    end
    task.delay(maxDelay + 0.34, finish)
  end)
end
end

SetWindowOpen = function(shouldOpen)
  if animating or shouldOpen == main.Visible then
    return
  end
  if Library._reloadAllSfx then
    Library._reloadAllSfx()
  end
  if Library._sfx then
    Library._sfx(shouldOpen and "open" or "close")
  end
  animating = true
  playStrips(shouldOpen, StripVariants[OpenCloseAnimation] or StripVariants.Classic)
end

runThemeTransition = function(applyChange)
  if type(applyChange) ~= "function" then
    return
  end
  if animating then
    pendingThemeAction = applyChange
    return
  end
  if not main.Visible then
    applyChange()
    return
  end

  animating = true
  local W, H = main.Size.X.Offset, main.Size.Y.Offset
  local oldPaper = Theme.Paper
  stripHost.Position = main.Position
  stripHost.Size = main.Size
  local list = buildStrips(W, H, false)
  local cover = new("Frame", {
    Name = "ThemeCover",
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.fromOffset(W, H),
    BackgroundColor3 = oldPaper,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 59,
    Active = false,
  }, stripHost)
stripHost.Visible = true

local coverIn = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local colorTween = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local revealTween = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local stripeTween = TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local maxStripeDelay = (#list - 1) * 0.025

local function finish()
  stripHost.Visible = false
  for _, child in ipairs(stripHost:GetChildren()) do
    if child ~= stripUIScale then
      child:Destroy()
    end
  end
  animating = false
  flushPendingThemeAction()
end

TweenService:Create(cover, coverIn, { BackgroundTransparency = 0 }):Play()
for i, strip in ipairs(list) do
  task.delay((#list - i) * 0.025, function()
    if not strip.bar.Parent then return end
    TweenService:Create(strip.bar, coverIn, { BackgroundTransparency = 0 }):Play()
    TweenService:Create(strip.stroke, coverIn, { Transparency = 0.4 }):Play()
  end)
end

task.delay(maxStripeDelay + 0.29, function()
  local ok, err = pcall(applyChange)
  if not ok then
    warn("[UnitLibrary] Theme transition failed: " .. tostring(err))
  end
  local newPaper, newLine = Theme.Paper, Theme.Line
  for _, strip in ipairs(list) do
    if strip.bar.Parent then
      TweenService:Create(strip.bar, colorTween, { BackgroundColor3 = newPaper }):Play()
      TweenService:Create(strip.stroke, colorTween, { Color = newLine }):Play()
    end
  end
  TweenService:Create(cover, colorTween, { BackgroundColor3 = newPaper }):Play()

  task.delay(0.25, function()
    TweenService:Create(cover, revealTween, { BackgroundTransparency = 1 }):Play()
    for i, strip in ipairs(list) do
      task.delay((i - 1) * 0.025, function()
        if not strip.bar.Parent then return end
        TweenService:Create(strip.bar, stripeTween, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(strip.stroke, stripeTween, { Transparency = 1 }):Play()
      end)
    end
    task.delay(maxStripeDelay + 0.36, finish)
  end)
end)
end

local toggleBtn = new("ImageButton", {
  Name = "ToggleBtn",
  Position = UDim2.fromOffset(20, 20),
  Size = UDim2.fromOffset(44, 44),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  AutoButtonColor = false,
  Image = "",
}, gui)
toggleUIScale = new("UIScale", { Scale = ToggleButtonScalePercent / 100 }, toggleBtn)
local tbVisual = new("Frame", {
  Name = "Visual",
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Size = UDim2.fromScale(1, 1),
}, toggleBtn)

local CENTER = Vector2.new(0.5, 0.5)

local function buildToggleVisual(style)
  tbVisual:ClearAllChildren()
  local hasImg = ToggleConfig.Image and ToggleConfig.Image ~= ""

  local function glyph(parent, size, colorToken, imgScale)
    if hasImg then
      return new("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = CENTER,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(imgScale or 0.6, imgScale or 0.6),
        Image = ToggleConfig.Image,
        ZIndex = 3,
      }, parent)
  end
  if ToggleConfig.Text then
    local t = new("TextLabel", {
      BackgroundTransparency = 1,
      Size = UDim2.fromScale(1, 1),
      Text = ToggleConfig.Text,
      ZIndex = 3,
    }, parent)
  bindFont(t, size, true)
  bind(t, "TextColor3", colorToken)
  return t
end
local d = new("Frame", {
  AnchorPoint = CENTER,
  Position = UDim2.fromScale(0.5, 0.5),
  Size = UDim2.fromOffset(size * 0.7, size * 0.7),
  Rotation = 45,
  BorderSizePixel = 0,
  ZIndex = 3,
}, parent)
bind(d, "BackgroundColor3", colorToken)
return d
end

if style == "Circle" then
  toggleBtn.Size = UDim2.fromOffset(46, 46)
  local disc = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, tbVisual)
  bind(disc, "BackgroundColor3", "Accent")
  new("UICorner", { CornerRadius = UDim.new(1, 0) }, disc)
  local st = new("UIStroke", { Thickness = 2 }, disc)
  bind(st, "Color", "Line")
  glyph(disc, 16, "Cream")
elseif style == "Diamond" then
  toggleBtn.Size = UDim2.fromOffset(56, 56)
  local outer = new("Frame", {
    AnchorPoint = CENTER,
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(38, 38),
    Rotation = 45,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
  }, tbVisual)
local os = new("UIStroke", { Thickness = 1 }, outer)
bind(os, "Color", "Accent")
local inner = new("Frame", {
  AnchorPoint = CENTER,
  Position = UDim2.fromScale(0.5, 0.5),
  Size = UDim2.fromOffset(30, 30),
  Rotation = 45,
  BorderSizePixel = 0,
}, tbVisual)
bind(inner, "BackgroundColor3", "Accent")
local ist = new("UIStroke", { Thickness = 1 }, inner)
bind(ist, "Color", "Line")
glyph(tbVisual, 16, "Cream", 0.45)
elseif style == "Pill" then
  toggleBtn.Size = UDim2.fromOffset(80, 30)
  local pill = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, tbVisual)
  bind(pill, "BackgroundColor3", "Accent")
  local st = new("UIStroke", { Thickness = 1 }, pill)
  bind(st, "Color", "Line")
  if hasImg then
    new("ImageLabel", {
      BackgroundTransparency = 1,
      Position = UDim2.new(0, 9, 0.5, -8),
      Size = UDim2.fromOffset(16, 16),
      Image = ToggleConfig.Image,
      ZIndex = 3,
    }, pill)
else
  local dia = new("Frame", {
    Position = UDim2.new(0, 13, 0.5, -4),
    Size = UDim2.fromOffset(8, 8),
    Rotation = 45,
    BorderSizePixel = 0,
    ZIndex = 3,
  }, pill)
bind(dia, "BackgroundColor3", "Cream")
end
local lab = new("TextLabel", {
  BackgroundTransparency = 1,
  Position = UDim2.fromOffset(30, 0),
  Size = UDim2.new(1, -38, 1, 0),
  Text = U(ToggleConfig.Text or "MENU"),
  TextXAlignment = Enum.TextXAlignment.Left,
  TextTruncate = Enum.TextTruncate.AtEnd,
  ZIndex = 3,
}, pill)
bindFont(lab, 12, true)
bind(lab, "TextColor3", "Cream")
elseif style == "Bracket" then
  toggleBtn.Size = UDim2.fromOffset(46, 46)
  local panel = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BorderSizePixel = 0,
    BackgroundTransparency = 0.15,
  }, tbVisual)
bind(panel, "BackgroundColor3", "Paper")
for _, c in ipairs({ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }) do
  local anchor = Vector2.new(c[1], c[2])
  local pos = UDim2.fromScale(c[1], c[2])
  local h = new("Frame", {
    AnchorPoint = anchor, Position = pos,
    Size = UDim2.fromOffset(12, 2), BorderSizePixel = 0, ZIndex = 2,
  }, panel)
bind(h, "BackgroundColor3", "Accent")
local v = new("Frame", {
  AnchorPoint = anchor, Position = pos,
  Size = UDim2.fromOffset(2, 12), BorderSizePixel = 0, ZIndex = 2,
}, panel)
bind(v, "BackgroundColor3", "Accent")
end
glyph(panel, 16, "Accent")
else
  toggleBtn.Size = UDim2.fromOffset(44, 44)
  local box = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, tbVisual)
  bind(box, "BackgroundColor3", "Accent")
  local st = new("UIStroke", { Thickness = 1 }, box)
  bind(st, "Color", "Line")
  glyph(box, 16, "Cream")
end
end
buildToggleVisual(MobileStyle)

local function SetMobileStyle(name)
  if not validStyle(name) then return end
  MobileStyle = name
  buildToggleVisual(MobileStyle)
  persistTheme()
end

local function SetOverallScale(percent)
  OverallScalePercent = math.clamp(math.floor((tonumber(percent) or 100) + 0.5), 70, 130)
  if mainUIScale then mainUIScale.Scale = OverallScalePercent / 100 end
  if stripUIScale then stripUIScale.Scale = OverallScalePercent / 100 end
  persistTheme()
end

local function SetToggleButtonScale(percent)
  ToggleButtonScalePercent = math.clamp(math.floor((tonumber(percent) or 100) + 0.5), 50, 180)
  if toggleUIScale then toggleUIScale.Scale = ToggleButtonScalePercent / 100 end
  persistTheme()
end

toggleBtn.Visible = isMobile or not toggleKey
local tbMoved = makeDraggable(toggleBtn, nil, nil, function()
  return ToggleButtonScalePercent / 100
end)
toggleBtn.MouseButton1Click:Connect(function()
  if not tbMoved() then
    SetWindowOpen(not main.Visible)
  end
end)

local toastHolder = new("Frame", {
  Name = "Toasts",
  AnchorPoint = Vector2.new(1, 1),
  Position = UDim2.new(1, -20, 1, -20),
  Size = UDim2.fromOffset(460, 0),
  AutomaticSize = Enum.AutomaticSize.Y,
  BackgroundTransparency = 1,
}, gui)
new("UIListLayout", {
  Padding = UDim.new(0, 6),
  VerticalAlignment = Enum.VerticalAlignment.Bottom,
  HorizontalAlignment = Enum.HorizontalAlignment.Right,
  SortOrder = Enum.SortOrder.LayoutOrder,
}, toastHolder)

local function Notify(text, duration)
  text = tostring(text)
  local title, sub = string.match(text, "^(.-)\n(.+)$")
  if not title then title = text end
  title = U(title)
  local wText = math.max(measure(title, 12), sub and measure(sub, 10) or 0)
  local w = math.clamp(wText + 70, 220, 460)
  local h = sub and 52 or 40

  local slot = new("Frame", {
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Size = UDim2.fromOffset(w, h),
  }, toastHolder)
local card = new("Frame", {
  Size = UDim2.fromScale(1, 1),
  Position = UDim2.fromScale(1, 0),
  BorderSizePixel = 0,
}, slot)
bind(card, "BackgroundColor3", "Accent")
local cardStroke = new("UIStroke", { Thickness = 1 }, card)
bind(cardStroke, "Color", "Line")

local iconBox = new("Frame", {
  BackgroundTransparency = 1,
  Position = UDim2.new(0, 10, 0.5, -12),
  Size = UDim2.fromOffset(24, 24),
  BorderSizePixel = 0,
}, card)
local ist = new("UIStroke", { Thickness = 1 }, iconBox)
bind(ist, "Color", "Cream")
local ex = new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "!" }, iconBox)
bindFont(ex, 13, true)
bind(ex, "TextColor3", "Cream")

local tl = new("TextLabel", {
  BackgroundTransparency = 1,
  Position = UDim2.new(0, 46, 0, sub and 8 or 0),
  Size = UDim2.new(1, -54, 0, sub and 16 or h),
  Text = title,
  TextXAlignment = Enum.TextXAlignment.Left,
  TextTruncate = Enum.TextTruncate.AtEnd,
}, card)
bindFont(tl, 12, true)
bind(tl, "TextColor3", "Cream")
if sub then
  local sl = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 46, 0, 27),
    Size = UDim2.new(1, -54, 0, 14),
    Text = sub,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    TextTransparency = 0.2,
  }, card)
bindFont(sl, 10, false)
bind(sl, "TextColor3", "Cream")
end

TweenService:Create(card, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
  Position = UDim2.fromScale(0, 0),
}):Play()
task.delay(duration or 3, function()
  if slot.Parent then
    local out = TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
      Position = UDim2.fromScale(1, 0),
    })
  out:Play()
  out.Completed:Wait()
  slot:Destroy()
end
end)
end


-- Context menu (COPY LINK / INSPECT / REPORT style)
local ctxMenu, ctxConn
local function HideContextMenu()
  if ctxConn then ctxConn:Disconnect(); ctxConn = nil end
  if ctxMenu then ctxMenu:Destroy(); ctxMenu = nil end
end

local function ShowContextMenu(items, position)
  HideContextMenu()
  if type(items) ~= "table" or #items == 0 then return end
  local ROW_H = 28
  local maxW = 0
  for _, it in ipairs(items) do
    maxW = math.max(maxW, measure(U(it.Text or ""), 11))
  end
  local w = math.clamp(maxW + 32, 150, 320)
  local h = #items * ROW_H
  local vp = gui.AbsoluteSize
  position = position or UserInputService:GetMouseLocation()
  local x = math.clamp(position.X, 4, math.max(4, vp.X - w - 4))
  local y = math.clamp(position.Y, 4, math.max(4, vp.Y - h - 4))

  local menu = new("Frame", {
    Name = "ContextMenu",
    Position = UDim2.fromOffset(x, y),
    Size = UDim2.fromOffset(w, h),
    BorderSizePixel = 0,
    Active = true,
    ZIndex = 80,
  }, gui)
  bind(menu, "BackgroundColor3", "Paper")
  local ms = new("UIStroke", { Thickness = 1 }, menu)
  bind(ms, "Color", "Ink")
  new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, menu)
  ctxMenu = menu

  for i, it in ipairs(items) do
    local b = new("TextButton", {
      AutoButtonColor = false,
      BorderSizePixel = 0,
      BackgroundTransparency = 0,
      Size = UDim2.new(1, 0, 0, ROW_H),
      LayoutOrder = i,
      Text = "",
      ZIndex = 81,
    }, menu)
    bind(b, "BackgroundColor3", "Paper")
    local l = new("TextLabel", {
      BackgroundTransparency = 1,
      Position = UDim2.fromOffset(12, 0),
      Size = UDim2.new(1, -24, 1, 0),
      Text = U(it.Text or ""),
      TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd,
      ZIndex = 82,
    }, b)
    bindFont(l, 11, true)
    bind(l, "TextColor3", "Ink")
    b.MouseEnter:Connect(function()
      b.BackgroundColor3 = Theme.Accent
      l.TextColor3 = Theme.Cream
    end)
    b.MouseLeave:Connect(function()
      b.BackgroundColor3 = Theme.Paper
      l.TextColor3 = Theme.Ink
    end)
    b.MouseButton1Click:Connect(function()
      HideContextMenu()
      if type(it.Callback) == "function" then
        task.spawn(it.Callback)
      end
    end)
  end

  task.defer(function()
    if ctxMenu ~= menu then return end
    ctxConn = UserInputService.InputBegan:Connect(function(input)
      if not isPointer(input) then return end
      local p = input.Position
      local a, sz = menu.AbsolutePosition, menu.AbsoluteSize
      if p.X < a.X or p.X > a.X + sz.X or p.Y < a.Y or p.Y > a.Y + sz.Y then
        HideContextMenu()
      end
    end)
    table.insert(connections, ctxConn)
  end)
end

local SettingsState = { open = false }
local ToggleSettingsVisibility = function() end
local OpenSettingsFn = function() end
local CloseSettingsFn = function() end
gearBtn.MouseButton1Click:Connect(function()
  ToggleSettingsVisibility()
end)

local pageAnimationStates = {}

local SCRAMBLE_GLYPHS = {
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
  "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "-", "=", "/", "\\", "<", ">", "#", "$", "%", "*"
}

local function splitTextCharacters(value)
  local characters = {}
  local ok = pcall(function()
    if utf8 and utf8.graphemes then
      for first, last in utf8.graphemes(value) do
        table.insert(characters, string.sub(value, first, last))
      end
    else
      for _, codepoint in utf8.codes(value) do
        table.insert(characters, utf8.char(codepoint))
      end
    end
  end)
  if not ok or #characters == 0 then
    return { value }
  end
  return characters
end

local function scramblePageText(entry, state, page)
  local instance = entry.instance
  if not instance or not instance.Parent then return end

  entry.target = instance.Text
  local characters = splitTextCharacters(entry.target)
  if #characters == 0 or entry.target:match("^%s*$") then return end

  local duration = math.clamp(#characters * 0.022, 0.18, 0.42)
  local started = os.clock()
  while os.clock() - started < duration do
    if pageAnimationStates[page] ~= state or state.cancelled or not page.Visible or not instance.Parent then
      return
    end

    local currentText = instance.Text
    if entry.lastRendered == nil or currentText ~= entry.lastRendered then
      entry.target = currentText
      characters = splitTextCharacters(entry.target)
      duration = math.clamp(#characters * 0.022, 0.18, 0.42)
    end

    local progress = math.clamp((os.clock() - started) / duration, 0, 1)
    local lockedCount = math.floor(progress * #characters)
    local output = {}
    for index, character in ipairs(characters) do
      if index <= lockedCount or character:match("^%s+$") then
        output[index] = character
      else
        output[index] = SCRAMBLE_GLYPHS[math.random(1, #SCRAMBLE_GLYPHS)]
      end
    end

    local rendered = table.concat(output)
    entry.lastRendered = rendered
    instance.Text = rendered
    task.wait(0.035)
  end

  if instance.Parent and entry.lastRendered ~= nil and instance.Text == entry.lastRendered then
    instance.Text = entry.target
  end
  entry.lastRendered = nil
end

local function getFadeProperties(instance)
  local props = {}
  if instance:IsA("GuiObject") then
    props.BackgroundTransparency = instance.BackgroundTransparency
  end
  if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
    props.TextTransparency = instance.TextTransparency
    props.TextStrokeTransparency = instance.TextStrokeTransparency
  end
  if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
    props.ImageTransparency = instance.ImageTransparency
  end
  if instance:IsA("ScrollingFrame") then
    props.ScrollBarImageTransparency = instance.ScrollBarImageTransparency
  end
  if instance:IsA("UIStroke") then
    props.Transparency = instance.Transparency
  end
  return props
end

local function cancelPageAnimation(page)
  local state = pageAnimationStates[page]
  if not state then return end
  state.cancelled = true
  for _, tween in ipairs(state.tweens) do
    pcall(function() tween:Cancel() end)
  end
  for _, entry in ipairs(state.textEntries or {}) do
    if entry.instance and entry.instance.Parent and entry.lastRendered ~= nil and entry.instance.Text == entry.lastRendered then
      pcall(function()
        entry.instance.Text = entry.target
      end)
    end
    entry.lastRendered = nil
  end
  for _, original in ipairs(state.originals) do
    if original.instance and original.instance.Parent then
      pcall(function()
        original.instance[original.property] = original.value
      end)
    end
  end
  if state.basePosition and page.Parent then
    pcall(function() page.Position = state.basePosition end)
  end
  if state.scaleObject and state.scaleObject.Parent then
    state.scaleObject:Destroy()
  end
  pageAnimationStates[page] = nil
end

local PAGE_POP_SCALE = 0.86

local function AnimatePageIn(page)
  if not page then return end
  cancelPageAnimation(page)

  local basePos = page:GetAttribute("BasePosition")
  if not basePos then
    basePos = page.Position
    page:SetAttribute("BasePosition", basePos)
  end
  page.Position = basePos

  local style = PageAnimation
  if style == "None" then
    return
  end

  local width = math.max(page.AbsoluteSize.X, 1)
  local height = math.max(page.AbsoluteSize.Y, 1)
  local startPosition = basePos
  if style == "Slide Left" then
    startPosition = offsetUDim2(basePos, width * 0.075, 0)
  elseif style == "Cascade" then
    startPosition = offsetUDim2(basePos, -width * 0.05, 0)
  elseif style == "Glitch" then
    startPosition = offsetUDim2(basePos, -14, 2)
  elseif style == "Pop" then
    local ui = (mainUIScale and mainUIScale.Scale) or 1
    startPosition = offsetUDim2(basePos, (width / ui) * (1 - PAGE_POP_SCALE) / 2, (height / ui) * (1 - PAGE_POP_SCALE) / 2)
  end

  local state = { tweens = {}, originals = {}, cancelled = false, basePosition = basePos, textEntries = {} }
  pageAnimationStates[page] = state

  if style == "Pop" then
    local scaleObject = Instance.new("UIScale")
    scaleObject.Name = "UnitPageTransitionScale"
    scaleObject.Scale = PAGE_POP_SCALE
    scaleObject.Parent = page
    state.scaleObject = scaleObject
    local scaleTween = TweenService:Create(scaleObject, TweenInfo.new(0.30, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
    table.insert(state.tweens, scaleTween)
    scaleTween:Play()
  end

  page.Position = startPosition
  local moveTween = TweenService:Create(page, TweenInfo.new(style == "Glitch" and 0.24 or 0.28, style == "Pop" and Enum.EasingStyle.Back or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = basePos })
  table.insert(state.tweens, moveTween)
  moveTween:Play()
  if style == "Glitch" then
    task.delay(0.045, function()
      if pageAnimationStates[page] == state and not state.cancelled and page.Visible then
        local jitter = TweenService:Create(page, TweenInfo.new(0.045, Enum.EasingStyle.Linear), { Position = offsetUDim2(basePos, 8, -1) })
        table.insert(state.tweens, jitter)
        jitter:Play()
      end
    end)
    task.delay(0.10, function()
      if pageAnimationStates[page] == state and not state.cancelled and page.Visible then
        local settle = TweenService:Create(page, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = basePos })
        table.insert(state.tweens, settle)
        settle:Play()
      end
    end)
  end

  local items = {}
  local function addItem(o)
    if o:IsA("GuiObject") then
      table.insert(items, o)
    end
  end
  for _, child in ipairs(page:GetChildren()) do
    if child.Name == "Cols" then
      for _, col in ipairs(child:GetChildren()) do
        if col:IsA("GuiObject") then
          for _, panel in ipairs(col:GetChildren()) do
            addItem(panel)
          end
        end
      end
    else
      addItem(child)
    end
  end
  table.sort(items, function(a, b)
    local ay, by = a.AbsolutePosition.Y, b.AbsolutePosition.Y
    if ay == by then
      return a.AbsolutePosition.X < b.AbsolutePosition.X
    end
    return ay < by
  end)

  local itemTargets = {}
  local itemTextTargets = {}
  for _, item in ipairs(items) do
    local targets = {}
    local textTargets = {}
    local objects = { item }
    for _, descendant in ipairs(item:GetDescendants()) do
      table.insert(objects, descendant)
    end
    for _, object in ipairs(objects) do
      local canFade = (object:IsA("GuiObject") and object.Visible) or (object:IsA("UIStroke") and object.Enabled)
      if canFade then
        for property, originalValue in pairs(getFadeProperties(object)) do
          if type(originalValue) == "number" and originalValue < 0.999 then
            local target = { instance = object, property = property, value = originalValue }
            table.insert(state.originals, target)
            table.insert(targets, target)
            pcall(function() object[property] = 1 end)
          end
        end
      end
      if style == "Glitch" and (object:IsA("TextLabel") or object:IsA("TextButton")) and object.Visible and object.Text ~= "" and not object.RichText then
        local textEntry = { instance = object, target = object.Text, lastRendered = nil }
        table.insert(textTargets, textEntry)
        table.insert(state.textEntries, textEntry)
      end
    end
    table.insert(itemTargets, targets)
    table.insert(itemTextTargets, textTargets)
  end

  local stagger = style == "Cascade" and 0.07 or 0.03
  local fadeInfo = TweenInfo.new(style == "Glitch" and 0.18 or 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
  for index in ipairs(items) do
    local targets = itemTargets[index]
    local textTargets = itemTextTargets[index]
    task.delay((index - 1) * stagger, function()
      if pageAnimationStates[page] ~= state or state.cancelled or not page.Visible then
        return
      end
      for _, target in ipairs(targets) do
        if target.instance and target.instance.Parent then
          local tween = TweenService:Create(target.instance, fadeInfo, { [target.property] = target.value })
          table.insert(state.tweens, tween)
          tween:Play()
        end
      end
      for _, entry in ipairs(textTargets) do
        task.spawn(scramblePageText, entry, state, page)
      end
    end)
  end

  task.delay(math.max(#items - 1, 0) * stagger + 0.65, function()
    if pageAnimationStates[page] == state then
      pageAnimationStates[page] = nil
      if state.scaleObject and state.scaleObject.Parent then state.scaleObject:Destroy() end
    end
  end)
end

local WindowElements = {}

function WindowElements:OpenSettings() OpenSettingsFn() end
function WindowElements:CloseSettings() CloseSettingsFn() end
function WindowElements:ToggleSettings() ToggleSettingsVisibility() end

function WindowElements:CreateCategory(CategoryName, IconName, Hidden)
  local CategoryElements = {}

  local catAsset = resolveIcon(IconName)
  local tabLabelText = U(CategoryName)
  local tabW = math.clamp(measure(tabLabelText, 12) + 32 + (catAsset and 20 or 0), 64, 220)

  local btn = new("TextButton", {
    Name = CategoryName,
    Size = UDim2.new(0, tabW, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    Visible = not Hidden,
    ZIndex = 4,
  }, tabsHolder)
btn:SetAttribute("CategorySelected", false)
local tabLine = new("Frame", {
  Position = UDim2.new(1, -1, 0, 0),
  Size = UDim2.new(0, 1, 1, 0),
  BorderSizePixel = 0,
  ZIndex = 6,
}, btn)
bind(tabLine, "BackgroundColor3", "Line")
local catIcon
if catAsset then
  catIcon = new("ImageLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0.5, -7),
    Size = UDim2.fromOffset(14, 14),
    Image = catAsset,
    ZIndex = 5,
  }, btn)
end
local catLabel = new("TextLabel", {
  BackgroundTransparency = 1,
  Position = UDim2.fromOffset(catAsset and 28 or 0, 0),
  Size = UDim2.new(1, -(catAsset and 28 or 0), 1, 0),
  Text = tabLabelText,
  ZIndex = 5,
}, btn)
bindFont(catLabel, 12, false)

local catHover = false
local function catLook(animate)
  local selected = btn:GetAttribute("CategorySelected") == true
  local dur = animate and 0.14 or 0
  local fill = selected and Theme.Accent or Theme.Row:Lerp(Theme.Accent, 0.16)
  tw(btn, dur, {
    BackgroundTransparency = (selected or catHover) and 0 or 1,
    BackgroundColor3 = fill,
  })
local txt = selected and Theme.Cream or Theme.Ink
tw(catLabel, dur, { TextColor3 = txt })
if catIcon then
  catIcon.ImageColor3 = txt
end
end
btn.MouseEnter:Connect(function() catHover = true; catLook(true) end)
btn.MouseLeave:Connect(function() catHover = false; catLook(true) end)
btn:GetAttributeChangedSignal("CategorySelected"):Connect(function() catLook(true) end)
table.insert(lookers, { row = btn, fn = catLook })
catLook(false)

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
new("UIPadding", {
  PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 22),
}, CategoryPage)

local cols, colH = {}, {}
local curCol, curPanel, panelCount, order = 1, nil, 0, 0
local colHolder

local function buildCols()
  colHolder = new("Frame", {
    Name = "Cols",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(16, 0),
    Size = UDim2.new(1, -(16 + 18), 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
  }, CategoryPage)
new("UIListLayout", {
  FillDirection = Enum.FillDirection.Horizontal,
  SortOrder = Enum.SortOrder.LayoutOrder,
  Padding = UDim.new(0, COL_GAP),
}, colHolder)
cols, colH = {}, {}
for i = 1, ColumnCount do
  local col = new("Frame", {
    Name = "Col" .. i,
    BackgroundTransparency = 1,
    Size = UDim2.new(1 / ColumnCount, -(COL_GAP * (ColumnCount - 1)) / ColumnCount, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = i,
  }, colHolder)
new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, COL_GAP) }, col)
cols[i], colH[i] = col, 0
end
curPanel, panelCount, curCol = nil, 0, 1
end
buildCols()

local function nextOrder()
  order += 1
  return order
end

local function newPanel(title, iconName, textColor)
  local ci = 1
  for i = 2, ColumnCount do
    if colH[i] < colH[ci] then ci = i end
  end
  curCol = ci
  local col = cols[ci]

  -- The panel itself has no layout; rows/headers go inside `inner`.
  local panel = new("Frame", {
    Name = "Panel",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = #col:GetChildren(),
  }, col)
  local ps = new("UIStroke", { Thickness = 1 }, panel)
  bind(ps, "Color", "Line")

  local inner = new("Frame", {
    Name = "Inner",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
  }, panel)
  new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, inner)

  for _, c in ipairs({ { 1, 1 } }) do
    local sq = new("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.fromScale(c[1], c[2]),
      Size = UDim2.fromOffset(5, 5),
      BorderSizePixel = 0,
      ZIndex = 8,
    }, panel)
    bind(sq, "BackgroundColor3", "Accent")
  end
  curPanel = inner

  local headLabel
  if title ~= nil then
    panelCount += 1
    local h = new("Frame", {
      Name = "PanelHeader",
      Size = UDim2.new(1, 0, 0, 26),
      BorderSizePixel = 0,
      LayoutOrder = 0,
    }, inner)
    bind(h, "BackgroundColor3", "Row")
    bindGlass(h)
    local ln = new("Frame", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 3 }, h)
    bind(ln, "BackgroundColor3", "Line")
    local x = 12
    local asset = resolveIcon(iconName)
    if asset then
      local img = new("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -7),
        Size = UDim2.fromOffset(14, 14),
        Image = asset,
      }, h)
      bind(img, "ImageColor3", "Accent")
      x = 30
    end
    local text = NumberSections and string.format("%02d / %s", panelCount, U(title)) or U(title)
    headLabel = new("TextLabel", {
      BackgroundTransparency = 1,
      Position = UDim2.new(0, x, 0, 0),
      Size = UDim2.new(1, -(x + 8), 1, 0),
      Text = text,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextTruncate = Enum.TextTruncate.AtEnd,
    }, h)
    bindFont(headLabel, 11, true)
    if textColor then
      headLabel.TextColor3 = textColor
    else
      bind(headLabel, "TextColor3", "Ink")
    end
    colH[ci] += 26
  end
  return panel, headLabel
end

local function ensurePanel()
  if not curPanel or not curPanel.Parent then
    newPanel(nil)
  end
end

function CategoryElements:Clear()
  if colHolder then
    colHolder:Destroy()
  end
  order = 0
  buildCols()
end

local function SelectTab()
  SettingsState.open = false
  for _, page in ipairs(ContentContainer:GetChildren()) do
    if page:IsA("ScrollingFrame") then
      cancelPageAnimation(page)
      page.Visible = false
    end
  end
  for _, b in ipairs(tabsHolder:GetChildren()) do
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

local function newRow(className, height)
  ensurePanel()
  height = height or 28
  local row = new(className, {
    Size = UDim2.new(1, 0, 0, height),
    BorderSizePixel = 0,
    LayoutOrder = nextOrder(),
  }, curPanel)
if className == "TextButton" then
  row.AutoButtonColor = false
  row.Text = ""
end
bind(row, "BackgroundColor3", "Row")
bindGlass(row)
local ln = new("Frame", {
  Position = UDim2.new(0, 0, 1, -1),
  Size = UDim2.new(1, 0, 0, 1),
  BorderSizePixel = 0,
  BackgroundTransparency = 0.45,
  ZIndex = 3,
}, row)
bind(ln, "BackgroundColor3", "Line")
colH[curCol] += height
return row
end

local function addMarker(parent, iconName)
  local asset = resolveIcon(iconName)
  if asset then
    local img = new("ImageLabel", {
      BackgroundTransparency = 1,
      Position = UDim2.new(0, 10, 0.5, -8),
      Size = UDim2.fromOffset(16, 16),
      Image = asset,
    }, parent)
  return img, true
end
local dummy = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 1), Visible = false }, parent)
return dummy, false
end

local function addLabel(parent, text, x, scale, reserve)
  local l = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, x, 0, 0),
    Size = UDim2.new(scale or 1, -(x + 10 + (reserve or 0)), 1, 0),
    Text = U(text),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
  }, parent)
bindFont(l, 12, false)
bind(l, "TextColor3", "Ink")
return l
end

local function hoverable(o)
  local state = { hover = false }
  local fullSize = o.wipeHeight and UDim2.new(1, 0, 0, o.wipeHeight) or UDim2.new(1, 0, 1, 0)
  local emptySize = o.wipeHeight and UDim2.new(0, 0, 0, o.wipeHeight) or UDim2.new(0, 0, 1, 0)

  local wipe = new("Frame", {
    Name = "Wipe",
    BorderSizePixel = 0,
    ZIndex = 0,
    Size = emptySize,
  }, o.row)
bind(wipe, "BackgroundColor3", "Accent")

local function look(animate)
  local h = state.hover
  local dur = animate and 0.12 or 0
  tw(wipe, dur, { Size = h and fullSize or emptySize })
  for _, l in ipairs(o.labels) do
    tw(l, dur, { TextColor3 = h and Theme.Cream or (o.color or Theme.Ink) })
  end
  if o.hasIcon then
    o.marker.ImageColor3 = h and Theme.Cream or Theme.Accent
  end
  if o.onLook then
    o.onLook(h, animate)
  end
end
local target = o.target or o.row
target.MouseEnter:Connect(function() state.hover = true; look(true) end)
target.MouseLeave:Connect(function() state.hover = false; look(true) end)
table.insert(lookers, { row = o.row, fn = look })
look(false)
return state, look, wipe
end

local function inputBox(row, placeholder, text, width)
  local bg = new("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(width or 130, 20),
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
bindFont(tb, 11, false)
bind(tb, "TextColor3", "Ink")
bind(tb, "PlaceholderColor3", dimInk)
return tb
end

function CategoryElements:CreateLabel(Text, IconName, TextColor)
  if typeof(IconName) == "Color3" then
    TextColor = IconName
    IconName = nil
  end
  local _, headLabel = newPanel(Text, IconName, TextColor)
  return headLabel
end

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
  local lbl = addLabel(row, ButtonText, hasIcon and 32 or 12)
  local state, look, wipe = hoverable({
    row = row, marker = marker, hasIcon = hasIcon, labels = { lbl }, color = TextColor,
  })

row.MouseButton1Click:Connect(function()
  wipe.BackgroundColor3 = Theme.Accent:Lerp(Theme.Paper, 0.25)
  task.delay(0.1, function()
    wipe.BackgroundColor3 = Theme.Accent
    if UserInputService.TouchEnabled then
      state.hover = false
    end
    look(true)
  end)
  if Callback then
    task.spawn(Callback)
  end
end)

return {
  SetText = function(t)
    lbl.Text = U(t)
  end,
}
end

function CategoryElements:CreateMenuButton(ButtonText, IconName, Items)
  if type(IconName) == "table" then
    Items = IconName; IconName = nil
  end
  return CategoryElements:CreateButton(ButtonText, IconName, function()
    ShowContextMenu(Items)
  end)
end

function CategoryElements:CreateButtonRow(Buttons)
  ensurePanel()
  local holder = new("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 42),
    LayoutOrder = nextOrder(),
  }, curPanel)
colH[curCol] += 42
new("UIListLayout", {
  FillDirection = Enum.FillDirection.Horizontal,
  HorizontalAlignment = Enum.HorizontalAlignment.Right,
  VerticalAlignment = Enum.VerticalAlignment.Center,
  SortOrder = Enum.SortOrder.LayoutOrder,
  Padding = UDim.new(0, 8),
}, holder)
new("UIPadding", { PaddingRight = UDim.new(0, 10) }, holder)

for i, def in ipairs(Buttons or {}) do
  local primary = def.Primary == true
  local b = new("TextButton", {
    AutoButtonColor = false,
    BorderSizePixel = 0,
    Text = U(def.Text or "OK"),
    Size = UDim2.fromOffset(def.Width or 86, 24),
    LayoutOrder = i,
  }, holder)
bindFont(b, 11, true)
local st = new("UIStroke", { Thickness = 1 }, b)
local hover = false
local function paint()
  local filled = primary ~= hover
  b.BackgroundColor3 = Theme.Accent
  b.BackgroundTransparency = filled and 0 or 1
  b.TextColor3 = filled and Theme.Cream or Theme.Ink
  st.Color = filled and Theme.Accent or Theme.Ink
end
b.MouseEnter:Connect(function() hover = true; paint() end)
b.MouseLeave:Connect(function() hover = false; paint() end)
b.MouseButton1Click:Connect(function()
  if def.Callback then
    task.spawn(def.Callback)
  end
end)
table.insert(lookers, { row = b, fn = paint })
paint()
end
end

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
  local lbl = addLabel(row, TextboxText, hasIcon and 32 or 12, 1, 140)
  if hasIcon then bind(marker, "ImageColor3", "Accent") end

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

function CategoryElements:CreateNumberTextbox(LabelText, IconName, DefaultNumber, Flag, Callback)
  if type(Flag) == "function" then
    Callback = Flag; Flag = nil
  end
  if Flag and SavedFlags[Flag] ~= nil then
    DefaultNumber = SavedFlags[Flag]
  end

  local row = newRow("Frame")
  local marker, hasIcon = addMarker(row, IconName)
  local lbl = addLabel(row, LabelText, hasIcon and 32 or 12, 1, 140)
  if hasIcon then bind(marker, "ImageColor3", "Accent") end

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

function CategoryElements:CreateSearchBar(Placeholder, IconName, Callback)
  if type(IconName) == "function" then
    Callback = IconName; IconName = nil
  end
  IconName = IconName or "lucide-search"

  local row = newRow("Frame")
  local asset = resolveIcon(IconName)
  if asset then
    local img = new("ImageLabel", {
      BackgroundTransparency = 1,
      Position = UDim2.new(0, 10, 0.5, -8),
      Size = UDim2.fromOffset(16, 16),
      Image = asset,
    }, row)
  bind(img, "ImageColor3", "Accent")
end
local x = asset and 34 or 12
local tb = new("TextBox", {
  BackgroundTransparency = 1,
  Position = UDim2.fromOffset(x, 0),
  Size = UDim2.new(1, -(x + 10), 1, 0),
  PlaceholderText = U(Placeholder or "Search"),
  Text = "",
  ClearTextOnFocus = false,
  TextXAlignment = Enum.TextXAlignment.Left,
  TextTruncate = Enum.TextTruncate.AtEnd,
}, row)
bindFont(tb, 12, false)
bind(tb, "TextColor3", "Ink")
bind(tb, "PlaceholderColor3", dimInk)
tb:GetPropertyChangedSignal("Text"):Connect(function()
  if Callback then
    Callback(tb.Text)
  end
end)
end

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
  local lbl = addLabel(row, ToggleText, hasIcon and 32 or 12, 1, 56)
  local box = new("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(44, 18),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
  }, row)
local boxStroke = new("UIStroke", { Thickness = 1 }, box)
local knob = new("Frame", {
  AnchorPoint = Vector2.new(0, 0.5),
  Position = UDim2.new(0, 3, 0.5, 0),
  Size = UDim2.fromOffset(12, 12),
  BorderSizePixel = 0,
}, box)

local hovering = false
local function paint(animate)
  local dur = animate and 0.14 or 0
  local onCol = hovering and Theme.Cream or Theme.Ink
  local offCol = hovering and Theme.Cream:Lerp(Theme.Accent, 0.5) or Theme.Ink:Lerp(Theme.Paper, 0.62)
  tw(knob, dur, {
    Position = current and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
    BackgroundColor3 = current and onCol or offCol,
  })
boxStroke.Color = hovering and Theme.Cream or Theme.Ink:Lerp(Theme.Paper, 0.2)
end
hoverable({
  row = row, marker = marker, hasIcon = hasIcon, labels = { lbl },
  active = function() return current end,
  onLook = function(h, animate)
    hovering = h
    paint(animate)
  end,
})

local function apply(fire)
  paint(true)
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
  if Library._sfx then
    Library._sfx(current and "toggleOn" or "toggleOff")
  end
end)

row:SetAttribute("NoSelectSfx", true)

return {
  Set = function(v)
    current = v == true
    if Flag then Flags[Flag].Value = current end
    apply(true)
  end,
  Get = function() return current end,
}
end

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
  local marker, hasIcon = addMarker(row, IconName)
  local lbl = addLabel(row, SliderText, hasIcon and 32 or 12, 0.4)
  local valLbl = new("TextLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(34, 20),
    TextXAlignment = Enum.TextXAlignment.Right,
  }, row)
bindFont(valLbl, 11, false)

local track = new("Frame", {
  AnchorPoint = Vector2.new(1, 0.5),
  Position = UDim2.new(1, -50, 0.5, 0),
  Size = UDim2.new(0.44, 0, 0, 18),
  BackgroundTransparency = 1,
  Active = true,
}, row)
new("UISizeConstraint", { MinSize = Vector2.new(70, 18), MaxSize = Vector2.new(240, 18) }, track)

local N = 22
local blocks = {}
for i = 1, N do
  blocks[i] = new("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new((i - 1) / N, 0, 0.5, 0),
    Size = UDim2.new(1 / N, -2, 0, 8),
    BorderSizePixel = 0,
  }, track)
end
local thumb = new("Frame", {
  AnchorPoint = Vector2.new(0.5, 0.5),
  Size = UDim2.fromOffset(2, 16),
  BorderSizePixel = 0,
  ZIndex = 2,
}, track)

local hoverState
local function render()
  local h = hoverState and hoverState.hover or false
  local f = (Max == Min) and 0 or (value - Min) / (Max - Min)
  valLbl.Text = tostring(value)
  valLbl.TextColor3 = h and Theme.Cream or Theme.Ink:Lerp(Theme.Paper, 0.35)
  thumb.Position = UDim2.new(f, 0, 0.5, 0)
  thumb.BackgroundColor3 = h and Theme.Cream or Theme.Ink
  local on = h and Theme.Cream or Theme.Ink
  local off = h and Theme.Cream:Lerp(Theme.Accent, 0.6) or Theme.Row:Lerp(Theme.Ink, 0.3)
  for i = 1, N do
    blocks[i].BackgroundColor3 = ((i - 0.5) / N) <= f and on or off
  end
end
hoverState = hoverable({
  row = row, marker = marker, hasIcon = hasIcon, labels = { lbl },
  onLook = function() render() end,
})
render()

makeDrag(track, function(input)
  local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
  local newValue = math.clamp(math.floor(Min + (Max - Min) * rel + 0.5), Min, Max)
  local changed = newValue ~= value
  value = newValue
  render()
  if changed and Library._sfx then
    Library._sfx("slider")
  end
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

function CategoryElements:CreateProgress(ProgressText, Default)
  local value = math.clamp(tonumber(Default) or 0, 0, 100)
  local row = newRow("Frame", 46)
  local lbl = addLabel(row, ProgressText, 12, 0.7)
  lbl.Size = UDim2.new(0.7, -22, 0, 26)
  local pct = new("TextLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 0),
    Size = UDim2.fromOffset(60, 26),
    TextXAlignment = Enum.TextXAlignment.Right,
  }, row)
bindFont(pct, 11, false)
local bar = new("Frame", {
  BackgroundTransparency = 1,
  Position = UDim2.fromOffset(12, 28),
  Size = UDim2.new(1, -22, 0, 10),
}, row)
local N = 28
local blocks = {}
for i = 1, N do
  blocks[i] = new("Frame", {
    Position = UDim2.new((i - 1) / N, 0, 0, 0),
    Size = UDim2.new(1 / N, -2, 1, 0),
    BorderSizePixel = 0,
  }, bar)
end
local function render()
  pct.Text = tostring(math.floor(value + 0.5)) .. "%"
  pct.TextColor3 = Theme.Ink:Lerp(Theme.Paper, 0.35)
  for i = 1, N do
    blocks[i].BackgroundColor3 = (i / N) <= (value / 100) + 0.0001 and Theme.Ink or Theme.Row:Lerp(Theme.Ink, 0.3)
  end
end
table.insert(lookers, { row = row, fn = render })
render()
return {
  Set = function(v)
    value = math.clamp(tonumber(v) or 0, 0, 100)
    render()
  end,
  Get = function() return value end,
}
end

function CategoryElements:CreateSegmented(SegText, IconName, Options, Default, Flag, Callback)
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
  Options = Options or {}
  local current = Default or Options[1]
  if Flag then
    Flags[Flag] = { Type = "Segmented", Value = current }
  end

  local row = newRow("Frame", 36)
  local marker, hasIcon = addMarker(row, IconName)
  addLabel(row, SegText, hasIcon and 32 or 12, 0.4)
  local group = new("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.new(0.56, 0, 0, 22),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
  }, row)
new("UISizeConstraint", { MinSize = Vector2.new(90, 22), MaxSize = Vector2.new(260, 22) }, group)
local gs = new("UIStroke", { Thickness = 1 }, group)
bind(gs, "Color", "Ink")

local buttons = {}
local count = math.max(#Options, 1)
for i, opt in ipairs(Options) do
  local b = new("TextButton", {
    AutoButtonColor = false,
    BorderSizePixel = 0,
    Text = U(opt),
    Position = UDim2.new((i - 1) / count, 0, 0, 0),
    Size = UDim2.new(1 / count, 0, 1, 0),
  }, group)
bindFont(b, 10, true)
if i > 1 then
  local sep = new("Frame", { Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, ZIndex = 3 }, b)
  bind(sep, "BackgroundColor3", "Line")
end
buttons[i] = { b = b, opt = opt }
b.MouseButton1Click:Connect(function()
  current = opt
  if Flag then
    Flags[Flag].Value = current
    save()
  end
  for _, e in ipairs(buttons) do
    local sel = e.opt == current
    e.b.BackgroundTransparency = sel and 0 or 1
    e.b.BackgroundColor3 = Theme.Accent
    e.b.TextColor3 = sel and Theme.Cream or Theme.Ink
  end
  if Callback then
    Callback(current)
  end
end)
end
local function paint()
  for _, e in ipairs(buttons) do
    local sel = e.opt == current
    e.b.BackgroundColor3 = Theme.Accent
    e.b.BackgroundTransparency = sel and 0 or 1
    e.b.TextColor3 = sel and Theme.Cream or Theme.Ink
  end
end
table.insert(lookers, { row = row, fn = paint })
paint()

return {
  Set = function(v)
    current = v
    if Flag then Flags[Flag].Value = current end
    paint()
  end,
  Get = function() return current end,
}
end

function CategoryElements:CreateSwatches(SwatchText, IconName, Colors, DefaultIndex, Flag, Callback)
  if type(IconName) == "table" then
    Callback = Flag; Flag = DefaultIndex; DefaultIndex = Colors; Colors = IconName; IconName = nil
  end
  if type(Flag) == "function" then
    Callback = Flag; Flag = nil
  end
  if Flag and SavedFlags[Flag] ~= nil then
    DefaultIndex = SavedFlags[Flag]
  end
  Colors = Colors or {}
  local index = tonumber(DefaultIndex) or 1
  if Flag then
    Flags[Flag] = { Type = "Swatches", Value = index }
  end

  local row = newRow("Frame", 36)
  local marker, hasIcon = addMarker(row, IconName)
  addLabel(row, SwatchText, hasIcon and 32 or 12, 0.4)
  local holder = new("Frame", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.new(0.56, 0, 1, 0),
  }, row)
new("UIListLayout", {
  FillDirection = Enum.FillDirection.Horizontal,
  HorizontalAlignment = Enum.HorizontalAlignment.Right,
  VerticalAlignment = Enum.VerticalAlignment.Center,
  SortOrder = Enum.SortOrder.LayoutOrder,
  Padding = UDim.new(0, 8),
}, holder)

local swatches = {}
local function paint()
  for i, s in ipairs(swatches) do
    s.stroke.Color = Theme.Ink
    s.stroke.Transparency = (i == index) and 0 or 1
  end
end
for i, col in ipairs(Colors) do
  local s = new("TextButton", {
    AutoButtonColor = false,
    Text = "",
    BorderSizePixel = 0,
    BackgroundColor3 = col,
    Size = UDim2.fromOffset(20, 20),
    LayoutOrder = i,
  }, holder)
local st = new("UIStroke", { Thickness = 2 }, s)
swatches[i] = { btn = s, stroke = st }
s.MouseButton1Click:Connect(function()
  index = i
  if Flag then
    Flags[Flag].Value = index
    save()
  end
  paint()
  if Callback then
    Callback(col, i)
  end
end)
end
table.insert(lookers, { row = row, fn = paint })
paint()

return {
  Set = function(i)
    index = i
    if Flag then Flags[Flag].Value = index end
    paint()
  end,
  Get = function() return index end,
}
end

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
local lbl = addLabel(header, PickerText, hasIcon and 32 or 12, 1, 100)
local hexLbl = new("TextLabel", {
  BackgroundTransparency = 1,
  AnchorPoint = Vector2.new(1, 0.5),
  Position = UDim2.new(1, -36, 0.5, 0),
  Size = UDim2.fromOffset(62, 20),
  TextXAlignment = Enum.TextXAlignment.Right,
}, header)
bindFont(hexLbl, 11, false)
local swatch = new("Frame", {
  AnchorPoint = Vector2.new(1, 0.5),
  Position = UDim2.new(1, -10, 0.5, 0),
  Size = UDim2.fromOffset(18, 18),
  BorderSizePixel = 0,
  BackgroundColor3 = DefaultColor,
}, header)
local sst = new("UIStroke", { Thickness = 1 }, swatch)
bind(sst, "Color", "Ink")

hoverable({
  row = container, target = header, marker = marker, hasIcon = hasIcon,
  labels = { lbl, hexLbl }, wipeHeight = 28,
})

local svBox = new("Frame", {
  Position = UDim2.fromOffset(10, 34), Size = UDim2.new(1, -20, 0, 92),
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
  Position = UDim2.fromOffset(10, 132), Size = UDim2.new(1, -20, 0, 14),
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
local lbl = addLabel(header, text, hasIcon and 32 or 12, 0.5)

local box = new("Frame", {
  AnchorPoint = Vector2.new(1, 0.5),
  Position = UDim2.new(1, -10, 0, 14),
  Size = UDim2.new(0.46, 0, 0, 20),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
}, header)
new("UISizeConstraint", { MinSize = Vector2.new(110, 20), MaxSize = Vector2.new(260, 20) }, box)
local boxStroke = new("UIStroke", { Thickness = 1 }, box)
local valLbl = new("TextLabel", {
  BackgroundTransparency = 1,
  Position = UDim2.fromOffset(8, 0),
  Size = UDim2.new(1, -26, 1, 0),
  TextXAlignment = Enum.TextXAlignment.Left,
  TextTruncate = Enum.TextTruncate.AtEnd,
}, box)
bindFont(valLbl, 11, false)
local arrow = new("TextLabel", {
  BackgroundTransparency = 1,
  AnchorPoint = Vector2.new(1, 0.5),
  Position = UDim2.new(1, -5, 0.5, 0),
  Size = UDim2.fromOffset(14, 14),
  Text = ">",
  Rotation = 90,
}, box)
bindFont(arrow, 11, true)

hoverable({
  row = container, target = header, marker = marker, hasIcon = hasIcon,
  labels = { lbl, valLbl, arrow }, wipeHeight = 28,
  onLook = function(h)
    boxStroke.Color = h and Theme.Cream or Theme.Ink
  end,
})

local function headerText()
  if multi then
    return #selOrder == 0 and "NONE" or U(joinList(selOrder))
  end
  return currentVal ~= nil and U(currentVal) or ""
end
valLbl.Text = headerText()

local showSearch = multi or #(options or {}) > 7
local listTop = (showSearch and 28 or 0) + (multi and 26 or 0)
local listFrame = new("Frame", {
  BorderSizePixel = 0,
  AnchorPoint = Vector2.new(1, 0),
  Position = UDim2.new(1, -10, 0, 30),
  Size = UDim2.new(0.46, 0, 1, -36),
}, container)
new("UISizeConstraint", { MinSize = Vector2.new(110, 0), MaxSize = Vector2.new(260, 100000) }, listFrame)
bind(listFrame, "BackgroundColor3", "Accent")
local listStroke = new("UIStroke", { Thickness = 1 }, listFrame)
bind(listStroke, "Color", "Line")

local search = new("TextBox", {
  BorderSizePixel = 0,
  Position = UDim2.fromOffset(4, 3),
  Size = UDim2.new(1, -8, 0, 22),
  PlaceholderText = "SEARCH",
  Text = "",
  ClearTextOnFocus = false,
  TextXAlignment = Enum.TextXAlignment.Left,
  TextTruncate = Enum.TextTruncate.AtEnd,
  Visible = showSearch,
}, listFrame)
new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, search)
bind(search, "BackgroundColor3", inputColor)
bind(search, "TextColor3", "Ink")
bind(search, "PlaceholderColor3", dimInk)
bindFont(search, 11, false)

local scroll = new("ScrollingFrame", {
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Position = UDim2.fromOffset(0, listTop),
  Size = UDim2.new(1, 0, 1, -listTop),
  ScrollBarThickness = 3,
  CanvasSize = UDim2.new(),
  AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, listFrame)
bind(scroll, "ScrollBarImageColor3", "Paper")
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
  local target = isOpen and (36 + listTop + math.min(visibleCount(), 6) * 24) or 28
  TweenService:Create(container, TweenInfo.new(0.18), { Size = UDim2.new(1, 0, 0, target) }):Play()
  TweenService:Create(arrow, TweenInfo.new(0.15), { Rotation = isOpen and -90 or 90 }):Play()
end
local function paintMarks()
  for _, e in ipairs(entries) do
    local selected
    if multi then selected = selSet[e.value] == true else selected = currentVal == e.value end
    e.mark.Visible = selected
  end
  valLbl.Text = headerText()
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
local mark = new("Frame", {
  Position = UDim2.fromOffset(8, 9), Size = UDim2.fromOffset(6, 6),
  BorderSizePixel = 0, Visible = false,
}, b)
bind(mark, "BackgroundColor3", "Cream")
local ol = new("TextLabel", {
  BackgroundTransparency = 1, Position = UDim2.fromOffset(22, 0), Size = UDim2.new(1, -28, 1, 0),
  Text = U(opt), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, b)
bindFont(ol, 11, false)
bind(ol, "TextColor3", "Cream")
local entry = { btn = b, value = opt, mark = mark, text = string.lower(tostring(opt)) }
table.insert(entries, entry)

b.MouseEnter:Connect(function()
  b.BackgroundTransparency = 0
  b.BackgroundColor3 = Theme.Paper
  ol.TextColor3 = Theme.Ink
  mark.BackgroundColor3 = Theme.Ink
end)
b.MouseLeave:Connect(function()
  b.BackgroundTransparency = 1
  ol.TextColor3 = Theme.Cream
  mark.BackgroundColor3 = Theme.Cream
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
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, showSearch and 28 or 0),
    Size = UDim2.new(1, 0, 0, 26),
  }, listFrame)
local function quickBtn(txt, xScale, fn)
  local qb = new("TextButton", {
    BorderSizePixel = 0, AutoButtonColor = false, Text = txt,
    Position = UDim2.new(xScale, xScale == 0 and 4 or 2, 0, 2),
    Size = UDim2.new(0.5, -6, 0, 22),
  }, quick)
bind(qb, "BackgroundColor3", "Paper")
bind(qb, "TextColor3", "Ink")
bindFont(qb, 10, true)
qb.MouseButton1Click:Connect(fn)
end
quickBtn("SELECT ALL", 0, function()
  for _, e in ipairs(entries) do
    if e.btn.Visible then setChecked(e, true, true) end
  end
  paintMarks()
  fire()
end)
quickBtn("CLEAR ALL", 0.5, function()
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

WindowElements.Flags = Flags
WindowElements.ApplyTeamColor = function(instance, property)
  bind(instance, property or "BackgroundColor3", "Team")
end
WindowElements.UpdateTeamColor = function(color)
  runThemeTransition(function()
    Theme.Team = color
    refreshTheme()
  end)
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

function WindowElements:Notify(text, duration)
  if Library._sfx then
    Library._sfx("notify")
  end
  Notify(text, duration)
end
function WindowElements:ShowContextMenu(items, position) ShowContextMenu(items, position) end
function WindowElements:HideContextMenu() HideContextMenu() end
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

connect(UserInputService.InputBegan, function(input, processed)
  if listeningKey or processed or not toggleKey then
    return
  end
  if input.KeyCode == toggleKey then
    SetWindowOpen(not main.Visible)
  end
end)

function WindowElements:SetToggleKey(key)
  if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
    toggleKey = key
    persistTheme()
    save()
  end
end
function WindowElements:SetMobileStyle(name)
  SetMobileStyle(name)
  save()
end

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
          cancelPageAnimation(page)
          page.Visible = false
        end
      end
      SettingsPage.Visible = true
      AnimatePageIn(SettingsPage)
      SettingsState.open = true
    end
    local function HideSettingsPanel()
      if not SettingsState.open then return end
      cancelPageAnimation(SettingsPage)
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

    local TransPercent = math.floor(GTrans * 100 + 0.5)
    local volumeSaveToken = 0
    local BuildSettingsUI

    local function applyPreset(name)
      if not Presets[name] then return end
      runThemeTransition(function()
        loadPreset(Presets[name])
        CurrentPreset = name
        refreshTheme()
        persistTheme()
        BuildSettingsUI()
        save()
      end)
    end

    BuildSettingsUI = function()
      local T = Translations[Language] or Translations.en
      SettingsTab:Clear()

      SettingsTab:CreateLabel(T.PresetHeader, "lucide-palette")
      SettingsTab:CreateDropdown(T.PresetLabel, "lucide-palette", PresetOrder, CurrentPreset, nil, function(selected)
        applyPreset(selected)
      end)
      SettingsTab:CreateSlider(T.OverallScaleLabel, "lucide-scaling", 70, 130, OverallScalePercent, "OverallScalePercent", function(v)
        SetOverallScale(v)
      end)
      SettingsTab:CreateSlider(T.TransparencyLabel, "lucide-glasses", 0, 90, TransPercent, function(v)
        TransPercent = v
        setGlass(v / 100)
        persistTheme()
      end)
      SettingsTab:CreateSlider(T.SoundVolumeLabel, "lucide-volume-2", 0, 100, math.floor((Library.SoundVolume or 1) * 100 + 0.5), function(v)
        if Library.SetSoundVolume then
          Library:SetSoundVolume(v / 100)
        end
        persistTheme()

        volumeSaveToken += 1
        local token = volumeSaveToken
        task.delay(0.5, function()
          if token == volumeSaveToken then
            save()
          end
        end)
      end)

      SettingsTab:CreateLabel(T.InterfaceHeader, "lucide-panels-top-left")
      SettingsTab:CreateDropdown(T.PageAnimationLabel, "lucide-panels-top-left", PageAnimationOrder, PageAnimation, nil, function(selected)
        if not containsOption(PageAnimationOrder, selected) then return end
        PageAnimation = selected
        persistTheme()
        save()
      end)
      SettingsTab:CreateDropdown(T.OpenCloseAnimationLabel, "lucide-sparkles", OpenCloseAnimationOrder, OpenCloseAnimation, nil, function(selected)
        if not containsOption(OpenCloseAnimationOrder, selected) then return end
        OpenCloseAnimation = selected
        persistTheme()
        save()
      end)

      if isMobile then
        SettingsTab:CreateDropdown(T.MobileStyleLabel, "lucide-smartphone", MobileStyleOrder, MobileStyle, nil, function(selected)
          SetMobileStyle(selected)
          save()
        end)
        SettingsTab:CreateSlider(T.ToggleButtonScaleLabel, "lucide-move", 50, 180, ToggleButtonScalePercent, "ToggleButtonScalePercent", function(v)
          SetToggleButtonScale(v)
        end)
      else
        local keyBtn
        local function keyText()
          return T.ToggleKeyLabel .. " : " .. (toggleKey and toggleKey.Name or "None")
        end
        keyBtn = SettingsTab:CreateButton(keyText(), "lucide-keyboard", function()
          if listeningKey then return end
          listeningKey = true
          keyBtn.SetText(T.PressKey)
          local conn
          conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            conn:Disconnect()
            if input.KeyCode ~= Enum.KeyCode.Escape then
              toggleKey = input.KeyCode
              persistTheme()
              save()
            end
            keyBtn.SetText(keyText())
            task.defer(function()
              listeningKey = false
            end)
          end)
        end)
      end
    end

    BuildSettingsUI()
  end)
end

if Config.StartOpen ~= false then
  task.defer(function()
    SetWindowOpen(true)
    if toggleKey and not isMobile and Config.ToggleHint ~= false then
      Notify("Press [ " .. toggleKey.Name .. " ] to hide GUI", 4)
    end
  end)
end

return WindowElements
end

local NIER_SOUND_URL = "https://github.com/PMLOLHUB/assets-library-/raw/refs/heads/main/NierSound.lua"

do
  local okSource, source = pcall(function()
    return game:HttpGet(NIER_SOUND_URL)
  end)
  if okSource and type(source) == "string" and source ~= "" then
    local compiler = getExecutorFunction("loadstring")
    if not compiler then
      local ok, value = pcall(function() return loadstring end)
      if ok and type(value) == "function" then compiler = value end
    end
    if compiler then
      local okChunk, chunk = pcall(compiler, source)
      if okChunk and type(chunk) == "function" then
        local okModule, module = pcall(chunk)
        if okModule and type(module) == "function" then
          pcall(module, Library)
        end
      end
    end
  end
end

return Library
