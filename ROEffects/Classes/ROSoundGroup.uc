//------------------------------------------------------------------------------
// $id:$
//  @description: Container object to hold up sounds
//  when calling "GetSound" one of the valid sounds in the
//  group will be returned.
//-----------------------------------------------------------
class ROSoundGroup extends Object;

var() array<Sound> Sounds;

function Sound getSound()
{
   return Sounds[rand(Sounds.length)];
}

defaultproperties
{
}
