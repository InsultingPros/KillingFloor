class KFGUIVertImageList extends GUIVertImageList;

function int SetIndex(int NewIndex)
{
	if ( Elements[NewIndex].Locked == 1 )
	{
		log(MenuOwner.MenuOwner);

		if ( KFModelSelect(MenuOwner.MenuOwner) != none )
		{
			KFModelSelect(MenuOwner.MenuOwner).HandleLockedCharacterClicked(NewIndex);
		}

		return Index;
	}

	return super.SetIndex(NewIndex);
}

function Add(Material Image, optional int Item, optional int Locked)
{
	local int i;

	if ( Image == None && !bAllowEmptyItems )
		return;

	i = Elements.Length;
	Elements.Length = i + 1;
	Elements[i].Image = Image;
	Elements[i].Item = Item;
	Elements[i].Locked = Locked;
	ItemCount = Elements.Length;

	if ( ItemCount != 1 || !bInitializeList )
		CheckLinkedObjects(Self);

	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();
}

defaultproperties
{
}
