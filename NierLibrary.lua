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
        Settings = "Settings",
        PresetHeader = "Preset Themes",
        PresetLabel = "Choose a Preset Theme",
        ColorHeader = "Colors",
        PaperLabel = "Background (Paper)",
        RowLabel = "Elements (Rows)",
        InputLabel = "Textbox / Input",
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
    InputLabel = "สีช่องกรอก (Textbox)",
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

local function tw(inst, dur, props, style, dir)
    if not dur or dur <= 0 then
        for k, v in pairs(props) do
            inst[k] = v
        end
        return
    end
    TweenService:Create(inst, TweenInfo.new(dur, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
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

local stripHost = new("Frame", {
    Name = "Strips",
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 60,
}, gui)
local STRIP_N = 9
local STRIP_ANGLE = -13
local rng = Random.new()
local animating = false

local function buildStrips(W, H, collapsed)
    stripHost:ClearAllChildren()
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
        stripHost:ClearAllChildren()
        animating = false
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
    if not StripAnim then
        main.Visible = shouldOpen
        return
    end
    animating = true
    playStrips(shouldOpen)
end

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
toggleBtn.Visible = Config.ToggleConfig ~= nil or (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
local tbMoved = makeDraggable(toggleBtn)
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
        TextColor3 = Color3.fromRGB(104, 100, 82),
        ZIndex = 2,
    })
bindFont(lab, 14, false)
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
    BackgroundColor3 = Color3.fromRGB(250, 244, 206),
}, slot)
local bar = new("Frame", { Size = UDim2.new(0, 4, 1, 0), BorderSizePixel = 0, ZIndex = 2 }, card)
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
return tb, bg
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

            SettingsTab:CreateSlider(T.TransparencyLabel, "lucide-glasses", 0, 90, TransPercent, function(v)
                TransPercent = v
                setGlass(v / 100)
                persistTheme()
            end)
        end

        BuildSettingsUI()
    end)
end

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
