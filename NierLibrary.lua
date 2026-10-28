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

-- Executor compatibility: filesystem APIs are optional and may be missing or restricted.
local function getExecutorFunction(name)
    local ok, value = pcall(function()
        return _G and _G[name] or nil
    end)
    if ok and type(value) == "function" then
        return value
    end
    -- Some executors expose APIs as environment globals rather than _G entries.
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

    -- Save the base dimensions, not AbsoluteSize, because UIScale changes the rendered size.
    local data = {
        Width = baseSize.X.Scale == 0 and baseSize.X.Offset or absoluteSize.X,
        Height = baseSize.Y.Scale == 0 and baseSize.Y.Offset or absoluteSize.Y,
    }
    if pos.X < 0 or pos.Y < 0 or pos.X + absoluteSize.X > viewport.X or pos.Y + absoluteSize.Y > viewport.Y then
        data.PosScaleX, data.PosScaleY = 0.5, 0.5
        data.PosX = -(baseSize.X.Offset / 2)
        data.PosY = -(baseSize.Y.Offset / 2)
    else
        -- Preserve UDim2 scale/offset values so the window stays in place at any UI scale.
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

local Icons = {
    
  ['lucide-accessibility'] = 'rbxassetid://10709751939',
  ['lucide-activity'] = 'rbxassetid://10709752035',
  ['lucide-air-vent'] = 'rbxassetid://10709752131',
  ['lucide-airplay'] = 'rbxassetid://10709752254',
  ['lucide-alarm-check'] = 'rbxassetid://10709752405',
  ['lucide-alarm-clock'] = 'rbxassetid://10709752630',
  ['lucide-alarm-clock-off'] = 'rbxassetid://10709752508',
  ['lucide-alarm-minus'] = 'rbxassetid://10709752732',
  ['lucide-alarm-plus'] = 'rbxassetid://10709752825',
  ['lucide-album'] = 'rbxassetid://10709752906',
  ['lucide-alert-circle'] = 'rbxassetid://10709752996',
  ['lucide-alert-octagon'] = 'rbxassetid://10709753064',
  ['lucide-alert-triangle'] = 'rbxassetid://10709753149',
  ['lucide-align-center'] = 'rbxassetid://10709753570',
  ['lucide-align-center-horizontal'] = 'rbxassetid://10709753272',
  ['lucide-align-center-vertical'] = 'rbxassetid://10709753421',
  ['lucide-align-end-horizontal'] = 'rbxassetid://10709753692',
  ['lucide-align-end-vertical'] = 'rbxassetid://10709753808',
  ['lucide-align-horizontal-distribute-center'] = 'rbxassetid://10747779791',
  ['lucide-align-horizontal-distribute-end'] = 'rbxassetid://10747784534',
  ['lucide-align-horizontal-distribute-start'] = 'rbxassetid://10709754118',
  ['lucide-align-horizontal-justify-center'] = 'rbxassetid://10709754204',
  ['lucide-align-horizontal-justify-end'] = 'rbxassetid://10709754317',
  ['lucide-align-horizontal-justify-start'] = 'rbxassetid://10709754436',
  ['lucide-align-horizontal-space-around'] = 'rbxassetid://10709754590',
  ['lucide-align-horizontal-space-between'] = 'rbxassetid://10709754749',
  ['lucide-align-justify'] = 'rbxassetid://10709759610',
  ['lucide-align-left'] = 'rbxassetid://10709759764',
  ['lucide-align-right'] = 'rbxassetid://10709759895',
  ['lucide-align-start-horizontal'] = 'rbxassetid://10709760051',
  ['lucide-align-start-vertical'] = 'rbxassetid://10709760244',
  ['lucide-align-vertical-distribute-center'] = 'rbxassetid://10709760351',
  ['lucide-align-vertical-distribute-end'] = 'rbxassetid://10709760434',
  ['lucide-align-vertical-distribute-start'] = 'rbxassetid://10709760612',
  ['lucide-align-vertical-justify-center'] = 'rbxassetid://10709760814',
  ['lucide-align-vertical-justify-end'] = 'rbxassetid://10709761003',
  ['lucide-align-vertical-justify-start'] = 'rbxassetid://10709761176',
  ['lucide-align-vertical-space-around'] = 'rbxassetid://10709761324',
  ['lucide-align-vertical-space-between'] = 'rbxassetid://10709761434',
  ['lucide-anchor'] = 'rbxassetid://10709761530',
  ['lucide-angry'] = 'rbxassetid://10709761629',
  ['lucide-annoyed'] = 'rbxassetid://10709761722',
  ['lucide-aperture'] = 'rbxassetid://10709761813',
  ['lucide-apple'] = 'rbxassetid://10709761889',
  ['lucide-archive'] = 'rbxassetid://10709762233',
  ['lucide-archive-restore'] = 'rbxassetid://10709762058',
  ['lucide-armchair'] = 'rbxassetid://10709762327',
  ['lucide-arrow-big-down'] = 'rbxassetid://10747796644',
  ['lucide-arrow-big-left'] = 'rbxassetid://10709762574',
  ['lucide-arrow-big-right'] = 'rbxassetid://10709762727',
  ['lucide-arrow-big-up'] = 'rbxassetid://10709762879',
  ['lucide-arrow-down'] = 'rbxassetid://10709767827',
  ['lucide-arrow-down-circle'] = 'rbxassetid://10709763034',
  ['lucide-arrow-down-left'] = 'rbxassetid://10709767656',
  ['lucide-arrow-down-right'] = 'rbxassetid://10709767750',
  ['lucide-arrow-left'] = 'rbxassetid://10709768114',
  ['lucide-arrow-left-circle'] = 'rbxassetid://10709767936',
  ['lucide-arrow-left-right'] = 'rbxassetid://10709768019',
  ['lucide-arrow-right'] = 'rbxassetid://10709768347',
  ['lucide-arrow-right-circle'] = 'rbxassetid://10709768226',
  ['lucide-arrow-up'] = 'rbxassetid://10709768939',
  ['lucide-arrow-up-circle'] = 'rbxassetid://10709768432',
  ['lucide-arrow-up-down'] = 'rbxassetid://10709768538',
  ['lucide-arrow-up-left'] = 'rbxassetid://10709768661',
  ['lucide-arrow-up-right'] = 'rbxassetid://10709768787',
  ['lucide-asterisk'] = 'rbxassetid://10709769095',
  ['lucide-at-sign'] = 'rbxassetid://10709769286',
  ['lucide-award'] = 'rbxassetid://10709769406',
  ['lucide-axe'] = 'rbxassetid://10709769508',
  ['lucide-axis-3d'] = 'rbxassetid://10709769598',
  ['lucide-baby'] = 'rbxassetid://10709769732',
  ['lucide-backpack'] = 'rbxassetid://10709769841',
  ['lucide-baggage-claim'] = 'rbxassetid://10709769935',
  ['lucide-banana'] = 'rbxassetid://10709770005',
  ['lucide-banknote'] = 'rbxassetid://10709770178',
  ['lucide-bar-chart'] = 'rbxassetid://10709773755',
  ['lucide-bar-chart-2'] = 'rbxassetid://10709770317',
  ['lucide-bar-chart-3'] = 'rbxassetid://10709770431',
  ['lucide-bar-chart-4'] = 'rbxassetid://10709770560',
  ['lucide-bar-chart-horizontal'] = 'rbxassetid://10709773669',
  ['lucide-barcode'] = 'rbxassetid://10747360675',
  ['lucide-baseline'] = 'rbxassetid://10709773863',
  ['lucide-bath'] = 'rbxassetid://10709773963',
  ['lucide-battery'] = 'rbxassetid://10709774640',
  ['lucide-battery-charging'] = 'rbxassetid://10709774068',
  ['lucide-battery-full'] = 'rbxassetid://10709774206',
  ['lucide-battery-low'] = 'rbxassetid://10709774370',
  ['lucide-battery-medium'] = 'rbxassetid://10709774513',
  ['lucide-beaker'] = 'rbxassetid://10709774756',
  ['lucide-bed'] = 'rbxassetid://10709775036',
  ['lucide-bed-double'] = 'rbxassetid://10709774864',
  ['lucide-bed-single'] = 'rbxassetid://10709774968',
  ['lucide-beer'] = 'rbxassetid://10709775167',
  ['lucide-bell'] = 'rbxassetid://10709775704',
  ['lucide-bell-minus'] = 'rbxassetid://10709775241',
  ['lucide-bell-off'] = 'rbxassetid://10709775320',
  ['lucide-bell-plus'] = 'rbxassetid://10709775448',
  ['lucide-bell-ring'] = 'rbxassetid://10709775560',
  ['lucide-bike'] = 'rbxassetid://10709775894',
  ['lucide-binary'] = 'rbxassetid://10709776050',
  ['lucide-bitcoin'] = 'rbxassetid://10709776126',
  ['lucide-bluetooth'] = 'rbxassetid://10709776655',
  ['lucide-bluetooth-connected'] = 'rbxassetid://10709776240',
  ['lucide-bluetooth-off'] = 'rbxassetid://10709776344',
  ['lucide-bluetooth-searching'] = 'rbxassetid://10709776501',
  ['lucide-bold'] = 'rbxassetid://10747813908',
  ['lucide-bomb'] = 'rbxassetid://10709781460',
  ['lucide-bone'] = 'rbxassetid://10709781605',
  ['lucide-book'] = 'rbxassetid://10709781824',
  ['lucide-book-open'] = 'rbxassetid://10709781717',
  ['lucide-bookmark'] = 'rbxassetid://10709782154',
  ['lucide-bookmark-minus'] = 'rbxassetid://10709781919',
  ['lucide-bookmark-plus'] = 'rbxassetid://10709782044',
  ['lucide-bot'] = 'rbxassetid://10709782230',
  ['lucide-box'] = 'rbxassetid://10709782497',
  ['lucide-box-select'] = 'rbxassetid://10709782342',
  ['lucide-boxes'] = 'rbxassetid://10709782582',
  ['lucide-briefcase'] = 'rbxassetid://10709782662',
  ['lucide-brush'] = 'rbxassetid://10709782758',
  ['lucide-bug'] = 'rbxassetid://10709782845',
  ['lucide-building'] = 'rbxassetid://10709783051',
  ['lucide-building-2'] = 'rbxassetid://10709782939',
  ['lucide-bus'] = 'rbxassetid://10709783137',
  ['lucide-cake'] = 'rbxassetid://10709783217',
  ['lucide-calculator'] = 'rbxassetid://10709783311',
  ['lucide-calendar'] = 'rbxassetid://10709789505',
  ['lucide-calendar-check'] = 'rbxassetid://10709783474',
  ['lucide-calendar-check-2'] = 'rbxassetid://10709783392',
  ['lucide-calendar-clock'] = 'rbxassetid://10709783577',
  ['lucide-calendar-days'] = 'rbxassetid://10709783673',
  ['lucide-calendar-heart'] = 'rbxassetid://10709783835',
  ['lucide-calendar-minus'] = 'rbxassetid://10709783959',
  ['lucide-calendar-off'] = 'rbxassetid://10709788784',
  ['lucide-calendar-plus'] = 'rbxassetid://10709788937',
  ['lucide-calendar-range'] = 'rbxassetid://10709789053',
  ['lucide-calendar-search'] = 'rbxassetid://10709789200',
  ['lucide-calendar-x'] = 'rbxassetid://10709789407',
  ['lucide-calendar-x-2'] = 'rbxassetid://10709789329',
  ['lucide-camera'] = 'rbxassetid://10709789686',
  ['lucide-camera-off'] = 'rbxassetid://10747822677',
  ['lucide-car'] = 'rbxassetid://10709789810',
  ['lucide-carrot'] = 'rbxassetid://10709789960',
  ['lucide-cast'] = 'rbxassetid://10709790097',
  ['lucide-charge'] = 'rbxassetid://10709790202',
  ['lucide-check'] = 'rbxassetid://10709790644',
  ['lucide-check-circle'] = 'rbxassetid://10709790387',
  ['lucide-check-circle-2'] = 'rbxassetid://10709790298',
  ['lucide-check-square'] = 'rbxassetid://10709790537',
  ['lucide-chef-hat'] = 'rbxassetid://10709790757',
  ['lucide-cherry'] = 'rbxassetid://10709790875',
  ['lucide-chevron-down'] = 'rbxassetid://10709790948',
  ['lucide-chevron-first'] = 'rbxassetid://10709791015',
  ['lucide-chevron-last'] = 'rbxassetid://10709791130',
  ['lucide-chevron-left'] = 'rbxassetid://10709791281',
  ['lucide-chevron-right'] = 'rbxassetid://10709791437',
  ['lucide-chevron-up'] = 'rbxassetid://10709791523',
  ['lucide-chevrons-down'] = 'rbxassetid://10709796864',
  ['lucide-chevrons-down-up'] = 'rbxassetid://10709791632',
  ['lucide-chevrons-left'] = 'rbxassetid://10709797151',
  ['lucide-chevrons-left-right'] = 'rbxassetid://10709797006',
  ['lucide-chevrons-right'] = 'rbxassetid://10709797382',
  ['lucide-chevrons-right-left'] = 'rbxassetid://10709797274',
  ['lucide-chevrons-up'] = 'rbxassetid://10709797622',
  ['lucide-chevrons-up-down'] = 'rbxassetid://10709797508',
  ['lucide-chrome'] = 'rbxassetid://10709797725',
  ['lucide-circle'] = 'rbxassetid://10709798174',
  ['lucide-circle-dot'] = 'rbxassetid://10709797837',
  ['lucide-circle-ellipsis'] = 'rbxassetid://10709797985',
  ['lucide-circle-slashed'] = 'rbxassetid://10709798100',
  ['lucide-citrus'] = 'rbxassetid://10709798276',
  ['lucide-clapperboard'] = 'rbxassetid://10709798350',
  ['lucide-clipboard'] = 'rbxassetid://10709799288',
  ['lucide-clipboard-check'] = 'rbxassetid://10709798443',
  ['lucide-clipboard-copy'] = 'rbxassetid://10709798574',
  ['lucide-clipboard-edit'] = 'rbxassetid://10709798682',
  ['lucide-clipboard-list'] = 'rbxassetid://10709798792',
  ['lucide-clipboard-signature'] = 'rbxassetid://10709798890',
  ['lucide-clipboard-type'] = 'rbxassetid://10709798999',
  ['lucide-clipboard-x'] = 'rbxassetid://10709799124',
  ['lucide-clock'] = 'rbxassetid://10709805144',
  ['lucide-clock-1'] = 'rbxassetid://10709799535',
  ['lucide-clock-10'] = 'rbxassetid://10709799718',
  ['lucide-clock-11'] = 'rbxassetid://10709799818',
  ['lucide-clock-12'] = 'rbxassetid://10709799962',
  ['lucide-clock-2'] = 'rbxassetid://10709803876',
  ['lucide-clock-3'] = 'rbxassetid://10709803989',
  ['lucide-clock-4'] = 'rbxassetid://10709804164',
  ['lucide-clock-5'] = 'rbxassetid://10709804291',
  ['lucide-clock-6'] = 'rbxassetid://10709804435',
  ['lucide-clock-7'] = 'rbxassetid://10709804599',
  ['lucide-clock-8'] = 'rbxassetid://10709804784',
  ['lucide-clock-9'] = 'rbxassetid://10709804996',
  ['lucide-cloud'] = 'rbxassetid://10709806740',
  ['lucide-cloud-cog'] = 'rbxassetid://10709805262',
  ['lucide-cloud-drizzle'] = 'rbxassetid://10709805371',
  ['lucide-cloud-fog'] = 'rbxassetid://10709805477',
  ['lucide-cloud-hail'] = 'rbxassetid://10709805596',
  ['lucide-cloud-lightning'] = 'rbxassetid://10709805727',
  ['lucide-cloud-moon'] = 'rbxassetid://10709805942',
  ['lucide-cloud-moon-rain'] = 'rbxassetid://10709805838',
  ['lucide-cloud-off'] = 'rbxassetid://10709806060',
  ['lucide-cloud-rain'] = 'rbxassetid://10709806277',
  ['lucide-cloud-rain-wind'] = 'rbxassetid://10709806166',
  ['lucide-cloud-snow'] = 'rbxassetid://10709806374',
  ['lucide-cloud-sun'] = 'rbxassetid://10709806631',
  ['lucide-cloud-sun-rain'] = 'rbxassetid://10709806475',
  ['lucide-cloudy'] = 'rbxassetid://10709806859',
  ['lucide-clover'] = 'rbxassetid://10709806995',
  ['lucide-code'] = 'rbxassetid://10709810463',
  ['lucide-code-2'] = 'rbxassetid://10709807111',
  ['lucide-codepen'] = 'rbxassetid://10709810534',
  ['lucide-codesandbox'] = 'rbxassetid://10709810676',
  ['lucide-coffee'] = 'rbxassetid://10709810814',
  ['lucide-cog'] = 'rbxassetid://10709810948',
  ['lucide-coins'] = 'rbxassetid://10709811110',
  ['lucide-columns'] = 'rbxassetid://10709811261',
  ['lucide-command'] = 'rbxassetid://10709811365',
  ['lucide-compass'] = 'rbxassetid://10709811445',
  ['lucide-component'] = 'rbxassetid://10709811595',
  ['lucide-concierge-bell'] = 'rbxassetid://10709811706',
  ['lucide-connection'] = 'rbxassetid://10747361219',
  ['lucide-contact'] = 'rbxassetid://10709811834',
  ['lucide-contrast'] = 'rbxassetid://10709811939',
  ['lucide-cookie'] = 'rbxassetid://10709812067',
  ['lucide-copy'] = 'rbxassetid://10709812159',
  ['lucide-copyleft'] = 'rbxassetid://10709812251',
  ['lucide-copyright'] = 'rbxassetid://10709812311',
  ['lucide-corner-down-left'] = 'rbxassetid://10709812396',
  ['lucide-corner-down-right'] = 'rbxassetid://10709812485',
  ['lucide-corner-left-down'] = 'rbxassetid://10709812632',
  ['lucide-corner-left-up'] = 'rbxassetid://10709812784',
  ['lucide-corner-right-down'] = 'rbxassetid://10709812939',
  ['lucide-corner-right-up'] = 'rbxassetid://10709813094',
  ['lucide-corner-up-left'] = 'rbxassetid://10709813185',
  ['lucide-corner-up-right'] = 'rbxassetid://10709813281',
  ['lucide-cpu'] = 'rbxassetid://10709813383',
  ['lucide-croissant'] = 'rbxassetid://10709818125',
  ['lucide-crop'] = 'rbxassetid://10709818245',
  ['lucide-cross'] = 'rbxassetid://10709818399',
  ['lucide-crosshair'] = 'rbxassetid://10709818534',
  ['lucide-crown'] = 'rbxassetid://10709818626',
  ['lucide-cup-soda'] = 'rbxassetid://10709818763',
  ['lucide-curly-braces'] = 'rbxassetid://10709818847',
  ['lucide-currency'] = 'rbxassetid://10709818931',
  ['lucide-database'] = 'rbxassetid://10709818996',
  ['lucide-delete'] = 'rbxassetid://10709819059',
  ['lucide-diamond'] = 'rbxassetid://10709819149',
  ['lucide-dice-1'] = 'rbxassetid://10709819266',
  ['lucide-dice-2'] = 'rbxassetid://10709819361',
  ['lucide-dice-3'] = 'rbxassetid://10709819508',
  ['lucide-dice-4'] = 'rbxassetid://10709819670',
  ['lucide-dice-5'] = 'rbxassetid://10709819801',
  ['lucide-dice-6'] = 'rbxassetid://10709819896',
  ['lucide-dices'] = 'rbxassetid://10723343321',
  ['lucide-diff'] = 'rbxassetid://10723343416',
  ['lucide-disc'] = 'rbxassetid://10723343537',
  ['lucide-divide'] = 'rbxassetid://10723343805',
  ['lucide-divide-circle'] = 'rbxassetid://10723343636',
  ['lucide-divide-square'] = 'rbxassetid://10723343737',
  ['lucide-dollar-sign'] = 'rbxassetid://10723343958',
  ['lucide-download'] = 'rbxassetid://10723344270',
  ['lucide-download-cloud'] = 'rbxassetid://10723344088',
  ['lucide-droplet'] = 'rbxassetid://10723344432',
  ['lucide-droplets'] = 'rbxassetid://10734883356',
  ['lucide-drumstick'] = 'rbxassetid://10723344737',
  ['lucide-edit'] = 'rbxassetid://10734883598',
  ['lucide-edit-2'] = 'rbxassetid://10723344885',
  ['lucide-edit-3'] = 'rbxassetid://10723345088',
  ['lucide-egg'] = 'rbxassetid://10723345518',
  ['lucide-egg-fried'] = 'rbxassetid://10723345347',
  ['lucide-electricity'] = 'rbxassetid://10723345749',
  ['lucide-electricity-off'] = 'rbxassetid://10723345643',
  ['lucide-equal'] = 'rbxassetid://10723345990',
  ['lucide-equal-not'] = 'rbxassetid://10723345866',
  ['lucide-eraser'] = 'rbxassetid://10723346158',
  ['lucide-euro'] = 'rbxassetid://10723346372',
  ['lucide-expand'] = 'rbxassetid://10723346553',
  ['lucide-external-link'] = 'rbxassetid://10723346684',
  ['lucide-eye'] = 'rbxassetid://10723346959',
  ['lucide-eye-off'] = 'rbxassetid://10723346871',
  ['lucide-factory'] = 'rbxassetid://10723347051',
  ['lucide-fan'] = 'rbxassetid://10723354359',
  ['lucide-fast-forward'] = 'rbxassetid://10723354521',
  ['lucide-feather'] = 'rbxassetid://10723354671',
  ['lucide-figma'] = 'rbxassetid://10723354801',
  ['lucide-file'] = 'rbxassetid://10723374641',
  ['lucide-file-archive'] = 'rbxassetid://10723354921',
  ['lucide-file-audio'] = 'rbxassetid://10723355148',
  ['lucide-file-audio-2'] = 'rbxassetid://10723355026',
  ['lucide-file-axis-3d'] = 'rbxassetid://10723355272',
  ['lucide-file-badge'] = 'rbxassetid://10723355622',
  ['lucide-file-badge-2'] = 'rbxassetid://10723355451',
  ['lucide-file-bar-chart'] = 'rbxassetid://10723355887',
  ['lucide-file-bar-chart-2'] = 'rbxassetid://10723355746',
  ['lucide-file-box'] = 'rbxassetid://10723355989',
  ['lucide-file-check'] = 'rbxassetid://10723356210',
  ['lucide-file-check-2'] = 'rbxassetid://10723356100',
  ['lucide-file-clock'] = 'rbxassetid://10723356329',
  ['lucide-file-code'] = 'rbxassetid://10723356507',
  ['lucide-file-cog'] = 'rbxassetid://10723356830',
  ['lucide-file-cog-2'] = 'rbxassetid://10723356676',
  ['lucide-file-diff'] = 'rbxassetid://10723357039',
  ['lucide-file-digit'] = 'rbxassetid://10723357151',
  ['lucide-file-down'] = 'rbxassetid://10723357322',
  ['lucide-file-edit'] = 'rbxassetid://10723357495',
  ['lucide-file-heart'] = 'rbxassetid://10723357637',
  ['lucide-file-image'] = 'rbxassetid://10723357790',
  ['lucide-file-input'] = 'rbxassetid://10723357933',
  ['lucide-file-json'] = 'rbxassetid://10723364435',
  ['lucide-file-json-2'] = 'rbxassetid://10723364361',
  ['lucide-file-key'] = 'rbxassetid://10723364605',
  ['lucide-file-key-2'] = 'rbxassetid://10723364515',
  ['lucide-file-line-chart'] = 'rbxassetid://10723364725',
  ['lucide-file-lock'] = 'rbxassetid://10723364957',
  ['lucide-file-lock-2'] = 'rbxassetid://10723364861',
  ['lucide-file-minus'] = 'rbxassetid://10723365254',
  ['lucide-file-minus-2'] = 'rbxassetid://10723365086',
  ['lucide-file-output'] = 'rbxassetid://10723365457',
  ['lucide-file-pie-chart'] = 'rbxassetid://10723365598',
  ['lucide-file-plus'] = 'rbxassetid://10723365877',
  ['lucide-file-plus-2'] = 'rbxassetid://10723365766',
  ['lucide-file-question'] = 'rbxassetid://10723365987',
  ['lucide-file-scan'] = 'rbxassetid://10723366167',
  ['lucide-file-search'] = 'rbxassetid://10723366550',
  ['lucide-file-search-2'] = 'rbxassetid://10723366340',
  ['lucide-file-signature'] = 'rbxassetid://10723366741',
  ['lucide-file-spreadsheet'] = 'rbxassetid://10723366962',
  ['lucide-file-symlink'] = 'rbxassetid://10723367098',
  ['lucide-file-terminal'] = 'rbxassetid://10723367244',
  ['lucide-file-text'] = 'rbxassetid://10723367380',
  ['lucide-file-type'] = 'rbxassetid://10723367606',
  ['lucide-file-type-2'] = 'rbxassetid://10723367509',
  ['lucide-file-up'] = 'rbxassetid://10723367734',
  ['lucide-file-video'] = 'rbxassetid://10723373884',
  ['lucide-file-video-2'] = 'rbxassetid://10723367834',
  ['lucide-file-volume'] = 'rbxassetid://10723374172',
  ['lucide-file-volume-2'] = 'rbxassetid://10723374030',
  ['lucide-file-warning'] = 'rbxassetid://10723374276',
  ['lucide-file-x'] = 'rbxassetid://10723374544',
  ['lucide-file-x-2'] = 'rbxassetid://10723374378',
  ['lucide-files'] = 'rbxassetid://10723374759',
  ['lucide-film'] = 'rbxassetid://10723374981',
  ['lucide-filter'] = 'rbxassetid://10723375128',
  ['lucide-fingerprint'] = 'rbxassetid://10723375250',
  ['lucide-flag'] = 'rbxassetid://10723375890',
  ['lucide-flag-off'] = 'rbxassetid://10723375443',
  ['lucide-flag-triangle-left'] = 'rbxassetid://10723375608',
  ['lucide-flag-triangle-right'] = 'rbxassetid://10723375727',
  ['lucide-flame'] = 'rbxassetid://10723376114',
  ['lucide-flashlight'] = 'rbxassetid://10723376471',
  ['lucide-flashlight-off'] = 'rbxassetid://10723376365',
  ['lucide-flask-conical'] = 'rbxassetid://10734883986',
  ['lucide-flask-round'] = 'rbxassetid://10723376614',
  ['lucide-flip-horizontal'] = 'rbxassetid://10723376884',
  ['lucide-flip-horizontal-2'] = 'rbxassetid://10723376745',
  ['lucide-flip-vertical'] = 'rbxassetid://10723377138',
  ['lucide-flip-vertical-2'] = 'rbxassetid://10723377026',
  ['lucide-flower'] = 'rbxassetid://10747830374',
  ['lucide-flower-2'] = 'rbxassetid://10723377305',
  ['lucide-focus'] = 'rbxassetid://10723377537',
  ['lucide-folder'] = 'rbxassetid://10723387563',
  ['lucide-folder-archive'] = 'rbxassetid://10723384478',
  ['lucide-folder-check'] = 'rbxassetid://10723384605',
  ['lucide-folder-clock'] = 'rbxassetid://10723384731',
  ['lucide-folder-closed'] = 'rbxassetid://10723384893',
  ['lucide-folder-cog'] = 'rbxassetid://10723385213',
  ['lucide-folder-cog-2'] = 'rbxassetid://10723385036',
  ['lucide-folder-down'] = 'rbxassetid://10723385338',
  ['lucide-folder-edit'] = 'rbxassetid://10723385445',
  ['lucide-folder-heart'] = 'rbxassetid://10723385545',
  ['lucide-folder-input'] = 'rbxassetid://10723385721',
  ['lucide-folder-key'] = 'rbxassetid://10723385848',
  ['lucide-folder-lock'] = 'rbxassetid://10723386005',
  ['lucide-folder-minus'] = 'rbxassetid://10723386127',
  ['lucide-folder-open'] = 'rbxassetid://10723386277',
  ['lucide-folder-output'] = 'rbxassetid://10723386386',
  ['lucide-folder-plus'] = 'rbxassetid://10723386531',
  ['lucide-folder-search'] = 'rbxassetid://10723386787',
  ['lucide-folder-search-2'] = 'rbxassetid://10723386674',
  ['lucide-folder-symlink'] = 'rbxassetid://10723386930',
  ['lucide-folder-tree'] = 'rbxassetid://10723387085',
  ['lucide-folder-up'] = 'rbxassetid://10723387265',
  ['lucide-folder-x'] = 'rbxassetid://10723387448',
  ['lucide-folders'] = 'rbxassetid://10723387721',
  ['lucide-form-input'] = 'rbxassetid://10723387841',
  ['lucide-forward'] = 'rbxassetid://10723388016',
  ['lucide-frame'] = 'rbxassetid://10723394389',
  ['lucide-framer'] = 'rbxassetid://10723394565',
  ['lucide-frown'] = 'rbxassetid://10723394681',
  ['lucide-fuel'] = 'rbxassetid://10723394846',
  ['lucide-function-square'] = 'rbxassetid://10723395041',
  ['lucide-gamepad'] = 'rbxassetid://10723395457',
  ['lucide-gamepad-2'] = 'rbxassetid://10723395215',
  ['lucide-gauge'] = 'rbxassetid://10723395708',
  ['lucide-gavel'] = 'rbxassetid://10723395896',
  ['lucide-gem'] = 'rbxassetid://10723396000',
  ['lucide-ghost'] = 'rbxassetid://10723396107',
  ['lucide-gift'] = 'rbxassetid://10723396402',
  ['lucide-gift-card'] = 'rbxassetid://10723396225',
  ['lucide-git-branch'] = 'rbxassetid://10723396676',
  ['lucide-git-branch-plus'] = 'rbxassetid://10723396542',
  ['lucide-git-commit'] = 'rbxassetid://10723396812',
  ['lucide-git-compare'] = 'rbxassetid://10723396954',
  ['lucide-git-fork'] = 'rbxassetid://10723397049',
  ['lucide-git-merge'] = 'rbxassetid://10723397165',
  ['lucide-git-pull-request'] = 'rbxassetid://10723397431',
  ['lucide-git-pull-request-closed'] = 'rbxassetid://10723397268',
  ['lucide-git-pull-request-draft'] = 'rbxassetid://10734884302',
  ['lucide-glass'] = 'rbxassetid://10723397788',
  ['lucide-glass-2'] = 'rbxassetid://10723397529',
  ['lucide-glass-water'] = 'rbxassetid://10723397678',
  ['lucide-glasses'] = 'rbxassetid://10723397895',
  ['lucide-globe'] = 'rbxassetid://10723404337',
  ['lucide-globe-2'] = 'rbxassetid://10723398002',
  ['lucide-grab'] = 'rbxassetid://10723404472',
  ['lucide-graduation-cap'] = 'rbxassetid://10723404691',
  ['lucide-grape'] = 'rbxassetid://10723404822',
  ['lucide-grid'] = 'rbxassetid://10723404936',
  ['lucide-grip-horizontal'] = 'rbxassetid://10723405089',
  ['lucide-grip-vertical'] = 'rbxassetid://10723405236',
  ['lucide-hammer'] = 'rbxassetid://10723405360',
  ['lucide-hand'] = 'rbxassetid://10723405649',
  ['lucide-hand-metal'] = 'rbxassetid://10723405508',
  ['lucide-hard-drive'] = 'rbxassetid://10723405749',
  ['lucide-hard-hat'] = 'rbxassetid://10723405859',
  ['lucide-hash'] = 'rbxassetid://10723405975',
  ['lucide-haze'] = 'rbxassetid://10723406078',
  ['lucide-headphones'] = 'rbxassetid://10723406165',
  ['lucide-heart'] = 'rbxassetid://10723406885',
  ['lucide-heart-crack'] = 'rbxassetid://10723406299',
  ['lucide-heart-handshake'] = 'rbxassetid://10723406480',
  ['lucide-heart-off'] = 'rbxassetid://10723406662',
  ['lucide-heart-pulse'] = 'rbxassetid://10723406795',
  ['lucide-help-circle'] = 'rbxassetid://10723406988',
  ['lucide-hexagon'] = 'rbxassetid://10723407092',
  ['lucide-highlighter'] = 'rbxassetid://10723407192',
  ['lucide-history'] = 'rbxassetid://10723407335',
  ['lucide-home'] = 'rbxassetid://10723407389',
  ['lucide-hourglass'] = 'rbxassetid://10723407498',
  ['lucide-ice-cream'] = 'rbxassetid://10723414308',
  ['lucide-image'] = 'rbxassetid://10723415040',
  ['lucide-image-minus'] = 'rbxassetid://10723414487',
  ['lucide-image-off'] = 'rbxassetid://10723414677',
  ['lucide-image-plus'] = 'rbxassetid://10723414827',
  ['lucide-import'] = 'rbxassetid://10723415205',
  ['lucide-inbox'] = 'rbxassetid://10723415335',
  ['lucide-indent'] = 'rbxassetid://10723415494',
  ['lucide-indian-rupee'] = 'rbxassetid://10723415642',
  ['lucide-infinity'] = 'rbxassetid://10723415766',
  ['lucide-info'] = 'rbxassetid://10723415903',
  ['lucide-inspect'] = 'rbxassetid://10723416057',
  ['lucide-italic'] = 'rbxassetid://10723416195',
  ['lucide-japanese-yen'] = 'rbxassetid://10723416363',
  ['lucide-joystick'] = 'rbxassetid://10723416527',
  ['lucide-key'] = 'rbxassetid://10723416652',
  ['lucide-keyboard'] = 'rbxassetid://10723416765',
  ['lucide-lamp'] = 'rbxassetid://10723417513',
  ['lucide-lamp-ceiling'] = 'rbxassetid://10723416922',
  ['lucide-lamp-desk'] = 'rbxassetid://10723417016',
  ['lucide-lamp-floor'] = 'rbxassetid://10723417131',
  ['lucide-lamp-wall-down'] = 'rbxassetid://10723417240',
  ['lucide-lamp-wall-up'] = 'rbxassetid://10723417356',
  ['lucide-landmark'] = 'rbxassetid://10723417608',
  ['lucide-languages'] = 'rbxassetid://10723417703',
  ['lucide-laptop'] = 'rbxassetid://10723423881',
  ['lucide-laptop-2'] = 'rbxassetid://10723417797',
  ['lucide-lasso'] = 'rbxassetid://10723424235',
  ['lucide-lasso-select'] = 'rbxassetid://10723424058',
  ['lucide-laugh'] = 'rbxassetid://10723424372',
  ['lucide-layers'] = 'rbxassetid://10723424505',
  ['lucide-layout'] = 'rbxassetid://10723425376',
  ['lucide-layout-dashboard'] = 'rbxassetid://10723424646',
  ['lucide-layout-grid'] = 'rbxassetid://10723424838',
  ['lucide-layout-list'] = 'rbxassetid://10723424963',
  ['lucide-layout-template'] = 'rbxassetid://10723425187',
  ['lucide-leaf'] = 'rbxassetid://10723425539',
  ['lucide-library'] = 'rbxassetid://10723425615',
  ['lucide-life-buoy'] = 'rbxassetid://10723425685',
  ['lucide-lightbulb'] = 'rbxassetid://10723425852',
  ['lucide-lightbulb-off'] = 'rbxassetid://10723425762',
  ['lucide-line-chart'] = 'rbxassetid://10723426393',
  ['lucide-link'] = 'rbxassetid://10723426722',
  ['lucide-link-2'] = 'rbxassetid://10723426595',
  ['lucide-link-2-off'] = 'rbxassetid://10723426513',
  ['lucide-list'] = 'rbxassetid://10723433811',
  ['lucide-list-checks'] = 'rbxassetid://10734884548',
  ['lucide-list-end'] = 'rbxassetid://10723426886',
  ['lucide-list-minus'] = 'rbxassetid://10723426986',
  ['lucide-list-music'] = 'rbxassetid://10723427081',
  ['lucide-list-ordered'] = 'rbxassetid://10723427199',
  ['lucide-list-plus'] = 'rbxassetid://10723427334',
  ['lucide-list-start'] = 'rbxassetid://10723427494',
  ['lucide-list-video'] = 'rbxassetid://10723427619',
  ['lucide-list-x'] = 'rbxassetid://10723433655',
  ['lucide-loader'] = 'rbxassetid://10723434070',
  ['lucide-loader-2'] = 'rbxassetid://10723433935',
  ['lucide-locate'] = 'rbxassetid://10723434557',
  ['lucide-locate-fixed'] = 'rbxassetid://10723434236',
  ['lucide-locate-off'] = 'rbxassetid://10723434379',
  ['lucide-lock'] = 'rbxassetid://10723434711',
  ['lucide-log-in'] = 'rbxassetid://10723434830',
  ['lucide-log-out'] = 'rbxassetid://10723434906',
  ['lucide-luggage'] = 'rbxassetid://10723434993',
  ['lucide-magnet'] = 'rbxassetid://10723435069',
  ['lucide-mail'] = 'rbxassetid://10734885430',
  ['lucide-mail-check'] = 'rbxassetid://10723435182',
  ['lucide-mail-minus'] = 'rbxassetid://10723435261',
  ['lucide-mail-open'] = 'rbxassetid://10723435342',
  ['lucide-mail-plus'] = 'rbxassetid://10723435443',
  ['lucide-mail-question'] = 'rbxassetid://10723435515',
  ['lucide-mail-search'] = 'rbxassetid://10734884739',
  ['lucide-mail-warning'] = 'rbxassetid://10734885015',
  ['lucide-mail-x'] = 'rbxassetid://10734885247',
  ['lucide-mails'] = 'rbxassetid://10734885614',
  ['lucide-map'] = 'rbxassetid://10734886202',
  ['lucide-map-pin'] = 'rbxassetid://10734886004',
  ['lucide-map-pin-off'] = 'rbxassetid://10734885803',
  ['lucide-maximize'] = 'rbxassetid://10734886735',
  ['lucide-maximize-2'] = 'rbxassetid://10734886496',
  ['lucide-medal'] = 'rbxassetid://10734887072',
  ['lucide-megaphone'] = 'rbxassetid://10734887454',
  ['lucide-megaphone-off'] = 'rbxassetid://10734887311',
  ['lucide-meh'] = 'rbxassetid://10734887603',
  ['lucide-menu'] = 'rbxassetid://10734887784',
  ['lucide-message-circle'] = 'rbxassetid://10734888000',
  ['lucide-message-square'] = 'rbxassetid://10734888228',
  ['lucide-mic'] = 'rbxassetid://10734888864',
  ['lucide-mic-2'] = 'rbxassetid://10734888430',
  ['lucide-mic-off'] = 'rbxassetid://10734888646',
  ['lucide-microscope'] = 'rbxassetid://10734889106',
  ['lucide-microwave'] = 'rbxassetid://10734895076',
  ['lucide-milestone'] = 'rbxassetid://10734895310',
  ['lucide-minimize'] = 'rbxassetid://10734895698',
  ['lucide-minimize-2'] = 'rbxassetid://10734895530',
  ['lucide-minus'] = 'rbxassetid://10734896206',
  ['lucide-minus-circle'] = 'rbxassetid://10734895856',
  ['lucide-minus-square'] = 'rbxassetid://10734896029',
  ['lucide-monitor'] = 'rbxassetid://10734896881',
  ['lucide-monitor-off'] = 'rbxassetid://10734896360',
  ['lucide-monitor-speaker'] = 'rbxassetid://10734896512',
  ['lucide-moon'] = 'rbxassetid://10734897102',
  ['lucide-more-horizontal'] = 'rbxassetid://10734897250',
  ['lucide-more-vertical'] = 'rbxassetid://10734897387',
  ['lucide-mountain'] = 'rbxassetid://10734897956',
  ['lucide-mountain-snow'] = 'rbxassetid://10734897665',
  ['lucide-mouse'] = 'rbxassetid://10734898592',
  ['lucide-mouse-pointer'] = 'rbxassetid://10734898476',
  ['lucide-mouse-pointer-2'] = 'rbxassetid://10734898194',
  ['lucide-mouse-pointer-click'] = 'rbxassetid://10734898355',
  ['lucide-move'] = 'rbxassetid://10734900011',
  ['lucide-move-3d'] = 'rbxassetid://10734898756',
  ['lucide-move-diagonal'] = 'rbxassetid://10734899164',
  ['lucide-move-diagonal-2'] = 'rbxassetid://10734898934',
  ['lucide-move-horizontal'] = 'rbxassetid://10734899414',
  ['lucide-move-vertical'] = 'rbxassetid://10734899821',
  ['lucide-music'] = 'rbxassetid://10734905958',
  ['lucide-music-2'] = 'rbxassetid://10734900215',
  ['lucide-music-3'] = 'rbxassetid://10734905665',
  ['lucide-music-4'] = 'rbxassetid://10734905823',
  ['lucide-navigation'] = 'rbxassetid://10734906744',
  ['lucide-navigation-2'] = 'rbxassetid://10734906332',
  ['lucide-navigation-2-off'] = 'rbxassetid://10734906144',
  ['lucide-navigation-off'] = 'rbxassetid://10734906580',
  ['lucide-network'] = 'rbxassetid://10734906975',
  ['lucide-newspaper'] = 'rbxassetid://10734907168',
  ['lucide-octagon'] = 'rbxassetid://10734907361',
  ['lucide-option'] = 'rbxassetid://10734907649',
  ['lucide-outdent'] = 'rbxassetid://10734907933',
  ['lucide-package'] = 'rbxassetid://10734909540',
  ['lucide-package-2'] = 'rbxassetid://10734908151',
  ['lucide-package-check'] = 'rbxassetid://10734908384',
  ['lucide-package-minus'] = 'rbxassetid://10734908626',
  ['lucide-package-open'] = 'rbxassetid://10734908793',
  ['lucide-package-plus'] = 'rbxassetid://10734909016',
  ['lucide-package-search'] = 'rbxassetid://10734909196',
  ['lucide-package-x'] = 'rbxassetid://10734909375',
  ['lucide-paint-bucket'] = 'rbxassetid://10734909847',
  ['lucide-paintbrush'] = 'rbxassetid://10734910187',
  ['lucide-paintbrush-2'] = 'rbxassetid://10734910030',
  ['lucide-palette'] = 'rbxassetid://10734910430',
  ['lucide-palmtree'] = 'rbxassetid://10734910680',
  ['lucide-paperclip'] = 'rbxassetid://10734910927',
  ['lucide-party-popper'] = 'rbxassetid://10734918735',
  ['lucide-pause'] = 'rbxassetid://10734919336',
  ['lucide-pause-circle'] = 'rbxassetid://10735024209',
  ['lucide-pause-octagon'] = 'rbxassetid://10734919143',
  ['lucide-pen-tool'] = 'rbxassetid://10734919503',
  ['lucide-pencil'] = 'rbxassetid://10734919691',
  ['lucide-percent'] = 'rbxassetid://10734919919',
  ['lucide-person-standing'] = 'rbxassetid://10734920149',
  ['lucide-phone'] = 'rbxassetid://10734921524',
  ['lucide-phone-call'] = 'rbxassetid://10734920305',
  ['lucide-phone-forwarded'] = 'rbxassetid://10734920508',
  ['lucide-phone-incoming'] = 'rbxassetid://10734920694',
  ['lucide-phone-missed'] = 'rbxassetid://10734920845',
  ['lucide-phone-off'] = 'rbxassetid://10734921077',
  ['lucide-phone-outgoing'] = 'rbxassetid://10734921288',
  ['lucide-pie-chart'] = 'rbxassetid://10734921727',
  ['lucide-piggy-bank'] = 'rbxassetid://10734921935',
  ['lucide-pin'] = 'rbxassetid://10734922324',
  ['lucide-pin-off'] = 'rbxassetid://10734922180',
  ['lucide-pipette'] = 'rbxassetid://10734922497',
  ['lucide-pizza'] = 'rbxassetid://10734922774',
  ['lucide-plane'] = 'rbxassetid://10734922971',
  ['lucide-play'] = 'rbxassetid://10734923549',
  ['lucide-play-circle'] = 'rbxassetid://10734923214',
  ['lucide-plus'] = 'rbxassetid://10734924532',
  ['lucide-plus-circle'] = 'rbxassetid://10734923868',
  ['lucide-plus-square'] = 'rbxassetid://10734924219',
  ['lucide-podcast'] = 'rbxassetid://10734929553',
  ['lucide-pointer'] = 'rbxassetid://10734929723',
  ['lucide-pound-sterling'] = 'rbxassetid://10734929981',
  ['lucide-power'] = 'rbxassetid://10734930466',
  ['lucide-power-off'] = 'rbxassetid://10734930257',
  ['lucide-printer'] = 'rbxassetid://10734930632',
  ['lucide-puzzle'] = 'rbxassetid://10734930886',
  ['lucide-quote'] = 'rbxassetid://10734931234',
  ['lucide-radio'] = 'rbxassetid://10734931596',
  ['lucide-radio-receiver'] = 'rbxassetid://10734931402',
  ['lucide-rectangle-horizontal'] = 'rbxassetid://10734931777',
  ['lucide-rectangle-vertical'] = 'rbxassetid://10734932081',
  ['lucide-recycle'] = 'rbxassetid://10734932295',
  ['lucide-redo'] = 'rbxassetid://10734932822',
  ['lucide-redo-2'] = 'rbxassetid://10734932586',
  ['lucide-refresh-ccw'] = 'rbxassetid://10734933056',
  ['lucide-refresh-cw'] = 'rbxassetid://10734933222',
  ['lucide-refrigerator'] = 'rbxassetid://10734933465',
  ['lucide-regex'] = 'rbxassetid://10734933655',
  ['lucide-repeat'] = 'rbxassetid://10734933966',
  ['lucide-repeat-1'] = 'rbxassetid://10734933826',
  ['lucide-reply'] = 'rbxassetid://10734934252',
  ['lucide-reply-all'] = 'rbxassetid://10734934132',
  ['lucide-rewind'] = 'rbxassetid://10734934347',
  ['lucide-rocket'] = 'rbxassetid://10734934585',
  ['lucide-rocking-chair'] = 'rbxassetid://10734939942',
  ['lucide-rotate-3d'] = 'rbxassetid://10734940107',
  ['lucide-rotate-ccw'] = 'rbxassetid://10734940376',
  ['lucide-rotate-cw'] = 'rbxassetid://10734940654',
  ['lucide-rss'] = 'rbxassetid://10734940825',
  ['lucide-ruler'] = 'rbxassetid://10734941018',
  ['lucide-russian-ruble'] = 'rbxassetid://10734941199',
  ['lucide-sailboat'] = 'rbxassetid://10734941354',
  ['lucide-save'] = 'rbxassetid://10734941499',
  ['lucide-scale'] = 'rbxassetid://10734941912',
  ['lucide-scale-3d'] = 'rbxassetid://10734941739',
  ['lucide-scaling'] = 'rbxassetid://10734942072',
  ['lucide-scan'] = 'rbxassetid://10734942565',
  ['lucide-scan-face'] = 'rbxassetid://10734942198',
  ['lucide-scan-line'] = 'rbxassetid://10734942351',
  ['lucide-scissors'] = 'rbxassetid://10734942778',
  ['lucide-screen-share'] = 'rbxassetid://10734943193',
  ['lucide-screen-share-off'] = 'rbxassetid://10734942967',
  ['lucide-scroll'] = 'rbxassetid://10734943448',
  ['lucide-search'] = 'rbxassetid://10734943674',
  ['lucide-send'] = 'rbxassetid://10734943902',
  ['lucide-separator-horizontal'] = 'rbxassetid://10734944115',
  ['lucide-separator-vertical'] = 'rbxassetid://10734944326',
  ['lucide-server'] = 'rbxassetid://10734949856',
  ['lucide-server-cog'] = 'rbxassetid://10734944444',
  ['lucide-server-crash'] = 'rbxassetid://10734944554',
  ['lucide-server-off'] = 'rbxassetid://10734944668',
  ['lucide-settings'] = 'rbxassetid://10734950309',
  ['lucide-settings-2'] = 'rbxassetid://10734950020',
  ['lucide-share'] = 'rbxassetid://10734950813',
  ['lucide-share-2'] = 'rbxassetid://10734950553',
  ['lucide-sheet'] = 'rbxassetid://10734951038',
  ['lucide-shield'] = 'rbxassetid://10734951847',
  ['lucide-shield-alert'] = 'rbxassetid://10734951173',
  ['lucide-shield-check'] = 'rbxassetid://10734951367',
  ['lucide-shield-close'] = 'rbxassetid://10734951535',
  ['lucide-shield-off'] = 'rbxassetid://10734951684',
  ['lucide-shirt'] = 'rbxassetid://10734952036',
  ['lucide-shopping-bag'] = 'rbxassetid://10734952273',
  ['lucide-shopping-cart'] = 'rbxassetid://10734952479',
  ['lucide-shovel'] = 'rbxassetid://10734952773',
  ['lucide-shower-head'] = 'rbxassetid://10734952942',
  ['lucide-shrink'] = 'rbxassetid://10734953073',
  ['lucide-shrub'] = 'rbxassetid://10734953241',
  ['lucide-shuffle'] = 'rbxassetid://10734953451',
  ['lucide-sidebar'] = 'rbxassetid://10734954301',
  ['lucide-sidebar-close'] = 'rbxassetid://10734953715',
  ['lucide-sidebar-open'] = 'rbxassetid://10734954000',
  ['lucide-sigma'] = 'rbxassetid://10734954538',
  ['lucide-signal'] = 'rbxassetid://10734961133',
  ['lucide-signal-high'] = 'rbxassetid://10734954807',
  ['lucide-signal-low'] = 'rbxassetid://10734955080',
  ['lucide-signal-medium'] = 'rbxassetid://10734955336',
  ['lucide-signal-zero'] = 'rbxassetid://10734960878',
  ['lucide-siren'] = 'rbxassetid://10734961284',
  ['lucide-skip-back'] = 'rbxassetid://10734961526',
  ['lucide-skip-forward'] = 'rbxassetid://10734961809',
  ['lucide-skull'] = 'rbxassetid://10734962068',
  ['lucide-slack'] = 'rbxassetid://10734962339',
  ['lucide-slash'] = 'rbxassetid://10734962600',
  ['lucide-slice'] = 'rbxassetid://10734963024',
  ['lucide-sliders'] = 'rbxassetid://10734963400',
  ['lucide-sliders-horizontal'] = 'rbxassetid://10734963191',
  ['lucide-smartphone'] = 'rbxassetid://10734963940',
  ['lucide-smartphone-charging'] = 'rbxassetid://10734963671',
  ['lucide-smile'] = 'rbxassetid://10734964441',
  ['lucide-smile-plus'] = 'rbxassetid://10734964188',
  ['lucide-snowflake'] = 'rbxassetid://10734964600',
  ['lucide-sofa'] = 'rbxassetid://10734964852',
  ['lucide-sort-asc'] = 'rbxassetid://10734965115',
  ['lucide-sort-desc'] = 'rbxassetid://10734965287',
  ['lucide-speaker'] = 'rbxassetid://10734965419',
  ['lucide-sprout'] = 'rbxassetid://10734965572',
  ['lucide-square'] = 'rbxassetid://10734965702',
  ['lucide-star'] = 'rbxassetid://10734966248',
  ['lucide-star-half'] = 'rbxassetid://10734965897',
  ['lucide-star-off'] = 'rbxassetid://10734966097',
  ['lucide-stethoscope'] = 'rbxassetid://10734966384',
  ['lucide-sticker'] = 'rbxassetid://10734972234',
  ['lucide-sticky-note'] = 'rbxassetid://10734972463',
  ['lucide-stop-circle'] = 'rbxassetid://10734972621',
  ['lucide-stretch-horizontal'] = 'rbxassetid://10734972862',
  ['lucide-stretch-vertical'] = 'rbxassetid://10734973130',
  ['lucide-strikethrough'] = 'rbxassetid://10734973290',
  ['lucide-subscript'] = 'rbxassetid://10734973457',
  ['lucide-sun'] = 'rbxassetid://10734974297',
  ['lucide-sun-dim'] = 'rbxassetid://10734973645',
  ['lucide-sun-medium'] = 'rbxassetid://10734973778',
  ['lucide-sun-moon'] = 'rbxassetid://10734973999',
  ['lucide-sun-snow'] = 'rbxassetid://10734974130',
  ['lucide-sunrise'] = 'rbxassetid://10734974522',
  ['lucide-sunset'] = 'rbxassetid://10734974689',
  ['lucide-superscript'] = 'rbxassetid://10734974850',
  ['lucide-swiss-franc'] = 'rbxassetid://10734975024',
  ['lucide-switch-camera'] = 'rbxassetid://10734975214',
  ['lucide-sword'] = 'rbxassetid://10734975486',
  ['lucide-swords'] = 'rbxassetid://10734975692',
  ['lucide-syringe'] = 'rbxassetid://10734975932',
  ['lucide-table'] = 'rbxassetid://10734976230',
  ['lucide-table-2'] = 'rbxassetid://10734976097',
  ['lucide-tablet'] = 'rbxassetid://10734976394',
  ['lucide-tag'] = 'rbxassetid://10734976528',
  ['lucide-tags'] = 'rbxassetid://10734976739',
  ['lucide-target'] = 'rbxassetid://10734977012',
  ['lucide-tent'] = 'rbxassetid://10734981750',
  ['lucide-terminal'] = 'rbxassetid://10734982144',
  ['lucide-terminal-square'] = 'rbxassetid://10734981995',
  ['lucide-text-cursor'] = 'rbxassetid://10734982395',
  ['lucide-text-cursor-input'] = 'rbxassetid://10734982297',
  ['lucide-thermometer'] = 'rbxassetid://10734983134',
  ['lucide-thermometer-snowflake'] = 'rbxassetid://10734982571',
  ['lucide-thermometer-sun'] = 'rbxassetid://10734982771',
  ['lucide-thumbs-down'] = 'rbxassetid://10734983359',
  ['lucide-thumbs-up'] = 'rbxassetid://10734983629',
  ['lucide-ticket'] = 'rbxassetid://10734983868',
  ['lucide-timer'] = 'rbxassetid://10734984606',
  ['lucide-timer-off'] = 'rbxassetid://10734984138',
  ['lucide-timer-reset'] = 'rbxassetid://10734984355',
  ['lucide-toggle-left'] = 'rbxassetid://10734984834',
  ['lucide-toggle-right'] = 'rbxassetid://10734985040',
  ['lucide-tornado'] = 'rbxassetid://10734985247',
  ['lucide-toy-brick'] = 'rbxassetid://10747361919',
  ['lucide-train'] = 'rbxassetid://10747362105',
  ['lucide-trash'] = 'rbxassetid://10747362393',
  ['lucide-trash-2'] = 'rbxassetid://10747362241',
  ['lucide-tree-deciduous'] = 'rbxassetid://10747362534',
  ['lucide-tree-pine'] = 'rbxassetid://10747362748',
  ['lucide-trees'] = 'rbxassetid://10747363016',
  ['lucide-trending-down'] = 'rbxassetid://10747363205',
  ['lucide-trending-up'] = 'rbxassetid://10747363465',
  ['lucide-triangle'] = 'rbxassetid://10747363621',
  ['lucide-trophy'] = 'rbxassetid://10747363809',
  ['lucide-truck'] = 'rbxassetid://10747364031',
  ['lucide-tv'] = 'rbxassetid://10747364593',
  ['lucide-tv-2'] = 'rbxassetid://10747364302',
  ['lucide-type'] = 'rbxassetid://10747364761',
  ['lucide-umbrella'] = 'rbxassetid://10747364971',
  ['lucide-underline'] = 'rbxassetid://10747365191',
  ['lucide-undo'] = 'rbxassetid://10747365484',
  ['lucide-undo-2'] = 'rbxassetid://10747365359',
  ['lucide-unlink'] = 'rbxassetid://10747365771',
  ['lucide-unlink-2'] = 'rbxassetid://10747397871',
  ['lucide-unlock'] = 'rbxassetid://10747366027',
  ['lucide-upload'] = 'rbxassetid://10747366434',
  ['lucide-upload-cloud'] = 'rbxassetid://10747366266',
  ['lucide-usb'] = 'rbxassetid://10747366606',
  ['lucide-user'] = 'rbxassetid://10747373176',
  ['lucide-user-check'] = 'rbxassetid://10747371901',
  ['lucide-user-cog'] = 'rbxassetid://10747372167',
  ['lucide-user-minus'] = 'rbxassetid://10747372346',
  ['lucide-user-plus'] = 'rbxassetid://10747372702',
  ['lucide-user-x'] = 'rbxassetid://10747372992',
  ['lucide-users'] = 'rbxassetid://10747373426',
  ['lucide-utensils'] = 'rbxassetid://10747373821',
  ['lucide-utensils-crossed'] = 'rbxassetid://10747373629',
  ['lucide-venetian-mask'] = 'rbxassetid://10747374003',
  ['lucide-verified'] = 'rbxassetid://10747374131',
  ['lucide-vibrate'] = 'rbxassetid://10747374489',
  ['lucide-vibrate-off'] = 'rbxassetid://10747374269',
  ['lucide-video'] = 'rbxassetid://10747374938',
  ['lucide-video-off'] = 'rbxassetid://10747374721',
  ['lucide-view'] = 'rbxassetid://10747375132',
  ['lucide-voicemail'] = 'rbxassetid://10747375281',
  ['lucide-volume'] = 'rbxassetid://10747376008',
  ['lucide-volume-1'] = 'rbxassetid://10747375450',
  ['lucide-volume-2'] = 'rbxassetid://10747375679',
  ['lucide-volume-x'] = 'rbxassetid://10747375880',
  ['lucide-wallet'] = 'rbxassetid://10747376205',
  ['lucide-wand'] = 'rbxassetid://10747376565',
  ['lucide-wand-2'] = 'rbxassetid://10747376349',
  ['lucide-watch'] = 'rbxassetid://10747376722',
  ['lucide-waves'] = 'rbxassetid://10747376931',
  ['lucide-webcam'] = 'rbxassetid://10747381992',
  ['lucide-wifi'] = 'rbxassetid://10747382504',
  ['lucide-wifi-off'] = 'rbxassetid://10747382268',
  ['lucide-wind'] = 'rbxassetid://10747382750',
  ['lucide-wrap-text'] = 'rbxassetid://10747383065',
  ['lucide-wrench'] = 'rbxassetid://10747383470',
  ['lucide-x'] = 'rbxassetid://10747384394',
  ['lucide-x-circle'] = 'rbxassetid://10747383819',
  ['lucide-x-octagon'] = 'rbxassetid://10747384037',
  ['lucide-x-square'] = 'rbxassetid://10747384217',
  ['lucide-zoom-in'] = 'rbxassetid://10747384552',
  ['lucide-zoom-out'] = 'rbxassetid://10747384679',
 
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
}
local PresetOrder = { "Paper", "Dusk", "Moss", "Rose", "Slate", "Night", "Ocean", "Sakura", "Ember", "Lavender", "Sand", "Mint", "Forest", "Midnight", "Crimson", "Mono" }
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
    -- sound system hook (defined in the SOUND SYSTEM block at the end of this file)
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
        if savedTheme.StripAnimation ~= nil then StripAnim = savedTheme.StripAnimation end
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
-- Try the common GUI containers used by different executors, then fall back to PlayerGui.
-- Every attempt is protected because some executors block one or more parent locations.
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
local STRIP_N = 9
local STRIP_ANGLE = -13
local rng = Random.new()
local animating = false
local pendingThemeAction = nil
local runThemeTransition

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

local function buildStrips(W, H, collapsed)
    -- Keep the host UIScale alive when rebuilding the animation strips.
    for _, child in ipairs(stripHost:GetChildren()) do
        if child ~= stripUIScale then
            child:Destroy()
        end
    end
    local list = {}
    for i = 1, STRIP_N do
        local r = rng:NextNumber(0.1, 0.9)
        local xc = -0.08 * W + (i - 1) * (1.2 * W / (STRIP_N - 1))

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
        Size = UDim2.fromOffset(W * 0.22, H * 1.8),
        Rotation = STRIP_ANGLE,
        BackgroundColor3 = Theme.Paper,
        BackgroundTransparency = collapsed and 0 or 1,
    }, band)
local stroke = new("UIStroke", {
    Thickness = 1,
    Color = Theme.Line,
    Transparency = collapsed and 0.4 or 1,
}, bar)
list[i] = { band = band, bar = bar, stroke = stroke, r = r, xc = xc, delay = rng:NextNumber(0, 0.22) }
end
return list
end

local function playStrips(opening)
    local W, H = main.Size.X.Offset, main.Size.Y.Offset
    stripHost.Position = main.Position
    stripHost.Size = main.Size
    local list = buildStrips(W, H, opening)
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

local function SetWindowOpen(shouldOpen)
    if animating or shouldOpen == main.Visible then
        return
    end
    if Library._sfx then
        Library._sfx(shouldOpen and "open" or "close")
    end
    if not StripAnim then
        main.Visible = shouldOpen
        return
    end
    animating = true
    playStrips(shouldOpen)
end

-- Cover the window before changing its palette, then reveal the updated UI.
-- The strip overlay reuses the same visual language as the window open/close effect.
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

    -- Closing: stagger the diagonal strips while an opaque curtain fills their gaps.
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
        -- The window is fully covered here, so the palette swap cannot flash underneath.
        for _, strip in ipairs(list) do
            if strip.bar.Parent then
                TweenService:Create(strip.bar, colorTween, { BackgroundColor3 = newPaper }):Play()
                TweenService:Create(strip.stroke, colorTween, { Color = newLine }):Play()
            end
        end
        TweenService:Create(cover, colorTween, { BackgroundColor3 = newPaper }):Play()

        task.delay(0.25, function()
            -- Opening: fade the cover and each strip away in sequence to reveal the new theme.
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
        -- 2 | Circle: round disc with an inner ring
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
        -- 3 | Diamond: double rotated square
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
        -- 4 | Pill: wide capsule with a label
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
        -- 5 | Bracket: glass panel with corner brackets
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
        -- 1 | Classic: solid square
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
        if original.instance.Parent then
            pcall(function()
                original.instance[original.property] = original.value
            end)
        end
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

    local state = { tweens = { pageSlideTween }, originals = {}, cancelled = false }
    pageAnimationStates[page] = state
    pageSlideTween:Play()
    local itemTargets = {}
    local itemTextTargets = {}

    -- Hide each row first, then restore its original transparency with a top-to-bottom stagger.
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
-- toggles play their own on/off sound, so skip the generic "select" click sound for this row
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
        -- tick on every value change; pitch rises with the value (0.8x at Min -> 1.5x at Max)
        Library._sfx("slider", 0.8 + 0.7 * rel)
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
                refreshTheme()
                persistTheme()
                BuildSettingsUI()
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
            SettingsTab:CreateDropdown(T.PresetLabel, "lucide-palette", PresetOrder, nil, nil, function(selected)
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

            SettingsTab:CreateSlider(T.SoundVolumeLabel, "lucide-volume-2", 0, 100, math.floor(Library.SoundVolume * 100 + 0.5), function(v)
                Library:SetSoundVolume(v / 100)
                persistTheme()
                -- Wait until dragging pauses before writing the config file.
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

-- ============================================================================
-- NIER UI : SOUND SYSTEM  (paste this whole block right ABOVE the last line `return Library`)
--
--   open   -> open_menu.ogg          (new, built from the close sound: higher + rising swoosh)
--   close  -> close_menu.ogg
--   hover  -> hover_tick.ogg
--   select -> tab_toggle_select.ogg  (tab switch / button / dropdown pick)
--   toggleOn  -> toggle_on.ogg       (CreateToggle switched ON,  rising two-note ping)
--   toggleOff -> toggle_off.ogg      (CreateToggle switched OFF, falling two-note ping)
--   slider -> slider_video_tick.ogg  (CreateSlider drag: video-matched tick, preloaded voices, pitch follows the value)
--   notify -> notify.ogg             (window:Notify(...) toast; the automatic start-up hint stays silent)
--
-- The .ogg files are embedded below (base64). On first run they are written to
-- <executor workspace>/NIER_UI_Sounds/ and played through getcustomasset().
-- If a file with the same name already exists there it is used as-is, so you can
-- replace any sound just by dropping your own .ogg into that folder.
-- Needs: writefile + getcustomasset (or getsynasset). Without them the UI stays silent.
--
--   Library.SoundEnabled = false        -- mute everything
--   Library.SoundVolume  = 0.5          -- master volume 0..1
-- ============================================================================
do
    local SoundService = game:GetService("SoundService")

    Library.SoundEnabled = true
    Library.SoundVolume = 1

    local SFX_FOLDER = "NIER_UI_Sounds"
    -- Bump this when the embedded sounds change: on the next run every .ogg in the folder is
    -- rewritten once, so old files left by a previous version can't shadow the new sounds.
    local SFX_VERSION = "4"

    -- gain: per-sound loudness multiplier, gap: minimum seconds between two plays
    local Sfx = {
        open   = { file = "open_menu.ogg",         gain = 0.8, gap = 0.10 },
        close  = { file = "close_menu.ogg",        gain = 0.8, gap = 0.10 },
        hover  = { file = "hover_tick.ogg",        gain = 1.0, gap = 0.05 },
        select = { file = "tab_toggle_select.ogg", gain = 0.9, gap = 0.04 },
        toggleOn  = { file = "toggle_on.ogg",  gain = 0.9, gap = 0.04 },
        toggleOff = { file = "toggle_off.ogg", gain = 0.9, gap = 0.04 },
        notify    = { file = "notify.ogg",     gain = 0.9, gap = 0.20 },
        slider    = { file = "slider_video_tick.ogg", gain = 1.0, gap = 0.045 },
    }
    local SfxData = {}

    -- remove sounds left over from a previous load of this library
    for _, old in ipairs(SoundService:GetChildren()) do
        if old:IsA("Sound") and string.find(old.Name, "^NIER_UI_Sfx_") then
            old:Destroy()
        end
    end

    -- executor function lookup (reuses the library helper, then falls back to getgenv)
    local function findFn(name)
        local f = getExecutorFunction(name)
        if f then
            return f
        end
        local gg = getExecutorFunction("getgenv")
        if gg then
            local ok, env = pcall(gg)
            if ok and type(env) == "table" and type(env[name]) == "function" then
                return env[name]
            end
        end
        return nil
    end

    -- pure Lua base64 decoder (no dependency on executor crypt functions)
    local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local B64Map = {}
    for i = 1, #B64 do
        B64Map[string.byte(B64, i)] = i - 1
    end
    local function decodeBase64(text)
        text = string.gsub(text, "%s", "")
        local out, n = {}, 0
        local byte, char, floor = string.byte, string.char, math.floor
        for i = 1, #text, 4 do
            local a, b, c, d = byte(text, i, i + 3)
            local x = (B64Map[a] or 0) * 262144 + (B64Map[b] or 0) * 4096 + (B64Map[c] or 0) * 64 + (B64Map[d] or 0)
            local b1, b2, b3 = floor(x / 65536), floor(x / 256) % 256, x % 256
            n += 1
            if c == 61 then
                out[n] = char(b1)
            elseif d == 61 then
                out[n] = char(b1, b2)
            else
                out[n] = char(b1, b2, b3)
            end
        end
        return table.concat(out)
    end

    local writeFn, readFn, isFileFn, assetFn
    local apiChecked, apiOk = false, false
    local function checkApi()
        if apiChecked then
            return apiOk
        end
        apiChecked = true
        writeFn = findFn("writefile")
        readFn = findFn("readfile")
        isFileFn = findFn("isfile")
        assetFn = findFn("getcustomasset") or findFn("getsynasset")
        apiOk = writeFn ~= nil and assetFn ~= nil
        return apiOk
    end

    -- sounds live in a folder when possible, otherwise in the workspace root with a prefix
    local sfxBase
    local refreshFiles = false -- true when the folder holds files from another version
    local function resolveBase()
        if sfxBase then
            return sfxBase
        end
        sfxBase = "NIER_UI_"
        local makeFolder, isFolder = findFn("makefolder"), findFn("isfolder")
        if makeFolder then
            local folderReady = false
            if isFolder then
                local okI, exists = pcall(isFolder, SFX_FOLDER)
                folderReady = okI and exists == true
            end
            if folderReady or pcall(makeFolder, SFX_FOLDER) then
                sfxBase = SFX_FOLDER .. "/"
            end
        end
        -- version marker: if it is missing or different, rewrite the embedded sounds once
        local marker = sfxBase .. "_version.txt"
        local current
        if isFileFn and readFn then
            local okF, exists = pcall(isFileFn, marker)
            if okF and exists then
                local okR, content = pcall(readFn, marker)
                current = okR and content or nil
            end
        end
        if current ~= SFX_VERSION then
            refreshFiles = true
            pcall(writeFn, marker, SFX_VERSION)
        end
        return sfxBase
    end

    local function ensureFile(name, entry)
        local path = resolveBase() .. entry.file
        local keep = false
        if isFileFn and not refreshFiles then
            local okF, exists = pcall(isFileFn, path)
            if okF and exists then
                if readFn then
                    local okR, content = pcall(readFn, path)
                    keep = okR and type(content) == "string" and #content > 256
                else
                    keep = true
                end
            end
        end
        if not keep then
            writeFn(path, decodeBase64(SfxData[name]))
        end
        return path
    end

    -- each Sound is created lazily on first use (and pre-warmed below)
    local function getSound(name)
        local entry = Sfx[name]
        if not entry or entry.failed or entry.busy then
            return nil
        end
        local existing = entry.sound
        if existing and existing.Parent then
            return existing
        end
        if not checkApi() then
            entry.failed = true
            return nil
        end
        if not SfxData[name] then
            return nil -- embedded data not defined yet; don't mark the sound as failed
        end
        entry.busy = true
        local ok, result = pcall(function()
            local path = ensureFile(name, entry)
            local sound = Instance.new("Sound")
            sound.Name = "NIER_UI_Sfx_" .. name
            sound.Volume = 0
            sound.SoundId = assetFn(path)
            sound.Parent = SoundService
            return sound
        end)
        entry.busy = false
        if ok and result then
            entry.sound = result
            return result
        end
        entry.failed = true
        return nil
    end

    local ContentProvider = game:GetService("ContentProvider")

    local function playSound(sound, entry, pitch)
        sound.Volume = entry.gain * math.clamp(tonumber(Library.SoundVolume) or 1, 0, 1)
        sound.PlaybackSpeed = pitch or 1
        sound.TimePosition = 0
        sound:Play()
    end

    -- pitch (optional): playback speed, 1 = normal. Used by the slider so the tick follows the value.
    function Library._sfx(name, pitch)
        if not Library.SoundEnabled then
            return
        end
        local entry = Sfx[name]
        if not entry then
            return
        end
        local now = os.clock()
        if now - (entry.last or -1) < entry.gap then
            return
        end
        local sound = getSound(name)
        if not sound then
            return
        end
        entry.last = now
        if sound.IsLoaded then
            playSound(sound, entry, pitch)
            return
        end
        -- The sound is still loading (typical for the "open" sound when the window opens right after
        -- the library is loaded). Calling Play() on an unloaded Sound can silently do nothing,
        -- so wait until it is loaded (max 3 s), then play it.
        task.spawn(function()
            local t0 = os.clock()
            while not sound.IsLoaded and sound.Parent and os.clock() - t0 < 3 do
                task.wait()
            end
            if sound.Parent and Library.SoundEnabled then
                playSound(sound, entry, pitch)
            end
        end)
    end

    function Library:SetSoundEnabled(state)
        Library.SoundEnabled = state == true
    end
    function Library:SetSoundVolume(value)
        Library.SoundVolume = math.clamp(tonumber(value) or 1, 0, 1)
    end

    -- Called from new() for every Instance the library creates.
    -- Buttons get a hover tick + select sound automatically; drag areas (ZIndex >= 5) are skipped.
    local touchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    Library._onNew = function(inst, class, props)
        if class == "ImageButton" then
            if props.Name ~= "SettingsGearBtn" then
                return
            end
        elseif class == "TextButton" then
            if (tonumber(props.ZIndex) or 0) >= 5 then
                return
            end
        else
            return
        end
        if not touchOnly then
            inst.MouseEnter:Connect(function()
                Library._sfx("hover")
            end)
        end
        inst.MouseButton1Click:Connect(function()
            -- rows that play their own sound (toggles) set this attribute to skip the generic one
            if not inst:GetAttribute("NoSelectSfx") then
                Library._sfx("select")
            end
        end)
    end

    -- (the pre-load of every sound is at the very end of this block, AFTER the embedded audio data,
    --  because task.spawn runs immediately and the first sound would otherwise be created with no data)

    -- ---------------------------------------------------------------- embedded audio data

    -- open_menu.ogg
    SfxData.open = [==[
T2dnUwACAAAAAAAAAAC3IgUMAAAAANyCqEIBHgF2b3JiaXMAAAAAAkSsAAAAAAAAAHECAAAAAAC4AU9nZ1MAAAAAAAAAAAAAtyIF
DAEAAABDtENuEkD/////////////////////kQN2b3JiaXMNAAAATGF2ZjYwLjE2LjEwMAEAAAAfAAAAZW5jb2Rlcj1MYXZjNjAu
MzEuMTAyIGxpYnZvcmJpcwEFdm9yYmlzKUJDVgEACAAAADFMIMWA0JBVAAAQAABgJCkOk2ZJKaWUoSh5mJRISSmllMUwiZiUicUY
Y4wxxhhjjDHGGGOMIDRkFQAABACAKAmOo+ZJas45ZxgnjnKgOWlOOKcgB4pR4DkJwvUmY26mtKZrbs4pJQgNWQUAAAIAQEghhRRS
SCGFFGKIIYYYYoghhxxyyCGnnHIKKqigggoyyCCDTDLppJNOOumoo4466ii00EILLbTSSkwx1VZjrr0GXXxzzjnnnHPOOeecc84J
QkNWAQAgAAAEQgYZZBBCCCGFFFKIKaaYcgoyyIDQkFUAACAAgAAAAABHkRRJsRTLsRzN0SRP8ixREzXRM0VTVE1VVVVVdV1XdmXX
dnXXdn1ZmIVbuH1ZuIVb2IVd94VhGIZhGIZhGIZh+H3f933f930gNGQVACABAKAjOZbjKaIiGqLiOaIDhIasAgBkAAAEACAJkiIp
kqNJpmZqrmmbtmirtm3LsizLsgyEhqwCAAABAAQAAAAAAKBpmqZpmqZpmqZpmqZpmqZpmqZpmmZZlmVZlmVZlmVZlmVZlmVZlmVZ
lmVZlmVZlmVZlmVZlmVZlmVZQGjIKgBAAgBAx3Ecx3EkRVIkx3IsBwgNWQUAyAAACABAUizFcjRHczTHczzHczxHdETJlEzN9EwP
CA1ZBQAAAgAIAAAAAABAMRzFcRzJ0SRPUi3TcjVXcz3Xc03XdV1XVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVYHQ
kFUAAAQAACGdZpZqgAgzkGEgNGQVAIAAAAAYoQhDDAgNWQUAAAQAAIih5CCa0JrzzTkOmuWgqRSb08GJVJsnuamYm3POOeecbM4Z
45xzzinKmcWgmdCac85JDJqloJnQmnPOeRKbB62p0ppzzhnnnA7GGWGcc85p0poHqdlYm3POWdCa5qi5FJtzzomUmye1uVSbc845
55xzzjnnnHPOqV6czsE54Zxzzonam2u5CV2cc875ZJzuzQnhnHPOOeecc84555xzzglCQ1YBAEAAAARh2BjGnYIgfY4GYhQhpiGT
HnSPDpOgMcgppB6NjkZKqYNQUhknpXSC0JBVAAAgAACEEFJIIYUUUkghhRRSSCGGGGKIIaeccgoqqKSSiirKKLPMMssss8wyy6zD
zjrrsMMQQwwxtNJKLDXVVmONteaec645SGultdZaK6WUUkoppSA0ZBUAAAIAQCBkkEEGGYUUUkghhphyyimnoIIKCA1ZBQAAAgAI
AAAA8CTPER3RER3RER3RER3RER3P8RxREiVREiXRMi1TMz1VVFVXdm1Zl3Xbt4Vd2HXf133f141fF4ZlWZZlWZZlWZZlWZZlWZZl
CUJDVgEAIAAAAEIIIYQUUkghhZRijDHHnINOQgmB0JBVAAAgAIAAAAAAR3EUx5EcyZEkS7IkTdIszfI0T/M00RNFUTRNUxVd0RV1
0xZlUzZd0zVl01Vl1XZl2bZlW7d9WbZ93/d93/d93/d93/d939d1IDRkFQAgAQCgIzmSIimSIjmO40iSBISGrAIAZAAABACgKI7i
OI4jSZIkWZImeZZniZqpmZ7pqaIKhIasAgAAAQAEAAAAAACgaIqnmIqniIrniI4oiZZpiZqquaJsyq7ruq7ruq7ruq7ruq7ruq7r
uq7ruq7ruq7ruq7ruq7ruq7rukBoyCoAQAIAQEdyJEdyJEVSJEVyJAcIDVkFAMgAAAgAwDEcQ1Ikx7IsTfM0T/M00RM90TM9VXRF
FwgNWQUAAAIACAAAAAAAwJAMS7EczdEkUVIt1VI11VItVVQ9VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV1TRN0zSB
0JCVAAAZAADkpKbUeg4SYpA5iUFoCEnEHMVcOumco1yMh5AjRkntIVPMEAS1mNBJhRTU4lpqHXNUi42tZEhBLbbGUiHlqAdCQ1YI
AKEZAA7HARxNAxxLAwAAAAAAAABJ0wBNFAHNEwEAAAAAAADA0TRAEz1AE0UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABxNAzRRBDRRBAAAAAAAAABNFAHRVAHRNAEAAAAAAABAE0XAM0VA
NFUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABxNAzRR
BDRRBAAAAAAAAABNFAFRNQFPNAEAAAAAAABAE0VANE1AVE0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAABDgAAARZCoSErAoA4AQCH40CSIEnw
NIBjWfA8eBpME+BYFjwPmgfTBAAAAAAAAAAAAEDyNHgePA+mCZA0D54Hz4NpAgAAAAAAAAAAACB5HjwPngfTBEieB8+D58E0AQAA
AAAAAAAAAPBME6YJ0YRqAjzThGnCNGGqAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIABBwCAABPKQKEhKwKAOAEAh6NIEgAAOJJk
WQAAoEiSZQEAgGVZngcAAJJleR4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAgAAAgAEHAIAAE8pAoSErAYAoAACHolgWcBzLAo5jWUCSLAtgWQBNA3gaQBQBgAAAgAIHAIAAGzQlFgcoNGQlABAF
AOBwFMvSNFHkOJalaaLIcSxL00SRZWmapokiNEvTRBGe53mmCc/zPNOEKIqiaQJRNE0BAAAFDgAAATZoSiwOUGjISgAgJADA4TiW
5XmiKIqmaZqqynEsy/NEURRNU1Vdl+NYlueJoiiapqq6LsvSNM8TRVE0TVV1XWia54miKJqmqrouNE0UTdM0VVVVXRea5ommaZqq
qqquC88TRdM0TVV1XdcFomiapqmqruu6QBRN0zRV1XVdF4iiaJqmqrqu6wLTNE1VVV3XlWWAaaqqqrquLANUVVVd15VlGaCqquq6
rivLANd1XdmVZVkG4LquK8uyLAAA4MABACDACDrJqLIIG0248AAUGrIiAIgCAACMYUoxpQxjEkIKoWFMQkghZFJSKimlCkIqJZVS
QUilpFIySi2lllIFIZWSSqkgpFJSKQUAgB04AIAdWAiFhqwEAPIAAAhjlGLMOeckQkox5pxzEiGlGHPOOakUY84555yUkjHnnHNO
SsmYc845J6VkzDnnnJNSOueccw5KKaV0zjnnpJRSQuicc1JKKZ1zzjkBAEAFDgAAATaKbE4wElRoyEoAIBUAwOA4lqVpnieKpmlJ
kqZ5nieapmlqkqRpnieKpmmaPM/zRFEUTVNVeZ7niaIomqaqcl1RFE3TNE1VJcuiKIqmqaqqCtM0TdNUVVWFaZqmaaqq68K2VVVV
Xdd1Yduqqqqu67rAdV3XdWUZuK7ruq4sCwAAT3AAACqwYXWEk6KxwEJDVgIAGQAAhDEIKYQQUgYhpBBCSCmFkAAAgAEHAIAAE8pA
oSErAYBwAACAEIwxxhhjjDE2jGGMMcYYY4wxcQpjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhj
jDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcYYY4wxxhhjjDHGGGOMMcbYWmuttVYA
GM6FA0BZhI0zrCSdFY4GFxqyEgAICQAAjEGIMegklJJKShVCjDkoJZWWWoqtQogxCKWk1FpsMRbPOQehpJRaiim24jnnpKTUWowx
xlpcCyGllFqLLbYYm2whpJRSazHGWmMzSrWUWosxxhhrLEq5lFJrscUYa41FKJtbazHGWmutNSnlc0ux1VpjrLUmo4ySMcZaa6y1
1iKUUjLGFFOstdaahDDG9xhjrDHnWpMSwvgeUy2x1VprUkopI2SNqcZac05KCWWMjS3VlHPOBQBAPTgAQCUYQScZVRZhowkXHoBC
Q1YCALkBAAhCSjHGmHPOOeeccw5SpBhzzDnnIIQQQgghpAgxxphzzkEIIYQQQkgZY8w55yCEEEIIoYSSUsqYc85BCCGEUkopJaXU
OecghBBCKKWUUkpKqXPOQQghhFJKKaWUlFIIIYQQQgillFJKKSmllEIIIYQSSimllFJSSimFEEIIpZRSSimlpJRSCiGEEEoppZRS
SkkppRRCCaWUUkoppZSSUkoppRBKKaWUUkopJaWUUkqllFJKKaWUUkpKKaWUSimllFJKKaWUlFJKKZVSSimllFJKKSmllFJKqZRS
SimllFJSSimllFIppZRSSimlpJRSSimlUkoppZRSSkkppZRSSqWUUkoppZSSUkoppZRSKqWUUkoppQAAoAMHAIAAIyotxE4zrjwC
RxQyTECFhqwEAMgAABAHsbTWWquMcspJSa1DRhrmoKTYSQchtVhLZSBByklKnYIIKQaphYwqpZiTlkLLmFIMYisxdIwxRznlVELH
GAAAAIIAAAMRMhMIFECBgQwAOEBIkAIACgsMHcNFQEAuIaPAoHBMOCedNgAAQYjMEImIxSAxoRooKqYDgMUFhnwAyNDYSLu4gC4D
XNDFXQdCCEIQglgcQAEJODjhhife8IQbnKBTVOpAAAAAAAAeAOABACDZACIiopnj6PD4AAkRGSEpMTlBEQAAAAAAOwD4AABIUoCI
iGjmODo8PkBCREZISkxOUAIAAAEEAAAAAEAAAQgICAAAAAAABAAAAAgIT2dnUwAAQK4AAAAAAAC3IgUMAgAAAI1H2x5ZMP9O/2T/
eP9y/4r/j/+J/67/tP+w/5v/mf+X/47/j/+X/5T/of99/4X/jf+P/3f/dv94/43/i/99/4T/h/94/3X/e/+L/5r/hv+b/5T/lP+R
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
DAMAAAA5lC+MAgEBDg4=
]==]

    -- close_menu.ogg
    SfxData.close = [==[
T2dnUwACAAAAAAAAAACzVqOeAAAAAASryIYBHgF2b3JiaXMAAAAAAkSsAAAAAAAAAGsDAAAAAAC4AU9nZ1MAAAAAAAAAAAAAs1aj
ngEAAABTlz8CEED//////////////////3EDdm9yYmlzDQAAAExhdmY2MC4xNi4xMDABAAAAHwAAAGVuY29kZXI9TGF2YzYwLjMx
LjEwMiBsaWJ2b3JiaXMBBXZvcmJpcytCQ1YBAAgAAAAxTCDFgNCQVQAAEAAAYCQpDpNmSSmllKEoeZiUSEkppZTFMImYlInFGGOM
McYYY4wxxhhjjCA0ZBUAAAQAgCgJjqPmSWrOOWcYJ45yoDlpTjinIAeKUeA5CcL1JmNuprSma27OKSUIDVkFAAACAEBIIYUUUkgh
hRRiiCGGGGKIIYcccsghp5xyCiqooIIKMsggg0wy6aSTTjrpqKOOOuootNBCCy200kpMMdVWY669Bl18c84555xzzjnnnHPOCUJD
VgEAIAAABEIGGWQQQgghhRRSiCmmmHIKMsiA0JBVAAAgAIAAAAAAR5EUSbEUy7EczdEkT/IsURM10TNFU1RNVVVVVXVdV3Zl13Z1
13Z9WZiFW7h9WbiFW9iFXfeFYRiGYRiGYRiGYfh93/d93/d9IDRkFQAgAQCgIzmW4ymiIhqi4jmiA4SGrAIAZAAABAAgCZIiKZKj
SaZmaq5pm7Zoq7Zty7Isy7IMhIasAgAAAQAEAAAAAACgaZqmaZqmaZqmaZqmaZqmaZqmaZpmWZZlWZZlWZZlWZZlWZZlWZZlWZZl
WZZlWZZlWZZlWZZlWZZlWUBoyCoAQAIAQMdxHMdxJEVSJMdyLAcIDVkFAMgAAAgAQFIsxXI0R3M0x3M8x3M8R3REyZRMzfRMDwgN
WQUAAAIACAAAAAAAQDEcxXEcydEkT1It03I1V3M913NN13VdV1VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVWB0JBV
AAAEAAAhnWaWaoAIM5BhIDRkFQCAAAAAGKEIQwwIDVkFAAAEAACIoeQgmtCa8805DprloKkUm9PBiVSbJ7mpmJtzzjnnnGzOGeOc
c84pypnFoJnQmnPOSQyapaCZ0JpzznkSmwetqdKac84Z55wOxhlhnHPOadKaB6nZWJtzzlnQmuaouRSbc86JlJsntblUm3POOeec
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
lGosDUHMQYmxZcYg5aDVGCqElINWW8gUQspRail0TCkmKaYSOqYUpBhbayV0kFrNubZUSgsAAIAgAMBAhMwEAgVQYCADAA4QEqQA
gMICQ8dwERCQS8goMCgcE85Jpw0AQBAiM0QiYjFITKgGiorpAGBxgSEfADI0NtIuLqDLABd0cdeBEIIQhCAWB1BAAg5OuOGJNzzh
BifoFJU6EAAAAAAACAB4AABINoCIaGbmODo8PkBCREZISkxOUFJUBAAAAAAAEAA+AACSFSAimpk5jg6PD5AQkRGSEpMTlBSVAABA
AAEAAAAAEEAAAgICAAAAAAABAAAAAgJPZ2dTAADArQAAAAAAALNWo54CAAAARHidmV4BAQEBAQFevquo//8u/+H/7//y/+X/4f/e
/+D/6P/J/8X/uP+9/7H/vP/B/8X/qv+5/7j/t/+r/7r/tf/Y/8j/yP/a/9f/5v/b/9//4v/j/+f/0v/m//T/7///AP/iAAoGAAAA
vPwMiRCev0vK1FO2xnegrrQUe6cLU8lk34+9AaWYGQDUa13e62p/RzZNWZa1/vvbaW3BWmuf14cPr99av9/v9/v9Hlso9FTXJePC
q9A1f/BsbqPTxTz6KJ9/2IsjBQQJYwI1qFzY7t7NUAWas3H4SRil/I9nnPGNmdWadj5i1ev1Yvroj1xaP30kps2r1szOnlZz/PpZ
2Wrl0yqKudrX82XmVPnn+vPk+vpn9nPN2eebGY8nZx2X/udjLf18H/ls7H0Xp2+5IjtWAL+ffxqNFqfH3ELv/tP4UngYVxQ6s9lY
kk0UCRZ8U0movY8OLd2PUMMMUPJ5bvnHC4JFs1qcxuIuCQb14BKdrrK80hvFdoR6WDzjs+8LKrq21AWEAR3Ul0rtg4stDBiAfEu2
vHCxy5OThtrv61SzZvqqmVZT25+HoigV51mOor+k1RnFLkevPK45KStZjY65YKRq46lbTna1K4UiYiIa7yfjePLYO3ZZVlWV2d+7
0VFQrILCs0vL9cRXkgT0MGIWyYMXsQWR7sEK98WJ5W/YFlsG/U2p4VWEZt/F9X/To1UotEb1fw3hUmegYSQMglN9GffNAUFyvx0U
SptNXgBs/RQQxg2798nbqx9DCQzx+F9Gj/fBa1qO2VDZ5cR6ma22Lvvj+1cVa/x+WjHzKUcUBypClcwpkVGr9mqWp/upnK1Usx5B
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
AOAop2UWFDIA
]==]

    -- hover_tick.ogg
    SfxData.hover = [==[
T2dnUwACAAAAAAAAAABvg0ZWAAAAAFPI+AUBHgF2b3JiaXMAAAAAAkSsAAAAAAAAAGsDAAAAAAC4AU9nZ1MAAAAAAAAAAAAAb4NG
VgEAAACWx6NUEED//////////////////3EDdm9yYmlzDQAAAExhdmY2MC4xNi4xMDABAAAAHwAAAGVuY29kZXI9TGF2YzYwLjMx
LjEwMiBsaWJ2b3JiaXMBBXZvcmJpcytCQ1YBAAgAAAAxTCDFgNCQVQAAEAAAYCQpDpNmSSmllKEoeZiUSEkppZTFMImYlInFGGOM
McYYY4wxxhhjjCA0ZBUAAAQAgCgJjqPmSWrOOWcYJ45yoDlpTjinIAeKUeA5CcL1JmNuprSma27OKSUIDVkFAAACAEBIIYUUUkgh
hRRiiCGGGGKIIYcccsghp5xyCiqooIIKMsggg0wy6aSTTjrpqKOOOuootNBCCy200kpMMdVWY669Bl18c84555xzzjnnnHPOCUJD
VgEAIAAABEIGGWQQQgghhRRSiCmmmHIKMsiA0JBVAAAgAIAAAAAAR5EUSbEUy7EczdEkT/IsURM10TNFU1RNVVVVVXVdV3Zl13Z1
13Z9WZiFW7h9WbiFW9iFXfeFYRiGYRiGYRiGYfh93/d93/d9IDRkFQAgAQCgIzmW4ymiIhqi4jmiA4SGrAIAZAAABAAgCZIiKZKj
SaZmaq5pm7Zoq7Zty7Isy7IMhIasAgAAAQAEAAAAAACgaZqmaZqmaZqmaZqmaZqmaZqmaZpmWZZlWZZlWZZlWZZlWZZlWZZlWZZl
WZZlWZZlWZZlWZZlWZZlWUBoyCoAQAIAQMdxHMdxJEVSJMdyLAcIDVkFAMgAAAgAQFIsxXI0R3M0x3M8x3M8R3REyZRMzfRMDwgN
WQUAAAIACAAAAAAAQDEcxXEcydEkT1It03I1V3M913NN13VdV1VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVWB0JBV
AAAEAAAhnWaWaoAIM5BhIDRkFQCAAAAAGKEIQwwIDVkFAAAEAACIoeQgmtCa8805DprloKkUm9PBiVSbJ7mpmJtzzjnnnGzOGeOc
c84pypnFoJnQmnPOSQyapaCZ0JpzznkSmwetqdKac84Z55wOxhlhnHPOadKaB6nZWJtzzlnQmuaouRSbc86JlJsntblUm3POOeec
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
]==]

    -- tab_toggle_select.ogg
    SfxData.select = [==[
T2dnUwACAAAAAAAAAACZERWGAAAAAKAEIIcBHgF2b3JiaXMAAAAAAkSsAAAAAAAAAGsDAAAAAAC4AU9nZ1MAAAAAAAAAAAAAmREV
hgEAAAAflKgkEED//////////////////3EDdm9yYmlzDQAAAExhdmY2MC4xNi4xMDABAAAAHwAAAGVuY29kZXI9TGF2YzYwLjMx
LjEwMiBsaWJ2b3JiaXMBBXZvcmJpcytCQ1YBAAgAAAAxTCDFgNCQVQAAEAAAYCQpDpNmSSmllKEoeZiUSEkppZTFMImYlInFGGOM
McYYY4wxxhhjjCA0ZBUAAAQAgCgJjqPmSWrOOWcYJ45yoDlpTjinIAeKUeA5CcL1JmNuprSma27OKSUIDVkFAAACAEBIIYUUUkgh
hRRiiCGGGGKIIYcccsghp5xyCiqooIIKMsggg0wy6aSTTjrpqKOOOuootNBCCy200kpMMdVWY669Bl18c84555xzzjnnnHPOCUJD
VgEAIAAABEIGGWQQQgghhRRSiCmmmHIKMsiA0JBVAAAgAIAAAAAAR5EUSbEUy7EczdEkT/IsURM10TNFU1RNVVVVVXVdV3Zl13Z1
13Z9WZiFW7h9WbiFW9iFXfeFYRiGYRiGYRiGYfh93/d93/d9IDRkFQAgAQCgIzmW4ymiIhqi4jmiA4SGrAIAZAAABAAgCZIiKZKj
SaZmaq5pm7Zoq7Zty7Isy7IMhIasAgAAAQAEAAAAAACgaZqmaZqmaZqmaZqmaZqmaZqmaZpmWZZlWZZlWZZlWZZlWZZlWZZlWZZl
WZZlWZZlWZZlWZZlWZZlWUBoyCoAQAIAQMdxHMdxJEVSJMdyLAcIDVkFAMgAAAgAQFIsxXI0R3M0x3M8x3M8R3REyZRMzfRMDwgN
WQUAAAIACAAAAAAAQDEcxXEcydEkT1It03I1V3M913NN13VdV1VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVWB0JBV
AAAEAAAhnWaWaoAIM5BhIDRkFQCAAAAAGKEIQwwIDVkFAAAEAACIoeQgmtCa8805DprloKkUm9PBiVSbJ7mpmJtzzjnnnGzOGeOc
c84pypnFoJnQmnPOSQyapaCZ0JpzznkSmwetqdKac84Z55wOxhlhnHPOadKaB6nZWJtzzlnQmuaouRSbc86JlJsntblUm3POOeec
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
]==]

    -- toggle_on.ogg
    SfxData.toggleOn = [==[
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
E0UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABxNAzTP
AzTPAwAAAAAAAADL8wBPFAHPEwEAAAAAAABA8zzAE0XAE0UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAABDgAAARZCoSErAoA4AQCHJEGSIEnQ
NIBkWdA0aBpMEyBZFjQNmgbTBAAAAAAAAAAAAEDyNGgaNA2iCJA0D5oGTYMoAgAAAAAAAAAAACBpGjQNmgZRBEiaBk2DpkEUAQAA
AAAAAAAAANBME6IIUYRpAjzThChCFGGaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIABBwCAABPKQKEhKwKAOAEAh6JYFgAAOJJj
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
]==]

    -- toggle_off.ogg
    SfxData.toggleOff = [==[
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
E0UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABxNAzTP
AzTPAwAAAAAAAADL8wBPFAHPEwEAAAAAAABA8zzAE0XAE0UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAABDgAAARZCoSErAoA4AQCHJEGSIEnQ
NIBkWdA0aBpMEyBZFjQNmgbTBAAAAAAAAAAAAEDyNGgaNA2iCJA0D5oGTYMoAgAAAAAAAAAAACBpGjQNmgZRBEiaBk2DpkEUAQAA
AAAAAAAAANBME6IIUYRpAjzThChCFGGaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIABBwCAABPKQKEhKwKAOAEAh6JYFgAAOJJj
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
]==]

    -- notify.ogg
    SfxData.notify = [==[
T2dnUwACAAAAAAAAAAAtp8B3AAAAABQ+/ZIBHgF2b3JiaXMAAAAAAkSsAAAAAAAAAPQBAAAAAAC4AU9nZ1MAAAAAAAAAAAAALafA
dwEAAAAPN+egEkD/////////////////////PAN2b3JiaXMNAAAATGF2ZjYwLjE2LjEwMAEAAAAfAAAAZW5jb2Rlcj1MYXZjNjAu
MzEuMTAyIGxpYnZvcmJpcwEFdm9yYmlzKUJDVgEACAAAgCJMGMSA0JBVAAAQAACgrDeWe8i99957gahHFHuIvffee+OsR9B6iLn3
3nvuvacae8u9995zIDRkFQAABACAKQiacuBC6r33HhnmEVEaKse99x4ZhYkwlBmFPZXaWushk9xC6j3nHggNWQUAAAIAQAghhBRS
SCGFFFJIIYUUUkgppZhiiimmmGLKKaccc8wxxyCDDjropJNQQgkppFBKKqmklFJKLdZac+69B91z70H4IIQQQgghhBBCCCGEEEII
QkNWAQAgAAAEQgghZBBCCCGEFFJIIaaYYsopp4DQkFUAACAAgAAAAABJkRTLsRzN0RzN8RzPESVREiXRMi3TUjVTMz1VVEXVVFVX
VV1dd23Vdm3Vlm3XVm3Vdm3VVm1Ztm3btm3btm3btm3btm3btm0gNGQVACABAKAjOZIjKZIiKZLjOJIEhIasAgBkAAAEAKAoiuM4
juRIjiVpkmZ5lmeJmqiZmuipngqEhqwCAAABAAQAAAAAAOB4iud4jmd5kud4jmd5mqdpmqZpmqZpmqZpmqZpmqZpmqZpmqZpmqZp
mqZpmqZpmqZpmqZpmqZpmqZpQGjIKgBAAgBAx3Ecx3Ecx3EcR3IkBwgNWQUAyAAACABAUiTHcixHczTHczxHdETHdEzJlFTJtVwL
CA1ZBQAAAgAIAAAAAABAEyxFUzzHkzzPEzXP0zTNE01RNE3TNE3TNE3TNE3TNE3TNE3TNE3TNE3TNE3TNE3TNE3TNE3TNE1TFIHQ
kFUAAAQAACGdZpZqgAgzkGEgNGQVAIAAAAAYoQhDDAgNWQUAAAQAAIih5CCa0JrzzTkOmuWgqRSb08GJVJsnuamYm3POOeecbM4Z
45xzzinKmcWgmdCac85JDJqloJnQmnPOeRKbB62p0ppzzhnnnA7GGWGcc85p0poHqdlYm3POWdCa5qi5FJtzzomUmye1uVSbc845
55xzzjnnnHPOqV6czsE54Zxzzonam2u5CV2cc875ZJzuzQnhnHPOOeecc84555xzzglCQ1YBAEAAAARh2BjGnYIgfY4GYhQhpiGT
HnSPDpOgMcgppB6NjkZKqYNQUhknpXSC0JBVAAAgAACEEFJIIYUUUkghhRRSSCGGGGKIIaeccgoqqKSSiirKKLPMMssss8wyy6zD
zjrrsMMQQwwxtNJKLDXVVmONteaec645SGultdZaK6WUUkoppSA0ZBUAAAIAQCBkkEEGGYUUUkghhphyyimnoIIKCA1ZBQAAAgAI
AAAA8CTPER3RER3RER3RER3RER3P8RxREiVREiXRMi1TMz1VVFVXdm1Zl3Xbt4Vd2HXf133f141fF4ZlWZZlWZZlWZZlWZZlWZZl
CUJDVgEAIAAAAEIIIYQUUkghhZRijDHHnINOQgmB0JBVAAAgAIAAAAAAR3EUx5EcyZEkS7IkTdIszfI0T/M00RNFUTRNUxVd0RV1
0xZlUzZd0zVl01Vl1XZl2bZlW7d9WbZ93/d93/d93/d93/d939d1IDRkFQAgAQCgIzmSIimSIjmO40iSBISGrAIAZAAABACgKI7i
OI4jSZIkWZImeZZniZqpmZ7pqaIKhIasAgAAAQAEAAAAAACgaIqnmIqniIrniI4oiZZpiZqquaJsyq7ruq7ruq7ruq7ruq7ruq7r
uq7ruq7ruq7ruq7ruq7ruq7rukBoyCoAQAIAQEdyJEdyJEVSJEVyJAcIDVkFAMgAAAgAwDEcQ1Ikx7IsTfM0T/M00RM90TM9VXRF
FwgNWQUAAAIACAAAAAAAwJAMS7EczdEkUVIt1VI11VItVVQ9VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV1TRN0zSB
0JCVAAAZAADDtOTScs+NoEgqR7XWklHlJMUcGoqgglZzDRU0iEmLIWIKISYxlg46ppzUGlMpGXNUc2whVIhJDTqmUikGLQhCQ1YI
AKEZAA7HASTLAiRLAwAAAAAAAABJ0wDN8wDL8wAAAAAAAABA0jTA8jRA8zwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACRNAzTPAzTPAwAAAAAAAADN8wBPFAFPFAEAAAAAAADA8jzAEz3A
E0UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABxNAzTP
AzTPAwAAAAAAAADL8wBPFAHPEwEAAAAAAABA8zzAE0XAE0UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAABDgAAARZCoSErAoA4AQCHJEGSIEnQ
NIBkWdA0aBpMEyBZFjQNmgbTBAAAAAAAAAAAAEDyNGgaNA2iCJA0D5oGTYMoAgAAAAAAAAAAACBpGjQNmgZRBEiaBk2DpkEUAQAA
AAAAAAAAANBME6IIUYRpAjzThChCFGGaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIABBwCAABPKQKEhKwKAOAEAh6JYFgAAOJJj
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
]==]

    -- slider_video_tick.ogg: exact short tick sample verified against the provided demo video
    SfxData.slider = [==[
T2dnUwACAAAAAAAAAABvg0ZWAAAAAFPI+AUBHgF2b3JiaXMAAAAAAkSsAAAAAAAAAGsDAAAAAAC4AU9nZ1MAAAAAAAAAAAAAb4NGVgEAAACW
x6NUEED//////////////////3EDdm9yYmlzDQAAAExhdmY2MC4xNi4xMDABAAAAHwAAAGVuY29kZXI9TGF2YzYwLjMxLjEwMiBsaWJ2b3Ji
aXMBBXZvcmJpcytCQ1YBAAgAAAAxTCDFgNCQVQAAEAAAYCQpDpNmSSmllKEoeZiUSEkppZTFMImYlInFGGOMMcYYY4wxxhhjjCA0ZBUAAAQA
gCgJjqPmSWrOOWcYJ45yoDlpTjinIAeKUeA5CcL1JmNuprSma27OKSUIDVkFAAACAEBIIYUUUkghhRRiiCGGGGKIIYcccsghp5xyCiqooIIK
Msggg0wy6aSTTjrpqKOOOuootNBCCy200kpMMdVWY669Bl18c84555xzzjnnnHPOCUJDVgEAIAAABEIGGWQQQgghhRRSiCmmmHIKMsiA0JBV
AAAgAIAAAAAAR5EUSbEUy7EczdEkT/IsURM10TNFU1RNVVVVVXVdV3Zl13Z113Z9WZiFW7h9WbiFW9iFXfeFYRiGYRiGYRiGYfh93/d93/d9
IDRkFQAgAQCgIzmW4ymiIhqi4jmiA4SGrAIAZAAABAAgCZIiKZKjSaZmaq5pm7Zoq7Zty7Isy7IMhIasAgAAAQAEAAAAAACgaZqmaZqmaZqm
aZqmaZqmaZqmaZpmWZZlWZZlWZZlWZZlWZZlWZZlWZZlWZZlWZZlWZZlWZZlWZZlWUBoyCoAQAIAQMdxHMdxJEVSJMdyLAcIDVkFAMgAAAgA
QFIsxXI0R3M0x3M8x3M8R3REyZRMzfRMDwgNWQUAAAIACAAAAAAAQDEcxXEcydEkT1It03I1V3M913NN13VdV1VVVVVVVVVVVVVVVVVVVVVV
VVVVVVVVVVVVVVVVVVVVVVWB0JBVAAAEAAAhnWaWaoAIM5BhIDRkFQCAAAAAGKEIQwwIDVkFAAAEAACIoeQgmtCa8805DprloKkUm9PBiVSb
J7mpmJtzzjnnnGzOGeOcc84pypnFoJnQmnPOSQyapaCZ0JpzznkSmwetqdKac84Z55wOxhlhnHPOadKaB6nZWJtzzlnQmuaouRSbc86JlJsn
tblUm3POOeecc84555xzzqlenM7BOeGcc86J2ptruQldnHPO+WSc7s0J4ZxzzjnnnHPOOeecc84JQkNWAQBAAAAEYdgYxp2CIH2OBmIUIaYh
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
]==]
    -- Dedicated filename prevents an older slider cache from shadowing this video-matched sample.
    Sfx.slider.file = "slider_video_tick.ogg"

    -- ---------------------------------------------------------------- fast playback (voice pool + preload)
    -- Every sound gets a few ready-made Sound objects ("voices"). They are created ONCE while the
    -- library loads, pre-loaded with ContentProvider, and then reused forever (round-robin).
    -- Playing a sound = set volume/speed + :Play(). Nothing is created, written to disk or decoded
    -- at play time, and quick repeats (slider drag, hover) overlap instead of cutting each other off.
    -- This block replaces the old getSound / playSound path: Library._sfx below overrides the old one.
    local VOICES = { open = 1, close = 1, select = 2, hover = 3, toggleOn = 2, toggleOff = 2, notify = 1, slider = 4 }
    -- tick-type sounds are simply skipped while their file is still loading (a late tick sounds wrong)
    local DROP_WHILE_LOADING = { hover = true, slider = true }
    local pools, building = {}, {}

    local function buildPool(name)
        local entry = Sfx[name]
        if not entry or entry.failed then
            return nil
        end
        if pools[name] then
            return pools[name]
        end
        if building[name] then
            return nil
        end
        if not checkApi() then
            entry.failed = true
            return nil
        end
        if not SfxData[name] then
            return nil -- embedded data not defined (yet); don't mark the sound as failed
        end
        building[name] = true
        local list = {}
        local ok = pcall(function()
            local assetId = assetFn(ensureFile(name, entry))
            for i = 1, (VOICES[name] or 1) do
                local sound = Instance.new("Sound")
                sound.Name = "NIER_UI_Sfx_" .. name
                sound.Volume = 0
                sound.SoundId = assetId
                sound.Parent = SoundService
                list[i] = sound
            end
        end)
        building[name] = nil
        if not ok or #list == 0 then
            for _, sound in ipairs(list) do
                sound:Destroy()
            end
            entry.failed = true
            return nil
        end
        pools[name] = { voices = list, nextVoice = 1 }
        return pools[name]
    end

    local function playNow(pool, entry, pitch)
        local list = pool.voices
        local voice = list[pool.nextVoice]
        pool.nextVoice = pool.nextVoice % #list + 1
        voice.Volume = entry.gain * math.clamp(tonumber(Library.SoundVolume) or 1, 0, 1)
        voice.PlaybackSpeed = pitch or 1
        voice.TimePosition = 0
        voice:Play()
    end

    -- pitch (optional): playback speed, 1 = normal. Used by the slider so the tick follows the value.
    function Library._sfx(name, pitch)
        if not Library.SoundEnabled then
            return
        end
        local entry = Sfx[name]
        if not entry or entry.failed then
            return
        end
        local now = os.clock()
        if now - (entry.last or -1) < entry.gap then
            return
        end
        local pool = pools[name] or buildPool(name)
        if not pool then
            return
        end
        entry.last = now
        local voice = pool.voices[pool.nextVoice]
        if voice.IsLoaded then
            playNow(pool, entry, pitch)
        elseif not DROP_WHILE_LOADING[name] then
            -- still loading (e.g. the window opens right after the library is loaded): wait max 3 s, then play
            task.spawn(function()
                local t0 = os.clock()
                while not voice.IsLoaded and voice.Parent and os.clock() - t0 < 3 do
                    task.wait()
                end
                if voice.Parent and Library.SoundEnabled then
                    playNow(pool, entry, pitch)
                end
            end)
        end
    end

    -- ---------------------------------------------------------------- pre-load (must stay LAST)
    -- Build + pre-load every sound in the background so the first play is instant.
    -- Slider is first so its voices start loading immediately. This must stay after all
    -- SfxData.* assignments: task.spawn runs immediately and would otherwise see no data.
    task.spawn(function()
        for _, name in ipairs({ "slider", "open", "close", "hover", "select", "toggleOn", "toggleOff", "notify" }) do
            local pool = buildPool(name)
            if pool then
                task.spawn(function()
                    pcall(function()
                        ContentProvider:PreloadAsync(pool.voices)
                    end)
                end)
            end
            task.wait() -- one frame between sounds so the base64 decoding never freezes the game
        end
    end)

end

return Library
