class xPawnGibGroup extends Object
    abstract;

var(Gib) array< class<Gib> > Gibs;

var class<xEmitter> BloodHitClass;
var class<xEmitter> LowGoreBloodHitClass;
var class<xEmitter> BloodGibClass;
var class<xEmitter> LowGoreBloodGibClass;
var class<xEmitter> LowGoreBloodEmitClass;
var class<xEmitter> BloodEmitClass;
var class<xEmitter> NoBloodEmitClass;
var class<xEmitter> NoBloodHitClass;

var sound GibSounds[3];

Enum EGibType
{
    EGT_Calf,
    EGT_Forearm,
    EGT_Hand,
    EGT_Head,
    EGT_Torso,
    EGT_Upperarm,
};

static function PrecacheContent(LevelInfo Level)
{
	local int i;

	if ( class'GameInfo'.static.UseLowGore() )
	{
		if ( class'GameInfo'.static.NoBlood() )
		{
			Default.NoBloodEmitClass.static.PrecacheContent(Level);
			Default.NoBloodHitClass.static.PrecacheContent(Level);
		}
		if ( Default.LowGoreBloodHitClass != None )
			Default.LowGoreBloodHitClass.static.PrecacheContent(Level);
		if ( Default.LowGoreBloodGibClass != None )
			Default.LowGoreBloodGibClass.static.PrecacheContent(Level);
		if ( Default.LowGoreBloodEmitClass != None )
			Default.LowGoreBloodEmitClass.static.PrecacheContent(Level);
	}
	else
	{
		if ( Default.BloodHitClass != None )
			Default.BloodHitClass.static.PrecacheContent(Level);
		if ( Default.BloodGibClass != None )
			Default.BloodGibClass.static.PrecacheContent(Level);
		if ( Default.BloodEmitClass != None )
			Default.BloodEmitClass.static.PrecacheContent(Level);

		for ( i=0; i<Default.Gibs.Length; i++ )
		{
			if ( Default.Gibs[i].Default.Skins.Length > 0 )
				Level.AddPrecacheMaterial(Default.Gibs[i].Default.Skins[0]);
			Level.AddPrecacheStaticMesh(Default.Gibs[i].Default.StaticMesh);
		}
	}
}

static function class<Gib> GetGibClass(EGibType gibType)
{
    return default.Gibs[int(gibType)];
}

static function class<xEmitter> GetBloodEmitClass()
{
	if ( class'GameInfo'.static.UseLowGore() )
	{
		if ( class'GameInfo'.static.NoBlood() )
			return Default.NoBloodEmitClass;
 		return Default.LowGoreBloodEmitClass;
 	}
    return Default.BloodEmitClass;
}

static function sound GibSound()
{
	return Default.GibSounds[Rand(3)];
}

defaultproperties
{
     Gibs(0)=Class'Old2k4.GibOrganicRedCalf'
     Gibs(1)=Class'Old2k4.GibOrganicRedForearm'
     Gibs(2)=Class'Old2k4.GibOrganicRedForearm'
     Gibs(3)=Class'Old2k4.GibOrganicRedHead'
     Gibs(4)=Class'Old2k4.GibOrganicRedTorso'
     Gibs(5)=Class'Old2k4.GibOrganicRedUpperArm'
     BloodHitClass=Class'Old2k4.BloodSmallHit'
     BloodGibClass=Class'Old2k4.BloodExplosion'
     BloodEmitClass=Class'Old2k4.BloodJet'
     GibSounds(0)=SoundGroup'KF_EnemyGlobalSnd.KFNewGib'
}
