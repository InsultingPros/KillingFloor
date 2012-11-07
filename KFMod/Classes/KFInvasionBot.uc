class KFInvasionBot extends InvasionBot;

// Shopping State

// General data for all code to use if needed
var float LastShopTime;

var float LastHealTime;

// Internal to state
var WeaponLocker TargetLocker;
var NavigationPoint ShoppingPath;
var vector MeLoc, LockLoc;
var float LockerDist;
var float LockerHeight;
var KFDoorMover TargetDoor;

var Syringe MySyringe;
var Inventory inv;
var Welder ActiveWelder;

var KFHumanPawn InjuredAlly;
var bool bHasChecked;

var int HealPoint; // Bots will not consider anyone above this threshold in need of medicial assistance
var float HealDist; // Bot will only travel so far to heal someone

// added CanAttack() check to calm trigger-happy bots
function bool FireWeaponAt(Actor A)
{
	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	Target = A;
	if ( Pawn.Weapon != None )
	{
		if(!Pawn.Weapon.CanAttack(A) )
			return false;

		if ( Pawn.Weapon.HasAmmo() )
			return WeaponFireAgain(Pawn.Weapon.RefireRate(),false);
	}
	else
		return WeaponFireAgain(Pawn.RefireRate(),false);
	return false;
}

// There was so much cruft in the UT2K version function that isn't
// relevant to KF. Lets lighten the load
function Actor FaceActor(float StrafingModifier)
{
	local actor SquadFace; //, N;

	//TODO - do we need this?
	SquadFace = Squad.SetFacingActor(self);
	if ( SquadFace != None )
		return SquadFace;

	bRecommendFastMove = false;

	if ( Enemy == none || Level.TimeSeconds - LastSeenTime > 4 - StrafingModifier)
		return FaceMoveTarget();

	// Gibber - trimmed this one down to happen regardless of skill level
	if ( (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon ) )
		return FaceMoveTarget();

	return Enemy;
}

function bool DefendMelee(float Dist)
{
    return (Super.DefendMelee(Dist) || (KFMonster(Enemy) != None && Dist <800));
}

function bool FindInjuredAlly()
{
  local controller c;
  local KFHumanPawn aKFHPawn;
  local float AllyDist;
  local float BestDist;

  InjuredAlly=none;
  BestDist = HealDist;

  if(FindMySyringe()==none)
    return false;

  if(!MySyringe.GetFireMode(0).AllowFire() )
    return false;

  for(c=level.ControllerList; c!=none; c=c.nextController)
  {

    aKFHPawn = kfHumanPawn(c.pawn);

    // If he's dead. dont bother.
    if (aKFHPawn!= none &&
    aKFHPawn.Health <= 0)
     return false;

    if(aKFHPawn!=none && c!=self )
    {

      if(aKFHPawn.Health < aKFHPawn.HealthMax)
      {
        AllyDist = vsize(location - AKFHPawn.Location);

        if(InjuredAlly==none && (AllyDist < HealDist) )
        {
          InjuredAlly = aKFHPawn;
          BestDist = AllyDist;
        }
        else
        {
          // TODO: Weight it so that a seriously injured ally is given
          //       preference even if slightly further away
          if(AllyDist < BestDist)
          {
            InjuredAlly = aKFHPawn;
            BestDist = AllyDist;
          }
        }
      }
    }

  }

  return !(InjuredAlly == none);
}

function bool EnemyReallyScary()
{
  // TODO: We might need deeper logic than this.
  //       This is enough to get Medic behaviour going though
  if(enemy==none)
    return false;
  else
    return ( vsize(location - enemy.Location) < HealDist);
}

// Gibber - stripping out vehicle stuff, adding shopping, better item scavaging
//          using the syringe and all the other little tweaks
function ExecuteWhatToDoNext()
{
	local float WeaponRating;
	local Controller C;
	local PlayerController AdminPC;
	local KFHumanPawn AdminPawn;
	local KFWeapon AdminWeapon;

	bHasFired = false;
	GoalString = "WhatToDoNext at "$Level.TimeSeconds;
	if ( Pawn == None )
	{
		warn(GetHumanReadableName()$" WhatToDoNext with no pawn");
		return;
	}

	// BOT FLASHLIGHT COMMANDS

	// Find Admin, take commands from him
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C!= none && C.IsA('KFPlayerController') && PlayerController(C).PlayerReplicationInfo.bAdmin)
		{
			AdminPC = PlayerController(C);
			if(AdminPC != none)
				AdminPawn = KFHumanPawn(AdminPC.pawn);
			if(AdminPawn != none)
				AdminWeapon = KFWeapon(AdminPawn.Weapon);
		}

	// Any of this is only relevant if theres an admin, and he has a flashlight weapon
	if (AdminWeapon != none && AdminWeapon.bTorchEnabled)
	{
		// If it's active....
		if(AdminWeapon.Flashlight != none && AdminWeapon.Flashlight.bHaslight)
		{
			// If we have a flashlight weapon ourselves, then turn it on.  If its already on, no change.
			if(KFWeapon(pawn.weapon) != none &&
			KFWeapon(pawn.weapon).bTorchEnabled)
			{
				if(KFWeapon(pawn.weapon).Flashlight == none || KFWeapon(pawn.weapon).Flashlight != none && !KFWeapon(pawn.weapon).Flashlight.bhaslight )
					KFWeapon(pawn.Weapon).LightFire();
			}
		}
		else if(AdminWeapon.Flashlight != none && !AdminWeapon.Flashlight.bHaslight)
		{
			// If we have a flashlight that's on , and his is off. turn ours off, too.
			if(KFWeapon(pawn.weapon) != none && KFWeapon(pawn.weapon).bTorchEnabled)
			{
				if(KFWeapon(pawn.weapon).Flashlight != none && KFWeapon(pawn.weapon).Flashlight.bhaslight)
					KFWeapon(pawn.Weapon).LightFire();
			}
		}
	}

	if ( Enemy == None )
	{
		if ( Level.Game.TooManyBots(self) )
		{
			if ( Pawn != None )
			{
				Pawn.Health = 0;
				Pawn.Died( self, class'Suicided', Pawn.Location );
			}
			Destroy();
			return;
		}
		BlockedPath = None;
		bFrustrated = false;
		if (Target == None || (Pawn(Target) != None && Pawn(Target).Health <= 0))
			StopFiring();
	}

	if ( ScriptingOverridesAI() && ShouldPerformScript() )
		return;
	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics();
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
		return;
	if ( (StartleActor != None) && !StartleActor.bDeleteMe && (VSize(StartleActor.Location - Pawn.Location) < StartleActor.CollisionRadius)  )
	{
		Startle(StartleActor);
		return;
	}
	bIgnoreEnemyChange = true;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		LoseEnemy();
	if ( Enemy == None )
		Squad.FindNewEnemyFor(self,false);
	else if ( !Squad.MustKeepEnemy(Enemy) && !EnemyVisible() )
	{
		// decide if should lose enemy
		// TODO - is losing enemies the right thing to do?
		//        do we need SquadAI?
		if ( Squad.IsDefending(self) )
		{
			if ( LostContact(4) )
				LoseEnemy();
		}
		else if ( LostContact(7) )
			LoseEnemy();
	}
	bIgnoreEnemyChange = false;

	if( Enemy==none && ShouldGoShopping() && GoShopping() ) { Return; }
		// do nothing. All the magic is in the line above
	else
	{
		if(FindInjuredAlly() && !EnemyReallyScary() && CanDoHeal() )
		{
			GoHealing();
			return;
		}
		else if ( AssignSquadResponsibility() )
		{
			if ( Pawn == None )
				return;
			SwitchToBestWeapon();
			return;
		}
		if ( ShouldPerformScript() )
			return;
		if ( Enemy != None )
			ChooseAttackMode();
		else
		{

          WeaponRating = Pawn.Weapon.CurrentRating/2000;

          if ( FindInventoryGoal(WeaponRating) )
		  {
			if ( InventorySpot(RouteGoal) == None )
				GoalString = "fallback - inventory goal is not pickup but "$RouteGoal;
			else
				GoalString = "Fallback to better pickup "$InventorySpot(RouteGoal).markedItem$" hidden "$InventorySpot(RouteGoal).markedItem.bHidden;
			GotoState('FallBack');
		  }
			else
			{
				// No enemy and no ammo to grab. Guess all there is left to do is to chill out
				GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
				WanderOrCamp(true);
			}
		}
	}
	SwitchToBestWeapon();
}

function bool DesperateForAmmo()
{
  local float AmmoPercent;
  local actor invit;

  for(invit=self; invit!=none; invit=invit.Inventory )
  {
    if(Weapon(invit)!=none)
    {
      AmmoPercent= (1.0f * Weapon(invit).AmmoCharge[0])/Weapon(invit).AmmoClass[0].default.MaxAmmo;
      if(AmmoPercent > 0.2) // 0.2 = arbitary low value
        return false;
    }
  }
  return true;
}

function bool ShouldGoShopping()
{
	// Can't shop if the shop ain't open
	if( KFGameType(Level.Game).bWaveInProgress )
		return false;

	// Don't need to shop if we've just shopped
	if( LastShopTime>level.TimeSeconds )
		return false;

	if( !bHasChecked && FRand()<0.35 )
	{
		LastShopTime = level.TimeSeconds+FRand()*120;
		bHasChecked = True;
		Return False;
	}

	// At the end of the day, it's all about having money, really
	return (PlayerReplicationInfo.score>=20);
}

function bool CanDoHeal()
{
	if(LastHealTime+2 > level.TimeSeconds)
		return false;

	if( FindMySyringe()==none || !(MySyringe.GetFireMode(0).AllowFire() ) || InjuredAlly==none || InjuredAlly.health <= 0 ||
		(InjuredAlly.healthToGive + InjuredAlly.health >= InjuredAlly.Healthmax) )
		return false;
	else return true;
}

function array<class<Pickup> > GetLegalPurchases()
{
	local int i,j;
	local KFLevelRules KFLR;
	local array<class<Pickup> > RetList;

	KFLR = KFGameType(Level.game).KFLRules;

	for(i=0; i<KFLR.MAX_BUYITEMS; i++ )
	{
		if( CanAfford(KFLR.ItemForSale[i] ) )
		{
			RetList.length = j+1;
			RetList[j++] = KFLR.ItemForSale[i];
		}
	}
	return RetList;
}

function bool CanAfford(class<Pickup> aItem)
{
	local class<kfWeaponPickup> aWeapon;
	local actor InvIt;
	local KFWeapon Weap;
	local bool bFoundInInventory;

	aWeapon = class<kfWeaponPickup>(aItem);

	if(aWeapon!=none)
	{
		bFoundInInventory=false;
		for(InvIt=pawn; InvIt!=none; InvIt=InvIt.Inventory)
		{
			Weap = KFWeapon(InvIt);
			if(Weap!=none)
			{
				bFoundInInventory=true;
				if(Weap.AmmoClass[0]!=none && Weap.Class==aWeapon.default.InventoryType)
				{
					if( PlayerReplicationInfo.score>aWeapon.default.ammocost )
						return true;
				}
			}
		}

		// if we didn't find it above, we need to see if we can buy the whole gun, not just ammo
		if(!bFoundInInventory && aWeapon.default.Cost < self.PlayerReplicationInfo.score && aWeapon.default.weight < (KFHumanPawn(pawn).MaxCarryWeight - KFHumanPawn(pawn).CurrentWeight) )
			return true;
	}
	return false;
}

function KFWeapon FindWeaponInInv(Class<KFWeaponPickup> TargetClass)
{
	local actor InvIt;
	local KFWeapon Weap;

	if( TargetClass==None )
		Return None;
	for( InvIt=pawn; InvIt!=none; InvIt=InvIt.Inventory)
	{
		Weap = KFWeapon(InvIt);
		if(Weap!=none && Weap.Class==TargetClass.default.InventoryType )
			return Weap;
	}
	return none;
}

function DoTrading()
{
	local KFWeapon Weap;
	local int i;
	local class<KFWeaponPickup> BuyWeapClass;
	local int NumCanAfford, NumNeeded, NumToBuy;
	local array<class<Pickup> > ShoppingList;
	local int OldCash;
	local byte LCount;

	LastShopTime = level.TimeSeconds+30+500*FRand();

	OldCash = PlayerReplicationInfo.score + 1;

	while ( (PlayerReplicationInfo.score > 20) && PlayerReplicationInfo.score!=OldCash && LCount++<10 )
	{
		OldCash = PlayerReplicationInfo.score;

		ShoppingList = GetLegalPurchases();
		if( ShoppingList.Length==0 )
			Break;

		// kludge to stack the odds to the low numbers where the best kit is ;)
		if(ShoppingList.length < 3 || frand() < 0.5)
			i = rand(ShoppingList.length);
		else i = rand(0.5*ShoppingList.length);

		BuyWeapClass = class<KFWeaponPickup>(ShoppingList[i]);
		if( BuyWeapClass==None )
			Continue;
		Weap = FindWeaponInInv(BuyWeapClass);

		if(Weap!=none) // already own gun, buy ammo
		{
			NumCanAfford = self.PlayerReplicationInfo.score / (BuyWeapClass.default.ammocost);
			NumNeeded = (Weap.AmmoClass[0].default.MaxAmmo-Weap.AmmoCharge[0]) / Weap.MagCapacity;
			NumToBuy = Min(NumCanAfford, NumNeeded);
			PlayerReplicationInfo.score -= (BuyWeapClass.default.ammocost) * NumToBuy;
			Weap.AddAmmo(Weap.MagCapacity * NumToBuy, 0);
		}
		else // buy that gun
		{
			Weap = KFWeapon(Spawn(BuyWeapClass.default.InventoryType));
			if( Weap!=None )
				Weap.GiveTo(pawn);
			PlayerReplicationInfo.score -= BuyWeapClass.default.cost;
		}
	}
	SwitchToBestWeapon();
}

function bool GoShopping()
{
	if( !GetNearestShop() )
		Return false;
	GoalString = "SHOPPING";
	GotoState('Shopping');
	return true;
}

function bool GoHealing()
{
	if(!IsInState('dead') && !IsInState('GameEnded') && InjuredAlly!=none)
	{
		GoalString = "HEALING";
		GotoState('Healing');
		return true;
	}
	else return false;
}

function Syringe FindMySyringe()
{
	if( MySyringe!=none && MySyringe.Owner==Pawn )
		return MySyringe;

	MySyringe = None;
	for(inv=pawn.Inventory; inv!=none; inv=inv.Inventory)
	{
		if( Syringe(inv)!=none )
			MySyringe = Syringe(inv);
	}
	return MySyringe;
}

function bool GetNearestShop()
{
	local KFGameType KFGT;
	local int i,l;
	local float Dist,BDist;
	local ShopVolume Sp;

	KFGT = KFGameType(Level.Game);
	if( KFGT==None )
		return false;
	l = KFGT.ShopList.Length;
	for( i=0; i<l; i++ )
	{
		if( !KFGT.ShopList[i].bCurrentlyOpen || KFGT.ShopList[i].BotPoint==None )
			continue;
		Dist = VSize(KFGT.ShopList[i].Location-Pawn.Location);
		if( Dist<BDist || Sp==None )
		{
			Sp = KFGT.ShopList[i];
			BDist = Dist;
		}
	}
	if( Sp==None )
		return false;
	ShoppingPath = Sp.BotPoint;
	return true;
}

state Shopping extends MoveToGoalNoEnemy
{
ignores EnemyNotVisible;

Begin:
	WaitForLanding();
	bHasChecked = False;

KeepMoving:
	if( KFGameType(Level.Game).bWaveInProgress )
	{
		LastShopTime = level.TimeSeconds+15+FRand()*30;
		WhatToDoNext(152);
	}
	if( ActorReachable(ShoppingPath) )
		MoveToward(ShoppingPath,FaceActor(1),,false);
	else
	{
		MoveTarget = FindPathToward(ShoppingPath);
		if( MoveTarget!=none )
			MoveToward(MoveTarget,FaceActor(1),,false );
		else
		{
			LastShopTime = level.TimeSeconds+8+FRand()*10;
			WhatToDoNext(151);
		}
		Goto('KeepMoving');
	}
	Focus = TargetLocker;
	Pawn.Acceleration = vect(0,0,0);
	Sleep(1+FRand()*3);
	DoTrading();
	WhatToDoNext(152);
	if ( bSoaking )
		SoakStop("STUCK IN SHOPPING!");
}

state Healing extends MoveToGoalWithEnemy
{

  function TimedFireWeaponAtEnemy()
  {
  	if ( Syringe(Pawn.Weapon)!=none )
  	{
      if(InjuredAlly==none || FireWeaponAt(InjuredAlly))
        SetCombatTimer();
  	  else
        SetTimer(0.1, True);
    }
    else
    {
      global.TimedFireWeaponAtEnemy();
    }
  }

	function SwitchToBestWeapon()
	{
		if(pawn.Weapon==MySyringe || pawn.PendingWeapon==MySyringe)
			return;
		else global.SwitchToBestWeapon();
	}

  function Actor FaceActor(float StrafingModifier)
  {
    if(Syringe(Pawn.Weapon)!=none || enemy==none)
      return InjuredAlly;
    else
      return Enemy;
  }

// TODO: whip syringe out earlier, especially if not under enemy pressure

Begin:
	SwitchToBestWeapon();
	WaitForLanding();

KeepMoving:

	if(enemy==none || vsize(pawn.location -InjuredAlly.location) < vsize(pawn.Location - enemy.location) )
      ClientSetWeapon(class'Syringe');

    MoveTarget = FindPathToward(InjuredAlly);

	if(MoveTarget!=none)
	{
      MoveToward(MoveTarget,FaceActor(1),,false ); //,GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	}
    else
    {
      LastHealTime = level.TimeSeconds;
      // TODO: find why we need the cheap fix above
      WhatToDoNext(151);
    }

    if(MySyringe==none)
    {
      FindMySyringe();
    }

	if(InjuredAlly!=none)
	{
      MeLoc = pawn.Location;
	  LockLoc = InjuredAlly.Location;
	  LockerHeight = abs(MeLoc.Z - LockLoc.Z);
      MeLoc.Z = 0;
      LockLoc.Z = 0;
      LockerDist = VSize(MeLoc - LockLoc);

      // TODO - do we need to use TriggerHeight/2? Don't know, must check
      //        right now it'll prove the concept however
	  if( LockerDist < MySyringe.weaponRange &&
	      LockerHeight < InjuredAlly.CollisionHeight )
	  {
        // TODO: Proper needle stabby (probably want to add check
        //       to ExecuteWhatToDoNext() or related for low syringeage,
        //       or target still under the effects of recent syringification

        // TODO: exhaustive check of reasons to abandon stabbiness
        if( !CanDoHeal() )
        {
          LastHealTime = level.TimeSeconds;
          WhatToDoNext(162);
        }
        else
        {
          sleep(0.5);
          goto('KeepMoving');
        }
        // UBERKLUDGE!!!
        //InjuredAlly.Health = InjuredAlly.HealthMax;
      }
      else Goto('KeepMoving');
	}

    LastHealTime = level.TimeSeconds;
	WhatToDoNext(163);
	if ( bSoaking )
		SoakStop("STUCK IN HEALING!");
}


function SetPawnClass(string inClass, string inCharacter)
{
}

/* ChooseAttackMode()
Handles tactical attacking state selection - choose which type of attack to do from here
*/
function ChooseAttackMode()
{
    local float EnemyStrength, WeaponRating;

    GoalString = " ChooseAttackMode last seen "$(Level.TimeSeconds - LastSeenTime);
    // should I run away?
    if ( (Squad == None) || (Enemy == None) || (Pawn == None) )
        log("HERE 1 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn);
    EnemyStrength = RelativeStrength(Enemy);

   /*
    if ( Vehicle(Pawn) != None )
    {
        VehicleFightEnemy(true, EnemyStrength);
        return;
    }
    */


    // This is where the new pawn retreat conditions will be. Keep it simple, stupid.

    // if he's hurt. He'll run.

      if ( (pawn.Health / pawn.HealthMax) <= 0.25 ||
    VSize(location - enemy.Location) < 50 &&
    pawn.Weapon != none &&
     !pawn.Weapon.bMeleeWeapon)
    {
     GoalString = "Retreat";
     DoRetreat();
     GotoState('FallBack');
    // Log("Fuck this, im outta here!");
    }


     /*

    if ( !bFrustrated && !Squad.MustKeepEnemy(Enemy) )
    {
        RetreatThreshold = Aggressiveness;
        if ( Pawn.Weapon.CurrentRating > 0.5 )
            RetreatThreshold = RetreatThreshold + 0.35 - skill * 0.05;
        if ( EnemyStrength > RetreatThreshold )
        {
            GoalString = "Retreat";
            if ( (PlayerReplicationInfo.Team != None) && (FRand() < 0.05) )
                SendMessage(None, 'Other', GetMessageIndex('INJURED'), 15, 'TEAM');
            DoRetreat();
            return;
        }
    }
    */
    if ( (Squad.PriorityObjective(self) == 0) && (Skill + Tactics > 2) && ((EnemyStrength > -0.3) || (Pawn.Weapon.AIRating < 0.5)) )
    {
        if ( Pawn.Weapon.AIRating < 0.5 )
        {
            if ( EnemyStrength > 0.3 )
                WeaponRating = 0;
            else
                WeaponRating = Pawn.Weapon.CurrentRating/2000;
        }
        else if ( EnemyStrength > 0.3 )
            WeaponRating = Pawn.Weapon.CurrentRating/2000;
        else
            WeaponRating = Pawn.Weapon.CurrentRating/1000;

        // fallback to better pickup?   No.  you're in a combat sitatuion.
        // being choosy about pickups should only come at round end. (for bots)
        /*
        if ( FindInventoryGoal(WeaponRating) )
        {
            if ( InventorySpot(RouteGoal) == None )
                GoalString = "fallback - inventory goal is not pickup but "$RouteGoal;
            else
                GoalString = "Fallback to better pickup "$InventorySpot(RouteGoal).markedItem$" hidden "$InventorySpot(RouteGoal).markedItem.bHidden;
            GotoState('FallBack');
            return;
        }
        */
    }
    GoalString = "ChooseAttackMode FightEnemy";
    FightEnemy(true, EnemyStrength);
}


function FightEnemy(bool bCanCharge, float EnemyStrength)
{
	local vector X,Y,Z;
	local float enemyDist;
	local float AdjustedCombatStyle;
	local bool bFarAway, bOldForcedCharge;

	if ( (Squad == None) || (Enemy == None) || (Pawn == None) )
		log("HERE 3 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn);

    if ( (Enemy == FailedHuntEnemy) && (Level.TimeSeconds == FailedHuntTime) )
    {
        GoalString = "FAILED HUNT - HANG OUT";
        if ( EnemyVisible() )
            bCanCharge = false;
        else if ( FindInventoryGoal(0) )
        {
            SetAttractionState();
            return;
        }
        else
        {
            WanderOrCamp(true);
            return;
        }
    }


	bOldForcedCharge = bMustCharge;
	bMustCharge = false;
	enemyDist = VSize(Pawn.Location - Enemy.Location);
	if( Pawn.Weapon==None )
		AdjustedCombatStyle = CombatStyle;
	else AdjustedCombatStyle = CombatStyle + Pawn.Weapon.SuggestAttackStyle();
	Aggression = 1.5 * FRand() - 0.8 + 2 * AdjustedCombatStyle - 0.5 * EnemyStrength + FRand() * (Normal(Enemy.Velocity - Pawn.Velocity) Dot Normal(Enemy.Location - Pawn.Location));

	if ( enemyDist > MAXSTAKEOUTDIST )
		Aggression += 0.5;
    if ( (Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Falling) )
    {
        if (Pawn.Location.Z > Enemy.Location.Z + TACTICALHEIGHTADVANTAGE)
            Aggression = FMax(0.0, Aggression - 1.0 + AdjustedCombatStyle);
        else if ( (Skill < 4) && (enemyDist > 0.65 * MAXSTAKEOUTDIST) )
        {
            bFarAway = true;
            Aggression += 0.5;
        }
        else if (Pawn.Location.Z < Enemy.Location.Z - Pawn.CollisionHeight) // below enemy
            Aggression += CombatStyle;
    }

	// see enemy - decide whether to charge it or strafe around/stand and fire
	BlockedPath = None;
	Target = Enemy;

	if( (Pawn.Weapon!=None && Pawn.Weapon.bMeleeWeapon) || (bCanCharge && bOldForcedCharge) )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}
	if ( Pawn.Weapon!=None && !Pawn.Weapon.bMeleeWeapon )
	{
		GoalString = "Long Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	if ( bCanCharge && (Skill < 5) && bFarAway && (Aggression > 1) && (FRand() < 0.5) )
	{
		GoalString = "Charge closer";
		DoCharge();
		return;
	}

	if ( (Pawn.Weapon!=None && Pawn.Weapon.RecommendRangedAttack()) || IsSniping() || ((FRand() > 0.17 * (skill + Tactics - 1)) && !DefendMelee(enemyDist)) )
	{
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}

	if ( bCanCharge )
	{
		if ( Aggression > 1 )
		{
			GoalString = "Charge 2";
			DoCharge();
			return;
		}
	}

	if( (pawn.Health / pawn.HealthMax) <= 0.25 || VSize(location - enemy.Location) < 50 && pawn.Weapon != none && !pawn.Weapon.bMeleeWeapon )
	{
		GoalString = "Retreat";
		DoRetreat();
		GotoState('FallBack');
	}

	GoalString = "Do tactical move";
	if ( Pawn.Weapon!=None && !Pawn.Weapon.RecommendSplashDamage() && (FRand() < 0.7) && (3*Jumpiness + FRand()*Skill > 3) )
	{
		GetAxes(Pawn.Rotation,X,Y,Z);
		GoalString = "Try to Duck ";
		if ( FRand() < 0.5 )
		{
			Y *= -1;
			TryToDuck(Y, true);
		}
		else TryToDuck(Y, false);
	}
	DoTacticalMove();
}

function DirectedWander(vector WanderDir)
{


    GoalString = "DIRECTED WANDER "$GoalString;
    Pawn.bWantsToCrouch = false;
    if ( TestDirection(WanderDir,Destination) )
        GotoState('RestFormation', 'Moving');
    else
        GotoState('RestFormation', 'Begin');
}

function WanderOrCamp(bool bMayCrouch)
{
    Pawn.bWantsToCrouch = false;
    GotoState('RestFormation');
}

function SealUpDoor( KFDoorMover Door ) // Called from door whenever bot should unseal this.
{
	local Welder W;

	if( Enemy!=None && LineOfSightTo(Enemy) )
		Return;
	W = Welder(Pawn.FindInventoryType(Class'Welder'));
	if( W==None )
		Return;
	ActiveWelder = W;
	TargetDoor = Door;
	GoToState('UnWeldDoor');
}

State UnWeldDoor
{
Ignores NotifyBump;

	function SwitchToBestWeapon()
	{
		if ( Pawn==None || Pawn.Inventory==None || Pawn.Weapon==ActiveWelder )
			return;
		Pawn.PendingWeapon = ActiveWelder;
		StopFiring();
		if ( Pawn.Weapon == None )
			Pawn.ChangedWeapon();
		else Pawn.Weapon.PutDown();
	}
	function Timer()
	{
		if( Pawn.Weapon==ActiveWelder )
			FireWeaponAt(TargetDoor);
	}
	function bool FireWeaponAt(Actor A)
	{
		Target = A;
		if ( Pawn.Weapon==ActiveWelder )
			return WeaponFireAgain(Pawn.Weapon.RefireRate(),false);
		else return False;
	}
	function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
	{
		LastFireAttempt = Level.TimeSeconds;
		Target = TargetDoor;
		if( Pawn.Weapon==ActiveWelder )
		{
			Focus = Target;
			bCanFire = true;
			bStoppedFiring = false;
			return Pawn.Weapon.BotFire(bFinishedFire);
		}
		StopFiring();
		return false;
	}
Begin:
	Pawn.Acceleration = vect(0,0,0);
	Focus = TargetDoor;
	Target = TargetDoor;
	While( Pawn.Weapon!=ActiveWelder )
	{
		SwitchToBestWeapon();
		Sleep(0.25);
	}
	FireWeaponAt(TargetDoor);
	Sleep(0.5);
	if( TargetDoor.bSealed )
		GoTo'Begin';
	Global.SwitchToBestWeapon();
	WhatToDoNext(12);
}
function SetMaxDesiredSpeed()
{
	if ( Pawn != None )
			Pawn.MaxDesiredSpeed = 1;
}
function SetPeripheralVision()
{
	if ( Pawn == None )
		return;
	if ( Pawn.bStationary || (Pawn.Physics == PHYS_Flying) )
	{
		bSlowerZAcquire = false;
		Pawn.PeripheralVision = -0.7;
		return;
	}
	bSlowerZAcquire = false;
	Pawn.PeripheralVision = -0.2;
	Pawn.PeripheralVision = FMin(Pawn.PeripheralVision - BaseAlertness, 0.8);
	Pawn.SightRadius = Pawn.Default.SightRadius;
}
function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
	local rotator FireRotation, TargetLook;
	local float FireDist, TargetDist, ProjSpeed,TravelTime;
	local actor HitActor;
	local vector FireSpot, FireDir, TargetVel, HitLocation, HitNormal;
	local int realYaw;
	local bool bDefendMelee, bClean, bLeadTargetNow;

	if ( FiredAmmunition.ProjectileClass != None )
		projspeed = FiredAmmunition.ProjectileClass.default.speed;

	// make sure bot has a valid target
	if ( Target == None )
	{
		Target = Enemy;
		if ( Target == None )
			return Rotation;
	}

	if ( Pawn(Target) != None )
		Target = Pawn(Target).GetAimTarget();

	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - Pawn.Location);

	// perfect aim at stationary objects
	if ( Pawn(Target) == None )
	{
		if ( !FiredAmmunition.bTossed )
			return rotator(Target.Location - projstart);
		else
		{
			FireDir = AdjustToss(projspeed,ProjStart,Target.Location,true);
			SetRotation(Rotator(FireDir));
			return Rotation;
		}
	}

	bLeadTargetNow = FiredAmmunition.bLeadTarget && bLeadTarget;
	bDefendMelee = ( (Target == Enemy) && DefendMelee(TargetDist) );
	aimerror = AdjustAimError(aimerror,TargetDist,bDefendMelee,FiredAmmunition.bInstantHit, bLeadTargetNow);

	// lead target with non instant hit projectiles
	if ( bLeadTargetNow )
	{
		TargetVel = Target.Velocity;
		TravelTime = TargetDist/projSpeed;
		// hack guess at projecting falling velocity of target
		if ( Target.Physics == PHYS_Falling )
		{
			if ( Target.PhysicsVolume.Gravity.Z <= Target.PhysicsVolume.Default.Gravity.Z )
				TargetVel.Z = FMin(TargetVel.Z + FMax(-400, Target.PhysicsVolume.Gravity.Z * FMin(1,TargetDist/projSpeed)),0);
			else
			{
				TargetVel.Z = TargetVel.Z + 0.5 * TravelTime * Target.PhysicsVolume.Gravity.Z;
				FireSpot = Target.Location + TravelTime*TargetVel;
			 	HitActor = Trace(HitLocation, HitNormal, FireSpot, Target.Location, false);
			 	bLeadTargetNow = false;
			 	if ( HitActor != None )
			 		FireSpot = HitLocation + vect(0,0,2);
			}
		}

		if ( bLeadTargetNow )
		{
			// more or less lead target (with some random variation)
			FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * TargetVel * TravelTime;
			FireSpot.Z = FMin(Target.Location.Z, FireSpot.Z);
		}
		if ( (Target.Physics != PHYS_Falling) && (FRand() < 0.55) && (VSize(FireSpot - ProjStart) > 1000) )
		{
			// don't always lead far away targets, especially if they are moving sideways with respect to the bot
			TargetLook = Target.Rotation;
			if ( Target.Physics == PHYS_Walking )
				TargetLook.Pitch = 0;
			bClean = ( ((Vector(TargetLook) Dot Normal(Target.Velocity)) >= 0.71) && FastTrace(FireSpot, ProjStart) );
		}
		else // make sure that bot isn't leading into a wall
			bClean = FastTrace(FireSpot, ProjStart);
		if ( !bClean)
		{
			// reduce amount of leading
			if ( FRand() < 0.3 )
				FireSpot = Target.Location;
			else
				FireSpot = 0.5 * (FireSpot + Target.Location);
		}
	}

	bClean = false; //so will fail first check unless shooting at feet
	if ( FiredAmmunition.bTrySplash && (Pawn(Target) != None) && ((Skill >=4) || bDefendMelee)
		&& (((Target.Physics == PHYS_Falling) && (Pawn.Location.Z + 80 >= Target.Location.Z))
			|| ((Pawn.Location.Z + 19 >= Target.Location.Z) && (bDefendMelee || (skill > 6.5 * FRand() - 0.5)))) )
	{
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,1) * (Target.CollisionHeight + 6), FireSpot, false);
 		bClean = (HitActor == None);
		if ( !bClean )
		{
			FireSpot = HitLocation + vect(0,0,3);
			bClean = FastTrace(FireSpot, ProjStart);
		}
		else
			bClean = ( (Target.Physics == PHYS_Falling) && FastTrace(FireSpot, ProjStart) );
	}
	if ( Pawn.Weapon != None && Pawn.Weapon.bSniping )
	{
		// try head
 		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
 		bClean = FastTrace(FireSpot, ProjStart);
	}

	if ( !bClean )
	{
		//try middle
		FireSpot.Z = Target.Location.Z;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( FiredAmmunition.bTossed && !bClean && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			bCanFire = false;
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
		}
		bClean = true;
	}

	if( !bClean )
	{
		// try head
 		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( !bClean && (Target == Enemy) && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
		if ( Pawn.Location.Z >= LastSeenPos.Z )
			FireSpot.Z -= 0.4 * Enemy.CollisionHeight;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			FireSpot = LastSeenPos + 2 * Enemy.CollisionHeight * HitNormal;
			if ( Pawn.Weapon != None && Pawn.Weapon.SplashDamage() && (Skill >= 4) )
			{
			 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
				if ( HitActor != None )
					FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			}
			if ( Pawn.Weapon != None && Pawn.Weapon.RefireRate() < 0.99 )
				bCanFire = false;
		}
	}

	// adjust for toss distance
	if ( FiredAmmunition.bTossed )
		FireDir = AdjustToss(projspeed,ProjStart,FireSpot,true);
	else
	{
		FireDir = FireSpot - ProjStart;
		if ( Pawn(Target) != None )
			FireDir = FireDir + Pawn(Target).GetTargetLocation() - Target.Location;
	}

	FireRotation = Rotator(FireDir);
	realYaw = FireRotation.Yaw;

	FireRotation.Yaw = SetFireYaw(FireRotation.Yaw + aimerror);
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	FireDist = FMin(VSize(FireSpot-ProjStart), 400);
	FireSpot = ProjStart + FireDist * FireDir;
	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
	if ( HitActor != None )
	{
		if ( HitNormal.Z < 0.7 )
		{
			FireRotation.Yaw = SetFireYaw(realYaw - aimerror);
			FireDir = vector(FireRotation);
			FireSpot = ProjStart + FireDist * FireDir;
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		}
		if ( HitActor != None )
		{
			FireSpot += HitNormal * 2 * Target.CollisionHeight;
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
			if ( HitActor != None )
				FireSpot += Target.CollisionHeight * HitNormal;
			FireDir = Normal(FireSpot - ProjStart);
			FireRotation = rotator(FireDir);
		}
	}
	InstantWarnTarget(Target,FiredAmmunition,vector(FireRotation));
	ShotTarget = Pawn(Target);

	SetRotation(FireRotation);
	return FireRotation;
}
function float AdjustAimError(float aimerror, float TargetDist, bool bDefendMelee, bool bInstantProj, bool bLeadTargetNow )
{
	return Super.AdjustAimError(aimerror,TargetDist,bDefendMelee,bInstantProj,bLeadTargetNow)*0.35;
}

defaultproperties
{
     HealPoint=50
     HealDist=2500.000000
     Aggressiveness=1.000000
     BaseAlertness=1.000000
     Accuracy=1.000000
     CombatStyle=-1.000000
     ReactionTime=1.000000
     Skill=7.000000
     FovAngle=360.000000
     bAdrenalineEnabled=False
     PawnClass=Class'KFMod.KFHumanPawn'
}
