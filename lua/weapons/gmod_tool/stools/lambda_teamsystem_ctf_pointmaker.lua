AddCSLuaFile()

if ( CLIENT ) then

	TOOL.Information = {
		{ name = "left" },
		{ name = "right" }
	}

	language.Add("tool.lambda_teamsystem_ctf_pointmaker", "Lambda CTF Point Maker")
	language.Add("tool.lambda_teamsystem_ctf_pointmaker.name", "Lambda CTF Point Maker")
	language.Add("tool.lambda_teamsystem_ctf_pointmaker.desc", "Creates a CTF flag")
	language.Add("tool.lambda_teamsystem_ctf_pointmaker.left", "Fire onto a surface to create flag")
	language.Add("tool.lambda_teamsystem_ctf_pointmaker.right", "Fire near a flag to remove it")

end

TOOL.Tab = "Lambda Player"
TOOL.Category = "Tools"
TOOL.Name = "#tool.lambda_teamsystem_ctf_pointmaker"
TOOL.ClientConVar = {
	[ "teamname" ] = "",
	[ "customname" ] = "",
	[ "iscapturezone" ] = "1",
	[ "custommodel" ] = "",
}

function TOOL:LeftClick( tr )
	if ( SERVER ) then
		local flag = ents.Create( "lambda_ctf_flag" )
		flag:SetPos( tr.HitPos )

		local teamName = self:GetClientInfo( "teamname" )
		flag.TeamName = teamName
		
		flag.CustomName = self:GetClientInfo( "customname" )
		flag.IsCaptureZone = ( self:GetClientNumber( "iscapturezone", 1 ) == 1 )

		local mdl = self:GetClientInfo( "custommodel" )
		flag.CustomModel = ( mdl != "" and mdl )

		flag:Spawn()
		flag:SetPos( tr.HitPos - tr.HitNormal * flag:OBBMins().z )

		local addname = ( teamName != "" and teamName or flag:GetCreationID() )
		undo.Create("Lambda Flag " .. addname )
			undo.SetPlayer( self:GetOwner() )
			undo.AddEntity( flag )
		undo.Finish("Lambda Flag " .. addname )

		self:GetOwner():AddCleanup( "sents", flag )
    end

    return true
end

function TOOL:RightClick(tr)
	if ( SERVER ) then
		for _, ent in ipairs( ents.FindInSphere( tr.HitPos, 5 ) ) do
			if IsValid( ent ) then 
				if ent.IsLambdaFlag then 
					ent:Remove() 
				elseif ent.IsLambdaCaptureFlag then
					ent.FlagOwner:Remove()
				end
			end
		end
	end

	return true
end

function TOOL.BuildCPanel( panel )
    local combo = panel:ComboBox( "Team", "lambda_teamsystem_ctf_pointmaker_teamname" )
    for k, v in pairs( LambdaTeams.TeamOptions ) do combo:AddChoice( k, v ) end
	panel:ControlHelp( "The team that this flag should belong to after spawning." )

	local refresh = vgui.Create( "DButton" )
	panel:AddItem( refresh )
	refresh:SetText( "Refresh Team List" )

	function refresh:DoClick()
		combo:Clear()
		local teamData = LAMBDAFS:ReadFile( "lambdaplayers/teamlist.json", "json" )
    	teamData[ "None" ] = ""
	    for k, _ in pairs( teamData ) do combo:AddChoice( k, k ) end
	end

	panel:TextEntry( "Custom Name", "lambda_teamsystem_ctf_pointmaker_customname" )
	panel:ControlHelp( "A custom name for this flag. Leave empty to use default ones." )

	panel:TextEntry( "Custom Model", "lambda_teamsystem_ctf_pointmaker_custommodel" )
	panel:ControlHelp( "A custom model for this flag. Leave empty to use default one." )

	panel:CheckBox( "Is Capture Zone", "lambda_teamsystem_ctf_pointmaker_iscapturezone" )
	panel:ControlHelp( "If this point should act as a capture zone." )
end