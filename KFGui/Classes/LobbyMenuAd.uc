class LobbyMenuAd extends AdAsset;

var Movie MenuMovie;

event OnStateChanged()
{
}

function DestroyMovie()
{
	if(MenuMovie !=none)
	{
		MenuMovie.Close();
		MenuMovie = None;
	}
}

event OnFinished()
{
}

defaultproperties
{
     InventoryName="movie_ad_1"
     ZoneName="mp_lobby"
}
