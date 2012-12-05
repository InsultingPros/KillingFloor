class KFCheatManager extends CheatManager;

var	localized string	CheatsNotEnabled;
var	localized string	EnablingCheatsKillsPerks;
var	localized string	CheatsEnabled;

/** check if cheats are enabled, if not playing a SP game always return true */
function bool areCheatsEnabled()
{
	if ( class'ROEngine.ROLevelInfo'.static.RODebugMode() )
	{
		return true;
	}

	if ( Level.NetMode != NM_Standalone )
	{
		return true;
	}

	if ( !bCheatsEnabled )
	{
		ClientMessage(CheatsNotEnabled$": EnableCheats");
		ClientMessage(EnablingCheatsKillsPerks);
		return false;
	}

	return true;
}

exec function EnableCheats()
{
	if ( Level.NetMode == NM_Standalone )
	{
		if ( Level.GetLocalPlayerController().SteamStatsAndAchievements != none )
		{
			Level.GetLocalPlayerController().SteamStatsAndAchievements.bUsedCheats = true;
		}

		bCheatsEnabled = true;
		ClientMessage(CheatsEnabled);
	}
}

exec function ReviewJumpSpots(name TestLabel)
{
	if ( areCheatsEnabled() )
	{
		super.ReviewJumpSpots(TestLabel);
	}
}

exec function ListDynamicActors()
{
	if ( areCheatsEnabled() )
	{
		super.ListDynamicActors();
	}
}

exec function FreezeFrame(float delay)
{
	if ( areCheatsEnabled() )
	{
		super.FreezeFrame(delay);
	}
}

exec function SetFlash(float F)
{
	if ( areCheatsEnabled() )
	{
		super.SetFlash(F);
	}
}

exec function SetFogR(float F)
{
	if ( areCheatsEnabled() )
	{
		super.SetFogR(F);
	}
}

exec function SetFogG(float F)
{
	if ( areCheatsEnabled() )
	{
		super.SetFogG(F);
	}
}

exec function SetFogB(float F)
{
	if ( areCheatsEnabled() )
	{
		super.SetFogB(F);
	}
}

exec function KillViewedActor()
{
	if ( areCheatsEnabled() )
	{
		super.KillViewedActor();
	}
}

exec function ChangeSize(float F)
{
	if ( areCheatsEnabled() )
	{
		super.ChangeSize(F);
	}
}

exec function LockCamera()
{
	if ( areCheatsEnabled() )
	{
		super.LockCamera();
	}
}

exec function SetCameraDist(float F)
{
	if ( areCheatsEnabled() )
	{
		super.SetCameraDist(F);
	}
}

exec function FreeCamera(bool B)
{
	if ( areCheatsEnabled() )
	{
		super.FreeCamera(B);
	}
}

exec function CauseEvent(name EventName)
{
	if ( areCheatsEnabled() )
	{
		super.CauseEvent(EventName);
	}
}

exec function Walk()
{
	if ( areCheatsEnabled() )
	{
		super.Walk();
	}
}

exec function Avatar(string ClassName)
{
	if ( areCheatsEnabled() )
	{
		super.Avatar(ClassName);
	}
}

exec function CheatView(class<actor> aClass, optional bool bQuiet)
{
	if ( areCheatsEnabled() )
	{
		super.CheatView(aClass, bQuiet);
	}
}

exec function RememberSpot()
{
	if ( areCheatsEnabled() )
	{
		super.RememberSpot();
	}
}

exec function ViewSelf(optional bool bQuiet)
{
	if ( areCheatsEnabled() )
	{
		super.ViewSelf(bQuiet);
	}
}

exec function ViewPlayer(string S)
{
	if ( areCheatsEnabled() )
	{
		super.ViewPlayer(S);
	}
}

exec function ViewActor(name ActorName)
{
	if ( areCheatsEnabled() )
	{
		super.ViewActor(ActorName);
	}
}

exec function ViewFlag()
{
	if ( areCheatsEnabled() )
	{
		super.ViewFlag();
	}
}

exec function ViewBot()
{
	if ( areCheatsEnabled() )
	{
		super.ViewBot();
	}
}

exec function ViewTurret()
{
	if ( areCheatsEnabled() )
	{
		super.ViewTurret();
	}
}

exec function ViewClass(class<actor> aClass, optional bool bQuiet, optional bool bCheat)
{
	if ( areCheatsEnabled() )
	{
		super.ViewClass(aClass, bQuiet, bCheat);
	}
}

exec function ruler()
{
	if ( areCheatsEnabled() )
	{
		super.ruler();
	}
}

exec function LaidLaw()
{
	if(!areCheatsEnabled()) return;
	if(Pawn != None)
	{
		ClientMessage("Lay down the LAW!");
		ReportCheat("LAW");
	}
}

exec function ImRich()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

    Pawn.PlayerReplicationInfo.Score += 10000;

	ReportCheat("I'm Rich");
	ClientMessage("You won the lottery.");
}

exec function HugeGnome()
{
	local KF_GnomeSmashable Gnome;
	local vector NewScale;

	NewScale.X = 20;
	NewScale.Y = 20;
	NewScale.Z = 20;

	ForEach DynamicActors( class 'KF_GnomeSmashable', Gnome)
	{
    	Gnome.SetDrawScale3D(NewScale);
	}
}

exec function FlameUp(optional bool bMaxAmmo)
{
	local Inventory Inv;

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("KFMod.FlameThrower");
	Pawn.GiveWeapon("KFmod.Trenchgun");
	Pawn.GiveWeapon("KFMod.HuskGun");
	Pawn.GiveWeapon("KFMod.FlareRevolver");
	Pawn.GiveWeapon("KFMod.DualFlareRevolver");

    if( bMaxAmmo )
    {
    	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    	{
    		if ( Weapon(Inv)!=None )
    			Weapon(Inv).SuperMaxOutAmmo();
    	}
	}

	ReportCheat("Flame Up");
	ClientMessage("Give Flame Weapons.");
}

exec function Flare(optional bool bMaxAmmo)
{
	local Inventory Inv;

	if (!areCheatsEnabled()) return;
	if( /*(Level.Netmode!=NM_Standalone) ||*/ (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("KFMod.FlareRevolver");

    if( bMaxAmmo )
    {
    	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    	{
    		if ( Weapon(Inv)!=None )
    			Weapon(Inv).SuperMaxOutAmmo();
    	}
	}

	ReportCheat("Flare");
	ClientMessage("Give Flare Gun.");
}

exec function Flares(optional bool bMaxAmmo)
{
	local Inventory Inv;

	if (!areCheatsEnabled()) return;
	if( /*(Level.Netmode!=NM_Standalone) ||*/ (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("KFMod.FlareRevolver");
	Pawn.GiveWeapon("KFMod.DualFlareRevolver");

    if( bMaxAmmo )
    {
    	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    	{
    		if ( Weapon(Inv)!=None )
    			Weapon(Inv).SuperMaxOutAmmo();
    	}
	}

	ReportCheat("Flares");
	ClientMessage("Give Flare Guns.");
}

exec function Arsenal(optional bool bMaxAmmo)
{
	local Inventory Inv;

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

    Pawn.GiveWeapon("KFmod.M32GrenadeLauncher");
    Pawn.GiveWeapon("KFmod.M79GrenadeLauncher");
    Pawn.GiveWeapon("KFmod.PipeBombExplosive");
    Pawn.GiveWeapon("KFmod.MP7MMedicGun");
    Pawn.GiveWeapon("KFmod.MP5MMedicGun");
    Pawn.GiveWeapon("KFmod.M7A3MMedicGun");
    Pawn.GiveWeapon("KFmod.AK47AssaultRifle");
    Pawn.GiveWeapon("KFmod.MKb42AssaultRifle");
    Pawn.GiveWeapon("KFmod.SCARMK17AssaultRifle");
    Pawn.GiveWeapon("KFmod.M14EBRBattleRifle");
    Pawn.GiveWeapon("KFmod.AA12AutoShotgun");
    Pawn.GiveWeapon("KFmod.KSGShotgun");
    Pawn.GiveWeapon("KFmod.BenelliShotgun");
	Pawn.GiveWeapon("KFmod.Bullpup");
	Pawn.GiveWeapon("KFmod.Winchester");
	Pawn.GiveWeapon("KFmod.Crossbow");
	Pawn.GiveWeapon("KFmod.M99SniperRifle");
	Pawn.GiveWeapon("KFmod.DualDeagle");
	Pawn.GiveWeapon("KFmod.Deagle");
	Pawn.GiveWeapon("KFmod.Dualies");
	Pawn.GiveWeapon("KFmod.Single");
	Pawn.GiveWeapon("KFmod.Magnum44Pistol");
	Pawn.GiveWeapon("KFmod.Dual44Magnum");
	Pawn.GiveWeapon("KFmod.MK23Pistol");
	Pawn.GiveWeapon("KFmod.DualMK23Pistol");
	Pawn.GiveWeapon("KFmod.Axe");
	Pawn.GiveWeapon("KFmod.Machete");
	Pawn.GiveWeapon("KFmod.Knife");
	Pawn.GiveWeapon("KFmod.Chainsaw");
//	Pawn.GiveWeapon("KFmod.PlaceMineWeapon");
//	Pawn.GiveWeapon("KFmod.PlaceCalWeapon");
	Pawn.GiveWeapon("KFmod.LAW");
//	Pawn.GiveWeapon("KFmod.Frag");
//	Pawn.GiveWeapon("KFmod.StunNade");
	Pawn.GiveWeapon("KFmod.Shotgun");
	Pawn.GiveWeapon("KFmod.Trenchgun");
	Pawn.GiveWeapon("KFmod.BoomStick");
	Pawn.GiveWeapon("KFMod.FlameThrower");
	Pawn.GiveWeapon("KFMod.Katana");
	Pawn.GiveWeapon("KFMod.MAC10MP");
	Pawn.GiveWeapon("KFMod.ClaymoreSword");
	Pawn.GiveWeapon("KFMod.M4AssaultRifle");
	Pawn.GiveWeapon("KFMod.M4203AssaultRifle");
	Pawn.GiveWeapon("KFMod.HuskGun");
	Pawn.GiveWeapon("KFmod.FNFAL_ACOG_AssaultRifle");
	Pawn.GiveWeapon("KFmod.NailGun");
	Pawn.GiveWeapon("KFMod.FlareRevolver");
	Pawn.GiveWeapon("KFMod.ThompsonSMG");
	Pawn.GiveWeapon("KFmod.Scythe");
	Pawn.GiveWeapon("KFmod.Crossbuzzsaw");

    if( bMaxAmmo )
    {
    	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    	{
    		if ( Weapon(Inv)!=None )
    			Weapon(Inv).SuperMaxOutAmmo();
    	}
	}

	ReportCheat("Arsenal");
	ClientMessage("All KF Weapons.");
}

exec function RifleMe()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

    Pawn.GiveWeapon("KFmod.AK47AssaultRifle");
    Pawn.GiveWeapon("KFmod.MKb42AssaultRifle");
    Pawn.GiveWeapon("KFmod.SCARMK17AssaultRifle");
    Pawn.GiveWeapon("KFmod.M14EBRBattleRifle");
	Pawn.GiveWeapon("KFmod.Bullpup");
	Pawn.GiveWeapon("KFmod.Winchester");
	Pawn.GiveWeapon("KFmod.Crossbow");
	Pawn.GiveWeapon("KFmod.M4AssaultRifle");
	Pawn.GiveWeapon("KFmod.FNFAL_ACOG_AssaultRifle");

	ReportCheat("RifleMe");
	ClientMessage("Rifle Weapons.");
}

exec function Sniper()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

    Pawn.GiveWeapon("KFmod.M14EBRBattleRifle");
	Pawn.GiveWeapon("KFmod.Winchester");
	Pawn.GiveWeapon("KFmod.Crossbow");
	Pawn.GiveWeapon("KFmod.M99SniperRifle");

	ReportCheat("Sniper");
	ClientMessage("Sniper Weapons.");
}

exec function AssaultMe()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

    Pawn.GiveWeapon("KFmod.AK47AssaultRifle");
    Pawn.GiveWeapon("KFmod.MKb42AssaultRifle");
    Pawn.GiveWeapon("KFmod.SCARMK17AssaultRifle");
	Pawn.GiveWeapon("KFmod.Bullpup");
	Pawn.GiveWeapon("KFmod.M4AssaultRifle");
	Pawn.GiveWeapon("KFmod.FNFAL_ACOG_AssaultRifle");
	Pawn.GiveWeapon("KFmod.M7A3MMedicGun");

	ReportCheat("RifleMe");
	ClientMessage("Rifle Weapons.");
}

exec function SMG()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

    Pawn.GiveWeapon("KFmod.MP7MMedicGun");
    Pawn.GiveWeapon("KFmod.MP5MMedicGun");
    Pawn.GiveWeapon("KFMod.MAC10MP");
    Pawn.GiveWeapon("KFmod.ThompsonSMG");

	ReportCheat("SMG");
	ClientMessage("SMG Weapons.");
}


exec function Meds()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

    Pawn.GiveWeapon("KFmod.MP7MMedicGun");
    Pawn.GiveWeapon("KFmod.MP5MMedicGun");
    Pawn.GiveWeapon("KFmod.M7A3MMedicGun");

	ReportCheat("Meds");
	ClientMessage("Medic Weapons.");
}

exec function Pistols()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("KFmod.Deagle");
	Pawn.GiveWeapon("KFmod.Dualies");
	Pawn.GiveWeapon("KFmod.DualDeagle");
	Pawn.GiveWeapon("KFmod.Single");
	Pawn.GiveWeapon("KFmod.Magnum44Pistol");
	Pawn.GiveWeapon("KFmod.Dual44Magnum");
	Pawn.GiveWeapon("KFmod.MK23Pistol");
	Pawn.GiveWeapon("KFmod.DualMK23Pistol");

	ReportCheat("Pistols");
	ClientMessage("Pistols.");
}


exec function Shotty()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("KFmod.Shotgun");
	Pawn.GiveWeapon("KFmod.Trenchgun");
	Pawn.GiveWeapon("KFmod.BoomStick");
	Pawn.GiveWeapon("KFmod.AA12AutoShotgun");
	Pawn.GiveWeapon("KFmod.BenelliShotgun");
	Pawn.GiveWeapon("KFmod.KSGShotgun");

	ReportCheat("Shotty");
	ClientMessage("Shotguns.");
}

exec function MeleeMe(optional bool bMaxAmmo)
{
	local Inventory Inv;

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("KFmod.Single");
	Pawn.GiveWeapon("KFmod.Axe");
	Pawn.GiveWeapon("KFmod.Machete");
	Pawn.GiveWeapon("KFmod.Knife");
	Pawn.GiveWeapon("KFmod.Chainsaw");
	Pawn.GiveWeapon("KFMod.Katana");
	Pawn.GiveWeapon("KFMod.ClaymoreSword");
	Pawn.GiveWeapon("KFmod.Crossbuzzsaw");
	Pawn.GiveWeapon("KFmod.Scythe");

    if( bMaxAmmo )
    {
    	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    	{
    		if ( Weapon(Inv)!=None )
    			Weapon(Inv).SuperMaxOutAmmo();
    	}
	}

	ReportCheat("MeleeMe");
	ClientMessage("All KF Melee sWeapons.");
}

exec function Bombs(optional bool bMaxAmmo)
{
	local Inventory Inv;

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("KFmod.PipeBombExplosive");
	Pawn.GiveWeapon("KFmod.M79GrenadeLauncher");
	Pawn.GiveWeapon("KFmod.M32GrenadeLauncher");
	Pawn.GiveWeapon("KFmod.M4203AssaultRifle");

    if( bMaxAmmo )
    {
    	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
    	{
    		if ( Weapon(Inv)!=None )
    			Weapon(Inv).SuperMaxOutAmmo();
    	}
	}

	ReportCheat("Bombs");
	ClientMessage("You threw down tha bomb.");
}

exec function Nails()
{
	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("KFmod.NailGun");
}

exec function IJC()
{
	if (!areCheatsEnabled()) return;
	if( /*(Level.Netmode!=NM_Standalone) ||*/ (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveWeapon("KFmod.Scythe");
	Pawn.GiveWeapon("KFmod.Crossbuzzsaw");
	Pawn.GiveWeapon("KFmod.ThompsonSMG");
}

exec function Backup()
{
	local KFSoldierFriendly Soldier;

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Soldier = Spawn(class'KFmod.KFSoldierFriendly');
	Soldier.PlayerReplicationInfo.Team.TeamIndex = PlayerReplicationInfo.Team.TeamIndex;

	ReportCheat("Backup");
	ClientMessage("Reinforcements are here!");
}

exec function Horde()
{
	local float RandomZombieNum;
	local String ZombieName;

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	RandomZombieNum = rand(7);

	if (RandomZombieNum == 0)
	 ZombieName = "Clot";
	else
	if (RandomZombieNum == 1)
	 ZombieName = "Crawler";
	else
	if (RandomZombieNum == 2)
	 ZombieName = "Stalker";
	else
	if (RandomZombieNum == 3)
	 ZombieName = "Bloat";
	else
	if (RandomZombieNum == 4)
	 ZombieName = "Gorefast";
	else
	if (RandomZombieNum == 5)
	 ZombieName = "Scrake";
	else
	if (RandomZombieNum == 6)
	 ZombieName = "FleshPound";


   if (ZombieName != "")
	ConsoleCommand("Summon KFChar.Zombie"$ZombieName);

	ReportCheat("Horde");
	ClientMessage("You've got company!");
}

exec function MopUp()
{
	local KFMonster LevelMonster;
	local int LevelMonsterTotal;

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

   forEach AllActors(class 'KFMonster',LevelMonster)
   {
	LevelMonsterTotal++;
	LevelMonster.KilledBy(Pawn);
   }

	ReportCheat("MopUp");
	ClientMessage("The number of zombies in this map was : "$LevelMonsterTotal);
}

exec function PatRage()
{
	local ZombieBossBase LevelMonster;

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

   forEach AllActors(class'ZombieBossBase',LevelMonster)
   {
        LevelMonster.GotoState('RadialAttack');
   }

	ReportCheat("PatRage");
	ClientMessage("Forcing the Patriarch to do his radial attack");
}

exec function ArmorUp()
{
	local KFHumanPawn P;

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

    forEach AllActors(class'KFHumanPawn',P)
    {
        P.ShieldStrength = 100;
    }

	ReportCheat("ArmorUp");
	ClientMessage("Everyone has full armor");
}

exec function Heal()
{

	if (!areCheatsEnabled()) return;
	if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
		return;

	Pawn.GiveHealth(100,Pawn.HealthMax);

	ReportCheat("Heal");
	ClientMessage("Much better.");
}


/*
	exec function TimeIsATeacher()
{

  //  if (!areCheatsEnabled()) return;
  //  if( (Level.Netmode!=NM_Standalone) || (Pawn == None) || (Vehicle(Pawn) != None) )
  //	  return;

	KFPlayerReplicationInfo(PlayerReplicationInfo).ExperienceLevel += 1.0 ;

	ReportCheat("TimeIsATeacher");
	ClientMessage("+ 1 Experience level");

}
*/

exec function ViewZombie()
{
	local actor first;
	local bool bFound;
	local Controller C;

	if (!areCheatsEnabled()) return;

	bViewBot = true;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('KFMonsterController') && (C.Pawn != None) )
		{
			if ( bFound || (first == None) )
			{
				first = C;
				if ( bFound )
					break;
			}
			if ( C == RealViewTarget )
				bFound = true;
		}
	}

	if ( first != None )
	{
		SetViewTarget(first);
		bBehindView = true;
		ViewTarget.BecomeViewTarget();
		FixFOV();
	}
	else
		ViewSelf(true);
}

defaultproperties
{
     CheatsNotEnabled="Cheats are NOT enabled, to enable cheats type"
     EnablingCheatsKillsPerks="Enabling cheats prevents you from obtaining Perks and Achievements"
     CheatsEnabled="Cheats enabled, you are no longer able to obtain Perks and Achievements until the map changes"
}