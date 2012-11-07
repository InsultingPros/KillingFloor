//=============================================================================
// Movie.uc: A movie that plays on a texture
//
// Created by Demiurge Studios 2002
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Movie extends Texture
	native
	noexport;

// TODO Al: Make this extend UBitmapMaterial, if possible

var const transient int FMovie;
var Object Callbacks;

// native functions.
native final function Open(String MovieFilename);
native final function Close();
native final function Play(bool LoopMovie);
native final function Pause( bool Pause );
native final function bool IsPaused();
native final function StopNow();
native final function StopAtEnd();
native final function bool IsPlaying();
native final function int GetWidth();
native final function int GetHeight();

defaultproperties
{
}
