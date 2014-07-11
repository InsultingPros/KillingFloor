/*
	--------------------------------------------------------------
	KFHumanPawn_Story
	--------------------------------------------------------------

	Custom Pawn class for use in Killing Floor 'Story' maps.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KFHumanPawn_Story extends KFHumanPawn ;

/* true if this pawn has had its currently held gear stored at a checkpoint */
var bool    bSavedLoadout;

/* Pawn is currently holding a KF_StoryInventoryItem actor */
var bool	bHasStoryItem;

replication
{
	reliable if ( bNetDirty && (Role == Role_Authority) )
	 	bHasStoryItem;
}
simulated function Fire( optional float F )
{
    local Controller C;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
        C.ReceiveWarning(self,0,vector(Rotation));
	}

    Super.Fire(F);
}

function bool DoJump( bool bUpdating )
{
    local float JumpModifier;

    JumpModifier = GetJumpZModifier();

    /* Also ramp up the allowed fallspeed so larger jumps dont instantly kill us */
    MaxFallSpeed = default.MaxFallSpeed * JumpModifier;
    JumpZ = default.JumpZ * JumpModifier ;



    return Super.DoJump(bUpdating);
}

simulated function  float GetJumpZModifier()
{
    local inventory I;
    local float Modifier;
    local KF_StoryInventoryItem Storyinv;

    Modifier = 1.f;

	for ( I = Inventory; I != none; I = I.Inventory )
	{
	   StoryInv = KF_StoryInventoryItem(I);
	   if(StoryInv != none)
	   {
	       Modifier *= StoryInv.JumpZModifier;
	   }
	}

	return Modifier;
}

function SetHasStoryItem( bool bHasItem )
{
 	bHasStoryItem = bHasItem;
}

simulated event ModifyVelocity(float DeltaTime, vector OldVelocity)
{
    local inventory I;
    local KF_StoryInventoryItem Storyinv;

    Super.ModifyVelocity(DeltaTime,OldVelocity);

	for ( I = Inventory; I != none; I = I.Inventory )
	{
        StoryInv = KF_StoryInventoryItem(I);
        if(StoryInv != none && StoryInv.bUseForcedGroundSpeed)
        {
            GroundSpeed = StoryInv.ForcedGroundSpeed ;
        }
	}
}

simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
 	super.TakeDamage( Damage, InstigatedBY, Hitlocation, Momentum, damageType, HitIndex );

	// HandleStoryAchievements is only used for Steamland. In fact, it screws up KFO-Transit!
 	if( class'KFGameType'.static.GetCurrentMapName(Level) ~= "KFO-Steamland" )
 	{
		HandleStoryAchievements();
	}
}

function HandleStoryAchievements()
{
	local KFGameReplicationInfo KFGRI;

	if ( bHasStoryItem )
	{
        KFGRI = KFGameReplicationInfo( Level.GRI );
        if( KFGRI != none )
        {
            KFGRI.bObjectiveAchievementFailed = true;
        }
	}
}

function bool AddInventory( inventory NewItem )
{
	if( !super.AddInventory(NewItem) )
		return false;

    if( KF_StoryInventoryItem(NewItem) != none )
	{
		CurrentWeight += KF_StoryInventoryItem(NewItem).Weight;
	}

	return true;
}

// Remove Item from this pawn's inventory, if it exists.
function DeleteInventory( inventory Item )
{
	local Inventory I;
	local bool bFoundItem;

	if ( Role != ROLE_Authority )
	{
		return;
	}

	for ( I = Inventory; I != none; I = I.Inventory )
	{
		if ( I == Item )
		{
			bFoundItem = true;
		}
	}

	if ( bFoundItem )
	{
        if ( KF_StoryInventoryItem(Item) != none )
		{
			CurrentWeight -= KF_StoryInventoryItem(Item).Weight;
		}
	}

	super.DeleteInventory(Item);
}

/* Returns true if this pawn is able to hold a weapon of the supplied type */
simulated function bool AllowHoldWeapon(Weapon InWeapon)
{
    local bool Result;
    local Inventory Inv;
    local KF_StoryInventoryItem StoryInv;

    Result = true;

    /* Query our inventory items to see if they restrict any weaponry we're holding */
    for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
        StoryInv = KF_StoryInventoryItem(Inv);
        if(StoryInv != none)
        {
            if(!StoryInv.AllowHoldWeapon(InWeapon))
            {
                Result = false;
                break;
            }
        }
    }

//    log("*********************************************");
//   log("Allow Hold Weapon of Type : "@InWeapon@" - "@Result);
//    log("*********************************************");

    if(!Result)
    {
        PlayerController(Controller).ReceiveLocalizedMessage(Class'KFMainMessages',5,,,InWeapon);
    }

    Return Result;
}


simulated function  Weapon FindUseableWeaponFor(KF_StoryInventoryItem  I)
{
    local Inventory Inv;
    local Weapon UseableWeap;
    local Dummy_JoggingWeapon DummyWeap;

    for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
    {
        if(Weapon(inv) != none && I.AllowHoldWeapon(Weapon(Inv),true))
        {
            UseableWeap = Weapon(Inv);
        }
    }

    if(UseableWeap == none )
    {
        DummyWeap = Dummy_JoggingWeapon(FindInventoryType(class 'Dummy_JoggingWeapon'));
        if(DummyWeap != none)
        {
            UseableWeap = DummyWeap ;
        }
    }

    log("Found useable weapon : "@UseableWeap);
    return UseableWeap;
}

/* Cache a list of equipment the pawn was carrying at the time of his death */
simulated function SaveLoadOut()
{
	local Inventory Inv;
	local int Count;
	local KFPlayerController_Story PC;

	PC = KFPlayerController_Story(Controller);
	if(PC == none )
	{
		return;
	}

    /* Save equipment that we're holding */
	for( Inv=Inventory; Inv!=None ;Inv=Inv.Inventory )
	{
		if(KFWeapon(Inv) != none)
		{
			PC.SavedLoadOut[Count]   = string(Inv.class) ;
			PC.SavedAmmo[Count]      = Weapon(Inv).AmmoAmount(0);
			PC.SavedMagAmmo[Count]   = KFWeapon(Inv).MagAmmoRemaining;

			Count ++ ;
		}
	}

	PC.SavedHealth = Health;
	PC.SavedArmor  = ShieldStrength ;
}


function bool RetrieveSavedLoadOut(Controller C)
{
	local int i, Index;
	local KFPlayerController_Story PC;

	PC = KFPLayerController_Story(C);
	if(PC != none && PC.CurrentCheckPoint != none)
	{
		/* Add Saved equipment from our controller  .. */
		for(i = 0 ; i < Min(PC.SavedLoadOut.length,ArrayCount(RequiredEquipment)) ; i ++)
		{
			if(RequiredEquipment[i] == "" && PC.SavedLoadOut[i] != "")
			{
				RequiredEquipment[i] = PC.SavedLoadOut[i] ;
				Index ++ ;
			}
		}

		return Index > 0;
	}

	return false;
}


function AddDefaultInventory()
{
	local KFLevelRules_Story	StoryRules;
	local int i,InvCount;
	local Inventory Inv;
	local KFPlayerController_Story SPC;
	local bool bUseCheckPointGear;
	local float MaxAmmo,CurrentAmmo;

	/* Clear pawn equipment defaults */
	for(i = 0 ; i < ArrayCount(RequiredEquipment) ; i ++)
	{
		RequiredEquipment[i] = "" ;
	}

	/* Base gear should fill from the level rules */
	Level.Game.AddGameSpecificInventory(self);

	/* next we Add saved gear - stuff we were carrying when we died */

	bUseCheckPointGear = RetrieveSavedLoadOut(Controller);

	Super(UnrealPawn).AddDefaultInventory();

	/* next add perk specific gear - on request */
 	if(KFStoryGameInfo(Level.Game) != none)
 	{
 		StoryRules = KFStoryGameInfo(Level.Game).StoryRules ;
 		if(StoryRules != none && StoryRules.bAllowPerkStartingWeaps)
 		{
			if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
			{
				KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.AddDefaultInventory(KFPlayerReplicationInfo(PlayerReplicationInfo), self);
			}
		}
	}

    if(bUseCheckPointGear)
    {
        /* restore saved ammo values from our last checkpoint .. */
        SPC = KFPlayerController_Story(Controller);
        if(SPC != none)
        {
            for( Inv=Inventory; Inv!=None ;Inv=Inv.Inventory )
            {
                if(Weapon(Inv) != none)
                {
                    Weapon(Inv).GetAmmoCount(MaxAmmo,CurrentAmmo);
                    Weapon(Inv).ConsumeAmmo(0,MaxAmmo,true);

                    Weapon(Inv).AddAmmo(SPC.SavedAmmo[InvCount],0);
                    KFWeapon(Inv).MagAmmoRemaining = SPC.SavedMagAmmo[InvCount];

                    InvCount ++;
                }
            }
	   }
	}
}

simulated function Tick(float DeltaTime)
{
    local KF_StoryPRI PRI;

    Super.Tick(DeltaTime);

    /* Replicated Location stuff - for tracking this pawn's position to display icons when its not relevant */

    PRI = KF_StoryPRI(PlayerReplicationInfo) ;
    if(PRI != none && PRI.GetFloatingIconMat() != none)
    {
        if(Role == Role_Authority)  // server authoritative
        {
            if(PRI.GetOwnerPawn() != self)
            {
                PRI.SetOwnerPawn(self);
                PRI.NetUpdateTime = Level.TimeSeconds - 1;
            }

            KF_StoryPRI(PlayerReplicationInfo).SetReplicatedPawnLoc(GetHoverIconPosition());
        }
        else  // simulated proxy.
        {
            if(bDeleteMe || bPendingDelete)
            {
                PRI.SetOwnerPawn(none);
                PRI.NetUpdateTime = Level.TimeSeconds - 1;
            }
        }
    }
}

/* position to render hovering icons at */
simulated function vector GetHoverIconPosition()
{
    return Location + Vect(0,0,1)*CollisionHeight ;
}

/* Fixing a problem where Perk-Less players dont get charged for ammo */

function bool ServerBuyAmmo( Class<Ammunition> AClass, bool bOnlyClip )
{
	local Inventory I;
	local float Price;
	local Ammunition AM;
	local KFWeapon KW;
	local int c;
	local float UsedMagCapacity;
	local class<KFVeterancyTypes> PlayerVeterancy;

	if ( !CanBuyNow() || AClass == None )
	{
		SetTraderUpdate();
		return false;
	}

	// Grab Players Veterancy for quick reference
	if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none &&
	KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		PlayerVeterancy = KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill;
	}
	else
	{
		PlayerVeterancy = class'KFVeterancyTypes';
	}


	for ( I=Inventory; I != none; I=I.Inventory )
	{
		if ( I.Class == AClass )
		{
			AM = Ammunition(I);
		}
		else if ( KW == None && KFWeapon(I) != None && (Weapon(I).AmmoClass[0] == AClass || Weapon(I).AmmoClass[1] == AClass) )
		{
			KW = KFWeapon(I);
		}
	}

	if ( KW == none || AM == none )
	{
		SetTraderUpdate();
		return false;
	}

	AM.MaxAmmo = AM.default.MaxAmmo;

	if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && PlayerVeterancy != none )
	{
		AM.MaxAmmo = int(float(AM.MaxAmmo) * PlayerVeterancy.static.AddExtraAmmoFor(KFPlayerReplicationInfo(PlayerReplicationInfo), AClass));
	}

	if ( AM.AmmoAmount >= AM.MaxAmmo )
	{
		SetTraderUpdate();
		return false;
	}

	Price = class<KFWeaponPickup>(KW.PickupClass).default.AmmoCost * PlayerVeterancy.static.GetAmmoCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), KW.PickupClass); // Clip price.

	if ( KW.bHasSecondaryAmmo && AClass == KW.FireModeClass[1].default.AmmoClass )
	{
		UsedMagCapacity = 1; // Secondary Mags always have a Mag Capacity of 1? KW.default.SecondaryMagCapacity;
	}
	else
	{
		UsedMagCapacity = KW.default.MagCapacity;
	}

	if( KW.PickupClass == class'HuskGunPickup' )
	{
		UsedMagCapacity = class<HuskGunPickup>(KW.PickupClass).default.BuyClipSize;
	}

	if ( bOnlyClip )
	{
		if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && PlayerVeterancy != none )
		{
			if( KW.PickupClass == class'HuskGunPickup' )
			{
				c = UsedMagCapacity * PlayerVeterancy.static.AddExtraAmmoFor(KFPlayerReplicationInfo(PlayerReplicationInfo), AM.Class);
			}
			else
			{
				c = UsedMagCapacity * PlayerVeterancy.static.GetMagCapacityMod(KFPlayerReplicationInfo(PlayerReplicationInfo), KW);
			}
		}
		else
		{
			c = UsedMagCapacity;
		}
	}
	else
	{
		c = (AM.MaxAmmo-AM.AmmoAmount);
	}

	Price = int(float(c) / UsedMagCapacity * Price);

	if ( PlayerReplicationInfo.Score < Price ) // Not enough CASH (so buy the amount you CAN buy).
	{
		c *= (PlayerReplicationInfo.Score/Price);

		if ( c == 0 )
		{
			SetTraderUpdate();
			return false; // Couldn't even afford 1 bullet.
		}

		AM.AddAmmo(c);
		PlayerReplicationInfo.Score = Max(PlayerReplicationInfo.Score - (float(c) / UsedMagCapacity * Price), 0);

		SetTraderUpdate();

		return false;
	}

	PlayerReplicationInfo.Score = int(PlayerReplicationInfo.Score-Price);
	AM.AddAmmo(c);

	SetTraderUpdate();

	return true;
}

// Drops All Story Items
simulated function InternalTossCarriedItems()
{
    local Inventory Inv, NextInv;
	local Vector X,Y,Z;
    local Vector TossDir;
    local float TossSpeed;
    local vector DropLoc;

	GetAxes(Rotation,X,Y,Z);


    TossSpeed = 250.f;
    DropLoc = Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y;

	// Throws all your story items
    for( Inv=Inventory; Inv!=None; Inv=NextInv )
    {
    	NextInv = Inv.Inventory;
    	TossDir = VRand();
        TossStoryItem( Inv, TossDir, TossSpeed, DropLoc );
    }

	// Throws your weapon
    super.InternalTossCarriedItems();
}

// Drops a single story item
simulated function TossSingleCarriedItem()
{
	local Inventory Inv;
	local Vector X,Y,Z;
    local Vector TossDir;
    local float TossSpeed;
    local vector DropLoc;

	GetAxes(Rotation,X,Y,Z);

    TossDir = vector(Rotation);
    TossSpeed = 250.f;
    DropLoc = Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y;

    for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory)
    {
        TossStoryItem( Inv, TossDir, TossSpeed, DropLoc );
    }
}

simulated function TossStoryItem( Inventory Inv, Vector TossDir, float TossSpeed, vector DropLoc )
{
	local KF_StoryinventoryItem StoryInv;
	if(Inv.IsThrowable())
    {
        StoryInv = KF_StoryInventoryItem(Inv);
        if(StoryInv != none)
        {
            if(StoryInv.bDropFromCameraLoc)
            {
                TossDir = Vector(GetViewRotation());
                if(PlayerController(Controller) != none)
                {
                    DropLoc = PlayerController(Controller).CalcViewLocation;
                }
            }

            TossSpeed = StoryInv.Pickup_TossVelocity;
        }
        Inv.Velocity = TossDir * TossSpeed;
        Inv.DropFrom(DropLoc);
    }
}

/* ============ AI -  Monster threat assessment functionality ==============================
Clamped from -1 to 100, where 100 is the most threatening ==================================
===========================================================================================*/

function  float AssessThreatTo(KFMonsterController  Monster, optional bool CheckDistance)
{
    local float ThreatRating;
    local Inventory CurInv;
    local KF_StoryInventoryItem StoryInv;

    ThreatRating = Super.AssessThreatTo(Monster,CheckDistance);

    /* Factor in story Items which adjust your desirability to ZEDs */
    for ( CurInv = Inventory; CurInv != none; CurInv = CurInv.Inventory )
    {
        StoryInv = KF_StoryInventoryItem(CurInv);
        if(StoryInv != none)
        {
            ThreatRating *= StoryInv.AIThreatModifier ;
        }
    }

    return ThreatRating;
}

defaultproperties
{
}
