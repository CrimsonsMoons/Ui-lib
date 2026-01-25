local DereckUI = {}

local UIS = game:GetService("UserInputService")

DereckUI.Theme = {
    BG = Color3.fromRGB(0, 0, 0),
    Panel = Color3.fromRGB(22, 22, 22),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255)
}

local function stroke(obj)
    local s = Instance.new("UIStroke")
    s.Parent = obj
    s.Color = DereckUI.Theme.Accent
    s.Thickness = 1
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

----------------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------------
function DereckUI:CreateWindow(title)
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.CoreGui

    local main = Instance.new("Frame")
    main.Parent = gui
    main.BackgroundColor3 = DereckUI.Theme.Panel
    main.Size = UDim2.new(0, 480, 0, 320)
    main.Position = UDim2.new(0.5, -240, 0.5, -160)
    stroke(main)
    corner(main, 6)

    local top = Instance.new("TextLabel")
    top.Parent = main
    top.Size = UDim2.new(1, 0, 0, 34)
    top.BackgroundColor3 = DereckUI.Theme.BG
    top.Text = title
    top.TextColor3 = DereckUI.Theme.Text
    top.Font = Enum.Font.GothamBold
    top.TextSize = 16
    top.TextYAlignment = Enum.TextYAlignment.Center
    stroke(top)
    corner(top, 6)

    -- DRAGGING
    local dragging, dragStart, startPos

    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    ------------------------------------------------------------------
    -- TAB BAR (CENTERED + CLEAN)
    ------------------------------------------------------------------
    local tabBar = Instance.new("Frame")
    tabBar.Parent = main
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 34)
    tabBar.BackgroundTransparency = 1

    local tabList = Instance.new("UIListLayout")
    tabList.Parent = tabBar
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.Padding = UDim.new(0, 12)
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    ------------------------------------------------------------------
    -- PAGE CONTAINER (With padding)
    ------------------------------------------------------------------
    local pages = Instance.new("Frame")
    pages.Parent = main
    pages.Size = UDim2.new(1, 0, 1, -64)
    pages.Position = UDim2.new(0, 0, 0, 64)
    pages.BackgroundTransparency = 1
    pages.ClipsDescendants = true

    local pageCache = {}

    ------------------------------------------------------------------
    -- WINDOW API
    ------------------------------------------------------------------
    local window = {}

    function window:CreateTab(name)
        -- TAB BUTTON
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = tabBar
        tabBtn.Size = UDim2.new(0, 100, 1, -4)
        tabBtn.BackgroundColor3 = DereckUI.Theme.Panel
        tabBtn.Text = name
        tabBtn.TextColor3 = DereckUI.Theme.Text
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 14
        stroke(tabBtn)
        corner(tabBtn, 5)

        -- PAGE
        local page = Instance.new("ScrollingFrame")
        page.Parent = pages
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 4
        page.BackgroundTransparency = 1
        page.Visible = false

        local pad = Instance.new("UIPadding")
        pad.Parent = page
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingTop = UDim.new(0, 12)

        local layout = Instance.new("UIListLayout")
        layout.Parent = page
        layout.Padding = UDim.new(0, 8)

        pageCache[name] = page

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(pageCache) do p.Visible = false end
            page.Visible = true
        end)

        --------------------------------------------------------------
        -- TAB API (BUTTONS)
        --------------------------------------------------------------
        local tabAPI = {}

        function tabAPI:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Parent = page
            btn.Size = UDim2.new(1, -24, 0, 36)
            btn.BackgroundColor3 = DereckUI.Theme.Panel
            btn.Text = text
            btn.TextColor3 = DereckUI.Theme.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            stroke(btn)
            corner(btn, 5)

            btn.MouseButton1Click:Connect(callback)
        end

        return tabAPI
    end

    return window
end

return DereckUI
