
local DereckUI = {}

local UIS = game:GetService("UserInputService")

DereckUI.Theme = {
    BG = Color3.fromRGB(0,0,0),
    Panel = Color3.fromRGB(20,20,20),
    Accent = Color3.fromRGB(255,255,255),
    Text = Color3.fromRGB(255,255,255)
}

local function stroke(obj)
    local s = Instance.new("UIStroke")
    s.Parent = obj
    s.Color = DereckUI.Theme.Accent
    s.Thickness = 1
end

------------------------------------------------------------
-- WINDOW
------------------------------------------------------------
function DereckUI:CreateWindow(title)
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.CoreGui

    local main = Instance.new("Frame")
    main.Parent = gui
    main.Size = UDim2.new(0, 460, 0, 320)
    main.Position = UDim2.new(0.5, -230, 0.5, -160)
    main.BackgroundColor3 = DereckUI.Theme.Panel
    stroke(main)

    local top = Instance.new("TextLabel")
    top.Parent = main
    top.Size = UDim2.new(1, 0, 0, 35)
    top.BackgroundColor3 = DereckUI.Theme.BG
    top.Text = title
    top.TextColor3 = DereckUI.Theme.Text
    top.Font = Enum.Font.GothamBold
    top.TextSize = 17
    stroke(top)

    -- Dragging
    local dragging = false
    local dragStart, startPos

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

    ------------------------------------------------------------
    -- TAB BAR
    ------------------------------------------------------------
    local tabBar = Instance.new("Frame")
    tabBar.Parent = main
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 35)
    tabBar.BackgroundColor3 = DereckUI.Theme.BG
    stroke(tabBar)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabBar
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 6)

    ------------------------------------------------------------
    -- PAGE HOLDER
    ------------------------------------------------------------
    local pages = Instance.new("Frame")
    pages.Parent = main
    pages.Size = UDim2.new(1, 0, 1, -65)
    pages.Position = UDim2.new(0, 0, 0, 65)
    pages.BackgroundTransparency = 1

    local pageCache = {}

    ------------------------------------------------------------
    -- WINDOW API
    ------------------------------------------------------------
    local window = {}

    function window:CreateTab(name)
        --------------------------------------------------------
        -- TAB BUTTON
        --------------------------------------------------------
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = tabBar
        tabBtn.Size = UDim2.new(0, 120, 1, 0)
        tabBtn.Text = name
        tabBtn.BackgroundColor3 = DereckUI.Theme.Panel
        tabBtn.TextColor3 = DereckUI.Theme.Text
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 14
        tabBtn.AutoButtonColor = true
        stroke(tabBtn)

        --------------------------------------------------------
        -- PAGE
        --------------------------------------------------------
        local page = Instance.new("ScrollingFrame")
        page.Parent = pages
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 4
        page.Visible = false
        page.BackgroundTransparency = 1

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Parent = page
        pageLayout.Padding = UDim.new(0, 6)

        pageCache[name] = page

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(pageCache) do p.Visible = false end
            page.Visible = true
        end)

        --------------------------------------------------------
        -- TAB API
        --------------------------------------------------------
        local tabAPI = {}

        function tabAPI:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Parent = page
            btn.Size = UDim2.new(1, -20, 0, 36)
            btn.BackgroundColor3 = DereckUI.Theme.Panel
            btn.Text = text
            btn.TextColor3 = DereckUI.Theme.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            stroke(btn)

            btn.MouseButton1Click:Connect(callback)
        end

        return tabAPI
    end

    return window
end

return DereckUI
