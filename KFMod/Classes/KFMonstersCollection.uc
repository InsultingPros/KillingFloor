class KFMonstersCollection extends Object;

struct MClassTypes
{
	var() config string MClassName, MID;
};

var() globalconfig array<MClassTypes> MonsterClasses;
var()   array<MClassTypes>  StandardMonsterClasses; // The standard monster classed

// Store info for a special squad we want to spawn outside of the normal wave system
struct SpecialSquad
{
	var array<string> ZedClass;
	var array<int> NumZeds;
};

// Special squads are used to spawn a squad outside of the normal wave system so
// we have a bit more control. Basically. these will only spawn towards the
// end of the normal squad list. This way you don't end up with a bunch of really
// beast Zeds spawning one right after the other> It also guarantees that this
// squad will always get used - Ramm
var     array<SpecialSquad>     SpecialSquads;          // The currently used SpecialSquad array
var     array<SpecialSquad>     ShortSpecialSquads;     // The special squad array for a short game
var     array<SpecialSquad>     NormalSpecialSquads;    // The special squad array for a normal game
var     array<SpecialSquad>     LongSpecialSquads;      // The special squad array for a long game

var     array<SpecialSquad>     FinalSquads;            // Squads that spawn with the Patriarch

var config 	string	FallbackMonsterClass;
var() string EndGameBossClass; // class of the end game boss, moved to non config - Ramm

static function PreLoadAssets()
{
    local int i;
    for(i=0;i<default.MonsterClasses.Length;i++)
    {
         class<KFMonster>(DynamicLoadObject(default.MonsterClasses[i].MClassName, Class'class')).static.PreCacheAssets(none);
    }
}

defaultproperties
{
     MonsterClasses(0)=(MClassName="KFChar.ZombieClot",Mid="A")
     MonsterClasses(1)=(MClassName="KFChar.ZombieCrawler",Mid="B")
     MonsterClasses(2)=(MClassName="KFChar.ZombieGoreFast",Mid="C")
     MonsterClasses(3)=(MClassName="KFChar.ZombieStalker",Mid="D")
     MonsterClasses(4)=(MClassName="KFChar.ZombieScrake",Mid="E")
     MonsterClasses(5)=(MClassName="KFChar.ZombieFleshpound",Mid="F")
     MonsterClasses(6)=(MClassName="KFChar.ZombieBloat",Mid="G")
     MonsterClasses(7)=(MClassName="KFChar.ZombieSiren",Mid="H")
     MonsterClasses(8)=(MClassName="KFChar.ZombieHusk",Mid="I")
     StandardMonsterClasses(0)=(MClassName="KFChar.ZombieClot",Mid="A")
     StandardMonsterClasses(1)=(MClassName="KFChar.ZombieCrawler",Mid="B")
     StandardMonsterClasses(2)=(MClassName="KFChar.ZombieGoreFast",Mid="C")
     StandardMonsterClasses(3)=(MClassName="KFChar.ZombieStalker",Mid="D")
     StandardMonsterClasses(4)=(MClassName="KFChar.ZombieScrake",Mid="E")
     StandardMonsterClasses(5)=(MClassName="KFChar.ZombieFleshpound",Mid="F")
     StandardMonsterClasses(6)=(MClassName="KFChar.ZombieBloat",Mid="G")
     StandardMonsterClasses(7)=(MClassName="KFChar.ZombieSiren",Mid="H")
     StandardMonsterClasses(8)=(MClassName="KFChar.ZombieHusk",Mid="I")
     ShortSpecialSquads(2)=(ZedClass=("KFChar.ZombieCrawler","KFChar.ZombieGorefast","KFChar.ZombieStalker","KFChar.ZombieScrake"),NumZeds=(2,2,1,1))
     ShortSpecialSquads(3)=(ZedClass=("KFChar.ZombieBloat","KFChar.ZombieSiren","KFChar.ZombieFleshPound"),NumZeds=(1,2,1))
     NormalSpecialSquads(3)=(ZedClass=("KFChar.ZombieCrawler","KFChar.ZombieGorefast","KFChar.ZombieStalker","KFChar.ZombieScrake"),NumZeds=(2,2,1,1))
     NormalSpecialSquads(4)=(ZedClass=("KFChar.ZombieFleshPound"),NumZeds=(1))
     NormalSpecialSquads(5)=(ZedClass=("KFChar.ZombieBloat","KFChar.ZombieSiren","KFChar.ZombieFleshPound"),NumZeds=(1,1,1))
     NormalSpecialSquads(6)=(ZedClass=("KFChar.ZombieBloat","KFChar.ZombieSiren","KFChar.ZombieFleshPound"),NumZeds=(1,1,2))
     LongSpecialSquads(4)=(ZedClass=("KFChar.ZombieCrawler","KFChar.ZombieGorefast","KFChar.ZombieStalker","KFChar.ZombieScrake"),NumZeds=(2,2,1,1))
     LongSpecialSquads(6)=(ZedClass=("KFChar.ZombieFleshPound"),NumZeds=(1))
     LongSpecialSquads(7)=(ZedClass=("KFChar.ZombieBloat","KFChar.ZombieSiren","KFChar.ZombieFleshPound"),NumZeds=(1,1,1))
     LongSpecialSquads(8)=(ZedClass=("KFChar.ZombieBloat","KFChar.ZombieSiren","KFChar.ZombieScrake","KFChar.ZombieFleshPound"),NumZeds=(1,2,1,1))
     LongSpecialSquads(9)=(ZedClass=("KFChar.ZombieBloat","KFChar.ZombieSiren","KFChar.ZombieScrake","KFChar.ZombieFleshPound"),NumZeds=(1,2,1,2))
     FinalSquads(0)=(ZedClass=("KFChar.ZombieClot"),NumZeds=(4))
     FinalSquads(1)=(ZedClass=("KFChar.ZombieClot","KFChar.ZombieCrawler"),NumZeds=(3,1))
     FinalSquads(2)=(ZedClass=("KFChar.ZombieClot","KFChar.ZombieStalker","KFChar.ZombieCrawler"),NumZeds=(3,1,1))
     FallbackMonsterClass="KFChar.ZombieStalker"
     EndGameBossClass="KFChar.ZombieBoss"
}
