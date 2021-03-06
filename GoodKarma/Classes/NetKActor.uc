//NetKActor as part of the GoodKarma package
//Build 134 Beta 4.5 Release
//By: Jonathan Zepp
//Original code based of the LawDogsKActor code available from unreal wiki (Thank You!)
//Though the current version has been SEVERELY modified, and modified some more.
//This is intended to add full server playability, and make karma a universal tool.
//Changes to bot pathing have also been made to put some sense into their empty heads...

class NetKActor extends KActor
	placeable;

#exec OBJ LOAD FILE="..\Sounds\WeaponSounds.uax"

//Edit in default properties in UnrealEd

var() bool bBlockedPath ;                   //Enables Basic bot-pathing
var() bool bCriticalObject ;                //Will Always function despite server physics detail (not fully functional)
var() float moveDistance ;                  //associated with bBlockedPath, how far the object must move for the bots to pass it
var() array<Sound> HitSounds ;              //A sound to play on impact
var() byte RelativeImpactVolume ;           //The relative sound volume of the hit sound
var() bool bShoveable ;                     //Can the object be shoved by a player?
var() name BlockedPath ;                    //The name of the associated blocked path
var() float ShoveModifier;                  //A multiplier to change how hard the object is shoved
var() bool bPuntable ;                      //Allows a NetKActor to be punted
var() int requiredPuntStrength ;            //A value which must be met by the actor calling the DeclarePunt function for a punt to be accepted
var() bool bEnableSpinProtection ;          //Overrides standard karma features to make shoving the object always work properly, not reccomended on all objects, especially long ones, unless they have trouble.
var() float hitSoundRepeatModifier ;        //How much more often will hit sounds play?

var(Damage) bool bCollisionDamage ;               //Enables damage when colliding with a player/vehicle/thing with health
var(Damage) float DamageSpeed ;                   //Minimum speed to deal damage
var(Damage) class<DamageType> HitDamageType ;     //Damage type associated with bCollisionDamage
var(Damage) float HitDamageScale ;                //Relative impact damage modifier
var(Damage) int initialHealth ;                   //The starting health of an object
var(Damage) int damageAbsorbtionAmount ;          //Absorbs this much damage off each hit.
var(Damage) bool limitDamagingClass ;             //Only allows the constrained class to deal damage (and push it around)
var(Damage) class<Weapon> DamageConstraintClass ; //The constraint class (only allowed class to damage it)

var(Destruction) int explodeDamage ;                   //When dieing, how much damage does it deal to its fragments/people near it
var(Destruction) float explodeRadius ;                 //How close does something have to be to be damaged when dieing
var(Destruction) int explodeForce ;                    //How hard does it push fragments and other objects when dieing
var(Destruction) bool bDestroyable ;                   //Does health and damage apply to this object?
var(Destruction) sound DestructionSound ;              //Sound played when the object is destroyed
var(Destruction) byte DestructionVolume ;              //Volume of the destruction sound
var(Destruction) class <Emitter> DestroyedEffect ;      //The effect created when the object is destroyed
var(Destruction) vector EffectOffset ;                 //Where the effect is in relation to the object when destroyed
var(Destruction) bool bOrientDestructionEffect ;       //Does the destruction effect have the same orientation as the hit which killed it?
var(Destruction) float DestroyedMass ;                 //What the mass is when destroyed
var(Destruction) float DestroyedDamping ;              //What the damping is when destroyed
var(Destruction) float DestroyedFriction ;             //What the friction is when destroyed
var(Destruction) float DestroyedBuoyancy ;             //What the buoyancy is when destroyed
var(Destruction) float DestroyedRestitution ;          //What the restitution is when destroyed
var(Destruction) StaticMesh DestroyedStaticMesh ;      //The static mesh used for the object after it is destroyed (anything but none enables the 5 destroyed karma changing values)

var(Respawning) float PreRespawnEffectTime ;          //How long before the object respawns will the respawn effect play?
var(Respawning) bool bRespawnEffect ;                 //Will a respawn effect play?
var(Respawning) class<emitter> RespawnEffect ;        //The effect spawned when the object respawns
var(Respawning) bool bInactivityReset ;               //Will the object reset automatically if moved and then idle?
var(Respawning) float inactivityTimeout ;             //How long of idleness will trigger an inactivity Reset?
var(Respawning) sound RespawnSound ;                  //Sound played when the object is respawned
var(Respawning) byte RespawnVolume ;                  //Volume of the respawning sound
var(Respawning) float AutoRespawnTime ;               //How long after it is destroyed does it wait to respawn on its own (-1 means it dosen't respawn)

//Internal

var vector startLocation ;
var KRigidBodyState KState, KRepState, initialKState;
var bool bPendingPunt, bPendingRespawn, bRespawnEffectPlayed, bInactive, bWaitTillMove, notifyPlayHit, bDead ;
var int StateCount, LastStateCount, Health ;
var actor Punter ;
var float PuntTimeout, respawnClock, inactiveClock, lastShoveTimer, replaySoundClock ;
var rotator startRotation, hitDirection ;
var float initialRest, initialFric, initialMass, initialDampLin, initialDampAng, initialBuoy ;
var StaticMesh initialMesh ;
var byte clientPlay ;                                 //0 for nothing, 1 for death emitters, 2 for respawn emitter

// shadow variables
var Projector Shadow;
var ShadowProjector PlayerShadow;
var globalconfig bool bBlobShadow;
var () bool bKActorShadows;

// ZOMG paint stains!
/*
var (Stains) bool bLeaveStains;
var (Stains) float StainStreakInterval;
var transient float LastStreakTime;
var (Stains) float StainSpeedThreshold;
*/
//var Actor LastTouchedActor;


var vector DieVect;
var vector lasthitlocation;
var pawn lastinstigatedby,LastStander;



replication
{
    reliable if(Role == ROLE_Authority)
        KRepState, StateCount, bDead, Health, hitDirection, clientPlay ;
    reliable if(Role == ROLE_Authority)
        clientDeathEmitters, clientRespawnEmitter ,DestroyedEffect;
    reliable if(bNetInitial)
        startRotation, startLocation ;
}

function PreBeginPlay()
{
    startLocation = Location ;
    startRotation = Rotation ;
    KGetRigidBodyState(initialKState) ;
    if(!bCriticalObject && Level.PhysicsDetailLevel == PDL_Low)
        SetPhysics(PHYS_None) ;
    initialRest = KParams.KRestitution ;
    initialFric = KParams.KFriction ;
    initialMass = (KarmaParams(KParams)).KMass ;
    initialDampLin = (KarmaParams(KParams)).KLinearDamping ;
    initialDampAng = (KarmaParams(KParams)).KAngularDamping ;
    initialBuoy = (KarmaParams(KParams)).KBuoyancy ;
    initialMesh = getObject(StaticMesh) ;
    respawn() ;
}

simulated function PostNetBeginPlay()
{

 if ( bKActorShadows == true)
 {

    PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
    PlayerShadow.ShadowActor = self;
    PlayerShadow.bBlobShadow = bBlobShadow;
    PlayerShadow.LightDirection = Normal(vect(1,1,3));
    PlayerShadow.LightDistance = 320;
    PlayerShadow.MaxTraceDistance = 350;
    PlayerShadow.InitShadow();

    PlayerShadow.bShadowActive = true;
 }

 // hardcode destruction effect to Material

 /*

 if (SurfaceType == EST_Metal)
 {
  DestroyedEffect = class'DoorExplodeMetalStandard';
  DestructionSound = Sound'PatchSounds.MetalCrash';
 }
 else
 if (SurfaceType == EST_Wood)
  DestroyedEffect = class'DoorExplodeWoodStandard';
 else
  DestroyedEffect = none;
  */


}

function respawn()
{
    setPhysics(PHYS_None) ;
    setLocation(StartLocation) ;
    setRotation(startRotation) ;
    SetStaticMesh(initialMesh) ;
    SetPhysics(PHYS_Karma) ;
    SetCollision(true, true, true) ;
    KSetMass(initialMass) ;
    KSetRestitution(initialRest) ;
    KSetDampingProps(initialDampLin, initialDampAng) ;
    KSetFriction(initialFric) ;
    (KarmaParams(KParams)).KBuoyancy = initialBuoy ;
    KRepState = initialKState ;
    Health = initialHealth ;
    bBlockedPath = default.bBlockedPath ;
    bPendingPunt = false ;
    bHidden = false ;
    bPendingRespawn = false ;
    if(bRespawnEffect && !bRespawnEffectPlayed)
        clientPlay = 2 ;
    bRespawnEffectPlayed = false ;
    bWaitTillMove = true ;
    inactiveClock = -999.0 ;
    bDead = false ;
    lastShoveTimer = 0.0 ;
    if(!((KarmaParams(KParams)).KStartEnabled))
    {
        KRepState.linVel = KRBVecFromVector(Vect(0,0,0)) ;
        KRepState.angVel = KRBVecFromVector(Vect(0,0,0)) ;
    }
    lastStateCount = StateCount ;
    //DEBUG
    //log("Respawn at "$Location$" Karma: "$KRBVecToVector(KRepState.Position)) ;
    //log(tag$" respawned at "$location$" and should be at "$startLocation) ;
}

function bool declarePunt(Actor newPunter, float maxTimeTo, bool bPriority, int Strength)
{
    if(!bPuntable)
        return false ;
    if(((Punter != none && PuntTimeout <= level.timeSeconds) || Punter == none  || bPriority) && Strength > RequiredPuntStrength)
    {
        Punter = newPunter ;
        PuntTimeout = level.timeSeconds + maxTimeTo ;
        bInactive = false ;
        return true ;
    }
    return false ;
}

simulated event Bump(Actor Other)
{
    local vector Shove;
    local int damage ;
    local float Speed;
    local class<damageType> damageTypeClass ;
  //  local KFBloodSplatter Streak;
   // local vector WallHit, WallNormal;
  //  local Actor WallActor;


    if(Pawn(Other) == None || Other.role != ROLE_Authority)
        return ;
    if(limitDamagingClass && (Other != DamageConstraintClass))
        return ;
    if(bShoveable == false)
        return ;
    if(lastShoveTimer > level.timeSeconds)
        return ;




    // no spinning wildly when people stand on you!
    if (pawn(Other) != none && pawn(Other).Base == self)
    {
     LastStander = pawn(Other);
     return;
    }


    if(!KIsAwake())
        KWake() ;



    damageTypeClass = class'DamTypeKick' ;
    damage = 3 ;



  /*
   if (bLeaveStains && Speed > StainSpeedThreshold)
        {
         StainStreakInterval -= (0.001 * VSize(Velocity));

        if (Other != none && Other.bWorldGeometry)
         WallActor = Trace(WallHit, WallNormal, Location + 50 * Velocity, Location, false);

         //Log(WallActor);

          if ( WallActor != None && Level.TimeSeconds > LastStreakTime + StainStreakInterval)
          {
             Streak= spawn(class 'KFMod.KFBloodSplatter',,,WallHit * (WallNormal + VRand()), rotator(-WallNormal));
            if (Streak != none)
             Streak.SetRotation(Rotator(Velocity));

             LastStreakTime = Level.TimeSeconds;
          }
        }
     */

    /*
    if (Other.IsA('KFHumanPawn'))
    {
     SetPhysics(PHYS_None);
     Other.attachtobone(self,'Bone_weapon');
    }
    */

    if(PuntTimeout >= level.timeSeconds && bPuntable)
    {
        if(Punter == Other)
        {
            damageTypeClass = class'DamTypePunt' ;
            damage = 9 ;
        }
    }
    else
        Punter = None ;

    Speed = VSize(Other.Velocity);
    Shove = (Normal(Other.Velocity) / (Mass * 0.4)) * ShoveModifier ;
    if(Other.Velocity.Z < -90.0)
        {
        Shove.Z *= 0.5 ;
        Shove.X *= 0.8 ;
        Shove.Y *= 0.8 ;
        }
    if(IsInWater(Other))
        {
        Shove.Z *= 0.75 ;
        Shove.X *= 0.5 ;
        Shove.Y *= 0.5 ;
        }
    if(shove.z == 0.0)
        shove.z = (1.6 / Mass) * 0.4 * ShoveModifier;
    if(bEnableSpinProtection)
        TakeDamage(damage, Pawn(Other), vect(0,0,0), Shove, damageTypeClass) ;
    else
        TakeDamage(damage, Pawn(Other), location, Shove, damageTypeClass) ;



    lastShoveTimer = level.timeSeconds + 0.1 ;
}

simulated event RanInto(Actor Other)
{
    local vector Momentum;
    local float Speed;

   // if (Other.bWorldGeometry)
   //  LastTouchedActor = Other;

    if(bCollisionDamage && Other != None && lastShoveTimer <= level.timeSeconds)
    {

       if ((Pawn(Other) == None) || (Vehicle(Other) != None) || Other == Instigator || Other.Role != ROLE_Authority)
            return;

        Speed = VSize(Velocity) ;

             //log(Velocity) ;

        if (Speed > DamageSpeed)
        {
            Momentum += Speed * 0.25 * Other.Mass * Normal(Velocity cross vect(0,0,1));
            Other.TakeDamage(int(Speed * 0.045 * HitDamageScale), Instigator, Other.Location, Momentum, HitDamageType);
            if(HitSounds.length != 0)
                notifyPlayHit = true ;
            //DEBUG
            //log(Tag$" injured "$Other.Tag$" dealing "$(int(Speed * 0.048 * HitDamageScale))$" Damage!") ;
            Velocity.z = Velocity.z * 0.45 ;
            if((Speed * 0.045 * HitDamageScale) >= 70)
                TakeDamage(3, instigator, Location, ((Velocity * -0.85) / (Mass + 1)), class'GoodKarma.DamTypeKick') ;
            else
                TakeDamage(7, instigator, Location, ((Velocity * -0.65) / (Mass + 1)), class'GoodKarma.DamTypeKick') ;
        }
        else if(Pawn(Other) != None)
                TakeDamage(4, instigator, Location, (Velocity * -1.03), class'GoodKarma.DamTypeKick') ;
        lastShoveTimer = level.TimeSeconds + 0.07 ;

        //log(Velocity) ;
    }

    //DEBUG
    //log(Tag$" is now moving at "$Velocity) ;
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    local vector ApplyImpulse;
    local Actor A;


    if(limitDamagingClass && (instigatedBy.Weapon != DamageConstraintClass))
        return ;

    lasthitlocation = hitlocation;
    lastinstigatedby = instigatedBy;

    // When shot, trigger self.
    TriggerEvent(Event, A, instigatedBy);

    Damage = Damage - DamageAbsorbtionAmount ;

    if(Damage < 0)
        Damage = 0 ;

    Health = Health - Damage ;

    if(Health <= 0 && bDestroyable && !bPendingRespawn)
        die() ;




    if(damageType.default.KDamageImpulse > 0)
    {
	if(VSize(momentum) < 0.001)
	{
	    return;
	}
	ApplyImpulse = Normal(momentum) * damageType.default.KDamageImpulse;
	//DEBUG
	//log("********************") ;
	//log(ApplyImpulse) ;
	KAddImpulse(ApplyImpulse, hitlocation) ;
    }
    hitDirection = rotator(momentum) ;
    //DEBUG
    //log("TakeDamage") ;
}

function bool IsInWater(Actor Other)
{
    local PhysicsVolume V;

    ForEach Other.TouchingActors(class'PhysicsVolume',V)
    {
        if(V.bWaterVolume == true)
            return true ;
    }
    return false;
}



simulated function KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
  Super.KImpact(Other,pos,impactVel,impactNorm);

  if (VSize(Velocity) != 0)
  {
   if(HitSounds.length != 0 )
    playServerHit();
  }
}




simulated function Tick(float Delta)
{
   local pawn Stander;

    if(clientPlay != 0)
    {
        switch(clientPlay)
        {
            case 1: clientDeathEmitters() ;
                    break ;
            case 2: clientRespawnEmitter() ;
                    break ;
            default:log("clientPlay invalid value") ;
        }
        clientPlay = 0 ;
    }
    PackState();
    if(bPendingRespawn && respawnClock <= level.timeSeconds)
        respawn() ;
    if(bPendingRespawn && bRespawnEffect && !bRespawnEffectPlayed && (level.timeSeconds >= (respawnClock - PreRespawnEffectTime)))
    {
        clientPlay = 2 ;
        playServerSoundRespawn() ;
        bRespawnEffectPlayed = true ;
    }
    if(bPendingDelete)
    {
        die() ;
        bPendingDelete = false ;
    }
    if(bInactive && bInactivityReset && !bWaitTillMove)
    {
        if(inactiveClock == -999.0)
            inactiveClock = inactivityTimeout + level.timeSeconds ;
        else if(inactiveClock <= level.timeSeconds)
        {
            //DEBUG
            //log(tag$" is pending inactivity respawn") ;
            bPendingRespawn = true ;
            respawnClock = level.TimeSeconds + 1.5 ;
            inactiveClock = -999.0 ;
        }
    }

    // If someone's standing on me, i can't go flying.

   if (VSize(Velocity) != 0)
   {
     foreach BasedActors( class 'pawn',Stander)
     {
       if (Stander != none)
       {
        //Log("I'm being stood on.  Halting movement");
        Velocity = vect(0,0,0);
       }
     }
   }

   // No super speeding objects

   if (Mass >= 0.5 && VSize(Velocity) > 100)
    Velocity *= 0.5;



}

//Pack current state to be replicated
function PackState()
{
    local bool bChanged;

    if(!KIsAwake())
    	return;

    KGetRigidBodyState(KState);

    bChanged = false ;
    bChanged = bChanged || VSize(KRBVecToVector(KState.Position) - KRBVecToVector(KRepState.Position)) > 2.5;
    bChanged = bChanged || VSize(KRBVecToVector(KState.LinVel) - KRBVecToVector(KRepState.LinVel)) > 0.5;
    bChanged = bChanged || VSize(KRBVecToVector(KState.AngVel) - KRBVecToVector(KRepState.AngVel)) > 0.5;

    if(bChanged)
    {
        KRepState = KState;
        StateCount++;

        if(bBlockedPath && stateCount > 1)                        //Does it need to trigger the blocked path?
        {
            if(VSize(startLocation - KRBVecToVector(KRepState.Position)) > moveDistance)
            {
                bBlockedPath=false ;
                TriggerEvent(BlockedPath, self, None) ;           //DO IT!
                //DEBUG
                log(Tag$" is "$VSize(startLocation - KRBVecToVector(KRepState.Position))$" units from its original position!") ;
            }
        }
        bInactive = false ;
        bWaitTillMove = false ;
    }
    else
    {
        bInactive = true ;
        return;
    }
}

simulated event PostNetReceive()
{
    if(StateCount == LastStateCount)
        return;
}

simulated event bool KUpdateState(out KRigidBodyState newState)
{
    if(StateCount == LastStateCount)
        return false;
    newState = KRepState;
    lastStateCount = StateCount ;
    return true;
}

/*
simulated function UsedBy( Pawn user )
{
  Log("I was just used...and I liked it");

  if (KFHumanPawn(user) != none)
  {
   SetPhysics(PHYS_None);
   user.AttachToBone( self, 'Bone_weapon' );
  }
}
*/


simulated function Die()
{
 DieVect = lasthitlocation-lastinstigatedBy.location;

     //DEBUG
    //log("Die at "$location) ;
    bDead = true ;
    if(bDestroyable)
    {
        playServerSoundDestroy() ;

        if ( EffectIsRelevant(Location,false) )
         spawn(DestroyedEffect,,,Location,rotator(DieVect) );

        ClientDeathEmitters();

        //DestroyedFX();
        HurtRadius(explodeDamage ,explodeRadius, class'DamTypeKick', explodeForce, Location) ;
        if(DestroyedStaticMesh == none)
        {
            bHidden = true ;
            SetPhysics(PHYS_None) ;
            SetCollision(false, false, false) ;
            Health = 0 ;
            Punter = none ;
            bPendingPunt = false ;
        }
        else
        {
             KWake() ;
             SetStaticMesh(DestroyedStaticMesh) ;
             KSetMass(DestroyedMass) ;
             KSetRestitution(DestroyedRestitution) ;
             KSetDampingProps(DestroyedDamping, DestroyedDamping) ;
             KSetFriction(DestroyedFriction) ;
             (KarmaParams(KParams)).KBuoyancy = DestroyedBuoyancy ;
             Health = 1 ;
        }
    }
    else
    {
        bHidden = true ;
        SetPhysics(PHYS_None) ;
        SetCollision(false, false, false) ;
        Health = 0 ;
        Punter = none ;
        bPendingPunt = false ;
    }
    if(AutoRespawnTime != -1)
    {
        bPendingRespawn = true ;
        respawnClock = level.timeseconds + AutoRespawnTime ;
        bInactive = false ;
    }
    clientPlay = 1 ;
}




function playServerSoundDestroy()
{
        PlaySound(DestructionSound, SLOT_None, DestructionVolume) ;
        //log("Server-SoundDestroy") ;
}

function playServerSoundRespawn()
{
        PlaySound(RespawnSound, SLOT_None, RespawnVolume) ;
        //log("Server-SoundRespawn") ;
}

function playServerHit()
{
        local int a ;
        local float b ;

        if(replaySoundClock <= level.TimeSeconds)
        {
            a = Rand(HitSounds.length) ;
            b = rand(4) * 0.1 ;
            PlaySound(HitSounds[a] , SLOT_None, RelativeImpactVolume);
            notifyPlayHit = false ;
            replaySoundClock = level.timeSeconds + ((0.55 + b) * hitSoundRepeatModifier) ;
        }
        //log("Server-SoundHit") ;
}

simulated event FellOutOfWorld(eKillZType KillType)
{Die() ;}

function StaticMesh getObject(StaticMesh A)
{ return A ;}

simulated function ClientDeathEmitters()
{
        if(level.NetMode != NM_DedicatedServer)
            return ;
        if(bOrientDestructionEffect)
            Spawn(DestroyedEffect,,,Location + EffectOffset, hitDirection) ;
        else
            Spawn(DestroyedEffect,,,Location + EffectOffset) ;
        //log("Client-EmittersDestroy") ;
}

simulated function ClientRespawnEmitter()
{
    if(level.NetMode != NM_DedicatedServer)
        return ;
    Spawn(RespawnEffect,,,startLocation + EffectOffset) ;
    //log("Client-EmittersRespawn") ;
}

defaultproperties
{
     bBlockedPath=True
     moveDistance=50.000000
     RelativeImpactVolume=127
     bShoveable=True
     ShoveModifier=1.500000
     bEnableSpinProtection=True
     hitSoundRepeatModifier=1.000000
     bCollisionDamage=True
     DamageSpeed=100.000000
     HitDamageType=Class'GoodKarma.DamTypeBludgeon'
     HitDamageScale=1.000000
     initialHealth=100
     damageAbsorbtionAmount=25
     explodeRadius=15.000000
     bDestroyable=True
     DestructionVolume=200
     bOrientDestructionEffect=True
     DestroyedMass=0.500000
     DestroyedDamping=1.000000
     DestroyedFriction=0.700000
     DestroyedBuoyancy=0.300000
     DestroyedRestitution=0.100000
     PreRespawnEffectTime=1.000000
     inactivityTimeout=15.000000
     RespawnVolume=180
     AutoRespawnTime=-1.000000
     bRespawnEffectPlayed=True
     bWaitTillMove=True
     bDead=True
     LastStateCount=-1
     inactiveClock=-999.000000
     bKActorShadows=True
     StaticMesh=StaticMesh'GKStaticMeshes.basicShapes.BasicCube'
     bUseDynamicLights=True
     bDetailAttachment=True
     RemoteRole=ROLE_SimulatedProxy
     bHardAttach=True
     bNetNotify=True
     Begin Object Class=KarmaParams Name=KarmaParams0
         KMass=0.500000
         bHighDetailOnly=False
         bClientOnly=False
         KFriction=0.500000
         KRestitution=0.200000
         KImpactThreshold=1.000000
     End Object
     KParams=KarmaParams'GoodKarma.NetKActor.KarmaParams0'

}
