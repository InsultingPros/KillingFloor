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
     Maps(0)="RO-Danzig"
     Maps(1)="RO-Arad"
     Maps(2)="RO-Barashka"
     Maps(3)="RO-Basovka"
     Maps(4)="RO-Bondarevo"
     Maps(5)="RO-HedgeHog"
     Maps(6)="RO-Kaukasus"
     Maps(7)="RO-KrasnyiOktyabr"
     Maps(8)="RO-Ogledow"
     Maps(9)="RO-Odessa"
     Maps(10)="RO-StalingradKessel"
     Maps(11)="RO-KonigsPlatz"
     Maps(12)="RO-Rakowice"
     Maps(13)="RO-BaksanValley"
     Maps(14)="RO-Berezina"
     Maps(15)="RO-BlackDayJuly"
     Maps(16)="RO-Kryukovo"
     Maps(17)="RO-KurlandKessel"
     Maps(18)="RO-Leningrad"
     Maps(19)="RO-Mannikkala"
     Maps(20)="RO-SmolenskStalemate"
     Maps(21)="RO-Tcherkassy"
     Maps(22)="RO-TulaOutskirts"
     Maps(23)="RO-Zhitomir1941"
}
