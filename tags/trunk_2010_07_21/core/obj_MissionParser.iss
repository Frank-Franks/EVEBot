/*
	Mission Data Parser
		Parses HTML Mission information to extract the needed details
		
	- CyberTech
*/

objectdef obj_MissionParser
{
	variable string SVN_REVISION = "$Rev$"
	variable int Version
	variable string LogPrefix

	variable string MissionDetails
	variable string MissionExpiresHex
	variable string MissionName
	variable string Caption
	
	variable int left = 0
	variable int right = 0
	
	method Initialize(string Details)
	{
		LogPrefix:Set["${This.ObjectName}"]
	}
	
	member:int TypeID()
	{
		variable int retval = 0
		
		left:Set[${This.MissionDetails.Escape.Find["<img src=\\\"typeicon:"]}]
		if ${left} > 0
		{
			;UI:UpdateConsole["${LogPrefix}: DEBUG: Found \"typeicon\" at ${left}.", LOG_DEBUG]
			left:Inc[20]
			;UI:UpdateConsole["${LogPrefix}: DEBUG: typeicon substring = ${This.MissionDetails.Escape.Mid[${left},16]}", LOG_DEBUG]
			right:Set[${This.MissionDetails.Escape.Mid[${left},16].Find["\" "]}]
			if ${right} > 0
			{
				right:Dec[2]
				;UI:UpdateConsole["${LogPrefix}: DEBUG: left = ${left}", LOG_DEBUG]
				;UI:UpdateConsole["${LogPrefix}: DEBUG: right = ${right}", LOG_DEBUG]
				;UI:UpdateConsole["${LogPrefix}: DEBUG: string = ${This.MissionDetails.Escape.Mid[${left},${right}]}", LOG_DEBUG]
				retval:Set[${This.MissionDetails.Escape.Mid[${left},${right}]}]
				UI:UpdateConsole["${LogPrefix}: DEBUG: typeID = ${retval}", LOG_DEBUG]
			}
			else
			{
				UI:UpdateConsole["${LogPrefix}: ERROR: Did not find end of \"typeicon\"!", LOG_CRITICAL]
			}
		}
		else
		{
			UI:UpdateConsole["${LogPrefix}: WARNING: Did not find \"typeicon\".  No cargo???"]
		}
		return ${retval}
	}
	
	member:int FactionID()
	{
		variable int retval = 0

		left:Set[${This.MissionDetails.Escape.Find["<img src=\\\"corplogo:"]}]
		if ${left} > 0
		{
			;UI:UpdateConsole["${LogPrefix}: DEBUG: Found \"corplogo\" at ${left}.", LOG_DEBUG]
			left:Inc[23]
			;UI:UpdateConsole["${LogPrefix}: DEBUG: Found \"corplogo\" at ${left}.", LOG_DEBUG]
			;UI:UpdateConsole["${LogPrefix}: DEBUG: corplogo substring = ${This.MissionDetails.Escape.Mid[${left},16]}", LOG_DEBUG]
			right:Set[${This.MissionDetails.Escape.Mid[${left},16].Find["\" "]}]
			if ${right} > 0
			{
				right:Dec[2]
				;UI:UpdateConsole["${LogPrefix}: DEBUG: left = ${left}", LOG_DEBUG]
				;UI:UpdateConsole["${LogPrefix}: DEBUG: right = ${right}", LOG_DEBUG]
				;UI:UpdateConsole["${LogPrefix}: DEBUG: string = ${This.MissionDetails.Escape.Mid[${left},${right}]}", LOG_DEBUG]
				retval:Set[${This.MissionDetails.Escape.Mid[${left},${right}]}]
				UI:UpdateConsole["${LogPrefix}: DEBUG: factionID = ${retval}", LOG_DEBUG]
			}
			else
			{
				UI:UpdateConsole["${LogPrefix}: ERROR: Did not find end of \"corplogo\"!", LOG_CRITICAL]
			}
		}
		else
		{
			UI:UpdateConsole["${LogPrefix}: WARNING: Did not find \"corplogo\".  Rogue Drones???"]
		}
		return ${retval}
	}
	
	member:float Volume()
	{
		variable int retval = 0

		right:Set[${This.MissionDetails.Escape.Find["msup3"]}]
		if ${right} > 0
		{
			;UI:UpdateConsole["${LogPrefix}: DEBUG: Found \"msup3\" at ${right}.", LOG_DEBUG]
			right:Dec
			left:Set[${This.MissionDetails.Escape.Mid[${Math.Calc[${right}-16]},16].Find[" ("]}]
			if ${left} > 0
			{
				left:Set[${Math.Calc[${right}-16+${left}+1]}]
				right:Set[${Math.Calc[${right}-${left}]}]
				;UI:UpdateConsole["${LogPrefix}: DEBUG: left = ${left}", LOG_DEBUG]
				;UI:UpdateConsole["${LogPrefix}: DEBUG: right = ${right}", LOG_DEBUG]
				;UI:UpdateConsole["${LogPrefix}: DEBUG: string = ${This.MissionDetails.Escape.Mid[${left},${right}]}", LOG_DEBUG]
				retval:Set[${This.MissionDetails.Escape.Mid[${left},${right}]}]
				UI:UpdateConsole["${LogPrefix}: DEBUG: Volume = ${retval}", LOG_DEBUG]
			}
			else
			{
				UI:UpdateConsole["${LogPrefix}: ERROR: Did not find number before \"msup3\"!", LOG_CRITICAL]
			}
		}
		else
		{
			UI:UpdateConsole["${LogPrefix}: WARNING: Did not find \"msup3\".  No cargo???"]
		}

		return ${retval}
	}
	
	member:bool IsLowSec()
	{
		left:Set[${This.MissionDetails.Escape.Find["(Low Sec Warning!)"]}]
		right:Set[${This.MissionDetails.Escape.Find["(The route generated by current autopilot settings contains low security systems!)"]}]
		if ${left} > 0 || ${right} > 0
		{
			;UI:UpdateConsole["${LogPrefix}: DEBUG: left = ${left}", LOG_DEBUG]
			;UI:UpdateConsole["${LogPrefix}: DEBUG: right = ${right}", LOG_DEBUG]
			UI:UpdateConsole["${LogPrefix}: DEBUG: IsLowSec = TRUE", LOG_DEBUG]
			return TRUE
		}
		UI:UpdateConsole["${LogPrefix}: DEBUG: IsLowSec = FALSE", LOG_DEBUG]
		return FALSE
	}

	method ParseCaption()
	{
		This.Caption:Set["${amIterator.Value.Name.Escape}"]
		left:Set[${This.Caption.Escape.Find["u2013"]}]

		if ${left} > 0
		{
			UI:UpdateConsole["${LogPrefix}: WARNING: Mission name contains u2013"]
			UI:UpdateConsole["${LogPrefix}: DEBUG: amIterator.Value.Name.Escape = ${amIterator.Value.Name.Escape}"]

			This.Caption:Set["${This.Caption.Escape.Right[${Math.Calc[${This.Caption.Escape.Length} - ${left} - 5]}]}"]

			UI:UpdateConsole["${LogPrefix}: DEBUG: This.Caption.Escape = ${This.Caption.Escape}"]
		}
	}
	
	method SaveCacheFile()
	{
		variable file DetailsFile
		DetailsFile:SetFilename["./config/logs/${This.MissionExpiresHex} ${This.MissionName.Replace[",",""]}.html"]

		if ${DetailsFile:Open(exists)}
		{
			DetailsFile:Write["${This.MissionDetails.Escape}"]
			DetailsFile:Close
		}
	}
}