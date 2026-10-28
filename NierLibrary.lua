local Library = {}

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ConfigFileName = "NIER_Config.json"
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
        PresetHeader = "Preset Themes",
        PresetLabel = "Choose a Preset Theme",
        TransparencyLabel = "Transparency (%)",
        OverallScaleLabel = "Overall UI Scale (%)",
        ToggleButtonScaleLabel = "Toggle Button Size (%)",
        ToggleKeyLabel = "Toggle Key",
        PressKey = "Press a key... (Esc = cancel)",
        MobileStyleLabel = "Mobile Button Style",
        SoundVolumeLabel = "Sound Volume (%)",
        PageAnimationLabel = "Page Transition Style",
        OpenCloseAnimationLabel = "Window Open / Close Style",
    },
th = {
    PresetHeader = "ธีมสำเร็จรูป",
    PresetLabel = "เลือกธีมสำเร็จรูป",
    TransparencyLabel = "ความโปร่งแสง (%)",
    OverallScaleLabel = "ขนาด UI โดยรวม (%)",
    ToggleButtonScaleLabel = "ขนาดปุ่มเปิด/ปิด (%)",
    ToggleKeyLabel = "ปุ่มเปิด/ปิด",
    PressKey = "กดปุ่มบนคีย์บอร์ด... (Esc = ยกเลิก)",
    MobileStyleLabel = "รูปแบบปุ่มเปิด/ปิด (มือถือ)",
    SoundVolumeLabel = "ระดับเสียง (%)",
    PageAnimationLabel = "สไตล์แอนิเมชันเปลี่ยนหน้า",
    OpenCloseAnimationLabel = "สไตล์แอนิเมชันเปิด / ปิด UI",
},
}

local Presets = {
    Paper = { Paper = { 204, 198, 174 }, Row = { 172, 166, 149 }, Input = { 226, 220, 198 }, Accent = { 54, 50, 44 }, Ink = { 72, 66, 52 }, Cream = { 252, 248, 220 }, Line = { 158, 152, 129 }, Team = { 120, 110, 80 } },
    Dusk = { Paper = { 196, 184, 170 }, Row = { 172, 158, 144 }, Input = { 228, 216, 204 }, Accent = { 70, 52, 58 }, Ink = { 70, 54, 56 }, Cream = { 244, 232, 222 }, Line = { 150, 134, 124 }, Team = { 150, 90, 100 } },
    Moss = { Paper = { 198, 202, 176 }, Row = { 172, 178, 148 }, Input = { 224, 230, 200 }, Accent = { 46, 60, 44 }, Ink = { 52, 64, 48 }, Cream = { 236, 242, 218 }, Line = { 146, 154, 124 }, Team = { 90, 130, 80 } },
    Rose = { Paper = { 222, 200, 196 }, Row = { 200, 172, 170 }, Input = { 244, 226, 222 }, Accent = { 92, 48, 56 }, Ink = { 86, 52, 58 }, Cream = { 250, 236, 232 }, Line = { 176, 148, 148 }, Team = { 170, 80, 100 } },
    Slate = { Paper = { 190, 196, 200 }, Row = { 164, 172, 178 }, Input = { 218, 224, 228 }, Accent = { 44, 52, 60 }, Ink = { 48, 56, 64 }, Cream = { 232, 238, 242 }, Line = { 140, 148, 154 }, Team = { 70, 110, 150 } },
    Night = { Paper = { 52, 50, 44 }, Row = { 70, 68, 60 }, Input = { 34, 33, 29 }, Accent = { 24, 23, 20 }, Ink = { 222, 216, 192 }, Cream = { 236, 230, 206 }, Line = { 96, 92, 80 }, Team = { 150, 140, 100 } },
    Ocean = { Paper = { 184, 200, 208 }, Row = { 154, 174, 184 }, Input = { 214, 228, 234 }, Accent = { 34, 58, 74 }, Ink = { 38, 60, 74 }, Cream = { 226, 240, 246 }, Line = { 130, 154, 166 }, Team = { 60, 120, 160 } },
    Sakura = { Paper = { 236, 214, 218 }, Row = { 214, 184, 192 }, Input = { 250, 236, 240 }, Accent = { 120, 60, 84 }, Ink = { 104, 56, 72 }, Cream = { 255, 240, 244 }, Line = { 196, 162, 172 }, Team = { 210, 110, 140 } },
    Ember = { Paper = { 206, 182, 160 }, Row = { 184, 154, 128 }, Input = { 230, 210, 190 }, Accent = { 96, 42, 28 }, Ink = { 88, 46, 32 }, Cream = { 250, 232, 214 }, Line = { 160, 130, 108 }, Team = { 196, 92, 52 } },
    Lavender = { Paper = { 206, 200, 222 }, Row = { 182, 174, 204 }, Input = { 232, 228, 244 }, Accent = { 62, 50, 94 }, Ink = { 62, 52, 92 }, Cream = { 240, 236, 252 }, Line = { 160, 152, 184 }, Team = { 130, 100, 190 } },
    Sand = { Paper = { 222, 208, 176 }, Row = { 200, 184, 148 }, Input = { 240, 230, 204 }, Accent = { 104, 82, 40 }, Ink = { 92, 74, 40 }, Cream = { 255, 246, 218 }, Line = { 178, 162, 124 }, Team = { 190, 150, 70 } },
    Mint = { Paper = { 200, 222, 212 }, Row = { 170, 200, 186 }, Input = { 226, 244, 236 }, Accent = { 34, 76, 62 }, Ink = { 38, 70, 58 }, Cream = { 232, 250, 242 }, Line = { 142, 176, 160 }, Team = { 70, 170, 130 } },
    Forest = { Paper = { 40, 52, 44 }, Row = { 58, 74, 62 }, Input = { 26, 34, 28 }, Accent = { 18, 26, 20 }, Ink = { 200, 222, 200 }, Cream = { 226, 244, 226 }, Line = { 84, 104, 88 }, Team = { 110, 160, 110 } },
    Midnight = { Paper = { 34, 40, 56 }, Row = { 50, 58, 80 }, Input = { 22, 26, 38 }, Accent = { 16, 20, 32 }, Ink = { 198, 208, 234 }, Cream = { 222, 230, 250 }, Line = { 76, 86, 116 }, Team = { 100, 130, 210 } },
    Crimson = { Paper = { 56, 34, 38 }, Row = { 78, 48, 54 }, Input = { 36, 22, 24 }, Accent = { 30, 14, 18 }, Ink = { 236, 206, 208 }, Cream = { 250, 226, 228 }, Line = { 108, 70, 76 }, Team = { 200, 70, 80 } },
    Mono = { Paper = { 44, 44, 46 }, Row = { 64, 64, 67 }, Input = { 28, 28, 30 }, Accent = { 16, 16, 18 }, Ink = { 220, 220, 224 }, Cream = { 240, 240, 244 }, Line = { 92, 92, 96 }, Team = { 160, 160, 170 } },
    Cyberpunk = { Paper = { 24, 18, 34 }, Row = { 46, 28, 58 }, Input = { 17, 14, 27 }, Accent = { 255, 45, 149 }, Ink = { 246, 222, 246 }, Cream = { 255, 242, 252 }, Line = { 114, 48, 112 }, Team = { 0, 245, 255 } },
    NeonViolet = { Paper = { 25, 20, 48 }, Row = { 47, 34, 83 }, Input = { 17, 14, 36 }, Accent = { 154, 83, 255 }, Ink = { 232, 222, 255 }, Cream = { 248, 242, 255 }, Line = { 91, 68, 155 }, Team = { 58, 232, 255 } },
    Arctic = { Paper = { 210, 231, 244 }, Row = { 177, 211, 232 }, Input = { 235, 247, 255 }, Accent = { 0, 116, 194 }, Ink = { 23, 55, 78 }, Cream = { 248, 253, 255 }, Line = { 105, 164, 198 }, Team = { 0, 166, 220 } },
    Toxic = { Paper = { 20, 29, 22 }, Row = { 37, 55, 39 }, Input = { 12, 20, 14 }, Accent = { 157, 255, 46 }, Ink = { 218, 255, 202 }, Cream = { 243, 255, 231 }, Line = { 72, 122, 58 }, Team = { 0, 255, 148 } },
    RoyalGold = { Paper = { 23, 29, 48 }, Row = { 39, 49, 76 }, Input = { 15, 20, 35 }, Accent = { 229, 183, 68 }, Ink = { 239, 231, 208 }, Cream = { 255, 248, 222 }, Line = { 115, 99, 69 }, Team = { 255, 211, 92 } },
    Synthwave = { Paper = { 38, 18, 53 }, Row = { 62, 31, 83 }, Input = { 24, 12, 38 }, Accent = { 255, 70, 190 }, Ink = { 250, 222, 250 }, Cream = { 255, 242, 255 }, Line = { 129, 57, 139 }, Team = { 63, 247, 224 } },
    Cobalt = { Paper = { 15, 27, 53 }, Row = { 27, 48, 86 }, Input = { 9, 17, 37 }, Accent = { 50, 128, 255 }, Ink = { 218, 234, 255 }, Cream = { 241, 248, 255 }, Line = { 62, 101, 172 }, Team = { 74, 221, 255 } },
    Inferno = { Paper = { 37, 19, 17 }, Row = { 64, 31, 24 }, Input = { 22, 12, 11 }, Accent = { 255, 100, 36 }, Ink = { 255, 223, 200 }, Cream = { 255, 244, 229 }, Line = { 139, 67, 42 }, Team = { 255, 47, 61 } },
    Aurora = { Paper = { 15, 38, 41 }, Row = { 25, 60, 61 }, Input = { 9, 25, 29 }, Accent = { 63, 242, 190 }, Ink = { 211, 255, 239 }, Cream = { 240, 255, 249 }, Line = { 63, 130, 123 }, Team = { 102, 181, 255 } },
    Voltage = { Paper = { 20, 22, 27 }, Row = { 39, 43, 52 }, Input = { 12, 14, 19 }, Accent = { 255, 230, 45 }, Ink = { 241, 244, 250 }, Cream = { 255, 252, 225 }, Line = { 95, 100, 111 }, Team = { 255, 54, 109 } },
}
local PresetOrder = { "Paper", "Dusk", "Moss", "Rose", "Slate", "Night", "Ocean", "Sakura", "Ember", "Lavender", "Sand", "Mint", "Forest", "Midnight", "Crimson", "Mono", "Cyberpunk", "NeonViolet", "Arctic", "Toxic", "RoyalGold", "Synthwave", "Cobalt", "Inferno", "Aurora", "Voltage" }
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
    cfgColor("InputColor", "Input")
    cfgColor("ThemeColor", "Accent")
    cfgColor("CategoryColor", "Accent")
    cfgColor("TextColor", "Ink")
    cfgColor("TeamColor", "Team")

    local GTrans = math.clamp(Config.ElementTransparency or 0.08, 0, 0.9)
    local FontScale = Config.FontScale or 1
    local OverallScalePercent = math.clamp(tonumber(Config.OverallScale) or 100, 70, 130)
    local ToggleButtonScalePercent = math.clamp(tonumber(Config.ToggleButtonScale) or 100, 50, 180)
    local mainUIScale, stripUIScale, toggleUIScale
    local FontFamily = (Config.FontFamily and FontPresets[Config.FontFamily]) and Config.FontFamily or "Gotham"
    local Language = "en"
    local cfgLang = Config.Language and string.lower(tostring(Config.Language))
    if cfgLang == "th" or cfgLang == "thai" then
        Language = "th"
    end
    local StripAnim = Config.StripAnimation ~= false

    -- Page Transition Style: Classic + 3 new styles
    --   Cascade    : rows fade in one after another while the page slides in from the left
    --   Glitch     : page jitters in and the text scrambles (like Classic, but with a glitch shake)
    --   Slide Left : the whole page slides in from the right while rows fade in
    local PageAnimationOrder = { "Classic", "Cascade", "Glitch", "Slide Left" }

    -- Window Open / Close Style: all options use the same strip-wipe animation family.
    --   Shutter       : straight vertical bars with a centered collapse
    --   Slash         : wide diagonal bars angled upward
    --   Pinstripe     : thin vertical bars with a quicker stagger
    --   Reverse Slash : wide diagonal bars angled in the opposite direction
    --   Crosscut      : alternating diagonal bars for a crossed-strip effect
    local OpenCloseAnimationOrder = { "Classic", "Shutter", "Slash", "Pinstripe", "Reverse Slash", "Crosscut" }

    local function containsOption(options, value)
        for _, option in ipairs(options) do
            if option == value then return true end
        end
        return false
    end
    local PageAnimation = "Classic"
    local OpenCloseAnimation = "Classic"
    StripAnim = true
    local CurrentPreset = (type(Config.Theme) == "string" and Presets[Config.Theme]) and Config.Theme or "Paper"
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
        StripAnim = true
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
    local function listColor(t)
        return t.Row:Lerp(t.Paper, 0.5)
    end
    local function dimInk(t)
        return t.Ink:Lerp(t.Paper, 0.45)
    end

    local gui = new("ScreenGui", {
        Name = "NIER_UI",
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
        error("[NierLibrary] Unable to parent ScreenGui. This executor may restrict GUI access.")
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

local TITLE_H = 22
local STRIP_H = 9
local SIDE_W = 0.29
local BODY_TOP = TITLE_H + STRIP_H

local top = new("Frame", { Name = "TopBar", Size = UDim2.new(1, 0, 0, TITLE_H), BorderSizePixel = 0, ZIndex = 3 }, main)
bind(top, "BackgroundColor3", function(t)
    return t.Accent:Lerp(t.Cream, 0.07)
end)

local titleX = 24
if Config.Logo and Config.Logo ~= "" then
    new("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0.5, -7),
        Size = UDim2.fromOffset(14, 14),
        Image = Config.Logo,
        ZIndex = 4,
    }, top)
titleX = 26
else
    local dia = new("Frame", {
        Position = UDim2.new(0, 8, 0.5, -4),
        Size = UDim2.fromOffset(8, 8),
        Rotation = 45,
        BorderSizePixel = 0,
        ZIndex = 4,
    }, top)
bind(dia, "BackgroundColor3", "Cream")
end

local titleLabel = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, titleX, 0, 0),
    Size = UDim2.new(1, -titleX - 30, 1, 0),
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
    Position = UDim2.new(1, -21, 0.5, -7),
    Size = UDim2.fromOffset(14, 14),
    Image = Icons["lucide-settings"] or "",
    ImageTransparency = 0.45,
    ZIndex = 5,
}, top)
bind(gearBtn, "ImageColor3", "Cream")
gearBtn.MouseEnter:Connect(function()
    tw(gearBtn, 0.12, { ImageTransparency = 0 })
end)
gearBtn.MouseLeave:Connect(function()
    tw(gearBtn, 0.12, { ImageTransparency = 0.45 })
end)

local function hline(parent, pos, size)
    local f = new("Frame", { Position = pos, Size = size, BorderSizePixel = 0, ZIndex = 2 }, parent)
    bind(f, "BackgroundColor3", "Line")
    return f
end

local function dotStrip(yPos)
    local strip = new("Frame", {
        Name = "DotStrip",
        BackgroundTransparency = 1,
        Position = yPos,
        Size = UDim2.new(1, 0, 0, STRIP_H),
        ClipsDescendants = true,
        ZIndex = 2,
    }, main)
local ln = new("Frame", { Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.35 }, strip)
bind(ln, "BackgroundColor3", "Line")
local CELL = 22
for i = 0, math.ceil(900 / CELL) do
    local cx = i * CELL + 11
    for _, d in ipairs({ { -3, 3 }, { 3, 3 }, { 0, 6 } }) do
        local dot = new("Frame", {
            Position = UDim2.fromOffset(cx + d[1], d[2]),
            Size = UDim2.fromOffset(1, 1),
            BorderSizePixel = 0,
            BackgroundTransparency = 0.45,
        }, strip)
    bind(dot, "BackgroundColor3", "Ink")
end
end
return strip
end
dotStrip(UDim2.fromOffset(0, TITLE_H))
dotStrip(UDim2.new(0, 0, 1, -STRIP_H))

local decor = new("Frame", {
    Name = "Decor",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ClipsDescendants = true,
    ZIndex = 0,
}, main)
local function decoLine(pos, length, rot)
    local f = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = pos,
        Size = UDim2.fromOffset(length, 1),
        Rotation = rot,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.8,
        ZIndex = 0,
    }, decor)
bind(f, "BackgroundColor3", "Line")
end
local function decoArc(pos, diameter)
    local c = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = pos,
        Size = UDim2.fromOffset(diameter, diameter),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 0,
    }, decor)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, c)
local s = new("UIStroke", { Thickness = 1, Transparency = 0.7 }, c)
bind(s, "Color", "Line")
end
decoLine(UDim2.new(0.26, 0, 0.43, 0), 320, 60)
decoLine(UDim2.new(0.26, 14, 0.43, 0), 320, 60)
decoLine(UDim2.new(0.73, 0, 0.64, 0), 270, 42)
decoLine(UDim2.new(0.8, 20, 0.7, 0), 200, 40)
decoArc(UDim2.new(1, 0, 1, -4), 200)
decoArc(UDim2.new(1, 0, 1, -4), 218)

local body = new("Frame", {
    Name = "Body",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, BODY_TOP),
    Size = UDim2.new(1, 0, 1, -(BODY_TOP + STRIP_H)),
}, main)

local Sidebar = new("ScrollingFrame", {
    Name = "Sidebar",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(SIDE_W, 0, 1, 0),
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, body)
new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 13) }, Sidebar)
new("UIPadding", { PaddingTop = UDim.new(0, 20), PaddingBottom = UDim.new(0, 10) }, Sidebar)

local divider = new("Frame", {
    Name = "Divider",
    Position = UDim2.new(SIDE_W, 0, 0, 0),
    Size = UDim2.new(0, 9, 1, 0),
    BorderSizePixel = 0,
    BackgroundTransparency = 0.55,
    ZIndex = 2,
}, body)
bind(divider, "BackgroundColor3", "Line")
hline(divider, UDim2.fromOffset(0, 0), UDim2.new(0, 1, 1, 0))
hline(divider, UDim2.fromOffset(8, 0), UDim2.new(0, 1, 1, 0))

local ContentContainer = new("Frame", {
    Name = "ContentContainer",
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Position = UDim2.new(SIDE_W, 9, 0, 0),
    Size = UDim2.new(1 - SIDE_W, -9, 1, 0),
}, body)

local rail = new("Frame", {
    Name = "Rail",
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -15, 0, 14),
    Size = UDim2.new(0, 9, 1, -22),
    ZIndex = 5,
}, ContentContainer)
local railStroke = new("UIStroke", { Thickness = 1 }, rail)
bind(railStroke, "Color", "Line")

makeDraggable(top, main, function()
    save()
end, function()
return OverallScalePercent / 100
end)

local resizeBtn = new("TextButton", {
    Name = "ResizeBtn",
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -15, 1, -15),
    Size = UDim2.fromOffset(15, 15),
    Text = "◢",
    TextTransparency = 0.55,
    ZIndex = 10,
}, main)
bindFont(resizeBtn, 11, true)
bind(resizeBtn, "TextColor3", "Accent")
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
            math.clamp(startAbs.X + d.X / scaleFactor, 360, 900),
            math.clamp(startAbs.Y + d.Y / scaleFactor, 240, 650)
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

-- Strip-wipe variants (Window Open / Close Style).
-- Each style uses the same strip system; settings control the strip count, angle, width and timing.
--   n               : number of strips
--   angle           : strip rotation in degrees
--   alternateAngle  : optional angle used on every second strip
--   barW            : strip width as a fraction of the window width
--   fixedR          : collapse each strip to this height (0..1) instead of a random one
--   step            : seconds between strips (sequential). Without it the timing is random
--   dynamicPad      : widen the strip range so angled strips still cover the whole window
local StripVariants = {
    Classic = { n = 9, angle = -13, barW = 0.22 },
    Shutter = { n = 12, angle = 0, barW = 0.2, fixedR = 0.5, step = 0.018, dynamicPad = true },
    Slash = { n = 7, angle = 24, barW = 0.3, dynamicPad = true },
    Pinstripe = { n = 16, angle = 0, barW = 0.095, step = 0.012, dynamicPad = true },
    ["Reverse Slash"] = { n = 8, angle = -27, barW = 0.27, dynamicPad = true },
    Crosscut = { n = 10, angle = 27, alternateAngle = -27, barW = 0.23, step = 0.015, dynamicPad = true },
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
        local pad = 0.5 * H * math.abs(math.tan(math.rad(variant.angle))) + 0.1 * W
        x0, x1 = -pad, W + pad
    else
        x0, x1 = -0.08 * W, 1.12 * W
    end

    local list = {}
    for i = 1, n do
        local r
        if variant.fixedR then
            r = variant.fixedR
        elseif variant.rByIndex then
            r = 0.1 + 0.8 * ((i - 1) / math.max(n - 1, 1))
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
        Size = UDim2.fromOffset(W * variant.barW, H * 1.8),
        Rotation = stripAngle,
        BackgroundColor3 = Theme.Paper,
        BackgroundTransparency = collapsed and 0 or 1,
    }, band)
local stroke = new("UIStroke", {
    Thickness = 1,
    Color = Theme.Line,
    Transparency = collapsed and 0.4 or 1,
}, bar)
local delay = variant.step and ((i - 1) * variant.step) or rng:NextNumber(0, 0.22)
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

    if opening then

        for _, s in ipairs(list) do
            task.delay(s.delay, function()
                TweenService:Create(s.band, grow, { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(W, H) }):Play()
                TweenService:Create(s.bar, grow, { Position = UDim2.fromOffset(s.xc, H / 2) }):Play()
            end)
        end

        task.delay(maxDelay + 0.33, function()
            main.Visible = true
            for i, s in ipairs(list) do
                task.delay((i - 1) * 0.035, function()
                    TweenService:Create(s.bar, fade, { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(s.stroke, fade, { Transparency = 1 }):Play()
                end)
            end
            task.delay(#list * 0.035 + 0.36, finish)
        end)
    else

        for i, s in ipairs(list) do
            task.delay((#list - i) * 0.03, function()
                TweenService:Create(s.bar, quick, { BackgroundTransparency = 0 }):Play()
                TweenService:Create(s.stroke, quick, { Transparency = 0.4 }):Play()
            end)
        end

        task.delay(#list * 0.03 + 0.24, function()
            main.Visible = false
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

local function offsetUDim2(position, dx, dy)
    return UDim2.new(position.X.Scale, position.X.Offset + dx, position.Y.Scale, position.Y.Offset + dy)
end

local function scaleUDim2(size, factor)
    return UDim2.new(size.X.Scale * factor, size.X.Offset * factor, size.Y.Scale * factor, size.Y.Offset * factor)
end

local function collectTransparencyTargets(root)
    local targets = {}
    local objects = { root }
    for _, descendant in ipairs(root:GetDescendants()) do
        table.insert(objects, descendant)
    end
    for _, object in ipairs(objects) do
        local props = {}
        if object:IsA("GuiObject") then
            props.BackgroundTransparency = object.BackgroundTransparency
        end
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            props.TextTransparency = object.TextTransparency
            props.TextStrokeTransparency = object.TextStrokeTransparency
        end
        if object:IsA("ImageLabel") or object:IsA("ImageButton") then
            props.ImageTransparency = object.ImageTransparency
        end
        if object:IsA("ScrollingFrame") then
            props.ScrollBarImageTransparency = object.ScrollBarImageTransparency
        end
        if object:IsA("UIStroke") then
            props.Transparency = object.Transparency
        end
        for property, value in pairs(props) do
            if type(value) == "number" and value < 0.999 then
                table.insert(targets, { instance = object, property = property, value = value })
            end
        end
    end
    table.sort(targets, function(a, b)
        local ay = a.instance:IsA("GuiObject") and a.instance.AbsolutePosition.Y or 0
        local by = b.instance:IsA("GuiObject") and b.instance.AbsolutePosition.Y or 0
        return ay < by
    end)
    return targets
end

local function restoreTransparencyTargets(targets)
    for _, target in ipairs(targets) do
        if target.instance and target.instance.Parent then
            pcall(function() target.instance[target.property] = target.value end)
        end
    end
end

local function playWindowStyle(shouldOpen, style)
    if style == "None" then
        main.Visible = shouldOpen
        return
    end

    animating = true
    local basePosition = main.Position
    local baseSize = main.Size
    local width = math.max(main.AbsoluteSize.X, baseSize.X.Offset, 1)
    local height = math.max(main.AbsoluteSize.Y, baseSize.Y.Offset, 1)
    local duration = (style == "Glitch" and 0.34) or (style == "Pop" and 0.38) or 0.30
    local motionPosition = basePosition
    local motionSize = baseSize

    if style == "Slide Left" then
        motionPosition = offsetUDim2(basePosition, -width * 0.88, 0)
    elseif style == "Slide Right" then
        motionPosition = offsetUDim2(basePosition, width * 0.88, 0)
    elseif style == "Slide Up" then
        motionPosition = offsetUDim2(basePosition, 0, -height * 0.88)
    elseif style == "Slide Down" then
        motionPosition = offsetUDim2(basePosition, 0, height * 0.88)
    elseif style == "Glitch" then
        motionPosition = offsetUDim2(basePosition, -18, 3)
    elseif style == "Zoom" or style == "Pop" then
        local factor = style == "Pop" and 0.78 or 0.88
        motionSize = scaleUDim2(baseSize, factor)
        motionPosition = offsetUDim2(basePosition, width * (1 - factor) / 2, height * (1 - factor) / 2)
    end

    local transparencyTargets = collectTransparencyTargets(main)
    if shouldOpen then
        main.Visible = true
        main.Position = (style == "Fade") and basePosition or motionPosition
        main.Size = (style == "Zoom" or style == "Pop") and motionSize or baseSize
        for _, target in ipairs(transparencyTargets) do
            if target.instance and target.instance.Parent then
                pcall(function() target.instance[target.property] = 1 end)
            end
        end

        local easingStyle = style == "Pop" and Enum.EasingStyle.Back or (style == "Zoom" and Enum.EasingStyle.Quint or Enum.EasingStyle.Quart)
        local info = TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out)
        local motion = TweenService:Create(main, info, { Position = basePosition, Size = baseSize })
        motion:Play()
        for index, target in ipairs(transparencyTargets) do
            if target.instance and target.instance.Parent then
                local fadeInfo = TweenInfo.new(style == "Glitch" and 0.18 or duration * 0.86, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(target.instance, fadeInfo, { [target.property] = target.value })
                if style == "Glitch" then
                    task.delay((index - 1) % 4 * 0.018, function()
                        if animating and target.instance and target.instance.Parent then tween:Play() end
                    end)
                else
                    tween:Play()
                end
            end
        end
        if style == "Glitch" then
            task.delay(0.05, function()
                if animating and main.Parent then
                    TweenService:Create(main, TweenInfo.new(0.07, Enum.EasingStyle.Linear), { Position = offsetUDim2(basePosition, 10, -2) }):Play()
                end
            end)
            task.delay(0.13, function()
                if animating and main.Parent then
                    TweenService:Create(main, TweenInfo.new(0.09, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = basePosition }):Play()
                end
            end)
        end
        task.delay(duration + 0.08, function()
            if main.Parent then
                main.Position = basePosition
                main.Size = baseSize
            end
            animating = false
            flushPendingThemeAction()
        end)
    else
        local outPosition = (style == "Fade") and basePosition or motionPosition
        local outSize = (style == "Zoom" or style == "Pop") and motionSize or baseSize
        local easingStyle = style == "Pop" and Enum.EasingStyle.Back or Enum.EasingStyle.Quad
        local info = TweenInfo.new(duration * 0.82, easingStyle, Enum.EasingDirection.In)
        local motion = TweenService:Create(main, info, { Position = outPosition, Size = outSize })
        motion:Play()
        for _, target in ipairs(transparencyTargets) do
            if target.instance and target.instance.Parent then
                TweenService:Create(target.instance, TweenInfo.new(duration * 0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { [target.property] = 1 }):Play()
            end
        end
        if style == "Glitch" then
            task.delay(0.08, function()
                if animating and main.Parent then
                    TweenService:Create(main, TweenInfo.new(0.06, Enum.EasingStyle.Linear), { Position = offsetUDim2(basePosition, 12, -2) }):Play()
                end
            end)
        end
        task.delay(duration + 0.02, function()
            if main.Parent then
                main.Visible = false
                main.Position = basePosition
                main.Size = baseSize
                restoreTransparencyTargets(transparencyTargets)
            end
            animating = false
            flushPendingThemeAction()
        end)
    end
end

local function SetWindowOpen(shouldOpen)
    if animating or shouldOpen == main.Visible then
        return
    end

    if Library._reloadAllSfx then
        Library._reloadAllSfx()
    end
    if Library._sfx then
        Library._sfx(shouldOpen and "open" or "close")
    end

    local stripVariant = StripVariants[OpenCloseAnimation]
    if stripVariant then
        animating = true
        playStrips(shouldOpen, stripVariant)
        return
    end
    playWindowStyle(shouldOpen, OpenCloseAnimation)
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
        warn("[NierLibrary] Theme transition failed: " .. tostring(err))
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
    local t = new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = ToggleConfig.Text or "◆",
        ZIndex = 3,
    }, parent)
bindFont(t, size, true)
bind(t, "TextColor3", colorToken)
return t
end

if style == "Circle" then

    toggleBtn.Size = UDim2.fromOffset(46, 46)
    local disc = new("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0 }, tbVisual)
    bind(disc, "BackgroundColor3", "Accent")
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, disc)
    local st = new("UIStroke", { Thickness = 2 }, disc)
    bind(st, "Color", "Line")
    local ring = new("Frame", {
        AnchorPoint = CENTER,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, -10, 1, -10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, disc)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, ring)
local rs = new("UIStroke", { Thickness = 1, Transparency = 0.55 }, ring)
bind(rs, "Color", "Cream")
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
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, pill)
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
    Text = ToggleConfig.Text or "MENU",
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

toggleBtn.Visible = isMobile
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
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 20, 1, -20),
    Size = UDim2.fromOffset(460, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
}, gui)
new("UIListLayout", {
    Padding = UDim.new(0, 6),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    SortOrder = Enum.SortOrder.LayoutOrder,
}, toastHolder)

local function Notify(text, duration)
    text = tostring(text)
    local lab = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(16, 0),
        Text = text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 2,
    })
bindFont(lab, 14, false)
bind(lab, "TextColor3", "Ink")
local okW, sz = pcall(function()
    return TextService:GetTextSize(text, lab.TextSize, lab.Font, Vector2.new(600, 40))
end)
local w = math.clamp((okW and sz.X or 260) + 38, 200, 460)

local slot = new("Frame", {
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Size = UDim2.fromOffset(w, 36),
}, toastHolder)
local card = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    Position = UDim2.fromScale(-1, 0),
    BorderSizePixel = 0,
}, slot)
bind(card, "BackgroundColor3", function(t)
    return t.Paper:Lerp(t.Cream, 0.12)
end)
local cardStroke = new("UIStroke", { Thickness = 1 }, card)
bind(cardStroke, "Color", "Line")
local bar =new("Frame", { Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0, ZIndex = 2 }, card)
bind(bar, "BackgroundColor3", "Accent")
lab.Size = UDim2.new(1, -24, 1, 0)
lab.Parent = card

TweenService:Create(card, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.fromScale(0, 0),
}):Play()
task.delay(duration or 3, function()
    if slot.Parent then
        local out = TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.fromScale(-1, 0),
        })
    out:Play()
    out.Completed:Wait()
    slot:Destroy()
end
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

local function AnimatePageIn(page)
    if not page then return end
    cancelPageAnimation(page)

    local basePos = page:GetAttribute("BasePosition")
    if not basePos then
        basePos = page.Position
        page:SetAttribute("BasePosition", basePos)
    end

    if PageAnimation ~= "Cipher" and PageAnimation ~= "Classic" then
        local style = PageAnimation
        page.Position = basePos
        if style == "None" then
            return
        end

        local width = math.max(page.AbsoluteSize.X, 1)
        local height = math.max(page.AbsoluteSize.Y, 1)
        local startPosition = basePos
        if style == "Slide Left" then
            startPosition = offsetUDim2(basePos, width * 0.075, 0)
        elseif style == "Slide Right" then
            startPosition = offsetUDim2(basePos, -width * 0.075, 0)
        elseif style == "Slide Up" then
            startPosition = offsetUDim2(basePos, 0, height * 0.075)
        elseif style == "Slide Down" then
            startPosition = offsetUDim2(basePos, 0, -height * 0.075)
        elseif style == "Cascade" then
            startPosition = offsetUDim2(basePos, -width * 0.05, 0)
        elseif style == "Glitch" then
            startPosition = offsetUDim2(basePos, -14, 2)
        end

        local state = { tweens = {}, originals = {}, cancelled = false, basePosition = basePos, textEntries = {} }
        pageAnimationStates[page] = state
        local scaleTween
        if style == "Zoom" or style == "Pop" then
            local scaleObject = Instance.new("UIScale")
            scaleObject.Name = "NierPageTransitionScale"
            scaleObject.Scale = style == "Pop" and 0.78 or 0.90
            scaleObject.Parent = page
            state.scaleObject = scaleObject
            scaleTween = TweenService:Create(scaleObject, TweenInfo.new(0.30, style == "Pop" and Enum.EasingStyle.Back or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Scale = 1 })
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
        for _, child in ipairs(page:GetChildren()) do
            if child:IsA("GuiObject") and child ~= state.scaleObject then
                table.insert(items, child)
            end
        end
        table.sort(items, function(a, b)
            if a.LayoutOrder == b.LayoutOrder then
                return a.AbsolutePosition.Y < b.AbsolutePosition.Y
            end
            return a.LayoutOrder < b.LayoutOrder
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

        local stagger = style == "Cascade" and 0.045 or 0.018
        local fadeInfo = TweenInfo.new(style == "Glitch" and 0.18 or 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        for index, item in ipairs(items) do
            local targets = itemTargets[index]
            local textTargets = itemTextTargets[index]
            task.delay((style == "Fade" and 0 or (index - 1) * stagger), function()
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
        return
    end

    page.Position = UDim2.new(basePos.X.Scale, basePos.X.Offset, basePos.Y.Scale, basePos.Y.Offset + 10)
    local pageSlideTween = TweenService:Create(
    page,
    TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    { Position = basePos }
    )

    local items = {}
    for _, child in ipairs(page:GetChildren()) do
        if child:IsA("GuiObject") then
            table.insert(items, child)
        end
    end
    table.sort(items, function(a, b)
        if a.LayoutOrder == b.LayoutOrder then
            return a.AbsolutePosition.Y < b.AbsolutePosition.Y
        end
        return a.LayoutOrder < b.LayoutOrder
    end)

    local state = { tweens = { pageSlideTween }, originals = {}, cancelled = false, basePosition = basePos }
    pageAnimationStates[page] = state
    pageSlideTween:Play()
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
            local canFade = (object:IsA("GuiObject") and object.Visible)
            or (object:IsA("UIStroke") and object.Enabled)
            if canFade then
                local properties = getFadeProperties(object)
                for property, originalValue in pairs(properties) do
                    if type(originalValue) == "number" and originalValue < 0.999 then
                        local target = {
                            instance = object,
                            property = property,
                            value = originalValue,
                        }
                    table.insert(state.originals, target)
                    table.insert(targets, target)
                    pcall(function()
                        object[property] = 1
                    end)
                end
            end
        end

        if (object:IsA("TextLabel") or object:IsA("TextButton"))
        and object.Visible
        and object.Text ~= ""
        and not object.RichText then
            table.insert(textTargets, {
                instance = object,
                target = object.Text,
                lastRendered = nil,
            })
    end
end
table.insert(itemTargets, targets)
table.insert(itemTextTargets, textTargets)
end

state.textEntries = {}
for _, entries in ipairs(itemTextTargets) do
    for _, entry in ipairs(entries) do
        table.insert(state.textEntries, entry)
    end
end

local stagger = 0.035
local fadeInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
for index, item in ipairs(items) do
    local targets = itemTargets[index]
    local textTargets = itemTextTargets[index]
    task.delay((index - 1) * stagger, function()
        if pageAnimationStates[page] ~= state or state.cancelled or not page.Visible then
            return
        end
        for _, target in ipairs(targets) do
            if target.instance.Parent then
                local tween = TweenService:Create(target.instance, fadeInfo, {
                    [target.property] = target.value,
                })
            table.insert(state.tweens, tween)
            tween:Play()
        end
    end
    for _, entry in ipairs(textTargets) do
        task.spawn(scramblePageText, entry, state, page)
    end
end)
end

task.delay(math.max(#items - 1, 0) * stagger + 0.75, function()
    if pageAnimationStates[page] == state then
        pageAnimationStates[page] = nil
    end
end)
end

local WindowElements = {}

function WindowElements:OpenSettings() OpenSettingsFn() end
function WindowElements:CloseSettings() CloseSettingsFn() end
function WindowElements:ToggleSettings() ToggleSettingsVisibility() end

function WindowElements:CreateCategory(CategoryName, IconName, Hidden)
    local CategoryElements = {}

    local btn = new("TextButton", {
        Name = CategoryName,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Visible = not Hidden,
    }, Sidebar)
btn:SetAttribute("CategorySelected", false)

local tabFill = new("Frame", {
    Name = "Fill",
    Size = UDim2.new(1, -16, 1, 0),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 1,
}, btn)
bind(tabFill, "BackgroundColor3", "Row")
local tabWipe = new("Frame", { Name = "Wipe", Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 }, tabFill)
bind(tabWipe, "BackgroundColor3", "Accent")
local selLineTop = new("Frame", {
    Position = UDim2.new(0, 0, 0, -3), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, Visible = false,
}, btn)
local selLineBot = new("Frame", {
    Position = UDim2.new(0, 0, 1, 2), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, Visible = false,
}, btn)
bind(selLineTop, "BackgroundColor3", "Accent")
bind(selLineBot, "BackgroundColor3", "Accent")

local catAsset = resolveIcon(IconName)
local catMarker
if catAsset then
    catMarker = new("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 5, 0.5, -8),
        Size = UDim2.fromOffset(16, 16),
        Image = catAsset,
        ZIndex = 2,
    }, btn)
else
    catMarker = new("Frame", {
        Position = UDim2.new(0, 6, 0.5, -6),
        Size = UDim2.fromOffset(12, 12),
        BorderSizePixel = 0,
        ZIndex = 2,
    }, btn)
end
local catLabel = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, catAsset and 28 or 25, 0, 0),
    Size = UDim2.new(1, -(catAsset and 44 or 41), 1, 0),
    Text = CategoryName,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 2,
}, btn)
bindFont(catLabel, 13, false)

local catHover = false
local function catLook(animate)
    local selected = btn:GetAttribute("CategorySelected") == true
    local dur = animate and 0.16 or 0
    local lit = selected or catHover
    tw(tabFill, dur, { Size = selected and UDim2.new(1, 0, 1, 0) or UDim2.new(1, -16, 1, 0) })
    tw(tabWipe, dur, { Size = lit and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0) })
    selLineTop.Visible = selected
    selLineBot.Visible = selected
    tw(catLabel, dur, { TextColor3 = lit and Theme.Cream or Theme.Ink })
    local markCol = lit and Theme.Cream or Theme.Accent
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

local CategoryPage = new("ScrollingFrame", {
    Name = CategoryName .. "Page",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Visible = false,
}, ContentContainer)
new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7) }, CategoryPage)
new("UIPadding", {
    PaddingLeft = UDim.new(0, 22), PaddingRight = UDim.new(0, 40),
    PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 14),
}, CategoryPage)

local heading = new("Frame", {
    Name = "Heading",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 36),
    LayoutOrder = 0,
}, CategoryPage)
local headShadow = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(-9, 2),
    Size = UDim2.new(1, 11, 1, 0),
    Text = CategoryName,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTransparency = 0.5,
}, heading)
bindFont(headShadow, 24, false)
bind(headShadow, "TextColor3", function(t)
    return t.Line:Lerp(t.Ink, 0.15)
end)
local headLabel = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(-11, 0),
    Size = UDim2.new(1, 11, 1, 0),
    Text = CategoryName,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 2,
}, heading)
bindFont(headLabel, 24, false)
bind(headLabel, "TextColor3", "Ink")

local railThumb = new("Frame", {
    Name = CategoryName .. "Thumb",
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 6,
}, rail)
bind(railThumb, "BackgroundColor3", "Accent")
local function syncThumb()
    local canvas, view = CategoryPage.AbsoluteCanvasSize.Y, CategoryPage.AbsoluteWindowSize.Y
    if not CategoryPage.Visible or canvas <= view + 1 then
        railThumb.Visible = false
        return
    end
    local h = math.clamp(view / canvas, 0.1, 1)
    local maxScroll = math.max(canvas - view, 1)
    local y = math.clamp(CategoryPage.CanvasPosition.Y / maxScroll, 0, 1) * (1 - h)
    railThumb.Size = UDim2.new(1, -4, h, 0)
    railThumb.Position = UDim2.new(0, 2, y, 0)
    railThumb.Visible = true
end
CategoryPage:GetPropertyChangedSignal("CanvasPosition"):Connect(syncThumb)
CategoryPage:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(syncThumb)
CategoryPage:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(syncThumb)
CategoryPage:GetPropertyChangedSignal("Visible"):Connect(syncThumb)

local order = 0
local function nextOrder()
    order += 1
    return order
end

local function SelectTab()
    SettingsState.open = false
    for _, page in ipairs(ContentContainer:GetChildren()) do
        if page:IsA("ScrollingFrame") then
            cancelPageAnimation(page)
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

local function addMarker(parent, iconName)
    local asset = resolveIcon(iconName)
    if asset then
        local img = new("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 7, 0.5, -8),
            Size = UDim2.fromOffset(16, 16),
            Image = asset,
        }, parent)
    return img, true
end
local sq = new("Frame", {
    Position = UDim2.new(0, 7, 0.5, -6),
    Size = UDim2.fromOffset(12, 12),
    BorderSizePixel = 0,
}, parent)
local st = new("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, sq)
bind(st, "Color", "Accent")
return sq, false
end

local function addLabel(parent, text, x, scale, reserve)
    x = x - 6
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
new("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.8, 0),
        NumberSequenceKeypoint.new(1, 0.55),
    }),
}, wipe)

local dia, tail
if not o.noDiamond then
    dia = new("Frame", {
        Position = UDim2.new(0, -15, 0.5, -3),
        Size = UDim2.fromOffset(6, 6),
        Rotation = 45,
        BorderSizePixel = 0,
        Visible = false,
    }, o.row)
tail = new("Frame", {
    Position = UDim2.new(0, -21, 0.5, 0),
    Size = UDim2.fromOffset(5, 1),
    BorderSizePixel = 0,
    Visible = false,
}, o.row)
local function markColor(t)
    return t.Line:Lerp(t.Accent, 0.55)
end
bind(dia, "BackgroundColor3", markColor)
bind(tail, "BackgroundColor3", markColor)
end

local function look(animate)
    local h = state.hover
    local dur = animate and 0.14 or 0
    tw(wipe, dur, { Size = h and fullSize or emptySize })
    for _, l in ipairs(o.labels) do
        tw(l, dur, { TextColor3 = h and Theme.Cream or (o.color or Theme.Ink) })
    end
    local active = o.active and o.active() or false
    if o.hasIcon then
        o.marker.ImageColor3 = h and Theme.Cream or Theme.Accent
    else
        o.marker.BackgroundColor3 = (h or active) and Theme.Cream or Theme.Accent
    end
    if dia then
        dia.Visible = h
        tail.Visible = h
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
return tb
end

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
    local state, look, wipe = hoverable({
        row = row, marker = marker, hasIcon = hasIcon, labels = { lbl }, color = TextColor,
    })

row.MouseButton1Click:Connect(function()
    wipe.BackgroundColor3 = Theme.Accent:Lerp(Theme.Cream, 0.35)
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
        lbl.Text = tostring(t)
    end,
}
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
    local lbl = addLabel(row, TextboxText, hasIcon and 32 or 30, 1, 158)
    bind(lbl, "TextColor3", "Ink")
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
    PlaceholderText = Placeholder or "Search",
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
    local badge = new("TextLabel", {
        Position = UDim2.new(0, 7, 0.5, -7),
        Size = UDim2.fromOffset(18, 14),
        BorderSizePixel = 0,
    }, row)
bind(badge, "BackgroundColor3", "Accent")
bind(badge, "TextColor3", "Cream")
bindFont(badge, 10, true)

local iconImg
local asset = resolveIcon(IconName)
if asset then
    iconImg = new("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(16, 16),
        Image = asset,
    }, row)
bind(iconImg, "ImageColor3", "Accent")
end
local lbl = addLabel(row, SliderText, 36, 0.6)
bind(lbl, "TextColor3", "Ink")

local function layout()
    local bw = math.max(16, 8 + 6 * #badge.Text)
    badge.Size = UDim2.fromOffset(bw, 14)
    local x = 7 + bw + 8
    if iconImg then
        iconImg.Position = UDim2.new(0, x, 0.5, -8)
        x = x + 22
    end
    lbl.Position = UDim2.new(0, x, 0, 0)
    lbl.Size = UDim2.new(1, -(x + 140), 1, 0)
end

local track = new("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -16, 0.5, 0),
    Size = UDim2.new(0.3, 0, 0, 22),
    BackgroundTransparency = 1,
    Active = true,
}, row)
new("UISizeConstraint", { MinSize = Vector2.new(72, 22), MaxSize = Vector2.new(120, 22) }, track)

local N = 32
local ticks, dots = {}, {}
for i = 1, N do
    local px = (i - 0.5) / N
    dots[i] = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(px, 0, 0.5, 0),
        Size = UDim2.fromOffset(1, 1),
        BorderSizePixel = 0,
    }, track)
ticks[i] = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(px, 0, 0.5, 0),
    Size = UDim2.fromOffset(1, 8),
    BorderSizePixel = 0,
}, track)
end
local thumb = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.fromOffset(2, 12),
    BorderSizePixel = 0,
    ZIndex = 2,
}, track)
bind(thumb, "BackgroundColor3", "Ink")

local function render()
    local f = (Max == Min) and 0 or (value - Min) / (Max - Min)
    badge.Text = tostring(value)
    layout()
    thumb.Position = UDim2.new(f, 0, 0.5, 0)
    for i = 1, N do
        local filled = ((i - 0.5) / N) <= f
        ticks[i].BackgroundColor3 = Theme.Ink
        ticks[i].BackgroundTransparency = filled and 0 or 1
        dots[i].BackgroundColor3 = Theme.Ink
        dots[i].BackgroundTransparency = filled and 1 or 0.35
    end
end
render()
table.insert(lookers, { row = row, fn = render })

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
    labels = { lbl, hexLbl }, noDiamond = true, wipeHeight = 28,
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
    labels = { lbl, arrow }, noDiamond = true, wipeHeight = 28,
})

local function headerText()
    if multi then
        return text .. " : " .. (#selOrder == 0 and "None" or joinList(selOrder))
    end
    return text .. " : " .. (currentVal ~= nil and tostring(currentVal) or "")
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
    PlaceholderText = "Search",
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
            for _, child in ipairs(SettingsPage:GetChildren()) do
                if not (child:IsA("UIListLayout") or child:IsA("UIPadding") or child.Name == "Heading") then
                    child:Destroy()
                end
            end

            SettingsTab:CreateLabel(T.PresetHeader, "lucide-palette")
            SettingsTab:CreateDropdown(T.PresetLabel, "lucide-palette", PresetOrder, CurrentPreset, nil, function(selected)
                applyPreset(selected)
            end)

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

            SettingsTab:CreateSlider(T.OverallScaleLabel, "lucide-scaling", 70, 130, OverallScalePercent, "OverallScalePercent", function(v)
                SetOverallScale(v)
            end)

            SettingsTab:CreateSlider(T.TransparencyLabel, "lucide-glasses", 0, 90, TransPercent, function(v)
                TransPercent = v
                setGlass(v / 100)
                persistTheme()
            end)

            SettingsTab:CreateSlider(T.SoundVolumeLabel, "lucide-volume-2", 0, 100, math.floor(Library.SoundVolume * 100 + 0.5), function(v)
                Library:SetSoundVolume(v / 100)
                persistTheme()

                volumeSaveToken += 1
                local token = volumeSaveToken
                task.delay(0.5, function()
                    if token == volumeSaveToken then
                        save()
                    end
                end)
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
