//=============================================================================
// DwarfAxeFire
//=============================================================================
// Dwarf Axe primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DwarfAxeFire extends KFMeleeFire;

var()   array<name>     FireAnims;
var     float           MomentumTransfer;         // Momentum magnitude imparted by impacting weapon.
var()	InterpCurve     AppliedMomentumCurve;     // How much momentum to apply to a zed based on how much mass it has

simulated event ModeDoFire()
{
    local int AnimToPlay;

    if(FireAnims.length > 0)
    {
        AnimToPlay = rand(FireAnims.length);
        FireAnim = FireAnims[AnimToPlay];
    }

    Super.ModeDoFire();

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
	local float AppliedMomentum;

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

                dir = Normal((HitActor.Location + KFMonster(HitActor).EyePosition()) - Instigator.Location);
                AppliedMomentum = InterpCurveEval(AppliedMomentumCurve,HitActor.Mass);

                HitActor.TakeDamage(MyDamage, Instigator, HitLocation, dir * AppliedMomentum, hitDamageClass) ;

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
				HitActor.TakeDamage(MyDamage, Instigator, HitLocation, Normal(vector(PointRot)) * MomentumTransfer, hitDamageClass) ;
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

                    if( VictimDist > (((weaponRange * 1.1) * (weaponRange * 1.1)) + (Victims.CollisionRadius * Victims.CollisionRadius)) )
                    {
                        continue;
                    }

    	  			lookdir = Normal(Vector(Instigator.GetViewRotation()));
    				dir = Normal(Victims.Location - Instigator.Location);

    	           	DiffAngle = lookdir dot dir;

    	           	dir = Normal((Victims.Location + Victims.EyePosition()) - Instigator.Location);

    	           	if( DiffAngle > WideDamageMinHitAngle )
    	           	{
                        AppliedMomentum = InterpCurveEval(AppliedMomentumCurve,Victims.Mass);

    	           		//log("Shot would hit "$Victims$" DiffAngle = "$DiffAngle$" for damage of: "$(MyDamage*DiffAngle));
    	           		Victims.TakeDamage(MyDamage*DiffAngle, Instigator, (Victims.Location + Victims.CollisionHeight * vect(0,0,0.7)), dir * AppliedMomentum, hitDamageClass) ;

                    	if(MeleeHitSounds.Length > 0)
                    	{
                    		Victims.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)],SLOT_None,MeleeHitVolume,,,,false);
                    	}
    	           	}
    //	           	else
    //	           	{
    //                    log("Shot would miss "$Victims$" DiffAngle = "$DiffAngle);
    //	           	}
    			}
    		}
		}
	}
}

defaultproperties
{
     FireAnims(0)="Fire"
     FireAnims(1)="Fire2"
     FireAnims(2)="fire3"
     FireAnims(3)="Fire4"
     MomentumTransfer=250000.000000
     AppliedMomentumCurve=(Points=((OutVal=10000.000000),(InVal=350.000000,OutVal=175000.000000),(InVal=600.000000,OutVal=250000.000000)))
     MeleeDamage=235
     ProxySize=0.150000
     weaponRange=90.000000
     DamagedelayMin=0.790000
     DamagedelayMax=0.790000
     hitDamageClass=Class'KFMod.DamTypeDwarfAxe'
     MeleeHitSounds(0)=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
     HitEffectClass=Class'KFMod.AxeHitEffect'
     WideDamageMinHitAngle=0.600000
     FireRate=1.400000
     BotRefireRate=1.000000
}
