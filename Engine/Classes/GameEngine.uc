//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class GameEngine extends Engine
	native
	noexport
	transient;

// URL structure.
struct URL
{
	var string			Protocol,	// Protocol, i.e. "unreal" or "http".
						Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int				Port;		// Optional host port.
	var string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string>	Op;			// Options.
	var string			Portal;		// Portal to enter through, default is "".
	var int				Valid;
};

var Level			GLevel,
					GEntry;
var PendingLevel	GPendingLevel;
var URL				LastURL;
var config array<string>  ServerActors,
					      ServerPackages;

var array<object>         DummyArray;	// Do not modify
var object                DummyObject;  // Do not modify
var string				  DummyString;	// Do not modify

var globalconfig String MainMenuClass;			// Menu that appears when you first start
var globalconfig string SinglePlayerMenuClass;	// Menu that appears when you return from a single player match after a cinematic game
var globalconfig String ConnectingMenuClass;	// Menu that appears when you are connecting
var globalconfig String DisconnectMenuClass;	// Menu that appears when you are disconnected
var globalconfig String LoadingClass;			// Loading screen that appears

var                  bool bCheatProtection;
var(Settings) config bool ColorHighDetailMeshes;
var(Settings) config bool ColorSlowCollisionMeshes;
var(Settings) config bool ColorNoCollisionMeshes;
var(Settings) config bool ColorWorldTextures;
var(Settings) config bool ColorPlayerAndWeaponTextures;
var(Settings) config bool ColorInterfaceTextures;

var(VoiceChat) globalconfig bool VoIPAllowVAD;

defaultproperties
{
     CacheSizeMegs=32
}
