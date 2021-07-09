class TextToSpeechAlias extends Object
	config(user)
	abstract
	native;

struct native SpeechReplacement
{
	var array<string>     MatchWords;
	var string            ReplaceWord;
};

var	config array<SpeechReplacement>		 Aliases;
var	config string				RemoveCharacters;

defaultproperties
{
     Aliases(0)=(MatchWords=("gg"),ReplaceWord="good game")
     Aliases(1)=(MatchWords=("rofl","rotfl","rotflmao"),ReplaceWord="rolls on floor laughing!")
     Aliases(2)=(MatchWords=("lol"),ReplaceWord="laughing out loud!")
     Aliases(3)=(MatchWords=(":)",":-)",":P"),ReplaceWord="smile")
     Aliases(4)=(MatchWords=(";)",";-)",";P"),ReplaceWord="wink")
     Aliases(5)=(MatchWords=("omg","omfg","omg!","omfg!"),ReplaceWord="oh my god!")
     Aliases(6)=(MatchWords=("ns"),ReplaceWord="nice shot")
     Aliases(7)=(MatchWords=("hf"),ReplaceWord="have fun")
     Aliases(8)=(MatchWords=("fc"),ReplaceWord="flag carrier")
     Aliases(9)=(MatchWords=("ih"),ReplaceWord="incoming high")
     Aliases(10)=(MatchWords=("iw"),ReplaceWord="incoming low")
     Aliases(11)=(MatchWords=("ir"),ReplaceWord="incoming right")
     Aliases(12)=(MatchWords=("il"),ReplaceWord="incoming left")
     Aliases(13)=(MatchWords=("bbl"),ReplaceWord="be back later")
     Aliases(14)=(MatchWords=("brb"),ReplaceWord="be right back")
     Aliases(15)=(MatchWords=("bbiab"),ReplaceWord="be back in a bit")
     RemoveCharacters="|:][}{^/~()"
}
