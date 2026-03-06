for k, v in pairs( AdminPopups.Config.OnDutyJobs ) do
	AdminPopups.Config.OnDutyJobs[k] = v:lower()
end

function AdminPopups.PlayerHasAccess( ply )
	if ulx then
		return ply:query( "ulx seeasay" )	
	end
	
	if sam then
		return ply:HasPermission( "see_admin_chat" )
	end
	
	if serverguard then
		return serverguard.player:HasPermission( ply, "Manage Reports" )
	end
	
	if sAdmin then
		return sAdmin.hasPermission( ply, "is_staff" )
	end

	if Lyn then
		return ply:HasPermission("see_admin_chat")
	end
	
	if Admin_System_Global then
		return ply:AdminStatusCheck()
	end
	
	return ply:IsAdmin()
end