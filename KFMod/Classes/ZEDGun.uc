//=============================================================================
// ZedGun
//=============================================================================
// Zed Eradication Device: ZEDGun- Horzine Prototype Weapon
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDGun extends KFWeapon;

// Motion Detector vars
var	ScriptedTexture	ScriptedScreen;
var	Shader			ShadedScreen;
var	Material		ScriptedScreenBack;
var	color			ScreenBackgroundColor;
var	texture			ScreenWeakEnemyTexture;
var	texture			ScreenMediumEnemyTexture;
var	texture			ScreenStrongEnemyTexture;
var	texture			ScreenBossEnemyTexture;
var float           EnemyUpdateTime;

var		string ScriptedScreenBackRef;
var		string ScreenWeakEnemyTextureRef;
var		string ScreenMediumEnemyTextureRef;
var		string ScreenStrongEnemyTextureRef;
var		string ScreenBossEnemyTextureRef;

// Laser site vars
var         LaserDot                    Spot;                       // The first person laser site dot
var()       float                       SpotProjectorPullback;      // Amount to pull back the laser dot projector from the hit location
var         LaserBeamEffectZED          LaserBeam;                  // Third person laser beam effect

var()		class<InventoryAttachment>	LaserAttachmentClass;      // First person laser attachment class
var 		Actor 						LaserAttachment;           // First person laser attachment

var()   sound   AlarmSound;      // An alarm that sounds when big guys get near
var     float   NextAlarmTime;   // The next time this alarm goes off

replication
{
	reliable if(Role == ROLE_Authority)
		ClientAlarmSound;
}

//=============================================================================
// Functions
//=============================================================================

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	super.PreloadAssets(Inv, bSkipRefCount);

	default.ScriptedScreenBack = Material(DynamicLoadObject(default.ScriptedScreenBackRef, class'Material', true));
	default.ScreenWeakEnemyTexture = texture(DynamicLoadObject(default.ScreenWeakEnemyTextureRef, class'texture', true));
	default.ScreenMediumEnemyTexture = texture(DynamicLoadObject(default.ScreenMediumEnemyTextureRef, class'texture', true));
	default.ScreenStrongEnemyTexture = texture(DynamicLoadObject(default.ScreenStrongEnemyTextureRef, class'texture', true));
	default.ScreenBossEnemyTexture = texture(DynamicLoadObject(default.ScreenBossEnemyTextureRef, class'texture', true));

	if ( ZEDGun(Inv) != none )
	{
		ZEDGun(Inv).ScriptedScreenBack = default.ScriptedScreenBack;
		ZEDGun(Inv).ScreenWeakEnemyTexture = default.ScreenWeakEnemyTexture;
		ZEDGun(Inv).ScreenMediumEnemyTexture = default.ScreenMediumEnemyTexture;
		ZEDGun(Inv).ScreenStrongEnemyTexture = default.ScreenStrongEnemyTexture;
		ZEDGun(Inv).ScreenBossEnemyTexture = default.ScreenBossEnemyTexture;
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		if (LaserBeam == None)
		{
			LaserBeam = Spawn(class'LaserBeamEffectZED');
		}
	}
}

// Returns the location of the first person alt fire stun/zap beam start
simulated function vector GetFirstPersonBeamFireStart()
{
    local vector StartTrace, StartProj;
    local vector X,Y,Z;

    GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = StartTrace + X* ZEDGunAltFire(FireMode[1]).ProjSpawnOffset.X;
    StartProj = StartProj + Hand * Y * ZEDGunAltFire(FireMode[1]).ProjSpawnOffset.Y + Z * ZEDGunAltFire(FireMode[1]).ProjSpawnOffset.Z;

    return StartProj;
}

simulated function WeaponTick(float dt)
{
	local int TeamIndex, i;
	local Pawn EnemyPawn;
	local KFPlayerController KFPC;
    local array<vector> EnemyPawnLocations;
	local Vector StartTrace, EndTrace, X,Y,Z;
	local Vector HitLocation, HitNormal;
	local Actor Other;
	local vector MyEndBeamEffect;
	local coords C;
	local float MaxThreat, HighestThreatDist;
	local float UsedAlarmTime;

	super.WeaponTick(dt);

	if( Role == ROLE_Authority && LaserBeam != none )
	{
		if( bIsReloading && WeaponAttachment(ThirdPersonActor) != none )
		{
			C = WeaponAttachment(ThirdPersonActor).GetBoneCoords('tip');
			X = C.XAxis;
			Y = C.YAxis;
			Z = C.ZAxis;
		}
		else
		{
			GetViewAxes(X,Y,Z);
		}

		// the to-hit trace always starts right in front of the eye
		StartTrace = GetFirstPersonBeamFireStart();//Instigator.Location + Instigator.EyePosition() + X*Instigator.CollisionRadius;

		EndTrace = StartTrace + 65535 * X;

		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (Other != None && Other != Instigator && Other.Base != Instigator )
		{
			MyEndBeamEffect = HitLocation;
		}
		else
		{
			MyEndBeamEffect = EndTrace;
		}

		LaserBeam.EndBeamEffect = MyEndBeamEffect;
		LaserBeam.EffectHitNormal = HitNormal;
	}

	if( ScriptedScreen==None )
		InitMaterials();
	ScriptedScreen.Revision++;
	if( ScriptedScreen.Revision>10 )
		ScriptedScreen.Revision = 1;

	// Update the motion tracker screen
    if ( ROLE == ROLE_Authority && Instigator != none )
	{
		if( EnemyUpdateTime <= 0 )
		{
            EnemyUpdateTime = 0.2;

            TeamIndex = Instigator.GetTeamNum();

        	KFPC = KFPlayerController(Instigator.Controller);
        	if ( KFPC != none  )
            {
        		foreach Instigator.CollidingActors(class'Pawn', EnemyPawn, 1875)
        		{
        			if ( EnemyPawn.Health > 0 && EnemyPawn.GetTeamNum() != TeamIndex )
        			{
        				EnemyPawnLocations[i] = EnemyPawn.Location;
        				// Set the Z location to threat level so we can use that on the client
                        if( KFMonster(EnemyPawn) != none )
        				{
        				    EnemyPawnLocations[i].Z = KFMonster(EnemyPawn).MotionDetectorThreat * 1000;

        				    if( KFMonster(EnemyPawn).MotionDetectorThreat > MaxThreat ||
                                (KFMonster(EnemyPawn).MotionDetectorThreat >= 3.0 && (VSize(EnemyPawn.Location - Instigator.Location) < HighestThreatDist)) )
        				    {
        				        HighestThreatDist = VSize( EnemyPawn.Location - Instigator.Location );
                                MaxThreat = KFMonster(EnemyPawn).MotionDetectorThreat;

        				    }
        				}
        				else
        				{
        				    EnemyPawnLocations[i].Z = 0;
        				}
        				i+=1;
        			}
        		}

                // Update the locations
        		for ( i = 0; i < 16; i++ )
        		{
                    if( i < EnemyPawnLocations.Length )
                    {
                        KFPC.EnemyLocation[i] = EnemyPawnLocations[i];
                    }
                    else
        			{
                        KFPC.EnemyLocation[i] = vect(0,0,0);
        			}
                }

                if( MaxThreat >= 3.0 )
                {
            		UsedAlarmTime = Level.TimeSeconds - NextAlarmTime;

                    if( UsedAlarmTime >= 0 )
            		{
                        if( HighestThreatDist < 500 )
                        {
                            if( MaxThreat >= 5.0 )
                            {
                                NextAlarmTime = Level.TimeSeconds + 0.5;
                            }
                            else
                            {
                                NextAlarmTime = Level.TimeSeconds + 1.0;
                            }
                        }
                        else
                        {
                            NextAlarmTime = Level.TimeSeconds + 2.0;
                        }

                        if( Level.NetMode == NM_DedicatedServer )
                        {
                            ClientAlarmSound();
                        }
                        PlayOwnedSound(AlarmSound,SLOT_None,2.0,,TransientSoundRadius,,false);
                    }
                }
    		}
		}
		else
		{
            EnemyUpdateTime -= dt;
		}
	}
}

simulated function ClientAlarmSound()
{
    PlayOwnedSound(AlarmSound,SLOT_None,2.0,,TransientSoundRadius,,false);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (Role == ROLE_Authority)
	{
		if (LaserBeam == None)
		{
			LaserBeam = Spawn(class'LaserBeamEffectZED');
		}
	}

	EnableLaser();
}

simulated function DetachFromPawn(Pawn P)
{
	TurnOffLaser();

	Super.DetachFromPawn(P);

	if (LaserBeam != None)
	{
		LaserBeam.Destroy();
	}
}

simulated function bool PutDown()
{
	if (LaserBeam != None)
	{
		LaserBeam.Destroy();
	}

	TurnOffLaser();

	return super.PutDown();
}

// Toggle the laser on and off
simulated function EnableLaser()
{
	if( Instigator.IsLocallyControlled() )
	{
		if( Role < ROLE_Authority  )
		{
			ServerSetLaserActive(true);
		}

		if( LaserBeam != none )
		{
			LaserBeam.SetActive(true);
		}

		if ( LaserAttachment == none )
		{
			LaserAttachment = Spawn(LaserAttachmentClass,,,,);
			AttachToBone(LaserAttachment,LaserAttachment.AttachmentBone); //'Laser_Bone'
		}
		LaserAttachment.bHidden = false;

		if (Spot == None)
		{
			Spot = Spawn(class'LaserDotZED', self);
		}
	}
}

simulated function TurnOffLaser()
{
	if( Instigator.IsLocallyControlled() )
	{
		if( Role < ROLE_Authority  )
		{
			ServerSetLaserActive(false);
		}

		//bLaserActive = false;
		LaserAttachment.bHidden = true;

		if( LaserBeam != none )
		{
			LaserBeam.SetActive(false);
		}

		if (Spot != None)
		{
			Spot.Destroy();
		}
	}
}

// Set the new fire mode on the server
function ServerSetLaserActive(bool bNewWaitForRelease)
{
	if( LaserBeam != none )
	{
		LaserBeam.SetActive(bNewWaitForRelease);
	}

	if( bNewWaitForRelease )
	{
		//bLaserActive = true;
		if (Spot == None)
		{
			Spot = Spawn(class'LaserDotZED', self);
		}
	}
	else
	{
		//bLaserActive = false;
		if (Spot != None)
		{
			Spot.Destroy();
		}
	}
}

simulated event RenderOverlays( Canvas Canvas )
{
	local int m;
	local Vector StartTrace, EndTrace;
	local Vector HitLocation, HitNormal;
	local Actor Other;
	local vector X,Y,Z;
	local coords C;

	if (Instigator == None)
		return;

	if ( Instigator.Controller != None )
		Hand = Instigator.Controller.Handedness;

	if ((Hand < -1.0) || (Hand > 1.0))
		return;

	// draw muzzleflashes/smoke for all fire modes so idle state won't
	// cause emitters to just disappear
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m] != None)
		{
			FireMode[m].DrawMuzzleFlash(Canvas);
		}
	}

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
	SetRotation( Instigator.GetViewRotation() + ZoomRotInterp);

	// Handle drawing the laser beam dot
	if (Spot != None)
	{
		StartTrace = GetFirstPersonBeamFireStart();//Instigator.Location + Instigator.EyePosition();
		GetViewAxes(X, Y, Z);

		if( bIsReloading && Instigator.IsLocallyControlled() )
		{
			C = GetBoneCoords('Tip2');
			X = C.XAxis;
			Y = C.YAxis;
			Z = C.ZAxis;
		}

		EndTrace = StartTrace + 65535 * X;

		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (Other != None && Other != Instigator && Other.Base != Instigator )
		{
			EndBeamEffect = HitLocation;
		}
		else
		{
			EndBeamEffect = EndTrace;
		}

		Spot.SetLocation(EndBeamEffect - X*SpotProjectorPullback);

		if(  Pawn(Other) != none )
		{
			Spot.SetRotation(Rotator(X));
			Spot.SetDrawScale(Spot.default.DrawScale * 0.5);
		}
		else if( HitNormal == vect(0,0,0) )
		{
			Spot.SetRotation(Rotator(-X));
			Spot.SetDrawScale(Spot.default.DrawScale);
		}
		else
		{
			Spot.SetRotation(Rotator(-HitNormal));
			Spot.SetDrawScale(Spot.default.DrawScale);
		}
	}

	//PreDrawFPWeapon();	// Laurent -- Hook to override things before render (like rotation if using a staticmesh)

	bDrawingFirstPerson = true;
	Canvas.DrawActor(self, false, false, DisplayFOV);
	bDrawingFirstPerson = false;
}


simulated function InitMaterials()
{
	if ( ScriptedScreen == none )
	{
		ScriptedScreen = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
		ScriptedScreen.SetSize(512,512);
		ScriptedScreen.FallBackMaterial = ScriptedScreenBack;
		ScriptedScreen.Client = self;
	}

	if ( ShadedScreen == none )
	{
		ShadedScreen = Shader(Level.ObjectPool.AllocateObject(class'Shader'));
		ShadedScreen.Diffuse = ScriptedScreen;
		ShadedScreen.SelfIllumination = ScriptedScreen;
		skins[1] = ShadedScreen;
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	local KFPlayerController KFPC;
	local rotator KFPCRotation, EnemyRotation;
	local vector EnemyLocation;
	local int i;
	local float Threat;
	local color ScreenEnemyColor;
    local texture ScreenEnemyTexture;

    Tex.DrawTile(0, 0, Tex.USize, Tex.VSize, 0, 0, 512, 512, ScriptedScreenBack, ScreenBackgroundColor); // Draws the tile background

	KFPC = KFPlayerController(Instigator.Controller);
	if ( KFPC != none && KFPC.Pawn != none )
	{
		KFPCRotation.Yaw = KFPC.Rotation.Yaw;

		for ( i = 0; i < 16; i++ )
		{
			if ( KFPC.EnemyLocation[i].X != 0.0 || KFPC.EnemyLocation[i].Y != 0.0 )
			{
				// Decompress the threat level of this monster
                Threat = KFPC.EnemyLocation[i].Z/1000;
                if( Threat < 1.0 )
                {
                    ScreenEnemyTexture = ScreenWeakEnemyTexture;
                }
                else if( Threat <= 2.0 )
                {
                    ScreenEnemyTexture = ScreenMediumEnemyTexture;
                }
                else if( Threat <= 5.0 )
                {
                    ScreenEnemyTexture = ScreenStrongEnemyTexture;
                }
                else
                {
                    ScreenEnemyTexture = ScreenBossEnemyTexture;
                }

                ScreenEnemyColor = class'HUD'.default.WhiteColor;

                EnemyLocation = (KFPC.EnemyLocation[i] - KFPC.Pawn.Location) / 2500;
				EnemyLocation.Z = 0;

				EnemyRotation.Yaw = rotator(EnemyLocation).Yaw + 16384;

				EnemyLocation.X = VSize(EnemyLocation);
				EnemyLocation.Y = 0;

				EnemyLocation = (EnemyLocation * 768) >> (EnemyRotation - KFPCRotation);

				Tex.DrawTile(256 - EnemyLocation.X - (ScreenEnemyTexture.USize / 2), 512 - EnemyLocation.Y - (ScreenEnemyTexture.VSize / 2), ScreenEnemyTexture.USize, ScreenEnemyTexture.VSize, 0, 0, ScreenEnemyTexture.USize, ScreenEnemyTexture.VSize, ScreenEnemyTexture, ScreenEnemyColor);
			}
		}
	}
}

simulated function Destroyed()
{
	if (Spot != None)
		Spot.Destroy();

	if (LaserBeam != None)
		LaserBeam.Destroy();

	if (LaserAttachment != None)
		LaserAttachment.Destroy();

    super.Destroyed();

	if ( ScriptedScreen != none )
	{
		ScriptedScreen.SetSize(512,512);
		ScriptedScreen.FallBackMaterial = none;
		ScriptedScreen.Client = none;
		Level.ObjectPool.FreeObject(ScriptedScreen);
		ScriptedScreen = none;
	}

	if ( ShadedScreen != none )
	{
		ShadedScreen.Diffuse = none;
		ShadedScreen.Opacity = none;
		ShadedScreen.SelfIllumination = none;
		ShadedScreen.SelfIlluminationMask = none;
		Level.ObjectPool.FreeObject(ShadedScreen);
		ShadedScreen = none;
		skins[1] = none;
	}
}

// Destroy this stuff when the level changes
simulated function PreTravelCleanUp()
{
	if ( ScriptedScreen != none )
	{
		ScriptedScreen.SetSize(512,512);
		ScriptedScreen.FallBackMaterial = none;
		ScriptedScreen.Client = none;
		Level.ObjectPool.FreeObject(ScriptedScreen);
		ScriptedScreen = none;
	}

	if ( ShadedScreen != none )
	{
		ShadedScreen.Diffuse = none;
		ShadedScreen.Opacity = none;
		ShadedScreen.SelfIllumination = none;
		ShadedScreen.SelfIlluminationMask = none;
		Level.ObjectPool.FreeObject(ShadedScreen);
		ShadedScreen = none;
		skins[1] = none;
	}
}

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

simulated function AnimEnd(int channel)
{
    if (FireMode[1].bIsFiring )
    {
    	LoopAnim('ChargeLoop');
    }
    else
    {
        Super.AnimEnd(channel);
    }
}

// Allow this weapon to auto reload on alt fire
simulated function AltFire(float F)
{
	if( MagAmmoRemaining < 1 && !bIsReloading &&
		 FireMode[1].NextFireTime <= Level.TimeSeconds )
	{
		// We're dry, ask the server to autoreload
		ServerRequestAutoReload();

		PlayOwnedSound(FireMode[1].NoAmmoSound,SLOT_None,2.0,,,,false);
	}

	super.AltFire(F);
}

simulated event StopFire(int Mode)
{
	if ( FireMode[Mode].bIsFiring )
	    FireMode[Mode].bInstantStop = true;
	// Handle playing fire end in the altfire class for this mode
    if (Instigator.IsLocallyControlled() && !FireMode[Mode].bFireOnRelease
        && Mode != 1 )
        FireMode[Mode].PlayFireEnd();

    FireMode[Mode].bIsFiring = false;
    FireMode[Mode].StopFiring();
    if (!FireMode[Mode].bFireOnRelease)
        ZeroFlashCount(Mode);
}

defaultproperties
{
     ScreenBackgroundColor=(B=255,G=255,R=255,A=255)
     ScriptedScreenBackRef="KFZED_FX_T.Screen.ZED_FX_Screen_BG_CMB"
     ScreenWeakEnemyTextureRef="KFZED_FX_T.Screen.Low_Zed_Head"
     ScreenMediumEnemyTextureRef="KFZED_FX_T.Screen.Mid_Zed_Head"
     ScreenStrongEnemyTextureRef="KFZED_FX_T.Screen.Strong_Zed_Head"
     ScreenBossEnemyTextureRef="KFZED_FX_T.Screen.Boss_Zed_Head"
     SpotProjectorPullback=1.000000
     LaserAttachmentClass=Class'KFMod.LaserAttachmentFirstPersonZEDGun'
     AlarmSound=Sound'KF_ZEDGunSnd.Handling.KF_WEP_ZED_Alert'
     MagCapacity=100
     ReloadRate=3.500000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Zed"
     Weight=8.000000
     bHasAimingMode=True
     IdleAimAnim="Idle"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     SleeveNum=2
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_ZEDGun'
     bIsTier3Weapon=True
     MeshRef="KF_Wep_ZEDGun.ZEDGun_Trip"
     SkinRefs(0)="Kf_Weapons9_Trip_T.Weapons.ZED_cmb"
     SelectSoundRef="KF_ZEDGunSnd.KF_WEP_ZED_Handling_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.ZEDGun_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.ZEDGun"
     UnlockedByAchievement=202
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=45.000000
     FireModeClass(0)=Class'KFMod.ZEDGunFire'
     FireModeClass(1)=Class'KFMod.ZEDGunAltFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.650000
     Description="The Zed Eradication Device (ZED gun to its friends) is Horzine's first real ray-gun. When it doesn't explode them, it'll actually slow them down!"
     DisplayFOV=65.000000
     Priority=205
     InventoryGroup=4
     GroupOffset=15
     PickupClass=Class'KFMod.ZEDGunPickup'
     PlayerViewOffset=(X=18.000000,Y=20.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.ZEDGunAttachment'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="Zed Eradication Device"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
}
