class KFGUIComboBox extends GUIComboBox;

var String SoldierNameToAdd;
var() array<xUtil.PlayerRecord> PlayerList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.Initcomponent(MyController, MyOwner);

    List              = MyListBox.List;
    List.OnChange     = ItemChanged;
    List.bHotTrack    = true;
    List.bHotTrackSound = false;
    List.OnClickSound = CS_Click;
    List.OnClick      = InternalListClick;
    List.OnInvalidate = InternalOnInvalidate;
    List.TextAlign    = TXTA_Left;
    MyListBox.Hide();

    Edit.OnChange           = TextChanged;
    Edit.OnMousePressed     = InternalEditPressed;
    Edit.INIOption          = INIOption;
    Edit.INIDefault         = INIDefault;
    Edit.bReadOnly          = bReadOnly;

    List.OnDeActivate = InternalListDeActivate;

    MyShowListBtn.OnClick = ShowListBox;
    MyShowListBtn.FocusInstead = List;
    SetHint(Hint);
    
    // Add KF bot choices
  /*
    List.Add("Soldier");
    List.Add("Soldier_Kara");
    List.Add("Soldier_Powers");
    List.Add("Soldier_Davin");
    List.Add("Soldier_Quick");
    */

    class'xUtil'.static.GetPlayerList(PlayerList);
    
     for(i=0; i<PlayerList.Length; i++)
    {
     if (Playerlist[i].DefaultName == "Soldier_Black"  ||
                Playerlist[i].DefaultName == "Soldier_Urban"  ||
                Playerlist[i].DefaultName == "Soldier"        ||
                Playerlist[i].DefaultName == "Soldier_Lewis"  ||
                Playerlist[i].DefaultName == "Soldier_Davin"  ||
                Playerlist[i].DefaultName == "Hazmat"  ||
                Playerlist[i].DefaultName == "Soldier_Kara"   ||
                Playerlist[i].DefaultName == "Soldier_Powers" ||
                Playerlist[i].DefaultName == "Stalker" ||
                Playerlist[i].DefaultName == "Soldier_Masterson")
            {
             List.Add(PlayerList[i].DefaultName);
            } 


    }

   // SoldierNameToAdd = List.Elements[0].Item;
  //  SetSoldierToAdd();

}

function SetText(string NewText, optional bool bListItemsOnly)
{
    local int i;

    i = List.FindIndex(NewText);
    if ( (bReadOnly || bListItemsOnly) && i < 0 )
        return;

    Edit.SetText(NewText);
    TextStr = Edit.TextStr;
    
   if(TextStr != "")
    SoldierNameToAdd = TextStr;

    SetSoldierToAdd();

}

function SetSoldierToAdd()
{
      if(KFGameReplicationInfo(PlayerOwner().GameReplicationInfo) != none)
       KFPlayerController(PlayerOwner()).ServerSetTempBotName(SoldierNameToAdd);
       Log("adding temp bot name...   :"$SoldierNameToAdd);
       Log("Was the Temp set on the server successfully? "$KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).TempBotName == SoldierNameToAdd);
}

defaultproperties
{
}
