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

var(Pickup_Feedback)        Material                    HUDMaterial;

var(Pickup_PawnModifiers)   float                       MovementSpeedModifier;

var(Pickup_Feedback)        localized string            Message_Dropped; // Human readable description when dropped.

var(Pickup_Feedback)        localized string            Message_PickedUp;

var(Pickup_Feedback)        localized string            Message_Use;

var(Pickup_Feedback)        bool                        bRenderIconThroughWalls;

var(Pickup_Audio)           Sound                       Sound_Dropped,Sound_PickedUp;

var(Pickup_Attachment)      vector                      Attachment_Offset;

var(Pickup_Attachment)      name                        Attachment_Bone;

var(Pickup_Attachment)      rotator                     Attachment_Rotation;

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

var(Pickup_Restrictions)    int                         InventoryWeight;

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
    NewPickup.MovementSpeedModifier = MovementSpeedModifier;
    NewPickup.AIThreatModifier = AIThreatModifier;
    NewPickup.Weight = InventoryWeight;
    NewPickup.default.DroppedMessage = Message_Dropped;
    NewPickup.default.UseMeMessage = Message_Use;
    NewPickup.default.PickupMessage = Message_PickedUp;
    NewPickup.CarriedMaterial = HUDMaterial ;
    NewPickup.PickupSound = Sound_PickedUp;
    NewPickup.DroppedSound = Sound_Dropped;

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
    if( PowerUp == None )
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
     MovementSpeedModifier=1.000000
     Message_Use="Press USE key to Pick up"
     bRenderIconThroughWalls=True
     Sound_Dropped=SoundGroup'Inf_Player.RagdollImpacts.BodyImpact'
     Sound_PickedUp=SoundGroup'KF_AxeSnd.Axe_Select'
     JumpZModifier=1.000000
     AIThreatModifier=1.000000
     PowerUp=Class'KFStoryGame.KF_StoryInventoryPickup'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DetailSM.Crates.WoodBox_B'
     bUseDynamicLights=True
     bHidden=True
     bNoDelete=True
     bNetInitialRotation=True
     PrePivot=(Z=10.000000)
     CollisionRadius=30.000000
     CollisionHeight=10.000000
}
