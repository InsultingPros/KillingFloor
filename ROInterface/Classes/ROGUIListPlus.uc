//=============================================================================
// ROGUIListPlus
//=============================================================================
// An enhanced version of GUIList. Allows for grayed out, non-clickable
// elements.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROGUIListPlus extends GUIList;

var string          DisabledMarker;
var bool            bCanSelectDisabledItems;

// Same as Add(), but adds the item disabled.
function AddDisabled(string NewItem, optional Object obj, optional string Str, optional bool bSection)
{
	local int NewIndex;
	local GUIListElem E;

	if ( !bAllowEmptyItems && NewItem == "" && Obj == None && Str == "" )
		return;

	E.Item = NewItem;
	E.ExtraData = Obj;
	E.ExtraStrData = Str;
	E.bSection = bSection;

	if (bSorted && Elements.Length > 0)
	{
		while (NewIndex < Elements.Length && CompareItem(Elements[NewIndex], E) < 0)
			NewIndex++;
	}
	else NewIndex = Elements.Length;

	Elements.Insert(NewIndex, 1);
	Elements[NewIndex] = E;

	SetDisabledAtIndex(NewIndex, true);

	ItemCount = Elements.Length;

	if (Elements.Length == 1 && bInitializeList)
		SetIndex(0);
	else if ( bNotify )
		CheckLinkedObjects(Self);

	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

function SetDisabledAtIndex(int i, bool bDisabled)
{
	if (!IsValidIndex(i))
		return;

    if (bDisabled)
	    Elements[i].ExtraStrData = DisabledMarker;
	else
	    Elements[i].ExtraStrData = "";

	if ( bNotify )
		CheckLinkedObjects(Self);
}

// disallow clicking on disabled items
function bool InternalOnClick(GUIComponent Sender)
{
	local int NewIndex;

	if ( !IsInClientBounds() || ItemsPerPage==0 )
		return false;

	// Get the Row..
	NewIndex = CalculateIndex();

	if (Elements[NewIndex].ExtraStrData == DisabledMarker && !bCanSelectDisabledItems)
	   return false;

	SetIndex(NewIndex);
	return true;
}

function bool Up()
{
    local int NewIndex;
	if ( (ItemCount<2) || (Index==0) ) return true;

    NewIndex = FindLastValidIndex(Index-1);
    if (NewIndex == -1)
        return true;

	SetIndex(NewIndex);
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
	return true;
}

function bool Down()
{
    local int NewIndex;
	if ( (ItemCount<2) || (Index==ItemCount-1) ) return true;

	NewIndex = FindNextValidIndex(Min(Index+1, ItemCount - 1));
    if (NewIndex == -1)
        return true;

	SetIndex(NewIndex);
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
	return true;
}

function Home()
{
    local int NewIndex;
	if (ItemCount<2) return;

	NewIndex = FindNextValidIndex(0);
    if (NewIndex == -1)
        return;

	SetIndex(NewIndex);
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
}

function End()
{
    local int NewIndex;
	if (ItemCount<2)	return;

	NewIndex = FindLastValidIndex(ItemCount-1);
    if (NewIndex == -1)
        return;

	SetIndex(NewIndex);
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
}

function PgUp()
{
    local int NewIndex;
	if (ItemCount<2)	return;

	NewIndex = FindLastValidIndex(Max(0, Index - ItemsPerPage));
    if (NewIndex == -1)
        return;

	SetIndex(NewIndex);
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
}

function PgDn()
{
    local int NewIndex;
	if (ItemCount<2)	return;

	NewIndex = FindNextValidIndex(Min(Index + ItemsPerPage, ItemCount - 1));
    if (NewIndex == -1)
        return;

	SetIndex(NewIndex);
	if ( MyScrollBar != None )
		MyScrollBar.AlignThumb();
}

function int FindNextValidIndex(int startIndex)
{
    local int i;
    if (startIndex >= ItemCount || startIndex < 0)
        return -1;

    if (bCanSelectDisabledItems)
        return startIndex;

    i = startIndex;
    while (i < ItemCount)
    {
        if (Elements[i].ExtraStrData != DisabledMarker)
            return i;
        i++;
    }

    return -1;
}

function int FindLastValidIndex(int startIndex)
{
    local int i;
    if (startIndex >= ItemCount || startIndex < 0)
        return -1;

    if (bCanSelectDisabledItems)
        return startIndex;

    i = startIndex;
    while (i >= 0)
    {
        if (Elements[i].ExtraStrData != DisabledMarker)
            return i;
        i--;
    }

    return -1;
}

function InternalOnDrawItem(Canvas C, int Item, float X, float Y, float XL, float YL, bool bIsSelected, bool bIsPending)
{
	local string Text;
	local bool bIsDrop;

	Text = Elements[item].Item;
	bIsDrop = Top + Item == DropIndex;

	if (bIsSelected || (bIsPending && !bIsDrop))
	{
		if (SelectedStyle!=None)
		{
			if (SelectedStyle.Images[MenuState] != None)
				SelectedStyle.Draw(C,MenuState, X, Y, XL, YL);
			else
			{
				C.SetPos(X, Y);
				C.DrawTile(Controller.DefaultPens[0], XL, YL,0,0,32,32);
			}
		}
		else
		{
			// Display the selection
			if ( (MenuState==MSAT_Focused)  || (MenuState==MSAT_Pressed) )
			{
				C.SetPos( X, Y );
				if (SelectedImage==None)
					C.DrawTile(Controller.DefaultPens[0], XL, YL,0,0,32,32);
				else
				{
					C.SetDrawColor(SelectedBKColor.R, SelectedBKColor.G, SelectedBKColor.B, SelectedBKColor.A);
					C.DrawTileStretched(SelectedImage, XL, YL);
				}
			}
		}
	}

	if (bIsPending && OutlineStyle != None )
	{
		if ( OutlineStyle.Images[MenuState] != None )
		{
			if ( bIsDrop )
				OutlineStyle.Draw(C, MenuState, X+1, Y+1, XL - 2, YL-2);
			else
			{
				OutlineStyle.Draw(C, MenuState, X, Y, XL, YL);
				if (DropState == DRP_Source)
					OutlineStyle.Draw(C, MenuState, Controller.MouseX - MouseOffset[0], Controller.MouseY - MouseOffset[1] + Y - ClientBounds[1], MouseOffset[2] + MouseOffset[0], ItemHeight);
			}
		}
	}

    if ( Elements[item].ExtraStrData == DisabledMarker)
        Style.DrawText( C, MSAT_Disabled, X, Y, XL, YL, TXTA_Left, Text, FontScale );
	else if ( bIsSelected && SelectedStyle != None )
		SelectedStyle.DrawText( C, MenuState, X, Y, XL, YL, TXTA_Left, Text, FontScale );
	else
        Style.DrawText( C, MenuState, X, Y, XL, YL, TXTA_Left, Text, FontScale );
}

defaultproperties
{
     DisabledMarker="%!)?_¼½G_DISABLED%!¶"
     OnDrawItem=ROGUIListPlus.InternalOnDrawItem
}
