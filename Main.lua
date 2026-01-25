--- DereckUI V3 (Simplified Working Version)
local DereckUI = {}

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

DereckUI.Theme = {
    Background = Color3.fromRGB(0,0,0),
    Panel = Color3.fromRGB(10,10,10),
    Text = Color3.fromRGB(255,255,255),
    Accent = Color3.fromRGB(255,255,255)
}

local function createStroke(obj)
    local s = Instance.new("UIStroke")
    s.Parent = obj
    s.Color = DereckUI.Theme.Accent
    s.Thickness = 1
end

function DereckUI:CreateWindow(name)
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.CoreGui

    local main = Instance.new("Frame")
    main.Parent = gui
    main.Size = UDim2.new(0,450,0,300)
    main.Position = UDim2.new(0.5,-225,0.5,-150)
    main.BackgroundColor3 = DereckUI.Theme.Panel
    createStroke(main)

    local top = Instance.new("TextLabel")
    top.Parent = main
    top.Size = UDim2.new(1,0,0,35)
    top.BackgroundColor3 = DereckUI.Theme.Background
    top.Text = name
    top.TextColor3 = DereckUI.Theme.Text
    top.Font = Enum.Font.Gotham
    top.TextSize = 16

    local dragging = false
    local dragStart
    local startPos

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

    local tabs = Instance.new("Frame")
    tabs.Parent = main
    tabs.Size = UDim2.new(1,0,0,30)
    tabs.Position = UDim2.new(0,0,0,35)
    tabs.BackgroundColor3 = DereckUI.Theme.Background
    createStroke(tabs)

    local tabList = Instance.new("UIListLayout")
    tabList.Parent = tabs
    tabList.FillDirection = Enum.FillDirection.Horizontal

    local pages = Instance.new("Frame")
    pages.Parent = main
    pages.Size = UDim2.new(1,0,1,-65)
    pages.Position = UDim2.new(0,0,0,65)
    pages.BackgroundTransparency = 1

    local pageContainer = {}

    function main:CreateTab(tabName)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = tabs
        tabBtn.Text = tabName
        tabBtn.Size = UDim2.new(0,120,1,0)
        tabBtn.BackgroundColor3 = DereckUI.Theme.Panel
        tabBtn.TextColor3 = DereckUI.Theme.Text
        createStroke(tabBtn)

        local page = Instance.new("ScrollingFrame")
        page.Parent = pages
        page.Size = UDim2.new(1,0,1,0)
        page.Visible = false
        page.ScrollBarThickness = 3

        local layout = Instance.new("UIListLayout")
        layout.Parent = page
        layout.Padding = UDim.new(0,6)

        pageContainer[tabName] = page

        tabBtn.MouseButton1Click:Connect(function()
            for _,p in pairs(pageContainer) do p.Visible = false end
            page.Visible = true
        end)

        local tabAPI = {}

        function tabAPI:Button(text, callback)
            local b = Instance.new("TextButton")
            b.Parent = page
            b.Size = UDim2.new(1,-20,0,35)
            b.BackgroundColor3 = DereckUI.Theme.Panel
            b.Text = text
            b.TextColor3 = DereckUI.Theme.Text
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            createStroke(b)

            b.MouseButton1Click:Connect(callback)
        end

        tabAPI.Page = page
        return tabAPI
    end

    return main
end

return DereckUI
