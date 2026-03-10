settings {
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "ffaSlots": 6,
        "spectatorSlots": 12
    },
    "gamemodes": {
        "ffa": {
            "enabledMaps": [
                "ecopointAntarctica"
            ],
            "enableSelfInitiatedRespawn": false
        },
        "elimination": {
            "enabled": false,
            "heroesAvailable": "mirroredRandom",
            "scoreToWin": 5
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "enableRandomHeroes": true,
            "spawnHealthPacks": "disabled"
        }
    },
    "heroes": {
        "allTeams": {
            "enabledHeroes": [
                "tracer"
            ]
        }
    }
}

#Global variables

globalvar SpawnPoints 0
globalvar IsDuelActive 1
globalvar HighestStreak 2
globalvar StreakPlayer 3
globalvar CurrentStreak 4
globalvar HighestStreakText 5
globalvar PlayerQueue 6
globalvar IsCountdown 7
globalvar CenterPos 8
globalvar RadiusLimit 9
globalvar CurrentStreakText 10
globalvar ShowIntro 11
globalvar Wall_N 13
globalvar Wall_O 14
globalvar Wall_Q 16
globalvar Wall_R 17
globalvar Wall_S 18
globalvar Wall_T 19
globalvar Wall_U 20
globalvar Wall_V 21
globalvar Wall_W 22
globalvar Wall_X 23
globalvar Wall_Y 24
globalvar Wall_Z 25


#Player variables

playervar HasInitialized 0
playervar Wins 1
playervar TotalMatches 2
playervar WinRate 3
playervar StatsString 4
playervar Losses 5


#Only remove the following directive if the gamemode does not use tricks such as A+0, A*0, "am" == "**", etc which would otherwise be optimized out.
#!optimizeStrict


rule "접속":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.HasInitialized == false

    eventPlayer.HasInitialized = true
    eventPlayer.enableDeathSpectateTargetHud()
    eventPlayer.enableDeathSpectateAllPlayers()
    PlayerQueue.append(eventPlayer)
    eventPlayer.setRespawnTime(9999)
    eventPlayer.disableRespawn()
    hudHeader([player for player in getAllPlayers() if PlayerQueue.index(eventPlayer) > 1], "{0}{1}".format(heroIcon(eventPlayer.getHero()), eventPlayer), HudPosition.RIGHT, PlayerQueue.index(eventPlayer), Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING)
    eventPlayer.StatsString = "{0}{1}".format(heroIcon(eventPlayer.getHero()), eventPlayer)


rule "리스폰":
    if getCurrentMap() == Map.ECOPOINT_ANTARCTICA:
        SpawnPoints = vect(3, 6.5, -18)
        SpawnPoints.append(vect(3, 6, 18))


rule "시작":
    @Event eachPlayer
    @Condition eventPlayer == PlayerQueue[1]
    @Condition IsDuelActive == false
    @Condition SpawnPoints == true

    wait(1, Wait.ABORT_WHEN_FALSE)
    PlayerQueue.slice(0, 2).respawn()
    IsCountdown = true
    PlayerQueue.slice(0, 2).setStatusEffect(null, Status.PHASED_OUT, 3)
    PlayerQueue.slice(0, 2).setStatusEffect(null, Status.ROOTED, 3)
    smallMessage(getAllPlayers(), 3)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, CenterPos, 200)
    wait(1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.StatsString = "{0}{1} {2}".format(heroIcon(eventPlayer.getHero()), eventPlayer, "{0}승 {1}패({2}%)".format(eventPlayer.Wins, eventPlayer.Losses, eventPlayer.WinRate))
    smallMessage(getAllPlayers(), 2)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, (SpawnPoints[0] + SpawnPoints.last()) / 2, 200)
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(getAllPlayers(), 1)
    playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, CenterPos, 200)
    wait(1, Wait.ABORT_WHEN_FALSE)
    smallMessage(getAllPlayers(), "시작")
    playEffect(getAllPlayers(), DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, CenterPos, 200)
    IsDuelActive = true
    IsCountdown = false


rule "자리고정":
    @Event eachPlayer
    @Condition eventPlayer in PlayerQueue.slice(0, 2) == true
    @Condition IsCountdown == true
    @Condition distance(SpawnPoints[PlayerQueue.index(eventPlayer)], eventPlayer) > 1.5
    @Condition SpawnPoints == true
    @Condition eventPlayer.isAlive() == true

    while distance(SpawnPoints[PlayerQueue.index(eventPlayer)], eventPlayer) > 1.5:
        eventPlayer.teleport(SpawnPoints[PlayerQueue.index(eventPlayer)])
        wait(0.05)
    eventPlayer.setFacing(directionTowards(SpawnPoints[PlayerQueue.index(eventPlayer)], SpawnPoints[not PlayerQueue.index(eventPlayer)]), Relativity.TO_WORLD)


rule "쿨타임초기화":
    @Event eachPlayer
    @Condition eventPlayer in PlayerQueue.slice(0, 2) == true
    @Condition IsDuelActive == false

    eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
    eventPlayer.setAbilityCooldown(Button.CROUCH, 0)


rule "나갔을 때":
    @Event playerLeft

    if not eventPlayer in PlayerQueue.slice(0, 2):
        goto lbl_0
    IsDuelActive = false
    lbl_0:
    PlayerQueue.remove(eventPlayer)


rule "관전자":
    @Event eachPlayer
    @Condition PlayerQueue.index(eventPlayer) > 1
    @Condition eventPlayer.isAlive() == true

    kill(eventPlayer)


rule "텍스트":
    @Event playerDied
    @Condition eventPlayer in PlayerQueue.slice(0, 2) == true
    @Condition IsDuelActive == true

    IsDuelActive = false
    PlayerQueue.remove(eventPlayer)
    PlayerQueue.append(eventPlayer)
    PlayerQueue[0].Wins++
    eventPlayer.Losses++
    [PlayerQueue[0], eventPlayer].TotalMatches++
    eventPlayer.WinRate = round(100 * (eventPlayer.Wins / eventPlayer.TotalMatches))
    PlayerQueue[0].WinRate = round(100 * (PlayerQueue[0].Wins / PlayerQueue[0].TotalMatches))
    eventPlayer.StatsString = "{0}{1} {2}".format(heroIcon(eventPlayer.getHero()), eventPlayer, "{0}승 {1}패({2}%)".format(eventPlayer.Wins, eventPlayer.Losses, eventPlayer.WinRate))
    PlayerQueue[0].StatsString = "{0}{1} {2}".format(heroIcon(PlayerQueue[0].getHero()), PlayerQueue[0], "{0}승 {1}패({2}%)".format(PlayerQueue[0].Wins, PlayerQueue[0].Losses, PlayerQueue[0].WinRate))
    PlayerQueue[0].cancelPrimaryAction()
    if StreakPlayer != PlayerQueue[0]:
        goto lbl_0
    CurrentStreak++
    goto lbl_1
    lbl_0:
    StreakPlayer = PlayerQueue[0]
    CurrentStreak = 1
    lbl_1:
    CurrentStreakText = "{2}\"{0}\" {1}".format("{1}{0}".format(StreakPlayer, heroIcon(StreakPlayer.getHero())), "{0}연승".format(CurrentStreak), "" if CurrentStreak < 5 else "" if CurrentStreak < 10 else "" if CurrentStreak < 15 else "" if CurrentStreak < 20 else "")
    if CurrentStreak > HighestStreak:
        HighestStreak = CurrentStreak
        HighestStreakText = CurrentStreakText
    PlayerQueue[0].addToScore(1)
    wait(0.1)
    bigMessage(getAllPlayers(), "{0} 승리".format(PlayerQueue[0]))
    wait(2)
    eventPlayer.disableRespawn()


rule "텍스트 색":
    #범위반경
    RadiusLimit = 30
    disableInspector()
    PlayerQueue = []
    disableScoring()
    ShowIntro = true

    hudHeader([player for player in getAllPlayers() if ShowIntro == true], "Code: 4MNDC github.com/junah201/tracer_1v1_arena", HudPosition.TOP, -3, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING)
    hudHeader([player for player in getAllPlayers() if HighestStreak > 1 and HighestStreak > CurrentStreak and ShowIntro != true], "최고기록 : {0} 달성".format(HighestStreakText), HudPosition.LEFT, -6, Color.RED, HudReeval.VISIBILITY_AND_STRING)
    hudHeader([player for player in getAllPlayers() if CurrentStreak > 0 and ShowIntro != true], "현재기록 : {0} 중".format(CurrentStreakText), HudPosition.LEFT, -5, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader([player for player in getAllPlayers() if getNumberOfPlayers(Team.ALL) > 2 and ShowIntro != true], "대기목록", HudPosition.RIGHT, 0, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_STRING)
    hudHeader([player for player in getAllPlayers() if ShowIntro != true], "{0}    vs    {1}".format(PlayerQueue[0].StatsString, PlayerQueue[1].StatsString), HudPosition.TOP, -2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    setMatchTime(0)
    disableAnnouncer()
    disableGamemodeCompletion()
    disableMusic()
    hudText(getAllPlayers(), null, "\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n", "\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n", HudPosition.TOP, -1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
    hudSubtext(getAllPlayers(), "♥♥♥ ~(>_<`๑)♥", HudPosition.RIGHT, -10, Color.ROSE, HudReeval.VISIBILITY_AND_STRING)
    wait(4)
    ShowIntro = false

rule "좌표":
    Wall_N = vect(14.959, 8.869, 33.049)
    Wall_O = vect(15.604, 8.939, -33.406)
    Wall_Q = vect(15.949, 7.26, 17.593)
    Wall_R = vect(15.754, 7.264, -17.227)
    Wall_S = vect(18.149, 6.405, 10.027)
    Wall_T = vect(17.972, 6.329, -9.877)
    Wall_U = vect(-13.396, 11.145, 19.813)
    Wall_V = vect(-12.26, 10.859, -19.483)
    Wall_W = vect(-14.913, 8.279, -9.923)
    Wall_X = vect(-15.105, 8.249, 10.089)
    Wall_Y = vect(-10.456, 9.773, -0.24)
    Wall_Z = vect(28.002, 4.248, 0.006)


rule "이펙트":
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_N, 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_O, 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_Q, 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_R, 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_S, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_T, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_U, 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_V, 3, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_W, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_X, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_Y, 1.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createEffect(getAllPlayers(), Effect.SPHERE, Color.RED, Wall_Z, 8, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)


rule "A":
    @Event eachPlayer
    @Condition distance(Wall_N, eventPlayer) <= 3

    damage(eventPlayer, null, 100000)


rule "B":
    @Event eachPlayer
    @Condition distance(Wall_O, eventPlayer) <= 3

    damage(eventPlayer, null, 100000)


rule "C":
    @Event eachPlayer
    @Condition distance(Wall_Q, eventPlayer) <= 3

    damage(eventPlayer, null, 100000)


rule "D":
    @Event eachPlayer
    @Condition distance(Wall_R, eventPlayer) <= 3

    damage(eventPlayer, null, 100000)


rule "E":
    @Event eachPlayer
    @Condition distance(Wall_S, eventPlayer) <= 2

    damage(eventPlayer, null, 100000)


rule "F":
    @Event eachPlayer
    @Condition distance(Wall_T, eventPlayer) <= 2

    damage(eventPlayer, null, 100000)


rule "G":
    @Event eachPlayer
    @Condition distance(Wall_U, eventPlayer) <= 3

    damage(eventPlayer, null, 100000)


rule "H":
    @Event eachPlayer
    @Condition distance(Wall_V, eventPlayer) <= 3

    damage(eventPlayer, null, 100000)


rule "I":
    @Event eachPlayer
    @Condition distance(Wall_W, eventPlayer) <= 2

    damage(eventPlayer, null, 100000)


rule "J":
    @Event eachPlayer
    @Condition distance(Wall_X, eventPlayer) <= 2

    damage(eventPlayer, null, 100000)


rule "K":
    @Event eachPlayer
    @Condition distance(Wall_Y, eventPlayer) <= 1.5

    damage(eventPlayer, null, 100000)


rule "L":
    @Event eachPlayer
    @Condition distance(Wall_Z, eventPlayer) <= 7

    damage(eventPlayer, null, 100000)


rule "DCIS A":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 4.9 for player in Wall_N]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(-10, 10, 50)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS B":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 4.9 for player in Wall_O]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(10, 10, -50)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS C":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 4.5 for player in Wall_Q]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(-10, 10, 50)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS D":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 4.5 for player in Wall_R]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(0, 10, -30)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS E":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 3 for player in Wall_S]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(0, 10, -30)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS F":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 3 for player in Wall_T]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(0, 10, 30)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS G":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 5.5 for player in Wall_U]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(0, 10, 30)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS H":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 5.5 for player in Wall_V]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(0, 10, -30)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS I":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 4 for player in Wall_W]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(0, 10, -30)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS J":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 4 for player in Wall_X]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(0, 10, 30)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS K":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 3 for player in Wall_Y]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(-15, 5, 0)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "DCIS L":
    @Event eachPlayer
    @Condition any([distance(player, eventPlayer) < 8.25 for player in Wall_Z]) == true

    wait(0)
    if not ruleCondition:
        return
    eventPlayer.applyImpulse(directionTowards(eventPlayer.getPosition(), Vector.BACKWARD[0] + vect(-15, 10, 0)), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    playEffect(getAllPlayers(), DynamicEffect.DEBUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 100)


rule "게임종료":
    @Event eachPlayer
    @Condition eventPlayer.getNumberOfElims() == 1000

    declarePlayerVictory(eventPlayer)


