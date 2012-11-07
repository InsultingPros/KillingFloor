// Written by .:..:, for handling song switches.
Class KFMusicInteraction extends Interaction;

var string ActiveSong,NextSong;
var int ActiveHandel;
var bool bFadeOutSong;
var StreamInteraction Stream;
var float FadeTimes[2],FadeOutPos,InitialVol;

event Initialized()
{
	local int i;

	For( i=0; i<ViewportOwner.LocalInteractions.Length; i++ )
	{
		if( StreamInteraction(ViewportOwner.LocalInteractions[i])!=None )
		{
			Stream = StreamInteraction(ViewportOwner.LocalInteractions[i]);
			Return;
		}
	}
}

function bool CanSwitchSong()
{
	Return (Stream==None || !Stream.IsPlaying());
}

function SetSong( string SngName, float FadeInTime, float FadeOutTime )
{
	if( !CanSwitchSong() )
		Return;
	if( ActiveSong!="" && FadeOutTime>0 )
	{
		InitialVol = Float(ViewportOwner.Actor.ConsoleCommand("Get ini:Engine.Engine.AudioDevice MusicVolume"));
		NextSong = SngName;
		bFadeOutSong = True;
		FadeTimes[0] = FadeInTime;
		FadeTimes[1] = FadeOutTime;
		FadeOutPos = FadeOutTime;
	}
	else
	{
		if( ActiveSong!="" )
			ViewportOwner.Actor.StopAllMusic();
		bFadeOutSong = False;
		ActiveSong = SngName;
		ActiveHandel = ViewportOwner.Actor.PlayMusic(SngName,FadeInTime);
	}
}
function StopSong( float FadeOutTime )
{
	if( !CanSwitchSong() || ActiveSong=="" )
		Return;
	else if( FadeOutTime<=0 )
	{
		ViewportOwner.Actor.StopAllMusic();
		bFadeOutSong = False;
		ActiveSong = "";
	}
	else
	{
		InitialVol = Float(ViewportOwner.Actor.ConsoleCommand("Get ini:Engine.Engine.AudioDevice MusicVolume"));
		NextSong = "";
		bFadeOutSong = True;
		FadeTimes[1] = FadeOutTime;
		FadeOutPos = FadeOutTime;
	}
}

function Tick(float DeltaTime)
{
	local float Scalar;

	if( bFadeOutSong )
	{
		Scalar = (FadeOutPos/FadeTimes[1]);
		if( Scalar<0.1 )
		{
			bFadeOutSong = False;
			ActiveSong = NextSong;
			ViewportOwner.Actor.StopAllMusic();
			ViewportOwner.Actor.AdjustVolume(ActiveHandel,InitialVol);
			if( NextSong!="" )
				ActiveHandel = ViewportOwner.Actor.PlayMusic(ActiveSong,FadeTimes[0]);
		}
		else
		{
			FadeOutPos-=DeltaTime;
			ViewportOwner.Actor.AdjustVolume(ActiveHandel,Scalar*InitialVol);
		}
	}
}
event NotifyLevelChange() // Musics don't stay over mapchanges.
{
	ActiveSong = "";
	ActiveHandel = 0;
	bFadeOutSong = False;
}

defaultproperties
{
     bActive=False
     bRequiresTick=True
}
