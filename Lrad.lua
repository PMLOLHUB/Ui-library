
local tast = {}

tast.Library = loadstring(game:HttpGet(
    "https://github.com/PMLOLHUB/Ui-library/raw/refs/heads/main/Lrad.lua"
))()

tast.Library:SetSoundEnabled(true)
tast.Library:SetSoundVolume(0.8)

tast.Window = tast.Library:CreateWindow("Lrad", {
    Theme = "Paper",
    ToggleKey = Enum.KeyCode.RightShift,
    Language = "en",
    StartOpen = true,
    ShowSettingsTab = true,
    ElementTransparency = 0.08,
    OverallScale = 100,
    ToggleButtonScale = 100,
    FontFamily = "Gotham",
    FontScale = 1,
    BorderEnabled = true,
    Logo = "rbxassetid://98985755793415",
    ToggleConfig = {
        Text = "NIER",
        Image = "rbxassetid://98985755793415"
    }
})

tast.Tab, tast.Page = tast.Window:CreateCategory(
    "Main",
    "lucide-house"
)

tast.Label = tast.Tab:CreateLabel(
    "NIER UI Library",
    "lucide-house"
)

tast.Button = tast.Tab:CreateButton(
    "Test Button",
    "rbxassetid://98985755793415",
    function()
        tast.Window:Notify("Button clicked!", 3)
    end
)

tast.Textbox = tast.Tab:CreateTextbox(
    "Textbox",
    "lucide-pencil",
    "Enter text...",
    "Textbox",
    function(value)
        print(value)
    end
)

tast.NumberTextbox = tast.Tab:CreateNumberTextbox(
    "Number",
    "lucide-hash",
    10,
    "Number",
    function(value)
        print(value)
    end
)

tast.SearchBar = tast.Tab:CreateSearchBar(
    "Search...",
    "lucide-search",
    function(value)
        print(value)
    end
)

tast.Toggle = tast.Tab:CreateToggle(
    "Toggle",
    "lucide-toggle-right",
    false,
    "Toggle",
    function(value)
        print(value)
    end
)

tast.Slider = tast.Tab:CreateSlider(
    "Slider",
    "lucide-sliders-horizontal",
    0,
    100,
    50,
    "Slider",
    function(value)
        print(value)
    end
)

tast.ColorPicker = tast.Tab:CreateColorPicker(
    "Color Picker",
    "lucide-palette",
    Color3.fromRGB(255, 170, 0),
    "ColorPicker",
    function(value)
        print(value)
    end
)

tast.Dropdown = tast.Tab:CreateDropdown(
    "Dropdown",
    "lucide-list",
    {"Option 1", "Option 2", "Option 3"},
    "Option 1",
    "Dropdown",
    function(value)
        print(value)
    end
)

tast.MultiDropdown = tast.Tab:CreateMultiDropdown(
    "Multi Dropdown",
    "lucide-list-check",
    {"Option 1", "Option 2", "Option 3"},
    {"Option 1"},
    "MultiDropdown",
    function(values)
        print(values)
    end
)

return tast
