--Code that went into the main inventory system.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")


local player = game.Players.LocalPlayer

script.Parent.BackButton.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.HotbarFrame.Visible = true
	-- Clearing all Buttons.
end)

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
	Handle.Parent = v.ViewportFrame
	Handle.Position = Vector3.new(0,0,0)
	Handle.Orientation = Vector3.new(0,0,0)
end

function returnFromNumber(num)
	for i,v in pairs(script.Parent.Hotbar:GetChildren()) do
		if v:IsA("TextButton") and v.ZIndex == num then
			return v
		end
	end
	return nil
end

function firstButton()
	for i = 1,9 do
		local button = returnFromNumber(i)
		if button.Name == "None" then
			return button
		end
	end
	return nil
end

-- Sending an item from the hotbar to the inventory.
script.Parent.Hotbar.ChildAdded:Connect(function(button)
	button.MouseButton1Click:Connect(function()
		if button:IsA("TextButton") and button.Name ~= "None" then
			local Value = player.Inventory[button.Name]
			Value:SetAttribute("Status", "Inventory")
			--Moving the button
			button.Name = "None"
			button.Val.Text = ""
			button.ViewportFrame:ClearAllChildren()

			local newButton = script.Parent.Inventory.Sample:Clone()
			newButton.Parent = script.Parent.Inventory
			newButton.Name = Value.Name
			newButton.Visible = true
			newButton.Val.Text = Value.Value
			assignHandle(newButton, Value.Name)
		end
	end)
end)

-- Sending an item from the inventory, back to the hotbar.
script.Parent.Inventory.ChildAdded:Connect(function(button)
	if button:IsA("TextButton") then
		button.MouseButton1Click:Connect(function()
			local newButton = firstButton()
			if newButton then
				player.Inventory[button.Name]:SetAttribute("Status", "Hotbar")
				newButton.Name = button.Name
				newButton.Val.Text = button.Val.Text
				assignHandle(newButton, newButton.Name)

				button:Destroy()
			else
			end
		end)
	end
end)

-- Adding in all Inventory elements when it is opened.
script.Parent.Changed:Connect(function(prop)
	if script.Parent.Visible == true and prop == "Visible" then
		--[[
		for _, v in pairs(game.Players.LocalPlayer.Inventory:GetChildren()) do
			local status = v:GetAttribute("Status")
			if status ~= "None" then
				local Item = script.Parent[status].Sample:Clone()
				Item.Name = v.Name
				Item.Val.Text = v.Value
				Item.Parent = script.Parent[status]
				assignHandle(Item, v.Name)
				Item.Visible = true
			end
		end]]
		
		for i = 1,9 do
			local Item = script.Parent.Hotbar.Sample:Clone()
			Item.Name = "None"
			Item.ZIndex = i
			Item.Visible = true
			Item.Parent = script.Parent.Hotbar
			
			Item.MouseEnter:Connect(function()
				local ToolTip = player.PlayerGui.Tooltip.Frame
				ToolTip.Visible = true
				ToolTip.TextLabel.Text = Item.Name
			end)
			Item.MouseLeave:Connect(function()
				player.PlayerGui.Tooltip.Frame.Visible = false
			end)
		end
		for i,v in pairs(player.Inventory:GetChildren()) do
			local status = v:GetAttribute("Status")
			if status == "Hotbar" and v.Value > 0 then
				local Item = firstButton()
				Item.Name = v.Name
				Item.Val.Text = v.Value
				assignHandle(Item, v.Name)
			elseif status == "Inventory" and v.Value > 0 then
				local Item = script.Parent.Inventory.Sample:Clone()
				Item.Name = v.Name
				Item.Val.Text = v.Value
				Item.Parent = script.Parent.Inventory
				assignHandle(Item, v.Name)
				Item.Visible = true
				Item.MouseEnter:Connect(function()
					local ToolTip = player.PlayerGui.Tooltip.Frame
					ToolTip.Visible = true
					ToolTip.TextLabel.Text = Item.Name
				end)
				Item.MouseLeave:Connect(function()
					player.PlayerGui.Tooltip.Frame.Visible = false
				end)
			end
		end
	elseif prop == "Visible" and script.Parent.Visible == false then
		for _, v in pairs(script.Parent.Hotbar:GetChildren()) do
			if v:IsA("TextButton") and v.Name ~= "Sample" then
				v:Destroy()
			end
		end
		for _, v in pairs(script.Parent.Inventory:GetChildren()) do
			if v:IsA("TextButton") and v.Name ~= "Sample" then
				v:Destroy()
			end
		end
	
	end
end)
