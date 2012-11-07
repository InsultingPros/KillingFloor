//=============================================================================
// RORoleInfo.
//=============================================================================
// Defines the characteristics of a given role
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class RORoleInfo extends Actor
	hidecategories(Object,Movement,Collision,Lighting,LightColor,Karma,Force,Events,Display,Advanced,Sound)
	placeable
	abstract;

//=============================================================================
// Variables
//=============================================================================

// Strings
var		localized	string			MyName;						// Names to use in-game for this role
var		localized	string			AltName;
var		localized	string			Article;
var		localized	string			PluralName;
var		localized	string			InfoText;

// Assorted properties
var		Material					MenuImage;					// texture to use on the menus
var		array<string>				Models;						// Player models to use
var		string						VoiceType;					// Player's voice type
var		string						AltVoiceType;				// Player's English voice type
var		bool						bIsLeader;					// Enable special leader capabilites?
var     bool                        bIsGunner;                  // Enable player to request MG resupply
var		int    						ObjCaptureWeight;		// How many people is this person worth in a capture zone?
var		float						PointValue;					// Used for scoring
var		Material					SleeveTexture;				// The texture this role should use for thier first person sleeves

// Gore
var class <SeveredAppendage>		DetachedArmClass;			// class of detached arm to spawn for this role.
var class <SeveredAppendage>		DetachedLegClass;			// class of detached arm to spawn for this role.

struct ItemData
{
	var()	class<Inventory>		Item;
	var()	int						Amount;
	var()	class<ROAmmoPouch>		AssociatedAttachment;
};

var()	ItemData					PrimaryWeapons[3];			// Primary weapons available
var()	ItemData					SecondaryWeapons[3];		// Secondary weapons available
var()	ItemData					Grenades[3];				// Grenade types available
var()	array<string>				GivenItems;					// Other items always given to the player
var		array<class<ROHeadgear> >	Headgear;					// Headgear classes used
var		array<string>				UnusableItems;				// List of items this person is NOT allowed to pickup at all
var()	bool						bCarriesMGAmmo;				// carries a load of MG ammo

// Have to do a default pawn class, since it seems to be the only way to guarantee the proper mesh
// is set immediately after a player spawns in laggy conditions
var		string						RolePawnClass;				// The default pawn class for this role

// New stuff
enum EWeaponType
{
	WT_Rifle,
	WT_SMG,
	WT_LMG,
	WT_Sniper,
	WT_SemiAuto,
	WT_Assault,
	WT_PTRD,
};

var()   EWeaponType					PrimaryWeaponType;			// Role will recieve bonuses based on thier primary weapontype

// Weapon abilities
var		bool						bEnhancedAutomaticControl;	// True if this person has extra experience in controlling automatic weapons( not including MG's)

var     bool                        bCanBeTankCrew;             // Qualified to operate tanks
var     bool                        bCanBeTankCommander;

// New stuff
enum ESide
{
	SIDE_Axis,
	SIDE_Allies,
};

var()	ESide				Side;				// Side that can use this role
var()	int					Limit;				// How many people can be this role?  (0 = no restriction)
var()   int                 Limit33to44;        // How many people can be this role on a 33 to 44 player server?
var()   int                 LimitOver44;        // How many people can be this role on a server with MaxPlayers more than 44?

//=============================================================================
// replication
//=============================================================================

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		Limit, PrimaryWeapons, SecondaryWeapons, Grenades;
}

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// PostBeginPlay - Add this role to the list
//-----------------------------------------------------------------------------

function PostBeginPlay()
{
	if (ROTeamGame(Level.Game) != None)
		ROTeamGame(Level.Game).AddRole(self);

	HandlePrecache();
}

//-----------------------------------------------------------------------------
// PostNetBeginPlay - Initiate precache
//-----------------------------------------------------------------------------

simulated function PostNetBeginPlay()
{
	if (Role < ROLE_Authority)
		HandlePrecache();
}

//-----------------------------------------------------------------------------
// HandlePrecache - Try to add necessary precache materials
//-----------------------------------------------------------------------------

simulated function HandlePrecache()
{
	local int i;
	local xUtil.PlayerRecord PR;

	for (i = 0; i < ArrayCount(PrimaryWeapons); i++)
	{
		if (PrimaryWeapons[i].Item == None)
			continue;

		if (PrimaryWeapons[i].Item.default.PickupClass != None)
			PrimaryWeapons[i].Item.default.PickupClass.static.StaticPrecache(Level);

		if (PrimaryWeapons[i].AssociatedAttachment != None)
			PrimaryWeapons[i].AssociatedAttachment.static.StaticPrecache(Level);
	}

	for (i = 0; i < ArrayCount(SecondaryWeapons); i++)
	{
		if (SecondaryWeapons[i].Item == None)
			continue;

		if (SecondaryWeapons[i].Item.default.PickupClass != None)
			SecondaryWeapons[i].Item.default.PickupClass.static.StaticPrecache(Level);

		if (SecondaryWeapons[i].AssociatedAttachment != None)
			SecondaryWeapons[i].AssociatedAttachment.static.StaticPrecache(Level);
	}

	for (i = 0; i < ArrayCount(Grenades); i++)
	{
		if (Grenades[i].Item == None)
			continue;

		if (Grenades[i].Item.default.PickupClass != None)
			Grenades[i].Item.default.PickupClass.static.StaticPrecache(Level);

		if (Grenades[i].AssociatedAttachment != None)
			Grenades[i].AssociatedAttachment.static.StaticPrecache(Level);
	}

	for (i = 0; i < default.Headgear.Length; i++)
		default.Headgear[i].static.StaticPrecache(Level);

	for (i = 0; i < default.Models.Length; i++)
	{
		PR = class'xUtil'.static.FindPlayerRecord(default.Models[i]);
		DynamicLoadObject(PR.MeshName, class'Mesh');
		Level.ForceLoadTexture(Texture(DynamicLoadObject(PR.BodySkinName, class'Material')));
		Level.ForceLoadTexture(Texture(DynamicLoadObject(PR.FaceSkinName, class'Material')));
	}

	if (default.VoiceType != "")
		DynamicLoadObject(default.VoiceType, class'Class');

	if (default.AltVoiceType != "")
		DynamicLoadObject(default.AltVoiceType, class'Class');

	if (default.DetachedArmClass != none)
		default.DetachedArmClass.static.PrecacheContent(Level);

	if (default.DetachedLegClass != none)
		default.DetachedLegClass.static.PrecacheContent(Level);
}

//-----------------------------------------------------------------------------
// GetDummyAttachments - Returns all the ammo pouches required of this role
//-----------------------------------------------------------------------------

function GetAmmoPouches(out array<class<ROAmmoPouch> > OutArray, int Prim, int Sec, int Gren)
{
	if (Prim >= 0 && PrimaryWeapons[Prim].AssociatedAttachment != None)
		OutArray[OutArray.Length] = PrimaryWeapons[Prim].AssociatedAttachment;

	if (Sec >= 0 && SecondaryWeapons[Sec].AssociatedAttachment != None)
		OutArray[OutArray.Length] = SecondaryWeapons[Sec].AssociatedAttachment;

	if (Gren >= 0 && Grenades[Gren].AssociatedAttachment != None)
		OutArray[OutArray.Length] = Grenades[Gren].AssociatedAttachment;
}

//-----------------------------------------------------------------------------
// CanPickUp
//-----------------------------------------------------------------------------

function bool CanPickUp(Inventory Item)
{
	local int i;

	for (i = 0; i < UnusableItems.Length; i++)
	{
		if (string(Item.Class) ~= UnusableItems[i])
			return false;
	}

	return true;
}

//-----------------------------------------------------------------------------
// GetModel
//-----------------------------------------------------------------------------

static function string GetModel()
{
	if (default.Models.Length == 0)
		return "";

	return default.Models[Rand(default.Models.Length)];
}


//-----------------------------------------------------------------------------
// GetPawnClass
//-----------------------------------------------------------------------------

static function string GetPawnClass()
{
	return default.RolePawnClass;
}

//-----------------------------------------------------------------------------
// GetHeadgear
//-----------------------------------------------------------------------------

function class<ROHeadgear> GetHeadgear()
{
	if (Headgear.Length == 0)
		return None;

	return Headgear[0];
}

static function Material GetSleeveTexture()
{
	return default.SleeveTexture;
}

static function class<SeveredAppendage> GetArmClass()
{
	return default.DetachedArmClass;
}

static function class<SeveredAppendage> GetLegClass()
{
	return default.DetachedLegClass;
}

//-----------------------------------------------------------------------------
// GetLimit
//-----------------------------------------------------------------------------

simulated function int GetLimit(byte MaxPlayers)
{
    //Use a higher limit if server's MaxPlayers is over 32
    if (MaxPlayers > 32)
    {
        if (MaxPlayers <= 44)
            return Max(Limit, Limit33to44);
        else
            return Max(Limit, LimitOver44);
    }

    return Limit;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     InfoText="No information provided."
     ObjCaptureWeight=1
     PointValue=1.000000
     bStatic=True
     bHidden=True
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     NetUpdateFrequency=10.000000
}
