class ROMapList extends MapList
    config;


function ClearMapsArray()
{
	Maps.Remove(0,Maps.Length);
}


function AddNewStringElement( string new_element_to_load, int index)
{
 	Maps[index] = new_element_to_load;
}

defaultproperties
{
}
