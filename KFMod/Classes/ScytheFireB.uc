//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ScytheFireB extends KFMeleeFire;

var float WideDamageMinHitAngle;

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

	           	if( DiffAngle > WideDamageMinHitAngle )
	           	{
	           		//log("Shot would hit "$Victims$" DiffAngle = "$DiffAngle$" for damage of: "$(MyDamage*DiffAngle));
	           		Victims.TakeDamage(MyDamage*DiffAngle, Instigator, (Victims.Location + Victims.CollisionHeight * vect(0,0,0.7)), vector(PointRot), hitDamageClass) ;

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

defaultproperties
{
     WideDamageMinHitAngle=0.600000
     MeleeDamage=330
     ProxySize=0.150000
     weaponRange=105.000000
     DamagedelayMin=0.950000
     DamagedelayMax=0.950000
     hitDamageClass=Class'KFMod.DamTypeScythe'
     MeleeHitSounds(0)=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
     HitEffectClass=Class'KFMod.ScytheHitEffect'
     bWaitForRelease=True
     FireAnim="PowerAttack"
     FireRate=1.500000
     BotRefireRate=0.850000
}
