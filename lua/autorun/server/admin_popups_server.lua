util.AddNetworkString( "AdminPopups_CasePopup" )
util.AddNetworkString( "AdminPopups_ClaimCase" )
util.AddNetworkString( "AdminPopups_CloseCase" )
util.AddNetworkString( "AdminPopups_ChatNotify" )

--[[
	FILE CONTROL
--]]

if not file.Exists( "admin_popups_caseclaims.txt","DATA" ) then
	file.Write( "admin_popups_caseclaims.txt", "[]" )
end

local caseclaims = util.JSONToTable( file.Read( "admin_popups_caseclaims.txt", "DATA" ) )

local function tabletofile()
	file.Write( "admin_popups_caseclaims.txt", util.TableToJSON( caseclaims ) )
end

--[[
	NET MESSAGES
--]]

net.Receive( "AdminPopups_ClaimCase", function( len, ply )
	local cur_time = CurTime()
	if ( ply.AdminPopups_NetRateLimit or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.AdminPopups_NetRateLimit = cur_time + 0.5
	
	local Plr = net.ReadEntity()
	
	if AdminPopups.PlayerHasAccess( ply ) and not Plr.AdminPopups_CaseClaimed then
		for k, v in ipairs( player.GetAll() ) do
			if AdminPopups.PlayerHasAccess( v ) then
				net.Start("AdminPopups_ClaimCase")
					net.WriteEntity( ply )
					net.WriteEntity( Plr )
				net.Send( v )
			end
		end
		
		-- Notify the reporter/Plr that it was claimed
		if AdminPopups.Config.NotifyClaimedTicket then
			net.Start( "AdminPopups_ChatNotify" )
				net.WriteString( "An admin ".. AdminPopups.Config.AdminClaimedTicketNotify )
			net.Send( Plr )
		end
		
		hook.Call( "AdminPopups_Hook_ClaimCase", GAMEMODE, ply, Plr )
		
		Plr.AdminPopups_CaseClaimed = ply
	end
end )

net.Receive( "AdminPopups_CloseCase", function( len, ply )
	local cur_time = CurTime()
	if ( ply.AdminPopups_NetRateLimit or 0 ) > cur_time then
		ply:ChatPrint( "You're running the command too fast. Slow down champ!" )
		return
	end
	ply.AdminPopups_NetRateLimit = cur_time + 0.5
	
	local Plr = net.ReadEntity()
	
	if not Plr or not IsValid( Plr ) then
		return
	end
	
	if not Plr.AdminPopups_CaseClaimed == ply then
		return
	end
	
	if timer.Exists( "AdminPopup_Timer_".. Plr:SteamID64() ) then
		timer.Destroy( "AdminPopup_Timer_".. Plr:SteamID64() )
	end
	
	for k, ply in ipairs( player.GetAll() ) do
		if AdminPopups.PlayerHasAccess( ply ) then
			net.Start("AdminPopups_CloseCase")
				net.WriteEntity( Plr )
			net.Send( ply )
		end
	end
	
	Plr.AdminPopups_CaseClaimed = nil
end )

--[[
	Admin Popup function
--]]
function AdminPopups.SendAdminPopup( Plr, message )
	if AdminPopups.Config.CaseUpdateOnly then
		if Plr.AdminPopups_CaseClaimed then
			if IsValid( Plr.AdminPopups_CaseClaimed ) and Plr.AdminPopups_CaseClaimed:IsPlayer() then
				net.Start( "AdminPopups_CasePopup" )
					net.WriteEntity( Plr )
					net.WriteString( message )
					net.WriteEntity( Plr.AdminPopups_CaseClaimed )
				net.Send( Plr.AdminPopups_CaseClaimed )
			end
		else
			for k, ply in ipairs( player.GetAll() ) do
				if AdminPopups.PlayerHasAccess( ply ) then
					net.Start( "AdminPopups_CasePopup" )
						net.WriteEntity( Plr )
						net.WriteString( message )
						net.WriteEntity( Plr.AdminPopups_CaseClaimed )
					net.Send( ply )
				end
			end
		end
	else
		for k, ply in ipairs( player.GetAll() ) do
			if AdminPopups.PlayerHasAccess( ply ) then
				net.Start("AdminPopups_CasePopup")
					net.WriteEntity( Plr )
					net.WriteString( message )
					net.WriteEntity( Plr.AdminPopups_CaseClaimed )
				net.Send( ply )
			end
		end
	end
	
	if IsValid( Plr ) and Plr:IsPlayer() then
		timer.Destroy( "AdminPopup_Timer_".. Plr:SteamID64() )
		
		if AdminPopups.Config.AutoCloseTime > 0 then
			timer.Create( "AdminPopup_Timer_".. Plr:SteamID64(), AdminPopups.Config.AutoCloseTime, 1, function()
				if IsValid( Plr ) and Plr:IsPlayer() then
					Plr.AdminPopups_CaseClaimed = nil
				end
			end )
		end
	end
end

--[[
	HOOKS
--]]

function AdminPopups.PlayerSay( ply, text )
	if ( string.StartWith( string.lower( text ), AdminPopups.Config.ReportCommand ) ) then
		text = string.Replace( text, AdminPopups.Config.ReportCommand, "" )
		
		if string.len( text ) < AdminPopups.Config.TicketMinimumCharacters then
			net.Start( "AdminPopups_ChatNotify" )
				net.WriteString( AdminPopups.Config.TicketMinimumNotificiation )
			net.Send( ply )
			
			return ""
		end
		
		local cur_time = CurTime()

		if ( ply.AdminPopups_SpamDelay or 0 ) > cur_time then
			net.Start( "AdminPopups_ChatNotify" )
				net.WriteString( "Please wait another ".. string.ToMinutesSeconds( math.Round( ply.AdminPopups_SpamDelay - cur_time ) ) .." before using the ticket system." )
			net.Send( ply )
			
			return ""
		end
		ply.AdminPopups_SpamDelay = cur_time + AdminPopups.Config.CreateTicketCooldown
		
		if AdminPopups.PlayerHasAccess( ply ) then
			if AdminPopups.Config.Debug then
				AdminPopups.SendAdminPopup( ply, text )
			end
		else
			AdminPopups.SendAdminPopup( ply, text )
		end

		net.Start( "AdminPopups_ChatNotify" )
			net.WriteString( AdminPopups.Config.PrintReportText )
		net.Send( ply )
		
		return ""
	end
end
hook.Add( "PlayerSay", "AdminPopups.PlayerSay", AdminPopups.PlayerSay )

hook.Add( "PlayerDisconnected", "AdminPopups_PopupsClose",function( Plr )
	for k, ply in ipairs( player.GetAll() ) do
		if AdminPopups.PlayerHasAccess( ply ) then
			net.Start( "AdminPopups_CloseCase" )
				net.WriteEntity( Plr )
			net.Send( ply )
		end
	end	
end )

hook.Add( "AdminPopups_Hook_ClaimCase", "AdminPopups_StoreClaims", function( admin, Plr )
	caseclaims[admin:SteamID()] = caseclaims[admin:SteamID()] or {
		name = admin:Nick(),
		claims = 0,
		lastclaim = os.time()
	}

	caseclaims[admin:SteamID()] = {
		name = admin:Nick(),
		claims = caseclaims[admin:SteamID()].claims + 1,
		lastclaim = os.time()
	}
	
	tabletofile()
end )