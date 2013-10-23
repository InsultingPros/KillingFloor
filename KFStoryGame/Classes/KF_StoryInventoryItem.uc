/*
	--------------------------------------------------------------
	KF_StoryInventoryItem
	--------------------------------------------------------------

    Base class for Objective-driven inventory items which players can
    hold on their pawns.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_StoryInventoryItem extends Inventory
dependson(KF_PlaceableStoryPickup);

/* Number of items of this class which can be held by a pawn at once */
var     int                         MaxHeldCopies;

var     Material                    CarriedMaterial;

/* Icon to render over top of this Pickup while it's sitting on the ground */
var     Material                    GroundMaterial;

var     float                       MovementSpeedModifier;

var     class<DamageType>           ImpactDamType;

var     int                         ImpactDamage;

var     rotator                     ViewRotationOffset;

var     vector                      ViewLocationOffset;

/* If we want the pawn to go a specific speed when carrying this item (ignoring all other modifiers) , here's where we do it */
var     float                       ForcedGroundSpeed;

var     bool                        bUseForcedGroundSpeed;

var     float                       Pickup_TossVelocity;

var     bool                        bDropFromCameraLoc;

var     bool                        bRender1PMesh;

var     float                       JumpZModifier;

var     StaticMesh                  PickupSM;

var     KF_PlaceableStoryPickup     StoryPickupBase;

var     name                        DroppedEvent;

var     int                         Weight;

/* Changes the amount of interest ZEDs will show in the player holding this item */
var     float                       AIThreatModifier;

var     name                        InvAttachmentBone;

/* When holding this item, display it with an 'X-Ray' shader in first person */
var     bool                        bUseFirstPersonXRayEffect;

/* List of weapons which cannot be used when this Item is carrieed */
var                                 array< Class<Weapon> >             AllowedWeapons;

/* List of weapons which can *only* be used when this item is carried */
var                                 array < Class<Weapon> >            RestrictedWeapons;

var                                 array<KF_PlaceableStoryPickup.SCarriedEvent>   CarriedEvents;

/* Disable the bCollideActors property of pickups spawned by this Item when they are created */
var     bool                        bDisableCollisionOnDrop;

replication
{
    reliable if( Role==ROLE_Authority)
        MovementSpeedModifier,CarriedMaterial,ClientGiveTo,AllowHoldWeapon,StoryPickupBase,bRender1PMesh,bUseFirstPersonXRayEffect;

}

function GiveTo( pawn Other, optional Pickup Pickup )
{
    Super.GiveTo(Other,Pickup);
    AttachToPawn(Instigator);
    ClientGiveTo(Other,Pickup);
    UpdateHeldMaterial(Other,CarriedMaterial);

	if ( KFHumanPawn_Story( Other ) != none)
	{
		KFHumanPawn_Story( Other ).SetHasStoryItem( true );
	}
}

/* Updates the Material which floats over the pawns head to this icon' Mat */
function UpdateHeldMaterial(Pawn Holder, Material NewMat)
{
    local KF_StoryPRI PRI;

    PRI = KF_StoryPRI(Holder.PlayerReplicationInfo);
    if(PRI != none)
    {
        PRI.SetFloatingIconMat(NewMat);
        PRI.NetupdateTime = Level.TimeSeconds - 1;
    }
}

function Tick(float DeltaTime)
{
    TriggerHeldEvents();
}

function TriggerHeldEvents()
{
    local int i;

    if(Instigator != none )
    {
        for(i = 0 ; i < CarriedEvents.length ; i ++)
        {
            if((CarriedEvents[i].NumRepeats == 0 ||
            CarriedEvents[i].NumTimesTriggered < CarriedEvents[i].NumRepeats) &&
            Level.TimeSeconds - CarriedEvents[i].LastTriggerTime >= CarriedEvents[i].TriggerInterval)
            {
                CarriedEvents[i].NumTimesTriggered ++ ;
                CarriedEvents[i].LastTriggerTime = Level.TimeSeconds;

                TriggerEvent(CarriedEvents[i].EventName,self,Instigator);
            }
        }
    }
}



simulated function ClientGiveTo(pawn Other,Pickup OwningPickup)
{
    Instigator = Other;

    if(KFHumanPawn_Story(Other) != none &&
    Other.Weapon != none &&
    !AllowHoldWeapon(Other.Weapon))
    {
        Other.PendingWeapon = KFHumanPawn_Story(Other).FindUseableWeaponFor(self);
        if(Other.PendingWeapon != none)
        {
            Other.PendingWeapon.ClientWeaponSet(true);
        }
    }
}


/* Render first person Model for Inventory item */
simulated event RenderOverlays( canvas Canvas)
{
    local int i;
    local int NumSkins;
    local vector ViewLoc, Locoffset;
    local Rotator ViewRot,RotOffset,PawnRot;

    /* Orient the model to the holder's camera and draw it */

    if(bRender1PMesh &&
    Instigator != none && PlayerController(Instigator.Controller) != none &&
    !PlayerController(Instigator.Controller).bBehindView)
    {
        /* X-Ray vision effect  */

        NumSkins = 3;
        Skins.length = Max(Skins.length,NumSkins);

        for(i = 0 ; i < Skins.length  ; i ++)
        {
            if(bUseFirstPersonXRayEffect)
            {
                Skins[i] = Shader 'KFStoryGame_Tex.Shaders.SeethruPickup_shdr' ;
            }
        }

        if(StoryPickupBase != none)
        {
            LocOffset = StoryPickupBase.ViewLocationOffset;
            RotOffset = StoryPickupbase.ViewRotationOffset;
        }

        PawnRot = Instigator.Rotation;
        ViewRot = Instigator.GetViewRotation() ;
        ViewLoc = (Instigator.Location + PlayerController(Instigator.Controller).CalcViewLocation) /2 ;

        SetLocation(ViewLoc + (vector(ViewRot) * (CollisionRadius + Instigator.CollisionRadius)));
        SetRotation(ViewRot);
        SetRelativeLocation(Location + LocOffset);
        SetRelativeRotation(ViewRot + RotOffset);

        Canvas.DrawActor(None, false, true); // clear Z Buffer.
        bDrawingFirstPerson = true;
        Canvas.DrawActor(self, false, false, 90.f);
        bDrawingFirstPerson = false;
    }
}

function AttachToPawn(Pawn P)
{
	local name BoneName;
    local vector LocOffset;
    local rotator RotOffset;

    /* NO attachment for this item, early out */
	if(AttachmentClass == none)
	{
	   return;
	}


    /* If attaching to a bone on the mesh, make sure to use relative values */
    if(StoryPickupBase != none )
    {
        LocOffset = StoryPickupBase.Attachment_Offset;
        RotOffset = StoryPickupBase.Attachment_Rotation;
    }

	Instigator = P;
	if ( ThirdPersonActor == None )
	{
		ThirdPersonActor = Spawn(AttachmentClass,Owner);

        if(ThirdPersonActor == none)
        {
            return;
        }

		InventoryAttachment(ThirdPersonActor).InitFor(self);
	}
	else
		ThirdPersonActor.NetUpdateTime = Level.TimeSeconds - 1;
	BoneName = InvAttachmentBone;
	if ( BoneName == '' )
	{
        // no attachment bone.  Dont render in third person.
        ThirdPersonActor.SetBase(P);
        ThirdPersonActor.bHidden = true;
	}
	else
    {
		P.AttachToBone(ThirdPersonActor,BoneName);

        ThirdPersonActor.SetRelativeLocation(LocOffset);
        ThirdPersonActor.SetRelativeRotation(RotOffset);
    }
}

simulated function CopyPropertiesFrom(KF_StoryInventoryPickup  OwningPickup)
{
    StoryPickupBase = OwningPickup.StoryPickupBase;

    MaxHeldCopies           = OwningPickup.MaxHeldCopies;
    MovementSpeedModifier   = OwningPickup.MovementSpeedModifier;
    AIThreatModifier        = OwningPickup.AIThreatModifier;
    PickupSM                = OwningPickup.StaticMesh;
    Weight                  = OwningPickup.Weight;
    CarriedMaterial         = OwningPickup.CarriedMaterial ;
    GroundMaterial          = OwningPickup.GroundMaterial;
    PrePivot                = OwningPickup.PrePivot;
    AmbientGlow             = OwningPickup.AmbientGlow;
    UV2Texture              = OwningPickup.UV2Texture;
    bUseFirstPersonXRayEffect = OwningPickup.bUseFirstPersonXRayEffect;
    bRender1PMesh           = OwningPickup.bRender1PMesh;
    ViewLocationOffset      = OwningPickup.ViewLocationOffset;
    ViewRotationOffset      = OwningPickup.ViewRotationOffset;
    Pickup_TossVelocity     = OwningPickup.Pickup_TossVelocity;
    bDropFromCameraLoc    = OwningPickup.bDropFromCameraLoc;
    ImpactDamType           = OwningPickup.ImpactDamType;
    ImpactDamage            = OwningPickup.ImpactDamage;

    SetDrawScale(OwningPickup.DrawScale);
    SetStaticMesh(OwningPickup.StaticMesh);
    LinkMesh(OwningPickup.Mesh);
    SetDrawType(OwningPickup.DrawType);
    SetDrawScale3D(OwningPickup.DrawScale3D);
    SetRotation(OwningPickup.Rotation);
    SetCollisionSize(OwningPickup.CollisionRadius,OwningPickup.CollisionHeight);

    if(StoryPickupBase != none)
    {
        JumpZModifier           = StoryPickupBase.JumpZModifier;
        DroppedEvent            = StoryPickupBase.DroppedEvent;
        CarriedEvents           = StoryPickupBase.CarriedEvents;
        InvAttachmentBone       = StoryPickupBase.Attachment_Bone;
    }

    log("=================================================");
    log("Copy properties from : "@OwningPickup@" to - "@self);
    log("=================================================");
}


simulated function ClientItemThrown()
{
    AmbientSound = None;
    Instigator.DeleteInventory(self);

    if(Instigator.Weapon.IsA('Dummy_JoggingWeapon'))
    {
        Instigator.Controller.SwitchToBestWeapon();
    }
}

function DropFrom(vector StartLocation)
{
	local Pickup P;
    local Rotator VRot;

    if( StoryPickupBase != none )
	{
	    VRot = StoryPickupBase.Rotation;
	}

	P = spawn(PickupClass,,,StartLocation,VRot);

	if( P == none && Instigator != none )
	{
	    // couldn't spawn using StartLocation, try Instigator's location and just drop it
	    P = spawn(PickupClass,,,Instigator.Location,VRot);
	    Velocity = vect(0,0,0);
	}

	if ( P == None )
	{
	    if( Instigator != none && Instigator.Health > 0 )
	    {
	        // couldn't spawn using Instigator's location, just hold on to it (do nothing)
	        return;
	    }

	    // Instigator can't hold on to it because he's dead, so freak out
	    warn(self$" couldn't be dropped by instigator "$Instigator);
		destroy();
		return;
	}

    ClientItemThrown();

	if ( Instigator != None )
	{
		if ( KFHumanPawn_Story( Instigator ) != none)
		{
			KFHumanPawn_Story( Instigator ).SetHasStoryItem( false );
		}

		DetachFromPawn(Instigator);
		Instigator.DeleteInventory(self);
	}

    UpdateHeldMaterial(Instigator,none);
	SetDefaultDisplayProperties();
	StopAnimating();
	GotoState('');

	if(StoryPickupBase != none && KF_StoryInventoryPickup(P) != none)
	{
	   StoryPickupBase.CopyPropertiesTo(KF_StoryInventoryPickup(P));
    }
    else
    {
        if(KF_StoryInventoryPickup(P) != none)
        {
            KF_StoryInventoryPickup(P).MovementSpeedModifier = MovementSpeedModifier;
        }

    	P.Tag = tag;                 // make sure we copy the tag over to the new pickup .
    }

	P.InitDroppedPickupFor(self);
	P.Velocity = Velocity;

	Velocity = vect(0,0,0);
	Instigator = None;
}


simulated function float GetMovementModifierFor(Pawn InPawn)
{
    return MovementSpeedmodifier;
}

simulated function bool AllowHoldWeapon(Weapon InWeapon, optional bool SkipDummyWeap)
{
    local int i;
    local bool Result;
    local array< class<Weapon> > AllowedWeaps,RestrictedWeaps;

    if(InWeapon == none)
    {
        return  false;
    }

    /* Hackity hack!*/
    if(!SkipDummyWeap &&
    InWeapon.IsA('Dummy_JoggingWeapon'))
    {
        return true;
    }

    if(StoryPickupBase == none)
    {
        AllowedWeaps = AllowedWeapons;
        RestrictedWeaps = RestrictedWeapons;
    }
    else
    {
        AllowedWeaps = StoryPickupBase.Weapons_Allowed;
        RestrictedWeaps = StoryPickupBase.Weapons_Restricted;
    }

    if(AllowedWeaps.length == 0)
    {
        Result = true;
    }
    else
    {
        for(i = 0 ; i < AllowedWeaps.length ; i ++)
        {
            if(ClassisChildOf(InWeapon.class,AllowedWeaps[i]))
            {
                Result = true;
                break;
            }
        }
    }

    for(i = 0 ; i < RestrictedWeaps.length ; i ++)
    {
        if(ClassisChildOf(InWeapon.class,RestrictedWeaps[i]))
        {
            Result = false;
            break;
        }
    }

//    log("does"@self@" allow the use of :"@InWeapon@" ? :"@Result);

    return Result;
}

simulated function bool IsThrowable()
{
    return true;
}

defaultproperties
{
     MovementSpeedModifier=1.000000
     ImpactDamType=Class'Engine.Crushed'
     Pickup_TossVelocity=250.000000
     JumpZModifier=1.000000
     AIThreatModifier=1.000000
     InvAttachmentBone="CHR_LArmForeArm"
     PickupClass=Class'KFStoryGame.KF_StoryInventoryPickup'
     PlayerViewOffset=(X=25.000000,Z=-20.000000)
     BobDamping=5.000000
     AttachmentClass=Class'KFStoryGame.StoryInventoryAttachment'
}
