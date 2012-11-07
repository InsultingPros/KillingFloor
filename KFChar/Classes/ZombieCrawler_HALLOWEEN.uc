//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieCrawler_HALLOWEEN extends ZombieCrawler;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax

// Removes eblood emitters from legs
simulated function HideBone(name boneName)
{
	local int BoneScaleSlot;
	local coords boneCoords;
	local bool bValidBoneToHide;

	if( boneName == RightFArmBone )
	{
		boneScaleSlot = 2;
		bValidBoneToHide = true;
		if( SeveredRightArm == none )
		{
			SeveredRightArm = Spawn(SeveredArmAttachClass,self);
			SeveredRightArm.SetDrawScale(SeveredArmAttachScale);
			boneCoords = GetBoneCoords( 'rarm' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'rarm', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredRightArm, 'rarm');
		}
	}
	else if ( boneName == LeftFArmBone )
	{
		boneScaleSlot = 3;
		bValidBoneToHide = true;
		if( SeveredLeftArm == none )
		{
			SeveredLeftArm = Spawn(SeveredArmAttachClass,self);
			SeveredLeftArm.SetDrawScale(SeveredArmAttachScale);
			boneCoords = GetBoneCoords( 'larm' );
			AttachEmitterEffect( LimbSpurtEmitterClass, 'larm', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredLeftArm, 'larm');
		}
	}
	else if ( boneName == HeadBone )
	{
		// Only scale the bone down once
		if( SeveredHead == none )
		{
			bValidBoneToHide = true;
			boneScaleSlot = 4;
			SeveredHead = Spawn(SeveredHeadAttachClass,self);
			SeveredHead.SetDrawScale(SeveredHeadAttachScale);
			boneCoords = GetBoneCoords( 'neck' );
			AttachEmitterEffect( NeckSpurtEmitterClass, 'neck', boneCoords.Origin, rot(0,0,0) );
			AttachToBone(SeveredHead, 'neck');
		}
		else
		{
			return;
		}
	}
	else if ( boneName == 'spine' )
	{
	    bValidBoneToHide = true;
		boneScaleSlot = 5;
	}

	// Only hide the bone if it is one of the arms, legs, or head, don't hide other misc bones
	if( bValidBoneToHide )
	{
		SetBoneScale(BoneScaleSlot, 0.0, BoneName);
	}
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Crawler.Crawler_Talk'
     KFRagdollName="RedneckCrawl_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Crawler.Crawler_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Crawler.Crawler_Jump'
     SeveredLegAttachClass=None
     DetachedArmClass=Class'KFChar.SeveredArmCrawler_HALLOWEEN'
     DetachedLegClass=Class'KFChar.SeveredLegCrawler_HALLOWEEN'
     DetachedHeadClass=Class'KFChar.SeveredHeadCrawler_HALLOWEEN'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Crawler.Crawler_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Crawler.Crawler_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Crawler.Crawler_Acquire'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Crawler.Crawler_Acquire'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Crawler.Crawler_Acquire'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Crawler.Crawler_Acquire'
     MenuName="HALLOWEEN Crawler"
     AmbientSound=Sound'KF_BaseCrawler_HALLOWEEN.Crawler_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_HALLOWEEN.Crawler_Halloween'
     Skins(0)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.Crawler.crawler_RedneckZombie_CMB'
}
