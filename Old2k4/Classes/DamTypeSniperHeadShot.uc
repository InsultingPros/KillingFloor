class DamTypeSniperHeadShot extends WeaponDamageType
	abstract;

var class<LocalMessage> KillerMessage;
var sound HeadHunter; // OBSOLETE

static function IncrementKills(Controller Killer)
{
	local xPlayerReplicationInfo xPRI;

	if ( PlayerController(Killer) == None )
		return;

	PlayerController(Killer).ReceiveLocalizedMessage( Default.KillerMessage, 0, Killer.PlayerReplicationInfo, None, None );
	xPRI = xPlayerReplicationInfo(Killer.PlayerReplicationInfo);
	if ( xPRI != None )
	{
		xPRI.headcount++;
		if ( (xPRI.headcount == 15) && (UnrealPlayer(Killer) != None) )
			UnrealPlayer(Killer).ClientDelayedAnnouncementNamed('HeadHunter',15);
	}
}

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    //KFTODO: Maybe replace this
    //HitEffects[0] = class'HitSmoke';
    //HitEffects[1] = class'ROEffects.FireTrail';
}

defaultproperties
{
     KillerMessage=Class'Old2k4.SpecialKillMessage'
     DeathString="%o's cranium was made extra crispy by %k's lightning gun."
     FemaleSuicide="%o violated the laws of space-time and sniped herself."
     MaleSuicide="%o violated the laws of space-time and sniped himself."
     bAlwaysSevers=True
     bSpecial=True
     bCauseConvulsions=True
     DamageOverlayTime=0.900000
}
