// Borrows most functionality from xTeamRoster

class ROTeamRoster extends UnrealTeamInfo;

// Added this because we don't subclass UnrealPawn
var() class<ROPawn> ROAllowedTeamMembers[32];


function PostBeginPlay()
{
	local array<xUtil.PlayerRecord> PlayerRecords;
	local int i,j;

	Super.PostBeginPlay();

	// add RosterNames to roster
	class'xUtil'.static.GetPlayerList(PlayerRecords);
	for ( i=0; i<RosterNames.Length; i++ )
	{
		j = Roster.Length;
		Roster.Length = Roster.Length + 1;
		Roster[j] = class'xRosterEntry'.Static.CreateRosterEntryCharacter(RosterNames[i]);
	}
}

// Overrides UnrealTeamInfo to allow the ROPawn functionality
simulated function class<Pawn> NextLoadOut(class<Pawn> CurrentLoadout)
{
	local int i;
	local class<Pawn> Result;

	Result = ROAllowedTeamMembers[0];

	for ( i=0; i<ArrayCount(ROAllowedTeamMembers) - 1; i++ )
	{
		if ( ROAllowedTeamMembers[i] == CurrentLoadout )
		{
			if ( ROAllowedTeamMembers[i+1] != None )
				Result = ROAllowedTeamMembers[i+1];
			break;
		}
		else if ( ROAllowedTeamMembers[i] == None )
			break;
	}

	return Result;
}

function RosterEntry GetNamedBot(string botName)
{
	local array<xUtil.PlayerRecord> PlayerRecords;
	local xUtil.PlayerRecord PR;

	class'xUtil'.static.GetPlayerList(PlayerRecords);
	PR = class'xUtil'.static.FindPlayerRecord(botName);
	return class'xRosterEntry'.Static.CreateRosterEntry(PR.RecordIndex);
}

function Initialize(int TeamBots)
{
	local int i;

	for ( i=Roster.Length; i<TeamBots; i++ )
		AddRandomPlayer();

	for ( i=0; i<TeamBots; i++ )
		Roster[i].PrecacheRosterFor(self);
}

function FillPlayerTeam(GameProfile G)
{
	local int i,j, limit;

	limit = Min (G.LINEUP_SIZE, G.GetNumTeammatesForMatch());
	for ( i=0; i<limit; i++ )
	{
		j = Roster.Length;
		Roster.Length = Roster.Length + 1;
		Roster[j] = class'xRosterEntry'.Static.CreateRosterEntryCharacter(G.PlayerTeam[G.PlayerLineup[i]]);
		Roster[j].SetOrders(G.PlayerPositions[G.PlayerLineup[i]]);
	}
	TeamSymbolName = G.TeamSymbolName;
}

function RosterEntry GetRandomPlayer()
{
	local array<xUtil.PlayerRecord> PlayerRecords;
	local int RND,i, num;
	local int max, total;

	class'xUtil'.static.GetPlayerList(PlayerRecords);
	for ( i=0; i<PlayerRecords.Length; i++ )
		max += PlayerRecords[i].BotUse;

	RND = Rand(Max);

	for ( i=0; i<PlayerRecords.Length; i++ )
	{
		total += PlayerRecords[i].BotUse;
		if ( total >= RND )
			break;
	}
	num = i;

	if ( AvailableRecord(PlayerRecords[num].Menu) && !AlreadyExistsEntry(PlayerRecords[num].DefaultName,false) )
		return class'xRosterEntry'.Static.CreateRosterEntry(num);

	for ( i=num; i<PlayerRecords.Length; i++ )
		if ( AvailableRecord(PlayerRecords[i].Menu) && (PlayerRecords[i].BotUse > 0) && !AlreadyExistsEntry(PlayerRecords[i].DefaultName,false) )
			return class'xRosterEntry'.Static.CreateRosterEntry(i);

	for ( i=0; i<num; i++ )
		if ( AvailableRecord(PlayerRecords[i].Menu) && (PlayerRecords[i].BotUse > 0) && !AlreadyExistsEntry(PlayerRecords[i].DefaultName,false) )
			return class'xRosterEntry'.Static.CreateRosterEntry(i);

	return GetNamedBot("Jakob");
}

// Overriden to support RO's UPL stuff
function bool AvailableRecord(string MenuString)
{
	if(MenuString ~= "ROSP")
	{
		return true;
	}
	else
	{

		return ( (MenuString ~= "DUP") || (MenuString ~= "SP") || (MenuString ~= "") || (MenuString ~= "UNLOCK") );
	}
}

function bool AlreadyExistsEntry(string CharacterName, bool bNoRecursion)
{
	local int i;

	for ( i=0; i<Roster.Length; i++ )
		if ( (xRosterEntry(Roster[i]) != None) && (xRosterEntry(Roster[i]).PlayerName == CharacterName) )
			return true;

	if ( !bNoRecursion && UnrealTeamInfo(Level.Game.OtherTeam(self)) != None )
		return UnrealTeamInfo(Level.Game.OtherTeam(self)).AlreadyExistsEntry(CharacterName,true);
	return false;
}

function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	return true;
}

defaultproperties
{
}
