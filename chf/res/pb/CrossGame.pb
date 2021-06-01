
Ÿå
CrossGame.proto
Base.protoCommon.proto"b
CCGameServerRegRq
serverId (

serverName (	2'
ext.Base— (2.CCGameServerRegRq"<
CCGameServerRegRs2'
ext.Base“ (2.CCGameServerRegRs"d
CCGetCrossServerListRq
roleId (
nick (	2,
ext.Base” (2.CCGetCrossServerListRq"
CCGetCrossServerListRs
roleId ('
gameServerInfo (2.GameServerInfo2,
ext.Base‘ (2.CCGetCrossServerListRs"V
CCGetCrossFightStateRq
roleId (2,
ext.Base’ (2.CCGetCrossFightStateRq"x
CCGetCrossFightStateRs
roleId (
	beginTime (	
state (2,
ext.Base÷ (2.CCGetCrossFightStateRs"E
CCSynChatRq
chat (2.Chat2!
ext.Base◊ (2.CCSynChatRq"æ
CCCrossFightRegRq
roleId (
groupId (
rankId (
fight (
nick (	
portrait (
	partyName (	
level (2'
ext.BaseŸ (2.CCCrossFightRegRq"L
CCCrossFightRegRs
roleId (2'
ext.Base⁄ (2.CCCrossFightRegRs"P
CCGetCrossRegInfoRq
roleId (2)
ext.Base€ (2.CCGetCrossRegInfoRq"ï
CCGetCrossRegInfoRs
roleId (
jyGroupPlayerNum (
dfGroupPlayerNum (
myGroup (2)
ext.Base‹ (2.CCGetCrossRegInfoRs"N
CCCancelCrossRegRq
roleId (2(
ext.Base› (2.CCCancelCrossRegRq"N
CCCancelCrossRegRs
roleId (2(
ext.Baseﬁ (2.CCCancelCrossRegRs"J
CCGetCrossFormRq
roleId (2&
ext.Baseﬂ (2.CCGetCrossFormRq"_
CCGetCrossFormRs
roleId (
form (2.Form2&
ext.Base‡ (2.CCGetCrossFormRs"¨
CCSetCrossFormRq
roleId (
form (2.Form
fight (
tank (2.Tank
hero (2.Hero

maxTankNum (
equip (2.Equip
part (2.Part
science	 (2.Science
skill
 (2.Skill
effect (2.Effect

staffingId ( 
inlay (2.EnergyStoneInlay1
militaryScienceGrid (2.MilitaryScienceGrid)
militaryScience (2.MilitaryScience
medal (2.Medal

medalBouns (2.MedalBouns

awakenHero (2.AwakenHero
leq (2
.LordEquip
militaryRank (#
secretWeapon (2.SecretWeapon
atkEft (2.AttackEffectPb%
graduateInfo (2.GraduateInfoPb2&
ext.Base· (2.CCSetCrossFormRq"n
CCSetCrossFormRs
roleId (
form (2.Form
fight (2&
ext.Base‚ (2.CCSetCrossFormRs"n
CCGetCrossPersonSituationRq
roleId (
page (21
ext.Base„ (2.CCGetCrossPersonSituationRq"É
CCGetCrossPersonSituationRs
roleId (!
crossRecord (2.CrossRecord21
ext.Base‰ (2.CCGetCrossPersonSituationRs"b
CCGetCrossJiFenRankRq
roleId (
page (2+
ext.BaseÂ (2.CCGetCrossJiFenRankRq"ú
CCGetCrossJiFenRankRs
roleId ('
crossJiFenRank (2.CrossJiFenRank
jifen (
myRank (2+
ext.BaseÊ (2.CCGetCrossJiFenRankRs"a
CCGetCrossReportRq
roleId (
	reportKey (2(
ext.BaseÁ (2.CCGetCrossReportRq"q
CCGetCrossReportRs
roleId (!
crossRptAtk (2.CrossRptAtk2(
ext.BaseË (2.CCGetCrossReportRs"Ñ
CCGetCrossKnockCompetInfoRq
roleId (
groupId (
	groupType (21
ext.BaseÈ (2.CCGetCrossKnockCompetInfoRq"∑
CCGetCrossKnockCompetInfoRs
roleId (
groupId (
	groupType (1
knockoutCompetGroup (2.KnockoutCompetGroup21
ext.BaseÍ (2.CCGetCrossKnockCompetInfoRs"q
CCGetCrossFinalCompetInfoRq
roleId (
groupId (21
ext.BaseÎ (2.CCGetCrossFinalCompetInfoRq"û
CCGetCrossFinalCompetInfoRs
roleId (
groupId (+
finalCompetGroup (2.FinalCompetGroup21
ext.BaseÏ (2.CCGetCrossFinalCompetInfoRs"õ
CCBetBattleRq
roleId (
myGroup (
stage (
	groupType (
competGroupId (
pos (2#
ext.BaseÌ (2.CCBetBattleRq"h
CCBetBattleRs
roleId (
myBet (2.MyBet
pos (2#
ext.BaseÓ (2.CCBetBattleRs"B
CCGetMyBetRq
roleId (2"
ext.BaseÔ (2.CCGetMyBetRq"Z
CCGetMyBetRs
roleId (
myBets (2.MyBet2"
ext.Base (2.CCGetMyBetRs"ê
CCReceiveBetRq
roleId (
myGroup (
stage (
	groupType (
competGroupId (2$
ext.BaseÒ (2.CCReceiveBetRq"l
CCReceiveBetRs
roleId (
myBet (2.MyBet
jifen (2$
ext.BaseÚ (2.CCReceiveBetRs"J
CCGetCrossShopRq
roleId (2&
ext.BaseÛ (2.CCGetCrossShopRq"z
CCGetCrossShopRs
roleId (

crossJifen (
buy (2.CrossShopBuy2&
ext.BaseÙ (2.CCGetCrossShopRs"s
CCExchangeCrossShopRq
roleId (
shopId (
count (2+
ext.Baseı (2.CCExchangeCrossShopRq"ò
CCExchangeCrossShopRs
roleId (

crossJifen (
shopId (
count (
restNum (2+
ext.Baseˆ (2.CCExchangeCrossShopRs"L
CCGetCrossTrendRq
roleId (2'
ext.Base˜ (2.CCGetCrossTrendRq"Å
CCGetCrossTrendRs
roleId (

crossJifen (

crossTrend (2.CrossTrend2'
ext.Base¯ (2.CCGetCrossTrendRs"ü
CCBetRollBackRq
roleId (
myGroup (
stage (
	groupType (
competGroupId (
pos (2%
ext.Base˘ (2.CCBetRollBackRq"c
CCGetCrossFinalRankRq
roleId (
group (2+
ext.Base˚ (2.CCGetCrossFinalRankRq"∏
CCGetCrossFinalRankRs
roleId (
group (#
crossTopRank (2.CrossTopRank
myRank (
state (
myJiFen (2+
ext.Base¸ (2.CCGetCrossFinalRankRs"a
CCReceiveRankRwardRq
roleId (
group (2*
ext.Base˝ (2.CCReceiveRankRwardRq"o
CCReceiveRankRwardRs
roleId (
group (
rank (2*
ext.Base˛ (2.CCReceiveRankRwardRs"m
CCSynMailRq
moldId (
type (
roleId (
param (	2!
ext.Baseˇ (2.CCSynMailRq"K
CCSynCrossStateRq
state (2'
ext.BaseÅ (2.CCSynCrossStateRq">
	CCHeartRq
serverId (2
ext.BaseÉ (2
.CCHeartRq",
	CCHeartRs2
ext.BaseÑ (2
.CCHeartRs"O
CCGMSetCrossFormRq
formNum (2(
ext.BaseÖ (2.CCGMSetCrossFormRq"Ω
CCSynCrossFameRq
	beginTime (	
endTime (	
	crossFame (2
.CrossFame
cpFame (2.CPFame
cdFame (2.CDFame
type (2&
ext.Baseá (2.CCSynCrossFameRq"T
CCGmSynCrossLashRankRq
type (2,
ext.Baseâ (2.CCGmSynCrossLashRankRq"V
CCGetCrossPartyStateRq
roleId (2,
ext.Baseã (2.CCGetCrossPartyStateRq"x
CCGetCrossPartyStateRs
roleId (
	beginTime (	
state (2,
ext.Baseå (2.CCGetCrossPartyStateRs"U
CCSynCrossPartyStateRq
state (2,
ext.Baseç (2.CCSynCrossPartyStateRq"`
CCGetCrossPartyServerListRq
roleId (21
ext.Baseè (2.CCGetCrossPartyServerListRq"â
CCGetCrossPartyServerListRs
roleId ('
gameServerInfo (2.GameServerInfo21
ext.Baseê (2.CCGetCrossPartyServerListRs"Ó
CCCrossPartyRegRq
roleId (
nick (	
level (
warRank (
partyId (
	partyName (	
partyLv (
portrait (
myPartySirPortrait	 (
gmState
 (2'
ext.Baseë (2.CCCrossPartyRegRq"L
CCCrossPartyRegRs
roleId (2'
ext.Baseí (2.CCCrossPartyRegRs"_
CCGetCPMyRegInfoRq
roleId (
partyId (2(
ext.Baseì (2.CCGetCPMyRegInfoRq"]
CCGetCPMyRegInfoRs
roleId (
isReg (2(
ext.Baseî (2.CCGetCPMyRegInfoRs"z
CCGetCrossPartyMemberRq
roleId (
warRank (
partyId (2-
ext.Baseï (2.CCGetCrossPartyMemberRq"∑
CCGetCrossPartyMemberRs
roleId (
	partyNums (
myPartyMemberNum (!
cpMemberReg (2.CPMemberReg
group (2-
ext.Baseñ (2.CCGetCrossPartyMemberRs"[
CCGetCrossPartyRq
roleId (
group (2'
ext.Baseó (2.CCGetCrossPartyRq"≤
CCGetCrossPartyRs
roleId (
group (!
cpPartyInfo (2.CPPartyInfo
totalRegPartyNum (
groupRegPartyNum (2'
ext.Baseò (2.CCGetCrossPartyRs"k
CCGetCPSituationRq
roleId (
group (
page (2(
ext.Baseô (2.CCGetCPSituationRq"à
CCGetCPSituationRs
roleId (
group (
page (
cpRecord (2	.CPRecord2(
ext.Baseö (2.CCGetCPSituationRs"ç
CCGetCPOurServerSituationRq
roleId (
type (
page (
partyId (21
ext.Baseõ (2.CCGetCPOurServerSituationRq"ô
CCGetCPOurServerSituationRs
roleId (
type (
page (
cpRecord (2	.CPRecord21
ext.Baseú (2.CCGetCPOurServerSituationRs"[
CCGetCPReportRq
roleId (
	reportKey (2%
ext.Baseü (2.CCGetCPReportRq"e
CCGetCPReportRs
roleId (
cpRptAtk (2	.CPRptAtk2%
ext.Base† (2.CCGetCPReportRs"`
CCGetCPRankRq
roleId (
type (
page (2#
ext.Base° (2.CCGetCPRankRq"£
CCGetCPRankRs
roleId (
type (
page (
cpRank (2.CPRank
mySelf (2.CPRank
myJiFen (2#
ext.Base¢ (2.CCGetCPRankRs"^
CCReceiveCPRewardRq
roleId (
type (2)
ext.Base£ (2.CCReceiveCPRewardRq"l
CCReceiveCPRewardRs
roleId (
type (
rank (2)
ext.Base§ (2.CCReceiveCPRewardRs"D
CCGetCPShopRq
roleId (2#
ext.Base• (2.CCGetCPShopRq"o
CCGetCPShopRs
roleId (
jifen (
buy (2.CrossShopBuy2#
ext.Base¶ (2.CCGetCPShopRs"m
CCExchangeCPShopRq
roleId (
shopId (
count (2(
ext.Baseß (2.CCExchangeCPShopRq"ç
CCExchangeCPShopRs
roleId (
jifen (
shopId (
count (
restNum (2(
ext.Base® (2.CCExchangeCPShopRs"j
CCSynCPSituationRq
gruop (
cpRecord (2	.CPRecord2(
ext.Base´ (2.CCSynCPSituationRq"D
CCGetCPFormRq
roleId (2#
ext.BaseØ (2.CCGetCPFormRq"h
CCGetCPFormRs
roleId (
form (2.Form
fight (2#
ext.Base∞ (2.CCGetCPFormRs"¶
CCSetCPFormRq
roleId (
form (2.Form
fight (
tank (2.Tank
hero (2.Hero

maxTankNum (
equip (2.Equip
part (2.Part
science	 (2.Science
skill
 (2.Skill
effect (2.Effect

staffingId ( 
inlay (2.EnergyStoneInlay1
militaryScienceGrid (2.MilitaryScienceGrid)
militaryScience (2.MilitaryScience
medal (2.Medal

medalBouns (2.MedalBouns

awakenHero (2.AwakenHero
leq (2
.LordEquip
militaryRank (#
secretWeapon (2.SecretWeapon
atkEft (2.AttackEffectPb%
graduateInfo (2.GraduateInfoPb2#
ext.Base± (2.CCSetCPFormRq"h
CCSetCPFormRs
roleId (
form (2.Form
fight (2#
ext.Base≤ (2.CCSetCPFormRs"F
CCGMSetCPFormRq
type (2%
ext.Base≥ (2.CCGMSetCPFormRq"F
CCGetCPTrendRq
roleId (2$
ext.Baseµ (2.CCGetCPTrendRq"v
CCGetCPTrendRs
roleId (
jifen (

crossTrend (2.CrossTrend2$
ext.Base∂ (2.CCGetCPTrendRs"m
CCCanQuitPartyRq
roleId (
type (
cleanRoleId (2&
ext.Base∑ (2.CCCanQuitPartyRq"|
CCCanQuitPartyRs
roleId (
isReg (
type (
cleanRoleId (2&
ext.Base∏ (2.CCCanQuitPartyRs"h
CCGMAddJiFenRq
roleId (
addJifen (
ccType (2$
ext.Baseπ (2.CCGMAddJiFenRq"F
CCGetCDStateRq
roleId (2$
ext.Base… (2.CCGetCDStateRq"ô
CCGetCDStateRs
roleId (
durationTime (	
state (
reg (
teamData (2.CDMyTeamData2$
ext.Base  (2.CCGetCDStateRs"E
CCSynCDStateRq
state (2$
ext.BaseÀ (2.CCSynCDStateRq"P
CCGetCDServerListRq
roleId (2)
ext.BaseÕ (2.CCGetCDServerListRq"y
CCGetCDServerListRs
roleId ('
gameServerInfo (2.GameServerInfo2)
ext.BaseŒ (2.CCGetCDServerListRs"†
CCCrossDrillRegRq
roleId (
nick (	
level (
fight (

staffingId (

staffingLv (2'
ext.Baseœ (2.CCCrossDrillRegRq"L
CCCrossDrillRegRs
roleId (2'
ext.Base– (2.CCCrossDrillRegRs"B
CCGetCDBetRq
roleId (2"
ext.Base— (2.CCGetCDBetRq"]
CCGetCDBetRs
roleId (
bet (2.CDBattleBet2"
ext.Base“ (2.CCGetCDBetRs"H
CCGetCDMoraleRq
roleId (2%
ext.Base” (2.CCGetCDMoraleRq"c
CCGetCDMoraleRs
roleId (
morale (2	.CDMorale2%
ext.Base‘ (2.CCGetCDMoraleRs"Ä
CCImproveCDMoraleRq
roleId (
buffId (
gold (
resource (2)
ext.Base’ (2.CCImproveCDMoraleRq"ã
CCImproveCDMoraleRs
roleId (
morale (2	.CDMorale
gold (
resource (2)
ext.Base÷ (2.CCImproveCDMoraleRs"N
CCGetCDFinalRankRq
roleId (2(
ext.Base◊ (2.CCGetCDFinalRankRq"y
CCGetCDFinalRankRs
roleId (
state (
rank (2.CDFinalRank2(
ext.Baseÿ (2.CCGetCDFinalRankRs"V
CCReceiveCDFinalRankRq
roleId (2,
ext.BaseŸ (2.CCReceiveCDFinalRankRq"d
CCReceiveCDFinalRankRs
roleId (
rank (2,
ext.Base⁄ (2.CCReceiveCDFinalRankRs"T
CCGetCDDistributionRq
roleId (2+
ext.Base€ (2.CCGetCDDistributionRq"É
CCGetCDDistributionRs
roleId (-

distribute (2.CDTeamServerDistribution2+
ext.Base‹ (2.CCGetCDDistributionRs"N
CCGetCDTeamScoreRq
roleId (2(
ext.Base› (2.CCGetCDTeamScoreRq"o
CCGetCDTeamScoreRs
roleId (
	teamScore (2.CDTeamScore2(
ext.Baseﬁ (2.CCGetCDTeamScoreRs"L
CCGetCDHeroRankRq
roleId (2'
ext.Baseﬂ (2.CCGetCDHeroRankRq"à
CCGetCDHeroRankRs
roleId (
rank (
state (
heroRank (2.CDHeroRank2'
ext.Base‡ (2.CCGetCDHeroRankRs"T
CCReceiveCDHeroRankRq
roleId (2+
ext.Base· (2.CCReceiveCDHeroRankRq"b
CCReceiveCDHeroRankRs
roleId (
rank (2+
ext.Base‚ (2.CCReceiveCDHeroRankRs"\
CCGetCDTeamDataRq
roleId (
teamId (2'
ext.Base„ (2.CCGetCDTeamDataRq"s
CCGetCDTeamDataRs
roleId (%

battleData (2.CDTeamBattleData2'
ext.Base‰ (2.CCGetCDTeamDataRs"c
CCGetCDBattlefieldRq
roleId (
fieldId (2*
ext.BaseÂ (2.CCGetCDBattlefieldRq"ﬂ
CCGetCDBattlefieldRs
roleId (
fieldId (
fieldStatus (
redServerName (	
blueServerName (	
ratio ('

stronghold (2.CDBattleStronghold2*
ext.BaseÊ (2.CCGetCDBattlefieldRs"z
CCGetCDRecordRq
roleId (
strongholdId (
type (
page (2%
ext.BaseÁ (2.CCGetCDRecordRq"ï
CCGetCDRecordRs
roleId (
strongholdId (
type (
page (
record (2	.CDRecord2%
ext.BaseË (2.CCGetCDRecordRs"[
CCGetCDReportRq
roleId (
	reportKey (2%
ext.BaseÈ (2.CCGetCDReportRq"q
CCGetCDReportRs
roleId ('
rptAtkFortress (2.RptAtkFortress2%
ext.BaseÍ (2.CCGetCDReportRs"n
CCGetCDStrongholdRankRq
roleId (
strongholdId (2-
ext.BaseÎ (2.CCGetCDStrongholdRankRq"¿
CCGetCDStrongholdRankRs
roleId (
strongholdId (
myRank (
winNum (
lostNum (
rank (2.CDStrongholdRank2-
ext.BaseÏ (2.CCGetCDStrongholdRankRs"D
CCGetCDTankRq
roleId (2#
ext.BaseÌ (2.CCGetCDTankRq"Y
CCGetCDTankRs
roleId (
tank (2.Tank2#
ext.BaseÓ (2.CCGetCDTankRs"m
CCExchangeCDTankRq
roleId (
tankId (
count (2(
ext.BaseÔ (2.CCExchangeCDTankRq"{
CCExchangeCDTankRs
roleId (
tankId (
cost (
count (2(
ext.Base (2.CCExchangeCDTankRs"U
CCGetCDFormRq
roleId (
fieldId (2#
ext.BaseÒ (2.CCGetCDFormRq"i
CCGetCDFormRs
roleId (#
form (2.CDStrongholdFormData2#
ext.BaseÚ (2.CCGetCDFormRs"˛
CCSetCDFormRq
roleId (
strongholdId (
form (2.Form
clean (
fight (

staffingLv (

maxTankNum (
hero (2.Hero
part	 (2.Part
equip
 (2.Equip
skill (2.Skill
effect (2.Effect
science (2.Science 
inlay (2.EnergyStoneInlay)
militaryScience (2.MilitaryScience1
militaryScienceGrid (2.MilitaryScienceGrid
partyScience (2.Science

staffingId (
medal (2.Medal

medalBouns (2.MedalBouns 
awakenHeros (2.AwakenHero
leq (2
.LordEquip
militaryRank (2#
ext.BaseÛ (2.CCSetCDFormRq"~
CCSetCDFormRs
roleId (
strongholdId (
form (2.Form
fight (2#
ext.BaseÙ (2.CCSetCDFormRs"L
CCGetCDKnockoutRq
roleId (2'
ext.Baseı (2.CCGetCDKnockoutRq"~
CCGetCDKnockoutRs
roleId (
stage (!
battle (2.CDKnockoutBattle2'
ext.Baseˆ (2.CCGetCDKnockoutRs"É
CCCrossDrillBetRq
roleId (
battleGroupId (
target (
betNum (2'
ext.Base˜ (2.CCCrossDrillBetRq"£
CCCrossDrillBetRs
roleId (
battleGroupId (
target (
betNum (
betCount (
cost (2'
ext.Base¯ (2.CCCrossDrillBetRs"a
CCReceiveCDBetRq
roleId (
battleGroupId (2&
ext.Base˘ (2.CCReceiveCDBetRq"p
CCReceiveCDBetRs
roleId (
battleGroupId (
jifen (2&
ext.Base˙ (2.CCReceiveCDBetRs"D
CCGetCDShopRq
roleId (2#
ext.Base˚ (2.CCGetCDShopRq"á
CCGetCDShopRs
roleId (
jifen (
buy (2.CrossShopBuy
canBuyTreasure (2#
ext.Base¸ (2.CCGetCDShopRs"m
CCExchangeCDShopRq
roleId (
shopId (
count (2(
ext.Base˝ (2.CCExchangeCDShopRq"ç
CCExchangeCDShopRs
roleId (
jifen (
shopId (
count (
restNum (2(
ext.Base˛ (2.CCExchangeCDShopRs"l
CCGetCDTeamBattleResultRq
roleId (
teamId (2/
ext.Baseˇ (2.CCGetCDTeamBattleResultRq"y
CCGetCDTeamBattleResultRs
roleId (

battleData (2.TwoInt2/
ext.BaseÄ (2.CCGetCDTeamBattleResultRsB
com.game.pbBCrossGamePb