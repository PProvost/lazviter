--[[
Lazviter/Utils.lua

Copyright 2008 Quaiche

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

local myname, ns = ...
local addonName = GetAddOnMetadata(myname, "Title")

function ns.Print(...) 
	print("|cFF33FF99" .. addonName .. "|r:", ...) 
end

local debugf = tekDebug and tekDebug:GetFrame(myname)

function ns.Debug(...) 
	if debugf then 
		debugf:AddMessage(string.join(", ", tostringall(...))) 
	end 
end

function ns.IsFriend(name)
	for i = 1, GetNumFriends() do
		if GetFriendInfo(i) == name then return true end
	end
end

function ns.IsGuildMember(name)
	for i = 1, GetNumGuildMembers() do
		if GetGuildRosterInfo(i) == name then return true end
	end
end

function ns.IsGuildMemberOnline(name)
   local count = GetNumGuildMembers(true)
   local nom, online
   for index = 1,count do
      nom, _, _, _, _, _, _, _, online = GetGuildRosterInfo(index)
      if name == nom and online == 1 then
         return 1
      end
   end
end

function ns.InviteUnit(name)
	if UnitIsUnit(name, "player") then return end
	if ns.IsGuildMember(name) then
		if ns.IsGuildMemberOnline(name) then
			InviteUnit(name)
		else
			ns.Print("Not online "..name)
		end
	else
		ns.Print("Inviting "..name.." (non guild)")
		InviteUnit(name)
	end
end


