local admin_popups = admin_popups or {}

-- Theme fallback
local Theme = (ancore and ancore.Theme and ancore.Theme.Dark) or nil

local function HexToColor(hex, a)
    if not hex then return Color(255,255,255,a or 255) end
    hex = hex:gsub("#","")

    return Color(
        tonumber(hex:sub(1,2),16),
        tonumber(hex:sub(3,4),16),
        tonumber(hex:sub(5,6),16),
        a or 255
    )
end
--[[
	MATERIALS
--]]
local mat_goto = Material( "icon16/lightning_go.png", "noclamp smooth" )
local mat_bring = Material( "icon16/arrow_left.png", "noclamp smooth" )
local mat_freeze = Material( "icon16/link.png", "noclamp smooth" )
local mat_return = Material( "icon16/arrow_undo.png", "noclamp smooth" )
local mat_spectate = Material( "icon16/eye.png", "noclamp smooth" )
local mat_kick = Material( "icon16/cancel.png", "noclamp smooth" )

local mat_case = Material( "icon16/briefcase.png", "noclamp smooth" )

--[[
	COLORS
--]]

if not Theme then
	print("FALLING BACK TO DEFAULT MATS")
end

local color_btn_hover = Theme and HexToColor(Theme["primary-200"]) or Color(52,152,219,255)
local color_btn_pressed = Theme and HexToColor(Theme["primary-200"],180) or Color(52,152,219,180)

local color_red = Theme and HexToColor(Theme["error"]) or Color(255,50,50,255)

local color_green = Theme and HexToColor(Theme["success"]) or Color(38,166,91,255)
local color_red_second = Theme and HexToColor(Theme["error"]) or Color(207,0,15,255)

local color_orange = Theme and HexToColor(Theme["warning"]) or Color(245,171,53,255)

local col_gray_dark = Theme and HexToColor(Theme["bg"]) or Color(30,30,30,230)
local col_gray_light = Theme and HexToColor(Theme["bg-200"]) or Color(50,50,50,230)
local col_gray_lighter = Theme and HexToColor(Theme["bg-300"]) or Color(75,75,75,230)

local color_white = Theme and HexToColor(Theme["fg"]) or Color(255,255,255)

--[[
	FONTS
--]]
surface.CreateFont( "FONT_AdminPopup_Title", {
	font = "Roboto Lt",
	size = 15,
	weight = 500,
	antialias = true,
	extended = true,
} )

surface.CreateFont( "FONT_AdminPopup_Button", {
	font = "Roboto Lt",
	size = 14,
	weight = 500,
	antialias = true,
	extended = true,
} )

--[[
	POPUP MENU
--]]

local function adminpopup_menu( Ply, message, claimed )
	if not IsValid( Ply ) or not Ply:IsPlayer() then
		return
	end
	
	for k, v in pairs( admin_popups ) do
		if v.idiot == Ply then
			local txt = v:GetChildren()[5]
			txt:AppendText( "\n".. message )
			txt:GotoTextEnd()
			
			timer.Destroy( "AdminPopup_Timer_".. Ply:SteamID64() )
			
			if AdminPopups.Config.AutoCloseTime > 0 then
				timer.Create( "AdminPopup_Timer_".. Ply:SteamID64() , AdminPopups.Config.AutoCloseTime, 1, function()
					if IsValid( v ) then
						v:Remove()
					end
				end )
			end
			
			surface.PlaySound( "ui/hint.wav" ) 
		end
	end

	local w, h = 300, 160
	
	--[[
		Background
	--]]
	
	local frm = vgui.Create("DFrame")
	frm:SetSize( w, h )
	frm:SetPos( AdminPopups.Config.XPos, AdminPopups.Config.YPos )
	frm.idiot = Ply
	function frm:Paint( w, h )
		-- Draw frame
		draw.RoundedBox( 8, 0, 0, w, h, col_gray_light )
		-- Draw top
		draw.RoundedBoxEx( 8, 0, 0, w, 20, col_gray_dark, true, true, false, false )
		
	end
	frm.lblTitle:SetColor( color_white )
	frm.lblTitle:SetFont( "FONT_AdminPopup_Title" )
	frm.lblTitle:SetContentAlignment( 7) 
	
	if claimed and IsValid( claimed ) and claimed:IsPlayer() then
		frm:SetTitle( Ply:Nick().." - Claimed by "..claimed:Nick() )
		
		if claimed == LocalPlayer() then
			function frm:Paint( w, h )
				-- Draw frame
				draw.RoundedBox( 8, 0, 0, w, h, col_gray_light )
				-- Draw top (green/claimed)
				draw.RoundedBoxEx( 8, 0, 0, w, 20, color_green, true, true, false, false )
			end
		else
			function frm:Paint( w, h )
				-- Draw frame
				draw.RoundedBox( 8, 0, 0, w, h, col_gray_light )
				-- Draw top (red/someone else claimed)
				draw.RoundedBoxEx( 8, 0, 0, w, 20, color_red_second, true, true, false, false )
			end	
		end
	else
		frm:SetTitle( Ply:Nick() )
	end
	
	--[[
		Text
	--]]
	
	local msg = vgui.Create("RichText",frm)
	msg:SetPos( 10, 30 )
	msg:SetSize( 190, h - 35 )
	msg:SetContentAlignment( 7 )
	msg:InsertColorChange( 255, 255, 255, 255 )
	msg:SetVerticalScrollbarEnabled( false )
	function msg:PerformLayout()
		self:SetFontInternal( "FONT_AdminPopup_Title" )
	end
	msg:AppendText( message )
	
	--[[
		Buttons
	--]]
	
	local cbu = vgui.Create( "DButton", frm )
	cbu:SetPos( 215, 20 * 1 )
	cbu:SetSize( 83, 18 )
	cbu:SetText("")
	cbu:SetContentAlignment(4)
	cbu.DoClick = function()
		AdminPopups.Commands[ AdminPopups.Config.AdminMod].Goto( Ply )
	end
	cbu.Paint = function( self, w, h )
		if cbu.Depressed or cbu.m_bSelected then 
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_pressed )
		elseif cbu.Hovered then
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_hover )
		else
			draw.RoundedBox( 1, 0, 0, w, h, col_gray_lighter )
		end
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( mat_goto )
		surface.DrawTexturedRect( 5, 1, 16, 16 )
		
		draw.SimpleText( "Goto", "FONT_AdminPopup_Button", w * 0.325, h * 0.075, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end
	
	local cbu = vgui.Create( "DButton", frm )
	cbu:SetPos( 215, 20 * 2 )
	cbu:SetSize( 83, 18 )
	cbu:SetText("")
	cbu:SetContentAlignment( 4 )
	cbu.DoClick = function()
		AdminPopups.Commands[ AdminPopups.Config.AdminMod].Bring( Ply )
	end
	cbu.Paint = function( self, w, h )
		if cbu.Depressed or cbu.m_bSelected then 
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_pressed )
		elseif cbu.Hovered then
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_hover )
		else
			draw.RoundedBox( 1, 0, 0, w, h, col_gray_lighter )
		end
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( mat_bring )
		surface.DrawTexturedRect( 5, 1, 16, 16 )
		
		draw.SimpleText( "Bring", "FONT_AdminPopup_Button", w * 0.325, h * 0.075, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end		
	
	local cbu = vgui.Create( "DButton", frm )
	cbu:SetPos( 215, 20 * 3 )
	cbu:SetSize( 83, 18 )
	cbu:SetText("")
	cbu:SetContentAlignment( 4 )
	cbu.should_unfreeze = false
	cbu.DoClick = function()
		if cbu.should_unfreeze then
			AdminPopups.Commands[ AdminPopups.Config.AdminMod].Unfreeze( Ply )
			cbu.should_unfreeze = false
			return
		end
		
		AdminPopups.Commands[ AdminPopups.Config.AdminMod].Freeze( Ply )

		cbu.should_unfreeze = true
	end
	cbu.Paint = function( self, w, h )
		if cbu.Depressed or cbu.m_bSelected then 
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_pressed )
		elseif cbu.Hovered then
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_hover )
		else
			draw.RoundedBox( 1, 0, 0, w, h, col_gray_lighter )
		end
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( mat_freeze )
		surface.DrawTexturedRect( 5, 1, 16, 16 )
		
		draw.SimpleText( "Freeze", "FONT_AdminPopup_Button", w * 0.325, h * 0.075, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end
	
	local cbu = vgui.Create( "DButton", frm )
	cbu:SetPos( 215, 20 * 4 )
	cbu:SetSize( 83, 18 )
	cbu:SetText("")
	cbu:SetContentAlignment( 4 )
	cbu.DoClick = function()
		AdminPopups.Commands[ AdminPopups.Config.AdminMod].Return( Ply )
	end
	cbu.Paint = function( self, w, h )
		if cbu.Depressed or cbu.m_bSelected then 
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_pressed )
		elseif cbu.Hovered then
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_hover )
		else
			draw.RoundedBox( 1, 0, 0, w, h, col_gray_lighter )
		end
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( mat_return )
		surface.DrawTexturedRect( 5, 1, 16, 16 )
		
		draw.SimpleText( "Return", "FONT_AdminPopup_Button", w * 0.325, h * 0.075, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end
	
	local cbu = vgui.Create( "DButton", frm )
	cbu:SetPos( 215, 20 * 5 )
	cbu:SetSize( 83, 18 )
	cbu:SetText("")
	cbu:SetContentAlignment( 4 )
	cbu.DoClick = function()
		AdminPopups.Commands[ AdminPopups.Config.AdminMod].Spectate( Ply )
	end
	cbu.Paint = function( self, w, h )
		if cbu.Depressed or cbu.m_bSelected then 
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_pressed )
		elseif cbu.Hovered then
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_hover )
		else
			draw.RoundedBox( 1, 0, 0, w, h, col_gray_lighter )
		end
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( mat_spectate )
		surface.DrawTexturedRect( 5, 1, 16, 16 )
		
		draw.SimpleText( "Spectate", "FONT_AdminPopup_Button", w * 0.325, h * 0.075, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end	
	
	local cbu = vgui.Create( "DButton", frm )
	cbu:SetPos( 215, 20 * 6 )
	cbu:SetSize( 83, 18 )
	cbu:SetText("")
	cbu:SetContentAlignment( 4 )
	cbu.setconfirm = false
	cbu.DoClick = function( self )
		if self.setconfirm then
			AdminPopups.Commands[ AdminPopups.Config.AdminMod].Kick( Ply )
		else
			self.setconfirm = true
		end
	end
	cbu.Paint = function( self, w, h )
		if cbu.Depressed or cbu.m_bSelected then 
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_pressed )
		elseif cbu.Hovered then
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_hover )
		else
			draw.RoundedBox( 1, 0, 0, w, h, col_gray_lighter )
		end
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( mat_kick )
		surface.DrawTexturedRect( 5, 1, 16, 16 )
		
		if self.setconfirm then
			draw.SimpleText( "Confirm", "FONT_AdminPopup_Button", w * 0.325, h * 0.075, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "Kick", "FONT_AdminPopup_Button", w * 0.325, h * 0.075, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		end
	end	
	
	local cbu = vgui.Create( "DButton", frm )
	cbu:SetPos( 215, 20 * 7 )
	cbu:SetSize( 83, 18 )
	cbu:SetText("")
	cbu:SetContentAlignment( 4 )
	cbu.shouldclose = false
	cbu.DoClick = function()
		if not cbu.shouldclose then
			if frm.lblTitle:GetText():lower():find("claimed") then
				chat.AddText( color_red, "", color_white, "Case has already been claimed." )
				surface.PlaySound( "common/wpn_denyselect.wav" )
			else
				chat.AddText( color_green, "", color_white, "You have claimed this case." )
				
				net.Start( "AdminPopups_ClaimCase" )
					net.WriteEntity( Ply )
				net.SendToServer()
				
				cbu.shouldclose = true
			end
		else
			chat.AddText( color_red, "", color_white, "You have closed this case." )
			
			net.Start( "AdminPopups_CloseCase" )
				net.WriteEntity( Ply or nil )
			net.SendToServer()
		end
	end
	cbu.Paint = function( self, w, h )
		if cbu.Depressed or cbu.m_bSelected then 
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_pressed )
		elseif cbu.Hovered then
			draw.RoundedBox( 1, 0, 0, w, h, color_btn_hover )
		else
			draw.RoundedBox( 1, 0, 0, w, h, col_gray_lighter )
		end
		
		surface.SetDrawColor( color_white )
		surface.SetMaterial( mat_case )
		surface.DrawTexturedRect( 5, 1, 16, 16 )
		
		if self.shouldclose then
			draw.SimpleText( "Close", "FONT_AdminPopup_Button", w * 0.325, h * 0.075, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		else
			draw.SimpleText( "Claim", "FONT_AdminPopup_Button", w * 0.325, h * 0.075, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
		end
	end
	
	
	--[[
		Close Button
	--]]
	
	local bu = vgui.Create( "DButton", frm )
	bu:SetText( "✕" )
	bu:SetColor( color_white )
	bu:SetPos( w - 22, 2 )
	bu:SetSize( 16, 16 )
	function bu:Paint( w, h )
	end	
	bu.DoClick = function()
		frm:Close()
	end
	
	frm:ShowCloseButton( false )
	
	frm:SetPos( -w -30, AdminPopups.Config.YPos + ( 175 * #admin_popups ) ) -- move out of screen 
	frm:MoveTo( AdminPopups.Config.XPos, AdminPopups.Config.YPos + ( 175 * #admin_popups ), 0.2, 0,1, function() -- move back in
		surface.PlaySound( "garrysmod/balloon_pop_cute.wav" )
	end )
	
	function frm:OnRemove() -- for animations when there are several panels
		table.RemoveByValue( admin_popups, frm )
		
		for k, v in pairs( admin_popups ) do
			v:MoveTo( AdminPopups.Config.XPos, AdminPopups.Config.YPos + ( 175 *( k - 1 ) ), 0.1, 0,1, function() end )
		end
		
		if Ply and IsValid( Ply ) and Ply:IsPlayer() and timer.Exists( "AdminPopup_Timer_".. Ply:SteamID64() ) then
			timer.Destroy( "AdminPopup_Timer_".. Ply:SteamID64() )
		end
	end
	
	table.insert( admin_popups, frm )
	
	--[[
		Autoclose Timer
	--]]
	if AdminPopups.Config.AutoCloseTime > 0 then
		timer.Create( "AdminPopup_Timer_".. Ply:SteamID64(), AdminPopups.Config.AutoCloseTime, 1, function()
			if IsValid( frm ) then
				frm:Remove()
			end
		end )
	end
end

--[[
	NET MESSAGES
--]]

net.Receive( "AdminPopups_CasePopup", function( len )
	local ply = net.ReadEntity()
	local msg = net.ReadString()
	local claimed = net.ReadEntity()
	
	local dutymode = cvars.Number( "cl_adminpopups_dutymode" )
	
	if dutymode == 0 then
		adminpopup_menu( ply, msg, claimed )
	elseif dutymode == 1 then
		if table.HasValue( AdminPopups.Config.OnDutyJobs, team.GetName( LocalPlayer():Team()):lower() ) then
			adminpopup_menu( ply, msg, claimed )
		else
			chat.AddText( color_orange, "", team.GetColor( ply:Team() ), ply:Nick(), color_white, ": ", msg )
		end				
	elseif dutymode == 2 then
		if table.HasValue( AdminPopups.Config.OnDutyJobs, team.GetName( LocalPlayer():Team()):lower() ) then
			adminpopup_menu( ply, msg, claimed )
		else
			MsgC( color_orange,"", team.GetColor( ply:Team() ), ply:Nick(), color_white, ": ", msg, "\n" )
		end	
	end		
end )

net.Receive( "AdminPopups_CloseCase", function( len )
	local Ply = net.ReadEntity()
	
	if not IsValid( Ply ) or not Ply:IsPlayer() then
		return
	end
	
	for k, v in pairs( admin_popups ) do
		if v.idiot == Ply then
			v:Remove()
		end
	end
	
	if timer.Exists( "AdminPopup_Timer_".. Ply:SteamID64() ) then
		timer.Destroy( "AdminPopup_Timer_".. Ply:SteamID64() )
	end
end )

net.Receive( "AdminPopups_ClaimCase", function( len )
	local ply = net.ReadEntity()
	local Ply = net.ReadEntity()
	
	for k, v in pairs( admin_popups ) do
		if v.idiot == Ply then
			if cvars.Bool( "cl_adminpopups_closeclaimed" ) and ply ~= LocalPlayer() then
				v:Remove()
			else
				local titl = v:GetChildren()[4]
				titl:SetText( titl:GetText() .. " - Claimed by ".. ply:Nick() )
				
				if ply == LocalPlayer() then
					function v:Paint( w, h )
						-- Draw frame
						draw.RoundedBox( 8, 0, 0, w, h, col_gray_light )
						-- Draw top (green/claimed)
						draw.RoundedBoxEx( 8, 0, 0, w, 20, color_green, true, true, false, false )
					end
				else
					function v:Paint( w, h )
						-- Draw frame
						draw.RoundedBox( 8, 0, 0, w, h, col_gray_light )
						-- Draw top (green/claimed)
						draw.RoundedBoxEx( 8, 0, 0, w, 20, color_red_second, true, true, false, false )
					end
				end
				
				local bu = v:GetChildren()[11]
				bu.DoClick = function()
					if LocalPlayer() == ply then
						net.Start( "AdminPopups_CloseCase" )
							net.WriteEntity( Ply )
						net.SendToServer()
					else
						v:Close()
					end
				end	
			end
		end
	end
end )

--[[
	CONCOMMAND
	76561198227843632
--]]

concommand.Add( "adminpopups_claimtop", function( ply, cmd, args )
	if not AdminPopups.PlayerHasAccess( ply ) then
		return
	end
	
	local reports = #admin_popups
	
	if reports > 0 then
		local button = admin_popups[1]:GetChildren()[12] -- button we want is 10th child of frame #1
		button.DoClick()
	end	
end )

--[[
	CHAT PRINT TO REPORT
--]]

if AdminPopups.Config.PrintReportCommand then
	timer.Create( "AdminPopup_AdvertCommand", AdminPopups.Config.PrintReportCommandInterval, 0, function()
		for k, ply in ipairs( player.GetAll() ) do
			chat.AddText( color_green, "", color_white, "Type ".. AdminPopups.Config.ReportCommand .." followed by your message to message admins." )
			return
		end
	end )
end

--[[
	Notify chat from server
--]]
net.Receive( "AdminPopups_ChatNotify", function( length, ply )
	local hint = net.ReadString()
	
	chat.AddText( color_green, "", color_white, hint )
end )