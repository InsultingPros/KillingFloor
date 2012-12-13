// KFMeleeFire
class KFMeleeFire extends WeaponFire;

var() int MeleeDamage;

var float ProxySize;

var int NumConHits; // Number of successful strikes before a combo.
var bool bComboTime; // Are we combo-ing?
var int LastComboStartTime;
var int LastConHitTime;
var float ComboConDecay;

var float StopFireTime;
var float f;
var float StartFireTime;

var int dmg;
var int i;

var Name IdleAnim;
var float IdleAnimRate;
var() float weaponRange;

var() float DamagedelayMin;
var float DamagedelayMax;

var bool bCanHit ;
var Vector EndTraceS;

var class<damageType> hitDamageClass;

var() vector ImpactShakeRotMag;		   // how far to rot view
var() vector ImpactShakeRotRate;		  // how fast to rot view
var() float  ImpactShakeRotTime;		  // how much time to rot the instigator's view
var() vector ImpactShakeOffsetMag;		// max view offset vertically
var() vector ImpactShakeOffsetRate;	   // how fast to offset view vertically
var() float  ImpactShakeOffsetTime;	   // how much time to offset view

var Vector SpawnTrace;
var Bool bTrigger;
var Actor SpawnActor;

var     array<sound>    MeleeHitSounds; // Sound for this melee strike hitting a pawn (fleshy hits)
var()	float			MeleeHitVolume;

var class<KFMeleeHitEffect> HitEffectClass; // The class to spawn for the hit effect for this melee weapon hitting the world (not pawns)

var		string			FireSoundRef;
var		string			ReloadSoundRef;
var		string			NoAmmoSoundRef;
var     array<string>	MeleeHitSoundRefs;

var float WideDamageMinHitAngle; // The angle to do sweeping strikes in front of the player. If zero do no strikes

static function PreloadAssets(optional KFMeleeFire Spawned)
{
	local int i;

	default.FireSound = sound(DynamicLoadObject(default.FireSoundRef, class'Sound', true));
	default.ReloadSound = sound(DynamicLoadObject(default.ReloadSoundRef, class'Sound', true));
	default.NoAmmoSound = sound(DynamicLoadObject(default.NoAmmoSoundRef, class'Sound', true));

	for ( i = 0; i < default.MeleeHitSoundRefs.Length; i++ )
	{
		default.MeleeHitSounds[i] = sound(DynamicLoadObject(default.MeleeHitSoundRefs[i], class'Sound', true));
	}

	if ( Spawned != none )
	{
		Spawned.FireSound = default.FireSound;
		Spawned.ReloadSound = default.ReloadSound;
		Spawned.NoAmmoSound = default.NoAmmoSound;

		for ( i = 0; i < default.MeleeHitSoundRefs.Length; i++ )
		{
			Spawned.MeleeHitSounds[i] = default.MeleeHitSounds[i];
		}
	}
}

static function bool UnloadAssets()
{
	local int i;

	default.FireSound = none;
	default.ReloadSound = none;
	default.NoAmmoSound = none;

	for ( i = 0; i < default.MeleeHitSoundRefs.Length; i++ )
	{
		default.MeleeHitSounds[i] = none;
	}

	return true;
}

simulated function PostBeginPlay()
{
	if ( FireSound == none )
	{
		PreloadAssets(self);
	}

	super.PostBeginPlay();
}

simulated function Timer()
{
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local rotator PointRot;
	local int MyDamage;
	local bool bBackStabbed;
	local Pawn Victims;
	local vector dir, lookdir;
	local float DiffAngle, VictimDist;

	MyDamage = MeleeDamage;

	If( !KFWeapon(Weapon).bNoHit )
	{
		MyDamage = MeleeDamage;
		StartTrace = Instigator.Location + Instigator.EyePosition();

		if( Instigator.Controller!=None && PlayerController(Instigator.Controller)==None && Instigator.Controller.Enemy!=None )
		{
        	PointRot = rotator(Instigator.Controller.Enemy.Location-StartTrace); // Give aimbot for bots.
        }
		else
        {
            PointRot = Instigator.GetViewRotation();
        }

		EndTrace = StartTrace + vector(PointRot)*weaponRange;
		HitActor = Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);

        //Instigator.ClearStayingDebugLines();
        //Instigator.DrawStayingDebugLine( StartTrace, EndTrace,0, 255, 0);

		if (HitActor!=None)
		{
			ImpactShakeView();

			if( HitActor.IsA('ExtendedZCollision') && HitActor.Base != none &&
                HitActor.Base.IsA('KFMonster') )
            {
                HitActor = HitActor.Base;
            }

			if ( (HitActor.IsA('KFMonster') || HitActor.IsA('KFHumanPawn')) && KFMeleeGun(Weapon).BloodyMaterial!=none )
			{
				Weapon.Skins[KFMeleeGun(Weapon).BloodSkinSwitchArray] = KFMeleeGun(Weapon).BloodyMaterial;
				Weapon.texture = Weapon.default.Texture;
			}
			if( Level.NetMode==NM_Client )
            {
                Return;
            }

			if( HitActor.IsA('Pawn') && !HitActor.IsA('Vehicle')
			 && (Normal(HitActor.Location-Instigator.Location) dot vector(HitActor.Rotation))>0 ) // Fixed in Balance Round 2
			{
				bBackStabbed = true;

				MyDamage*=2; // Backstab >:P
			}

			if( (KFMonster(HitActor)!=none) )
			{
			//	log(VSize(Instigator.Velocity));

				KFMonster(HitActor).bBackstabbed = bBackStabbed;

                HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;

            	if(MeleeHitSounds.Length > 0)
            	{
            		Weapon.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)],SLOT_None,MeleeHitVolume,,,,false);
            	}

				if(VSize(Instigator.Velocity) > 300 && KFMonster(HitActor).Mass <= Instigator.Mass)
				{
				    KFMonster(HitActor).FlipOver();
				}

			}
			else
			{
				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), hitDamageClass) ;
				Spawn(HitEffectClass,,, HitLocation, rotator(HitLocation - StartTrace));
				//if( KFWeaponAttachment(Weapon.ThirdPersonActor)!=None )
		        //  KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(HitActor,HitLocation,HitNormal);

		        //Weapon.IncrementFlashCount(ThisModeNum);
			}
		}

		if( WideDamageMinHitAngle > 0 )
		{
            foreach Weapon.VisibleCollidingActors( class 'Pawn', Victims, (weaponRange * 2), StartTrace ) //, RadiusHitLocation
    		{
                if( (HitActor != none && Victims == HitActor) || Victims.Health <= 0 )
                {
                    continue;
                }

            	if( Victims != Instigator )
    			{
    				VictimDist = VSizeSquared(Instigator.Location - Victims.Location);

                    //log("VictimDist = "$VictimDist$" Weaponrange = "$(weaponRange*Weaponrange));

                            //Instigator.ClearStayingDebugLines();
                    //Instigator.DrawStayingDebugLine( Instigator.Location, EndTrace,0, 255, 0);

                    if( VictimDist > (((weaponRange * 1.1) * (weaponRange * 1.1)) + (Victims.CollisionRadius * Victims.CollisionRadius)) )
                    {
                        continue;
                    }

    	  			lookdir = Normal(Vector(Instigator.GetViewRotation()));
    				dir = Normal(Victims.Location - Instigator.Location);

    	           	DiffAngle = lookdir dot dir;

    	           	if( DiffAngle > WideDamageMinHitAngle )
    	           	{
    	           		//Instigator.DrawStayingDebugLine( Victims.Location + vect(0,0,10), Instigator.Location,255, 0, 0);
                        //log("Shot would hit "$Victims$" DiffAngle = "$DiffAngle$" WideDamageMinHitAngle = "$WideDamageMinHitAngle$" for damage of: "$(MyDamage*DiffAngle));
    	           		Victims.TakeDamage(MyDamage*DiffAngle, Instigator, (Victims.Location + Victims.CollisionHeight * vect(0,0,0.7)), vector(PointRot), hitDamageClass) ;

                    	if(MeleeHitSounds.Length > 0)
                    	{
                    		Victims.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)],SLOT_None,MeleeHitVolume,,,,false);
                    	}
    	           	}
    	           	//else
    	           	//{
                        //Instigator.DrawStayingDebugLine( Victims.Location, Instigator.Location,255, 255, 0);
                        //log("Shot would miss "$Victims$" DiffAngle = "$DiffAngle$" WideDamageMinHitAngle = "$WideDamageMinHitAngle);
    	           	//}
    			}
    		}
		}
	}
}

function float GetFireSpeed()
{
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		return KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetFireSpeedMod(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), Weapon);
	}

	return 1.0;
}
simulated event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	Rec = GetFireSpeed();
	SetTimer(DamagedelayMin/Rec, False);
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	ReloadAnimRate = default.ReloadAnimRate*Rec;

	if (MaxHoldTime > 0.0)
		HoldTime = FMin(HoldTime, MaxHoldTime);

	// server
	if (Weapon.Role == ROLE_Authority)
	{
		Weapon.ConsumeAmmo(ThisModeNum, Load);
		DoFireEffect();

		HoldTime = 0;   // if bot decides to stop firing, HoldTime must be reset first
		if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

		if ( AIController(Instigator.Controller) != None )
			AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

		Instigator.DeactivateSpawnProtection();
	}

	// client
	if (Instigator.IsLocallyControlled())
	{
		ShakeView();
		PlayFiring();
		FlashMuzzleFlash();
		StartMuzzleSmoke();
		ClientPlayForceFeedback(FireForce);
	}
	else // server
		ServerPlayFiring();

	Weapon.IncrementFlashCount(ThisModeNum);

	// set the next firing time. must be careful here so client and server do not get out of sync
	if (bFireOnRelease)
	{
		if (bIsFiring)
			NextFireTime += MaxHoldTime + FireRate;
		else
			NextFireTime = Level.TimeSeconds + FireRate;
	}
	else
	{
		NextFireTime += FireRate;
		NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
	}

	Load = AmmoPerFire;
	HoldTime = 0;

	if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
	{
		bIsFiring = false;
		Weapon.PutDown();
	}

    if( Weapon.Owner != none && Weapon.Owner.Physics != PHYS_Falling )
    {
        Weapon.Owner.Velocity.x *= KFMeleeGun(Weapon).ChopSlowRate;
        Weapon.Owner.Velocity.y *= KFMeleeGun(Weapon).ChopSlowRate;
    }
}

function DoFireEffect()
{
	local KFMeleeGun kf;
	local int damage ;

	if(KFMeleeGun(Weapon) == none)
		return;

	kf = KFMeleeGun(Weapon);
	damage = MeleeDamage;
}


simulated function ShakeView()
{
	local PlayerController P;

	if (Instigator == None)
		return;

	P = PlayerController(Instigator.Controller);
	if (P != None )
		P.WeaponShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime, ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
}

function SlowDown();

function SpeedUp();

function ResetRate();

function ImpactShakeView()
{
	local PlayerController P;

	P = PlayerController(Instigator.Controller);
	if ( P != None )
		P.WeaponShakeView(ImpactShakeRotMag, ImpactShakeRotRate, ImpactShakeRotTime,ImpactShakeOffsetMag,ImpactShakeOffsetRate,ImpactShakeOffsetTime);
}

defaultproperties
{
     ProxySize=0.200000
     IdleAnim="Idle"
     IdleAnimRate=1.000000
     weaponRange=70.000000
     DamagedelayMin=0.300000
     DamagedelayMax=0.400000
     hitDamageClass=Class'KFMod.DamTypeMelee'
     ImpactShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ImpactShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ImpactShakeRotTime=2.000000
     ImpactShakeOffsetMag=(X=10.000000,Y=10.000000,Z=10.000000)
     ImpactShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ImpactShakeOffsetTime=2.000000
     MeleeHitVolume=1.000000
     HitEffectClass=Class'KFMod.KFMeleeHitEffect'
     FireEndAnim=
     FireForce="ShockRifleFire"
     aimerror=100.000000
}
