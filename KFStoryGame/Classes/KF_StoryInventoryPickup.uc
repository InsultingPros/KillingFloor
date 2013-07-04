/*
	--------------------------------------------------------------
	KF_StoryInventoryPickup
	--------------------------------------------------------------

    Base class for Objective-driven inventory items which players can
    hold on their pawns.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_StoryInventoryPickup extends Pickup
notplaceable;

/* Number of items of this class which can be held by a pawn at once */
var                                     int                                 MaxHeldCopies;

var(Pickup_Feedback)                    Material                            CarriedMaterial;

var(Pickup_Restrictions)                float                               MovementSpeedModifier;

var(Pickup_Feedback)                    string                              DroppedMessage; // Human readable description when dropped.

var(Pickup_Feedback)                    string                              UseMeMessage;

var                                     Rotator                             PlacedRotation;

var                                     float                               LastUseMeMsgTime;

var                                     bool                                bRenderIconThroughWalls;

/* Sound this pickup makes when it falls to the floor */
var(Pickup_Audio)                       Sound                               DroppedSound;

/* Number of inventory blocks this item takes up when carried */
var(Pickup_Restrictions)                int                                 Weight;

/* Changes the amount of interest ZEDs will show in the player holding this item */
var                                     float                               AIThreatModifier;

var                                     KF_PlaceableStoryPickup             StoryPickupBase;

replication
{
    reliable if (Role== Role_Authority)
        CarriedMaterial,bRenderIconThroughWalls;
}


static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
    if(Switch == 1)
    {
        return default.DroppedMessage;
    }
    else
    {
    	return default.PickupMessage;
    }
}

state FallingPickup
{
	// Story Inventory pickups can't be grabbed by walking over them.
	function Touch( actor Other )
	{
	}

	event Landed( vector HitNormal )
	{
        Global.Landed(HitNormal);
        if(DroppedSound != none)
        {
            PlaySound(DroppedSound,,2.f,false,SoundRadius,SoundPitch,true);
        }
	}
}


auto state Pickup
{
	function Timer()
	{
	}

	// Story Inventory pickups can't be grabbed by walking over them.
	function Touch( actor Other )
	{
        if(!ValidTouch(Other))
        {
            return;
        }

        if(Pawn(Other) != none && PlayerController(Pawn(Other).Controller) != none && Level.TimeSeconds - LastUseMeMsgTime > 4.f)
        {
            LastUseMeMsgTime = Level.TimeSeconds;
            PlayerController(Pawn(Other).Controller).ClientMessage(UseMeMessage, 'KFCriticalEvent');
        }

        /* Have KFBots auto pickup stuff for testing purposes*/
        if(Pawn(Other) != none && KFInvasionBot(Pawn(Other).Controller) != none)
        {
            UsedBy(Pawn(Other));
        }
	}

	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( actor Other )
	{
		// make sure its a live player
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None) )
			return false;

        /* Too much weight .. ? */
		if (KFHumanPawn(Other) != none && !KFHumanPawn(Other).CanCarry(Weight))
		{
			PlayerController(Pawn(Other).Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 4);
            return false;
		}
        /* Too many held copies ? */
        if(IsHoldingTooManyCopies(Pawn(Other)))
        {
            return false;
        }

		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
			return false;

		TriggerEvent(Event, self, Pawn(Other));
		return true;
	}

	event UsedBy( Pawn user)
	{
		local Inventory Copy;
		local KF_StoryInventoryPickup P,Closest;
		local float Dist,ClosestDist;

        /* Only grab one inventory pickup at a time */
		foreach User.TouchingActors(class 'KF_StoryInventoryPickup', P)
		{
		    Dist = VSizeSquared(P.Location - Location);
            if(ClosestDist == 0 || Dist < ClosestDist)
            {
                ClosestDist = Dist;
                Closest = P;
            }
		}

		// If used by a player pawn, let him pick this up.
		if( Closest == self && ValidTouch(user) )
		{
			Copy = SpawnCopy(user);
			AnnouncePickup(user);
            SetRespawn();
            if ( Copy != None )
				Copy.PickupFunction(user);
		}
	}
}


function AnnouncePickup( Pawn Receiver )
{
    BroadCastPickupEvent(Receiver,1);
    PlaySound( PickupSound,SLOT_Interact );
}

function AnnounceDropped( Pawn Dropper)
{
    BroadCastPickupEvent(Dropper,2);
}

function BroadCastPickupEvent( Pawn Receiver , int Switch)
{
    local Controller C;
    local PlayerController PC;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
        PC = PlayerController(C);
        if(PC != none)
        {
            PC.ReceiveLocalizedMessage(MessageClass,Switch,Receiver.PlayerReplicationInfo);
        }
	}
}


simulated function bool IsHoldingTooManyCopies(pawn InPawn)
{
    local Inventory Inv;
    local int NumHeld;

    if(MaxHeldCopies <= 0)
    {
        return false;
    }

	for( inv=InPawn.Inventory; inv!=None; inv=inv.Inventory )
	{
        if(Inv.class == InventoryType)
        {
            NumHeld ++;
        }
	}

	return (NumHeld + 1) > MaxHeldCopies;
}



/* Draw floating icons overtop of pickups, on request */
simulated event RenderOverlays( canvas Canvas )
{
	local float Opacity;
	local float IconSize;
	local float XCentre,YCentre;
	local vector ScreenPos;
	local Material RenderMat;
	local vector CameraLocation;
	local rotator CameraRotation;
	local float Dist;

    Super.RenderOverlays(Canvas);

	if(CarriedMaterial == none)
	{
        return;
	}


    Canvas.GetCameraLocation(CameraLocation, CameraRotation);

	/* fading jazz from PlayerBeacon code */

	Dist = vsize(CameraLocation-Location);
	Dist -= class 'HUDKillingFloor'.default.HealthBarFullVisDist;
	Dist = FClamp(Dist, 0, class 'HUDKillingFloor'.default.HealthBarCutoffDist-class 'HUDKillingFloor'.default.HealthBarFullVisDist);
	Dist = Dist / (class 'HUDKillingFloor'.default.HealthBarCutoffDist- class 'HUDKillingFloor'.default.HealthBarFullVisDist);
    Opacity = Max(byte((1.f - Dist) * 255.f),100.f);

    if(!bRenderIconThroughWalls && !FastTrace(Location,CameraLocation))
    {
        return;
    }

    RenderMat = CarriedMaterial ;
	IconSize = CarriedMaterial.MaterialUSize();

    ScreenPos = Canvas.WorldToScreen(Location + CollisionHeight * Vect(0,0,1));

    XCentre = ScreenPos.X;
    YCentre = ScreenPos.Y;

    /* Dont render stuff behind the camera */
	if ( (Normal(Location - CameraLocation) dot vector(CameraRotation)) < 0 )
	{
        return;
    }

    Canvas.DrawColor.R = 255;
    Canvas.DrawColor.G = 255;
    Canvas.DrawColor.B = 255;
    Canvas.DrawColor.A = Opacity;

    Canvas.SetPos(XCentre - (0.5 * IconSize) + 1.0, YCentre - (0.5 * IconSize) + 1.0);
    Canvas.DrawTileScaled(RenderMat, IconSize/ RenderMat.MaterialVSize() ,IconSize/ RenderMat.MaterialVSize() );
}

function InitDroppedPickupFor(Inventory Inv)
{
	SetPhysics(PHYS_Falling);
	GotoState('FallingPickup');
	Inventory = Inv;
	bAlwaysRelevant = false;
	bOnlyReplicateHidden = false;
	bUpdateSimulatedPosition = true;
    bDropped = true;
	bIgnoreEncroachers = false; // handles case of dropping stuff on lifts etc
	NetUpdateFrequency = 8;
 //   Inv.Instigator.HandlePickup(self);
    Instigator = Inv.Instigator;
    BroadCastPickupEvent(Inv.Instigator,2);
}

/* Create an Inventory Item for this Pickup */

function inventory SpawnCopy( pawn Other )
{
    local Inventory Copy;
    local KF_StoryInventoryItem StoryInv;

	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else
	{
        Copy = spawn(InventoryType,Other,,,rot(0,0,0));
    }

    Copy.Tag = tag;


    StoryInv = KF_StoryInventoryItem(Copy);
    if(StoryInv != none)
    {
        StoryInv.CopyPropertiesFrom(self);
    }

	Copy.GiveTo( Other, self );

    return Copy;
}

defaultproperties
{
     MovementSpeedModifier=1.000000
     DroppedMessage="You dropped the gold bars."
     UseMeMessage="Press USE key to Pick up"
     bRenderIconThroughWalls=True
     DroppedSound=SoundGroup'Inf_Player.RagdollImpacts.BodyImpact'
     AIThreatModifier=1.000000
     InventoryType=Class'KFStoryGame.KF_StoryInventoryItem'
     bOnlyReplicateHidden=False
     PickupSound=SoundGroup'KF_AxeSnd.Axe_Select'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DetailSM.Crates.WoodBox_B'
     bOrientOnSlope=False
     bIgnoreEncroachers=False
     bNetInitialRotation=True
     Physics=PHYS_Falling
     NetUpdateFrequency=8.000000
     PrePivot=(Z=10.000000)
     CollisionRadius=30.000000
     CollisionHeight=10.000000
     bFixedRotationDir=False
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
