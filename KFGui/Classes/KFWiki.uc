class KFWiki extends Settings_Tabs;

var ()array<String> WikiObjectDescription,WikiObjectName,WikiObjectClassName;

var rotator ItemRotOffset;

var automated KFGUISectionBackground i_BG, i_BG2, i_BG3;
var automated GUIImage i_Shadow, i_Bk;
var automated GUIListBox    lb_items;
var automated GUIScrollTextBox  lb_Desc,lb_statBox,lb_Healthbox;

var KFSpinnyWeap          SpinnyWeap; // MUST be set to null when you leave the window
var() vector                SpinnyWeapOffset;
var rotator SpinnyWeaponRot;

var editconst noexport float SavedPitch;

var float fScale;

var localized string HiddenText, LoadingText;

var config bool bDebugPriority, bDebugScale, bDebugWeapon;

var () rotator infoDrawRotation;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	lb_items.List.bMultiSelect=False;
	i_BG2.ManageComponent(lb_items);
	if ( bDebugWeapon )
		OnKeyEvent = CoolOnKeyEvent;
}

function IntializeWeaponList()
{
    local UT2K4GenericMessageBox Page;

    // Display the "loading" page
    if ( Controller.OpenMenu("GUI2K4.UT2K4GenericMessageBox", "", LoadingText) )
    {
        Page = UT2K4GenericMessageBox(Controller.ActivePage);
        Page.RemoveComponent(Page.b_Ok);
        Page.RemoveComponent(Page.l_Text);
        Page.l_Text2.FontScale = FNS_Large;
        Page.l_Text2.WinHeight = 1.0;
        Page.l_Text2.WinTop = 0.0;
        Page.l_Text2.bBoundToParent = True;
        Page.l_Text2.bScaleToParent = True;
        Page.l_Text2.VertAlign = TXTA_Center;
        Page.l_Text2.TextAlign = TXTA_Center;
        Page.bRenderWorld = False;
        Page.OnRendered = ReallyInitializeWeaponList;
    }
}

function ReallyInitializeWeaponList( Canvas C )
{
    local int i;
    local rotator AdjustedRot;

    if ( Controller.ActivePage.Tag != 55 )
    {
        Controller.ActivePage.Tag = 55;
        return;
    }


    // Disable the combo list's OnChange()
    lb_items.List.bNotify = False;

    lb_items.List.Clear();

   // lb_items.List.Add("ENEMIES",,,true);

     lb_items.List.Add("ENEMIES",,,true);
    for(i=0; i<WikiObjectName.length; i++)
    {
        lb_items.List.Add(WikiObjectName[i], DynamicLoadObject(WikiObjectClassName[i],class'class'), WikiObjectDescription[i]);
      if (i==8)
       lb_items.List.Add("WEAPONRY",,,true);
      if (i==22)
       lb_items.List.Add("EQUIPMENT",,,true);

    }



    // Spawn spinny weapon actor
    if ( SpinnyWeap == None )
        SpinnyWeap = PlayerOwner().spawn(class'KFGUI.KFSpinnyWeap');

    AdjustedRot = PlayerOwner().Rotation;
    AdjustedRot.pitch = -AdjustedRot.pitch;
    AdjustedRot.yaw = -AdjustedRot.yaw;

    SpinnyWeap.SetRotation(AdjustedRot);

    SpinnyWeaponRot = SpinnyWeap.Rotation;

    SpinnyWeap.SetStaticMesh(None);

    // Start with first item on list selected
    lb_items.List.SetIndex(0);
    WeaponListInitialized();

    lb_items.List.bNotify = True;

    if ( Controller.ActivePage != PageOwner )
        Controller.CloseMenu(true);

    FocusFirst(none);
}



function ResetClicked()
{
    local int i;
    local bool bTemp;

   Super.ResetClicked();


    bTemp = Controller.bCurMenuInitialized;
    Controller.bCurMenuInitialized = False;

    for (i = 0; i < Controls.Length; i++)
        Controls[i].LoadINI();

   // lb_items.List.SortList();
    Controller.bCurMenuInitialized = bTemp;

    WeaponListInitialized();
}



function ShowPanel(bool bShow)
{
	local rotator R;

	Super.ShowPanel(bShow);
	if (bShow)
	{
		if ( bInit )
		{
			IntializeWeaponList();
			bInit = False;
		}
		if ( SpinnyWeap != None )
			R = PlayerOwner().Rotation;
	}
}

function InternalOnChange(GUIComponent Sender)
{
	Super.InternalOnChange(Sender);
	if(Sender == lb_items)
		UpdateCurrentItem(); // Selected a different weapon
}

function WeaponListInitialized()
{
    UpdateCurrentItem();
}


function InternalDraw(Canvas canvas)
{
    local vector CamPos, X, Y, Z, WX, WY, WZ;
    local rotator CamRot;

    canvas.GetCameraLocation(CamPos, CamRot);
    GetAxes(CamRot, X, Y, Z);

    if(SpinnyWeap.DrawType == DT_Mesh)
    {
        GetAxes(SpinnyWeap.Rotation, WX, WY, WZ);
        SpinnyWeap.SetLocation(CamPos + (SpinnyWeapOffset.X * X) + (SpinnyWeapOffset.Y * Y) + (SpinnyWeapOffset.Z * Z) + (30 * WX));
    }
    else
    {
        SpinnyWeap.SetLocation(CamPos + (SpinnyWeapOffset.X * X) + (SpinnyWeapOffset.Y * Y) + (SpinnyWeapOffset.Z * Z));
    }

   // SpinnyWeap.SetRotation(Dummy);
    canvas.DrawActorClipped(SpinnyWeap, false, i_BG.ClientBounds[0], i_BG.ClientBounds[1], i_BG.ClientBounds[2] - i_BG.ClientBounds[0], (i_BG.ClientBounds[3] - i_BG.ClientBounds[1]), true, 65.0);    //2


}

function bool RaceCapturedMouseMove(float deltaX, float deltaY)
{
    local rotator r;
    r = SpinnyWeap.Rotation;
    r.Yaw -= (150 * DeltaX);
    r.Pitch -= (0.5* r.Yaw);
    SpinnyWeap.SetRotation(r);
    return true;
}



function UpdateCurrentItem()
{
    local class<KFMonster> CurrentEnemy;
    local class<KFWeapon> CurrentWeapon;
    local class<KFWeaponPickup> CurrentWeaponPickup;
    local Rotator AdjustedRot;


    if(SpinnyWeap == None)
        return;


    i_BG.Caption = lb_items.List.Get();
    lb_Desc.SetContent( lb_items.List.GetExtra() );


// Weapons
if(lb_items.List.index < 9)
{

    CurrentEnemy = class<KFMonster>(DynamicLoadObject(WikiObjectClassName[lb_items.List.Index], class'Class'));
    //log(CurrentEnemy);
    //log(CurrentEnemy.default.HealthMax);

    SpinnyWeap.LinkMesh(CurrentEnemy.default.Mesh);
    SpinnyWeap.SetDrawType(CurrentEnemy.default.DrawType);
    SpinnyWeap.SetDrawScale(CurrentEnemy.default.DrawScale * 1.5);
    SpinnyWeap.SetDrawScale3D(CurrentEnemy.default.DrawScale3D);

    SpinnyWeap.SetRotation(SpinnyWeaponRot);

    lb_StatBox.SetContent(" Damage Potential - "$CurrentEnemy.default.MeleeDamage);
    lb_Healthbox.SetContent(" Hitpoints - "$CurrentEnemy.default.HealthMax);


    if (CurrentEnemy == class 'KFChar.ZombieBloat')//
      SpinnyWeap.PlayAnim('ZombieBarf',1.0);
    else
    if (CurrentEnemy == class 'KFChar.ZombieSiren')
      SpinnyWeap.PlayAnim('Siren_Scream',1.0);
    else
     SpinnyWeap.PlayAnim(CurrentEnemy.default.MeleeAnims[rand(3)],1.0);


    // SpinnyWeap.LoopAnim(CurrentEnemy.default.IdleRestAnim);

  //  SpinnyWeap.SetStaticMesh

}
else
 if (lb_items.List.index > 9)
 {
    CurrentWeapon = class<KFWeapon>(DynamicLoadObject(WikiObjectClassName[lb_items.List.Index - 1], class'Class'));
    //CurrentWeaponFire = class<KFFire>(DynamicLoadObject(string(CurrentWeapon.GetFireMode(0), class'Class'));
    CurrentWeaponPickup = class<KFWeaponPickup>(DynamicLoadObject(string(CurrentWeapon.default.PickupClass), class'Class'));

    //lb_StatBox.SetContent(" Damage Potential - "$CurrentWeaponFire.default.DamageMin$"-"$(CurrentWeaponFire.default.DamageMin + CurrentWeaponFire.default.DamageMax));
    lb_Healthbox.SetContent("");

    SpinnyWeap.LinkMesh(none);
    SpinnyWeap.SetDrawType(CurrentWeaponPickup.default.DrawType);
    SpinnyWeap.SetDrawScale(CurrentWeaponPickup.default.DrawScale * 2.5);
    SpinnyWeap.SetDrawScale3D(CurrentWeaponPickup.default.DrawScale3D);
    SpinnyWeap.SetStaticMesh(CurrentWeaponPickup.default.StaticMesh);

    AdjustedRot = SpinnyWeap.Rotation;
    if (AdjustedRot.yaw == SpinnyWeaponRot.yaw)
     AdjustedRot.Yaw = -SpinnyWeaponRot.Yaw;
    SpinnyWeap.SetRotation(AdjustedRot);
 }
}



event Opened(GUIComponent Sender)
{

    Super.Opened(Sender);


    if ( SpinnyWeap != None )
    {
       SpinnyWeap.bHidden = false;
    }



}

event Closed(GUIComponent Sender, bool bCancelled)
{
    Super.Closed(Sender, bCancelled);

    if ( SpinnyWeap != None )
        SpinnyWeap.bHidden = true;
}

event Free()
{
    if ( SpinnyWeap != None )
    {
        SpinnyWeap.Destroy();
        SpinnyWeap = None;
    }

    Super.Free();
}

function bool CoolOnKeyEvent(out byte Key, out byte State, float delta)
{
    local Interactions.EInputKey iKey;
    local vector V;

    iKey = EInputKey(Key);
    V = SpinnyWeap.DrawScale3D;

    if ( state == 1 )
    {
        switch (iKey)
        {
        case IK_E:
            SpinnyWeapOffset.X = SpinnyWeapOffset.X - 1;
            LogSpinnyWeap();
            return true;
        case IK_C:
            SpinnyWeapOffset.X = SpinnyWeapOffset.X + 1;
            LogSpinnyWeap();
            return true;
        case IK_W:
            SpinnyWeapOffset.Z = SpinnyWeapOffset.Z + 1;
            LogSpinnyWeap();
            return true;
        case IK_A:
            SpinnyWeapOffset.Y = SpinnyWeapOffset.Y - 1;
            LogSpinnyWeap();
            return true;
        case IK_S:
            SpinnyWeapOffset.Z = SpinnyWeapOffset.Z - 1;
            LogSpinnyWeap();
            return true;
        case IK_D:
            SpinnyWeapOffset.Y = SpinnyWeapOffset.Y + 1;
            LogSpinnyWeap();
            return true;
        case IK_NumPad8:
            V.Z = V.Z + 1;
            SpinnyWeap.SetDrawScale3D( V );
            LogWeapScale();
            return True;
        case IK_NumPad4:
            V.Y = V.Y - 1;
            SpinnyWeap.SetDrawScale3D(V);
            LogWeapScale();
            return True;
        case IK_NumPad6:
            V.Y = V.Y + 1;
            SpinnyWeap.SetDrawScale3D(V);
            LogWeapScale();
            return True;
        case IK_NumPad2:
            V.Z = V.Z - 1;
            SpinnyWeap.SetDrawScale3D(V);
            LogWeapScale();
            return True;
        case IK_NumPad7:
            V.X = V.X - 1;
            SpinnyWeap.SetDrawScale3D(V);
            LogWeapScale();
            return True;
        case IK_NumPad9:
            V.X = V.X + 1;
            SpinnyWeap.SetDrawScale3D(V);
            LogWeapScale();
            return True;
        }
    }


    return false;

}

function LogSpinnyWeap()
{
    log("Weapon Position X:"$SpinnyWeapOffset.X@"Y:"$SpinnyWeapOffset.Y@"Z:"$SpinnyWeapOffset.Z);
}

function LogWeapScale()
{
    log("DrawScale3D X:"$SpinnyWeap.DrawScale3D.X@"Y:"$SpinnyWeap.DrawScale3D.Y@"Z:"$SpinnyWeap.DrawScale3D.Z);
}

defaultproperties
{
     WikiObjectDescription(1)="When Horzine started its second wave of human cloning and genetic engineering programs, the intention was to create a fully grown male that would respond to imperatives and could recognize Horzine staff as its masters. Orders were to be given to these subjects through a neural implant which released controlled doses of serotonin upon successful completion of a mandate. The subjects quickly showed signs of abberant behaviour, however, including aggressive self mutilation. The first batch of clones was spawned from the DNA of Horzine CEO Kevin Clamely's deceased son. The failure of these specimens put a brief hold on the project while new avenues were pursued."
     WikiObjectDescription(2)="A scary girl..!"
     WikiObjectDescription(3)="Fatty Fat"
     WikiObjectDescription(4)="A fast moving, leaping critter.  Dangerous in mobs."
     WikiObjectDescription(5)="Run!!"
     WikiObjectDescription(6)="BUZZZZZ"
     WikiObjectDescription(7)="Siiiing"
     WikiObjectDescription(8)="CRUSH!"
     WikiObjectDescription(9)="A combat knife. sharp."
     WikiObjectDescription(10)="a machete"
     WikiObjectDescription(11)="an axe!"
     WikiObjectDescription(12)="a fallback weapon"
     WikiObjectDescription(13)="two of the above."
     WikiObjectDescription(14)="a bigass pistol"
     WikiObjectDescription(15)="an automatic rifle"
     WikiObjectDescription(16)="an old school rifle"
     WikiObjectDescription(17)="a boomstick"
     WikiObjectDescription(18)="a bigger boomstick"
     WikiObjectDescription(19)="a ranged hunting weapon"
     WikiObjectDescription(20)="flaaaame on"
     WikiObjectDescription(21)="Light anti tank weapons"
     WikiObjectDescription(22)="It blows up"
     WikiObjectDescription(23)="It heals!"
     WikiObjectDescription(24)="it welds!"
     WikiObjectDescription(25)="it protects!"
     WikiObjectDescription(26)="it heals lots!!"
     WikiObjectName(1)="Clot"
     WikiObjectName(2)="Stalker"
     WikiObjectName(3)="Bloat"
     WikiObjectName(4)="Crawler"
     WikiObjectName(5)="Gorefast"
     WikiObjectName(6)="Scrake"
     WikiObjectName(7)="Siren"
     WikiObjectName(8)="Fleshpound"
     WikiObjectName(9)="Combat Knife"
     WikiObjectName(10)="Machete"
     WikiObjectName(11)="Fire Axe"
     WikiObjectName(12)="9mm tactical"
     WikiObjectName(13)="Dual 9mms"
     WikiObjectName(14)="Handcannon"
     WikiObjectName(15)="Bullpup"
     WikiObjectName(16)="Lever Action Rifle"
     WikiObjectName(17)="Combat Shotgun"
     WikiObjectName(18)="Hunting Shotgun"
     WikiObjectName(19)="Crossbow"
     WikiObjectName(20)="Flamethrower"
     WikiObjectName(21)="L.A.W"
     WikiObjectName(22)="Fragmentation Grenade"
     WikiObjectName(23)="Medical Syringe"
     WikiObjectName(24)="Welding Tool"
     WikiObjectName(25)="Kevlar Vest"
     WikiObjectName(26)="First Aid Kit"
     WikiObjectClassName(1)="KFChar.ZombieClot"
     WikiObjectClassName(2)="KFChar.ZombieStalker"
     WikiObjectClassName(3)="KFChar.ZombieBloat"
     WikiObjectClassName(4)="KFChar.ZombieCrawler"
     WikiObjectClassName(5)="KFChar.ZombieGorefast"
     WikiObjectClassName(6)="KFChar.ZombieScrake"
     WikiObjectClassName(7)="KFChar.ZombieSiren"
     WikiObjectClassName(8)="KFChar.ZombieFleshpound"
     WikiObjectClassName(9)="KFMod.Knife"
     WikiObjectClassName(10)="KFMod.Machete"
     WikiObjectClassName(11)="KFMod.Axe"
     WikiObjectClassName(12)="KFMod.Single"
     WikiObjectClassName(13)="KFMod.Dualies"
     WikiObjectClassName(14)="KFMod.Deagle"
     WikiObjectClassName(15)="KFMod.Bullpup"
     WikiObjectClassName(16)="KFMod.Winchester"
     WikiObjectClassName(17)="KFMod.Shotgun"
     WikiObjectClassName(18)="KFMod.Boomstick"
     WikiObjectClassName(19)="KFMod.Crossbow"
     WikiObjectClassName(20)="KFMod.Flamethrower"
     WikiObjectClassName(21)="KFMod.LAW"
     WikiObjectClassName(22)="KFMod.Frag"
     WikiObjectClassName(23)="KFMod.Syringe"
     WikiObjectClassName(24)="KFMod.Welder"
     WikiObjectClassName(25)="KFMod.Vest"
     WikiObjectClassName(26)="KFMod.FirstAidKit"
     Begin Object Class=KFGUISectionBackground Name=WeaponBK
         AltCaptionOffset(0)=-500
         AltCaptionOffset(3)=120
         bAltCaption=True
         HeaderBase=None
         Caption="Weapon"
         FontScale=FNS_Large
         WinTop=0.007663
         WinLeft=0.001253
         WinWidth=0.594473
         WinHeight=0.978337
         bCaptureMouse=True
         OnPreDraw=WeaponBK.InternalPreDraw
         OnCapturedMouseMove=KFWiki.RaceCapturedMouseMove
     End Object
     i_BG=KFGUISectionBackground'KFGui.KFWiki.WeaponBK'

     Begin Object Class=KFGUISectionBackground Name=WeaponPriorityBK
         bFillClient=True
         Caption="Information"
         LeftPadding=0.000000
         RightPadding=0.000000
         TopPadding=0.000000
         BottomPadding=0.000000
         FontScale=FNS_Medium
         WinTop=0.013973
         WinLeft=0.615537
         WinWidth=0.380157
         WinHeight=0.968776
         OnPreDraw=WeaponPriorityBK.InternalPreDraw
     End Object
     i_BG2=KFGUISectionBackground'KFGui.KFWiki.WeaponPriorityBK'

     Begin Object Class=GUIListBox Name=WeaponPrefWeapList
         bVisibleWhenEmpty=True
         OnCreateComponent=WeaponPrefWeapList.InternalOnCreateComponent
         Hint="Select order for weapons"
         WinTop=0.733868
         WinLeft=0.068546
         WinWidth=0.338338
         WinHeight=0.221055
         RenderWeight=0.510000
         TabOrder=1
         OnChange=KFWiki.InternalOnChange
     End Object
     lb_items=GUIListBox'KFGui.KFWiki.WeaponPrefWeapList'

     Begin Object Class=GUIScrollTextBox Name=WeaponDescription
         CharDelay=0.001500
         EOLDelay=0.250000
         bVisibleWhenEmpty=True
         OnCreateComponent=WeaponDescription.InternalOnCreateComponent
         FontScale=FNS_Small
         WinTop=0.137477
         WinLeft=0.014425
         WinWidth=0.206476
         WinHeight=0.586749
         RenderWeight=0.510000
         TabOrder=0
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     lb_Desc=GUIScrollTextBox'KFGui.KFWiki.WeaponDescription'

     Begin Object Class=GUIScrollTextBox Name=ItemStatsBox
         bNoTeletype=True
         CharDelay=0.001500
         EOLDelay=0.250000
         bVisibleWhenEmpty=True
         OnCreateComponent=ItemStatsBox.InternalOnCreateComponent
         FontScale=FNS_Small
         StyleName="MidGameButton"
         WinTop=0.957376
         WinLeft=0.000830
         WinWidth=0.413595
         WinHeight=0.029286
         RenderWeight=0.510000
         TabOrder=0
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     lb_statBox=GUIScrollTextBox'KFGui.KFWiki.ItemStatsBox'

     Begin Object Class=GUIScrollTextBox Name=HealthBox
         bNoTeletype=True
         CharDelay=0.001500
         EOLDelay=0.250000
         bVisibleWhenEmpty=True
         OnCreateComponent=HealthBox.InternalOnCreateComponent
         FontScale=FNS_Small
         StyleName="MidGameButton"
         WinTop=0.925000
         WinLeft=0.000830
         WinWidth=0.413595
         WinHeight=0.029286
         RenderWeight=0.510000
         TabOrder=0
         bAcceptsInput=False
         bNeverFocus=True
     End Object
     lb_Healthbox=GUIScrollTextBox'KFGui.KFWiki.HealthBox'

     SpinnyWeapOffset=(X=200.000000,Y=1.500000,Z=-10.000000)
     HiddenText="Hidden"
     LoadingText="...Loading D.R.F Database..."
     PanelCaption="Weapons"
     WinTop=0.150000
     WinHeight=0.740000
     OnRendered=KFWiki.InternalDraw
}
