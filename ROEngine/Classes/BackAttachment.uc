//=============================================================================
// BackAttachment
//=============================================================================
// Base class for items that attach to the pawn's back
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class BackAttachment extends InventoryAttachment;

var class<Inventory>	InventoryClass;

function InitFor(Inventory I)
{
	Instigator = I.Instigator;

	if( I != none )
	{
		LinkMesh( I.AttachmentClass.default.Mesh);
		InventoryClass = I.Class;
	}
}

defaultproperties
{
     NetUpdateFrequency=5.000000
     AttachmentBone="weapon_back"
}
