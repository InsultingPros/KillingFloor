class KFMeleeGun extends KFWeapon;

//var name TPAnim;
//var name TPAnim2;
var bool btryHit ;
var float THMax, THMin, dmg ;
var class<damageType> hitDamType ;
var float weaponRange ;
var vector momOffset ;
var Actor HitObject ;
var byte MeleeHitVolume ;

var float hitTimeout ;
var bool bCanHit ;//, bAnimating ;

var float ChopSlowRate; // percentage your speed gets reduced to when chopping

// Bloody Weapons. By Alex.
// Gibby, when you re-do the melee code, you may have to move the code I put in Tick.

var Material BloodyMaterial; // When you slash someone and draw blood, switch to this skin.
var int BloodSkinSwitchArray; // In case the material array number varies between weapons, switch this num in defprops. (usually it's "2")
var bool bDoCombos; // DISABLE FOR NOW

var string BloodyMaterialRef;

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	super.PreloadAssets(Inv, bSkipRefCount);

	default.BloodyMaterial = Combiner(DynamicLoadObject(default.BloodyMaterialRef, class'combiner', true));

	if ( KFMeleeGun(Inv) != none )
	{
		KFMeleeGun(Inv).BloodyMaterial = default.BloodyMaterial;
	}
}

static function bool UnloadAssets()
{
	if ( super.UnloadAssets() )
	{
		default.BloodyMaterial = none;
	}

	return true;
}

function DoReflectEffect(int Drain)
{
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if(BloodyMaterial!=none && Skins[BloodSkinSwitchArray] == BloodyMaterial )
	{
		Skins[BloodSkinSwitchArray] = default.Skins[BloodSkinSwitchArray];
		Texture = default.Texture;
	}
	super.BringUp(PrevWeapon);
}

simulated function bool HasAmmo()
{
	return true;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local vector boxscreenloc,endpoint,eyepoint;

	boxscreenloc = Canvas.WorldToScreen( GetBoneCoords('tip').Origin );
	Canvas.SetDrawColor(0,255,0,255);
	Canvas.SetPos(boxscreenloc.X-10,boxscreenloc.Y-10);
	Canvas.DrawBox(Canvas,20,20);

	eyepoint = Instigator.Location;
	eyepoint.Z += Instigator.Eyeheight;
	endpoint = (Normal(GetBoneCoords('tip').Origin-eyepoint)*1000)+eyepoint;
	boxscreenloc = Canvas.WorldToScreen(endpoint);
	Canvas.SetDrawColor(255,0,0,255);
	Canvas.SetPos(boxscreenloc.X-10,boxscreenloc.Y-10);
	Canvas.DrawBox(Canvas,20,20);

	boxscreenloc = Canvas.WorldToScreen(eyepoint);
	Canvas.SetDrawColor(0,0,255,255);
	Canvas.SetPos(boxscreenloc.X-10,boxscreenloc.Y-10);
	Canvas.DrawBox(Canvas,20,20);
	Super.DisplayDebug(Canvas,YL,YPos);
}

function byte BestMode()
{
	return 0;
}

function float GetAIRating()
{
	if( Instigator.Controller==None || PlayerController(Instigator.Controller)!=None || Instigator.Controller.Target==None )
		Return AIRating;
	if( VSize(Instigator.Controller.Target.Location-Instigator.Location)<120 )
		return AIRating*2;
	return AIRating/2;
}

function float SuggestAttackStyle()
{
    return 1;
}

function float SuggestDefenseStyle()
{
    return -1;
}

defaultproperties
{
     weaponRange=70.000000
     MeleeHitVolume=255
     ChopSlowRate=0.500000
     BloodSkinSwitchArray=2
     PutDownAnim="PutDown"
     AIRating=0.100000
     bMeleeWeapon=True
}
