class Claws extends KFMeleeGun;

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx

//var() Material ZoomMat;
//var color ChargeColor;
//var() float HealRate;
var int jabs;
var float jabTimer ;

//TODO - This smells, but I'm not sure what to do about it yet
//       Bigger fish first
function bool CanAttack(Actor Other)
{

  local float enemyDist;
  local Bot B;

  if(Bot(Instigator.Controller) != none)
  {
    B = Bot(Instigator.Controller);
    enemyDist = VSize(B.Enemy.Location - Instigator.Location);

    if (enemyDist < 110 )
    {
        return true;
    }
    else
      return false;
  }
  return true ;
}

/*

function TryHit(float hitMinTime, float hitMaxTime, int damage, class<damageType> hitDamageType, vector momentumOffset)
{
    super.TryHit(hitMinTime, hitMaxTime, damage, hitDamageType, momentumOffset) ;
    //log("Start timer at: "$level.timeSeconds$" min and max hit values: "$THMin$" "$THMax) ;
    jabTimer = THMin;
    jabs = 0 ;
}



simulated function Tick(float dt)
{
    local Actor Other;
    local Vector HitNormal, StartTrace, EndTrace, hitLocation ;
    local rotator Aim ;

     //log("zero") ;
    if ( (Level.NetMode == NM_Client) || Instigator == None || Instigator.PlayerReplicationInfo == None)
        return;

    // Experience related Weapon Skill


    if (Pawn(Owner).Controller != none)
    {
     FireMode[0].FireRate = (FireMode[0].default.FireRate - KFPlayerReplicationInfo(Pawn(Owner).Controller.PlayerReplicationInfo).ExperienceLevel * FireMode[0].default.FireRate* 0.05 );
     FireMode[0].FireAnimRate = (FireMode[0].default.FireAnimRate + KFPlayerReplicationInfo(Pawn(Owner).Controller.PlayerReplicationInfo).ExperienceLevel * FireMode[0].default.FireAnimRate* 0.05 );
    }






    if(Instigator.Weapon == self && Instigator.Health < Instigator.HealthMax)
    {
        HealAccum += HealRate*dt;
        if(HealAccum > 1)
        {
            Instigator.Health = Min(Instigator.HealthMax, Instigator.Health+HealAccum);

             HealAccum -= int(HealAccum);
        }
    }


    //log("one") ;
    if(jabs >= 2)
    {
        bCanHit = false ;
        jabs = 0 ;
    }

    if(bCanHit)
    {
        //log("two jabs: "$jabs) ;
        if((jabs == 0) && (jabTimer <= level.TimeSeconds))
        {
             //log("Hit enabled from"$THMin$" to "$THMax) ;
             btryHit = true ;
             jabTimer = THMax ;
        }
        else if((jabs == 1) && (jabTimer <= level.TimeSeconds))
            bTryHit = true ;
        else
            bTryHit = false ;

        if(btryHit)
        {
            jabs++ ;
            //log("TryHit, jab: "$jabs) ;
            StartTrace = Instigator.Location;
            Aim = FireMode[0].AdjustAim(StartTrace, FireMode[0].AimError);
            EndTrace = StartTrace + weaponRange * Vector(Aim);
            Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
            if (((Pawn(Other) != None) || (KActor(Other) != none)) && (Other != Instigator) )
            {
                HitObject = Other;
                //log("Successful hit: "$other$" at "$level.TimeSeconds$" hitting with "$dmg) ;
                if((KActor(Other) != none))
                    HitObject.TakeDamage(dmg, Instigator, HitLocation, (vector(Aim) + momOffset), hitDamType) ;
                else
                {
                    //HitObject.TakeDamage(dmg, Instigator, HitLocation, vect(0,0,0), hitDamType) ;
                    HitObject.TakeDamage(dmg, Instigator, HitLocation, (vector(Aim) + momOffset), hitDamType) ;
                    playServerSound() ;
                }
            }
        }
    }
}




simulated event RenderOverlays(Canvas Canvas)
{
	local PlayerController PC;

	PC = PlayerController(Instigator.Controller);

	if(PC == None)
		return;

	if (PC.DesiredFOV == PC.DefaultFOV || (Level.bClassicView && PC.DesiredFOV == 90))
	{
		Super.RenderOverlays(Canvas);
	}
	else
	{

		//Black-out either side of the main zoom circle.
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Texture'KillingFloorHUD.RedEyesSource', (Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);
		Canvas.SetPos(Canvas.SizeX, 0);
		Canvas.DrawTile(Texture'KillingFloorHUD.RedEyesSource', -(Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);

		//The view through the scope itself.
		Canvas.Style = 255;
		Canvas.SetPos((Canvas.SizeX - Canvas.SizeY) / 2,0);
		Canvas.DrawTile(ZoomMat, Canvas.SizeY, Canvas.SizeY, 0.0, 0.0, 512, 512);


	}
}



function RegenHealthZombie( float dt )
{
   if (Pawn(Other) != None && Pawn(Other).Health < Pawn(Other).HealthMax*2 )
       {
            Pawn(Other).Health = Min( Pawn(Other).Health+RegenPerSecond, Pawn(Other).HealthMax*2 );
        }
}
*/

defaultproperties
{
     weaponRange=55.000000
     FireModeClass(0)=Class'KFMod.ClawsFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     SelectForce="SwitchToFlakCannon"
     AIRating=0.450000
     CurrentRating=0.250000
     bCanThrow=False
     Description="Bloody and Sharp. Yikes! "
     EffectOffset=(X=100.000000,Y=32.000000,Z=-20.000000)
     DisplayFOV=85.000000
     Priority=1
     HudColor=(G=0)
     SmallViewOffset=(X=6.000000,Y=12.000000,Z=-50.000000)
     CenteredOffsetY=-5.000000
     CenteredRoll=3000
     CenteredYaw=-1500
     GroupOffset=2
     PickupClass=Class'KFMod.ClawsPickup'
     PlayerViewOffset=(X=1.000000,Y=9.500000,Z=-36.000000)
     PlayerViewPivot=(Pitch=5400)
     BobDamping=7.000000
     AttachmentClass=Class'KFMod.ClawsAttachment'
     IconCoords=(X1=169,Y1=78,X2=244,Y2=124)
     ItemName="Fists"
}
