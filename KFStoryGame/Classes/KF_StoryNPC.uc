/*
	--------------------------------------------------------------
	LD Placeable NPC actor.  Can be controlled by AI Scripts
	(for non-combat behaviour).  Or with the KF_StoryNPC_AI controller
	for simple combat AI.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_StoryNPC extends KFHumanPawn
placeable
hidecategories(DeRes,Bob,Blur,UDamage);

var	()	    localized array<string>		NPCDialogue;

var	()	    localized string			NPCName;

var	        KF_DialogueSpot		DialogueTrigger;

var ()	    bool				bRunning;

var		    name				RunningAnims[8];

var	()	    float				BaseGroundSpeed;

var ()      float               RespawnTime;

var ()      bool                bStartActive;

var ()      bool                bIndestructible;

var (AI)    int					TeamIndex;

var (AI)	bool				bFireAtWill;

var (AI)    float               BaseAIThreatRating;

var (AI)    array< class <Pawn> >  OnlyThreateningTo,NotThreateningTo;

var (AI)    bool                bNoThreatToZEDs;

var		    bool				bShotAnim;

var	()	    bool				bHasInfiniteAmmo;

var			bool				bInitialFireAtWill;

var ()		bool				bDropInventoryOnDeath;

/* If true, this pawn is marked Hidden while inactive. */
var (Display) bool              bOnlyVisibleWhenActive;

/* Initial location this NPC was placed at by the L.D */
var		   vector				PlacedLoc;

var 	   rotator				PlacedRot;

/* Modifier to apply to incoming damage from friendly pawns */
var()        float              FriendlyFireDamageScale;

var()       bool                bShowHealthBar;

var(Movement) bool              bUseDefaultPhysics;

var()       float               NPCHealth;

var()       float               StartingHealthPct;

var()       bool                bDamageable;

var         bool                bActive;

var         bool                bInitialActive;

/* Event to fire off when this NPC becomes 'Active' */
var(Events) name                ActivationEvent,DeActivationEvent,HealedEvent;

var(Pawn)   bool                bUseHitPoints;

enum	ENPCTriggerAction
{
	TA_ToggleHoldFire,
	TA_CommitSuicide,
	TA_ToggleActive,
};


var ()  ENPCTriggerAction		TriggerAction;

replication
{
    reliable if(Role == Role_Authority)
        bActive;
}

/* Stub.  The objective just changed. Called from KFStoryGameinfo.SetActiveObjective() */
function OnObjectiveChanged(name OldObjectiveName, name NewObjectiveName){}

function SetMovemetPhysics()
{
    if(!bUseDefaultPhysics)
    {
        Super.SetMovementPhysics();
    }
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
    Health = Min(Health + Amount, HealthMax);
    return true;
}

function ProcessLocationalDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, array<int> PointsHit )
{
    if(!bUseHitPoints)
    {
        TakeDamage(Damage,instigatedBy,HitLocation,Momentum,damageType);
    }
    else
    {
        Super.ProcessLocationalDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType,PointsHit);
    }
}

function SaveHealthState(){}

function Reset()
{
	bFireAtWill = bInitialFireAtWill ;
	SetActive(bInitialActive);
	ResurrectNPC();
}

simulated function PostBeginPlay()
{
    local AIScript A;

	Super.PostbeginPlay();

	SpawnDialogueTrigger();

	bInitialFireAtWill	= bFireAtWill;

	if(bStartActive)
	{
	   SetActive(true);
	}

    if(bOnlyVisibleWhenActive)
    {
        UpdateVisibility(bActive);
    }

    bInitialActive      = bActive;

	PlacedLoc			= Location;
	PlacedRot 			= Rotation;
	GroundSpeed 		= BaseGroundSpeed;
	MenuName			= NPCName;
	Health              = NPCHealth * StartingHealthPct;
	HealthMax           = NPCHealth;

	// automatically add controller to pawns which were placed in level
	// NOTE: pawns spawned during gameplay are not automatically possessed by a controller
	if ( (Health > 0) && !bDontPossess )
	{
		// check if I have an AI Script
		if ( AIScriptTag != '' )
		{
			ForEach AllActors(class'AIScript',A,AIScriptTag)
				break;
			// let the AIScript spawn and init my controller
			if ( A != None )
			{
				A.SpawnControllerFor(self);
				if ( Controller != None )
					return;
			}
		}
		if ( (ControllerClass != None) && (Controller == None) )
			Controller = spawn(ControllerClass);
		if ( Controller != None )
		{
			Controller.Possess(self);
			AIController(Controller).Skill += SkillModifier;
		}
	}
}


function ResurrectNPC()
{
    if(Health < NPCHealth)
    {
        Health          = NPCHealth * StartingHealthPct;
	    HealthMax       = NPCHealth;
	    SetCollision(true,true);
	    bHidden = false;
	    RepositionNPC();
    }
}



function RepositionNPC()
{
    if(bMovable)
    {
	   SetRotation(PlacedRot);
	   SetLocation(PlacedLoc);
    }
}

function SpawnDialogueTrigger()
{
	local int i;

	if(DialogueTrigger == none && NPCDialogue.length > 0)
	{
		DialogueTrigger = Spawn(class 'KF_DialogueSpot');
		DialogueTrigger.bTouchTriggered = true;
		DialogueTrigger.bRandomize = true;
		DialogueTrigger.bHardAttach = true;
		DialogueTrigger.SetBase(self);
		DialogueTrigger.SetCollisionSize(CollisionRadius * 1.5,CollisionHeight) ;

		for(i = 0 ; i < NPCDialogue.length ; i ++)
		{
			DialogueTrigger.Dialogues.length = i + 1;
			DialogueTrigger.Dialogues[i].Display.Dialogue_text = NPCDialogue[i];
			DialogueTrigger.Dialogues[i].Display.Dialogue_header = NPCName;
            DialogueTrigger.Dialogues[i].BroadcastScope = InstigatorOnly;
			DialogueTrigger.Dialogues[i].VoiceOver.SourceActor = self;
		}
	}

}

/* Doing this here instead of in Gameinfo.ReduceDamage() because of how hilariously hacked up KFGameType's implementation
of that function is ... */

simulated function TakeDamage(int Damage,pawn instigatedBy, Vector HitLocation, vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    local int ReducedDamage;

/*   log("=============================================================",'Story_Debug');
    log(self@"Took Damage : "@Damage@" from : "@instigatedBy@" Am I damageable ? : "@bDamageable@" Current Health : "@Health,'Story_Debug');
*/

    if(!bDamageable || Health <= 0)
    {
        return;
    }

    ReducedDamage = Damage;

    // friendly fire ... scale down the damage
    if(/*instigatedBy.Controller.GetTeamNum() == Controller.GetTeamNum()*/
    PlayerController(instigatedBy.Controller) != none)    // Yeah looks like this guy's never actually getting assigned a correct team.
    {
        ReducedDamage *= FriendlyFireDamageScale;
    }

    Super.TakeDamage(ReducedDamage,InstigatedBy,HitLocation,Momentum,damageType,HitIndex);

}


function bool GiveHealth(int HealAmount, int HealMax)
{
    local bool bHealed;

    bHealed = Super.GiveHealth(HealAmount,HealMax);

    if(HealedEvent != '' && HealAmount > 0 && bHealed)
    {
        TriggerEvent(HealedEvent,self,Instigator);
    }


    return bHealed;
}

/*
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(!bPlayedDeath && !bIndestructible)
	{
		SpawnDummyCorpse(Killer,damageType,HitLocation);
	}
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    Super(xPawn).PlayDying(DamageType,HitLoc);
}*/

simulated function SpawnDummyCorpse(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local KFPawn DummyCorpse;
	local int i, EquipLength;

	SetCollision(false,false);
	bHidden = true;

	DummyCorpse = Spawn(class 'KFHumanPawn',,,Location,Rotation);
	if(DummyCorpse != none)
	{
		DummyCorpse.LinkMesh(Mesh);
		DummyCorpse.tag = tag;
  		DummyCorpse.Event = Event;

		if(bDropInventoryOnDeath)
		{
			EquipLength = arraycount(RequiredEquipment);
			for(i = 0 ; i < EquipLength ; i ++)
			{
				DummyCorpse.RequiredEquipment[i] = RequiredEquipment[i] ;
			}

			DummyCorpse.AddDefaultInventory();
		}

		DummyCorpse.Died(Killer,damageType,HitLocation);
	}
}


function Trigger( Actor Other, Pawn EventInstigator )
{
	switch(TriggerAction)
	{
		case TA_CommitSuicide  :  Died(Controller,class 'Suicided',  Location) ; break;
		case TA_ToggleHoldFire :  bFireAtWill = !bFireAtWill;                    break;
		case TA_ToggleActive   :  SetActive(!bActive);                           break;
	}
}

function UpdateVisibility(bool On)
{
    if(bOnlyVisibleWhenActive)
    {
        bHidden = !On;
        SetCollision(!bHidden,!bHidden);
    }
}

/* turns this NPC on / off
ie. Makes it damageable and decides whether AI ignores it

Network :  Server */

function SetActive(bool On)
{
    if(Role < Role_Authority)
    {
        return;
    }

    UpdateVisibility(On);

    bActive         = On;
    bDamageable     = bActive;
    log(self@" is now  bActive : "@On,'Story_Debug');

    if(On && ActivationEvent != '')
    {
        TriggerEvent(ActivationEvent,self,self);
    }
    else
    if(!On && DeActivationEvent != '')
    {
        TriggerEvent(DeActivationEvent,self,self);
    }
}

simulated function int GetTeamNum()
{
    return TeamIndex;
}

/* === AI functions =====================================*/

function  float AssessThreatTo(KFMonsterController  Monster, optional bool CheckDistance)
{
    if(bNoThreatToZEDs ||
    TeamIndex == 255   ||
    Health <= 0        ||
    !bActive           ||
    !bDamageable       ||
    (!IsThreateningTo(Monster.Pawn)) )
    {
        return -1.f;
    }

    return Super.AssessThreatTo(Monster,CheckDistance) + BaseAIThreatRating ;
}

/* Returns true if the supplied Monster considers this NPC a threat (and is prepared to attack it) */
function bool IsThreateningTo( Pawn Monster)
{
    local int i;
    local bool Result;

    if(Monster == none)
    {
        return false;
    }

    Result = true;

    for(i = 0 ; i < NotThreateningTo.length ; i ++)
    {
        if(ClassisChildOf(Monster.class,NotThreateningTo[i]))
        {
            Result = false;
            break;
        }
    }

    for(i = 0 ; i < OnlyThreateningTo.length ; i ++)
    {
        Result = false;
        if(ClassisChildOf(Monster.class,OnlyThreateningTo[i]))
        {
            Result = true;
            break;
        }
    }

    return Result;
}

function bool 	IsPacifist()
{
	local Inventory Inv;
	local int Count;
	local Weapon	Weap;
	local bool 		bUsingLethalGear;

	for( Inv=Inventory; Inv!=None && Count < 1000; Inv=Inv.Inventory )
	{
		Weap = Weapon(Inv);

		bUsingLethalGear = Weap != none && (Weap.bMeleeWeapon || Weap.HasAmmo()) ;
		if(bUsingLethalGear && bFireAtWill)
		{
			return false;
		}

		Count++;
	}

	return true;
}


simulated event PostRender2D(Canvas C, float ScreenLocX, float ScreenLocY)  // called if bScriptPostRender is true, overrides native team beacon drawing code
{
	local PlayerController PC;
	local float Opacity;
//	local float Dist;
	local HUDKillingFloor KFHUD;
    local vector CameraLocation,CamDir;
    local rotator CameraRotation;

	if(!bShowHealthBar ||
	!bActive ||
    GetStateName() == 'Dying')
	{
        return;
	}

	PC = Level.GetLocalPlayerController();

	if ( PC != None )
	{
        KFHUD = HUDKillingFloor(PC.myHUD);
        if(KFHUD != none)
        {
            C.GetCameraLocation(CameraLocation, CameraRotation);
            CamDir  = vector(CameraRotation);

            /* Rendering behind us... */
            if ( (Normal(Location - CameraLocation) dot CamDir) < 0 )
            {
                return;
            }

            Opacity =  FClamp(1.f - (VSize(PC.CalcViewLocation - Location) / 3000.f),0.25f,1.f) ;
            KFHUD.DrawKFBar(C,ScreenLocX,ScreenLocY,Health/HealthMax,Byte(Opacity * 255.f),false);
        }
    }
}

function RosterEntry GetPlacedRoster()
{
	return None;
}

function string GetPlayerName()
{
    return NPCName;
}

defaultproperties
{
     NPCName="An NPC"
     bStartActive=True
     bFireAtWill=True
     bDropInventoryOnDeath=True
     FriendlyFireDamageScale=1.000000
     NPCHealth=100.000000
     StartingHealthPct=1.000000
     bDamageable=True
     bUseHitPoints=True
     TriggerAction=TA_ToggleActive
     ControllerClass=Class'KFStoryGame.KF_StoryNPC_AI'
     bNoDelete=True
     bAlwaysRelevant=True
}
