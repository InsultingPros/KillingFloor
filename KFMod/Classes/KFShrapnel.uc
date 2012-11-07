// This is the Shrapnel projectile used with High explosives like the landmines and the Frag grenade.

class KFShrapnel extends FlakChunk;

var () float VelocityDecayAmount; // How much speed does the shrapnel lose in one second

var float MinSpeed;

var float GlowTime;
var float SpawnTime;

simulated function PostBeginPlay()
{
    local float r;

    if ( Level.NetMode != NM_DedicatedServer )
    {
        if ( !PhysicsVolume.bWaterVolume )
        {
            Trail = Spawn(class'KFTracer',self);
            Trail.Lifespan = GlowTime;
        }

    }

    Velocity = Vector(Rotation) * (Speed);
    if (PhysicsVolume.bWaterVolume)
        Velocity *= 0.65;

    r = FRand();
    if (r > 0.75)
        Bounces = 2;
    else if (r > 0.25)
        Bounces = 1;
    else
        Bounces = 0;

    SetRotation(RotRand());

    SpawnTime=level.TimeSeconds;

    super(projectile).PostBeginPlay();
}

function Tick( float DeltaTime )
{
 local Vector NewVelocity; //, OriginalVelocity;
 /*
 OriginalVelocity = Velocity;
 NewVelocity = Velocity;
 NewVelocity.X /= VelocityDecayAmount;          // -984
 NewVelocity.Y /= VelocityDecayAmount;         // -6.7
 //if (Velocity.Z > (OriginalVelocity.Z * 5))   // 2298
  NewVelocity.Z /= (-VelocityDecayAmount * 1.5);
 Velocity = NewVelocity;
 VelocityDecayAmount *= 1.5;
 */

 AmbientGlow=default.AmbientGlow* FClamp((GlowTime-(level.timeseconds-spawntime))/GlowTime, 0,1);

 NewVelocity = Velocity;

 // dirty hack to prevent drag overwhelming gravity
 if(vsize(velocity) > MinSpeed) //vsize(PhysicsVolume.Gravity*0.5))
 {
   NewVelocity -= (Normal(Velocity)*VelocityDecayAmount*deltaTime);
   NewVelocity += PhysicsVolume.Gravity*0.5*deltaTime;
 }
 else
 {
   NewVelocity = Normal(Velocity)*MinSpeed;
   Disable('Tick');
   AmbientGlow = 0;
 }

 Velocity = NewVelocity;
}

defaultproperties
{
     VelocityDecayAmount=3500.000000
     MinSpeed=300.000000
     GlowTime=0.800000
     Speed=3500.000000
     MaxSpeed=4000.000000
     Damage=25.000000
     MyDamageType=Class'KFMod.DamTypeFrag'
     DrawScale=5.000000
     AmbientGlow=40
}
