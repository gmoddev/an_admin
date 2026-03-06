local MODULE = GAS.Logging:MODULE()

MODULE.Category = "Admin Popups"
MODULE.Name     = "Cases"
MODULE.Colour   = Color(255, 90, 0)

GAS.Logging:AddPhrase("adminpopups_report_created", "%s created a report: %s")

GAS.Logging:AddPhrase("adminpopups_case_claimed", "%s claimed %s's report")

GAS.Logging:AddPhrase("adminpopups_case_closed", "%s closed %s's report")

GAS.Logging:AddPhrase("adminpopups_case_autoclosed", "Report auto-closed because %s (%s) disconnected")

MODULE:Setup(function()

    -- Player created a report
    MODULE:Hook("PlayerSay", "AdminPopups_Report", function(ply, text)
        if not AdminPopups or not AdminPopups.Config then return end

        local cmd = AdminPopups.Config.ReportCommand
        if not cmd then return end

        if string.StartWith(string.lower(text), cmd) then
            local msg = string.Trim(string.Replace(text, cmd, ""))

            MODULE:LogPhrase(
                "adminpopups_report_created",
                GAS.Logging:FormatPlayer(ply),
                GAS.Logging:Highlight(msg)
            )
        end
    end)

    -- Case claimed
    MODULE:Hook("AdminPopups_Hook_ClaimCase", "AdminPopups_Claim", function(admin, reporter)

        MODULE:LogPhrase(
            "adminpopups_case_claimed",
            GAS.Logging:FormatPlayer(admin),
            GAS.Logging:FormatPlayer(reporter)
        )

    end)

    -- Case closed (detect when claim cleared)
    MODULE:Hook("AdminPopups_CloseCase", "AdminPopups_Close", function(admin, reporter)

        MODULE:LogPhrase(
            "adminpopups_case_closed",
            GAS.Logging:FormatPlayer(admin),
            GAS.Logging:FormatPlayer(reporter)
        )

    end)

end)

GAS.Logging:AddModule(MODULE)