Class ClassicPlayerController extends KFPlayerController
    config(ClassicPlayer);

var transient float NextSpectateChange;

var ClassicPerkManager PerkManager;
var class<ClassicPerkManager> PerkManagerClass;
var class<KFGUI_Page> MidGameMenuClass, LobbyMenuClass, FlashUIClass, TraderMenuClass;

var UI_LobbyMenu LobbyMenu;
var UI_TraderMenu TraderMenu;
var UI_MainChatBox CurrentChatBox;
var UIP_ColorSettings ColorSettingMenu;

var ClassicPerk_Base PendingPerk;
var int DropCount;

var KFEventHelper EventHelper;

var string ServerMOTD, PendingMOTD;

struct SChatColorInfo
{
    var string Tag, HexColor;
};
var globalconfig array<SChatColorInfo> ColorTags;

var transient KF2GUIController GUIController;
var transient UIP_PerkSelection PerkSelectionBox;
var transient KFHUDInterface HUDInterface;

var config int SelectedEmoteIndex, ConfigVer;
var globalconfig string ControllerType;
var globalconfig array<name> FavoriteWeaponClassNames;

// UBOOL is packed together and you lose the packing if the bool vars are seperated.
var bool bBehindView, OldDrawCrosshair, bSetPerk, bMOTDReceived, bPlayerNeedsPerkUpdate;
var globalconfig bool bHideKillMsg, bSetupBindings;

replication
{
    if( bNetDirty )
        MidGameMenuClass, LobbyMenuClass, FlashUIClass, TraderMenuClass, PendingPerk, bPlayerNeedsPerkUpdate, PerkManager, bSetPerk;
}

simulated function PostBeginPlay()
{
    local SChatColorInfo TagInfo;
    local ClassicPlayerInput Input;
    
    EventHelper = class'KFEventHelper'.static.FindEventHelper(WorldInfo);

    Super.PostBeginPlay();
    
    if( WorldInfo.NetMode != NM_Client && PerkManager == None )
    {
        PerkManager = Spawn(PerkManagerClass, Self);
        PerkManager.PlayerOwner = Self;
        PerkManager.PRIOwner = ClassicPlayerReplicationInfo(PlayerReplicationInfo);
    }
    
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if( !bSetupBindings )
        {
            Input = ClassicPlayerInput(PlayerInput);
            if( Input != None )
            {
                Input.default.Bindings = class'KFPlayerInput'.default.Bindings;
                Input.default.bRequiresPushToTalk = class'KFPlayerInput'.default.bRequiresPushToTalk;
                Input.default.GamepadButtonHoldTime = class'KFPlayerInput'.default.GamepadButtonHoldTime;
                Input.default.AutoUpgradeHoldTime = class'KFPlayerInput'.default.AutoUpgradeHoldTime;
                Input.default.SprintAnalogThreshold = class'KFPlayerInput'.default.SprintAnalogThreshold;
                Input.default.bUseGamepadLastWeapon = class'KFPlayerInput'.default.bUseGamepadLastWeapon;
                Input.default.bAimAssistEnabled = class'KFPlayerInput'.default.bAimAssistEnabled;
                Input.default.ZoomedSensitivityScale = class'KFPlayerInput'.default.ZoomedSensitivityScale;
                Input.default.GamepadZoomedSensitivityScale = class'KFPlayerInput'.default.GamepadZoomedSensitivityScale;
                Input.default.bViewAccelerationEnabled = class'KFPlayerInput'.default.bViewAccelerationEnabled;
                Input.default.MouseSensitivity = class'KFPlayerInput'.default.MouseSensitivity; 
                Input.default.bInvertMouse = class'KFPlayerInput'.default.bInvertMouse; 
                Input.default.bEnableMouseSmoothing = class'KFPlayerInput'.default.bEnableMouseSmoothing; 
                Input.static.StaticSaveConfig();
            }
            
            bSetupBindings = true;
        }
        
        if( ConfigVer < 1 )
        {
            TagInfo.Tag = "^0";
            TagInfo.HexColor = "010101";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^1";
            TagInfo.HexColor = "C80101";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^2";
            TagInfo.HexColor = "01C801";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^3";
            TagInfo.HexColor = "C8C801";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^4";
            TagInfo.HexColor = "0101FF";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^5";
            TagInfo.HexColor = "01FFFF";
            ColorTags.AddItem(TagInfo);

            TagInfo.Tag = "^6";
            TagInfo.HexColor = "C800C8";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^7";
            TagInfo.HexColor = "C8C8C8";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^8";
            TagInfo.HexColor = "F4EDCD";
            ColorTags.AddItem(TagInfo);        
            
            TagInfo.Tag = "^9";
            TagInfo.HexColor = "808080";
            ColorTags.AddItem(TagInfo);            
            
            TagInfo.Tag = "^w$";
            TagInfo.HexColor = "FFFFFF";
            ColorTags.AddItem(TagInfo);
        
            TagInfo.Tag = "^r$";
            TagInfo.HexColor = "FF0101";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^g$";
            TagInfo.HexColor = "01FF01";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^b$";
            TagInfo.HexColor = "0101FF";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^y$";
            TagInfo.HexColor = "FFFF01";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^c$";
            TagInfo.HexColor = "01FFFF";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^o$";
            TagInfo.HexColor = "FF8C01";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^u$";
            TagInfo.HexColor = "FF1493";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^s$";
            TagInfo.HexColor = "01C0FF";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^n$";
            TagInfo.HexColor = "8B4513";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^W$";
            TagInfo.HexColor = "708A90";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^R$";
            TagInfo.HexColor = "840101";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^G$";
            TagInfo.HexColor = "018401";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^B$";
            TagInfo.HexColor = "010184";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^Y$";
            TagInfo.HexColor = "FFC001";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^C$";
            TagInfo.HexColor = "01A0C0";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^O$";
            TagInfo.HexColor = "FF4501";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^U$";
            TagInfo.HexColor = "A020F0";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^S$";
            TagInfo.HexColor = "4169FF";
            ColorTags.AddItem(TagInfo);
            
            TagInfo.Tag = "^N$";
            TagInfo.HexColor = "502814";
            ColorTags.AddItem(TagInfo);
        
            ConfigVer = 1;
        }
        
        if( ConfigVer < 2 )
        {
            ControllerType = "Xbox One";
            ConfigVer = 2;
        }
        
        SaveConfig();
    }
        
    if( WorldInfo.NetMode==NM_Client )
        OldDrawCrosshair = KFHudBase(myHUD).bDrawCrosshair;
        
    UpdateSeasonalState();
    bSkipNonCriticalForceLookAt = true;
}

reliable client function ClientSetHUD(class<HUD> newHUDType)
{
    Super.ClientSetHUD(newHUDType);
    HUDInterface = KFHUDInterface(myHUD);
}

simulated event name GetSeasonalStateName()
{
    if( EventHelper == None )
    {
        EventHelper = class'KFEventHelper'.static.FindEventHelper(WorldInfo);
        if( EventHelper == None )
            return 'No_Event';
    }
        
    switch( EventHelper.GetEventType() )
    {
        case EV_SUMMER:
            return 'Summer_Sideshow';
        case EV_WINTER:
            return 'Winter';
        case EV_FALL:
            return 'Fall';
        case EV_SPRING:
        case EV_NORMAL:
        default:
            return 'No_Event';
    }

    return 'No_Event';
}

function OpenLobbyMenu()
{
    if( HUDInterface == None || HUDInterface.GUIController == None )
        return;
        
    if( !PlayerReplicationInfo.bOnlySpectator )
    {
        GUIController = HUDInterface.GUIController;
        GUIController.OpenMenu(LobbyMenuClass);
    }
}

reliable client function ClientSetCountdown(bool bFinalCountdown, byte CountdownTime, optional NavigationPoint PredictedSpawn)
{
    Super.ClientSetCountdown(bFinalCountdown, CountdownTime, PredictedSpawn);
    
    if( LobbyMenu != None )
    {
        LobbyMenu.SetFinalCountdown(bFinalCountdown, CountdownTime);
    }
}

function OpenChatBox()
{
    if( LobbyMenu != None && !LobbyMenu.bViewMapClicked )
        return;
    
    if( HUDInterface != None && HUDInterface.ChatBox != None )
    {
        IgnoreLookInput(true);
        
        HUDInterface.ChatBox.SetVisible(true);
        HUDInterface.ChatBox.CurrentTextChatChannel = CurrentTextChatChannel;
        
        switch(CurrentTextChatChannel)
        {
            case ETCC_ALL:
                HUDInterface.ChatBox.WindowTitle = "Chat Box - All";
                break;
            case ETCC_TEAM:
                HUDInterface.ChatBox.WindowTitle = "Chat Box - Team";
                break;
        }
    }
}

function CloseChatBox()
{
    if( HUDInterface != None && HUDInterface.ChatBox != None )
    {
        IgnoreLookInput(false);
        HUDInterface.ChatBox.SetVisible(false);
    }
}

function OpenTraderMenu( optional bool bForce=false )
{
    local KFInventoryManager KFIM;

    SyncInventoryProperties();

    if( Role == ROLE_Authority && Pawn != none )
    {
        KFIM = KFInventoryManager(Pawn.InvManager);
        if( KFIM != none && !KFIM.bServerTraderMenuOpen )
        {
            KFIM.bServerTraderMenuOpen = true;
            ClientOpenTraderMenu(bForce);
        }
    }
}

reliable client function ClientOpenTraderMenu( optional bool bForce=false )
{
    if( Role < ROLE_Authority && !KFGameReplicationInfo(WorldInfo.GRI).bTraderIsOpen && !bForce )
    {
        return;
    }

    SyncInventoryProperties();
    GUIController.OpenMenu(TraderMenuClass);
}

function CloseTraderMenu()
{
    if( TraderMenu != None )
        TraderMenu.DoClose();
}

reliable client function ClientSetCameraMode( name NewCamMode )
{
    Super.ClientSetCameraMode(NewCamMode);
    
    if( HUDInterface != None && HUDInterface.SpectatorInfo != None )
    {
        if( NewCamMode == 'FirstPerson' && ViewTarget == self )
        {
            HUDInterface.SpectatorInfo.SetSpectatedPRI(None);
        }
    }
}

function NotifyChangeSpectateViewTarget()
{
    local KFPlayerReplicationInfo KFPRI;
    local KFPawn KFP;

    if( WorldInfo.GRI == none || WorldInfo.GRI.ElapsedTime < 2.f || ViewTarget == LocalCustomizationPawn )
    {
        return;
    }
    
    if( LocalCustomizationPawn != none && !LocalCustomizationPawn.bPendingDelete )
    {
        if( MyGFxManager != none && MyGFxManager.CurrentMenu != none && MyGFxManager.CurrentMenu == MyGFxManager.GearMenu )
        {
            MyGFxManager.CloseMenus();
        }
        LocalCustomizationPawn.Destroy();
    }
    
    if( HUDInterface != None && HUDInterface.SpectatorInfo != None )
    {
        KFP = KFPawn( ViewTarget );
        if( KFP != none )
        {
            if( KFP == Pawn && Pawn.IsAliveAndWell() )
            {
                return;
            }

            if( KFP.PlayerReplicationInfo != None )
            {
                KFPRI = KFPlayerReplicationInfo(KFP.PlayerReplicationInfo);
            }
            else
            {
                KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
            }
        }
        else if( ViewTarget == self )
        {
            KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
        }

        if( KFPRI != None)
        {
            HUDInterface.SpectatorInfo.SetSpectatedPRI(KFPRI);
        }
    }
}

function Restart(bool bVehicleTransition)
{
    Super.Restart(bVehicleTransition);
    ChangePerks(PendingPerk, true);
}

reliable client function ClientRestart(Pawn NewPawn)
{
    Super.ClientRestart(NewPawn);
    
    if(MyGFxHUD != None && MyGFxHUD.SpectatorInfoWidget != None)
    {
        MyGFxHUD.SpectatorInfoWidget.SetVisible(false);
    }
    
    if( KFPawn_Customization(NewPawn) == None && LobbyMenu != None )
    {
        LobbyMenu.DoClose();
    }
    
    if( HUDInterface != None && HUDInterface.SpectatorInfo != None )
    {
        HUDInterface.SpectatorInfo.SetVisibility(PlayerReplicationInfo.bOnlySpectator);
    }
}

exec function StartFire( optional byte FireModeNum )
{
    local KFInventoryManager KFIM;

    if( bCinematicMode )
    {
        return;
    }

    if (!KFPlayerInput(PlayerInput).bQuickWeaponSelect)
    {
        if( HUDInterface != None && HUDInterface.bDisplayInventory )
        {
            KFIM = KFInventoryManager( Pawn.InvManager );
            KFIM.SetCurrentWeapon( KFIM.PendingWeapon );
            return;
        }
    }
    
    if (KFPlayerInput(PlayerInput).bGamepadWeaponSelectOpen )
    {
        KFPlayerInput(PlayerInput).bGamepadWeaponSelectOpen = false;
    }

    if (MyGFxHUD != none && MyGFxHUD.VoiceCommsWidget != none && MyGFxHUD.VoiceCommsWidget.bActive)
    {
        return;
    }

    super.StartFire( FireModeNum );
}

reliable client function ReceiveServerMOTD( string S, bool bFinal )
{
    ServerMOTD $= S;
    bMOTDReceived = bFinal;
}

function StartSpectate( optional Name SpectateType )
{
    Super.StartSpectate();
    ForceSpectatorInput();
}

function ForceSpectatorInput()
{
    local KFGFxMoviePlayer_HUD GFXHUD;
    
    IgnoreMoveInput(false);
    IgnoreLookInput(false);
    
    if( HUDInterface != None )
    {
        GFXHUD = HUDInterface.HudMovie;
        if( GFXHUD != None )
        {
            GFXHUD.SetMovieCanReceiveFocus(false);
            GFXHUD.SetMovieCanReceiveInput(false);
            GFXHUD.bIgnoreMouseInput = true;
        }
    }
    
    ServerCamera('FreeCam');
    ServerViewNextPlayer();
}

simulated function NotifyTraderDoshChanged()
{
    if( TraderMenu != None )
    {
        GetPurchaseHelper().NotifyDoshChanged();
    }
}

function SetHaveUpdatePerk( bool bUsedUpdate )
{
    if( KFGameReplicationInfo(WorldInfo.GRI).bMatchHasBegun )
    {
        bPlayerNeedsPerkUpdate = bUsedUpdate;
    }
}

function bool GetHaveUpdatePerk()
{
    return bPlayerNeedsPerkUpdate;
}

function AwardXP( int XP )
{
    if( WorldInfo.NetMode!=NM_Client && PerkManager!=None )
        PerkManager.EarnedEXP(XP);
}

function OnPlayerXPAdded(INT XP, class<KFPerk> PerkClass)
{
    AwardXP(XP);
}

simulated function bool CanUpdatePerkInfoEx()
{
    return !bSetPerk;
}

simulated function bool WasPerkUpdatedThisRoundEx()
{
    return bSetPerk;
}

function bool CanApplyPerk( ClassicPerk_Base P )
{
    return (KFGameReplicationInfo(WorldInfo.GRI).CanChangePerks() && CanUpdatePerkInfoEx()) || !KFGameReplicationInfo(WorldInfo.GRI).bMatchHasBegun;
}

function bool ShouldApplyPendingPerk( ClassicPerk_Base P )
{
    return P == PendingPerk && CanApplyPerk(P);
}

function ChangePerks( ClassicPerk_Base P, optional bool bForce=false )
{    
    local ClassicPlayerReplicationInfo PRI;
    
    if( P == None )
        return;
        
    SetSavedPerkIndex(GetPerkIndexFromClass(P.Class));
        
    if( P == CurrentPerk )
    {
        if( PendingPerk!=None )
        {
            SetHaveUpdatePerk(false);
            PendingPerk = None;
        }
    }
    else if( CurrentPerk==None || (PendingPerk != None && ShouldApplyPendingPerk(P)) || CanApplyPerk(P) || bForce )
    {
        if( PendingPerk != None )
        {
            SetHaveUpdatePerk(false);
            PendingPerk = None;
        }
        
        CurrentPerk = P;
        
        PRI = ClassicPlayerReplicationInfo(PlayerReplicationInfo);
        if( PRI != None )
        {
            PRI.CurrentPerkClass = P.Class;
            PRI.CurrentPerkLevel = P.GetLevel();
            PRI.NetPerkIndex = GetPerkIndexFromClass(P.Class);
        }
        
        if( Pawn != None )
        {
            ClassicPerk_Base(CurrentPerk).PostPerkUpdate(Pawn);
        }
        
        if( KFPlayerReplicationInfo(PlayerReplicationInfo).bHasSpawnedIn && !bForce )
        {
            bSetPerk = true;
        }
    }
    else
    {
        PendingPerk = P;
    }
}

reliable server function ServerChangePerks( ClassicPerk_Base P )
{
    ChangePerks(P);
}

reliable client function ClientKillMessage( class<DamageType> DamType, PlayerReplicationInfo Victim, PlayerReplicationInfo KillerPRI, optional class<Pawn> KillerPawn )
{
    if( Player==None || Victim==None )
        return;
    
    if( Victim==KillerPRI || (KillerPRI==None && KillerPawn==None) )
    {
        if( Victim.GetTeamNum()==0 )
        {
            class'KFMusicStingerHelper'.static.PlayPlayerDiedStinger(Self);
        }
    }
    else
    {
        if( KillerPRI!=None && Victim.Team!=None && Victim.Team==KillerPRI.Team )
        {
            class'KFMusicStingerHelper'.static.PlayTeammateDeathStinger(Self);
        }
        else
        {
            class'KFMusicStingerHelper'.static.PlayZedKillHumanStinger(Self);
        }
    }
}

reliable client function ReceiveKillMessage( class<Pawn> Victim, optional bool bGlobal, optional PlayerReplicationInfo KillerPRI )
{
    if( bHideKillMsg || (bGlobal && KillerPRI==None) )
        return;
        
    if( HUDInterface!=None && Victim!=None )
        HUDInterface.AddKillMessage(Victim,1,KillerPRI,byte(bGlobal));
}

function SetSavedPerkIndex( byte NewSavedPerkIndex )
{
    SavedPerkIndex = NewSavedPerkIndex;
    ClientSetSavedPerkIndex(NewSavedPerkIndex);
}

reliable client function ClientSetSavedPerkIndex( byte NewSavedPerkIndex )
{
    SavedPerkIndex = NewSavedPerkIndex;
}

reliable client function SetPerkStaticLevel( byte Index, byte Level )
{
    if( PerkList.Length > 0 )
    {
        PerkList[Index].PerkLevel = Level;
    }
}

function float GetPerkLevelProgressPercentage(Class<KFPerk> PerkClass, optional out int CurrentVetLevelEXP, optional out int NextLevelEXP)
{
    local ClassicPerk_Base Perk;
    
    Perk = PerkManager.FindPerk(PerkClass);
    if( Perk != None )
    {
        CurrentVetLevelEXP = Perk.CurrentEXP;
        NextLevelEXP = Perk.NextLevelEXP;
        
        return Perk.GetProgressPercent();
    }
    
    return Super.GetPerkLevelProgressPercentage(PerkClass, CurrentVetLevelEXP, NextLevelEXP);
}

function int GetPerkXP(class<KFPerk> PerkClass)
{
    local ClassicPerk_Base P;
    
    P = PerkManager.FindPerk(PerkClass);
    if( P != None )
    {
        return P.CurrentEXP;
    }
    
    return Super.GetPerkXP(PerkClass);
}

function UpdateZEDTimeEffects(float DeltaTime)
{
    local KFPawn KFP;
    local float ZedTimeAudioModifier;

    if ( TargetZEDTimeEffectIntensity == PartialZEDTimeEffectIntensity )
    {
        KFP = KFPawn(Pawn);
        if ( KFP != None && !KFP.bUnaffectedByZedTime )
        {
            ClientEnterZedTime(false);
        }
    }

    if( WorldInfo.TimeDilation != LastTimeDilation )
    {
        ZedTimeAudioModifier = Max((1.0 - WorldInfo.TimeDilation) * 100, 0);
        SetRTPCValue( 'ZEDTime_Modifier', ZedTimeAudioModifier, true );
        LastTimeDilation = WorldInfo.TimeDilation;
    }
}

reliable server function ServerItemDropGet( string Item )
{
    if( DropCount>5 || Len(Item)>100 )
        return;
    ++DropCount;
    WorldInfo.Game.Broadcast(Self,PlayerReplicationInfo.GetHumanReadableName()$" got item: "$Item);
}

reliable server function ChangeSpectateMode( bool bSpectator )
{
    OnSpectateChange(Self,bSpectator);
}
simulated reliable client function ClientSpectateMode( bool bSpectator )
{
    UpdateURL("SpectatorOnly",(bSpectator ? "1" : "0"),false);
}
Delegate OnSpectateChange( ClassicPlayerController PC, bool bSpectator );

reliable client event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
    local string MessageStr, KeyName, FinalString;
    local string LeftBracket, RightBracket;
    local array<String> StringArray;
    
    if( class<KFLocalMessage_Priority>(Message) != None )
    {
        switch ( Switch )
        {
            case GMT_WaveSBoss:
                if(!PlayerReplicationInfo.bOnlySpectator && PlayerReplicationInfo.bReadyToPlay)
                {
                    if( LEDEffectsManager != none )
                    {
                        LEDEffectsManager.PlayEffectWaveIncoming();
                    }
                    
                    if( MyGfxManager != none )
                    {
                        if( MyGfxManager.bMenusOpen )
                        {
                            MyGfxManager.CloseMenus(true);
                        }
                    }
                }
            case GMT_WaveStart:
            case GMT_WaveStartWeekly:
            case GMT_WaveStartSpecial:
                class'KFMusicStingerHelper'.static.PlayWaveStartStinger( self, Switch );
                return;
            case GMT_WaveEnd:
                class'KFMusicStingerHelper'.static.PlayWaveCompletedStinger( self );
                return;
        }
    }
    else if( class<KFLocalMessage_Game>(Message) != None )
    {
        if( HUDInterface != None )
        {
            HUDInterface.ShowNonCriticalMessage(class'ClassicLocalMessage_Game'.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject));
            return;
        }
    }
    else if( class<KFLocalMessage_Interaction>(Message) != None )
    {
        if( HUDInterface != None )
        {
            MessageStr = Message.static.GetString(Switch, false, RelatedPRI_1, RelatedPRI_2, OptionalObject);
            if( Len(MessageStr) == 0 )
                return;
                
            if( PlayerInput.bUsingGamepad )
            {
                KeyName = "<Icon>"$ControllerType$"."$class'KFLocalMessage_Interaction'.static.GetKeyBind(self, Switch)$"_Asset</Icon>";
            }
            else
            {
                KeyName = class'KFLocalMessage_Interaction'.static.GetKeyBind(self, Switch);
            }
            
            LeftBracket = "[[";
            RightBracket = "]]";
             
            StringArray = SplitString(MessageStr, class'KFGFxMoviePlayer_HUD'.default.HoldCommandDelimiter);
            if(StringArray.Length > 1)
            {
                if( Len(StringArray[0]) != 0 )
                {
                    FinalString = LeftBracket @ class'KFGFxControlsContainer_ControllerPresets'.default.TapString @ KeyName @ RightBracket @ StringArray[0] $ "\n" $ LeftBracket @ class'KFGFxControlsContainer_ControllerPresets'.default.HoldString @ KeyName @ RightBracket @ StringArray[1];
                }
                else
                {
                    FinalString = LeftBracket @ class'KFGFxControlsContainer_ControllerPresets'.default.HoldString @ KeyName @ RightBracket $ "\n" $ StringArray[1];
                }
            }
            else
            {
                FinalString = LeftBracket @ class'KFGFxControlsContainer_ControllerPresets'.default.TapString @ KeyName @ RightBracket $ "\n" $ StringArray[0];
            }
            
            HUDInterface.ShowNonCriticalMessage(FinalString, "\n");
            return;
        }
    }
    
    Super.ReceiveLocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

static function string StripColorMessage(string Str)
{
    local int Pos;
    local string S;
    
    S = Str;

    Pos = InStr(S,"#{");
    while ( Pos>=0 )
    {
        S = Left(S,Pos)$StripColorTag(S,Pos);
        Pos = InStr(S,"#{");
    }
    
    return S;
}

static function string StripColorTag(string S, int TextPos)
{
    S = Mid(S,TextPos+2);
    if( Left(S,4)=="DEF}" || Left(S,4)=="HSV}" )
    {
        S = Mid(S,4);
    }
    else if( Left(S,6)=="FLASH}" )
    {
        S = Mid(S,6);
    }
    else if( Left(S,7)=="CFLASH=" )
    {
        S = Mid(S,14);
    }
    else
    {
        S = Mid(S,7);
    }
    
    return S;
}

simulated reliable client event bool ShowConnectionProgressPopup( EProgressMessageType ProgressType, string ProgressTitle, string ProgressDescription, bool SuppressPasswordRetry = false)
{
    switch(ProgressType)
    {
    case    PMT_ConnectionFailure :
    case    PMT_PeerConnectionFailure :
        HUDInterface.NotifyLevelChange();
        HUDInterface.ShowProgressMsg("Connection Error: "$ProgressTitle$"|"$ProgressDescription$"|Disconnecting...",true);
        return true;
    case    PMT_DownloadProgress :
        HUDInterface.NotifyLevelChange();
    case    PMT_AdminMessage :
        HUDInterface.ShowProgressMsg(ProgressTitle$"|"$ProgressDescription);
        return true;
    }
    return false;
}

unreliable client function ClientUpdateAttachmentSkin( int Index, KFPawn P, MaterialInstanceConstant Mat )
{
    if ( P.WeaponAttachment != None && P.WeaponAttachment.WeapMesh != None )
    {
        P.WeaponAttachment.WeapMesh.SetMaterial(Index, Mat);
    }
}

function bool NotifyDisconnect(string Command)
{
    ClientNotifyDisconnect();
    return Super.NotifyDisconnect(Command);
}

reliable client function ClientNotifyDisconnect()
{
    KFPerk_Survivalist(FindObject("KFGame.Default__KFPerk_Survivalist",class'KFPerk_Survivalist')).PerkIcon = Texture2D'UI_PerkIcons_TEX.UI_PerkIcon_Survivalist';
    KFEmit_TraderPath(FindObject("KFGame.Default__KFEmit_TraderPath",class'KFEmit_TraderPath')).EmitterTemplate = ParticleSystem'FX_Gameplay_EMIT.FX_Trader_Trail';
    KFGFxObject_TraderItems(FindObject("KFGame.Default__KFGFxObject_TraderItems",class'KFGFxObject_TraderItems')).OffPerkIconPath = "UI_TraderMenu_TEX.UI_WeaponSelect_Trader_Perk";
}

function bool SetupMessage(out string S)
{
    local int i;
    local string StrippedMessage;
    
    for( i=0; i < ColorTags.Length; i++ )
    {
        S = Repl(S, ColorTags[i].Tag, "#{"$ColorTags[i].HexColor$"}", true);
    }
    
    StrippedMessage = StripColorMessage(S);
    if( Len(StrippedMessage) > 128 )
    {
        ClientMessage("Message is too long "$Len(StrippedMessage)$"/128 characters");
        return false;
    }
    
    return AllowTextMessage(S);
}

exec function Say( string Msg )
{
    if ( SetupMessage(Msg) )
    {
        ServerSay(Msg);
    }
}

exec function TeamSay( string Msg )
{
    if ( SetupMessage(Msg) )
    {
        ServerTeamSay(Msg);
    }
}

reliable client event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  )
{
    local string Msg,PlayerName,NamePrefix,NamePostfix,ChatColor;
    local ClassicPlayerReplicationInfo CPRI;

    if(PRI == None || Player==None || (Type != 'Event' && Type != 'Say' && Type != 'TeamSay'))
    {
        return;
    }

    if( PRI.Team != None && Type == 'TeamSay' && PRI.Team.TeamIndex != PlayerReplicationInfo.Team.TeamIndex )
    {
        return;
    }
    
    if( Type == 'Event' )
    {
        Msg = "#{"$class 'KFLocalMessage'.default.EventColor$"}"$S$"<LINEBREAK>";
        if( LobbyMenu != None )
        {
            LobbyMenu.ChatBox.AddText(Msg);
        }
        
        CurrentChatBox.AddText(Msg);
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "("$Type$") "$StripColorMessage(S) );
    }
    else if( ( ( Type == 'Say' ) || ( Type == 'TeamSay' ) ) )
    {
        PlayerName = StripColorMessage(PRI.GetHumanReadableName());
        
        CPRI = ClassicPlayerReplicationInfo(PRI);
        if( CPRI != None )
        {
            ChatColor = CPRI.GetMessageHexColor(Type);
            
            NamePrefix = CPRI.GetNamePrefix(Type);
            NamePostfix = CPRI.GetNamePostfix(Type);
            
            if( NamePrefix != "" )
            {
                NamePrefix $= " ";
            }
            
            if( NamePostfix != "" )
            {
                NamePostfix $= " ";
            }
            
            Msg = "#{"$CPRI.GetNameHexColor(Type)$"}"$NamePrefix$PlayerName$NamePostfix$"#{DEF}: #{"$ChatColor$"}"$S$"#{DEF}<LINEBREAK>";
        } 
        else
        {    
            Msg = "#{DEF}"$PlayerName$": "$S$"#{DEF}<LINEBREAK>";
        }
        
        if( LobbyMenu != None )
        {
            LobbyMenu.ChatBox.AddText(Msg);
        }
        
        CurrentChatBox.AddText("#{DEF}" $ GetChatChannel(Type, PRI) @ Msg);
        LocalPlayer( Player ).ViewportClient.ViewportConsole.OutputText( "("$Type$") "$PlayerName$": "$StripColorMessage(S) );
    }
}

simulated function CancelConnection()
{
    if( HUDInterface!=None )
        HUDInterface.CancelConnection();
    else class'Engine'.Static.GetEngine().GameViewport.ConsoleCommand("Disconnect");
}

exec function ViewPlayerID( int ID )
{
	ServerViewPlayerID(ID);
}

reliable server function ServerViewPlayerID( int ID )
{
	local PlayerReplicationInfo PRI;
    local ViewTargetTransitionParams TransitionParams;

	if( !IsSpectating() )
		return;

	// Find matching player by ID
	foreach WorldInfo.GRI.PRIArray(PRI)
	{
		if ( PRI.PlayerID==ID )
			break;
	}
	if( PRI==None || PRI.PlayerID!=ID || Controller(PRI.Owner)==None || Controller(PRI.Owner).Pawn==None || !WorldInfo.Game.CanSpectate(self, PRI) )
		return;
	
    TransitionParams.BlendTime = 0.35;
    TransitionParams.BlendFunction = VTBlend_Cubic;
    TransitionParams.BlendExp = 2.f;
    TransitionParams.bLockOutgoing = false;

    SetViewTarget(PRI, TransitionParams);
	ClientMessage("Now viewing from "$StripColorMessage(PRI.GetHumanReadableName()));
	if( CurrentSpectateMode==SMODE_Roaming )
		SpectatePlayer( SMODE_PawnFreeCam );
}

reliable server function ForceLobbySpectate()
{
    if( Pawn != None && KFPawn_Customization(Pawn) == None && !WorldInfo.GRI.bMatchHasBegun )
        return;
        
    ClientSetCameraFade( true, MakeColor(0,0,0,255), vect2d(1.f, 0.f), 0.5f, true );
    SpectateRoaming();
    MoveToValidSpectatorLocation();
    StartSpectate();
}

function NotifyLevelUp(class<KFPerk> PerkClass, byte PerkLevel, byte NewPrestigeLevel);
function SetGrabEffect(bool bValue, optional bool bPlayerZed, optional bool bSkipMessage);

defaultproperties
{
    InputClass=class'KFClassicMode.ClassicPlayerInput'
    PerkManagerClass=class'ClassicPerkManager'
    PurchaseHelperClass=class'ClassicAutoPurchaseHelper'
    
    MidGameMenuClass=class'UI_MidGameMenu'
    LobbyMenuClass=class'UI_LobbyMenu'
    FlashUIClass=class'UI_FlashLobby'
    TraderMenuClass=class'UI_TraderMenu'
    
    PerkList.Empty
}