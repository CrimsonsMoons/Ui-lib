local DereckUI = {}

local UIS = game:GetService("UserInputService")

DereckUI.Theme = {
    BG = Color3.fromRGB(0, 0, 0),
    Panel = Color3.fromRGB(18,18,18),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255)
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
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame")
    main.Parent = gui
    main.BackgroundColor3 = DereckUI.Theme.Panel
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    stroke(main)

    local top = Instance.new("TextLabel")
    top.Parent = main
    top.BackgroundColor3 = DereckUI.Theme.BG
    top.Size = UDim2.new(1, 0, 0, 38)
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
    -- TAB BAR (clean spacing)
    ------------------------------------------------------------
    local tabBar = Instance.new("Frame")
    tabBar.Parent = main
    tabBar.Size = UDim2.new(1, 0, 0, 32)
    tabBar.Position = UDim2.new(0, 0, 0, 38)
    tabBar.BackgroundColor3 = DereckUI.Theme.BG
    stroke(tabBar)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabBar
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    ------------------------------------------------------------
    -- PAGE AREA (clean margins)
    ------------------------------------------------------------
    local pages = Instance.new("Frame")
    pages.Parent = main
    pages.Size = UDim2.new(1, 0, 1, -70)
    pages.Position = UDim2.new(0, 0, 0, 70)
    pages.BackgroundTransparency = 1
    pages.ClipsDescendants = true

    local pageCache = {}

    ------------------------------------------------------------
    -- WINDOW API
    ------------------------------------------------------------
    local window = {}

    function window:CreateTab(name)
        ------------------------------------------------------
        -- TAB BUTTON (nicely styled)
        ------------------------------------------------------
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = tabBar
        tabBtn.Size = UDim2.new(0, 120, 1, -6)
        tabBtn.BackgroundColor3 = DereckUI.Theme.Panel
        tabBtn.Text = name
        tabBtn.TextColor3 = DereckUI.Theme.Text
        tabBtn.Font = Enum.Font.Gotham
        tabBtn.TextSize = 15
        stroke(tabBtn)

        ------------------------------------------------------
        -- PAGE AREA (clean padding + margins)
        ------------------------------------------------------
        local page = Instance.new("ScrollingFrame")
        page.Parent = pages
        page.Size = UDim2.new(1, 0, 1, 0)
        page.ScrollBarThickness = 5
        page.Visible = false
        page.BackgroundTransparency = 1

        local pl = Instance.new("UIPadding")
        pl.Parent = page
        pl.PaddingLeft = UDim.new(0, 12)
        pl.PaddingTop = UDim.new(0, 12)

        local layout = Instance.new("UIListLayout")
        layout.Parent = page
        layout.Padding = UDim.new(0, 10)

        pageCache[name] = page

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(pageCache) do p.Visible = false end
            page.Visible = true
        end)

        ------------------------------------------------------
        -- TAB API
        ------------------------------------------------------
        local tab = {}

        function tab:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Parent = page
            btn.Size = UDim2.new(1, -24, 0, 38)
            btn.BackgroundColor3 = DereckUI.Theme.Panel
            btn.Text = text
            btn.TextColor3 = DereckUI.Theme.Text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 15
            stroke(btn)

            btn.MouseButton1Click:Connect(callback)
        end

        return tab
    end

    return window
end

return DereckUI
