class KFMaplistManager extends MaplistManager;

// returns whether Maplist class was loaded successfully
function bool GetDefaultMaps( string MaplistClassName, out array<string> Maps )
{
    local class<Maplist> List;

    if ( MaplistClassName == "" )
        return false;

    List = class<Maplist>(DynamicLoadObject( MaplistClassName, class'Class', True ));
    if ( List == None )
        return false;

    Maps = List.static.StaticGetMaps();
    return true;
}

defaultproperties
{
}
