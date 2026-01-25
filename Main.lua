--============================================================
--- DERECKUI V3 - FLUXUS BLACK + NEON WHITE (SOFT-GLOW)
-- PART 1: Core Engine, Window, Dragging, Resizing, Glow System
--============================================================

local DereckUI = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--============================================================
-- THEME (Default - can be changed in Theme Tab later)
--============================================================
DereckUI.Theme = {
    Background = Color3.fromRGB(0, 0, 0),        -- Absolute black
    Panel      = Color3.fromRGB(10, 10, 10),     -- Near-black panels
    Accent     = Color3.fromRGB(255, 255, 255),  -- Neon white
    Text       = Color3.fromRGB(255, 255, 255),  -- White text
    Glow       = Color3.fromRGB(255, 255, 255),  -- Glow color
}

DereckUI.Settings = {
    GlowStrength = 0.55,     -- Soft glow level (0.4–0.7 recommended)
    BlurEnabled  = false,    -- Glass Mode toggle
    UIScale      = 1,        -- Rescaling UI
}

--============================================================
-- QUICK HELPERS
--============================================================
local function New(class, properties)
    local obj = Instance.new(class)
    for i, v in next, properties do
        obj[i] = v
    end
    return obj
end

local function Tween(obj, info)
    TweenService:Create(obj, TweenInfo.new(
        info.Time or 0.15,
        info.Style or Enum.EasingStyle.Quad,
        info.Direction or Enum.EasingDirection.Out
    ), info.Goal):Play()
end

--============================================================
-- GLOW OUTLINE SYSTEM
--============================================================
function DereckUI:AddGlow(parent, thickness)
    thickness = thickness or 18

    local glow = New("ImageLabel", {
        Parent = parent,
        Name = "Glow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://4996891970",        -- Soft glow texture
        ImageColor3 = DereckUI.Theme.Glow,
        ImageTransparency = 1 - DereckUI.Settings.GlowStrength,
        ZIndex = parent.ZIndex - 1,
        Size = UDim2.new(1, thickness, 1, thickness),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })

    return glow
end

--============================================================
-- MAIN WINDOW CREATION
--============================================================
function DereckUI:CreateWindow(title)
    local theme = DereckUI.Theme

    -- ScreenGui container
    local ScreenGui = New("ScreenGui", {
        Parent = getgenv().DereckUI_Parent or game.CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    })

    --========================================================
    -- BACKGROUND BLUR (Glass Mode)
    --========================================================
    if DereckUI.Settings.BlurEnabled then
        local blur = New("BlurEffect", {
            Parent = game.Lighting,
            Size = 0
        })
        Tween(blur, {Time = 0.4, Goal = {Size = 13}})
    end

    --========================================================
    -- MAIN WINDOW FRAME
    --========================================================
    local Main = New("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 520, 0, 350),
        Position = UDim2.new(0.5, -260, 0.5, -175)
    })

    local UIStroke = New("UIStroke", {
        Parent = Main,
        Color = theme.Accent,
        Thickness = 1.6,
        Transparency = 0
    })

    -- Soft glow halo
    DereckUI:AddGlow(Main, 24)

    -- Scaling
    New("UIScale", {
        Parent = Main,
        Scale = DereckUI.Settings.UIScale
    })

    --========================================================
    -- TOP BAR (Title + Drag)
    --========================================================
    local TopBar = New("Frame", {
        Parent = Main,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,40)
    })

    DereckUI:AddGlow(TopBar, 22)

    New("UIStroke", {
        Parent = TopBar,
        Color = theme.Accent,
        Thickness = 1
    })

    local Title = New("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamMedium,
        TextSize = 16,
        TextColor3 = theme.Text,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    --========================================================
    -- DRAGGING SYSTEM
    --========================================================
    local dragging = false
    local dragStart, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    --========================================================
    -- RESIZE HANDLE
    --========================================================
    local Resize = New("Frame", {
        Parent = Main,
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -12, 1, -12),
        ZIndex = 50
    })

    local resizeGlow = DereckUI:AddGlow(Resize, 16)

    local resizing = false
    local resizeStart, startSize

    Resize.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = Main.Size
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            Main.Size = UDim2.new(0, startSize.X.Offset + delta.X, 0, startSize.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    --========================================================
    -- TAB BAR + PAGES
    --========================================================
    local TabBar = New("Frame", {
        Parent = Main,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0, 40)
    })

    New("UIStroke", {
        Parent = TabBar,
        Color = theme.Accent,
        Thickness = 1
    })

    DereckUI:AddGlow(TabBar, 20)

    local TabList = New("UIListLayout", {
        Parent = TabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left
    })

    local Pages = New("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -75),
        Position = UDim2.new(0, 0, 0, 75)
    })

    local PageContainer = {}

    --========================================================
    -- CREATE TAB FUNCTION (extended in Part 2)
    --========================================================
    function DereckUI:_internalCreateTab(tabName)
        local theme = DereckUI.Theme

        local TabButton = New("TextButton", {
            Parent = TabBar,
            BackgroundColor3 = theme.Panel,
            TextColor3 = theme.Text,
            Text = tabName,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            Size = UDim2.new(0, 120, 1, 0),
            BorderSizePixel = 0
        })

        New("UIStroke", {
            Parent = TabButton,
            Color = theme.Accent,
            Thickness = 1
        })

        DereckUI:AddGlow(TabButton, 20)

        local Page = New("ScrollingFrame", {
            Parent = Pages,
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            Visible = false,
            Size = UDim2.new(1, 0, 1, 0)
        })

        New("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 10)
        })

        PageContainer[tabName] = Page

        TabButton.MouseButton1Click:Connect(function()
            for _, page in next, PageContainer do
                page.Visible = false
            end
            Page.Visible = true
        end)

        return { Page = Page }
    end

    return self
end

--============================================================
-- DERECKUI V3 - PART 2
-- UI Elements, Ripple Engine, Theme Changer Tab
--============================================================

--------------------------------------------------------------
-- RIPPLE EFFECT (Material UI Ripple)
--------------------------------------------------------------
function DereckUI:CreateRipple(button)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = DereckUI.Theme.Accent
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5,0.5)
    ripple.ZIndex = button.ZIndex + 5
    ripple.Parent = button

    return ripple
end

function DereckUI:PlayRipple(button, clickPos)
    local ripple = self:CreateRipple(button)

    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.8
    ripple.Position = UDim2.new(0, clickPos.X - button.AbsolutePosition.X, 0, clickPos.Y - button.AbsolutePosition.Y)
    ripple.Size = UDim2.new(0, 0, 0, 0)

    local tweenOut = TweenService:Create(ripple, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    })

    tweenOut:Play()
    tweenOut.Completed:Connect(function() ripple:Destroy() end)
end

--------------------------------------------------------------
-- BASE ELEMENT CREATOR
--------------------------------------------------------------
local function NewElementFrame(parent)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = DereckUI.Theme.Panel
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, -10, 0, 36)

    Instance.new("UIStroke", {
        Parent = frame,
        Color = DereckUI.Theme.Accent,
        Thickness = 1
    })

    DereckUI:AddGlow(frame, 18)

    return frame
end

--------------------------------------------------------------
-- BUTTON
--------------------------------------------------------------
function DereckUI:CreateButton(tab, text, callback)
    local frame = NewElementFrame(tab.Page)

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1,0,1,0)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = DereckUI.Theme.Text

    btn.MouseButton1Down:Connect(function(x,y)
        self:PlayRipple(btn, Vector2.new(x,y))
        task.defer(callback)
    end)

    return frame
end

--------------------------------------------------------------
-- TOGGLE
--------------------------------------------------------------
function DereckUI:CreateToggle(tab, text, default, callback)
    local frame = NewElementFrame(tab.Page)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0,10,0,0)
    label.Size = UDim2.new(1,-50,1,0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = text
    label.TextColor3 = DereckUI.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("Frame")
    toggle.Parent = frame
    toggle.AnchorPoint = Vector2.new(1,0.5)
    toggle.Position = UDim2.new(1,-10,0.5,0)
    toggle.Size = UDim2.new(0,36,0,16)
    toggle.BackgroundColor3 = DereckUI.Theme.Background
    toggle.BorderSizePixel = 0

    Instance.new("UICorner", {Parent = toggle, CornerRadius = UDim.new(0,8)})

    local knob = Instance.new("Frame")
    knob.Parent = toggle
    knob.Size = UDim2.new(0,16,0,16)
    knob.Position = default and UDim2.new(1,-16,0,0) or UDim2.new(0,0,0,0)
    knob.BackgroundColor3 = DereckUI.Theme.Accent

    Instance.new("UICorner", {Parent = knob, CornerRadius = UDim.new(0,8)})
    DereckUI:AddGlow(knob, 12)

    local state = default
    callback(state)

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            Tween(knob, {Time = 0.22, Goal = {Position = state and UDim2.new(1,-16,0,0) or UDim2.new(0,0,0,0)}})
            task.defer(function() callback(state) end)
        end
    end)

    return frame
end

--------------------------------------------------------------
-- SLIDER
--------------------------------------------------------------
function DereckUI:CreateSlider(tab, text, min, max, default, callback)
    local frame = NewElementFrame(tab.Page)
    frame.Size = UDim2.new(1, -10, 0, 50)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0,10,0,2)
    label.Size = UDim2.new(1,-20,0,20)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = DereckUI.Theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text .. " : " .. default

    local bar = Instance.new("Frame")
    bar.Parent = frame
    bar.Position = UDim2.new(0,10,0,28)
    bar.Size = UDim2.new(1,-20,0,8)
    bar.BackgroundColor3 = DereckUI.Theme.Background
    bar.BorderSizePixel = 0

    Instance.new("UICorner", {Parent = bar, CornerRadius = UDim.new(0,4)})

    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.BackgroundColor3 = DereckUI.Theme.Accent
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)

    DereckUI:AddGlow(fill, 12)

    local dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos,0,1,0)
        local val = math.floor(min + (max-min)*pos)
        label.Text = text.." : "..val
        callback(val)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return frame
end

--------------------------------------------------------------
-- DROPDOWN
--------------------------------------------------------------
function DereckUI:CreateDropdown(tab, text, list, callback)
    local frame = NewElementFrame(tab.Page)
    frame.Size = UDim2.new(1,-10,0,38)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0,10,0,0)
    label.Size = UDim2.new(1,-20,1,0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = DereckUI.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text .. " ▼"

    local open = false
    local optionFrames = {}

    function toggleDropdown()
        open = not open
        for _,opt in ipairs(optionFrames) do
            opt.Visible = open
        end
        frame.Size = open and UDim2.new(1,-10,0,38 + #list*28) or UDim2.new(1,-10,0,38)
    end

    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleDropdown()
        end
    end)

    for i,v in ipairs(list) do
        local opt = Instance.new("TextButton")
        opt.Parent = frame
        opt.Visible = false
        opt.Text = v
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 13
        opt.TextColor3 = DereckUI.Theme.Text
        opt.BackgroundColor3 = DereckUI.Theme.Background
        opt.BorderSizePixel = 0
        opt.Position = UDim2.new(0,0,0,38 + (i-1)*28)
        opt.Size = UDim2.new(1,0,0,28)

        DereckUI:AddGlow(opt, 14)

        opt.MouseButton1Down:Connect(function(x,y)
            DereckUI:PlayRipple(opt, Vector2.new(x,y))
            toggleDropdown()
            callback(v)
        end)

        optionFrames[i] = opt
    end

    return frame
end

--------------------------------------------------------------
-- KEYBIND PICKER
--------------------------------------------------------------
function DereckUI:CreateKeybind(tab, text, defaultKey, callback)
    local frame = NewElementFrame(tab.Page)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0,10,0,0)
    label.Size = UDim2.new(1,-80,1,0)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = DereckUI.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text

    local bindBtn = Instance.new("TextButton")
    bindBtn.Parent = frame
    bindBtn.AnchorPoint = Vector2.new(1,0.5)
    bindBtn.Position = UDim2.new(1,-10,0.5,0)
    bindBtn.Size = UDim2.new(0,70,0,26)
    bindBtn.Text = defaultKey.Name
    bindBtn.Font = Enum.Font.Gotham
    bindBtn.TextSize = 14
    bindBtn.TextColor3 = DereckUI.Theme.Text
    bindBtn.BackgroundColor3 = DereckUI.Theme.Background
    bindBtn.BorderSizePixel = 0

    local waiting = false
    local currentKey = defaultKey

    DereckUI:AddGlow(bindBtn, 14)

    bindBtn.MouseButton1Click:Connect(function()
        waiting = true
        bindBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input)
        if waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
            currentKey = input.KeyCode
            waiting = false
            bindBtn.Text = currentKey.Name
            callback(currentKey)
        end
    end)

    return frame
end

--------------------------------------------------------------
-- LABEL / SECTION TITLE
--------------------------------------------------------------
function DereckUI:CreateLabel(tab, text)
    local label = Instance.new("TextLabel")
    label.Parent = tab.Page
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,-10,0,26)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 15
    label.TextColor3 = DereckUI.Theme.Accent
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left

    return label
end


--------------------------------------------------------------
-- THEME CHANGER TAB (live theme editing)
--------------------------------------------------------------
function DereckUI:InjectThemeTab(window)
    local themeTab = window:CreateTab("Themes")

    self:CreateLabel(themeTab, "Colors")

    self:CreateSlider(themeTab, "Glow Strength", 0, 100, DereckUI.Settings.GlowStrength * 100, function(v)
        DereckUI.Settings.GlowStrength = v / 100
        -- Glow updates automatically due to render pipeline 
    end)

    self:CreateDropdown(themeTab, "Accent Preset", {"White","Blue","Red","Purple","Green"}, function(choice)
        local map = {
            White  = Color3.fromRGB(255,255,255),
            Blue   = Color3.fromRGB(0,170,255),
            Red    = Color3.fromRGB(255,60,60),
            Purple = Color3.fromRGB(155,70,255),
            Green  = Color3.fromRGB(60,255,160)
        }
        DereckUI.Theme.Accent = map[choice]
    end)

    self:CreateToggle(themeTab, "Glass Mode", false, function(state)
        DereckUI.Settings.BlurEnabled = state
    end)

    return themeTab
end


--============================================================
-- DERECKUI V3 - PART 3 (FINAL)
-- Notifications • Config Saving • Glass Mode
--============================================================

local HttpService = game:GetService("HttpService")

--------------------------------------------------------------
-- NOTIFICATION SYSTEM
--------------------------------------------------------------
function DereckUI:Notify(title, message, duration)
    duration = duration or 3

    local ScreenGui = getgenv().DereckUI_NotifyGui
    if not ScreenGui then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game.CoreGui
        ScreenGui.ResetOnSpawn = false
        getgenv().DereckUI_NotifyGui = ScreenGui
    end

    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.AnchorPoint = Vector2.new(1,1)
    notif.Position = UDim2.new(1,-15,1,-15)
    notif.Size = UDim2.new(0, 260, 0, 80)
    notif.BackgroundColor3 = DereckUI.Theme.Panel
    notif.BorderSizePixel = 0

    Instance.new("UIStroke", {
        Parent = notif,
        Color = DereckUI.Theme.Accent,
        Thickness = 1
    })

    DereckUI:AddGlow(notif, 20)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Parent = notif
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, -10, 0, 28)
    titleLbl.Position = UDim2.new(0,5,0,2)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 15
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Text = title
    titleLbl.TextColor3 = DereckUI.Theme.Accent

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Parent = notif
    msgLbl.BackgroundTransparency = 1
    msgLbl.Size = UDim2.new(1, -10, 0, 48)
    msgLbl.Position = UDim2.new(0,5,0,30)
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 13
    msgLbl.TextWrapped = true
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top
    msgLbl.Text = message
    msgLbl.TextColor3 = DereckUI.Theme.Text

    -- Slide in animation
    notif.Position = UDim2.new(1,300,1,-15)
    Tween(notif, {Time = 0.35, Goal = {Position = UDim2.new(1,-15,1,-15)}})

    task.wait(duration)

    -- Slide out animation
    Tween(notif, {Time = 0.35, Goal = {Position = UDim2.new(1,300,1,-15)}})
    task.wait(0.4)
    notif:Destroy()
end


--------------------------------------------------------------
-- CONFIG SAVE / LOAD SYSTEM (JSON)
--------------------------------------------------------------
DereckUI.ConfigFolder = "DereckUI_Configs"

function DereckUI:EnsureConfigFolder()
    if not isfolder(self.ConfigFolder) then
        makefolder(self.ConfigFolder)
    end
end

function DereckUI:SaveConfig(name, data)
    self:EnsureConfigFolder()

    writefile(self.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(data))

    self:Notify("Config Saved", "Saved as " .. name .. ".json", 3)
end

function DereckUI:LoadConfig(name)
    local path = self.ConfigFolder .. "/" .. name .. ".json"
    if not isfile(path) then
        self:Notify("Load Failed", "Config does not exist.", 3)
        return nil
    end

    local data = HttpService:JSONDecode(readfile(path))

    self:Notify("Config Loaded", "Loaded " .. name .. ".json", 3)

    return data
end


--------------------------------------------------------------
-- APPLY GLASS MODE (Blur + Transparency)
--------------------------------------------------------------
function DereckUI:ApplyGlass(window)
    if self.Settings.BlurEnabled then
        window.BackgroundTransparency = 0.35
    else
        window.BackgroundTransparency = 0
    end
end


--------------------------------------------------------------
-- FINAL ASSEMBLY HOOKS
--------------------------------------------------------------
function DereckUI:Attach(window)
    self.Window = window
    self:InjectThemeTab(window)
end

--------------------------------------------------------------
-- ALLOW TAB TO AUTO-GENERATE ELEMENT FUNCTIONS
--------------------------------------------------------------
function DereckUI:CreateTab(name)
    local tab = self:_internalCreateTab(name)

    function tab:Button(text, callback)
        return DereckUI:CreateButton(tab, text, callback)
    end

    function tab:Toggle(text, default, callback)
        return DereckUI:CreateToggle(tab, text, default, callback)
    end

    function tab:Slider(text, min,max,default,callback)
        return DereckUI:CreateSlider(tab, text, min, max, default, callback)
    end

    function tab:Dropdown(text,list,callback)
        return DereckUI:CreateDropdown(tab, text, list, callback)
    end

    function tab:Keybind(text,key,callback)
        return DereckUI:CreateKeybind(tab, text, key, callback)
    end

    function tab:Label(text)
        return DereckUI:CreateLabel(tab, text)
    end

    return tab
end

-- Internal alias
DereckUI._internalCreateTab = DereckUI.CreateTab


--------------------------------------------------------------
-- RETURN MODULE
--------------------------------------------------------------
return DereckUI
