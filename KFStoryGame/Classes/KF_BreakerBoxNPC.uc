/*
	--------------------------------------------------------------
	 KF_StoryNPC_Static
	--------------------------------------------------------------

	Repairable breaker box NPC for use in Objective missions.
	Has support for different visual damage states.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_BreakerBoxNPC extends KF_StoryNPC_Static;

var             float               LastTriggerEventTime;

var             Material            BrokenMat,FixedMat;

var ()          bool                bWeldable;

var(Events)     name                Event_FullHealth,Event_NoHealth;

var             bool                bRepaired,SavedbFullhealth,bDestroyed,SavedbNoHealth;

var(Display)    StaticMesh          HealthyMesh,DestroyedMesh;

var class<Emitter> HitEmitter;

replication
{
    reliable if(Role == Role_Authority && bNetDirty)
        bRepaired;
}


function Reset()
{
    Super.Reset();
    if(bCheckPointed)
    {
        bRepaired = SavedbFullHealth;
        bDestroyed   = SavedbNoHealth;
    }

    CheckHealthCondition(self);
}

simulated function PostBeginPlay()
{
	Super.PostbeginPlay();

    CheckHealthCondition(self);
    bHidden = true;                // breaker boxes start out hidden and non-interactable.
    SetCollision(false,false);
}

function SetActive(bool On)
{
    Super.SetActive(On);

    if(bActive)
    {
        bHidden = false;
        SetCollision(true,true);
    }
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if(!bDestroyed && Level.TimeSeconds -LastTriggerEventTime > 1.0)
    {
        LastTriggerEventTime = Level.TimeSeconds;
        TriggerEvent('IncrementPower',self,self);
    }
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    local bool bHealed;

	if ( bWeldable && damageType == class 'DamTypeWelder' )
	{
        Health = Min(Health + Damage, NPCHealth);
        bHealed = true;
	}

    CheckHealthCondition(InstigatedBy);

    if(bHealed)
    {
        return; // can skip the rest of the takedamage stuff.
    }

    Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,damageType,HitIndex);

    CheckhealthCondition(InstigatedBy);
}


simulated function CheckHealthCondition(Pawn InstigatedBy)
{
    if(!bRepaired && Health >= NPCHealth)
    {
        bRepaired = true;
        bDestroyed   = false;

        TriggerEvent(Event_FullHealth,self,InstigatedBy);

        if(HealthyMesh != none)
        {
            SetStaticMesh(HealthyMesh);
        }
    }
    else
    {
        if(!bDestroyed && Health <= 0 )
        {
            bDestroyed = true;
            bRepaired = false;

            TriggerEvent(Event_NoHealth,self,InstigatedBy);

            if(DestroyedMesh != none)
            {
                SetStaticMesh(DestroyedMesh);
            }
        }
    }
}

/* Draw additional icons for Breaker boxes */

simulated event PostRender2D(Canvas C, float ScreenLocX, float ScreenLocY)  // called if bScriptPostRender is true, overrides native team beacon drawing code
{
	local PlayerController PC;
	local float Opacity;
//	local float Dist;
	local HUDKillingFloor KFHUD;
	local float IconSize;
	local float XCentre,YCentre;
	local vector ScreenPos;
	local float HealthPct;
	local Material RenderMat;

	if(!bShowHealthBar ||
	!bActive ||
    GetStateName() == 'Dying' )
	{
        return;
	}

	IconSize = 64.f * (C.SizeX/1920.f);

	PC = Level.GetLocalPlayerController();
	if ( PC != None )
	{
        KFHUD = HUDKillingFloor(PC.myHUD);
        if(KFHUD != none)
        {
            if(bRepaired)
            {
                RenderMat = FixedMat ;
            }
            else
            {
                RenderMat = BrokenMat;
            }

            ScreenPos = C.WorldToScreen(Location);
            XCentre = ScreenPos.X;
            YCentre = ScreenPos.Y;

            Opacity =  FClamp(1.f - (VSize(PC.CalcViewLocation - Location) / 3000.f),0.4f,1.f) ;
            HealthPct = FClamp(float(Health) / NPCHealth,0.f,1.f);

            C.DrawColor.R = Lerp(HealthPct,255,0);
            C.DrawColor.G = Lerp(HealthPct,0,255);
            C.DrawColor.B = 50;
            C.DrawColor.A = Opacity * 255;

            C.SetPos(XCentre - (0.5 * IconSize) + 1.0, YCentre - (0.5 * IconSize) + 1.0);
            C.DrawTileScaled(RenderMat, IconSize/ RenderMat.MaterialVSize() ,IconSize/ RenderMat.MaterialVSize() );
        }
    }
}

// Breaker boxes should never spawn gibs even if it looks cool
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{}

// Replace the damage type hit emitter with a custom one
function SpawnHitEmitter( float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum )
{
  	local Vector HitNormal;

  	// Play any set effect
	if ( EffectIsRelevant(Location,true) )
	{
		if (HitEmitter != None)
		{
		    if( InstigatedBy != none )
		        HitNormal = Normal((InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight))-HitLocation);

			Spawn(HitEmitter,,,HitLocation+HitNormal + (-HitNormal * CollisionRadius), Rotator(HitNormal));
		}
	}
}

defaultproperties
{
     BrokenMat=Texture'KFStoryGame_Tex.HUD.Repair_Icon_64_BW'
     FixedMat=Texture'KFStoryGame_Tex.HUD.Electricity_Icon_64'
     bWeldable=True
     HealthyMesh=StaticMesh'Props_ObjectiveMode.Breaker_Box'
     DestroyedMesh=StaticMesh'Props_ObjectiveMode.Breaker_Box_DMG'
     HitEmitter=Class'KFMod.Breaker_Damaged_OneOff'
     NPCName="Breaker Box"
     bStartActive=False
     BaseAIThreatRating=0.010000
     NotThreateningTo(0)=Class'KFChar.ZombieFleshPound'
     NotThreateningTo(1)=Class'KFChar.ZombieScrake'
     FriendlyFireDamageScale=0.000000
     bShowHealthBar=True
     NPCHealth=200.000000
     StartingHealthPct=0.000000
     ProjectileBloodSplatClass=None
     StaticMesh=StaticMesh'Props_ObjectiveMode.Breaker_Box'
     DrawScale=0.500000
     PrePivot=(Z=30.000000)
     Skins(0)=None
     CollisionRadius=30.000000
}
