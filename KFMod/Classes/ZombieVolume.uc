class ZombieVolume extends Volume;

struct KFDoorSelType
{
	var() edfindable KFDoorMover DoorActor;
	var() bool bOnlyWhenWelded;
};
var() float CanRespawnTime; // How long to save CanSpawn values before re-check
var() float TouchDisableTime; // How long time does this volume get disabled if a player touches it.
var() bool bMassiveZeds,bLeapingZeds,bNormalZeds,bRangedZeds; // The type of zombies that can spawn here.
var() float ZombieCountMulti; // Multiply zombie spawn count with this.
var() bool bVolumeIsEnabled;
var() array<int> DisabledWaveNums;
var() name ToggledEnabledEvent;
var() array< class<KFMonster> > OnlyAllowedZeds,DisallowedZeds;
var() float SpawnDesirability,MinDistanceToPlayer;
var() array<KFDoorSelType> RoomDoorsList;
var transient float LastCheckTime;
var transient bool bHasInitSpawnPoints;
var transient array<vector> SpawnPos;
var transient vector OldInitPos;
var()   bool    bDebugZombieSpawning;   // Set this to true to view zombie spawning debug in game
var     bool    bDebugZoneSelection;    // Set this to true to view zone selection debug in game
var     bool    bDebugSpawnSelection;   // Set this to true to view individual zombie spawning debugging
var     float   LastSpawnTime;          // Last time a zombie squad spawned here
var     float   LastFailedSpawnTime;    // Last time a zombie squad failed spawning here

var()   bool    bNoZAxisDistPenalty;    // Will ignore the Z axis distance when evaluating spawns. Helps if maps are large and hilly (wouldnt want to use this on a multi floored office building!)

/* tag to set on all Zombies spawned by this volume */
var(Events)							name						ZombieSpawnTag;

/* Death Event to set on all Zombies spawned by this volume */
var(Events)							name						ZombieDeathEvent;

/* Event to fire off every time this volume spawns any ZED*/
var(Events)                         name                        ZombieSpawnEvent;

/* array of all living Zombies spawned by this volume */
var									array<KFMonster>			ZEDList;

/* if true, ignore the lineofsight check in SpawnInHere() so that zombies can spawn in plain sight  */
var()		                        bool						bAllowPlainSightSpawns;

/* This volume is only used for spawning in Objective Mode */
var(Advanced)                       bool                        bObjectiveModeOnly;


// Init the spawn points of this actor
function PostBeginPlay()
{
	Super.PostBeginPlay();

	InitSpawnPoints();
}

function Reset()
{
	LastCheckTime = 0;
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    bVolumeIsEnabled = !bVolumeIsEnabled;
}

function NotifyNewWave( int CurWave )
{
	local int i,l;

	l = DisabledWaveNums.Length;
	for( i=0; i<l; i++ )
		if( DisabledWaveNums[i]==CurWave )
		{
			if( bVolumeIsEnabled )
			{
				bVolumeIsEnabled = False;
				TriggerEvent(ToggledEnabledEvent,Self,None);
			}
		}
	if( !bVolumeIsEnabled )
	{
		bVolumeIsEnabled = True;
		TriggerEvent(ToggledEnabledEvent,Self,None);
	}
}

// Reduces calls the CPU-heavy SpawnInHere function,
// at the cost of possibly returning occasional inaccurate values
function bool CanSpawnInHere( array< class<KFMonster> > zombies )
{
    if(bObjectiveModeOnly && !Level.Game.IsA('KFStoryGameInfo'))
    {
        return false;
    }

	if( LastCheckTime < Level.TimeSeconds )
	{
		//LastCheckTime = Level.TimeSeconds+CanRespawnTime;
		if( !bVolumeIsEnabled )
		{
            if(bDebugZoneSelection)
            {
                log("!CanSpawnInHere -> Reason =  !bVolumeIsEnabled ");
            }

        	return false;
        }

        if( SpawnPos.Length==0 )
        {
            if(bDebugZoneSelection)
            {
                log("!CanSpawnInHere -> Reason =  SpawnPos.Length == 0 ");
            }

			return false; // Failed to find ANY possible spawn points.
		}

		return SpawnInHere(zombies,true);
	}
	else
    {
        if(bDebugZoneSelection)
        {
            log("!CanSpawnInHere -> Reason =  LastCheckTime >= Level.TimeSeconds");
        }

        return false;
    }
}

//Experimental volume for spawning squads of zombies.
function bool SpawnInHere( out array< class<KFMonster> > zombies, optional bool test,
    optional out int numspawned, optional out int TotalMaxMonsters, optional int MaxMonstersAtOnceLeft,
    optional out int TotalZombiesValue, optional bool bTryAllSpawns )
{
	local int i,l,j,zc,yc;
	local KFMonster Act;
	local byte fl;
	local rotator RandRot;
	local vector TrySpawnPoint;
	local int NumTries;

	/* First make sure there are any zombie types allowed to spawn in here */
	l = zombies.Length;
	zc = DisallowedZeds.Length;
	yc = OnlyAllowedZeds.Length;
	for( i=0; i<l; i++ )
	{
		fl = zombies[i].Default.ZombieFlag;
		if( (!bNormalZeds && fl==0) || (!bRangedZeds && fl==1) || (!bLeapingZeds && fl==2) || (!bMassiveZeds && fl==3) )
			goto'RemoveEntry';
		if( zc==0 && yc==0 )
			continue;
		for( j=0; j<zc; j++ )
			if( ClassIsChildOf(zombies[i],DisallowedZeds[j]) )
				goto'RemoveEntry';

		if( yc>0 )
		{
			for( j=0; j<yc; j++ )
				if( ClassIsChildOf(zombies[i],OnlyAllowedZeds[j]) )
					goto'LoopEnd';
RemoveEntry:
			zombies.Remove(i,1);
			l--;
			i--;
		}
LoopEnd:
	}
	if( l==0 )
	{
	    if(bDebugZoneSelection)
        {
            log("!SpawnInHere -> Reason =  Zombie Squad array is empty! ");
        }

        return false;
    }

	if( !test )
	{
		if( ZombieCountMulti<1 )
			zombies.Length = Max(zombies.Length*ZombieCountMulti,1); // Decrease the size.
		else if( ZombieCountMulti>1 )
		{
			// Increase the size and scramble zombie spawn types.
			zombies.Length = Max(zombies.Length*(ZombieCountMulti/2+ZombieCountMulti*FRand()),zombies.Length);
			l = zombies.Length;
			for( i=0; i<l; i++ )
				if( zombies[i]==None )
					zombies[i] = zombies[Rand(i)];
		}
		if( zombies.Length==0 )
			return false;
	}

	/* Now do the actual spawning */
	if( !test )
	{
		l = zombies.Length;
		for( i=0; i<l; i++ )
		{
			if( TotalMaxMonsters>0 && MaxMonstersAtOnceLeft>0) // Always make sure we are allowed to spawn em.
			{
				RandRot.Yaw = Rand(65536);

                if( bTryAllSpawns )
                {
                    // Try spawning in all the points
                    NumTries = SpawnPos.Length;
                }
                else
                {
                    // Try spawning 3 times in 3 dif points.
                    NumTries = 3;
                }

                /* We need to clear this every time. */
                Act = none;

                for( j=0; j<NumTries; j++ )
		        {
                    TrySpawnPoint = SpawnPos[Rand(SpawnPos.Length)];
    				if( !PlayerCanSeePoint(TrySpawnPoint, zombies[i]) )
    				{
                        Act = Spawn(zombies[i],,,TrySpawnPoint,RandRot);
                    }
                    else
                    {
                        if( bDebugZoneSelection )
                        {
                            log("Failed trying to spawn "$zombies[i]$" attempt "$j);
                        }
                        continue;
                    }

    				if(Act!=None)
    				{
                        break;
    				}
				}

				if(Act!=None)
				{
                    // Triggers & Event Tracking
    				/* ========================================================================*/

					if(ZombieSpawnTag != '')
					{
						Act.Tag = ZombieSpawnTag ;
					}

					if(ZombieDeathEvent != '')
					{
						Act.Event = ZombieDeathEvent;
					}

					if(ZombieSpawnEvent != '')
					{
						TriggerEvent(ZombieSpawnEvent,self,Act);
					}

                    AddZEDToSpawnList(Act);

					/*==========================================================================*/

                    if( bDebugSpawnSelection )
                    {
                        DrawDebugCylinder(Act.Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),Act.CollisionRadius,Act.CollisionHeight,5,0, 255, 0);
                    }

    				if( bDebugZoneSelection )
    				{
                        log(self@"Spawned "$zombies[i]$" on attempt "$j);
                    }

					TotalMaxMonsters--;
					MaxMonstersAtOnceLeft--;
					numspawned++;
					TotalZombiesValue += Act.ScoringValue;
				}
    			else if( bDebugZoneSelection )
    			{
                    log(self@" completely failed spawning "$zombies[i]$" on attempt "$j);
    			}
			}
		}
		if( numspawned>0 )
		{
            LastSpawnTime = Level.TimeSeconds;
            LastFailedSpawnTime = 0;
            return true;
		}
		else
		{
            LastFailedSpawnTime = Level.TimeSeconds;
            return false;
		}
	}

	return true;
}

//Spawn squads of zombies in story mode. Has special handling to make sure the
// whole squad gets spawned properly.
function bool StorySpawnInHere( out array< class<KFMonster> > NextSpawnSquad, optional bool test,
    optional out int numspawned, optional out int TotalMaxMonsters, optional int MaxMonstersAtOnceLeft,
    optional out int TotalZombiesValue, optional bool bTryAllSpawns )
{
	local int i,l,j,zc,yc;
	local KFMonster Act;
	local byte fl;
	local rotator RandRot;
	local vector TrySpawnPoint;
	local int NumTries;
	Local array< class<KFMonster> > zombies;
	//local array int RemovedIndexes;
	local int k;

	zombies = NextSpawnSquad;

	/* First make sure there are any zombie types allowed to spawn in here */
	l = zombies.Length;
	zc = DisallowedZeds.Length;
	yc = OnlyAllowedZeds.Length;
	for( i=0; i<l; i++ )
	{
		fl = zombies[i].Default.ZombieFlag;
		if( (!bNormalZeds && fl==0) || (!bRangedZeds && fl==1) || (!bLeapingZeds && fl==2) || (!bMassiveZeds && fl==3) )
			goto'RemoveEntry';
		if( zc==0 && yc==0 )
			continue;
		for( j=0; j<zc; j++ )
			if( ClassIsChildOf(zombies[i],DisallowedZeds[j]) )
				goto'RemoveEntry';

		if( yc>0 )
		{
			for( j=0; j<yc; j++ )
				if( ClassIsChildOf(zombies[i],OnlyAllowedZeds[j]) )
					goto'LoopEnd';
RemoveEntry:
			zombies.Remove(i,1);
			l--;
			i--;
		}
LoopEnd:
	}
	if( l==0 )
	{
	    if(bDebugZoneSelection)
        {
            log("!SpawnInHere -> Reason =  Zombie Squad array is empty! ");
        }

        return false;
    }

	if( !test )
	{
		if( ZombieCountMulti<1 )
			zombies.Length = Max(zombies.Length*ZombieCountMulti,1); // Decrease the size.
		else if( ZombieCountMulti>1 )
		{
			// Increase the size and scramble zombie spawn types.
			zombies.Length = Max(zombies.Length*(ZombieCountMulti/2+ZombieCountMulti*FRand()),zombies.Length);
			l = zombies.Length;
			for( i=0; i<l; i++ )
				if( zombies[i]==None )
					zombies[i] = zombies[Rand(i)];
		}
		if( zombies.Length==0 )
			return false;
	}

	/* Now do the actual spawning */
	if( !test )
	{
		l = zombies.Length;
		for( i=0; i<l; i++ )
		{
			if( TotalMaxMonsters>0 && MaxMonstersAtOnceLeft>0) // Always make sure we are allowed to spawn em.
			{
				RandRot.Yaw = Rand(65536);

                if( bTryAllSpawns )
                {
                    // Try spawning in all the points
                    NumTries = SpawnPos.Length;
                }
                else
                {
                    // Try spawning 3 times in 3 dif points.
                    NumTries = 3;
                }

                /* We need to clear this every time. */
                Act = none;

                for( j=0; j<NumTries; j++ )
		        {
                    TrySpawnPoint = SpawnPos[Rand(SpawnPos.Length)];
    				if( !PlayerCanSeePoint(TrySpawnPoint, zombies[i]) )
    				{
                        Act = Spawn(zombies[i],,,TrySpawnPoint,RandRot);
                    }
                    else
                    {
                        if( bDebugZoneSelection )
                        {
                            log("Failed trying to spawn "$zombies[i]$" attempt "$j);
                        }
                        continue;
                    }

    				if(Act!=None)
    				{
                        break;
    				}
				}

				if(Act!=None)
				{
                    // Triggers & Event Tracking
    				/* ========================================================================*/

					if(ZombieSpawnTag != '')
					{
						Act.Tag = ZombieSpawnTag ;
					}

					if(ZombieDeathEvent != '')
					{
						Act.Event = ZombieDeathEvent;
					}

					if(ZombieSpawnEvent != '')
					{
						TriggerEvent(ZombieSpawnEvent,self,Act);
					}

                    AddZEDToSpawnList(Act);

					/*==========================================================================*/

                    if( bDebugSpawnSelection )
                    {
                        DrawDebugCylinder(Act.Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),Act.CollisionRadius,Act.CollisionHeight,5,0, 255, 0);
                    }

    				if( bDebugZoneSelection )
    				{
                        log(self@"Spawned "$zombies[i]$" on attempt "$j);
                    }

					TotalMaxMonsters--;
					MaxMonstersAtOnceLeft--;
					numspawned++;
					TotalZombiesValue += Act.ScoringValue;

                    for(k=0; k < NextSpawnSquad.length ; k++)
                    {
                        if( NextSpawnSquad[k] == zombies[i] )
                        {
                            NextSpawnSquad.Remove(k, 1);
                            if( bDebugZoneSelection )
                            {
                                log(self@" Removed: zombie "$zombies[i]$" from NextSpawnSquad because we spawned it");
                            }
                            break;
                        }
                    }
				}
    			else if( bDebugZoneSelection )
    			{
                    log(self@" completely failed spawning "$zombies[i]$" on attempt "$j);
    			}
			}
		}
		if( numspawned>0 )
		{
            LastSpawnTime = Level.TimeSeconds;
            LastFailedSpawnTime = 0;
            return true;
		}
		else
		{
            LastFailedSpawnTime = Level.TimeSeconds;
            return false;
		}
	}

	return true;
}

/* Returns true if the supplied Monster was spawned by this volume.  Using an array instead of tags for this
to give level designers greater flexibility.  ie. There could be situations where you'd want your Volume to have
a different tag than the ZEDS it spawns */

function	bool		ZombieWasSpawnedHere(KFMonster TestZombie , optional out int SpawnIdx)
{
	local int i;

	for(i = 0 ; i < ZEDList.length ; i ++)
	{
		if(ZEDList[i] == TestZombie)
		{
			SpawnIdx = i ;
			return true;
		}
	}

	return false;
}


function               AddZEDToSpawnList(KFMonster NewZED)
{
    ZEDList.Insert(ZEDList.length,1);
	ZEDList[ZEDList.length-1] = NewZED ;
	NewZED.SpawnVolume = self;
}

function               RemoveZEDFromSpawnList(KFMonster ExistingZED)
{
    local int ZEDIndex;

    if(ZombieWasSpawnedHere(ExistingZED,ZEDIndex))
    {
        ExistingZED.SpawnVolume = none;
        ZEDList.Remove(ZEDIndex,1);
    }
}

function bool PlayerCanSeePoint(vector TestLocation, class <KFMonster> TestMonster)
{
    local Controller C;
    local float dist;
    local vector Right, Test;
    local float CollRadius;

    if(bAllowPlainSightSpawns)
    {
        return false;
    }

	// Now make sure no player sees the spawn point.
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.Pawn!=none && C.Pawn.Health>0 && C.bIsPlayer )
		{
            dist = VSize(TestLocation - C.Pawn.Location);

            CollRadius = TestMonster.Default.CollisionRadius;
            CollRadius *= 1.1;
            Right = ((TestLocation - C.Pawn.Location) cross vect(0.f,0.f,1.f));
			Right = Normal(Right) * CollRadius;
			Test.Z = TestMonster.Default.CollisionHeight;
			Test.Z *= 1.25;

//			DrawStayingDebugLine(TestLocation,C.Pawn.Location + C.Pawn.EyePosition(),255,0,0);
//            DrawStayingDebugLine((TestLocation + Test) + Right,C.Pawn.Location + C.Pawn.EyePosition(),255,255,0);
//            DrawStayingDebugLine((TestLocation + Test) - Right,C.Pawn.Location + C.Pawn.EyePosition(),0,0,255);

            // Do three traces, one to the location, and one slightly above left and right of the collision
            // cylinder size so we don't see this zed spawn
            if( (!C.Pawn.Region.Zone.bDistanceFog || (dist < C.Pawn.Region.Zone.DistanceFogEnd)) &&
                FastTrace(TestLocation,C.Pawn.Location + C.Pawn.EyePosition()) &&
                FastTrace((TestLocation + Test) + Right,C.Pawn.Location + C.Pawn.EyePosition()) &&
                FastTrace((TestLocation + Test) - Right,C.Pawn.Location + C.Pawn.EyePosition()) )
            {
                if( bDebugZoneSelection || bDebugSpawnSelection)
                {
                    DrawStayingDebugLine(TestLocation + TestMonster.default.EyeHeight * vect(0,0,1),C.Pawn.Location + C.Pawn.EyePosition(),255,255,0);
                }
                return true;
            }
            else
            {
                if( bDebugZoneSelection || bDebugSpawnSelection)
                {
                    DrawStayingDebugLine(TestLocation + TestMonster.default.EyeHeight * vect(0,0,1),C.Pawn.Location + C.Pawn.EyePosition(),0,255,0);
                }
            }
        }
    }

    return false;
}

/* Code added by Marco, simple handler function for initilizing spawn points */
function InitSpawnPoints()
{
	local VolumeColTester Tst;
	local int x,y;
	local vector Pos;
	local vector PosOffset, NegOffset, TestOffset;
    local int i;
    local int StepSizeX, StepSizeY;
    local vector OffSet, AnotherOffset;

    if( bDebugZombieSpawning )
    {
        log("Initializing Spawn Point "$self);
    }

	OldInitPos = Location;
	bHasInitSpawnPoints = True;
	Tst = Spawn(Class'VolumeColTester');

	if( Tst == none )
	{
	   log(self$"couldn't spawn collision tester, move this volume!!!");
       return;
	}

	Tst.bCollideWhenPlacing = True;

    // Find the X and Y bounds of this volume
	for( i=0; i<=10; i++ )
	{
		TestOffset = Location;
		AnotherOffset = vect(0,0,0);
		AnotherOffset.X = (100 * i);
		TestOffset += AnotherOffset;

		if( !Tst.SetLocation(TestOffset) || !Encompasses(Tst) )
		{
        	//DrawDebugCylinder(TestOffset,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,255, 255, 0);
            break;
        }
        else
        {
            //DrawDebugCylinder(Tst.Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,0, 0, 255);
            PosOffset.X = AnotherOffset.X;//Tst.Location.X;
        }
	}

	for( i=0; i<=10; i++ )
	{
		TestOffset = Location;
		AnotherOffset = vect(0,0,0);
		AnotherOffset.Y = (100 * i);
		TestOffset += AnotherOffset;

		if( !Tst.SetLocation(TestOffset) || !Encompasses(Tst) )
		{
        	//DrawDebugCylinder(TestOffset,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,255, 255, 0);
            break;
        }
        else
        {
            //DrawDebugCylinder(Tst.Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,0, 0, 255);
            PosOffset.Y = AnotherOffset.Y;//Tst.Location.Y;
        }
	}

	for( i=0; i<=10; i++ )
	{
		TestOffset = Location;
		AnotherOffset = vect(0,0,0);
		AnotherOffset.X = (100 * -i);
		TestOffset += AnotherOffset;

		if( !Tst.SetLocation(TestOffset) || !Encompasses(Tst) )
		{
        	//DrawDebugCylinder(TestOffset,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,255, 255, 0);
            break;
        }
        else
        {
            //DrawDebugCylinder(Tst.Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,0, 0, 255);
            NegOffset.X = AnotherOffset.X;
        }
	}

	for( i=0; i<=10; i++ )
	{
		TestOffset = Location;
		AnotherOffset = vect(0,0,0);
		AnotherOffset.Y = (100 * -i);
		TestOffset += AnotherOffset;

		if( !Tst.SetLocation(TestOffset) || !Encompasses(Tst) )
		{
        	//DrawDebugCylinder(TestOffset,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,255, 255, 0);
            break;
        }
        else
        {
            //DrawDebugCylinder(Tst.Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,0, 0, 255);
            NegOffset.Y = AnotherOffset.Y;
        }
	}

    // Scale the space between spawn points to match the size of the volume
    StepSizeX = (Abs(NegOffset.X) + PosOffset.X)/10;

    if( StepSizeX < 56 )
    {
        StepSizeX = 56;
    }

    StepSizeY = (Abs(NegOffset.Y) + PosOffset.Y)/10;

    if( StepSizeY < 56 )
    {
        StepSizeY = 56;
    }

    // Search for places to spawn within the volume
	for( x=-5; x<=5; x++ )
	{
		for( y=-5; y<=5; y++ )
		{
            Pos = Location;
			OffSet.X=(StepSizeX*x);
			OffSet.Y=(StepSizeY*y);
			Pos += OffSet;

			// Just continue if the offset is out of bounds
			if( OffSet.X > 0 && OffSet.X > PosOffset.X )
			{
                continue;
			}
			else if( OffSet.X < 0 && OffSet.X < NegOffset.X )
			{
                continue;
			}

			if( OffSet.Y > 0 && OffSet.Y > PosOffset.Y )
			{
                continue;
			}
			else if( OffSet.Y < 0 && OffSet.Y < NegOffset.Y )
			{
                continue;
			}

			if( !Tst.SetLocation(Pos) || !Encompasses(Tst) || !FastTrace(Tst.Location+vect(0,0,22),Tst.Location-vect(0,0,22)) )
			{
            	if( bDebugZombieSpawning )
                {
                    DrawDebugCylinder(Pos,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,255, 0, 0);
                }
                continue;
            }
            else
            {
            	if( bDebugZombieSpawning )
                {
                    DrawDebugCylinder(Tst.Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),Tst.CollisionRadius,Tst.CollisionHeight,5,0, 255, 0);
                }
            }
			SpawnPos[SpawnPos.Length] = Tst.Location;
		}
	}

	if( SpawnPos.Length==0 )
	{
	   log("No Spawn points found for "$self$"!!!!!!!!!!!!!");
	}
	Tst.Destroy();
}

// Draw a debugging cylinder
simulated function DrawDebugCylinder(vector Base,vector X, vector Y,vector Z, FLOAT Radius,float HalfHeight,int NumSides, byte R, byte G, byte B)
{
	local float AngleDelta;
	local vector LastVertex, Vertex;
	local int SideIndex;
	//Color = Color.RenderColor();

	AngleDelta = 2.0f * PI / NumSides;
	LastVertex = Base + X * Radius;

	for(SideIndex = 0;SideIndex < NumSides;SideIndex++)
	{
		Vertex = Base + (X * Cos(AngleDelta * (SideIndex + 1)) + Y * Sin(AngleDelta * (SideIndex + 1))) * Radius;

		DrawStayingDebugLine(LastVertex - Z * HalfHeight,Vertex - Z * HalfHeight,R,G,B);
		DrawStayingDebugLine(LastVertex + Z * HalfHeight,Vertex + Z * HalfHeight,R,G,B);
		DrawStayingDebugLine(LastVertex - Z * HalfHeight,LastVertex + Z * HalfHeight,R,G,B);

		LastVertex = Vertex;
	}
}

// Calculate spawning cost.
function float RateZombieVolume(KFGameType KFGT, ZombieVolume LastSpawnedVolume, Controller SpawnCloseTo, optional bool bIgnoreFailedSpawnTime, optional bool bBossSpawning)
{
	local Controller C;
	local float Score;
	local float dist;
	local byte i,l;
	local float PlayerDistScoreZ, PlayerDistScoreXY, TotalPlayerDistScore, UsageScore;
	local vector LocationZ, LocationXY, TestLocationZ, TestLocationXY;
	local bool bTooCloseToPlayer;

    if( bDebugZoneSelection )
    {
        DrawStayingDebugLine(Location,SpawnCloseTo.Pawn.Location,255,255,0);
    }

    if( !bIgnoreFailedSpawnTime && Level.TimeSeconds - LastFailedSpawnTime < 5.0 )
    {
        if( bDebugZoneSelection )
        {
            log(self$" RateZombieVolume LastFailedSpawnTime < 5 seconds, returning");
            DrawDebugCylinder(Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),SpawnCloseTo.Pawn.CollisionRadius,SpawnCloseTo.Pawn.CollisionHeight,5,255, 0, 0);
        }
        return -1;
    }

	l = RoomDoorsList.Length;
	for( i=0; i<l; i++ )
	{
		if( RoomDoorsList[i].DoorActor==None )
			continue;
		if( (!RoomDoorsList[i].bOnlyWhenWelded && RoomDoorsList[i].DoorActor.KeyNum==0) || RoomDoorsList[i].DoorActor.bSealed )
		{
            if( bDebugZoneSelection )
            {
        		  log(self$" RateZombieVolume doors welded or shut, returning");
        		  DrawDebugCylinder(Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),SpawnCloseTo.Pawn.CollisionRadius,SpawnCloseTo.Pawn.CollisionHeight,5,255, 0, 0);
            }

        	return -1;
		}
	}
	if( !CanSpawnInHere(KFGT.NextSpawnSquad) )
	{
        if( bDebugZoneSelection )
        {
            log(self$" RateZombieVolume !CanSpawnInHere, returning");
            DrawDebugCylinder(Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),SpawnCloseTo.Pawn.CollisionRadius,SpawnCloseTo.Pawn.CollisionHeight,5,255, 0, 0);
        }

    	return -1;
	}

    // Start score with Spawn desirability
	Score = SpawnDesirability;

    if( bDebugZoneSelection )
    {
        log(self$" RateZombieVolume initial Score = "$Score$" SpawnDesirability = "$SpawnDesirability);
    }

    // Rate how long its been since this spawn was used
    UsageScore = FMin(Level.TimeSeconds - LastSpawnTime,30.0)/30.0;

    if( bDebugZoneSelection )
    {
        log(self$" RateZombieVolume Usage UsageScore = "$UsageScore$" Time = "$(Level.TimeSeconds - LastSpawnTime));
    }

    LocationZ = Location * vect(0,0,1);
    LocationXY = Location * vect(1,1,0);

	// Now make sure no player sees the spawn point.
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.Pawn!=none && C.Pawn.Health>0 && C.bIsPlayer )
		{
		    // If there is a player inside this volume, return
            if( Encompasses(C.Pawn) )
            {
                if( bDebugZoneSelection )
                {
                    log(self$" RateZombieVolume player in volume, returning");
                    DrawDebugCylinder(Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),SpawnCloseTo.Pawn.CollisionRadius,SpawnCloseTo.Pawn.CollisionHeight,5,255, 0, 0);
            	}
                return -1;
            }

            // Rate the Volume on how close it is to the players.
            TestLocationZ = C.Pawn.Location * vect(0,0,1);
            TestLocationXY = C.Pawn.Location * vect(1,1,0);

        	PlayerDistScoreZ = FClamp(250.f-VSize(TestLocationZ-LocationZ),1.f,250.f)/250.0;
        	PlayerDistScoreXY = FClamp(2000.f-VSize(TestLocationXY-LocationXY),1.f,2000.f)/2000.0;

        	if( bNoZAxisDistPenalty )
        	{
        	    TotalPlayerDistScore += PlayerDistScoreXY/KFGT.NumPlayers;
        	}
        	else
        	{
            	// Weight the XY distance much higher than the Z dist. This gets zombies spawning more
            	// on the same level as the player
            	TotalPlayerDistScore += ((PlayerDistScoreZ * 0.3) + (PlayerDistScoreXY * 0.7))/KFGT.NumPlayers;
            }

            if( bDebugZoneSelection )
            {
                log(self$" RateZombieVolume Player DistCheck DistXY = "$VSize(TestLocationXY-LocationXY)/50.0$"m DistZ = "$VSize(TestLocationZ-LocationZ)/50.0$"m");
                log(self$" RateZombieVolume Player DistCheck PlayerDistScoreZ = "$PlayerDistScoreZ$" PlayerDistScoreXY = "$PlayerDistScoreXY);
            }

			dist = VSize(Location - C.Pawn.Location);

            // If the zone is too close to a boss character, reduce its desirability
        	if( bBossSpawning )
        	{
                if( dist < 1000.0 ) // 20 meters
                {
                    if( bDebugZoneSelection )
                    {
                        log(self$" too close to player, dist = "$(dist/50.0)$"m");
                    }
                    bTooCloseToPlayer = true;
                }
        	}

			// Do individual checks for spawn locations now, maybe add this back in later as an optimization
            // if fog doesn't hide spawn & lineofsight possible
			if( !bAllowPlainSightSpawns && ((!C.Pawn.Region.Zone.bDistanceFog || (dist < C.Pawn.Region.Zone.DistanceFogEnd)) && FastTrace(Location,C.Pawn.Location + C.Pawn.EyePosition())) )
			{
                if( bDebugZoneSelection )
                {
                	log(self$" RateZombieVolume player can see this zone, returning");
                	DrawDebugCylinder(Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),SpawnCloseTo.Pawn.CollisionRadius,SpawnCloseTo.Pawn.CollisionHeight,5,255, 0, 0);
            	}
                return -1;
            }
			else if( dist<MinDistanceToPlayer )
			{
                if( bDebugZoneSelection || bDebugSpawnSelection )
                {
                    log(self$" RateZombieVolume player too close to zone, returning dist = "$dist$" MinDistanceToPlayer = "$MinDistanceToPlayer);
                    DrawDebugCylinder(Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),SpawnCloseTo.Pawn.CollisionRadius,SpawnCloseTo.Pawn.CollisionHeight,5,255, 0, 0);
            	}

            	return -1;
			}
		}
	}

    if( bDebugZoneSelection )
    {
        log(self$" RateZombieVolume Player DistCheck TotalPlayerDistScore = "$TotalPlayerDistScore);
    }

	// Spawning score is 30% SpawnDesirability, 30% Distance from players, 30% when the spawn was last used, 10% random
    Score = (Score * 0.30) +  (TotalPlayerDistScore * ( Score * 0.30)) + (UsageScore * ( Score * 0.30)) + (FRand() * ( Score * 0.10));

    if( bTooCloseToPlayer )
    {
        Score*=0.2;

        // if the zone is too close to a boss character, reduce its desirability
        if( bDebugZoneSelection )
        {
            log(self$" bTooCloseToPlayer, *= .2 new Score = "$Score);
        }
    }

//    log("*** Base Score Part = "$(Score * 0.15));
//    log("*** Dist Score Part = "$(TotalPlayerDistScore * ( Score * 0.15)));
//    log("*** UsageScore Score Part = "$(UsageScore * ( Score * 0.70)));

	// Try and prevent spawning in the same volume back to back
    if( LastSpawnedVolume != none && LastSpawnedVolume==self )
	{
		Score*=0.2;

        if( bDebugZoneSelection )
        {
            log(self$" RateZombieVolume just used, *= .2 new Score = "$Score);
        }
	}

    if( bDebugZoneSelection )
    {
        log(self$" RateZombieVolume final Score = "$Score);
        log("******");

        DrawDebugCylinder(Location,vect(1,0,0),vect(0,1,0),vect(0,0,1),SpawnCloseTo.Pawn.CollisionRadius * ((Score/2000) * 2),SpawnCloseTo.Pawn.CollisionHeight * ((Score/2000) * 2),5,0, 255, 0);
    }

	// if we get here, return at least a 1
	return FMax(Score,1);
}

function Touch( Actor Other )
{
	if( KFHumanPawn(Other)!=None )
		LastCheckTime = Level.TimeSeconds+TouchDisableTime; // Disable me for ~30 seconds.
	Super.Touch(Other);
}

defaultproperties
{
     CanRespawnTime=1.500000
     TouchDisableTime=10.000000
     bMassiveZeds=True
     bLeapingZeds=True
     bNormalZeds=True
     bRangedZeds=True
     ZombieCountMulti=1.000000
     bVolumeIsEnabled=True
     SpawnDesirability=3000.000000
     MinDistanceToPlayer=600.000000
     bStatic=False
     RemoteRole=ROLE_None
}
