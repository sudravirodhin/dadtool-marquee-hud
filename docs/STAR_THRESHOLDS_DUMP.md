# STAR_THRESHOLDS_DUMP.md

This file documents the structural findings and metadata collected from memory sweeps on game build `++brainjar+release-CL-29008` (June 2026 update). It is a complete reference of the game's internals related to song catalogs, combat scoring, save progression, and subsystem layouts.

---

## 1. Class Function Catalogs
These are the C++ methods exposed on key game objects, retrieved via `ForEachFunction` sweeps.

### `PagodaChallengeData`
- `AddNewEnemyWave`
- `CreateChallengeDataAssetFromChallengeData`
- `GetObjectiveDefs`
- `GetPatternStructForWave`
- `GetSpawnPatternType`
- `RemoveEnemyWaveSpawnIfExists`
- `ResetPatternType`
- `SetOrAddNewSpawnToEnemyWave`
- `SetPatternStructForWave`
- `SetPatternType`
- `SetSongData`
- `SetSongPlaylistData`

### `PagodaGameState`
- `Get`
- `GetGameplaySegmentComponent`
- `GetLevelFlowProcessorComponent`
- `GetMovesetSyncRuntimeComponent`
- `GetMovesetSyncRuntimeComponentMutable`
- `GetMpSessionComponent`
- `GetNetworkEventsComponent`
- `GetObjectiveComponent`
- `GetPagodaDataLayerHelper`
- `GetPagodaPlayerState`
- `GetPagodaPlayerStates`
- `GetPhaseComponent`
- `IsAIAgentStunned`
- `IsInLimboGameplay`
- `Multicast_SetGlobalTimeDilation`
- `OnGameStatePreInitializeComponents`
- `OnPlayerStateArrayChanged__DelegateSignature`
- `OnPreLevelActorBeginPlay`
- `OnRep_RecorderPlayerState`
- `OnRestartLevelRequested`
- `OnStartLevelEndFlow`
- `SetGamePaused`
- `SetLimboGameplay`

### `PagodaLevelFunctionLibrary`
- `GetAllActorsOfClassAllGameWorlds`
- `GetAllActorsOfClassWithTagAllGameWorlds`
- `GetAllGameWorlds`
- `GetEditorVisibleLevelAssets`
- `GetLevelNameFromSoftReference`
- `GetPagodaWorldSettings`
- `IsSimulatingInEditor`
- `IsWorldTearingDown`
- `TryFindChallengeProgressionTag`
- `TryFindLevelLookupTagForWorld`
- `TryGetLevelLookupData`

### `PagodaMusicSubsystem`
- `CanActivateMovesetSyncWindow`
- `GetAbsoluteTimeFromTimestamp`
- `GetAudioBeatTimestamp`
- `GetBPM`
- `GetBeatDurationSeconds`
- `GetCachedTimelinePosition`
- `GetCurrentPlaylist`
- `GetCurrentRootKey`
- `GetCurrentSong`
- `GetCurrentSongSectionTag`
- `GetEventDispatcher`
- `GetGameplaySyncTime`
- `GetGameplaySyncTimeFromTimelinePos`
- `GetLevelDefaultSong`
- `GetMusicalTimeFromTimestamp`
- `GetRelativePlaybackRate`
- `GetSongEventInstance`
- `GetSongLengthSeconds`
- `GetSongPlayer`
- `GetTimelinePosition`
- `Get_BP`
- `HandleSongSectionEnded`
- `HandleSongSectionStarted`
- `HandleSongTransition`
- `IsLoopingEnabled`
- `IsPlayingSilentSong`
- `IsSilentSongAsset`
- `IsSongPaused`
- `IsSongPlaying`
- `PauseSong`
- `PlaySong`
- `PlaySongPlaylist`
- `RequestTestScenario`
- `ResumeSong`
- `SetBPMOverride`
- `SetDebugRepeatInterval`
- `SetIsLoopingEnabled`
- `SetIsSongPaused`
- `SetLocalParameter`
- `SetMusicAudioComponent`
- `SetTimelinePosition`
- `ShouldOffsetDefaultSongTransitionsOnPlay`
- `ShouldUseLevelDefaultSongTransitions`
- `StopSong`
- `TryGetBPMOverride`
- `TryGetCurrentMovesetSyncWindow`
- `TryGetCurrentSongFloatParam`
- `TryGetFirstCurrentMovesetSyncWindow`
- `TryGetNextMovesetSyncWindow`
- `TryGetTimeSinceLastBeat`
- `TryGetTimeToClosestBeat`
- `TryGetTimeToNextBarSeconds`
- `TryGetTimeToNextBeatSeconds`

### `PagodaPlayerStateScoreComponent`
- `AddCombatScore`
- `AddCombatScoreForLevelBonus`
- `GetCombatScore`
- `GetMaxComboCount`
- `GetTotalTimePenaltyApplied`
- `OnPlayerScoreAdded__DelegateSignature`
- `OnPossessedPawnChanged`
- `OnRep_MaxComboCount`
- `OnScoreStackUpdated__DelegateSignature`
- `OverrideCombatScore`
- `ResetCombatScore`

### `PagodaPlaythroughPlayerData`
- `AddCredits`
- `AddOwnedUpgrade`
- `AddStars`
- `EquipCosmetic`
- `EquipDanceMoveToSlot`
- `FindBossAbilityInputSlot`
- `FindDanceMoveInputSlot`
- `GetBossAbilityUpgradeAtSlot`
- `GetCredits`
- `GetDanceMoveIdAtSlot`
- `GetDiveBarCurrentSongId`
- `GetDiveBarSongExplicitlySelected`
- `GetEquippedUpgradeAssetIds`
- `GetInfiniteDiscoDifficulty`
- `GetLastAttemptedLevelState`
- `GetLevelCompletionCount`
- `GetNumBossAbilitySlots`
- `GetNumDanceMoveSlots`
- `GetOwnedUpgradeAssetIds`
- `GetSlottedBossAbilityUpgrades`
- `GetSlottedDanceMoves`
- `GetStars`
- `GetStoryDifficulty`
- `HasPendingNewCompletedLevelDialogue`
- `IsCollectibleDiscovered`
- `IsCosmeticEquipped`
- `IsDanceExcludedFromRandom`
- `IsDanceMoveEquipped`
- `IsUpgradeEquipped`
- `IsUpgradeOwned`
- `OnCosmeticItemStateChanged__DelegateSignature`
- `OnDanceMoveStateChanged__DelegateSignature`
- `OnDifficultyChanged__DelegateSignature`
- `OnIntChanged__DelegateSignature`
- `OnOwnedStateChanged__DelegateSignature`
- `OnUpgradeEquipStateChanged__DelegateSignature`
- `RemoveOwnedUpgrade`
- `SetCollectibleDiscovered`
- `SetDiveBarCurrentSongId`
- `SetDiveBarSongExplicitlySelected`
- `SetHasPendingNewCompletedLevelDialogue`
- `SetInfiniteDiscoDifficulty`
- `SetIsDanceExcludedFromRandom`
- `SetStoryDifficulty`
- `UnequipCosmetic`
- `UnequipDanceMove`

### `PagodaProgressionSubsystem`
- `AnyScopeOnIsActiveChangedMulti__DelegateSignature`
- `AnyScopeOnIsActiveChanged__DelegateSignature`
- `RegisterOnAnyScopeOnIsActiveChanged`
- `UnregisterOnAnyScopeOnIsActiveChanged`

### `PagodaSong`
- `Editor_MigrateTracksToV1`
- `Editor_TryShiftEventsByBeats`
- `GetEndTimeWithRawData`
- `GetImportedSongUniqueID`
- `IsDoNotShipAsset`
- `SetBeatOffset`
- `SetEndOffsetWithRawData`
- `SetEndOffsetWithRawDataFromEndTime`
- `SetName`
- `SetPerformedBy`
- `SetSongCrafterData`
- `SetStartOffsetWithRawData`
- `SetTempo`
- `SetTempoAndBeatOffset`
- `SetWrittenBy`

### `PagodaSongCatalogSubsystem`
- `DeleteImportedSong`
- `Editor_TestDecodeSampleFiles`
- `FindPlaylist`
- `GetAllPlaylists`
- `GetAllSongs`
- `GetImportedSongDirectoryPath`
- `GetImportedSongFromUniqueId`
- `GetImportedSongJsonBaseFilename`
- `GetImportedSongJsonPath`
- `GetImportedSongOggBaseFilename`
- `GetImportedSongOggPath`
- `GetInGamePlaylists`
- `GetListOfValidSongsToImport`
- `GetNumSongs`
- `GetSongCategories`
- `GetSongInCatalogFromName`
- `GetSongsInCategory`
- `GetSongsToImportDirectory`
- `GetUserPlaylists`
- `IsImportedSongValid`
- `IsSongSavedOnDisk`
- `LoadExistingSongRawDataForImport`
- `LoadNewSongRawDataForImport`
- `LoadRawDataForExistingImportedSong`
- `OnCultureChanged`
- `OnDecodeTestComplete__DelegateSignature`
- `OnPlaylistCatalogChanged__DelegateSignature`
- `OnSongLoadedFromDisk__DelegateSignature`
- `OnSongSavedToDisk__DelegateSignature`
- `RemovePlaylist`
- `RenameImportedSong`
- `SanitizeImportedSongName`
- `SavePlaylist`
- `TryAddAndSaveImportedSong`
- `UnloadSongRawDataAfterImport`

---

## 2. Struct Definitions
These structure layouts define how scoring breakdowns, save data, and song parameters are packed in memory.

### Struct `PagodaMovesetSongData`
| Field | Type |
|---|---|
| `MovesetSyncWindows` | `ArrayProperty` |

### Struct `PagodaPlayerScoreBreakdown`
| Field | Type |
|---|---|
| `CombatActionScores` | `MapProperty` |
| `LevelBonusScores` | `MapProperty` |
| `TotalTimePenaltyApplied` | `IntProperty` |
| `TotalRestartFromCheckpointPenalty` | `IntProperty` |

### Struct `PagodaSongDebugInterval`
| Field | Type |
|---|---|
| `StartTimelinePos` | `FloatProperty` |
| `EndTimelinePos` | `FloatProperty` |
| `Description` | `StrProperty` |

### Struct `PagodaSongGameplayParams`
| Field | Type |
|---|---|
| `Floats` | `MapProperty` |

### Struct `SongCrafterData`
| Field | Type |
|---|---|
| `Tempo` | `FloatProperty` |
| `CurrentTempo` | `OptionalProperty` |
| `CustomTempoSections` | `ArrayProperty` |
| `BeatOffset` | `IntProperty` |
| `StartSongOffset` | `FloatProperty` |
| `EndSongOffset` | `FloatProperty` |
| `Signature` | `StructProperty` |
| `ActorWorld` | `SoftObjectProperty` |
| `CombatTracks` | `ArrayProperty` |
| `SpawnTracks` | `ArrayProperty` |
| `LightTracks` | `ArrayProperty` |
| `ActorTracks` | `ArrayProperty` |
| `CameraTracks` | `ArrayProperty` |
| `OverlayTracks` | `ArrayProperty` |
| `MusicTracks` | `ArrayProperty` |
| `OuterSong` | `ObjectProperty` |

---

## 3. Subsystem and Class Instance Layouts
Unique properties and typical values found on active class instances during gameplay. This provides a complete dictionary of fields we can read or poll.

### Class `BP_PagodaChallengeData_C` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `ArenaColorIndex` | `IntProperty` | `0` | `PagodaChallengeData` |
| `ArenaIdTag` | `StructProperty` | `ScriptStruct /Script/GameplayTags.GameplayTag` | `PagodaChallengeData` |
| `ChallengeName` | `TextProperty` | `unknown` | `PagodaChallengeData` |
| `DefaultIncursionProfile` | `ObjectProperty` | `DataTable /Game/Pagoda/Levels/Test/DT_IncursionProfiles_InfiniteDisco.DT_IncursionProfiles_InfiniteDisco` | `PagodaChallengeData` |
| `EnemyWaves` | `ArrayProperty` | `unknown` | `PagodaChallengeData` |
| `ModAssets` | `ArrayProperty` | `unknown` | `PagodaChallengeData` |
| `ObjectiveDefs` | `ArrayProperty` | `unknown` | `PagodaChallengeData` |
| `SongPlaylistRef` | `ObjectProperty` | `nil` | `PagodaChallengeData` |
| `SongRef` | `ObjectProperty` | `PagodaSong /Game/Pagoda/Audio/Songs/PS_MC_JustDance_124/PS_MC_JustDance_124.PS_MC_JustDance_124` | `PagodaChallengeData` |
| `TunableMods` | `ArrayProperty` | `unknown` | `PagodaChallengeData` |
| `UserChallengeId` | `StructProperty` | `ScriptStruct /Script/CoreUObject.Guid` | `PagodaChallengeData` |

### Class `BP_PagodaGameMode_InfiniteDisco_C` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `AttachmentReplication` | `StructProperty` | `ScriptStruct /Script/Engine.RepAttachment` | `Actor` |
| `AudioVolume` | `ObjectProperty` | `nil` | `BP_PagodaGameMode_C` |
| `AutoReceiveInput` | `ByteProperty` | `0` | `Actor` |
| `BlueprintCreatedComponents` | `ArrayProperty` | `unknown` | `Actor` |
| `Children` | `ArrayProperty` | `unknown` | `Actor` |
| `CustomTimeDilation` | `FloatProperty` | `1.0` | `Actor` |
| `DefaultPawnClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Characters/Player/BP_PagodaPlayerCharacter_Charlie.BP_PagodaPlayerCharacter_Charlie_C` | `GameModeBase` |
| `DefaultPlayerName` | `TextProperty` | `unknown` | `GameModeBase` |
| `DefaultSceneRoot` | `ObjectProperty` | `SceneComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameMode_InfiniteDisco_C_2147475926.DefaultSceneRoot` | `BP_PagodaGameMode_C` |
| `DefaultUpdateOverlapsMethodDuringLevelStreaming` | `EnumProperty` | `2` | `Actor` |
| `EndLevelConditions` | `ArrayProperty` | `unknown` | `PagodaGameMode` |
| `GameNetDriverReplicationSystem` | `EnumProperty` | `0` | `GameModeBase` |
| `GameSession` | `ObjectProperty` | `GameSession /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.GameSession_2147475920` | `GameModeBase` |
| `GameSessionClass` | `ClassProperty` | `Class /Script/Engine.GameSession` | `GameModeBase` |
| `GameState` | `ObjectProperty` | `BP_PagodaGameState_InfiniteDisco_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917` | `GameModeBase` |
| `GameStateClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Core/GameModes/InfiniteDisco/BP_PagodaGameState_InfiniteDisco.BP_PagodaGameState_InfiniteDisco_C` | `GameModeBase` |
| `HLODLayer` | `ObjectProperty` | `nil` | `Actor` |
| `HUDClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Core/GameModes/InfiniteDisco/BP_PagodaHUD_InfiniteDisco.BP_PagodaHUD_InfiniteDisco_C` | `GameModeBase` |
| `InPlaythrough` | `BoolProperty` | `true` | `PagodaGameMode` |
| `InitialLifeSpan` | `FloatProperty` | `0.0` | `Actor` |
| `InputComponent` | `ObjectProperty` | `nil` | `Actor` |
| `InputPriority` | `IntProperty` | `0` | `Actor` |
| `InstanceComponents` | `ArrayProperty` | `unknown` | `Actor` |
| `Instigator` | `ObjectProperty` | `nil` | `Actor` |
| `Layers` | `ArrayProperty` | `unknown` | `Actor` |
| `MinNetUpdateFrequency` | `FloatProperty` | `2.0` | `Actor` |
| `MpSessionComponent` | `ObjectProperty` | `PagodaMpSessionGameModeComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameMode_InfiniteDisco_C_2147475926.MpSessionComponent` | `PagodaGameMode` |
| `MusicDebug` | `ObjectProperty` | `nil` | `BP_PagodaGameMode_C` |
| `NetCullDistanceSquared` | `FloatProperty` | `225000000.0` | `Actor` |
| `NetDormancy` | `ByteProperty` | `1` | `Actor` |
| `NetDriverName` | `NameProperty` | `unknown` | `Actor` |
| `NetPriority` | `FloatProperty` | `1.0` | `Actor` |
| `NetTag` | `IntProperty` | `0` | `Actor` |
| `NetUpdateFrequency` | `FloatProperty` | `10.0` | `Actor` |
| `OnActorBeginOverlap` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorBeginOverlap` | `Actor` |
| `OnActorEndOverlap` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorEndOverlap` | `Actor` |
| `OnActorHit` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorHit` | `Actor` |
| `OnBeginCursorOver` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnBeginCursorOver` | `Actor` |
| `OnClicked` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnClicked` | `Actor` |
| `OnDestroyed` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnDestroyed` | `Actor` |
| `OnEndCursorOver` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnEndCursorOver` | `Actor` |
| `OnEndPlay` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnEndPlay` | `Actor` |
| `OnInputTouchBegin` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchBegin` | `Actor` |
| `OnInputTouchEnd` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchEnd` | `Actor` |
| `OnInputTouchEnter` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchEnter` | `Actor` |
| `OnInputTouchLeave` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchLeave` | `Actor` |
| `OnReleased` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnReleased` | `Actor` |
| `OnTakeAnyDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakeAnyDamage` | `Actor` |
| `OnTakePointDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakePointDamage` | `Actor` |
| `OnTakeRadialDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakeRadialDamage` | `Actor` |
| `OptionsString` | `StrProperty` | `unknown` | `GameModeBase` |
| `Owner` | `ObjectProperty` | `nil` | `Actor` |
| `ParentComponent` | `WeakObjectProperty` | `unknown` | `Actor` |
| `PhysicsReplicationMode` | `EnumProperty` | `0` | `Actor` |
| `PlayerControllerClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Characters/Player/BP_PagodaPlayerController.BP_PagodaPlayerController_C` | `GameModeBase` |
| `PlayerPawnClasses` | `MapProperty` | `unknown` | `PagodaGameMode` |
| `PlayerStateClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Characters/Player/BP_PagodaPlayerState.BP_PagodaPlayerState_C` | `GameModeBase` |
| `PrimaryActorTick` | `StructProperty` | `ScriptStruct /Script/Engine.ActorTickFunction` | `Actor` |
| `RayTracingGroupId` | `IntProperty` | `-1` | `Actor` |
| `RemoteRole` | `ByteProperty` | `0` | `Actor` |
| `ReplaySpectatorPlayerControllerClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Characters/Player/BP_PagodaReplayPlayerController.BP_PagodaReplayPlayerController_C` | `GameModeBase` |
| `ReplicatedMovement` | `StructProperty` | `ScriptStruct /Script/Engine.RepMovement` | `Actor` |
| `Role` | `ByteProperty` | `3` | `Actor` |
| `RootComponent` | `ObjectProperty` | `SceneComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameMode_InfiniteDisco_C_2147475926.DefaultSceneRoot` | `Actor` |
| `ServerStatReplicator` | `ObjectProperty` | `nil` | `GameModeBase` |
| `ServerStatReplicatorClass` | `ClassProperty` | `Class /Script/Engine.ServerStatReplicator` | `GameModeBase` |
| `SlotName` | `StrProperty` | `unknown` | `BP_PagodaGameMode_C` |
| `SpawnCollisionHandlingMethod` | `EnumProperty` | `1` | `Actor` |
| `SpectatorClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Characters/Player/BP_PagodaSpectatorPawn.BP_PagodaSpectatorPawn_C` | `GameModeBase` |
| `Tags` | `ArrayProperty` | `unknown` | `Actor` |
| `UberGraphFrame` | `StructProperty` | `ScriptStruct /Script/Engine.PointerToUberGraphFrame` | `BP_PagodaGameMode_C` |
| `UpdateOverlapsMethodDuringLevelStreaming` | `EnumProperty` | `0` | `Actor` |
| `bActorEnableCollision` | `BoolProperty` | `true` | `Actor` |
| `bActorIsBeingDestroyed` | `BoolProperty` | `false` | `Actor` |
| `bAllowReceiveTickEventOnDedicatedServer` | `BoolProperty` | `true` | `Actor` |
| `bAllowTickBeforeBeginPlay` | `BoolProperty` | `true` | `Actor` |
| `bAlwaysRelevant` | `BoolProperty` | `false` | `Actor` |
| `bAsyncPhysicsTickEnabled` | `BoolProperty` | `false` | `Actor` |
| `bAutoDestroyWhenFinished` | `BoolProperty` | `false` | `Actor` |
| `bBlockInput` | `BoolProperty` | `false` | `Actor` |
| `bCallPreReplication` | `BoolProperty` | `true` | `Actor` |
| `bCallPreReplicationForReplay` | `BoolProperty` | `true` | `Actor` |
| `bCanBeDamaged` | `BoolProperty` | `false` | `Actor` |
| `bCanBeInCluster` | `BoolProperty` | `false` | `Actor` |
| `bCollideWhenPlacing` | `BoolProperty` | `false` | `Actor` |
| `bEnableAutoLODGeneration` | `BoolProperty` | `false` | `Actor` |
| `bExchangedRoles` | `BoolProperty` | `true` | `Actor` |
| `bFindCameraComponentWhenViewTarget` | `BoolProperty` | `true` | `Actor` |
| `bForceNetAddressable` | `BoolProperty` | `false` | `Actor` |
| `bGenerateOverlapEventsDuringLevelStreaming` | `BoolProperty` | `false` | `Actor` |
| `bHidden` | `BoolProperty` | `true` | `Actor` |
| `bIgnoresOriginShifting` | `BoolProperty` | `false` | `Actor` |
| `bIsEditorOnlyActor` | `BoolProperty` | `false` | `Actor` |
| `bNetLoadOnClient` | `BoolProperty` | `false` | `Actor` |
| `bNetTemporary` | `BoolProperty` | `false` | `Actor` |
| `bNetUseOwnerRelevancy` | `BoolProperty` | `false` | `Actor` |
| `bOnlyRelevantToOwner` | `BoolProperty` | `false` | `Actor` |
| `bPauseable` | `BoolProperty` | `true` | `GameModeBase` |
| `bRelevantForLevelBounds` | `BoolProperty` | `true` | `Actor` |
| `bRelevantForNetworkReplays` | `BoolProperty` | `true` | `Actor` |
| `bReplayRewindable` | `BoolProperty` | `false` | `Actor` |
| `bReplicateMovement` | `BoolProperty` | `false` | `Actor` |
| `bReplicateUsingRegisteredSubObjectList` | `BoolProperty` | `false` | `Actor` |
| `bReplicates` | `BoolProperty` | `false` | `Actor` |
| `bStartPlayersAsSpectators` | `BoolProperty` | `false` | `GameModeBase` |
| `bTearOff` | `BoolProperty` | `false` | `Actor` |
| `bUseSeamlessTravel` | `BoolProperty` | `false` | `GameModeBase` |

### Class `BP_PagodaGameState_InfiniteDisco_C` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `AbilitySystemComponent` | `ObjectProperty` | `PagodaAbilitySystemComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.AbilitySystemComponent` | `PagodaGameState` |
| `AttachmentReplication` | `StructProperty` | `ScriptStruct /Script/Engine.RepAttachment` | `Actor` |
| `AuthorityGameMode` | `ObjectProperty` | `BP_PagodaGameMode_InfiniteDisco_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameMode_InfiniteDisco_C_2147475926` | `GameStateBase` |
| `AutoReceiveInput` | `ByteProperty` | `0` | `Actor` |
| `BPC_GameStateBossHandler` | `ObjectProperty` | `BPC_GameStateBossHandler_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.BPC_GameStateBossHandler` | `BP_PagodaGameState_C` |
| `BlueprintCreatedComponents` | `ArrayProperty` | `unknown` | `Actor` |
| `BossCardVideoPlayer` | `ObjectProperty` | `BP_BossCardVideoPlayer_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_BossCardVideoPlayer_C_2147475311` | `BP_PagodaGameState_C` |
| `BossDefeated` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Game/Pagoda/Core/GameModes/BP_PagodaGameState.BP_PagodaGameState_C:BossDefeated` | `BP_PagodaGameState_C` |
| `CheckpointFadeFailsafeTimerHandle` | `StructProperty` | `ScriptStruct /Script/Engine.TimerHandle` | `BP_PagodaGameState_C` |
| `Children` | `ArrayProperty` | `unknown` | `Actor` |
| `CompletedIntroAnims` | `IntProperty` | `0` | `BP_PagodaGameState_InfiniteDisco_C` |
| `CustomTimeDilation` | `FloatProperty` | `1.0` | `Actor` |
| `DefaultIncursionProfile` | `ObjectProperty` | `DataTable /Game/Pagoda/Levels/Test/DT_IncursionProfiles_InfiniteDisco.DT_IncursionProfiles_InfiniteDisco` | `BP_PagodaGameState_InfiniteDisco_C` |
| `DefaultSceneRoot` | `ObjectProperty` | `SceneComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.DefaultSceneRoot` | `BP_PagodaGameState_C` |
| `DefaultSong` | `ObjectProperty` | `PagodaSong /Game/Pagoda/Audio/Songs/PS_ED_Mission_155/PS_ED_Mission_155.PS_ED_Mission_155` | `BP_PagodaGameState_InfiniteDisco_C` |
| `DefaultUpdateOverlapsMethodDuringLevelStreaming` | `EnumProperty` | `2` | `Actor` |
| `DoInfiniteDiscoNextSong` | `BoolProperty` | `false` | `BP_PagodaGameState_InfiniteDisco_C` |
| `FirstSpawnOnBeatTimer` | `StructProperty` | `ScriptStruct /Script/Engine.TimerHandle` | `BP_PagodaGameState_InfiniteDisco_C` |
| `ForceBeginOnSongStarted` | `BoolProperty` | `false` | `BP_PagodaGameState_InfiniteDisco_C` |
| `FreePlayChallengeDefault` | `ObjectProperty` | `BP_PagodaChallengeData_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.BP_PagodaChallengeData_C_2147473967` | `BP_PagodaGameState_InfiniteDisco_C` |
| `FreePlayChallengeInfinite` | `ObjectProperty` | `BP_PagodaChallengeData_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.BP_PagodaChallengeData_C_2147473965` | `BP_PagodaGameState_InfiniteDisco_C` |
| `GameModeClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Core/GameModes/InfiniteDisco/BP_PagodaGameMode_InfiniteDisco.BP_PagodaGameMode_InfiniteDisco_C` | `GameStateBase` |
| `GameplaySegmentComponent` | `ObjectProperty` | `PagodaGameplaySegmentComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.GameplaySegmentComponent` | `PagodaGameState` |
| `HLODLayer` | `ObjectProperty` | `nil` | `Actor` |
| `InfiniteDiscoMenuInst` | `ObjectProperty` | `WBP_InfiniteDiscoMenu_C /Engine/Transient.GameEngine_2147482572:GI_PagodaGameInstance_C_2147482510.UI_Layout_Game_C_2147475893.WidgetTree_2147475892.WBP_InfiniteDiscoMenu_C_2147475308` | `BP_PagodaGameState_InfiniteDisco_C` |
| `InfiniteDiscoTimerWidgets` | `ArrayProperty` | `unknown` | `BP_PagodaGameState_InfiniteDisco_C` |
| `InitialLifeSpan` | `FloatProperty` | `0.0` | `Actor` |
| `InputComponent` | `ObjectProperty` | `nil` | `Actor` |
| `InputPriority` | `IntProperty` | `0` | `Actor` |
| `InstanceComponents` | `ArrayProperty` | `unknown` | `Actor` |
| `Instigator` | `ObjectProperty` | `nil` | `Actor` |
| `LastPlayedSong` | `ObjectProperty` | `nil` | `BP_PagodaGameState_C` |
| `LastPlayedSongPlaylist` | `ObjectProperty` | `PagodaSongPlaylist /Engine/Transient.PagodaSongPlaylist_2147473126` | `BP_PagodaGameState_InfiniteDisco_C` |
| `LastPlayedSong_0` | `ObjectProperty` | `nil` | `BP_PagodaGameState_InfiniteDisco_C` |
| `LastSetLevelEndResults` | `StructProperty` | `ScriptStruct /Script/Pagoda.PagodaLevelEndResults` | `PagodaGameState` |
| `Layers` | `ArrayProperty` | `unknown` | `Actor` |
| `LevelFlowProcessorComponent` | `ObjectProperty` | `PagodaLevelFlowProcessorComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.LevelFlowProcessorComponent` | `PagodaGameState` |
| `MainFlowTimerHandle` | `StructProperty` | `ScriptStruct /Script/Engine.TimerHandle` | `BP_PagodaGameState_InfiniteDisco_C` |
| `MinNetUpdateFrequency` | `FloatProperty` | `2.0` | `Actor` |
| `MovesetSyncRuntimeComponent` | `ObjectProperty` | `MovesetSyncRuntimeComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.MovesetSyncRuntimeComponent` | `PagodaGameState` |
| `MpSessionComponent` | `ObjectProperty` | `PagodaMpSessionGameStateComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.MpSessionComponent` | `PagodaGameState` |
| `NetCullDistanceSquared` | `FloatProperty` | `225000000.0` | `Actor` |
| `NetDormancy` | `ByteProperty` | `1` | `Actor` |
| `NetDriverName` | `NameProperty` | `unknown` | `Actor` |
| `NetPriority` | `FloatProperty` | `10.0` | `Actor` |
| `NetTag` | `IntProperty` | `0` | `Actor` |
| `NetUpdateFrequency` | `FloatProperty` | `10.0` | `Actor` |
| `NetworkEventsComponent` | `ObjectProperty` | `PagodaNetworkEventsComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.NetworkEventsComponent` | `PagodaGameState` |
| `NewPlayerIncursionProfile` | `ObjectProperty` | `DataTable /Game/Pagoda/Levels/Test/DT_IncursionProfiles_InfiniteDisco_NewPlayer.DT_IncursionProfiles_InfiniteDisco_NewPlayer` | `BP_PagodaGameState_InfiniteDisco_C` |
| `ObjectiveComponent` | `ObjectProperty` | `PagodaObjectiveComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.ObjectiveComponent` | `PagodaGameState` |
| `OnActorBeginOverlap` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorBeginOverlap` | `Actor` |
| `OnActorEndOverlap` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorEndOverlap` | `Actor` |
| `OnActorHit` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorHit` | `Actor` |
| `OnAttackAbilityWithoutSelectedTarget` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Game/Pagoda/Core/GameModes/BP_PagodaGameState.BP_PagodaGameState_C:OnAttackAbilityWithoutSelectedTarget` | `BP_PagodaGameState_C` |
| `OnBeginCursorOver` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnBeginCursorOver` | `Actor` |
| `OnCleanupAttackObjectsForTransition` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Game/Pagoda/Core/GameModes/BP_PagodaGameState.BP_PagodaGameState_C:OnCleanupAttackObjectsForTransition` | `BP_PagodaGameState_C` |
| `OnClicked` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnClicked` | `Actor` |
| `OnDestroyed` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnDestroyed` | `Actor` |
| `OnEndCursorOver` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnEndCursorOver` | `Actor` |
| `OnEndPlay` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnEndPlay` | `Actor` |
| `OnInputTouchBegin` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchBegin` | `Actor` |
| `OnInputTouchEnd` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchEnd` | `Actor` |
| `OnInputTouchEnter` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchEnter` | `Actor` |
| `OnInputTouchLeave` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchLeave` | `Actor` |
| `OnLevelStartCountdownComplete` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Game/Pagoda/Core/GameModes/BP_PagodaGameState.BP_PagodaGameState_C:OnLevelStartCountdownComplete` | `BP_PagodaGameState_C` |
| `OnPlayerStateChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaGameState:OnPlayerStateChanged` | `PagodaGameState` |
| `OnReleased` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnReleased` | `Actor` |
| `OnTakeAnyDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakeAnyDamage` | `Actor` |
| `OnTakePointDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakePointDamage` | `Actor` |
| `OnTakeRadialDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakeRadialDamage` | `Actor` |
| `Owner` | `ObjectProperty` | `nil` | `Actor` |
| `PagodaChallengeGameState` | `ObjectProperty` | `PagodaChallengeGameStateComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.PagodaChallengeGameState` | `BP_PagodaGameState_InfiniteDisco_C` |
| `PagodaChallengeProceduralIncursion` | `ObjectProperty` | `PagodaProceduralIncursionComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.PagodaChallengeProceduralIncursion` | `BP_PagodaGameState_InfiniteDisco_C` |
| `PagodaDataLayerHelper` | `ObjectProperty` | `PagodaDataLayerHelper /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.PagodaDataLayerHelper_2147475455` | `PagodaGameState` |
| `ParentComponent` | `WeakObjectProperty` | `unknown` | `Actor` |
| `PhaseComponent` | `ObjectProperty` | `PagodaPhaseComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.PhaseComponent` | `PagodaGameState` |
| `PhysicsReplicationMode` | `EnumProperty` | `0` | `Actor` |
| `PlayerArray` | `ArrayProperty` | `unknown` | `GameStateBase` |
| `PreloadedLevelPackages` | `ArrayProperty` | `unknown` | `PagodaGameState` |
| `PrimaryActorTick` | `StructProperty` | `ScriptStruct /Script/Engine.ActorTickFunction` | `Actor` |
| `QueuedLevelEndTimerHandle` | `StructProperty` | `ScriptStruct /Script/Engine.TimerHandle` | `BP_PagodaGameState_C` |
| `RayTracingGroupId` | `IntProperty` | `-1` | `Actor` |
| `RecorderPlayerState` | `ObjectProperty` | `nil` | `PagodaGameState` |
| `RemoteRole` | `ByteProperty` | `1` | `Actor` |
| `ReplicatedMovement` | `StructProperty` | `ScriptStruct /Script/Engine.RepMovement` | `Actor` |
| `ReplicatedWorldTimeSecondsDouble` | `DoubleProperty` | `20.017805811018` | `GameStateBase` |
| `Role` | `ByteProperty` | `3` | `Actor` |
| `RootComponent` | `ObjectProperty` | `SceneComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.DefaultSceneRoot` | `Actor` |
| `ServerWorldTimeSecondsDelta` | `FloatProperty` | `0.0` | `GameStateBase` |
| `ServerWorldTimeSecondsUpdateFrequency` | `FloatProperty` | `0.10000000149012` | `GameStateBase` |
| `SongBlackboards` | `MapProperty` | `unknown` | `BP_PagodaGameState_C` |
| `SongPlayerComponent` | `ObjectProperty` | `PagodaSongPlayerComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaGameState_InfiniteDisco_C_2147475917.SongPlayerComponent` | `PagodaGameState` |
| `SpawnCollisionHandlingMethod` | `EnumProperty` | `1` | `Actor` |
| `Spawners` | `ArrayProperty` | `unknown` | `BP_PagodaGameState_InfiniteDisco_C` |
| `SpectatorClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Characters/Player/BP_PagodaSpectatorPawn.BP_PagodaSpectatorPawn_C` | `GameStateBase` |
| `StartupTags` | `StructProperty` | `ScriptStruct /Script/GameplayTags.GameplayTagContainer` | `BP_PagodaGameState_C` |
| `Tags` | `ArrayProperty` | `unknown` | `Actor` |
| `TimeRemaining` | `DoubleProperty` | `187.96737194061` | `BP_PagodaGameState_InfiniteDisco_C` |
| `TimeRemainingUpdateTimer` | `StructProperty` | `ScriptStruct /Script/Engine.TimerHandle` | `BP_PagodaGameState_InfiniteDisco_C` |
| `UberGraphFrame` | `StructProperty` | `ScriptStruct /Script/Engine.PointerToUberGraphFrame` | `BP_PagodaGameState_C` |
| `UpdateOverlapsMethodDuringLevelStreaming` | `EnumProperty` | `0` | `Actor` |
| `bActorEnableCollision` | `BoolProperty` | `true` | `Actor` |
| `bActorIsBeingDestroyed` | `BoolProperty` | `false` | `Actor` |
| `bAllowReceiveTickEventOnDedicatedServer` | `BoolProperty` | `true` | `Actor` |
| `bAllowTickBeforeBeginPlay` | `BoolProperty` | `true` | `Actor` |
| `bAlwaysRelevant` | `BoolProperty` | `true` | `Actor` |
| `bAsyncPhysicsTickEnabled` | `BoolProperty` | `false` | `Actor` |
| `bAutoDestroyWhenFinished` | `BoolProperty` | `false` | `Actor` |
| `bBlockInput` | `BoolProperty` | `false` | `Actor` |
| `bCallPreReplication` | `BoolProperty` | `true` | `Actor` |
| `bCallPreReplicationForReplay` | `BoolProperty` | `true` | `Actor` |
| `bCanBeDamaged` | `BoolProperty` | `false` | `Actor` |
| `bCanBeInCluster` | `BoolProperty` | `false` | `Actor` |
| `bCollideWhenPlacing` | `BoolProperty` | `false` | `Actor` |
| `bEnableAutoLODGeneration` | `BoolProperty` | `false` | `Actor` |
| `bExchangedRoles` | `BoolProperty` | `true` | `Actor` |
| `bFindCameraComponentWhenViewTarget` | `BoolProperty` | `true` | `Actor` |
| `bForceNetAddressable` | `BoolProperty` | `false` | `Actor` |
| `bGenerateOverlapEventsDuringLevelStreaming` | `BoolProperty` | `false` | `Actor` |
| `bHasStartedLevelEndFlow` | `BoolProperty` | `false` | `BP_PagodaGameState_C` |
| `bHidden` | `BoolProperty` | `true` | `Actor` |
| `bIgnoresOriginShifting` | `BoolProperty` | `false` | `Actor` |
| `bInfiniteDiscoByUI` | `BoolProperty` | `true` | `BP_PagodaGameState_InfiniteDisco_C` |
| `bIsActive` | `BoolProperty` | `false` | `BP_PagodaGameState_InfiniteDisco_C` |
| `bIsEditorOnlyActor` | `BoolProperty` | `false` | `Actor` |
| `bIsInfinite` | `BoolProperty` | `false` | `BP_PagodaGameState_InfiniteDisco_C` |
| `bLastPlayedSongLooping` | `BoolProperty` | `false` | `BP_PagodaGameState_C` |
| `bNetLoadOnClient` | `BoolProperty` | `false` | `Actor` |
| `bNetTemporary` | `BoolProperty` | `false` | `Actor` |
| `bNetUseOwnerRelevancy` | `BoolProperty` | `false` | `Actor` |
| `bOnlyRelevantToOwner` | `BoolProperty` | `false` | `Actor` |
| `bRelevantForLevelBounds` | `BoolProperty` | `true` | `Actor` |
| `bRelevantForNetworkReplays` | `BoolProperty` | `true` | `Actor` |
| `bReplayRewindable` | `BoolProperty` | `false` | `Actor` |
| `bReplicateMovement` | `BoolProperty` | `false` | `Actor` |
| `bReplicateUsingRegisteredSubObjectList` | `BoolProperty` | `false` | `Actor` |
| `bReplicatedHasBegunPlay` | `BoolProperty` | `true` | `GameStateBase` |
| `bReplicates` | `BoolProperty` | `true` | `Actor` |
| `bShowSongListOnNextLevelRestart` | `BoolProperty` | `false` | `BP_PagodaGameState_InfiniteDisco_C` |
| `bTearOff` | `BoolProperty` | `false` | `Actor` |
| `round` | `IntProperty` | `1` | `BP_PagodaGameState_InfiniteDisco_C` |

### Class `BP_PagodaPlayerController_C` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `AcknowledgedPawn` | `ObjectProperty` | `BP_PagodaPlayerCharacter_Charlie_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerCharacter_Charlie_C_2147473547` | `PlayerController` |
| `ActiveForceFeedbackEffects` | `ArrayProperty` | `unknown` | `PlayerController` |
| `AttachmentReplication` | `StructProperty` | `ScriptStruct /Script/Engine.RepAttachment` | `Actor` |
| `AutoReceiveInput` | `ByteProperty` | `0` | `Actor` |
| `BPC_IndicatorHandler_DebugHealthBar` | `ObjectProperty` | `BPC_IndicatorHandler_DebugHealthBar_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.BPC_IndicatorHandler_DebugHealthBar` | `BP_PagodaPlayerController_C` |
| `BPC_IndicatorHandler_ExecutionIndicator` | `ObjectProperty` | `BPC_IndicatorHandler_ExecutionIndicator_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.BPC_IndicatorHandler_ExecutionIndicator` | `BP_PagodaPlayerController_C` |
| `BPC_IndicatorHandler_OnScreenAttacks` | `ObjectProperty` | `BPC_IndicatorHandler_OnScreenAttacks_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.BPC_IndicatorHandler_OnScreenAttacks` | `BP_PagodaPlayerController_C` |
| `BPC_IndicatorHandler_PassiveAttackIndicator` | `ObjectProperty` | `BPC_IndicatorHandler_PassiveAttackIndicator_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.BPC_IndicatorHandler_PassiveAttackIndicator` | `BP_PagodaPlayerController_C` |
| `BPC_IndicatorHandler_TakedownIndicator` | `ObjectProperty` | `BPC_IndicatorHandler_FinisherIndicator_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.BPC_IndicatorHandler_TakedownIndicator` | `BP_PagodaPlayerController_C` |
| `BPC_IndicatorManagerComponent` | `ObjectProperty` | `BPC_IndicatorManagerComponent_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.BPC_IndicatorManagerComponent` | `BP_PagodaPlayerController_C` |
| `BPC_OffscreenAttackerIndicatorHandler` | `ObjectProperty` | `BPC_IndicatorHandler_OffscreenEnemies_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.BPC_OffscreenAttackerIndicatorHandler` | `BP_PagodaPlayerController_C` |
| `BPC_PlayerTempFeverBarHandler` | `ObjectProperty` | `BPC_PlayerTempFeverBarHandler_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.BPC_PlayerTempFeverBarHandler` | `BP_PagodaPlayerController_C` |
| `BlueprintCreatedComponents` | `ArrayProperty` | `unknown` | `Actor` |
| `CachedConnectionPlayerId` | `StructProperty` | `ScriptStruct /Script/Engine.UniqueNetIdRepl` | `PlayerController` |
| `Character` | `ObjectProperty` | `BP_PagodaPlayerCharacter_Charlie_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerCharacter_Charlie_C_2147473547` | `Controller` |
| `CheatClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Core/Cheat/BP_PagodaCheatManager.BP_PagodaCheatManager_C` | `PlayerController` |
| `CheatManager` | `ObjectProperty` | `nil` | `PlayerController` |
| `Children` | `ArrayProperty` | `unknown` | `Actor` |
| `ClickEventKeys` | `ArrayProperty` | `unknown` | `PlayerController` |
| `ClientCap` | `IntProperty` | `0` | `PlayerController` |
| `ClientHandshakeId` | `UInt32Property` | `0` | `PlayerController` |
| `ControlRotation` | `StructProperty` | `ScriptStruct /Script/CoreUObject.Rotator` | `Controller` |
| `CurrentClickTraceChannel` | `ByteProperty` | `3` | `PlayerController` |
| `CurrentMouseCursor` | `ByteProperty` | `1` | `PlayerController` |
| `CurrentTouchInterface` | `ObjectProperty` | `nil` | `PlayerController` |
| `CustomTimeDilation` | `FloatProperty` | `1.0` | `Actor` |
| `DefaultClickTraceChannel` | `ByteProperty` | `3` | `PlayerController` |
| `DefaultMouseCursor` | `ByteProperty` | `1` | `PlayerController` |
| `DefaultUpdateOverlapsMethodDuringLevelStreaming` | `EnumProperty` | `2` | `Actor` |
| `ForceFeedbackScale` | `FloatProperty` | `1.0` | `PlayerController` |
| `HLODLayer` | `ObjectProperty` | `nil` | `Actor` |
| `HiddenActors` | `ArrayProperty` | `unknown` | `PlayerController` |
| `HiddenPrimitiveComponents` | `ArrayProperty` | `unknown` | `PlayerController` |
| `HitResultTraceDistance` | `FloatProperty` | `100000.0` | `PlayerController` |
| `InactiveStateInputComponent` | `ObjectProperty` | `nil` | `PlayerController` |
| `InitialLifeSpan` | `FloatProperty` | `0.0` | `Actor` |
| `InputComponent` | `ObjectProperty` | `EnhancedInputComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.PC_InputComponent0` | `Actor` |
| `InputPitchScale` | `FloatProperty` | `-2.5` | `PlayerController` |
| `InputPriority` | `IntProperty` | `0` | `Actor` |
| `InputRollScale` | `FloatProperty` | `1.0` | `PlayerController` |
| `InputYawScale` | `FloatProperty` | `2.5` | `PlayerController` |
| `InstanceComponents` | `ArrayProperty` | `unknown` | `Actor` |
| `Instigator` | `ObjectProperty` | `nil` | `Actor` |
| `LastCompletedSeamlessTravelCount` | `UInt16Property` | `0` | `PlayerController` |
| `LastSpectatorStateSynchTime` | `FloatProperty` | `0.0` | `PlayerController` |
| `LastSpectatorSyncLocation` | `StructProperty` | `ScriptStruct /Script/CoreUObject.Vector` | `PlayerController` |
| `LastSpectatorSyncRotation` | `StructProperty` | `ScriptStruct /Script/CoreUObject.Rotator` | `PlayerController` |
| `Layers` | `ArrayProperty` | `unknown` | `Actor` |
| `MinNetUpdateFrequency` | `FloatProperty` | `2.0` | `Actor` |
| `MpSessionComponent` | `ObjectProperty` | `PagodaMpSessionPlayerControllerComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.MpSessionComponent` | `PagodaPlayerController` |
| `MyHUD` | `ObjectProperty` | `BP_PagodaHUD_InfiniteDisco_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaHUD_InfiniteDisco_C_2147475830` | `PlayerController` |
| `NetConnection` | `ObjectProperty` | `nil` | `PlayerController` |
| `NetCullDistanceSquared` | `FloatProperty` | `225000000.0` | `Actor` |
| `NetDormancy` | `ByteProperty` | `1` | `Actor` |
| `NetDriverName` | `NameProperty` | `unknown` | `Actor` |
| `NetPlayerIndex` | `ByteProperty` | `0` | `PlayerController` |
| `NetPriority` | `FloatProperty` | `3.0` | `Actor` |
| `NetTag` | `IntProperty` | `0` | `Actor` |
| `NetUpdateFrequency` | `FloatProperty` | `100.0` | `Actor` |
| `OnActorBeginOverlap` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorBeginOverlap` | `Actor` |
| `OnActorEndOverlap` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorEndOverlap` | `Actor` |
| `OnActorHit` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorHit` | `Actor` |
| `OnBeginCursorOver` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnBeginCursorOver` | `Actor` |
| `OnClicked` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnClicked` | `Actor` |
| `OnDestroyed` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnDestroyed` | `Actor` |
| `OnEndCursorOver` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnEndCursorOver` | `Actor` |
| `OnEndPlay` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnEndPlay` | `Actor` |
| `OnInputTouchBegin` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchBegin` | `Actor` |
| `OnInputTouchEnd` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchEnd` | `Actor` |
| `OnInputTouchEnter` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchEnter` | `Actor` |
| `OnInputTouchLeave` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchLeave` | `Actor` |
| `OnInstigatedAnyDamage` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Engine.Controller:OnInstigatedAnyDamage` | `Controller` |
| `OnKeyPressed` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Game/Pagoda/Characters/Player/BP_PagodaPlayerController.BP_PagodaPlayerController_C:OnKeyPressed` | `BP_PagodaPlayerController_C` |
| `OnPossessedPawnChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Engine.Controller:OnPossessedPawnChanged` | `Controller` |
| `OnReleased` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnReleased` | `Actor` |
| `OnTakeAnyDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakeAnyDamage` | `Actor` |
| `OnTakePointDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakePointDamage` | `Actor` |
| `OnTakeRadialDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakeRadialDamage` | `Actor` |
| `OverridePlayerInputClass` | `ClassProperty` | `nil` | `PlayerController` |
| `Owner` | `ObjectProperty` | `nil` | `Actor` |
| `ParentComponent` | `WeakObjectProperty` | `unknown` | `Actor` |
| `Pawn` | `ObjectProperty` | `BP_PagodaPlayerCharacter_Charlie_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerCharacter_Charlie_C_2147473547` | `Controller` |
| `PendingSwapConnection` | `ObjectProperty` | `nil` | `PlayerController` |
| `PhysicsReplicationMode` | `EnumProperty` | `0` | `Actor` |
| `Player` | `ObjectProperty` | `PagodaLocalPlayer /Engine/Transient.GameEngine_2147482572:PagodaLocalPlayer_2147482279` | `PlayerController` |
| `PlayerCameraManager` | `ObjectProperty` | `BP_PlayerCameraManager_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PlayerCameraManager_C_2147475911` | `PlayerController` |
| `PlayerCameraManagerClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/Camera/BP_PlayerCameraManager.BP_PlayerCameraManager_C` | `PlayerController` |
| `PlayerDialogueComponent` | `ObjectProperty` | `BP_PlayerDialogueComponent_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.PlayerDialogueComponent` | `BP_PagodaPlayerController_C` |
| `PlayerInput` | `ObjectProperty` | `PagodaEnhancedPlayerInput /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.PagodaEnhancedPlayerInput_2147475897` | `PlayerController` |
| `PlayerState` | `ObjectProperty` | `BP_PagodaPlayerState_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912` | `Controller` |
| `PrimaryActorTick` | `StructProperty` | `ScriptStruct /Script/Engine.ActorTickFunction` | `Actor` |
| `RayTracingGroupId` | `IntProperty` | `-1` | `Actor` |
| `RemoteRole` | `ByteProperty` | `1` | `Actor` |
| `ReplicatedMovement` | `StructProperty` | `ScriptStruct /Script/Engine.RepMovement` | `Actor` |
| `Role` | `ByteProperty` | `3` | `Actor` |
| `RootComponent` | `ObjectProperty` | `SceneComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.TransformComponent0` | `Actor` |
| `SeamlessTravelCount` | `UInt16Property` | `0` | `PlayerController` |
| `SmoothTargetViewRotationSpeed` | `FloatProperty` | `20.0` | `PlayerController` |
| `SpawnCollisionHandlingMethod` | `EnumProperty` | `1` | `Actor` |
| `SpawnLocation` | `StructProperty` | `ScriptStruct /Script/CoreUObject.Vector` | `PlayerController` |
| `SpectatorPawn` | `ObjectProperty` | `nil` | `PlayerController` |
| `StateName` | `NameProperty` | `unknown` | `Controller` |
| `StreamingSourceDebugColor` | `StructProperty` | `ScriptStruct /Script/CoreUObject.Color` | `PlayerController` |
| `StreamingSourcePriority` | `EnumProperty` | `128` | `PlayerController` |
| `StreamingSourceShapes` | `ArrayProperty` | `unknown` | `PlayerController` |
| `Tags` | `ArrayProperty` | `unknown` | `Actor` |
| `TargetViewRotation` | `StructProperty` | `ScriptStruct /Script/CoreUObject.Rotator` | `PlayerController` |
| `TransformComponent` | `ObjectProperty` | `SceneComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.TransformComponent0` | `Controller` |
| `UberGraphFrame` | `StructProperty` | `ScriptStruct /Script/Engine.PointerToUberGraphFrame` | `BP_PagodaPlayerController_C` |
| `UpdateOverlapsMethodDuringLevelStreaming` | `EnumProperty` | `0` | `Actor` |
| `WasGamePausedBeforeSubmitting` | `BoolProperty` | `false` | `BP_PagodaPlayerController_C` |
| `WhitelistedInputs` | `SetProperty` | `unknown` | `PagodaPlayerController` |
| `WidgetInteraction` | `ObjectProperty` | `WidgetInteractionComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913.WidgetInteraction` | `BP_PagodaPlayerController_C` |
| `bActorEnableCollision` | `BoolProperty` | `true` | `Actor` |
| `bActorIsBeingDestroyed` | `BoolProperty` | `false` | `Actor` |
| `bAllowReceiveTickEventOnDedicatedServer` | `BoolProperty` | `true` | `Actor` |
| `bAllowTickBeforeBeginPlay` | `BoolProperty` | `true` | `Actor` |
| `bAlwaysRelevant` | `BoolProperty` | `false` | `Actor` |
| `bAsyncPhysicsTickEnabled` | `BoolProperty` | `false` | `Actor` |
| `bAttachToPawn` | `BoolProperty` | `false` | `Controller` |
| `bAutoDestroyWhenFinished` | `BoolProperty` | `false` | `Actor` |
| `bAutoManageActiveCameraTarget` | `BoolProperty` | `true` | `PlayerController` |
| `bBlockInput` | `BoolProperty` | `false` | `Actor` |
| `bCallPreReplication` | `BoolProperty` | `true` | `Actor` |
| `bCallPreReplicationForReplay` | `BoolProperty` | `true` | `Actor` |
| `bCanBeDamaged` | `BoolProperty` | `false` | `Actor` |
| `bCanBeInCluster` | `BoolProperty` | `false` | `Actor` |
| `bCollideWhenPlacing` | `BoolProperty` | `false` | `Actor` |
| `bEnableAutoLODGeneration` | `BoolProperty` | `true` | `Actor` |
| `bEnableClickEvents` | `BoolProperty` | `false` | `PlayerController` |
| `bEnableMotionControls` | `BoolProperty` | `true` | `PlayerController` |
| `bEnableMouseOverEvents` | `BoolProperty` | `false` | `PlayerController` |
| `bEnableStreamingSource` | `BoolProperty` | `true` | `PlayerController` |
| `bEnableTouchEvents` | `BoolProperty` | `true` | `PlayerController` |
| `bEnableTouchOverEvents` | `BoolProperty` | `false` | `PlayerController` |
| `bExchangedRoles` | `BoolProperty` | `true` | `Actor` |
| `bFindCameraComponentWhenViewTarget` | `BoolProperty` | `true` | `Actor` |
| `bForceFeedbackEnabled` | `BoolProperty` | `true` | `PlayerController` |
| `bForceNetAddressable` | `BoolProperty` | `false` | `Actor` |
| `bGenerateOverlapEventsDuringLevelStreaming` | `BoolProperty` | `false` | `Actor` |
| `bHidden` | `BoolProperty` | `true` | `Actor` |
| `bIgnoresOriginShifting` | `BoolProperty` | `false` | `Actor` |
| `bIsEditorOnlyActor` | `BoolProperty` | `false` | `Actor` |
| `bIsLocalPlayerController` | `BoolProperty` | `true` | `PlayerController` |
| `bNetLoadOnClient` | `BoolProperty` | `true` | `Actor` |
| `bNetTemporary` | `BoolProperty` | `false` | `Actor` |
| `bNetUseOwnerRelevancy` | `BoolProperty` | `false` | `Actor` |
| `bOnlyRelevantToOwner` | `BoolProperty` | `true` | `Actor` |
| `bPlayerIsWaiting` | `BoolProperty` | `false` | `PlayerController` |
| `bRelevantForLevelBounds` | `BoolProperty` | `true` | `Actor` |
| `bRelevantForNetworkReplays` | `BoolProperty` | `true` | `Actor` |
| `bReplayRewindable` | `BoolProperty` | `false` | `Actor` |
| `bReplicateMovement` | `BoolProperty` | `false` | `Actor` |
| `bReplicateUsingRegisteredSubObjectList` | `BoolProperty` | `false` | `Actor` |
| `bReplicates` | `BoolProperty` | `true` | `Actor` |
| `bShouldPerformFullTickWhenPaused` | `BoolProperty` | `false` | `PlayerController` |
| `bShowMouseCursor` | `BoolProperty` | `false` | `PlayerController` |
| `bStreamingSourceShouldActivate` | `BoolProperty` | `true` | `PlayerController` |
| `bStreamingSourceShouldBlockOnSlowStreaming` | `BoolProperty` | `true` | `PlayerController` |
| `bTearOff` | `BoolProperty` | `false` | `Actor` |

### Class `BP_PagodaPlayerState_C` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `AbilitySystemComponent` | `ObjectProperty` | `PagodaAbilitySystemComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912.AbilitySystemComponent` | `PagodaPlayerState` |
| `AttachmentReplication` | `StructProperty` | `ScriptStruct /Script/Engine.RepAttachment` | `Actor` |
| `AutoReceiveInput` | `ByteProperty` | `0` | `Actor` |
| `BlueprintCreatedComponents` | `ArrayProperty` | `unknown` | `Actor` |
| `Children` | `ArrayProperty` | `unknown` | `Actor` |
| `CombatAttributeSet` | `ObjectProperty` | `PagodaCombatAttributeSet /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912.CombatAttributeSet` | `PagodaPlayerState` |
| `CompressedPing` | `ByteProperty` | `0` | `PlayerState` |
| `CustomTimeDilation` | `FloatProperty` | `1.0` | `Actor` |
| `DefaultSceneRoot` | `ObjectProperty` | `SceneComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912.DefaultSceneRoot` | `BP_PagodaPlayerState_C` |
| `DefaultUpdateOverlapsMethodDuringLevelStreaming` | `EnumProperty` | `2` | `Actor` |
| `EngineMessageClass` | `ClassProperty` | `Class /Script/Engine.EngineMessage` | `PlayerState` |
| `HLODLayer` | `ObjectProperty` | `nil` | `Actor` |
| `HealthAttributeSet` | `ObjectProperty` | `PagodaHealthAttributeSet /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912.HealthAttributeSet` | `PagodaPlayerState` |
| `InitialLifeSpan` | `FloatProperty` | `0.0` | `Actor` |
| `InputComponent` | `ObjectProperty` | `nil` | `Actor` |
| `InputPriority` | `IntProperty` | `0` | `Actor` |
| `InstanceComponents` | `ArrayProperty` | `unknown` | `Actor` |
| `Instigator` | `ObjectProperty` | `nil` | `Actor` |
| `Layers` | `ArrayProperty` | `unknown` | `Actor` |
| `MinNetUpdateFrequency` | `FloatProperty` | `2.0` | `Actor` |
| `MovementAttributeSet` | `ObjectProperty` | `PagodaMovementAttributeSet /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912.MovementAttributeSet` | `PagodaPlayerState` |
| `MpSessionComponent` | `ObjectProperty` | `PagodaMpSessionPlayerStateComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912.MpSessionComponent` | `PagodaPlayerState` |
| `NetCullDistanceSquared` | `FloatProperty` | `225000000.0` | `Actor` |
| `NetDormancy` | `ByteProperty` | `1` | `Actor` |
| `NetDriverName` | `NameProperty` | `unknown` | `Actor` |
| `NetPriority` | `FloatProperty` | `1.0` | `Actor` |
| `NetTag` | `IntProperty` | `0` | `Actor` |
| `NetUpdateFrequency` | `FloatProperty` | `100.0` | `Actor` |
| `OnActorBeginOverlap` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorBeginOverlap` | `Actor` |
| `OnActorEndOverlap` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorEndOverlap` | `Actor` |
| `OnActorHit` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnActorHit` | `Actor` |
| `OnBeginCursorOver` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnBeginCursorOver` | `Actor` |
| `OnClicked` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnClicked` | `Actor` |
| `OnDestroyed` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnDestroyed` | `Actor` |
| `OnEndCursorOver` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnEndCursorOver` | `Actor` |
| `OnEndPlay` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnEndPlay` | `Actor` |
| `OnInputTouchBegin` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchBegin` | `Actor` |
| `OnInputTouchEnd` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchEnd` | `Actor` |
| `OnInputTouchEnter` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchEnter` | `Actor` |
| `OnInputTouchLeave` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnInputTouchLeave` | `Actor` |
| `OnPawnSet` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Engine.PlayerState:OnPawnSet` | `PlayerState` |
| `OnPlayerNameChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlayerState:OnPlayerNameChanged` | `PagodaPlayerState` |
| `OnReleased` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnReleased` | `Actor` |
| `OnTakeAnyDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakeAnyDamage` | `Actor` |
| `OnTakePointDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakePointDamage` | `Actor` |
| `OnTakeRadialDamage` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.Actor:OnTakeRadialDamage` | `Actor` |
| `Owner` | `ObjectProperty` | `BP_PagodaPlayerController_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerController_C_2147475913` | `Actor` |
| `ParentComponent` | `WeakObjectProperty` | `unknown` | `Actor` |
| `PawnPrivate` | `ObjectProperty` | `BP_PagodaPlayerCharacter_Charlie_C /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerCharacter_Charlie_C_2147473547` | `PlayerState` |
| `PhysicsReplicationMode` | `EnumProperty` | `0` | `Actor` |
| `PlayerId` | `IntProperty` | `259` | `PlayerState` |
| `PlayerNamePrivate` | `StrProperty` | `unknown` | `PlayerState` |
| `PlayerOnlyAttributeSet` | `ObjectProperty` | `PagodaPlayerOnlyAttributeSet /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912.PlayerOnlyAttributeSet` | `PagodaPlayerState` |
| `PlaythroughData` | `ObjectProperty` | `PagodaPlaythroughPlayerData /Engine/Transient.GameEngine_2147482572:GI_PagodaGameInstance_C_2147482510.PagodaGameSavesSubsystem_2147482356.PagodaPlaythroughPlayerData_2147482355` | `PagodaPlayerState` |
| `PrimaryActorTick` | `StructProperty` | `ScriptStruct /Script/Engine.ActorTickFunction` | `Actor` |
| `RayTracingGroupId` | `IntProperty` | `-1` | `Actor` |
| `RemoteRole` | `ByteProperty` | `1` | `Actor` |
| `ReplicatedMovement` | `StructProperty` | `ScriptStruct /Script/Engine.RepMovement` | `Actor` |
| `Role` | `ByteProperty` | `3` | `Actor` |
| `RootComponent` | `ObjectProperty` | `SceneComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912.DefaultSceneRoot` | `Actor` |
| `SavedNetworkAddress` | `StrProperty` | `unknown` | `PlayerState` |
| `Score` | `FloatProperty` | `0.0` | `PlayerState` |
| `ScoreComponent` | `ObjectProperty` | `PagodaPlayerStateScoreComponent /Game/Pagoda/Levels/InfiniteDisco/L_InfiniteDisco_Persistent.L_InfiniteDisco_Persistent:PersistentLevel.BP_PagodaPlayerState_C_2147475912.ScoreComponent` | `PagodaPlayerState` |
| `SpawnCollisionHandlingMethod` | `EnumProperty` | `1` | `Actor` |
| `StartTime` | `IntProperty` | `0` | `PlayerState` |
| `Tags` | `ArrayProperty` | `unknown` | `Actor` |
| `UberGraphFrame` | `StructProperty` | `ScriptStruct /Script/Engine.PointerToUberGraphFrame` | `BP_PagodaPlayerState_C` |
| `UniqueID` | `StructProperty` | `ScriptStruct /Script/Engine.UniqueNetIdRepl` | `PlayerState` |
| `UpdateOverlapsMethodDuringLevelStreaming` | `EnumProperty` | `0` | `Actor` |
| `bActorEnableCollision` | `BoolProperty` | `true` | `Actor` |
| `bActorIsBeingDestroyed` | `BoolProperty` | `false` | `Actor` |
| `bAllowReceiveTickEventOnDedicatedServer` | `BoolProperty` | `true` | `Actor` |
| `bAllowTickBeforeBeginPlay` | `BoolProperty` | `true` | `Actor` |
| `bAlwaysRelevant` | `BoolProperty` | `true` | `Actor` |
| `bAsyncPhysicsTickEnabled` | `BoolProperty` | `false` | `Actor` |
| `bAutoDestroyWhenFinished` | `BoolProperty` | `false` | `Actor` |
| `bBlockInput` | `BoolProperty` | `false` | `Actor` |
| `bCallPreReplication` | `BoolProperty` | `true` | `Actor` |
| `bCallPreReplicationForReplay` | `BoolProperty` | `true` | `Actor` |
| `bCanBeDamaged` | `BoolProperty` | `false` | `Actor` |
| `bCanBeInCluster` | `BoolProperty` | `false` | `Actor` |
| `bCollideWhenPlacing` | `BoolProperty` | `false` | `Actor` |
| `bEnableAutoLODGeneration` | `BoolProperty` | `false` | `Actor` |
| `bExchangedRoles` | `BoolProperty` | `true` | `Actor` |
| `bFindCameraComponentWhenViewTarget` | `BoolProperty` | `true` | `Actor` |
| `bForceNetAddressable` | `BoolProperty` | `false` | `Actor` |
| `bFromPreviousLevel` | `BoolProperty` | `false` | `PlayerState` |
| `bGenerateOverlapEventsDuringLevelStreaming` | `BoolProperty` | `false` | `Actor` |
| `bHidden` | `BoolProperty` | `true` | `Actor` |
| `bIgnoresOriginShifting` | `BoolProperty` | `false` | `Actor` |
| `bIsABot` | `BoolProperty` | `false` | `PlayerState` |
| `bIsEditorOnlyActor` | `BoolProperty` | `false` | `Actor` |
| `bIsInactive` | `BoolProperty` | `false` | `PlayerState` |
| `bIsSpectator` | `BoolProperty` | `false` | `PlayerState` |
| `bNetLoadOnClient` | `BoolProperty` | `false` | `Actor` |
| `bNetTemporary` | `BoolProperty` | `false` | `Actor` |
| `bNetUseOwnerRelevancy` | `BoolProperty` | `false` | `Actor` |
| `bOnlyRelevantToOwner` | `BoolProperty` | `false` | `Actor` |
| `bOnlySpectator` | `BoolProperty` | `false` | `PlayerState` |
| `bRelevantForLevelBounds` | `BoolProperty` | `true` | `Actor` |
| `bRelevantForNetworkReplays` | `BoolProperty` | `true` | `Actor` |
| `bReplayRewindable` | `BoolProperty` | `false` | `Actor` |
| `bReplicateMovement` | `BoolProperty` | `false` | `Actor` |
| `bReplicateUsingRegisteredSubObjectList` | `BoolProperty` | `false` | `Actor` |
| `bReplicates` | `BoolProperty` | `true` | `Actor` |
| `bShouldUpdateReplicatedPing` | `BoolProperty` | `true` | `PlayerState` |
| `bTearOff` | `BoolProperty` | `false` | `Actor` |

### Class `GI_PagodaGameInstance_C` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `GI_DebugON` | `BoolProperty` | `false` | `GI_PagodaGameInstance_C` |
| `LocalPlayers` | `ArrayProperty` | `unknown` | `GameInstance` |
| `Music` | `ObjectProperty` | `BP_Music_C /Temp/Game/Pagoda/Levels/Arenas/LI_Arenas_LevelInstance_a3a9a1e2f444b27d_1.LI_Arenas:PersistentLevel.BP_Music_C_UAID_107C614BF20E689C02_1774409564` | `GI_PagodaGameInstance_C` |
| `MusicFmodEventInstance` | `StructProperty` | `ScriptStruct /Script/FMODStudio.FMODEventInstance` | `GI_PagodaGameInstance_C` |
| `MusicParams` | `ObjectProperty` | `DataTable /Game/MusicSystem/MusicParams.MusicParams` | `GI_PagodaGameInstance_C` |
| `OnInputDeviceConnectionChange` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Engine.GameInstance:OnInputDeviceConnectionChange` | `GameInstance` |
| `OnPawnControllerChangedDelegates` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Engine.GameInstance:OnPawnControllerChangedDelegates` | `GameInstance` |
| `OnUserInputDevicePairingChange` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Engine.GameInstance:OnUserInputDevicePairingChange` | `GameInstance` |
| `OnWorldChangedEvent` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaGameInstance:OnWorldChangedEvent` | `PagodaGameInstance` |
| `OnlineSession` | `ObjectProperty` | `OnlineSession /Engine/Transient.GameEngine_2147482572:GI_PagodaGameInstance_C_2147482510.OnlineSession_2147482387` | `GameInstance` |
| `PendingDebugFocusRequests` | `ArrayProperty` | `unknown` | `PagodaGameInstance` |
| `ReferencedObjects` | `ArrayProperty` | `unknown` | `GameInstance` |
| `TexturesToLoadOnStart` | `ArrayProperty` | `unknown` | `GI_PagodaGameInstance_C` |
| `UIEventDispatchers` | `ObjectProperty` | `BP_UI_EventDispatchers_C /Engine/Transient.GameEngine_2147482572:GI_PagodaGameInstance_C_2147482510.BP_UI_EventDispatchers_C_2147482388` | `GI_PagodaGameInstance_C` |
| `UberGraphFrame` | `StructProperty` | `ScriptStruct /Script/Engine.PointerToUberGraphFrame` | `GI_PagodaGameInstance_C` |
| `bTempForcePlayIntro` | `BoolProperty` | `false` | `GI_PagodaGameInstance_C` |

### Class `PagodaChallengeCatalogSubsystem` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `AllChallenges` | `ArrayProperty` | `unknown` | `PagodaChallengeCatalogSubsystem` |
| `AllMods` | `ArrayProperty` | `unknown` | `PagodaChallengeCatalogSubsystem` |
| `AllObjectives` | `ArrayProperty` | `unknown` | `PagodaChallengeCatalogSubsystem` |
| `AllPlaylists` | `ArrayProperty` | `unknown` | `PagodaChallengeCatalogSubsystem` |
| `AllUserChallenges` | `ArrayProperty` | `unknown` | `PagodaChallengeCatalogSubsystem` |
| `CachedChallengeOfTheDay` | `ObjectProperty` | `nil` | `PagodaChallengeCatalogSubsystem` |
| `CachedNPCTagToRowHandleMap` | `MapProperty` | `unknown` | `PagodaChallengeCatalogSubsystem` |
| `CachedPlaylists` | `ArrayProperty` | `unknown` | `PagodaChallengeCatalogSubsystem` |
| `ChallengeDataBPClass` | `ClassProperty` | `BlueprintGeneratedClass /Game/Pagoda/UI/SongList/ChallengeEditor/BP_PagodaChallengeData.BP_PagodaChallengeData_C` | `PagodaChallengeCatalogSubsystem` |
| `ChallengeSettings` | `ObjectProperty` | `PagodaChallengeSettingsDataAsset /Game/Pagoda/Challenges/DA_PagodaChallengeSettings.DA_PagodaChallengeSettings` | `PagodaChallengeCatalogSubsystem` |
| `ChallengesSortedForUI` | `ArrayProperty` | `unknown` | `PagodaChallengeCatalogSubsystem` |
| `ObjectiveSettings` | `ObjectProperty` | `PagodaObjectiveSettingsDataAsset /Game/Pagoda/Objectives/DA_PagodaObjectiveSettings.DA_PagodaObjectiveSettings` | `PagodaChallengeCatalogSubsystem` |
| `OnChallengesSortedForUIChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaChallengeCatalogSubsystem:OnChallengesSortedForUIChanged` | `PagodaChallengeCatalogSubsystem` |
| `OnPlaylistsSortedForUIChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaChallengeCatalogSubsystem:OnPlaylistsSortedForUIChanged` | `PagodaChallengeCatalogSubsystem` |
| `PossibleChallengesOfTheDay` | `ArrayProperty` | `unknown` | `PagodaChallengeCatalogSubsystem` |

### Class `PagodaChallengeDataAsset` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `ArenaColorVariantIndex` | `IntProperty` | `0` | `PagodaChallengeDataAsset` |
| `ArenaIdTag` | `StructProperty` | `ScriptStruct /Script/GameplayTags.GameplayTag` | `PagodaChallengeDataAsset` |
| `Description` | `TextProperty` | `unknown` | `PagodaChallengeDataAsset` |
| `IncursionPreset` | `StructProperty` | `ScriptStruct /Script/Engine.DataTableRowHandle` | `PagodaChallengeDataAsset` |
| `IncursionProfile` | `ObjectProperty` | `DataTable /Game/Pagoda/Levels/Test/DT_IncursionProfiles_InfiniteDisco.DT_IncursionProfiles_InfiniteDisco` | `PagodaChallengeDataAsset` |
| `IsForChallengeOfTheDay` | `BoolProperty` | `false` | `PagodaChallengeDataAsset` |
| `LeaderboardVersion` | `IntProperty` | `1` | `PagodaChallengeDataAsset` |
| `Mods` | `ArrayProperty` | `unknown` | `PagodaChallengeDataAsset` |
| `NativeClass` | `ClassProperty` | `Class /Script/Pagoda.PagodaChallengeDataAsset` | `DataAsset` |
| `Objectives` | `ArrayProperty` | `unknown` | `PagodaChallengeDataAsset` |
| `ProgressionTag` | `StructProperty` | `ScriptStruct /Script/GameplayTags.GameplayTag` | `PagodaChallengeDataAsset` |
| `Song` | `ObjectProperty` | `PagodaSong /Engine/Transient.GameEngine_2147482572:GI_PagodaGameInstance_C_2147482510.PagodaSongCatalogSubsystem_2147482331.Gorillaz - Feel Good Inc (Lyrics) - 7clouds Rap` | `PagodaChallengeDataAsset` |
| `SongEndTime` | `FloatProperty` | `0.0` | `PagodaChallengeDataAsset` |
| `SongPlaylist` | `ObjectProperty` | `nil` | `PagodaChallengeDataAsset` |
| `SongStartTime` | `FloatProperty` | `0.0` | `PagodaChallengeDataAsset` |
| `Title` | `TextProperty` | `unknown` | `PagodaChallengeDataAsset` |
| `UISortPriority` | `IntProperty` | `0` | `PagodaChallengeDataAsset` |
| `UnlockDef` | `ObjectProperty` | `nil` | `PagodaChallengeDataAsset` |
| `UserChallengeId` | `StructProperty` | `ScriptStruct /Script/CoreUObject.Guid` | `PagodaChallengeDataAsset` |
| `bCustomSongEnd` | `BoolProperty` | `false` | `PagodaChallengeDataAsset` |
| `bIsUserChallenge` | `BoolProperty` | `true` | `PagodaChallengeDataAsset` |

### Class `PagodaChallengeSettingsDataAsset` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `NativeClass` | `ClassProperty` | `Class /Script/Pagoda.PagodaChallengeSettingsDataAsset` | `DataAsset` |
| `UGCChallengeBuiltInModAssets` | `ArrayProperty` | `unknown` | `PagodaChallengeSettingsDataAsset` |

### Class `PagodaMusicSubsystem` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `ActiveSegmentHandle` | `StructProperty` | `ScriptStruct /Script/GameplayAbilities.GameplayAbilitySpecHandle` | `PagodaMusicSubsystem` |
| `DebugRepeatInterval` | `StructProperty` | `ScriptStruct /Script/Pagoda.PagodaSongDebugInterval` | `PagodaMusicSubsystem` |
| `GameplayMPCInstance` | `ObjectProperty` | `MaterialParameterCollectionInstance /Engine/Transient.MaterialParameterCollectionInstance_2147475942` | `PagodaMusicSubsystem` |
| `LevelFMODComponent` | `ObjectProperty` | `FMODAudioComponent /Temp/Game/Pagoda/Levels/Arenas/LI_Arenas_LevelInstance_a3a9a1e2f444b27d_1.LI_Arenas:PersistentLevel.BP_Music_C_UAID_107C614BF20E689C02_1774409564.FMODAudio` | `PagodaMusicSubsystem` |
| `SilentSongAsset` | `ObjectProperty` | `PagodaSong /Game/Pagoda/Audio/Songs/PS_BlandMilcho_150/PS_BlandMilcho_150.PS_BlandMilcho_150` | `PagodaMusicSubsystem` |
| `SongPlayer` | `ObjectProperty` | `PagodaSongPlayer /Engine/Transient.GameEngine_2147482572:GI_PagodaGameInstance_C_2147482510.PagodaMusicSubsystem_2147482335.PagodaSongPlayer_2147482333` | `PagodaMusicSubsystem` |
| `SpectrumRenderTarget` | `ObjectProperty` | `TextureRenderTarget2D /Game/Pagoda/Environment/RT_AudioSpectrum.RT_AudioSpectrum` | `PagodaMusicSubsystem` |
| `bUseUnadjustedBPMForPitch` | `BoolProperty` | `false` | `PagodaMusicSubsystem` |

### Class `PagodaPlayerStateScoreComponent` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `AssetUserData` | `ArrayProperty` | `unknown` | `ActorComponent` |
| `ComponentTags` | `ArrayProperty` | `unknown` | `ActorComponent` |
| `CreationMethod` | `EnumProperty` | `0` | `ActorComponent` |
| `MaxComboCount` | `IntProperty` | `5` | `PagodaPlayerStateScoreComponent` |
| `OnComponentActivated` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.ActorComponent:OnComponentActivated` | `ActorComponent` |
| `OnComponentDeactivated` | `MulticastSparseDelegateProperty` | `MulticastSparseDelegateProperty /Script/Engine.ActorComponent:OnComponentDeactivated` | `ActorComponent` |
| `OnPlayerScoreAdded` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlayerStateScoreComponent:OnPlayerScoreAdded` | `PagodaPlayerStateScoreComponent` |
| `OnScoreStackUpdated` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlayerStateScoreComponent:OnScoreStackUpdated` | `PagodaPlayerStateScoreComponent` |
| `PrimaryComponentTick` | `StructProperty` | `ScriptStruct /Script/Engine.ActorComponentTickFunction` | `ActorComponent` |
| `ScoreBreakdown` | `StructProperty` | `ScriptStruct /Script/Pagoda.PagodaPlayerScoreBreakdown` | `PagodaPlayerStateScoreComponent` |
| `UCSSerializationIndex` | `IntProperty` | `-1` | `ActorComponent` |
| `bAutoActivate` | `BoolProperty` | `false` | `ActorComponent` |
| `bCanEverAffectNavigation` | `BoolProperty` | `false` | `ActorComponent` |
| `bEditableWhenInherited` | `BoolProperty` | `true` | `ActorComponent` |
| `bIsActive` | `BoolProperty` | `false` | `ActorComponent` |
| `bIsEditorOnly` | `BoolProperty` | `false` | `ActorComponent` |
| `bNetAddressable` | `BoolProperty` | `false` | `ActorComponent` |
| `bReplicateUsingRegisteredSubObjectList` | `BoolProperty` | `false` | `ActorComponent` |
| `bReplicates` | `BoolProperty` | `true` | `ActorComponent` |

### Class `PagodaPlaythroughPlayerData` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `OnCosmeticEquippedStateChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlaythroughPlayerData:OnCosmeticEquippedStateChanged` | `PagodaPlaythroughPlayerData` |
| `OnCosmeticOwnedStateChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlaythroughPlayerData:OnCosmeticOwnedStateChanged` | `PagodaPlaythroughPlayerData` |
| `OnCreditsChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlaythroughPlayerData:OnCreditsChanged` | `PagodaPlaythroughPlayerData` |
| `OnDanceEquippedStateChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlaythroughPlayerData:OnDanceEquippedStateChanged` | `PagodaPlaythroughPlayerData` |
| `OnDanceRandomExclusionChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlaythroughPlayerData:OnDanceRandomExclusionChanged` | `PagodaPlaythroughPlayerData` |
| `OnStarsChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlaythroughPlayerData:OnStarsChanged` | `PagodaPlaythroughPlayerData` |
| `OnUpgradeEquipStateChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlaythroughPlayerData:OnUpgradeEquipStateChanged` | `PagodaPlaythroughPlayerData` |
| `OnUpgradeOwnedStateChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaPlaythroughPlayerData:OnUpgradeOwnedStateChanged` | `PagodaPlaythroughPlayerData` |
| `PlayerData` | `StructProperty` | `ScriptStruct /Script/Pagoda.PagodaSaveData_PlayerPlaythrough` | `PagodaPlaythroughPlayerData` |
| `UIPreviewCosmetics` | `StructProperty` | `ScriptStruct /Script/Pagoda.PagodaEquippedCosmeticStates` | `PagodaPlaythroughPlayerData` |
| `bWasLoaded` | `BoolProperty` | `true` | `PagodaPlaythroughPlayerData` |

### Class `PagodaProgressionSubsystem` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `ActiveScopes` | `MapProperty` | `unknown` | `PagodaProgressionSubsystem` |
| `AllScopes` | `MapProperty` | `unknown` | `PagodaProgressionSubsystem` |
| `OnAnyScopeIsActiveChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaProgressionSubsystem:OnAnyScopeIsActiveChanged` | `PagodaProgressionSubsystem` |
| `ValidTagsToVariableClass` | `MapProperty` | `unknown` | `PagodaProgressionSubsystem` |
| `VariableClasses` | `ArrayProperty` | `unknown` | `PagodaProgressionSubsystem` |
| `VariableDefinitions` | `MapProperty` | `unknown` | `PagodaProgressionSubsystem` |

### Class `PagodaSong` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `DebugRepeatIntervalPresets` | `ArrayProperty` | `unknown` | `PagodaSong` |
| `DebugUISortPriority` | `IntProperty` | `999` | `PagodaSong` |
| `FMODEvent` | `ObjectProperty` | `FMODEvent /Game/FMOD/Events/MX/MC/MX_MC_JustDance_124.MX_MC_JustDance_124` | `PagodaSong` |
| `GameplayParams` | `StructProperty` | `ScriptStruct /Script/Pagoda.PagodaSongGameplayParams` | `PagodaSong` |
| `ImportedSongUniqueId` | `UInt32Property` | `0` | `PagodaSong` |
| `InternalCategories` | `ArrayProperty` | `unknown` | `PagodaSong` |
| `Isrc` | `StrProperty` | `unknown` | `PagodaSong` |
| `JukeBoxUnlockTag` | `StructProperty` | `ScriptStruct /Script/GameplayTags.GameplayTag` | `PagodaSong` |
| `MovesetData` | `StructProperty` | `ScriptStruct /Script/Pagoda.PagodaMovesetSongData` | `PagodaSong` |
| `OriginalAudioFileHash` | `StrProperty` | `unknown` | `PagodaSong` |
| `OriginalAudioFilePath` | `StrProperty` | `unknown` | `PagodaSong` |
| `PerformedBy` | `ArrayProperty` | `unknown` | `PagodaSong` |
| `ProgressionTag` | `StructProperty` | `ScriptStruct /Script/GameplayTags.GameplayTag` | `PagodaSong` |
| `Seed` | `UInt32Property` | `0` | `PagodaSong` |
| `SharedTracks` | `ArrayProperty` | `unknown` | `PagodaSong` |
| `SongCrafterData` | `StructProperty` | `ScriptStruct /Script/Pagoda.SongCrafterData` | `PagodaSong` |
| `SongLength` | `StrProperty` | `unknown` | `PagodaSong` |
| `SongLengthSec` | `FloatProperty` | `0.0` | `PagodaSong` |
| `SongName` | `TextProperty` | `unknown` | `PagodaSong` |
| `SortedSectionStarts` | `ArrayProperty` | `unknown` | `PagodaSong` |
| `TestScenarioTimes` | `ArrayProperty` | `unknown` | `PagodaSong` |
| `UIVisibility` | `EnumProperty` | `1` | `PagodaSong` |
| `WrittenBy` | `ArrayProperty` | `unknown` | `PagodaSong` |
| `bFirePlaybackStartedEvent` | `BoolProperty` | `true` | `PagodaSong` |
| `bImportedSong` | `BoolProperty` | `false` | `PagodaSong` |
| `bIsAvailableInTowerMode` | `BoolProperty` | `true` | `PagodaSong` |
| `bIsStreamerSafe` | `BoolProperty` | `false` | `PagodaSong` |

### Class `PagodaSongCatalogSubsystem` Properties
| Property | Type | Example Value / Value Type | Defined In Class |
|---|---|---|---|
| `OnPlaylistCatalogChanged` | `MulticastInlineDelegateProperty` | `MulticastInlineDelegateProperty /Script/Pagoda.PagodaSongCatalogSubsystem:OnPlaylistCatalogChanged` | `PagodaSongCatalogSubsystem` |
| `Playlists` | `ArrayProperty` | `unknown` | `PagodaSongCatalogSubsystem` |
| `SongAssets` | `ArrayProperty` | `unknown` | `PagodaSongCatalogSubsystem` |

---

## 4. Loaded DataTables
Below are the primary DataTables loaded by the game engine during play:
- `CommonGenericInputActionDataTable`
- `DataTable`
- `MirrorDataTable`

---

## 5. Playthrough Save Progress Keys
Analysis of playthrough save data (`PagodaSaveData_PlayerPlaythrough` struct and `PagodaPT_M_0.sav`) reveals song progress stats are serialized using composite gameplay tag counters:
- **Song success count counter:** `Progression.Counter.Song.SuccessCount` (Integer value matching completion counts)
- **Song highest star rating counter:** `Progression.Counter.Song.HighestStarRating` (Integer 1-5 matching the highest achieved star rating)

---

## 6. Current Star Threshold Logic (Fallback)
Currently, `combat_stats.lua` falls back to these static threshold assumptions when song-specific thresholds cannot be resolved dynamically:
- **1 Star:** 40,000 score
- **2 Stars:** 80,000 score
- **3 Stars:** 120,000 score
- **4 Stars:** 240,000 score
- **5 Stars:** 480,000 score

We are actively staging the dynamic threshold resolution from `MusicParams` rows (layout: `MusicTableStructure`) and `IncursionProfiles` (`DT_IncursionProfiles_InfiniteDisco`) mapped on active challenges.