AdminPopups = AdminPopups or {}
AdminPopups.Config = AdminPopups.Config or {}

-- Debug Mode
AdminPopups.Config.Debug = true -- Debug mode allows admins to send popups too

-- Select Admin Mod
-- Available admin mods: ulx, sam, xadmin, xadmin2, sadmin, fadmin, serverguard, lyn
AdminPopups.Config.AdminMod = "lyn"

-- Select Prefix
AdminPopups.Config.ReportCommand = "!r" -- Prefix to create admin popups. DO NOT CHANGE TO @ or //

-- Position
AdminPopups.Config.XPos = 20 -- X cordinate of the popup. Can be changed in case it blocks something important
AdminPopups.Config.YPos = 20 -- Y cordinate of the popup. Can be changed in case it blocks something important

-- General Configuration
AdminPopups.Config.AutoCloseTime = 300 -- the case will auto close after this amount of seconds (SET TO 0 TO DISABLE) (300 = 5 minutes)
AdminPopups.Config.KickMessage = "Kicked by an administrator."
AdminPopups.Config.CaseUpdateOnly = false -- Once a case is claimed, only the claimer sees further updates (false if all should see updates on case (recommended))

AdminPopups.Config.PrintReportCommand = true -- Should the report command be printed to the players in the chat?
AdminPopups.Config.PrintReportCommandInterval = 600 -- How often should we print the command if enabled?

AdminPopups.Config.PrintReportConfirmation = true -- Should players receive a message when their report has been sent?
AdminPopups.Config.PrintReportText = "Your report has been sent to administrators. An admin will respond as soon as possible." -- The text to print to the player

AdminPopups.Config.TicketMinimumCharacters = 10 -- How many characters must a ticket minimum be?
AdminPopups.Config.TicketMinimumNotificiation = "Your ticket must be at least ".. AdminPopups.Config.TicketMinimumCharacters .." characters." --- Reply to the player if the char limit is not met.

AdminPopups.Config.CreateTicketCooldown = 10 -- How many seconds cooldown between making tickets?

AdminPopups.Config.NotifyClaimedTicket = true -- Should the repoter have a chat print when an admin claims their ticket?
AdminPopups.Config.AdminClaimedTicketNotify = "has claimed your ticket." -- Notify the reporter when an admin claims their ticket. It will say the admins name first.

AdminPopups.Config.OnDutyJobs = { -- These are the 'on duty' jobs. Clients can restrict notifications to these jobs only
	"admin on duty",
	"mod on duty",
	"moderator on duty"
}

if CLIENT then
	-- Clients are able to configure these ingame with console, however you can set the default here. Only change the first number after the convar name
	CreateClientConVar( "cl_adminpopups_closeclaimed", 0, true, false ) -- This will autoclose cases claimed by others.
	CreateClientConVar( "cl_adminpopups_dutymode", 0, true, false ) -- see below
	-- 0 = Always show popups
	-- 1 = Show chat messages while on NOT duty
	-- 2 = Show console messages while NOT on duty
	-- 3 = Disable admin messages
end