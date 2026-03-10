--// =========================================================
--// NOVA UI LIBRARY + DUMMY HUB (ONE FILE)
--// =========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local DUMMIES_FOLDER = Workspace:WaitForChild("Players")

--// =========================================================
--// LIBRARY
--// =========================================================

local Library = {}
Library.__index = Library

local Theme = {
    Background = Color3.fromRGB(10, 12, 16),
    Surface = Color3.fromRGB(16, 18, 24),
    Surface2 = Color3.fromRGB(21, 24, 31),
    Surface3 = Color3.fromRGB(28, 32, 40),
    Border = Color3.fromRGB(42, 47, 58),
    Accent = Color3.fromRGB(105, 145, 255),
    Text = Color3.fromRGB(236, 240, 255),
    SubText = Color3.fromRGB(150, 160, 180),
    Good = Color3.fromRGB(90, 200, 140),
    Bad = Color3.fromRGB(235, 95, 110),
    Warning = Color3.fromRGB(255, 180, 70)
}

local function Tween(obj, time, props, style, direction)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function Create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function AddCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 12)
    c.Parent = obj
    return c
end

local function AddStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function AddPadding(obj, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = obj
    return p
end

local function SafeDestroy(name)
    pcall(function()
        local old = CoreGui:FindFirstChild(name)
        if old then
            old:Destroy()
        end
    end)
end

function Library.new(config)
    config = config or {}

    local self = setmetatable({}, Library)

    self.Name = config.Name or "NovaHub"
    self.Title = config.Title or "Nova Hub"
    self.Subtitle = config.Subtitle or "Clean UI Library"
    self.Width = config.Width or 860
    self.Height = config.Height or 540
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    self.Theme = Theme
    self.Tabs = {}
    self.Hidden = false
    self.Minimized = false
    self.DragSmoothing = 0.18
    self.ConfigFolder = config.ConfigFolder or "NovaUIConfigs"
    self.CurrentConfigName = "default"
    self.Flags = {}
    self.AutoLoadConfig = false
    self.AutoSaveConfig = false
    self.RainbowAccent = false
    self.RainbowText = false

    self._connections = {}
    self._accentObjects = {}
    self._mainTextObjects = {}
    self._subTextObjects = {}
    self._toggleSwitches = {}
    self._dragGoal = nil
    self._activeTab = nil
    self._isCapturingKeybind = false
    self._fadeCache = {}
    self._isFading = false

    SafeDestroy(self.Name)

    self.ScreenGui = Create("ScreenGui", {
        Name = self.Name,
        Parent = CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    self.NotificationHolder = Create("Frame", {
        Name = "Notifications",
        Parent = self.ScreenGui,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -18, 0, 18),
        Size = UDim2.new(0, 320, 1, -36)
    })

    Create("UIListLayout", {
        Parent = self.NotificationHolder,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right
    })

    self.Main = Create("Frame", {
        Name = "Main",
        Parent = self.ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, self.Width, 0, self.Height),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    AddCorner(self.Main, UDim.new(0, 16))
    AddStroke(self.Main, Theme.Border, 1, 0)

    self.TopBar = Create("Frame", {
        Parent = self.Main,
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 52)
    })
    AddCorner(self.TopBar, UDim.new(0, 16))

    self.TopFix = Create("Frame", {
        Parent = self.TopBar,
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 16)
    })

    self.TitleLabel = Create("TextLabel", {
        Parent = self.TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 0),
        Size = UDim2.new(0, 250, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = self.Title,
        TextColor3 = Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    self.SubtitleLabel = Create("TextLabel", {
        Parent = self.TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 118, 0, 0),
        Size = UDim2.new(0, 360, 1, 0),
        Font = Enum.Font.Gotham,
        Text = self.Subtitle,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    self.MinButton = Create("TextButton", {
        Parent = self.TopBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -54, 0.5, 0),
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundColor3 = Theme.Surface3,
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 16,
        AutoButtonColor = false
    })
    AddCorner(self.MinButton, UDim.new(1, 0))
    AddStroke(self.MinButton, Theme.Border, 1, 0)

    self.CloseButton = Create("TextButton", {
        Parent = self.TopBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundColor3 = Theme.Surface3,
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 14,
        AutoButtonColor = false
    })
    AddCorner(self.CloseButton, UDim.new(1, 0))
    AddStroke(self.CloseButton, Theme.Border, 1, 0)

    self.Sidebar = Create("Frame", {
        Parent = self.Main,
        Position = UDim2.new(0, 12, 0, 64),
        Size = UDim2.new(0, 190, 1, -76),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0
    })
    AddCorner(self.Sidebar, UDim.new(0, 14))
    AddStroke(self.Sidebar, Theme.Border, 1, 0)
    AddPadding(self.Sidebar, 10, 10, 10, 10)

    self.SidebarContainer = Create("Frame", {
        Parent = self.Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })

    self.TopTabsHolder = Create("Frame", {
        Parent = self.SidebarContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -52)
    })

    Create("UIListLayout", {
        Parent = self.TopTabsHolder,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    self.BottomTabsHolder = Create("Frame", {
        Parent = self.SidebarContainer,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42)
    })

    self.TabSelector = Create("Frame", {
        Parent = self.SidebarContainer,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 0, 24),
        Position = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 5
    })
    AddCorner(self.TabSelector, UDim.new(0, 10))

    self.Content = Create("Frame", {
        Parent = self.Main,
        Position = UDim2.new(0, 214, 0, 64),
        Size = UDim2.new(1, -226, 1, -76),
        BackgroundTransparency = 1
    })

    self.OriginalSize = self.Main.Size

    self:_registerMainText(self.TitleLabel)
    self:_registerSubText(self.SubtitleLabel)
    self:_registerAccent(self.TabSelector, "BackgroundColor3")

    self:_bindWindowButtons()
    self:_bindDragging()
    self:_bindToggleKey()
    self:_bindRainbowUpdater()
    self:_createSettingsTab()

    return self
end

function Library:_registerAccent(obj, prop)
    table.insert(self._accentObjects, {Object = obj, Property = prop or "BackgroundColor3"})
end

function Library:_registerMainText(obj)
    table.insert(self._mainTextObjects, obj)
end

function Library:_registerSubText(obj)
    table.insert(self._subTextObjects, obj)
end

function Library:_cacheFadeState(root)
    self._fadeCache = {}

    local function save(obj, key, value)
        self._fadeCache[obj] = self._fadeCache[obj] or {}
        self._fadeCache[obj][key] = value
    end

    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("ScrollingFrame") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            save(obj, "BackgroundTransparency", obj.BackgroundTransparency)
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            save(obj, "TextTransparency", obj.TextTransparency)
        end
        if obj:IsA("UIStroke") then
            save(obj, "Transparency", obj.Transparency)
        end
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            save(obj, "ImageTransparency", obj.ImageTransparency)
            save(obj, "BackgroundTransparency", obj.BackgroundTransparency)
        end
    end
end

function Library:_restoreFadeState()
    for obj, data in pairs(self._fadeCache) do
        if obj and obj.Parent then
            for prop, value in pairs(data) do
                pcall(function()
                    obj[prop] = value
                end)
            end
        end
    end
end

function Library:_setFadeAlpha(root, alpha)
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("ScrollingFrame") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.BackgroundTransparency = alpha
        end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextTransparency = alpha
        end
        if obj:IsA("UIStroke") then
            obj.Transparency = alpha
        end
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            obj.ImageTransparency = alpha
            obj.BackgroundTransparency = alpha
        end
    end
end

function Library:RefreshUIIntegrity()
    self:_restoreFadeState()

    self.Main.BackgroundColor3 = self.Theme.Background
    self.TopBar.BackgroundColor3 = self.Theme.Surface
    self.TopFix.BackgroundColor3 = self.Theme.Surface
    self.Sidebar.BackgroundColor3 = self.Theme.Surface

    for _, toggleObj in ipairs(self._toggleSwitches) do
        if toggleObj and toggleObj.RefreshColorOnly then
            toggleObj:RefreshColorOnly()
        end
    end

    for _, obj in ipairs(self._mainTextObjects) do
        if obj and obj.Parent and not self.RainbowText then
            obj.TextColor3 = self.Theme.Text
        end
    end

    for _, obj in ipairs(self._subTextObjects) do
        if obj and obj.Parent then
            obj.TextColor3 = self.Theme.SubText
        end
    end

    if not self.RainbowAccent then
        self:SetAccent(self.Theme.Accent, true)
    end
end

function Library:_ensureConfigFolder()
    if makefolder and not isfolder(self.ConfigFolder) then
        makefolder(self.ConfigFolder)
    end
end

function Library:_getConfigPath(name)
    return self.ConfigFolder .. "/" .. tostring(name) .. ".json"
end

function Library:GetConfigList()
    self:_ensureConfigFolder()
    local out = {}

    if listfiles then
        local ok, files = pcall(function()
            return listfiles(self.ConfigFolder)
        end)

        if ok and type(files) == "table" then
            for _, file in ipairs(files) do
                local name = tostring(file):match("([^/\\]+)%.json$")
                if name then
                    table.insert(out, name)
                end
            end
        end
    end

    table.sort(out)
    return out
end

function Library:SaveConfig(name)
    if not writefile then
        self:Notify("Config", "writefile not supported.", 2)
        return false
    end

    self:_ensureConfigFolder()
    name = tostring(name or self.CurrentConfigName or "default")
    if name == "" then
        name = "default"
    end

    self.CurrentConfigName = name

    local data = {
        ToggleKey = self.ToggleKey.Name,
        Accent = {
            math.floor(self.Theme.Accent.R * 255 + 0.5),
            math.floor(self.Theme.Accent.G * 255 + 0.5),
            math.floor(self.Theme.Accent.B * 255 + 0.5),
        },
        RainbowAccent = self.RainbowAccent,
        RainbowText = self.RainbowText,
        AutoLoadConfig = self.AutoLoadConfig,
        AutoSaveConfig = self.AutoSaveConfig,
        DragSmoothing = self.DragSmoothing,
        Flags = self.Flags
    }

    local ok, err = pcall(function()
        writefile(self:_getConfigPath(name), HttpService:JSONEncode(data))
    end)

    if not ok then
        self:Notify("Config", "Failed to save: " .. tostring(err), 2)
        return false
    end

    return true
end

function Library:LoadConfig(name)
    if not readfile then
        self:Notify("Config", "readfile not supported.", 2)
        return false
    end

    name = tostring(name or self.CurrentConfigName or "default")
    local path = self:_getConfigPath(name)

    if not isfile or not isfile(path) then
        self:Notify("Config", "Config not found.", 2)
        return false
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)

    if not ok or type(data) ~= "table" then
        self:Notify("Config", "Invalid config file.", 2)
        return false
    end

    self.CurrentConfigName = name

    if data.ToggleKey and Enum.KeyCode[data.ToggleKey] then
        self.ToggleKey = Enum.KeyCode[data.ToggleKey]
    end

    if data.Accent then
        self:SetAccent(Color3.fromRGB(data.Accent[1], data.Accent[2], data.Accent[3]), true)
    end

    self.RainbowAccent = data.RainbowAccent == true
    self.RainbowText = data.RainbowText == true
    self.AutoLoadConfig = data.AutoLoadConfig == true
    self.AutoSaveConfig = data.AutoSaveConfig == true
    self.DragSmoothing = tonumber(data.DragSmoothing) or self.DragSmoothing
    self.Flags = data.Flags or {}

    if self._settingsRefs then
        self._settingsRefs.AutoLoad:Set(self.AutoLoadConfig)
        self._settingsRefs.AutoSave:Set(self.AutoSaveConfig)
        self._settingsRefs.RainbowAccent:Set(self.RainbowAccent)
        self._settingsRefs.RainbowText:Set(self.RainbowText)
        self._settingsRefs.KeybindLabel:Set("Current Toggle Key: " .. self.ToggleKey.Name)
        self._settingsRefs.DragSmooth:Set(math.floor(self.DragSmoothing * 100 + 0.5))
        self._settingsRefs.ConfigNameInput:Set(name)
    end

    self:RefreshUIIntegrity()
    return true
end

function Library:_notifyAutoSave()
    if self.AutoSaveConfig then
        self:SaveConfig(self.CurrentConfigName)
    end
end

function Library:SetAccent(color, silent)
    self.Theme.Accent = color

    for _, item in ipairs(self._accentObjects) do
        local obj = item.Object
        local prop = item.Property
        if obj and obj.Parent then
            pcall(function()
                obj[prop] = color
            end)
        end
    end

    for _, toggleObj in ipairs(self._toggleSwitches) do
        if toggleObj.Switch and toggleObj.Switch.Parent then
            toggleObj:RefreshColorOnly()
        end
    end

    if not silent then
        self:_notifyAutoSave()
    end
end

function Library:SetToggleKey(keyCode)
    self.ToggleKey = keyCode
    if self._settingsRefs and self._settingsRefs.KeybindLabel then
        self._settingsRefs.KeybindLabel:Set("Current Toggle Key: " .. keyCode.Name)
    end
    self:_notifyAutoSave()
end

function Library:_bindRainbowUpdater()
    table.insert(self._connections, RunService.RenderStepped:Connect(function()
        local rainbow = Color3.fromHSV((tick() * 0.12) % 1, 0.7, 1)

        if self.RainbowAccent then
            self:SetAccent(rainbow, true)
        end

        if self.RainbowText then
            for _, obj in ipairs(self._mainTextObjects) do
                if obj and obj.Parent then
                    obj.TextColor3 = rainbow
                end
            end
        else
            for _, obj in ipairs(self._mainTextObjects) do
                if obj and obj.Parent then
                    obj.TextColor3 = self.Theme.Text
                end
            end
        end

        for _, obj in ipairs(self._subTextObjects) do
            if obj and obj.Parent then
                obj.TextColor3 = self.Theme.SubText
            end
        end
    end))
end

function Library:_bindWindowButtons()
    self.CloseButton.MouseEnter:Connect(function()
        Tween(self.CloseButton, 0.12, {BackgroundColor3 = Theme.Bad})
    end)

    self.CloseButton.MouseLeave:Connect(function()
        Tween(self.CloseButton, 0.12, {BackgroundColor3 = Theme.Surface3})
    end)

    self.MinButton.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            Tween(self.Main, 0.2, {Size = UDim2.new(0, self.Width, 0, 52)})
        else
            Tween(self.Main, 0.2, {Size = self.OriginalSize})
        end
    end)

    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

function Library:_bindDragging()
    local dragging = false
    local dragStart
    local startPos

    self._dragGoal = self.Main.Position

    self.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self._dragGoal or self.Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self._dragGoal = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end))

    table.insert(self._connections, RunService.RenderStepped:Connect(function()
        if self._dragGoal and self.Main and self.Main.Parent then
            local current = self.Main.Position
            local goal = self._dragGoal
            local a = self.DragSmoothing

            self.Main.Position = UDim2.new(
                current.X.Scale + (goal.X.Scale - current.X.Scale) * a,
                current.X.Offset + (goal.X.Offset - current.X.Offset) * a,
                current.Y.Scale + (goal.Y.Scale - current.Y.Scale) * a,
                current.Y.Offset + (goal.Y.Offset - current.Y.Offset) * a
            )
        end
    end))
end

function Library:ToggleUI(state)
    if self._isFading then
        return
    end

    if state == nil then
        self.Hidden = not self.Hidden
    else
        self.Hidden = not state
    end

    self._isFading = true

    if self.Hidden then
        self:_cacheFadeState(self.Main)
        self:_setFadeAlpha(self.Main, 1)
        Tween(self.Main, 0.18, {BackgroundTransparency = 1})
        task.delay(0.2, function()
            if self.Hidden and self.Main then
                self.Main.Visible = false
            end
            self._isFading = false
        end)
    else
        self.Main.Visible = true
        self:_restoreFadeState()
        self.Main.BackgroundTransparency = 1
        Tween(self.Main, 0.2, {BackgroundTransparency = 0})

        for obj, data in pairs(self._fadeCache) do
            if obj and obj.Parent then
                if data.BackgroundTransparency ~= nil then
                    obj.BackgroundTransparency = 1
                    Tween(obj, 0.2, {BackgroundTransparency = data.BackgroundTransparency})
                end
                if data.TextTransparency ~= nil then
                    obj.TextTransparency = 1
                    Tween(obj, 0.2, {TextTransparency = data.TextTransparency})
                end
                if data.Transparency ~= nil and obj:IsA("UIStroke") then
                    obj.Transparency = 1
                    Tween(obj, 0.2, {Transparency = data.Transparency})
                end
                if data.ImageTransparency ~= nil and (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) then
                    obj.ImageTransparency = 1
                    Tween(obj, 0.2, {ImageTransparency = data.ImageTransparency})
                end
            end
        end

        task.delay(0.22, function()
            self:RefreshUIIntegrity()
            self._isFading = false
        end)
    end
end

function Library:_bindToggleKey()
    table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gp)
        if gp or self._isCapturingKeybind then
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.ToggleKey then
            self:ToggleUI()
        end
    end))
end

function Library:Notify(title, text, duration, imageId)
    duration = duration or 3

    local Card = Create("Frame", {
        Parent = self.NotificationHolder,
        BackgroundColor3 = Theme.Surface2,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    AddCorner(Card, UDim.new(0, 10))
    AddStroke(Card, Theme.Border, 1, 0)

    local AccentBar = Create("Frame", {
        Parent = Card,
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0)
    })
    AddCorner(AccentBar, UDim.new(0, 10))
    self:_registerAccent(AccentBar, "BackgroundColor3")

    local Inner = Create("Frame", {
        Parent = Card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 10),
        Size = UDim2.new(1, -22, 1, -20),
        AutomaticSize = Enum.AutomaticSize.Y
    })

    Create("UIListLayout", {
        Parent = Inner,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    if imageId and imageId ~= "" then
        local Image = Create("ImageLabel", {
            Parent = Inner,
            BackgroundColor3 = Theme.Surface3,
            Size = UDim2.new(0, 52, 0, 52),
            Image = imageId,
            ScaleType = Enum.ScaleType.Crop
        })
        AddCorner(Image, UDim.new(0, 8))
        AddStroke(Image, Theme.Border, 1, 0)
    end

    local Title = Create("TextLabel", {
        Parent = Inner,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.GothamBold,
        Text = title or "Notification",
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    self:_registerMainText(Title)

    local Body = Create("TextLabel", {
        Parent = Inner,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        Text = text or "",
        TextColor3 = Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    self:_registerSubText(Body)

    Card.BackgroundTransparency = 1
    Tween(Card, 0.18, {BackgroundTransparency = 0})

    task.delay(duration, function()
        if Card and Card.Parent then
            Tween(Card, 0.16, {BackgroundTransparency = 1})
            task.wait(0.18)
            if Card then
                Card:Destroy()
            end
        end
    end)
end

function Library:_makePage()
    local Page = Create("ScrollingFrame", {
        Parent = self.Content,
        Visible = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent
    })
    self:_registerAccent(Page, "ScrollBarImageColor3")

    local List = Create("UIListLayout", {
        Parent = Page,
        Padding = UDim.new(0, 14),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 8)
    end)

    return Page, List
end

function Library:_moveTabSelector(button)
    if not button or not button.Parent then
        return
    end

    local y = button.AbsolutePosition.Y - self.SidebarContainer.AbsolutePosition.Y + ((button.AbsoluteSize.Y - 24) / 2)

    self.TabSelector.Visible = true
    Tween(self.TabSelector, 0.22, {
        Position = UDim2.new(0, 0, 0, y),
        Size = UDim2.new(0, 4, 0, 24)
    }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
end

function Library:_createTabButton(name, isBottom)
    local parent = isBottom and self.BottomTabsHolder or self.TopTabsHolder

    local Button = Create("TextButton", {
        Parent = parent,
        BackgroundColor3 = Theme.Surface2,
        Size = UDim2.new(1, 0, 0, 42),
        Text = "",
        AutoButtonColor = false
    })
    AddCorner(Button, UDim.new(0, 10))
    AddStroke(Button, Theme.Border, 1, 0)

    local Label = Create("TextLabel", {
        Parent = Button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -14, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = name,
        TextColor3 = Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    self:_registerMainText(Label)

    return Button, Label
end

function Library:_newTabObject(name, isBottom)
    local Tab = {}
    Tab.Library = self
    Tab.Name = name

    Tab.Button, Tab.Label = self:_createTabButton(name, isBottom)
    Tab.Page, Tab.List = self:_makePage()

    function Tab:Show()
        for _, other in ipairs(self.Library.Tabs) do
            other.Page.Visible = false
            Tween(other.Button, 0.12, {BackgroundColor3 = Theme.Surface2})
            other.Label.TextColor3 = Theme.SubText
        end

        self.Page.Visible = true
        Tween(self.Button, 0.12, {BackgroundColor3 = Theme.Surface3})
        self.Label.TextColor3 = Theme.Text
        self.Library._activeTab = self

        self.Library:_moveTabSelector(self.Button)
    end

    function Tab:CreateSection(title)
        local Section = {}
        Section.Tab = self

        Section.Frame = Create("Frame", {
            Parent = self.Page,
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        AddCorner(Section.Frame, UDim.new(0, 14))
        AddStroke(Section.Frame, Theme.Border, 1, 0)
        AddPadding(Section.Frame, 12, 12, 12, 12)

        Section.Header = Create("TextLabel", {
            Parent = Section.Frame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        self.Library:_registerMainText(Section.Header)

        Section.Divider = Create("Frame", {
            Parent = Section.Frame,
            BackgroundColor3 = Theme.Border,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 28),
            Size = UDim2.new(1, 0, 0, 1)
        })

        Section.Holder = Create("Frame", {
            Parent = Section.Frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 40),
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })

        Section.Layout = Create("UIListLayout", {
            Parent = Section.Holder,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Section.Holder.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y)
        end)

        function Section:CreateLabel(text)
            local Label = Create("TextLabel", {
                Parent = self.Holder,
                BackgroundColor3 = Theme.Surface2,
                Size = UDim2.new(1, 0, 0, 34),
                Font = Enum.Font.Gotham,
                Text = "  " .. tostring(text),
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            AddCorner(Label, UDim.new(0, 8))
            AddStroke(Label, Theme.Border, 1, 0)
            self.Tab.Library:_registerSubText(Label)

            return {
                Set = function(_, newText)
                    Label.Text = "  " .. tostring(newText)
                end,
                Object = Label
            }
        end

        function Section:CreateButton(text, callback)
            local Button = Create("TextButton", {
                Parent = self.Holder,
                BackgroundColor3 = Theme.Surface2,
                Size = UDim2.new(1, 0, 0, 38),
                Text = "",
                AutoButtonColor = false
            })
            AddCorner(Button, UDim.new(0, 8))
            AddStroke(Button, Theme.Border, 1, 0)

            local Label = Create("TextLabel", {
                Parent = Button,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            self.Tab.Library:_registerMainText(Label)

            Button.MouseEnter:Connect(function()
                Tween(Button, 0.12, {BackgroundColor3 = Theme.Surface3})
            end)

            Button.MouseLeave:Connect(function()
                Tween(Button, 0.12, {BackgroundColor3 = Theme.Surface2})
            end)

            Button.MouseButton1Click:Connect(function()
                if callback then
                    task.spawn(callback)
                end
            end)

            return {
                SetText = function(_, newText)
                    Label.Text = tostring(newText)
                end,
                Object = Button
            }
        end

        function Section:CreateToggle(text, default, callback, flagName)
            local ToggleState = default or false
            local lib = self.Tab.Library

            if flagName ~= nil and lib.Flags[flagName] ~= nil then
                ToggleState = lib.Flags[flagName]
            else
                if flagName ~= nil then
                    lib.Flags[flagName] = ToggleState
                end
            end

            local Toggle = Create("TextButton", {
                Parent = self.Holder,
                BackgroundColor3 = Theme.Surface2,
                Size = UDim2.new(1, 0, 0, 42),
                Text = "",
                AutoButtonColor = false
            })
            AddCorner(Toggle, UDim.new(0, 8))
            AddStroke(Toggle, Theme.Border, 1, 0)

            local ToggleLabel = Create("TextLabel", {
                Parent = Toggle,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -80, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            lib:_registerMainText(ToggleLabel)

            local Switch = Create("Frame", {
                Parent = Toggle,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 42, 0, 22),
                BackgroundColor3 = Theme.Surface3
            })
            AddCorner(Switch, UDim.new(1, 0))

            local Knob = Create("Frame", {
                Parent = Switch,
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = Theme.Text
            })
            AddCorner(Knob, UDim.new(1, 0))

            local toggleRef = {}

            function toggleRef:RefreshColorOnly()
                if ToggleState then
                    Switch.BackgroundColor3 = lib.Theme.Accent
                else
                    Switch.BackgroundColor3 = Theme.Surface3
                end
            end

            local function Refresh()
                toggleRef:RefreshColorOnly()

                if ToggleState then
                    Tween(Knob, 0.14, {Position = UDim2.new(1, -20, 0.5, -9)})
                else
                    Tween(Knob, 0.14, {Position = UDim2.new(0, 2, 0.5, -9)})
                end
            end

            Toggle.MouseButton1Click:Connect(function()
                ToggleState = not ToggleState
                if flagName ~= nil then
                    lib.Flags[flagName] = ToggleState
                end
                Refresh()
                if callback then
                    task.spawn(callback, ToggleState)
                end
                lib:_notifyAutoSave()
            end)

            toggleRef.Switch = Switch
            table.insert(lib._toggleSwitches, toggleRef)

            Refresh()

            return {
                Set = function(_, value)
                    ToggleState = value == true
                    if flagName ~= nil then
                        lib.Flags[flagName] = ToggleState
                    end
                    Refresh()
                    if callback then
                        task.spawn(callback, ToggleState)
                    end
                    lib:_notifyAutoSave()
                end,
                Get = function()
                    return ToggleState
                end,
                Object = Toggle
            }
        end

        function Section:CreateSlider(text, min, max, default, callback, flagName)
            local lib = self.Tab.Library
            local Value = default or min
            local Dragging = false

            if flagName ~= nil and lib.Flags[flagName] ~= nil then
                Value = tonumber(lib.Flags[flagName]) or Value
            else
                if flagName ~= nil then
                    lib.Flags[flagName] = Value
                end
            end

            local Slider = Create("Frame", {
                Parent = self.Holder,
                BackgroundColor3 = Theme.Surface2,
                Size = UDim2.new(1, 0, 0, 56)
            })
            AddCorner(Slider, UDim.new(0, 8))
            AddStroke(Slider, Theme.Border, 1, 0)

            local Title = Create("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 6),
                Size = UDim2.new(1, -70, 0, 18),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            lib:_registerMainText(Title)

            local ValueLabel = Create("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 6),
                Size = UDim2.new(0, 60, 0, 18),
                Font = Enum.Font.Gotham,
                Text = tostring(Value),
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            lib:_registerSubText(ValueLabel)

            local Bar = Create("Frame", {
                Parent = Slider,
                BackgroundColor3 = Theme.Surface3,
                Position = UDim2.new(0, 12, 0, 34),
                Size = UDim2.new(1, -24, 0, 8)
            })
            AddCorner(Bar, UDim.new(1, 0))

            local Fill = Create("Frame", {
                Parent = Bar,
                BackgroundColor3 = lib.Theme.Accent,
                Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
            })
            AddCorner(Fill, UDim.new(1, 0))
            lib:_registerAccent(Fill, "BackgroundColor3")

            local function SetValueFromX(x)
                local percent = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Value = math.floor((min + ((max - min) * percent)) + 0.5)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                ValueLabel.Text = tostring(Value)
                if flagName ~= nil then
                    lib.Flags[flagName] = Value
                end
                if callback then
                    task.spawn(callback, Value)
                end
                lib:_notifyAutoSave()
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    SetValueFromX(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    SetValueFromX(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)

            return {
                Set = function(_, newValue)
                    newValue = math.clamp(tonumber(newValue) or Value, min, max)
                    Value = newValue
                    Fill.Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
                    ValueLabel.Text = tostring(Value)
                    if flagName ~= nil then
                        lib.Flags[flagName] = Value
                    end
                    if callback then
                        task.spawn(callback, Value)
                    end
                    lib:_notifyAutoSave()
                end,
                Get = function()
                    return Value
                end,
                Object = Slider
            }
        end

        function Section:CreateDropdown(text, options, default, callback, flagName)
            local lib = self.Tab.Library
            options = options or {}
            local Selected = default or options[1] or "None"
            local Open = false

            if flagName ~= nil and lib.Flags[flagName] ~= nil then
                Selected = lib.Flags[flagName]
            else
                if flagName ~= nil then
                    lib.Flags[flagName] = Selected
                end
            end

            local Drop = Create("Frame", {
                Parent = self.Holder,
                BackgroundColor3 = Theme.Surface2,
                Size = UDim2.new(1, 0, 0, 42),
                ClipsDescendants = true
            })
            AddCorner(Drop, UDim.new(0, 8))
            AddStroke(Drop, Theme.Border, 1, 0)

            local Top = Create("TextButton", {
                Parent = Drop,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
                Text = "",
                AutoButtonColor = false
            })

            local Title = Create("TextLabel", {
                Parent = Top,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            lib:_registerMainText(Title)

            local Current = Create("TextLabel", {
                Parent = Top,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(0.5, -30, 1, 0),
                Font = Enum.Font.Gotham,
                Text = tostring(Selected),
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            lib:_registerSubText(Current)

            local Arrow = Create("TextLabel", {
                Parent = Top,
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                Font = Enum.Font.GothamBold,
                Text = "˅",
                TextColor3 = Theme.SubText,
                TextSize = 13
            })
            lib:_registerSubText(Arrow)

            local OptionHolder = Create("Frame", {
                Parent = Drop,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 6, 0, 48),
                Size = UDim2.new(1, -12, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })

            Create("UIListLayout", {
                Parent = OptionHolder,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            local optionButtons = {}

            local function rebuild()
                for _, btn in ipairs(optionButtons) do
                    if btn then
                        btn:Destroy()
                    end
                end
                table.clear(optionButtons)

                for _, option in ipairs(options) do
                    local Opt = Create("TextButton", {
                        Parent = OptionHolder,
                        BackgroundColor3 = Theme.Surface3,
                        Size = UDim2.new(1, 0, 0, 32),
                        Text = tostring(option),
                        Font = Enum.Font.Gotham,
                        TextColor3 = Theme.Text,
                        TextSize = 12,
                        AutoButtonColor = false
                    })
                    AddCorner(Opt, UDim.new(0, 7))
                    lib:_registerMainText(Opt)

                    table.insert(optionButtons, Opt)

                    Opt.MouseButton1Click:Connect(function()
                        Selected = option
                        Current.Text = tostring(option)
                        Open = false
                        Arrow.Text = "˅"
                        Tween(Drop, 0.15, {Size = UDim2.new(1, 0, 0, 42)})
                        if flagName ~= nil then
                            lib.Flags[flagName] = Selected
                        end
                        if callback then
                            task.spawn(callback, option)
                        end
                        lib:_notifyAutoSave()
                    end)
                end
            end

            rebuild()

            Top.MouseButton1Click:Connect(function()
                Open = not Open
                if Open then
                    local count = #options
                    local targetHeight = 42 + (count * 38) + 12
                    Arrow.Text = "˄"
                    Tween(Drop, 0.15, {Size = UDim2.new(1, 0, 0, targetHeight)})
                else
                    Arrow.Text = "˅"
                    Tween(Drop, 0.15, {Size = UDim2.new(1, 0, 0, 42)})
                end
            end)

            return {
                Set = function(_, value)
                    Selected = value
                    Current.Text = tostring(value)
                    if flagName ~= nil then
                        lib.Flags[flagName] = Selected
                    end
                    if callback then
                        task.spawn(callback, value)
                    end
                    lib:_notifyAutoSave()
                end,
                Get = function()
                    return Selected
                end,
                Refresh = function(_, newOptions)
                    options = newOptions or options
                    rebuild()
                end,
                Object = Drop
            }
        end

        function Section:CreateInput(text, placeholder, default, callback, flagName)
            local lib = self.Tab.Library
            local Value = default or ""

            if flagName ~= nil and lib.Flags[flagName] ~= nil then
                Value = tostring(lib.Flags[flagName])
            else
                if flagName ~= nil then
                    lib.Flags[flagName] = Value
                end
            end

            local InputFrame = Create("Frame", {
                Parent = self.Holder,
                BackgroundColor3 = Theme.Surface2,
                Size = UDim2.new(1, 0, 0, 42)
            })
            AddCorner(InputFrame, UDim.new(0, 8))
            AddStroke(InputFrame, Theme.Border, 1, 0)

            local Label = Create("TextLabel", {
                Parent = InputFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(0.38, 0, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            lib:_registerMainText(Label)

            local Box = Create("TextBox", {
                Parent = InputFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.38, 0, 0, 0),
                Size = UDim2.new(0.62, -12, 1, 0),
                Font = Enum.Font.Gotham,
                PlaceholderText = placeholder or "",
                Text = tostring(Value),
                TextColor3 = Theme.SubText,
                PlaceholderColor3 = Theme.SubText,
                TextSize = 12,
                ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            lib:_registerSubText(Box)

            local function commit()
                Value = Box.Text
                if flagName ~= nil then
                    lib.Flags[flagName] = Value
                end
                if callback then
                    task.spawn(callback, Value)
                end
                lib:_notifyAutoSave()
            end

            Box.FocusLost:Connect(function()
                commit()
            end)

            return {
                Set = function(_, newText)
                    Value = tostring(newText or "")
                    Box.Text = Value
                    if flagName ~= nil then
                        lib.Flags[flagName] = Value
                    end
                end,
                Get = function()
                    return Value
                end,
                Object = InputFrame,
                Box = Box
            }
        end

        return Section
    end

    Tab.Button.MouseButton1Click:Connect(function()
        Tab:Show()
    end)

    table.insert(self.Tabs, Tab)

    if #self.Tabs == 1 then
        task.defer(function()
            Tab:Show()
        end)
    end

    return Tab
end

function Library:CreateTab(name)
    return self:_newTabObject(name, false)
end

function Library:_createColorPicker(section)
    local Picker = Create("Frame", {
        Parent = section.Holder,
        BackgroundColor3 = Theme.Surface2,
        Size = UDim2.new(1, 0, 0, 170)
    })
    AddCorner(Picker, UDim.new(0, 8))
    AddStroke(Picker, Theme.Border, 1, 0)

    local Title = Create("TextLabel", {
        Parent = Picker,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 18),
        Font = Enum.Font.GothamMedium,
        Text = "Accent Color Picker",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    self:_registerMainText(Title)

    local Preview = Create("Frame", {
        Parent = Picker,
        BackgroundColor3 = self.Theme.Accent,
        Position = UDim2.new(1, -40, 0, 10),
        Size = UDim2.new(0, 20, 0, 20)
    })
    AddCorner(Preview, UDim.new(0, 6))
    self:_registerAccent(Preview, "BackgroundColor3")

    local SV = Create("Frame", {
        Parent = Picker,
        BackgroundColor3 = Color3.fromHSV(0, 1, 1),
        Position = UDim2.new(0, 12, 0, 36),
        Size = UDim2.new(1, -48, 0, 100),
        ClipsDescendants = true
    })
    AddCorner(SV, UDim.new(0, 6))

    Create("UIGradient", {
        Parent = SV,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
        },
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        },
        Rotation = 0
    })

    local BlackOverlay = Create("Frame", {
        Parent = SV,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    })
    AddCorner(BlackOverlay, UDim.new(0, 6))

    Create("UIGradient", {
        Parent = BlackOverlay,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
        },
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        },
        Rotation = 90
    })

    local SVKnob = Create("Frame", {
        Parent = SV,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size = UDim2.new(0, 8, 0, 8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, 0, 0, 0)
    })
    AddCorner(SVKnob, UDim.new(1, 0))

    local Hue = Create("Frame", {
        Parent = Picker,
        Position = UDim2.new(1, -26, 0, 36),
        Size = UDim2.new(0, 14, 0, 100),
        BackgroundColor3 = Color3.new(1,1,1)
    })
    AddCorner(Hue, UDim.new(0, 6))

    Create("UIGradient", {
        Parent = Hue,
        Rotation = 90,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
        }
    })

    local HueKnob = Create("Frame", {
        Parent = Hue,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size = UDim2.new(1, 4, 0, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0, 0)
    })
    AddCorner(HueKnob, UDim.new(1, 0))

    local h, s, v = Color3.toHSV(self.Theme.Accent)
    local dragSV = false
    local dragHue = false

    local function apply()
        local c = Color3.fromHSV(h, s, v)
        SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        Preview.BackgroundColor3 = c
        self:SetAccent(c)
    end

    local function setSV(x, y)
        local px = math.clamp((x - SV.AbsolutePosition.X) / SV.AbsoluteSize.X, 0, 1)
        local py = math.clamp((y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y, 0, 1)
        s = px
        v = 1 - py
        SVKnob.Position = UDim2.new(px, 0, py, 0)
        apply()
    end

    local function setHue(y)
        local py = math.clamp((y - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y, 0, 1)
        h = py
        HueKnob.Position = UDim2.new(0.5, 0, py, 0)
        apply()
    end

    SV.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragSV = true
            setSV(input.Position.X, input.Position.Y)
        end
    end)

    Hue.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragHue = true
            setHue(input.Position.Y)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragSV then
                setSV(input.Position.X, input.Position.Y)
            end
            if dragHue then
                setHue(input.Position.Y)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragSV = false
            dragHue = false
        end
    end)

    SVKnob.Position = UDim2.new(s, 0, 1 - v, 0)
    HueKnob.Position = UDim2.new(0.5, 0, h, 0)
    apply()
end

function Library:_createSettingsTab()
    local Tab = self:_newTabObject("Settings", true)
    self.SettingsTab = Tab
    self._settingsRefs = {}

    local ThemeSection = Tab:CreateSection("Theme")
    self:_createColorPicker(ThemeSection)

    self._settingsRefs.RainbowAccent = ThemeSection:CreateToggle("Rainbow Accent", false, function(state)
        self.RainbowAccent = state
        self:_notifyAutoSave()
    end)

    self._settingsRefs.RainbowText = ThemeSection:CreateToggle("Rainbow Text", false, function(state)
        self.RainbowText = state
        self:_notifyAutoSave()
    end)

    local ConfigSection = Tab:CreateSection("Config")
    self._settingsRefs.ConfigNameInput = ConfigSection:CreateInput("Config Name", "default", self.CurrentConfigName, function(value)
        self.CurrentConfigName = value ~= "" and value or "default"
    end)

    self._settingsRefs.AutoLoad = ConfigSection:CreateToggle("Auto Load Config", false, function(state)
        self.AutoLoadConfig = state
        self:_notifyAutoSave()
    end)

    self._settingsRefs.AutoSave = ConfigSection:CreateToggle("Auto Save Config", false, function(state)
        self.AutoSaveConfig = state
        self:_notifyAutoSave()
    end)

    local configNames = self:GetConfigList()
    if #configNames == 0 then
        configNames = {"default"}
    end

    local ConfigDropdown = ConfigSection:CreateDropdown("Saved Configs", configNames, self.CurrentConfigName, function(value)
        self.CurrentConfigName = value
        if self._settingsRefs.ConfigNameInput then
            self._settingsRefs.ConfigNameInput:Set(value)
        end
    end)

    ConfigSection:CreateButton("Refresh Config List", function()
        local names = self:GetConfigList()
        if #names == 0 then
            names = {"default"}
        end
        ConfigDropdown:Refresh(names)
    end)

    ConfigSection:CreateButton("Save / Create Config", function()
        local name = self._settingsRefs.ConfigNameInput:Get()
        if name == "" then
            name = "default"
            self._settingsRefs.ConfigNameInput:Set(name)
        end

        if self:SaveConfig(name) then
            local names = self:GetConfigList()
            if #names == 0 then
                names = {"default"}
            end
            ConfigDropdown:Refresh(names)
            self:Notify("Config", "Saved " .. tostring(name), 2)
        end
    end)

    ConfigSection:CreateButton("Load Selected Config", function()
        local name = self._settingsRefs.ConfigNameInput:Get()
        if name == "" then
            name = self.CurrentConfigName
        end

        if self:LoadConfig(name) then
            self:Notify("Config", "Loaded " .. tostring(name), 2)
        end
    end)

    local KeybindSection = Tab:CreateSection("Keybind")
    self._settingsRefs.KeybindLabel = KeybindSection:CreateLabel("Current Toggle Key: " .. self.ToggleKey.Name)

    KeybindSection:CreateButton("Set Toggle Key", function()
        if self._isCapturingKeybind then
            return
        end

        self._isCapturingKeybind = true
        self._settingsRefs.KeybindLabel:Set("Press any key...")

        local captureConn
        captureConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then
                return
            end

            if input.UserInputType == Enum.UserInputType.Keyboard then
                self:SetToggleKey(input.KeyCode)
                self:Notify("Keybind", "Toggle key set to " .. input.KeyCode.Name, 2)
                self._isCapturingKeybind = false
                if captureConn then
                    captureConn:Disconnect()
                end
            end
        end)
    end)

    local WindowSection = Tab:CreateSection("Window")
    self._settingsRefs.DragSmooth = WindowSection:CreateSlider("Drag Smoothness", 5, 35, math.floor(self.DragSmoothing * 100 + 0.5), function(value)
        self.DragSmoothing = value / 100
        self:_notifyAutoSave()
    end)

    WindowSection:CreateButton("Hide UI", function()
        self:ToggleUI(false)
    end)

    WindowSection:CreateButton("Show UI", function()
        self:ToggleUI(true)
    end)

    WindowSection:CreateButton("Repair UI Visuals", function()
        self:RefreshUIIntegrity()
        self:Notify("UI", "Visual state refreshed.", 2)
    end)

    if self.AutoLoadConfig then
        self:LoadConfig(self.CurrentConfigName)
    end

    return Tab
end

--// =========================================================
--// HUB
--// =========================================================

local Window = Library.new({
    Name = "NovaHub",
    Title = "Nova Hub",
    Subtitle = "Dummy / Player Control",
    Width = 940,
    Height = 620,
    ToggleKey = Enum.KeyCode.RightShift
})

Window:Notify("Loaded", "Main hub loaded.", 3)

local State = {
    NotifyJoinLeave = false,
    TeleportEnabled = false,

    CurrentTargetName = nil,
    SelectedTargets = {},
    Blacklisted = {},

    TeleportMode = "Loop TP",
    OrbitRadius = 4,
    OrbitSpeed = 2,
    LoopSpeed = 0.12,
    HeadSitHeight = 2.3,

    PredictionBase = 0.12,
    PredictionVelocityFactor = 0.020,
    PredictionJumpFactor = 0.10,
    PredictionClamp = 0.75,
}

local TeleportConn
local thumbCache = {}
local userIdCache = {}

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid") or nil
end

local function getTorso(model)
    if not model then return nil end
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChild("Head")
end

local function getRootVelocity(part)
    if not part then
        return Vector3.zero
    end
    local ok, vel = pcall(function()
        return part.AssemblyLinearVelocity
    end)
    return ok and vel or Vector3.zero
end

local function getDistance(model)
    local hrp = getHRP()
    local torso = getTorso(model)
    if not hrp or not torso then
        return math.huge
    end
    return (hrp.Position - torso.Position).Magnitude
end

local function getStatus(model)
    local hum = getHumanoid(model)
    if not hum then
        return "No Humanoid"
    end
    if hum.Health <= 0 then
        return "Dead"
    end

    local bodyEffects = model:FindFirstChild("BodyEffects")
    local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")
    if ko and ko.Value == true then
        return "Knocked"
    end

    return "Alive"
end

local function getHP(model)
    local hum = getHumanoid(model)
    return hum and math.floor(hum.Health + 0.5) or 0
end

local function getAllTargets()
    local out = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and getTorso(plr.Character) then
            table.insert(out, {
                Name = plr.Name,
                DisplayName = plr.DisplayName,
                IsPlayer = true,
                Model = plr.Character,
                Player = plr,
            })
        end
    end

    for _, obj in ipairs(DUMMIES_FOLDER:GetChildren()) do
        if obj:IsA("Model") and getTorso(obj) then
            local exists = false
            for _, item in ipairs(out) do
                if item.Name == obj.Name then
                    exists = true
                    break
                end
            end

            if not exists then
                table.insert(out, {
                    Name = obj.Name,
                    DisplayName = obj.Name,
                    IsPlayer = false,
                    Model = obj,
                    Player = nil,
                })
            end
        end
    end

    table.sort(out, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)

    return out
end

local function getTargetNames()
    local names = {}
    for _, item in ipairs(getAllTargets()) do
        table.insert(names, item.Name)
    end
    if #names == 0 then
        table.insert(names, "NoTargets")
    end
    return names
end

local function getTargetByName(name)
    if not name or name == "" or name == "NoTargets" then
        return nil, nil
    end

    local plr = Players:FindFirstChild(name)
    if plr and plr.Character and getTorso(plr.Character) then
        return plr.Character, plr
    end

    local dummy = DUMMIES_FOLDER:FindFirstChild(name)
    if dummy and dummy:IsA("Model") and getTorso(dummy) then
        return dummy, nil
    end

    return nil, nil
end

local function getDisplayName(name)
    local plr = Players:FindFirstChild(name)
    if plr then
        return plr.DisplayName
    end
    return name
end

local function getUserIdFromNameSafe(name)
    if userIdCache[name] ~= nil then
        return userIdCache[name]
    end

    local plr = Players:FindFirstChild(name)
    if plr then
        userIdCache[name] = plr.UserId
        return plr.UserId
    end

    local ok, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(name)
    end)

    if ok then
        userIdCache[name] = userId
        return userId
    end

    userIdCache[name] = false
    return nil
end

local function getThumbnailForName(name)
    if thumbCache[name] ~= nil then
        return thumbCache[name] ~= false and thumbCache[name] or nil
    end

    local userId = getUserIdFromNameSafe(name)
    if not userId then
        thumbCache[name] = false
        return nil
    end

    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            userId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)

    if ok and image and image ~= "" then
        thumbCache[name] = image
        return image
    end

    thumbCache[name] = false
    return nil
end

local function predictPosition(model)
    local torso = getTorso(model)
    if not torso then
        return nil, nil, nil, 0
    end

    local vel = getRootVelocity(torso)
    local hum = getHumanoid(model)
    local speed = vel.Magnitude

    local timeAhead =
        State.PredictionBase
        + (speed * State.PredictionVelocityFactor)

    if hum and hum.FloorMaterial == Enum.Material.Air then
        timeAhead += State.PredictionJumpFactor
    end

    timeAhead = math.clamp(timeAhead, 0, State.PredictionClamp)

    local predicted = torso.Position + (vel * timeAhead)
    predicted = Vector3.new(
        predicted.X,
        torso.Position.Y + (vel.Y * math.min(timeAhead, 0.2)),
        predicted.Z
    )

    return predicted, torso, vel, timeAhead
end

local function lookAt(fromPos, toPos)
    return CFrame.new(fromPos, toPos)
end

local function tpToTarget(mode, targetModel, angle)
    local hrp = getHRP()
    if not hrp or not targetModel then
        return
    end

    local predicted, torso = predictPosition(targetModel)
    if not predicted or not torso then
        return
    end

    if mode == "Loop TP" then
        local dir = torso.CFrame.LookVector
        local flip = math.sin(angle) >= 0 and 1 or -1
        local offset = dir * (3 * flip)
        local pos = predicted + offset
        hrp.CFrame = lookAt(pos, predicted)

    elseif mode == "Orbit" then
        local offset = Vector3.new(
            math.cos(angle) * State.OrbitRadius,
            0.5,
            math.sin(angle) * State.OrbitRadius
        )
        local pos = predicted + offset
        hrp.CFrame = lookAt(pos, predicted)

    elseif mode == "Head Sit" then
        local pos = predicted + Vector3.new(0, State.HeadSitHeight, 0)
        hrp.CFrame = CFrame.new(pos)
    end
end

local function stopTeleport()
    State.TeleportEnabled = false
    if TeleportConn then
        TeleportConn:Disconnect()
        TeleportConn = nil
    end
end

local function startTeleportLoop()
    stopTeleport()

    State.TeleportEnabled = true
    local angle = 0
    local currentIndex = 1
    local lastSwap = 0

    TeleportConn = RunService.Heartbeat:Connect(function(dt)
        if not State.TeleportEnabled then
            return
        end

        angle += dt * (State.OrbitSpeed * 6)

        if State.TeleportMode == "Multi Loop" then
            if #State.SelectedTargets == 0 then
                return
            end

            if tick() - lastSwap >= State.LoopSpeed then
                lastSwap = tick()

                if currentIndex > #State.SelectedTargets then
                    currentIndex = 1
                end

                local targetName = State.SelectedTargets[currentIndex]
                local model = getTargetByName(targetName)
                if model then
                    tpToTarget("Loop TP", model, angle)
                end

                currentIndex += 1
            end
        else
            local model = getTargetByName(State.CurrentTargetName)
            if model then
                tpToTarget(State.TeleportMode, model, angle)
            end
        end
    end)
end

local function addSelected(name)
    if not name or name == "NoTargets" then return end
    if not table.find(State.SelectedTargets, name) then
        table.insert(State.SelectedTargets, name)
    end
end

local function removeSelected(name)
    local i = table.find(State.SelectedTargets, name)
    if i then
        table.remove(State.SelectedTargets, i)
    end
end

local function selectedText()
    if #State.SelectedTargets == 0 then
        return "Selected: none"
    end
    return "Selected: " .. table.concat(State.SelectedTargets, ", ")
end

local function blacklistText()
    local names = {}
    for name, yes in pairs(State.Blacklisted) do
        if yes then
            table.insert(names, name)
        end
    end
    table.sort(names)

    if #names == 0 then
        return "Blacklisted: none"
    end

    return "Blacklisted: " .. table.concat(names, ", ")
end

local function notifyWithThumb(title, body, targetName, duration)
    local thumb = getThumbnailForName(targetName)
    Window:Notify(title, body, duration or 3, thumb)
end

-- main tab
local MainTab = Window:CreateTab("Main")
local DummyTab = Window:CreateTab("Dummies")

local MainSection = MainTab:CreateSection("Main")
MainSection:CreateLabel("Dummy / player controls are in the Dummies tab.")
MainSection:CreateButton("Stop Teleport", function()
    stopTeleport()
    Window:Notify("Teleport", "Stopped.", 2)
end)

local TargetSection = DummyTab:CreateSection("Targets")
local SelectedLabel = TargetSection:CreateLabel("Selected: none")
local BlacklistLabel = TargetSection:CreateLabel("Blacklisted: none")
local InfoLabel = TargetSection:CreateLabel("Info: none")

local ThumbFrame = Create("Frame", {
    Parent = TargetSection.Holder,
    BackgroundColor3 = Theme.Surface2,
    Size = UDim2.new(1, 0, 0, 74)
})
AddCorner(ThumbFrame, UDim.new(0, 8))
AddStroke(ThumbFrame, Theme.Border, 1, 0)

local ThumbTitle = Create("TextLabel", {
    Parent = ThumbFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 8),
    Size = UDim2.new(1, -24, 0, 16),
    Font = Enum.Font.GothamMedium,
    Text = "Thumbnail Preview",
    TextColor3 = Theme.Text,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left
})

local ThumbImage = Create("ImageLabel", {
    Parent = ThumbFrame,
    BackgroundColor3 = Theme.Surface3,
    Position = UDim2.new(0, 12, 0, 28),
    Size = UDim2.new(0, 34, 0, 34),
    Image = "",
    ScaleType = Enum.ScaleType.Crop
})
AddCorner(ThumbImage, UDim.new(0, 6))
AddStroke(ThumbImage, Theme.Border, 1, 0)

local ThumbInfo = Create("TextLabel", {
    Parent = ThumbFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 56, 0, 28),
    Size = UDim2.new(1, -68, 0, 34),
    Font = Enum.Font.Gotham,
    Text = "No thumbnail",
    TextColor3 = Theme.SubText,
    TextSize = 12,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left
})

Window:_registerMainText(ThumbTitle)
Window:_registerSubText(ThumbInfo)

local targetNames = getTargetNames()

local CurrentTargetDropdown = TargetSection:CreateDropdown(
    "Current Target",
    targetNames,
    targetNames[1],
    function(value)
        State.CurrentTargetName = value
    end,
    "CurrentTarget"
)

if targetNames[1] ~= "NoTargets" then
    State.CurrentTargetName = targetNames[1]
end

local SelectionDropdown = TargetSection:CreateDropdown(
    "Selection Dropdown",
    targetNames,
    targetNames[1],
    function(value)
        if value ~= "NoTargets" then
            addSelected(value)
            SelectedLabel:Set(selectedText())
            Window:Notify("Selection", value .. " added.", 2, getThumbnailForName(value))
        end
    end,
    "SelectionDropdown"
)

local BlacklistDropdown = TargetSection:CreateDropdown(
    "Blacklist Dropdown",
    targetNames,
    targetNames[1],
    function(value)
        if value ~= "NoTargets" then
            State.Blacklisted[value] = true
            BlacklistLabel:Set(blacklistText())
            Window:Notify("Blacklist", value .. " blacklisted.", 2, getThumbnailForName(value))
        end
    end,
    "BlacklistDropdown"
)

TargetSection:CreateButton("Refresh All Target Lists", function()
    local names = getTargetNames()
    CurrentTargetDropdown:Refresh(names)
    SelectionDropdown:Refresh(names)
    BlacklistDropdown:Refresh(names)
    Window:Notify("Targets", "Target lists refreshed.", 2)
end)

TargetSection:CreateButton("Add Current To Selection", function()
    addSelected(State.CurrentTargetName)
    SelectedLabel:Set(selectedText())
end)

TargetSection:CreateButton("Remove Current From Selection", function()
    removeSelected(State.CurrentTargetName)
    SelectedLabel:Set(selectedText())
end)

TargetSection:CreateButton("Clear Selection", function()
    table.clear(State.SelectedTargets)
    SelectedLabel:Set(selectedText())
end)

TargetSection:CreateButton("Blacklist Current", function()
    if State.CurrentTargetName and State.CurrentTargetName ~= "NoTargets" then
        State.Blacklisted[State.CurrentTargetName] = true
        BlacklistLabel:Set(blacklistText())
        Window:Notify("Blacklist", State.CurrentTargetName .. " added.", 2, getThumbnailForName(State.CurrentTargetName))
    end
end)

TargetSection:CreateButton("Unblacklist Current", function()
    if State.CurrentTargetName then
        State.Blacklisted[State.CurrentTargetName] = nil
        BlacklistLabel:Set(blacklistText())
        Window:Notify("Blacklist", State.CurrentTargetName .. " removed.", 2, getThumbnailForName(State.CurrentTargetName))
    end
end)

TargetSection:CreateButton("Clear Blacklist", function()
    table.clear(State.Blacklisted)
    BlacklistLabel:Set(blacklistText())
    Window:Notify("Blacklist", "Cleared.", 2)
end)

local TeleportSection = DummyTab:CreateSection("Teleport")
TeleportSection:CreateDropdown(
    "Mode",
    {"Loop TP", "Orbit", "Head Sit", "Multi Loop"},
    "Loop TP",
    function(value)
        State.TeleportMode = value
    end,
    "TeleportMode"
)

TeleportSection:CreateToggle("Teleport Loop", false, function(state)
    State.TeleportEnabled = state
    if state then
        startTeleportLoop()
    else
        stopTeleport()
    end
end, "TeleportLoop")

TeleportSection:CreateSlider("Orbit Radius", 2, 12, 4, function(v)
    State.OrbitRadius = v
end, "OrbitRadius")

TeleportSection:CreateSlider("Orbit Speed", 1, 12, 2, function(v)
    State.OrbitSpeed = v
end, "OrbitSpeed")

TeleportSection:CreateSlider("Loop Speed x100", 5, 100, 12, function(v)
    State.LoopSpeed = v / 100
end, "LoopSpeed")

TeleportSection:CreateSlider("Head Sit Height x10", 10, 50, 23, function(v)
    State.HeadSitHeight = v / 10
end, "HeadSitHeight")

TeleportSection:CreateSlider("Base Prediction x100", 0, 50, 12, function(v)
    State.PredictionBase = v / 100
end, "PredictionBase")

TeleportSection:CreateSlider("Velocity Factor x1000", 0, 100, 20, function(v)
    State.PredictionVelocityFactor = v / 1000
end, "PredictionVelocityFactor")

TeleportSection:CreateSlider("Jump Factor x100", 0, 50, 10, function(v)
    State.PredictionJumpFactor = v / 100
end, "PredictionJumpFactor")

TeleportSection:CreateSlider("Prediction Clamp x100", 10, 100, 75, function(v)
    State.PredictionClamp = v / 100
end, "PredictionClamp")

local NotifySection = DummyTab:CreateSection("Notifications")
NotifySection:CreateToggle("Join / Leave Notifications", false, function(state)
    State.NotifyJoinLeave = state
end, "NotifyJoinLeave")

local function refreshInfo()
    local model = getTargetByName(State.CurrentTargetName)
    if not model then
        InfoLabel:Set("Info: none")
        ThumbImage.Image = ""
        ThumbInfo.Text = "No thumbnail"
        return
    end

    local status = getStatus(model)
    local hp = getHP(model)
    local dist = math.floor(getDistance(model) + 0.5)
    local display = getDisplayName(model.Name)

    InfoLabel:Set(
        "Info: @" .. model.Name
        .. " | Display: " .. display
        .. " | Status: " .. status
        .. " | HP: " .. tostring(hp)
        .. " | Dist: " .. tostring(dist)
    )

    local thumb = getThumbnailForName(model.Name)
    if thumb then
        ThumbImage.Image = thumb
        ThumbInfo.Text = model.Name
    else
        ThumbImage.Image = ""
        ThumbInfo.Text = "No valid Roblox thumbnail for this name"
    end
end

RunService.Heartbeat:Connect(function()
    refreshInfo()
    SelectedLabel:Set(selectedText())
    BlacklistLabel:Set(blacklistText())
end)

local function onPlayerAdded(plr)
    if State.NotifyJoinLeave then
        notifyWithThumb("Player Joined", plr.Name .. " joined the game.", plr.Name, 3)
    end

    if State.Blacklisted[plr.Name] then
        notifyWithThumb("Blacklist Alert", plr.Name .. " is in the game.", plr.Name, 4)
    end
end

local function onPlayerRemoving(plr)
    if State.NotifyJoinLeave then
        notifyWithThumb("Player Left", plr.Name .. " left the game.", plr.Name, 3)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

Window:Notify("Ready", "Dummies tab loaded above Settings.", 3)
