class KFModelSelect extends UT2k4ModelSelect;

// Overridden to get rid of the Race combo
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super(LockedFloatingWindow).Initcomponent(MyController, MyOwner);

	sb_Main.SetPosition(0.040000,0.075000,0.680742,0.555859);
	sb_Main.RightPadding = 0.5;
	sb_Main.ManageComponent(CharList);

	class'xUtil'.static.GetPlayerList(PlayerList);
	RefreshCharacterList("DUP");

	// Spawn spinning character actor
	if ( SpinnyDude == None )
		SpinnyDude = PlayerOwner().spawn(class'XInterface.SpinnyWeap');

	SpinnyDude.SetDrawType(DT_Mesh);
	SpinnyDude.SetDrawScale(0.9);
	SpinnyDude.SpinRate = 0;
}

function RefreshCharacterList(string ExcludedChars, optional string Race)
{
    local int i, j;
    local array<string> Excluded;

    // Prevent list from calling OnChange events
    CharList.List.bNotify = False;
    CharList.Clear();

    Split(ExcludedChars, ";", Excluded);
    for ( i = 0; i < PlayerList.Length; i++ )
    {
		// Check that this character is selectable
		if ( PlayerList[i].Menu != "" )
		{
			for (j = 0; j < Excluded.Length; j++)
				if ( InStr(";" $ Playerlist[i].Menu $ ";", ";" $ Excluded[j] $ ";") != -1 )
					break;

			if ( j < Excluded.Length )
				continue;
		}

        if ( IsUnLocked(PlayerList[i]) )
        {
			CharList.List.Add(Playerlist[i].Portrait, i, 0);
        }
        else if ( Playerlist[i].LockedPortrait == none )
        {
			CharList.List.Add(Playerlist[i].Portrait, i, 1);
        }
        else
        {
        	CharList.List.Add(Playerlist[i].LockedPortrait, i, 1);
        }
    }

    CharList.List.LockedMat = LockedImage;
    CharList.List.bNotify = True;
}

function HandleParameters( string Who, string Team )
{
	local int i;

	for ( i = 0; i < PlayerList.Length; i++)
	{
		if ( PlayerList[i].DefaultName ~= Who && IsUnlocked(PlayerList[i]) )
		{
			CharList.List.SetIndex(CharList.List.FindItem(i));
		}
	}

	UpdateSpinnyDude();
}

// Overridden to set Idle Animation
function UpdateSpinnyDude()
{
	local int idx;
	local xUtil.PlayerRecord Rec;
	local Mesh PlayerMesh;
	local Material BodySkin, HeadSkin;
	local string BodySkinName, HeadSkinName, TeamSuffix;

	idx = CharList.List.GetItem();
	if ( idx < 0 || idx >= Playerlist.Length )
		return;

	Rec = PlayerList[idx];

	if (Rec.Race ~= "Juggernaut" || Rec.DefaultName~="Axon" || Rec.DefaultName~="Cyclops" || Rec.DefaultName ~="Virus" )
		SpinnyDudeOffset=vect(250.0,1.00,-14.00);
	else
	    SpinnyDudeOffset=vect(250.0,1.00,-24.00);

	PlayerMesh = Mesh(DynamicLoadObject(Rec.MeshName, class'Mesh'));
	if(PlayerMesh == None)
	{
		Log("Could not load mesh: "$Rec.MeshName$" For player: "$Rec.DefaultName);
		return;
	}

	// Get the body skin
	BodySkinName = Rec.BodySkinName;

	// Get the head skin
	HeadSkinName = Rec.FaceSkinName;
	if ( Rec.TeamFace )
		HeadSkinName $= TeamSuffix;

	BodySkin = Material(DynamicLoadObject(BodySkinName, class'Material'));
	if(BodySkin == None)
	{
		Log("Could not load body material: "$Rec.BodySkinName$" For player: "$Rec.DefaultName);
		return;
	}

	HeadSkin = Material(DynamicLoadObject(HeadSkinName, class'Material'));
	if(HeadSkin == None)
	{
		Log("Could not load head material: "$HeadSkinName$" For player: "$Rec.DefaultName);
		return;
	}

	SpinnyDude.LinkMesh(PlayerMesh);
	SpinnyDude.Skins[0] = BodySkin;
	SpinnyDude.Skins[1] = HeadSkin;
	SpinnyDude.LoopAnim('Profile_idle');
}

// Overridden to stop log spam
function PopulateRaces()
{
}

// Overridden to hook up Steam Checks
function bool IsUnlocked(xUtil.PlayerRecord Test)
{
	// If character has no menu filter, just return true
	if ( PlayerOwner() == none )
		return super.IsUnlocked(Test);

	return PlayerOwner().CharacterAvailable(Test.DefaultName);
}

function HandleLockedCharacterClicked(int NewIndex)
{
	if ( PlayerOwner() != none && PlayerOwner().PurchaseCharacter(Playerlist[NewIndex].DefaultName) )
	{
		Controller.CloseMenu(true);
	}
}

defaultproperties
{
     Begin Object Class=KFGUIVertImageListBox Name=vil_CharList
         CellStyle=CELL_FixedCount
         NoVisibleRows=3
         NoVisibleCols=4
         OnCreateComponent=vil_CharList.InternalOnCreateComponent
         WinTop=0.185119
         WinLeft=0.102888
         WinWidth=0.403407
         WinHeight=0.658125
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFModelSelect.ListChange
     End Object
     CharList=KFGUIVertImageListBox'KFGui.KFModelSelect.vil_CharList'

     co_Race=None

}
