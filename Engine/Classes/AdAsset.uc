class AdAsset extends Object
	native;

enum AdAssetState
{
	ADASSET_STATE_CREATED,
	ADASSET_STATE_DOWNLOADING,
	ADASSET_STATE_DOWNLOADED,
	ADASSET_STATE_ERROR,
};

var() string InventoryName;
var() string ZoneName;
var() string DownloadPath;
var const transient pointer Subscriber;

native final function string GetLastErrorString();
native final function SetVisible(bool visible, int width, int height);
native final function Displayed();
native final function bool HasBeenDisplayed();
native final function AdAssetState GetState();

event OnStateChanged()
{
}

defaultproperties
{
}
