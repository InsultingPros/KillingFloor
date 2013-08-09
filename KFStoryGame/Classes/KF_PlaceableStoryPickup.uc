/*
	--------------------------------------------------------------
	KF_StoryInvPickupSpot
	--------------------------------------------------------------

    When placing Inventory Pickups in Story maps this actor should be used
    in place of KF_StoryInventoryPickups.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class   KF_PlaceableStoryPickup extends xPickupBase
hidecategories(PickupBase);

/* Icon to render for this Pickup on the holding player's HUD */
var(Pickup_HUD)        Material                         HUDMaterial;

/* Icon to render over top of this Pickup while it's sitting on the ground */
var(Pickup_HUD)        Material                         GroundMaterial;

/* If true, don't perform line traces to determine if we should render the GroundMaterial  (setting this true is an optimization) */
var(Pickup_HUD)             bool                        bRenderIconThroughWalls;

/* Modifier to apply to the holding player's groundspeed */
var(Pickup_PawnModifiers)   float                       MovementSpeedModifier;

var(Pickup_Feedback)        localized string            Message_Dropped; // Human readable description when dropped.

var(Pickup_Feedback)        localized string            Message_PickedUp;

var(Pickup_Feedback)        localized string            Message_Use;

var(Pickup_Audio)           Sound                       Sound_Dropped,Sound_PickedUp;

var(Pickup_3P)      vector                              Attachment_Offset;

var(Pickup_3P)      name                                Attachment_Bone;

var(Pickup_3P)      rotator                             Attachment_Rotation;

var(Pickup_1P)      bool                                bRender1PMesh;

/* When holding this item, display it with an 'X-Ray' shader in first person */
var(Pickup_1P)      bool                                bUseFirstPersonXRayEffect;

var(Pickup_1P)      rotator                             ViewRotationOffset;

var(Pickup_1P)      vector                              ViewLocationOffset;

/* Multiplies the height of the player's jumpZ by this amount */
var(Pickup_PawnModifiers)   float                       JumpZModifier;

/* List of weapons which cannot be used when this Item is carrieed */
var(Pickup_Restrictions)                               array< Class<Weapon> >             Weapons_Restricted;

/* List of weapons which can *only* be used when this item is carried */
var(Pickup_Restrictions)                               array < Class<Weapon> >            Weapons_Allowed;

/* Changes the amount of interest ZEDs will show in the player holding this item */
var(Pickup_PawnModifiers)   float                       AIThreatModifier;

/* Number of items of this class which can be held by a pawn at once */
var(Pickup_Restrictions)    int                         MaxHeldCopies;

/* Number of Inventory blocks this item takes up of the holder's weight allowance */
var(Pickup_Restrictions)    int                         InventoryWeight;

/* Determines when the pickup actor should be spawned for this pickupspot */
enum EPickupSpawnMethod
{
    Spawn_OnMapLoad,
    Spawn_OnMatchBegin,
    Spawn_OnTrigger,
};

var(Pickup_Spawning)        EPickupSpawnMethod          SpawnMethod;

var                         KF_StoryInventoryPickup     MyStoryPickup;

struct SCarriedEvent
{
    var()       name        EventName;
    var()       float       TriggerInterval;
    var()       int         NumRepeats;
    var         int         NumTimesTriggered;
    var         float       LastTriggerTime;
};

var(Events)          array<SCarriedEvent>               CarriedEvents;

var(Events)          name                               DroppedEvent;

/* UUs per second this pickup should travel at when tossed by a player */
var(Pickup_Tossing)         float                       Pickup_TossVelocity;

/* If true, orient this pickup's toss direction from the players camera instead of his pawn rotation */
var(Pickup_Tossing)         bool                        bDropFromCameraLoc;

/* Type of damage this pickup does when it smacks into something :- )  */
var(Pickup_Tossing)         class<DamageType>           ImpactDamType;

var(Pickup_Tossing)         int                         ImpactDamage;


simulated event PostBeginPlay()
{
    if(SpawnMethod == Spawn_OnMapLoad)
    {
	   Super.PostBeginPlay();
    }
}

function MatchStarting()
{
    Super.MatchStarting();

    if(SpawnMethod == Spawn_OnMatchBegin)
    {
        SpawnPickup();
    }
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    Super.Trigger(Other,EventInstigator);

    if(SpawnMethod == Spawn_OnTrigger)
    {
        SpawnPickup();
    }
}

simulated function CopyPropertiesTo(KF_StoryInventoryPickup  NewPickup)
{
    log("*******************************************************");
    log("Client Copy properties from : "@self@" to - :"@NewPickup);

    NewPickup.StoryPickupBase = self;

    NewPickup.Event = event;
    NewPickup.tag = tag;
    NewPickup.MaxHeldCopies = MaxHeldCopies;
    NewPickup.SetCollisionSize(CollisionRadius,CollisionHeight);
    NewPickup.PrePivot = PrePivot;
    NewPickup.PlacedRotation = Rotation;
    NewPickup.SetDrawType(DrawType);
    NewPickup.SetStaticMesh(StaticMesh);
    NewPickup.LinkMesh(Mesh);
    NewPickup.SetDrawScale(DrawScale);
    NewPickup.SetDrawScale3D(DrawScale3D);
    NewPickup.bRenderIconThroughWalls = bRenderIconThroughWalls;
    NewPickup.bUseFirstPersonXRayEffect = bUseFirstPersonXRayEffect;
    NewPickup.MovementSpeedModifier = MovementSpeedModifier;
    NewPickup.AIThreatModifier = AIThreatModifier;
    NewPickup.Weight = InventoryWeight;
    NewPickup.default.DroppedMessage = Message_Dropped;
    NewPickup.default.UseMeMessage = Message_Use;
    NewPickup.default.PickupMessage = Message_PickedUp;
    NewPickup.CarriedMaterial = HUDMaterial ;
    Newpickup.GroundMaterial = GroundMaterial;
    NewPickup.PickupSound = Sound_PickedUp;
    NewPickup.DroppedSound = Sound_Dropped;
    NewPickup.UV2Texture = UV2Texture;
    NewPickup.bRender1PMesh = bRender1PMesh;
    NewPickup.ViewLocationOffset = ViewLocationOffset;
    NewPickup.ViewRotationOffset = ViewRotationOffset;
    NewPickup.Pickup_TossVelocity = Pickup_TossVelocity;
    NewPickup.bDropFromCameraLoc = bDropFromCameraLoc;
    NewPickup.ImpactDamType = ImpactDamType;
    NewPickup.ImpactDamage = ImpactDamage;

    // Lighting

    NewPickup.LightType = LightType;
    NewPickup.LightCone = LightCone;
    NewPickup.LightBrightness = LightBrightness;
    NewPickup.LightRadius = LightRadius;
    NewPickup.bUseDynamicLights = bUseDynamicLights;
    NewPickup.LightSaturation = LightSaturation;
    NewPickup.bDynamicLight = bDynamicLight;
    NewPickup.AmbientGlow = AmbientGlow;
    NewPickup.LightHue = LightHue;

    NewPickup.bLightChanged = true;
}

function SpawnPickup()
{
    if( myPickUp != none || PowerUp == None || Level.NetMode == NM_Client )
        return;

    myPickUp = Spawn(PowerUp,,,Location,Rotation);
    if(myPickup != none)
    {
        myPickUp.PickUpBase = self;

        MyStoryPickup = KF_StoryInventoryPickup(myPickup);
        if(MyStoryPickup != none)
        {
            CopyPropertiesTo(MyStoryPickup);
        }
    }

	if (myMarker != None)
	{
		myMarker.markedItem = myPickUp;
		myMarker.ExtraCost = ExtraPathCost;
        if (myPickUp != None)
		    myPickup.MyMarker = MyMarker;
	}
	else log("No marker for "$self);
}

defaultproperties
{
     bRenderIconThroughWalls=True
     MovementSpeedModifier=1.000000
     Message_Use="Press USE key to Pick up"
     Sound_Dropped=SoundGroup'Inf_Player.RagdollImpacts.BodyImpact'
     Sound_PickedUp=SoundGroup'KF_AxeSnd.Axe_Select'
     bRender1PMesh=True
     JumpZModifier=1.000000
     AIThreatModifier=1.000000
     Pickup_TossVelocity=250.000000
     ImpactDamType=Class'Engine.Crushed'
     PowerUp=Class'KFStoryGame.KF_StoryInventoryPickup'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DetailSM.Crates.WoodBox_B'
     bUseDynamicLights=True
     bStatic=False
     bHidden=True
     bNoDelete=True
     bNetInitialRotation=True
     PrePivot=(Z=10.000000)
     CollisionRadius=30.000000
     CollisionHeight=10.000000
}
