-----------------------------------------------------------
--       Shazbot Sounds! by Vectus on Sargeras (A)       --
-- Filename: Shazbot.lua                                 --
-- Author: Eleswon/Vectus on Sargeras (A)               --
-- Description: This file controls the functionality     -- 
-- of the Shazbot! add-on. The add-on will allow players --
-- to hear VGS sounds and announce them in chat. Only    --
-- players with this addon will hear the sounds.         --
-----------------------------------------------------------

--------------------
-- Main Variables --
--------------------

local Shazbot = {}
local shazDB

-- Event Handler Setup
Shazbot.eventHandler = CreateFrame("Frame")
Shazbot.eventHandler.eventList = {
	["PLAYER_ENTERING_WORLD"] = function(self) Shazbot:PLAYER_ENTERING_WORLD(self) end,
	["CHAT_MSG_GUILD"] = function(self, msg, author) Shazbot:chatHandler(self, msg, author) end,
	["CHAT_MSG_SAY"] = function(self, msg, author) Shazbot:chatHandler(self, msg, author) end,
	["CHAT_MSG_YELL"] = function(self, msg, author) Shazbot:chatHandler(self, msg, author) end,
	["CHAT_MSG_PARTY"] = function(self, msg, author) Shazbot:chatHandler(self, msg, author) end,
	["CHAT_MSG_PARTY_LEADER"] = function(self, msg, author) Shazbot:chatHandler(self, msg, author) end,
	["CHAT_MSG_RAID"] = function(self, msg, author) Shazbot:chatHandler(self, msg, author) end,
	["CHAT_MSG_RAID_LEADER"] = function(self, msg, author) Shazbot:chatHandler(self, msg, author) end,
	["CHAT_MSG_INSTANCE_CHAT"] = function(self, msg, author) Shazbot:chatHandler(self, msg, author) end,
	--["PLAYER_LOGOUT"] = function(self) Shazbot:saveShazDB(self) end,
}

-- Register initial events
Shazbot.eventHandler:RegisterEvent("PLAYER_LOGIN")
--Shazbot.eventHandler:RegisterEvent("ADDON_LOADED")

-- Event Handler
Shazbot.eventHandler:SetScript("OnEvent", function(self, event, ...)
	-- Player login
	if (event == "PLAYER_LOGIN") then
		-- Load addon config
		Shazbot:OnLoad(self, name)
		Shazbot.eventHandler:UnregisterEvent("PLAYER_LOGIN")
	else
		Shazbot.eventHandler.eventList[event](self, ...)
	end
end)
	
----------------------
-- OnLoad Functions --
----------------------

function Shazbot:OnLoad(self, name)

--if name == "Shazbot" then
	Shazbot.eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	-- Load AceGUI 
	AceGUI = AceGUI or LibStub("AceGUI-3.0")

	if not shazDB then shazDB = ShazDB() end
	if not shazPlayerVars then shazPlayerVars = {currentChannel = "SAY", currentClass = "LIGHT"} end
	
	-- Setup Slash Commands
	SLASH_ShazCmd1 = "/vgs"
	SlashCmdList["ShazCmd"] = Shazbot_Commands
	
	-- Register events
	Shazbot:OnEnable()
	
	-- Print Loaded Message
	ChatFrame1:AddMessage("VGS System Loaded. Use /vgs ui for chat options and /vgs for a command list.", 1, 0, 0)
--end
end

function Shazbot:PLAYER_ENTERING_WORLD(self)
	--Play '[VGH] Hi.' to welcome the player.
	Shazbot:playSound("vgh", false)
end

------------------------------
-- Enable/Disable Functions --
------------------------------

function Shazbot:OnEnable()
	if (Shazbot.enabled == false) or (Shazbot.enabled == nil) then
		--Shazbot.eventHandler:RegisterEvent("ADDON_LOADED")
		Shazbot.eventHandler:RegisterEvent("CHAT_MSG_GUILD")
		Shazbot.eventHandler:RegisterEvent("CHAT_MSG_SAY")
		Shazbot.eventHandler:RegisterEvent("CHAT_MSG_YELL")
		Shazbot.eventHandler:RegisterEvent("CHAT_MSG_PARTY")
		Shazbot.eventHandler:RegisterEvent("CHAT_MSG_PARTY_LEADER")
		Shazbot.eventHandler:RegisterEvent("CHAT_MSG_RAID")
		Shazbot.eventHandler:RegisterEvent("CHAT_MSG_RAID_LEADER")
		Shazbot.eventHandler:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
		--Shazbot.eventHandler.eventList = shazDB.events
		Shazbot.enabled = true
	end
end

function Shazbot:OnDisable()
	-- TODO: Disable outgoing commands from using /vgs
	Shazbot.eventHandler:UnregisterAllEvents()
	Shazbot.enabled = false
end

function Shazbot:powerSwitch(info, flag)
	if flag == true then
		Shazbot:OnEnable()
		Shazbot.enabled = true
	else
		Shazbot:OnDisable()
		Shazbot.enabled = false
	end
end

-----------------------
-- AceConfig Options --
-----------------------

local function getChannel(info)
	return shazPlayerVars.currentChannel
end

local function setChannel(info, value)
	shazPlayerVars.currentChannel = value
end

local function getClass(info)
	return shazPlayerVars.currentClass
end

local function setClass(info, value)
	shazPlayerVars.currentClass = value
end

function Shazbot:InitOptions()

	-- List of available channels
	local chatChannels = {
        ["GUILD"] = "Guild",
		["SAY"] = "Say",
		["YELL"] = "Yell",
		["PARTY"] = "Party",
		["RAID"] = "Raid",
		["INSTANCE_CHAT"] = "Instance Chat",
	}

	local classOptions = {
		["LIGHT"] = "Light",
		["MEDIUM"] = "Medium",
		["HEAVY"] = "Heavy",
	}

	-- Options for AceConfig
	self.options = {
		name = "Shazbot",
		type = "group",
		--get = getOption,
		--set = setOption,
		args = {
			enable = {
				name = "Enable",
				desc = "Enables / disables the addon",
				type = "toggle",
				set = function(info,val) Shazbot:powerSwitch(info, val) end,
				get = function(info) return Shazbot.enabled end,
			},
			general = {
				name = "General",
				type = "group",
				args = {
					options = {
						type = "group",
						name = "Options",
						--inline = true,
						args = {
							channel = {
								type = "select",
								name = "Channel Select",
								desc = "Choose which channel to broadcast on.",
								get = getChannel,
								set = setChannel,
								--style = "dropdown",
								values = chatChannels,
							},
							class = {
								type = "select",
								name = "Class Voice",
								desc = "Choose which class the voice playback will be.",
								get = getClass,
								set = setClass,
								values = classOptions,
							},
						},
					},
				},
			},
		},
	}
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Shazbot", self.options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Shazbot", "Shazbot")
end

--------------------
-- PlaySound Func --
--------------------

function Shazbot:playSound(soundID, msgFlag)
	if shazPlayerVars.currentClass == "LIGHT" then 
		PlaySoundFile("Interface\\addons\\Shazbot\\media\\" .. shazDB.sound.light[soundID] .. ".ogg","MASTER")
	elseif shazPlayerVars.currentClass == "MEDIUM" then
		PlaySoundFile("Interface\\addons\\Shazbot\\media\\" .. shazDB.sound.medium[soundID] .. ".ogg","MASTER")
	elseif shazPlayerVars.currentClass == "HEAVY" then
		PlaySoundFile("Interface\\addons\\Shazbot\\media\\" .. shazDB.sound.heavy[soundID] .. ".ogg","MASTER")
	end
	if msgFlag then
		SendChatMessage(shazDB.message[soundID], shazPlayerVars.currentChannel)
	end
end

----------------
-- Get MSG ID --
----------------

-- Returns the appropriate message
function Shazbot:getMSGID(msg)
	local index
	for k,v in pairs(shazDB.message) do
		if msg == v then
			return k
		end
	end
	return 0
end

-----------------------
-- Check for VGS CMD --
-----------------------

-- Looks up the VGS ID from shazDB.
-- Returns true if msg is valid command, otherwise returns false.
function Shazbot:getVGSID(msg)
	local index
	for k,v in pairs(shazDB.message) do
		if msg == k then
			return true
		end
	end
	return false
end

---------------------
-- Channel Handler --
---------------------

function Shazbot:chatHandler(self, msg, author)
	-- We need to make sure the sound plays only when other player use it
	-- to avoid multiple plays for one command		
	if IsPlayer(author) == 0 then
		-- Find out if player used a VGS command
		soundID = Shazbot:getMSGID(msg)
		if soundID ~= 0 then
			Shazbot:playSound(soundID, false)
		end
	end
end

-----------------------
-- Command Generator --
-----------------------

-- Creates an interactive label that allows the user to launch a command
function Shazbot:commandUILabelGen(frame, text, command)
	local ilabel = AceGUI:Create("InteractiveLabel")
	ilabel:SetText(text)
	ilabel:SetHighlight(1, 0, 1)
	ilabel:SetCallback("OnClick", function() Shazbot:playSound(command, true) end)
	frame:AddChild(ilabel)
end

------------------
-- UI Functions --
------------------

-- Creates a container and scroll frame
function Shazbot:addScrollFrame(parent)
	-- Local Variables
	local shazFrameUIScrollContainer
	local shazFrameUIScroll

	-- Create Scroll Frame Container TODO: Add this portion to its own function
	shazFrameUIScrollContainer = AceGUI:Create("InlineGroup")
	--shazFrameUIScrollContainer:SetHeight(parent.status.height-100)
	shazFrameUIScrollContainer:SetFullHeight(true)
	shazFrameUIScrollContainer:SetFullWidth(true)
	shazFrameUIScrollContainer:SetLayout("Fill")
	
	-- Add the frame
	shazFrameUIScroll = AceGUI:Create("ScrollFrame")
	--shazFrameUIScroll:SetLayout("Flow")
	shazFrameUIScrollContainer:AddChild(shazFrameUIScroll)
	
	return shazFrameUIScrollContainer, shazFrameUIScroll
end

-- Adds widgets safely
function Shazbot:UIRefresh(frame, widget)
	-- Show elements
	frame:PauseLayout()
	frame:AddChildren(widget)
	frame:ResumeLayout()
	frame:ApplyStatus()
end

function Shazbot:UIList()
	-- Local variables
	local shazFrameUI

	-- Create Main Frame
	shazFrameUI = AceGUI:Create("Frame")
	shazFrameUI:SetLayout("Flow")
	shazFrameUI:SetStatusTable({width=400, height=400})
	shazFrameUI:SetTitle("Shazbot!")
	shazFrameUI:SetCallback("OnClose", function(shazFrameUI) AceGUI:Release(shazFrameUI) end)
	
	-- Add Left Menu
	local shazList, shazListScroll = Shazbot:addScrollFrame(shazFrameUI)
	
	-- Add the new widget to the frame
	Shazbot:UIRefresh(shazFrameUI, shazList)
	
	-- Populates List using values in shazDB
	for k, v in pairs(shazDB.message) do
		Shazbot:commandUILabelGen(shazListScroll, v, k)
	end
end

--------------------
-- Slash Commands --
--------------------

function Shazbot_Commands(cmd)
	cmd = cmd:trim()
	local lower = cmd:lower()
	
	if (cmd == "") and (not shazFrameUI or (not shazFrameUI:IsVisible())) then
		-- Call a UI that will show a list of commands to the user
		Shazbot:UIList()
	elseif (cmd == "ui") or (cmd == "config") then
		local AceDialog = LibStub("AceConfigDialog-3.0")
		local AceRegistry = AceRegistry or LibStub("AceConfigRegistry-3.0")
		
		if (not Shazbot.options) then
			Shazbot:InitOptions()
		end
		
		AceDialog:Open("Shazbot")
	elseif (cmd == "light") then
		shazPlayerVars.currentClass = "LIGHT"
	elseif (cmd == "medium") then
		shazPlayerVars.currentClass = "MEDIUM"
	elseif (cmd == "heavy") then
		shazPlayerVars.currentClass = "HEAVY"
	else
		if Shazbot.enabled == true then
			if Shazbot:getVGSID(cmd) then
				Shazbot:playSound(lower, true)
			else
				print("Command not found!")
			end
		else
			print("Shazbot is currently disabled.")
		end
	end
	
end

--------------------
-- Helper Methods --
--------------------

function IsPlayer(author)
	-- Get the current realm name
	local player = GetUnitName("player")
	local realm = GetRealmName():gsub(" ", "-")
	local fullAuthor = player .. "-" .. realm:gsub("-", "", 1)
	local fullPlayer = player .. "-" ..realm
	
	if (author == fullAuthor) or (author == player) or (player == fullPlayer) then
		return 1
	else
		return 0
	end
end