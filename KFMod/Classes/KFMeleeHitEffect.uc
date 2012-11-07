//=============================================================================
// KFMeleeHitEffect
//=============================================================================
// Base hit effect class for melee hits
//=============================================================================
// Killing Floor Source
// Copyright (C) 20099 John "Ramm-Jaeger" Gibson
//=============================================================================

class KFMeleeHitEffect extends ROHitEffect;

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     HitEffects(0)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitRockEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDefault')
     HitEffects(1)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitRockEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(2)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitDirtEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(3)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitMetalEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitMetal')
     HitEffects(4)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitWoodEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitWood')
     HitEffects(5)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitGrassEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(6)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitFleshEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitFlesh')
     HitEffects(7)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitIceEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(8)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitSnowEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(9)=(HitEffect=Class'ROEffects.ROBulletHitWaterEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDefault')
     HitEffects(10)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBreakingGlass',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDefault')
     HitEffects(11)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitGravelEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(12)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitConcreteEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitConc')
     HitEffects(13)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitWoodEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitWood')
     HitEffects(14)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitMudEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(15)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitMetalArmorEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitMetal')
     HitEffects(16)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitPaperEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(17)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitClothEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(18)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitRubberEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     HitEffects(19)=(HitDecal=Class'ROEffects.KnifeHitDirt',HitEffect=Class'ROEffects.ROBulletHitMudEffect',HitSound=SoundGroup'KF_KnifeSnd.Knife_HitDirt')
     RemoteRole=ROLE_SimulatedProxy
}
