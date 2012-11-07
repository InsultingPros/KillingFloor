//=============================================================================
// KF Use Trigger. Now with bigger messages, and Refire delays for human users.
// This shit's used for Doors in Killing Floor.
// By: Alex
//=============================================================================
class KFUseTrigger extends UseTrigger;

var array<KFDoorMover> DoorOwners;

var()   int     ReFireDelay;
var     int     LastAttempt;

var     float   WeldStrength,LastMessageTimer;
var()   float   MaxWeldStrength;

var()   float   CombatSealReduction; // How much do we weaken the effectiveness of the Players' welder by when the door is being attacked?

var()   bool    bAlwaysShowMessage; // Show a text message to nearby players even when the doors are sealed /  the trigger is not useable
var()   string  LockedMessage, UnLockedMessage, WeldedShutMessage, WeldedShutMessage2;
var()   sound   LockedSound, UnLockedSound ;  // The SFX for trying to open a locked door, and unlocking it.
var()   bool    bDirectionalOpen;
var     vector  InitRotation;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if( bDirectionalOpen )
		InitRotation = vector(Rotation);
}
function AddDoor( KFDoorMover Other )
{
	local int i;

	i = DoorOwners.Length;
	DoorOwners.Length = i+1;
	DoorOwners[i] = Other;
}

function bool SelfTriggered()
{
	return true;
}
/*
function HideDoorWeldingStatus()
{
	HUDKillingFloor(PlayerController(DoorUser.Controller).myHUD).HideDoorIntegrityMeter();
}

function ShowDoorWeldingStatus(PlayerController PC, KFDoorMover)
{
	local int i;

	For( i = 0; i < DoorOwners.Length; i++ )
	{
		if ( !bUntouch && !DoorOwners[i].bHidden && (DoorOwners[i].bClosed || DoorOwners[i].bSealed) )
		{
			if ( PlayerController(DoorUser.Controller) != None )
			{

			}
		}
		else
		{
			if ( PlayerController(DoorUser.Controller) != None )
			{
			     HUDKillingFloor(PlayerController(DoorUser.Controller).myHUD).ShowDoorIntegrity(false, 0, 0);
			}
		}
	}
}
*/
function UsedBy(Pawn user)
{
	local int i;
	local Inventory inv;
	local byte OpenKeyNum;

	if( (Level.TimeSeconds-LastAttempt)<RefireDelay || User.IsA('KFMonster') )
		Return;

	if( bDirectionalOpen )
	{
		if( (Normal(user.Location-Location) dot InitRotation)>0 )
			OpenKeyNum = 1;
		else OpenKeyNum = 2;
	}

	For( i = 0; i < DoorOwners.Length; i++ )
	{
		if ( !DoorOwners[i].bSealed && !DoorOwners[i].bHidden && !DoorOwners[i].bKeyLocked )
		{
			if( OpenKeyNum == 0 )
				DoorOwners[i].Trigger(Self,User);
			else DoorOwners[i].OpenDoorToKey(User,OpenKeyNum);

			LastAttempt = Level.TimeSeconds;
		}

		if ( DoorOwners[i].bSealed && !DoorOwners[i].bHidden && DoorOwners[i].bClosed)
		{
			if ( PlayerController(user.controller) != none )
			{
				PlayerController(user.controller).ReceiveLocalizedMessage(class'KFMod.WaitingMessage', 4);
			}

			LastAttempt = Level.TimeSeconds;
		}

	   	if( DoorOwners[i].bKeyLocked && !DoorOwners[i].bSealed && !DoorOwners[i].bHidden && DoorOwners[i].bClosed )
		{
			for( inv=user.Inventory; inv!=None; inv=inv.Inventory)
			{
				if( KFKeyInventory(inv)!=None && inv.tag==DoorOwners[i].tag )
				{
					if( OpenKeyNum==0 )
						DoorOwners[i].Trigger(Self,User);
					else DoorOwners[i].OpenDoorToKey(User,OpenKeyNum);
					if( PlayerController(user.controller)!=None )
						PlayerController(user.controller).ClientMessage(UnLockedMessage, 'CriticalEvent');
					PlaySound(UnLockedSound,,255,,100);
					DoorOwners[i].bKeyLocked = false;
					LastAttempt = Level.TimeSeconds;
					KFKeyInventory(inv).UnLock();
				}
			}
		}
	}
}

// Modded to account for...Zombies, and the Sealing (removal) of the Door Movers.
function Touch( Actor Other )
{
	local int i;
	local byte OpenKeyNum;

	if( Pawn(Other)==None || Pawn(Other).Health <= 0 )
		Return;

	if( bDirectionalOpen )
	{
		if( (Normal(Other.Location-Location) dot InitRotation)>0 )
			OpenKeyNum = 1;
		else OpenKeyNum = 2;
	}

	For( i = 0; i < DoorOwners.Length; i++ )
	{
		if( KFMonster(Other)!=none || KFInvasionBot(Pawn(Other).Controller) != none )
		{
			if( !DoorOwners[i].bKeyLocked && !DoorOwners[i].bSealed && !DoorOwners[i].bHidden && DoorOwners[i].KeyNum==0 )
			{
				if( OpenKeyNum==0 )
					DoorOwners[i].Trigger(Self,Pawn(Other));
				else DoorOwners[i].OpenDoorToKey(Pawn(Other),OpenKeyNum);
			}
		}
		else if ( !DoorOwners[i].bSealed && !DoorOwners[i].bHidden )
		{
			// Send a string message to the toucher.
			if(PlayerController(Pawn(Other).Controller)!=none)
			{
				if( LastMessageTimer<Level.TimeSeconds && Message!="" )
				{
					LastMessageTimer = Level.TimeSeconds+0.6;
					if ( InStr(Message, "USE") != -1 )
					{
						PlayerController(Pawn(Other).Controller).ReceiveLocalizedMessage(class'KFMod.WaitingMessage', 6);
					}
					else
					{
						PlayerController(Pawn(Other).Controller).ClientMessage(Message, 'CriticalEvent');
					}

					if ( KFPlayerController(Pawn(Other).Controller) != none )
					{
						KFPlayerController(Pawn(Other).Controller).CheckForHint(50);
					}
				}
			}
			else if ( DoorOwners[i].bClosed && Pawn(Other).Controller!=None )
				UsedBy(Pawn(Other));
		}
		else if( !DoorOwners[i].bHidden && bAlwaysShowMessage && LastMessageTimer<Level.TimeSeconds
		 && PlayerController(Pawn(Other).Controller)!=none && Message!="" )
		{
			LastMessageTimer = Level.TimeSeconds+0.6;
			PlayerController(Pawn(Other).Controller).ClientMessage(Message, 'CriticalEvent');
		}
	}
}

// The weld functions here are needed so that all doors for this
// trigger stay in sync
function AddWeld( float ExtraWeld, bool bZombieAttacking, Pawn WelderInst )
{
	local int i;
	local KFPlayerController PC;

	if ( bZombieAttacking )
	{
		ExtraWeld *= CombatSealReduction;
	}

	if ( (WeldStrength + ExtraWeld) > MaxWeldStrength )
	{
		ExtraWeld = MaxWeldStrength-WeldStrength;
	}

	if ( ExtraWeld == 0 )
	{
		return;
	}

	if ( WelderInst != none )
	{
		PC = KFPlayerController(WelderInst.Controller);
		if ( PC != none && KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements) != none )
		{
			KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements).AddWeldingPoints(ExtraWeld);
		}
	}

	WeldStrength +=ExtraWeld;

	For( i=0; i<DoorOwners.Length; i++ )
		DoorOwners[i].SetWeldStrength(WeldStrength);
}

function UnWeld(float DeWeldage,bool bZombieAttacking, Pawn WelderInst)
{
	local int i;
	local KFPlayerController PC;

	if (bZombieAttacking)
		DeWeldage *= CombatSealReduction;


//	if( DeWeldage<WeldStrength )
	//	DeWeldage = WeldStrength;
	if( DeWeldage==0 )
		Return;

	if ( WelderInst != none )
	{
		PC = KFPlayerController(WelderInst.Controller);
		if ( PC != none && KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements) != none )
		{
			KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements).AddWeldingPoints(DeWeldage * 0.5);
		}
	}

	WeldStrength -=DeWeldage;


	For( i=0; i<DoorOwners.Length; i++ )
		DoorOwners[i].SetWeldStrength(WeldStrength);
}

//TODO: store last hit parameters, and time,
//      then check in unweld if the unweld should become a damageweld
//      using the stored parameters
function DamageWeld(float WeldDamage,pawn instigatedBy, Vector hitlocation,Vector momentum, class<DamageType> damageType)
{
	local int i;

	if( WeldDamage==0 )
		Return;
	WeldStrength-=WeldDamage;

	if( WeldStrength<=0 )
	{
		WeldStrength = 0;
		For( i=0; i<DoorOwners.Length; i++ )
		{
			DoorOwners[i].SetWeldStrength(0);
			DoorOwners[i].GoBang(instigatedBy,hitlocation,momentum,damageType);
		}
	}
	else
	{
		For( i=0; i<DoorOwners.Length; i++ )
			DoorOwners[i].SetWeldStrength(WeldStrength);
	}
}

defaultproperties
{
     ReFireDelay=2
     MaxWeldStrength=400.000000
     CombatSealReduction=0.500000
     LockedMessage="This door is locked. Looks like it needs a key.."
     UnLockedMessage="Your Key unlocked the door."
     LockedSound=Sound'PatchSounds.LockedDoorSound'
     UnLockedSound=Sound'PatchSounds.DoorUnlockSound'
     bDirectional=True
}
