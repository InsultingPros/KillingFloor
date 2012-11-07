Class KFShadowProject extends ShadowProjector;

var KFPlayerController BaseController;
var array<KFMiscShadowProject> MiscShadows;
var bool bInitDir;

function Tick(float DeltaTime)
{
	local coords C;
	local int i,l,j,m;
	local float DotDir,Dist;
	local KFMiscShadowProject Sh;

	DetachProjector(true);

	if( BaseController==None )
	{
		BaseController = KFPlayerController(Level.GetLocalPlayerController());
		if( BaseController==None )
			return;
	}
	if( (ShadowActor != None) && !ShadowActor.bHidden && (Level.TimeSeconds - ShadowActor.LastRenderTime < 4) && (ShadowTexture != None) && bShadowActive )
	{
		if( ShadowTexture.Invalid )
			Destroy();
		else
		{
			if(RootMotion && ShadowActor.DrawType == DT_Mesh && ShadowActor.Mesh != None)
			{
				C = ShadowActor.GetBoneCoords('');
				SetLocation(C.Origin);
			}
			else
				SetLocation(ShadowActor.Location + vect(0,0,5));

			l = BaseController.LightSources.Length;
			m = MiscShadows.Length;
			LightDistance = Default.LightDistance;
			if( l>0 )
			{
				for( i=0; i<l; i++ )
				{
					C.XAxis = Location-BaseController.LightSources[i].Location;
					Dist = VSize(C.XAxis);
					if( Dist>BaseController.LightSources[i].LightRadius )
						continue;
					Dist = (Dist/BaseController.LightSources[i].LightRadius);
					C.XAxis = Normal(C.XAxis);
					DotDir = C.XAxis Dot vector(BaseController.LightSources[i].Rotation);
					if( DotDir>0.5 )
					{
						LightDistance*=FMin(1.75-DotDir,1.f)*(1.f-Dist);
						for( j=0; j<m; j++ )
						{
							Sh = MiscShadows[j];
							if( Sh.OwnerProj==BaseController.LightSources[i] )
							{
								Sh.bDoUpdate = true;
								Sh.SetLocation(Location);
								Sh.LightDirection = -C.XAxis;
								Sh.LightDistance = 1500.f*(DotDir-0.5)*(Dist*0.5+0.5);
								Sh.MaxTraceDistance = Sh.LightDistance;
								goto'LoopWasOK';
							}
						}
						Sh = AddMiscProjector(BaseController.LightSources[i],Location,-C.XAxis);
						Sh.bDoUpdate = true;
						Sh.LightDistance = 1500.f*(DotDir-0.5)*(Dist*0.5+0.5);
LoopWasOK:
					}
				}
			}
			MaxTraceDistance = LightDistance;
			for( j=0; j<m; j++ )
				if( !MiscShadows[j].bDoUpdate )
				{
					MiscShadows[j].Destroy();
					MiscShadows.Remove(j,1);
					m--;
					j--;
				}
			if( !bInitDir )
			{
				bInitDir = True;
				SetRotation(Rotator(-LightDirection));
			}

			ShadowTexture.Dirty = true;

			AttachProjector();
		}
	}
}
function UpdateShadow()
{
	Tick(0.f);
}
function KFMiscShadowProject AddMiscProjector( Actor GoalAct, vector Pos, vector Dir )
{
	local KFMiscShadowProject M;

	M = Spawn(Class'KFMiscShadowProject',Owner,,Pos);
	M.OwnerProj = GoalAct;
	M.ShadowActor = ShadowActor;
	M.bBlobShadow = bBlobShadow;
	M.LightDirection = Dir;
	M.LightDistance = 450;
	M.MaxTraceDistance = 500;
	M.InitShadow();
	MiscShadows[MiscShadows.Length] = M;
	return M;
}
simulated function Destroyed()
{
	local int i,l;

	Super.Destroyed();
	l = MiscShadows.Length;
	for( i=0; i<l; i++ )
		MiscShadows[i].Destroy();
	MiscShadows.Length = 0;
}

defaultproperties
{
     LightDistance=320.000000
     MaxTraceDistance=350
}
