-- The code that went into creating the Blockland Saving and Loading Screen!
-- Created abt a year ago, so I'm going to revise it soon.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local loading = false

function assignHandle(player, ViewportFrame, Name)
	local Handle
	local Tool
	if not game.StarterPack:FindFirstChild(Name) then
		Handle = game.ReplicatedStorage.Blocks[Name]:Clone()
	else
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
	end
	Handle.Parent = ViewportFrame
	Handle.Position = Vector3.new(0,0,0)
	Handle.Orientation = Vector3.new(0,0,0)
end

function checkSlotData(plrId, num)
	local IslandDS = DataStoreService:GetDataStore("Blockland")
	if IslandDS:GetAsync(plrId.."_"..tostring(num)) then
		return false
	else
		return true
	end
end

function save(player)
	local saveFile = {}
	if player.Slot.Value ~= 4 and player:FindFirstChild("FinishedLoading") then
		for i,v in pairs(workspace.Blocks:GetChildren()) do
			local blockFile = {name = v.Name, X = v.Position.X, Y = v.Position.Y, Z = v.Position.Z, RotationX = v.Rotation.X, RotationY = v.Rotation.Y, RotationZ = v.Rotation.Z}
			
			if v.Name == "Furnace" then
				blockFile.Fuel = v.Fuel.Value
				blockFile.Input = {}
				blockFile.Output = {}
				for i,v in pairs(v.Input:GetChildren()) do
					table.insert(blockFile.Input, v.Name)
				end
				for i,v in pairs(v.Output:GetChildren()) do
					table.insert(blockFile.Output, v.Name)
				end
			elseif v.Name == "Crusher" then
				blockFile.Input = {}
				blockFile.Output = {}
				for i,v in pairs(v.Input:GetChildren()) do
					table.insert(blockFile.Input, v.Name)
				end
				for i,v in pairs(v.Output:GetChildren()) do
					table.insert(blockFile.Output, v.Name)
				end
			elseif v.Name == "Melter" then
				blockFile.Fuel = v.Fuel.Value
				blockFile.Input = {}
				blockFile.Output = {}
				for i,v in pairs(v.Input:GetChildren()) do
					table.insert(blockFile.Input, v.Name)
				end
				for i,v in pairs(v.Output:GetChildren()) do
					table.insert(blockFile.Output, v.Name)
				end
			elseif v.Name == "Disc Mold Plate" then
				blockFile.MoldingTime = v.MoldingTime.Value
			elseif v.Name == "Iron Pickaxe Hilt Mold Plate" then
				blockFile.MoldingTime = v.MoldingTime.Value
			elseif v.Name == "Iron Axe Head Mold Plate" then
				blockFile.MoldingTime = v.MoldingTime.Value
			elseif v.Name == "Tree Grower" then
				blockFile.Essence = v.InsertedEssence.Value
				blockFile.GrowthTime = v.growthTime.Value
			elseif v.Name == "Sawmill" then
				blockFile.Fuel = v.Fuel.Value
				blockFile.Input = {}
				blockFile.Output = {}
				for i,v in pairs(v.Input:GetChildren()) do
					table.insert(blockFile.Input, v.Name)
				end
				for i,v in pairs(v.Output:GetChildren()) do
					table.insert(blockFile.Output, v.Name)
				end
			end
			table.insert(saveFile, blockFile)
		end
		DataStoreService:GetDataStore("Blockland"):SetAsync(player.UserId .."_"..tostring(player.Slot.Value), saveFile)
	end
end

function load(player)
	
	if loading then
		return
	end
	
	loading = true
	
	local DataStore = DataStoreService:GetDataStore("Blockland")
	local Async = DataStore:GetAsync(player.UserId .."_"..tostring(player.Slot.Value))
	
	player.PlayerGui.SaveUI.BuildingBlocks.Visible = true
	player.PlayerGui.SaveUI.SlotSelection.Visible = false
	
	
	if Async and Async ~= {} then
		local thyme = 0
		for i,v in pairs(Async) do
			if thyme >= 10 then
				ReplicatedStorage.FrameMeasures[player.UserId].OnServerEvent:Wait()
				thyme = 0
			else
				thyme += 1
			end
			local BlockClone = ReplicatedStorage.Blocks[v.name]:Clone()
			BlockClone.Parent = workspace.Blocks
			BlockClone.Position = Vector3.new(v.X, v.Y, v.Z)
			BlockClone.Rotation = Vector3.new(v.RotationX,v.RotationY,v.RotationZ)
			if BlockClone.Name == "Furnace" and v.Fuel then
				BlockClone.Fuel.Value = v.Fuel
				for i2,v2 in pairs(v.Input) do
					local newItem = Instance.new("IntValue")
					newItem.Name = v2
					newItem.Parent = BlockClone.Input
				end
				for i2,v2 in pairs(v.Output) do
					local newItem = Instance.new("IntValue")
					newItem.Name = v2
					newItem.Parent = BlockClone.Output
				end
			elseif BlockClone.Name == "Crusher" and v.Input then
				for i2,v2 in pairs(v.Input) do
					local newItem = Instance.new("IntValue")
					newItem.Name = v2
					newItem.Parent = BlockClone.Input
				end
				for i2,v2 in pairs(v.Output) do
					local newItem = Instance.new("IntValue")
					newItem.Name = v2
					newItem.Parent = BlockClone.Output
				end
			elseif BlockClone.Name == "Melter" and v.Fuel then
				BlockClone.Fuel.Value = v.Fuel
				for i2,v2 in pairs(v.Input) do
					local newItem = Instance.new("IntValue")
					newItem.Name = v2
					newItem.Parent = BlockClone.Input
				end
				for i2,v2 in pairs(v.Output) do
					local newItem = Instance.new("IntValue")
					newItem.Name = v2
					newItem.Parent = BlockClone.Output
				end
			elseif BlockClone.Name == "Disc Mold Plate" and v.MoldingTime then
				BlockClone.MoldingTime.Value = v.MoldingTime
			elseif BlockClone.Name == "Iron Pickaxe Hilt Mold Plate" and v.MoldingTime then
				BlockClone.MoldingTime.Value = v.MoldingTime	
			elseif v.Name == "Iron Axe Head Mold Plate" then
				BlockClone.MoldingTime.Value = v.MoldingTime
			elseif BlockClone.Name == "Tree Grower" then
				if not v.GrowthTime then
					print("No growth time :(")
				elseif v.GrowthTime > 0 and v.Essence ~= "" then
					BlockClone.InsertedEssence.Value = v.Essence
					BlockClone.growthTime.Value = v.GrowthTime
					BlockClone.growTree:Fire(player)
					print("Saved Data, currently growing result of " .. v.Essence .. " which has " .. v.GrowthTime .. " seconds left.")
				end
			end
			player.PlayerGui.SaveUI.BuildingBlocks.BlockProgress.MaxBlocks.Size = UDim2.new((i / #Async),0,1,0)
			player.PlayerGui.SaveUI.BuildingBlocks.BlockProgress.TextLabel.Text = "Building your World! ("..i.."/"..#Async..")"
		end
		for i,v in pairs(workspace.Blocks:GetChildren()) do
			if thyme >= #Async / 100 then
				ReplicatedStorage.FrameMeasures[player.UserId].OnServerEvent:Wait()
				thyme = 0
			else
				thyme += 1
			end
			local ValueClone = Instance.new("ObjectValue", ReplicatedStorage.BlockPos)
			ValueClone.Name = tostring(v.Position)
			ValueClone.Value = v
			player.PlayerGui.SaveUI.BuildingBlocks.BlockProgress.MaxBlocks.Size = UDim2.new((i / #workspace.Blocks:GetChildren()),0,1,0)
			player.PlayerGui.SaveUI.BuildingBlocks.BlockProgress.TextLabel.Text = "Syncing Block Data ("..math.floor(i / #workspace.Blocks:GetChildren() * 100).."%"..")"
		end
	end
	player.Character.PrimaryPart.Anchored = false
	player.PlayerGui.SaveUI.BuildingBlocks.Visible = false
	local FinishedLoading = Instance.new("BoolValue", player)
	FinishedLoading.Name = "FinishedLoading"
end

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Wait()
	
	local playerUI = player.PlayerGui
	
	local SaveUI = playerUI:WaitForChild("SaveUI").SlotSelection
	
	local Slot = Instance.new("IntValue", player)
	
	Slot.Name = "Slot"
	Slot.Value = 4
	
	SaveUI.Visible = true
	
	player.Character.PrimaryPart.Anchored = true
	player.Character:PivotTo(workspace.SpawnLocation.CFrame)
	
	for i = 1,3 do
		local slotData = checkSlotData(player.UserId, i)
		local slot = SaveUI["Slot"..i]
		
		slot.NUsed.Visible = slotData
		
		local indX = math.ceil(player.UserId / i) % #ReplicatedStorage.Blocks:GetChildren() + i
		
		local blockName = ReplicatedStorage.Blocks:GetChildren()[math.fmod(player.UserId * i, #ReplicatedStorage.Blocks:GetChildren()) + 1].Name
		
		assignHandle(player, slot.ItemHolder, blockName)
		slot.MouseButton1Click:Connect(function()
			player.Slot.Value = i
			load(player)
		end)
	end
end)

Players.PlayerRemoving:Connect(save)
