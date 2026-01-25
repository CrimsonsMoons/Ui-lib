---=====================================================
-- DERECKUI - SHORT VERSION (TABS + BUTTONS)
-- CLEAN, FAST, FLUXUS STYLE
--=====================================================

local DereckUI = {}

local UIS = game:GetService("UserInputService")

-- Theme
DereckUI.Theme = {
    BG = Color3.fromRGB(0,0,0),
    Panel = Color3.fromRGB(15,15,15),
    Accent = Color3.fromRGB(255,255,255),
    Text = Color3.fromRGB(255,255,255)
}

local function stroke(obj)
    local s = Instance.new("UIStroke")
    s.Parent = obj
    s.Color = DereckUI.Theme.Accent
    s.Thickness = 1
end

-------------------------------------------------------
-- WINDOW
-------------------------------------------------------
function DereckUI:CreateWindow(title)
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.CoreGui
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame")
    main.Parent = gui
    main.Size = UDim2.new(0,450,0,300)
    main.Position = UDim2.new(0.5,-225,0.5,-150)
    main.BackgroundColor3 = DereckUI.Theme.Panel
    stroke(main)

    local top = Instance.new("TextLabel")
    top.Parent = main
    top.Size = UDim2.new(1,0,0,35)
    top.BackgroundColor3 = DereckUI.Theme.BG
    top.Text = title
    top.TextColor3 = DereckUI.Theme.Text
    top.TextSize = 16
    top.Font = Enum.Font.GothamBold
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

    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Parent = main
    tabBar.Size = UDim2.new(1,0,0,30)
    tabBar.Position = UDim2.new(0,0,0,35)
    tabBar.BackgroundColor3 = DereckUI.Theme.BG
    stroke(tabBar)

    local tabList = Instance.new("UIListLayout")
    tabList.Parent = tabBar
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.Padding = UDim.new(0,5)

    -- Page holder
    local pages = Instance.new("Frame")
    pages.Parent = main
    pages.Size = UDim2.new(1,0,1,-65)
    pages.Position = UDim2.new(0,0,0,65)
    pages.BackgroundTransparency = 1

    local pageCache = {}

    -------------------------------------------------------
    -- WINDOW API
    -------------------------------------------------------
    local window = {}

    function window:CreateTab(name)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = tabBar
        tabBtn.Text = name
        tabBtn.BackgroundColor3 = DereckUI.Theme.Panel
        tabBtn.TextColor3 = DereckUI.Theme.Text
        tabBtn.Size = UDim2.new(0,120,1,0)
        tabBtn.Font = Enum.Font.Gotham
        stroke(tabBtn)

        local page = Instance.new("ScrollingFrame")
        page.Parent = pages
        page.Size = UDim2.new(1,0,1,0)
        page.Visible = false
        page.ScrollBarThickness = 3

        local layout = Instance.new("UIListLayout")
        layout.Parent = page
        layout.Padding = UDim.new(0,6)

        pageCache[name] = page

        tabBtn.MouseButton1Click:Connect(function()
            for _,pg in pairs(pageCache) do pg.Visible = false end
            page.Visible = true
        end)

        ---------------------------------------------------
        -- TAB API
        ---------------------------------------------------
        local tab = {}

        function tab:Button(text, callback)
            local b = Instance.new("TextButton")
            b.Parent = page
            b.Size = UDim2.new(1,-20,0,35)
            b.BackgroundColor3 = DereckUI.Theme.Panel
            b.Text = text
            b.TextColor3 = DereckUI.Theme.Text
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            stroke(b)

            b.MouseButton1Click:Connect(callback)
        end

        return tab
    end

    return window
end

return DereckUI
