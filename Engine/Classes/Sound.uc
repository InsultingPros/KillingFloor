class Sound extends Object
    native
	hidecategories(Object)
    noexport;

var(Sound) native float Likelihood;
var native const byte Data[44]; // sizeof (FSoundData) :(
var native const Name FileType;
var native const String FileName;
var native const int OriginalSize;
var native const float Duration;
var native const pointer Handle;
var native const int Flags;
var native const int VoiceCodec;
var native const float InitialSeekTime;

var(Sound) float BaseRadius;
var(Sound) float VelocityScale;

// if _RO_
var native const bool bUseDistantSound;
var(Sound) bool  bHasDistantSound;
var(Sound) float DistantRadius;
// if _KF_
var native const bool bUseStereoAmbientSound;
var(Sound) bool  bHasStereoAmbientSound;
// end _KF_
// end _RO_

defaultproperties
{
     BaseRadius=2000.000000
}
