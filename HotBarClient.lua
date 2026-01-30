-- This was the code that went into the HotBar system in OneBlock.

local buttons = {}
local listOfItems = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerUI = player.PlayerGui

local lastUsedButton = "None"

function Activate(button)
	local Label = script.Parent.Parent.TextLabel
	if button.Name ~= "None" then
		if button.Name == lastUsedButton then
			ReplicatedStorage.HotbarEvent:FireServer(false)
			Label.TextTransparency = 1
			button.BackgroundColor3 = Color3.fromRGB(212, 206, 186)
			lastUsedButton = "None"
		else
			ReplicatedStorage.HotbarEvent:FireServer(true, button.Name)
			-- Creating a super cool function which shows what the name of the item is:
			task.spawn(function()
				Label.Text = button.Name
				Label.TextTransparency = 0
				task.wait(2)
				if Label.Text == button.Name then
					local Tween = TweenService:Create(Label, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {TextTransparency = 1})
					Tween:Play()
					Tween.Completed:Wait()
				end
			end)
			for i,v in pairs(script.Parent:GetChildren()) do
				if v:IsA("TextButton") and v.Name ~= "Sample" then
					v.BackgroundColor3 = Color3.fromRGB(212,206,186)
				end
			end
			button.BackgroundColor3 = Color3.fromRGB(152, 148, 134)
			lastUsedButton = button.Name
		end
	end
end




-- Create da hotbar buttons
for i = 1,9 do
	local hotbarClone = script.Parent.Sample:Clone()
	hotbarClone.Visible = true
	hotbarClone.Parent = script.Parent
	hotbarClone.Key.Text = i
	hotbarClone.ZIndex = i
	hotbarClone.Name = "None"
	hotbarClone.MouseButton1Click:Connect(function()Activate(hotbarClone) end)
	hotbarClone.MouseEnter:Connect(function()
		if hotbarClone.Name ~= "None" then
			playerUI.Tooltip.Frame.Visible = true
			playerUI.Tooltip.Frame.TextLabel.Text = hotbarClone.Name
		end
	end)
	hotbarClone.MouseLeave:Connect(function()
		playerUI.Tooltip.Frame.Visible = false
	end)
	table.insert(buttons, hotbarClone)
end

-- Useful function which allows you to find the Inventory Element, just using it's number. VERY COOL!!!
function findFromNumber(num)
	for i,v in pairs(player.Inventory:GetChildren()) do
		if i == num then
			return v
		end
	end
	return nil
end

-- Returns from the key Number
function returnFromNumber(num)
	for i,v in pairs(script.Parent:GetChildren()) do
		if v:IsA("TextButton") and v.ZIndex == num then
			return v
		end
	end
	return nil
end

function assignHandle(v, Name)
	local Handle
	local Tool
	if player.Backpack:FindFirstChild(Name) then
		Handle = player.Backpack[Name].Handle:Clone()
		Tool = player.Backpack[Name]
	else
		Handle = player.Character[Name].Handle:Clone()
		Tool = player.Character[Name]
	end
	if CollectionService:HasTag(Tool,"Block") then
		Handle = ReplicatedStorage.Blocks[Tool.Name]:Clone()
	end
	if ReplicatedStorage.EnlargenedItems:FindFirstChild(Tool.Name) then
		Handle = ReplicatedStorage.EnlargenedItems[Tool.Name]:Clone()
	end
	if v:FindFirstChild("ViewportFrame") then
		Handle.Parent = v.ViewportFrame
	end
	Handle.Position = Vector3.new(0,0,0)
	Handle.Orientation = Vector3.new(0,0,0)
end

-- Assign the hotbar buttons to the items
function assign()
	for i = 1,9 do
		local b = returnFromNumber(i)
		b.ViewportFrame:ClearAllChildren()
		b.Name = "None"
		b.Val.Text = ""
	end
	for i,v in pairs(player.Inventory:GetChildren()) do
		v:SetAttribute("Status", "None")
	end
	local num = 0
	for i,v in pairs(buttons) do
		repeat
			num += 1
		until findFromNumber(num) and player.Inventory[findFromNumber(num).Name] and player.Inventory[findFromNumber(num).Name].Value ~= 0 and player.Inventory[findFromNumber(num).Name]:GetAttribute("Status") == "None" or num >= (#player.Inventory:GetChildren() + 1)
		if num >= (#player.Inventory:GetChildren() + 1) then
			if findFromNumber(num) and player.Inventory:FindFirstChild(findFromNumber(num).Name) then
				player.Inventory[findFromNumber(num).Name]:SetAttribute("Status",  "Inventory")
			end
		else
			player.Inventory[findFromNumber(num).Name]:SetAttribute("Status",  "Hotbar")
			v.Name = findFromNumber(num).Name
			v.Val.Text = player.Inventory[findFromNumber(num).Name].Value
			assignHandle(v, findFromNumber(num).Name)
			
			table.insert(listOfItems, v.Name)
		end
	end
end

assign()

local function firstButton()
	for i = 1,9 do
		local button = returnFromNumber(i)
		if button.Name == "None" then
			return button
		end
	end
	return nil
end

function refresh()
	-- This function basically makes sure that everything that now has a value of 0 has been removed, and everything that now has a higher value than 0 has a special spot.
	-- This for loop removes everything that now has a value of 0
	for i,v in pairs(player.Inventory:GetChildren()) do
		if v.Value == 0 and v:GetAttribute("Status") ~= "Inventory" then
			local button = script.Parent:FindFirstChild(v.Name)
			if button then
				button.Name = "None"
				button.ViewportFrame:ClearAllChildren()
				button.Val.Text = ""
			end
		end
	end
	
	-- This for loop adds things that now have a value higher than 0.
	for i,v in pairs(player.Inventory:GetChildren()) do
		if v.Value > 0 and not script.Parent:FindFirstChild(v.Name) and v:GetAttribute("Status") ~= "Inventory" then
			local button = firstButton()
			if button then
				button.Name = v.Name
				button.Val.Text = v.Value
				assignHandle(button, v.Name)
				v:SetAttribute("Status", "Hotbar")
			else
				v:SetAttribute("Status", "Inventory")
			end
		end
	end
end

-- Equipping Tool
function currentTool()
	for i,v in pairs(player.Character:GetChildren()) do
		if v:IsA("Tool") then
			return v
		end
	end
	return nil
end

-- Cleans up before each frame.
RunService.PreRender:Connect(function()
	-- Updates the Hotbar UI
	refresh()
	-- Updates other UIs
	if currentTool() then
		script.Parent.Parent.Drop.Visible = true
	else
		script.Parent.Parent.Drop.Visible = false
	end
	-- If a player has equipped an item which now has been updated to 0, we now fix an error that might be caused.
	local foundItem = false
	for i,v in pairs(script.Parent:GetChildren()) do
		if v:IsA("TextButton") and v.Name == lastUsedButton then
			foundItem = true
		end
	end
	if not foundItem then
		for i,v in pairs(script.Parent:GetChildren()) do
			if v:IsA("TextButton") then
				v.BackgroundColor3 = script.Parent.Sample.BackgroundColor3
				ReplicatedStorage.HotbarEvent:FireServer(false)
			end
		end
	end
	-- Updates Item Counts
	for i = 1,9 do
		local button = returnFromNumber(i)
		if button.Name ~= "None" and button.Val.Text ~= 0 then
			local Value = player.Inventory[button.Name].Value
			button.Val.Text = Value
		end
	end
	-- Making sure that everything that is in the hotbar, is SUPPOSED to be in the hotbar
	for i,v in pairs(player.Inventory:GetChildren()) do
		if v:GetAttribute("Status") == "Inventory" and script.Parent:FindFirstChild(v.Name) and player.Inventory[v.Name].Value ~= 0 then
			local button = script.Parent[v.Name]
			button.Name = "None"
			button.ViewportFrame:ClearAllChildren()
			button.Val.Text = ""
		elseif v:GetAttribute("Status") == "Hotbar" and not script.Parent:FindFirstChild(v.Name) and player.Inventory[v.Name].Value ~= 0 then
			local button = firstButton()
			button.Name = v.Name
			button.Val.Text = v.Value
			assignHandle(button.ViewportFrame, button.Name)
		end
	end
end)

-- Creating keybinds for the hotbar
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.One then
		Activate(returnFromNumber(1))
	elseif input.KeyCode == Enum.KeyCode.Two then
		Activate(returnFromNumber(2))
	elseif input.KeyCode == Enum.KeyCode.Three then
		Activate(returnFromNumber(3))
	elseif input.KeyCode == Enum.KeyCode.Four then
		Activate(returnFromNumber(4))
	elseif input.KeyCode == Enum.KeyCode.Five then
		Activate(returnFromNumber(5))
	elseif input.KeyCode == Enum.KeyCode.Six then
		Activate(returnFromNumber(6))
	elseif input.KeyCode == Enum.KeyCode.Seven then
		Activate(returnFromNumber(7))
	elseif input.KeyCode == Enum.KeyCode.Eight then
		Activate(returnFromNumber(8))
	elseif input.KeyCode == Enum.KeyCode.Nine then
		Activate(returnFromNumber(9))
	elseif input.KeyCode == Enum.KeyCode.Zero then
		Activate(returnFromNumber(math.random(1,9)))
	end
end)



function drop()
	if currentTool() then
		-- Drop
		local tool = currentTool()
		ReplicatedStorage.DropTool:FireServer(tool)
	end
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.DPadUp then
		drop()
	end
end)

script.Parent.Parent.Drop.MouseButton1Click:Connect(function()
	drop()
end)
