
Îó
Common.proto" 
Kv
key (
value ("$
KvLong
key (
value ("&
KvString
key (
value (	" 
TwoInt

v1 (

v2 ("!
TwoLong

v1 (

v2 (".
ThreeInt

v1 (

v2 (

v3 ("3
Tank
tankId (
count (
rest ("f
Grab
stone (
iron (
silicon (
copper (
oil (
honourScore ("4
Collect
load (
speed (
over ("à
Form
	commander (
p1 (2.TwoInt
p2 (2.TwoInt
p3 (2.TwoInt
p4 (2.TwoInt
p5 (2.TwoInt
p6 (2.TwoInt
type (

awakenHero	 (2.AwakenHero
formName
 (	
tacticsKeyId (
tactics (2.TwoInt"(
FormExt
weaponId (
eid ("∑
Army
keyId (
target (
state (
period (
endTime (
form (2.Form
grab (2.Grab
collect (2.Collect
staffingTime	 (
senior
 (
occupy (
isRuins (
tar_qua (
type (
lordId (
fight (
freeWarTime (
startFreeWarTime (
honourScore (

honourGold (
collectBeginTime (
newHeroAddGold (
caiJiStartTime (
caiJiEndTime (
newHeroSubGold (
staffingExp (
isZhuJun (
	crossMine (
load ("(
FailNum
operType (
num ("π
BuildQue
keyId (

buildingId (
pos (
period (
endTime (
siliconCost (
ironCost (
oilCost (
goldCost	 (

copperCost
 ("g
TankQue
keyId (
tankId (
count (
state (
period (
endTime ("y
RefitQue
keyId (
tankId (
refitId (
count (
state (
period (
endTime ("%
Prop
propId (
count ("g
PropQue
keyId (
propId (
count (
state (
period (
endTime ("]
Equip
keyId (
equipId (

lv (
exp (
pos (
starLv ("∑
Part
keyId (
partId (
upLv (
refitLv (
pos (
locked (
smeltLv (
smeltExp (
attr	 (2.PartSmeltAttr
saved
 (:true"%
Chip
chipId (
count ("º

ScienceQue
keyId (
	scienceId (
period (
state (
endTime (
	stoneCost (
ironCost (
oilCost (

silionCost	 (

copperCost
 ("A
Science
	scienceId (
	scienceLv (
schedule ("(
Combat
combatId (
star ("ó
Action
target (
hurt (
crit (
impale (
dodge (
count (
frighten (

forceCount (
force	 ("M
PassiveSkillEffect
round (
key (

id (
enemyId ("-
Round
key (
action (2.Action"ù
Record
keyId (

hp (
round (2.Round
first (
formA (2.Form
formB (2.Form
reborn (2.Reborn$
addSkillEffect (2.SkillEffect
formExtA	 (2.FormExt
formExtB
 (2.FormExt/
passiveSkillEffect (2.PassiveSkillEffect"N
Award
type (

id (
count (
keyId (
param ("Q
Hero
keyId (
heroId (
count (
endTime (

cd ("„
Man
lordId (
icon (
sex (
nick (	
level (
fight (
ranks (
exp (
pos	 (
vip
 (
honour (
pros (
prosMax (
	partyName (	
jobId ("c
Mine
mineId (
mineLv (
pos (
qua (
quaExp (
	scoutTime ("<
Bless
man (2.Man
state (
	blessTime (";
DbBless
lordId (
state (
	blessTime ("u
Friend
man (2.Man
bless (
	blessTime (
state (
friendliness (
	giveCount ("R
DbFriend
lordId (
bless (
	blessTime (
friendliness ("á
Store
pos (
enemy (
friend (
isMine (
man (2.Man
mine (2.Mine
mark (	
type ("_
Weal
stone (
iron (
silicon (
copper (
oil (
gold ("…
RptScoutMine
pos (

lv (
mine (
product (
form (2.Form
harvest (
party (	
friend (	

honourGold	 (
honourScore
 (
newHeroGold ("ù
RptScoutHome
pos (

lv (
name (	
pros (
prosMax (
grab (2.Grab
form (2.Form
party (	
friend	 (	"`
RptScoutRebel
pos (

lv (
rebelId (
heroPick (
form (2.Form"(
RptTank
tankId (
count ("◊
RptMan
pos (
name (	
vip (
pros (
prosMax (
party (	
hero (
prosAdd	 (
tank (2.RptTank

lv
 (
mplt (

firstValue (

serverName (	"C
CrossRptMan
name (	

serverName (	

firstValue ("∂
RptMine
pos (
mine (

lv (
name (	
vip (
party (	
hero (
tank (2.RptTank
mplt	 (

firstValue
 (

serverName (	"Ò

RptAtkHome
result (
first (
honour (
attacker (2.RptMan
defencer (2.RptMan
friend (	
grab (2.Grab
record (2.Record
award	 (2.Award
demageScore
 (
friendliness ("Ñ

RptAtkMine
result (
first (
honour (
attacker (2.RptMan
defencer (2.RptMine
grab (2.Grab
award (2.Award
record	 (2.Record
winStaffingExp
 (
failStaffingExp (
staffingExpAdd (
honourGoldWin (
honourGoldFail (
	grabScore (
demageScore (
plunderGold (
defPlunderGold ("í
RptAtkArena
result (
first (
attacker (2.RptMan
defencer (2.RptMan
award (2.Award
record (2.Record"y
	RptAtkWar
result (
first (
attacker (2.RptMan
defencer (2.RptMan
record (2.Record"°
Report 
	scoutHome (2.RptScoutHome 
	scoutMine (2.RptScoutMine
atkHome (2.RptAtkHome
atkMine (2.RptAtkMine
defHome (2.RptAtkHome
defMine (2.RptAtkMine
time (
atkArena (2.RptAtkArena
defArena	 (2.RptAtkArena!
globalArena
 (2.RptAtkArena"

scoutRebel (2.RptScoutRebel"

atkAirship (2.RptAtkAirship"

defAirship (2.RptAtkAirship"õ
MailShow
keyId (
type (
moldId (
title (	
sendName (	
state (
time (
param (	
isCollections	 ("É
Mail
keyId (
type (
title (	
sendName (	
toName (	
state (
contont (	
time (
award	 (2.Award
report
 (2.Report
moldId (
param (	

lv (
vipLv (
isCollections (")
Section
	sectionId (
box ("
Skill

id (

lv ("+
Mill
pos (

id (

lv ("%
Effect

id (
endTime ("C

RankPlayer
rank (
name (	

lv (
fight ("Ñ
LotteryEquip
	lotteryId (
	freetimes (

cd (
lotteryTime (
purple (
time (
isFirst ("í
	PartyRank
rank (
partyId (
	partyName (	
partyLv (
member (
fight (
applyLv (

applyFight ("ç
Party
partyId (
rank (
	partyName (	
legatusName (	
partyLv (
member (
fight (
slogan (	
innerSlogan	 (	
	applyType
 (
applyLv (

applyFight (
jobName1 (	
jobName2 (	
jobName3 (	
jobName4 (	
build (
	scienceLv (
wealLv (
altarLv (
altarexp (
altarBossLv ("f
PartyDonate
stone (
iron (
silicon (
copper (
oil (
gold ("‘
PartyMember
lordId (
icon (
sex (
nick (	
job (
level (
fight (
donate (
weekAllDonate	 (

weekDonate
 (
isOnline (
militaryRank (")
LiveTask
taskId (
count (")
	PartyProp
keyId (
count ("i

PartyApply
lordId (
icon (
nick (	
level (
fight (
	applyDate ("1
DbPartyApply
lordId (
	applyDate (">
Ruins
isRuins (
lordId (
attackerName (	"Ã
MapData
pos (
name (	
pros (
prosMax (

lv (
party (	
free (
surface (
ruins	 (2.Ruins
heroPick
 (
	nameplate (
	rebelGift ("$
WorldMineInfo
mine (2.Mine"&
	PartyMine
name (	
pos (":
WorldFreeTimeInfo
time (
pos (

my (".
	TaskDayiy
dayiy (

dayiyCount ("J
TaskLive
live (
	liveAward (
liveAwardMap (2.TwoInt"H
Task
taskId (
schedule (
status (
accept ("L
Trend
trendId (

trendParam (2.TrendParam
	trendTime ("0

TrendParam
content (	
man (2.Man"<
DbTrend
trendId (
param (	
	trendTime ("F
PartyCombat
combatId (
schedule (
form (2.Form"E
PartySection
	sectionId (

combatLive (
status ("u
Invasion
lordId (
keyId (
portrait (
state (
name (	

lv (
endTime ("ë
Aid
lordId (
keyId (
portrait (
name (	

lv (
state (
form (2.Form
fight (
load	 ("9
	ArmyStatu
lordId (
keyId (
state ("ﬁ
Chat
time (
channel (
name (	
portrait (
vip (
msg (	

id (
param (	
report	 (
style
 (
tankData (2	.TankData
sysId (
heroId (
isGm (
isGuider (
staffing (
fortressJobId (
	medalData (2
.MedalData

awakenHero (2.AwakenHero
militaryRank (
bubble (
teamId (
uid (+
crossPlayInfo (2.crossChatPlayerInfo
roleId ("Z
crossChatPlayerInfo

serverName (	
fight (
	partyName (	
level ("1
Extreme
name (	

lv (
time ("A

AtkExtreme
attacker (2.Extreme
record (2.Record"n
	PartyLive
lordId (
icon (
sex (
nick (	
job (
level (
live ("C
RankData
name (	

lv (
value (
value2 ("Ë
TankData
tankId (
attack (

hp (
payload (
hit (
dodge (
crit (
critDef (
impale	 (
defend
 (
tenacity (
burst (
frighten (
	fortitude ("Ø
Activity

activityId (
name (	
	beginTime (
endTime (
displayTime (
open (
tips (
type (
awardId	 (
minLv
 ("a
ActivityCond
keyId (
cond (
status (
award (2.Award
param (	"?
	CondState
state (#
activityCond (2.ActivityCond"©

DbActivity

activityId (
status (
towInt (2.TwoInt
	beginTime (
open (
endTime (
prop (2.TwoInt
save (2.TwoInt"o
Mecha
mechaId (
tankId (
cost (
count (
crit (
part (
free ("k
Quota
quotaId (
display (
price (
count (
award (2.Award
buy ("Å
ActPlayerRank
lordId (
rank (
rankType (
	rankValue (
param (	
nick (	
rankTime ("•
ActPartyRank
partyId (
rankType (
	rankValue (
param (	
lordId (
	partyName (	
fight (
rank (
rankTime	 ("Ç
PartyLvRank
rank (
partyId (
	partyName (	
partyLv (
	scienceLv (
wealLv (
build ("-
	AmyRebate
rebateId (
status ("H
Fortune
	fortuneId (
cost (
count (
score ("R
	RankAward
rank (
rankEd (
rankType (
award (2.Award"c
BeeRank
status (

resourceId (
state (%
actPlayerRank (2.ActPlayerRank"B
	MemberReg
time (
name (	

lv (
fight ("B
PartyReg

lv (
name (	
count (
fight ("±
	WarRecord

partyName1 (	
name1 (	
hp1 (

partyName2 (	
name2 (	
hp2 (
result (
rank (
time	 (
lv1
 (
lv2 ("F
WarRecordPerson
record (2
.WarRecord
rpt (2
.RptAtkWar"(
Profoto
propId (
count ("H
WarRank
rank (
	partyName (	
count (
fight ("I

WarWinRank
rank (
name (	
winCount (
fight ("l
Tech
techId (
type (
	usePropId (
usePropcount (
propId (
count ("Z
General

generanlId (
heroId (
count (
price (
point (".
QuotaVip
vip (
quota (2.Quota"4
HurtRank
rank (
name (	
hurt (":
Village
	villageId (
topup (
price ("v
VillageAward
landId (
	villageId (
onday (
state (
status (
award (2.Award"=
Atom
grid (
type (

id (
count ("ñ
Cash
cashId (
	formulaId (
state (
free (
price (
atom (2.Atom
award (2.Award
refreshDate ("V
PartResolve
	resolveId (
propId (
count (
award (2.Award"T
TopupGamble
gambleId (
topup (
price (
award (2.Award"W
SeniorMapData
pos (
name (	
party (
freeTime (

my ("H
SeniorScore
lordId (
fight (
score (
get ("A
SeniorPartyScore
partyId (
fight (
score ("7
	ScoreRank
name (	
fight (
score ("6
Pray
prayId (
card (
prayTime ("=
PrayCard

prayCardId (
propId (
count (""
TwoValue

v1 (

v2 ("^
MilitaryScience
militaryScienceId (
level (
	fitTankId (
fitPos ("s
TankFormula
tankFormulaId (
tankId (
grab (2.Grab
tank (2.Tank
prop (2.Prop"ñ
TankExtract
	extractId (
price (
tenPrice (
	highPrice (
highTenPrice (
commonTankId (
seniorTankId ("]
MilitaryScienceGrid
tankId (
pos (
status (
militaryScienceId ("-
MilitaryMaterial

id (
count ("F
Equate
equateId (
atom (2.Atom
award (2.Award"0
Atom2
kind (

id (
count ("B
Pendant
	pendantId (
endTime (
foreverHold ("<
Portrait

id (
endTime (
foreverHold ("G
FortressBattleParty
rank (
partyId (
	partyName (	"0
FortressSelf
nowNum (
totalNum ("L
FortressDefend
lordId (
nick (	
level (
fight ("S
WarRankInfo
dateTime (
rankId (
partyId (
	partyName (	"∞
FortressRecord
	reportKey (

partyName1 (	
name1 (	
hp1 (

partyName2 (	
name2 (	
hp2 (
result (
time	 (
isNPC
 ("ë
RptAtkFortress
	reportKey (
result (
first (
attacker (2.RptMan
defencer (2.RptMan
record (2.Record"g
FortressPartyRank
rank (
	partyName (	
fightNum (
jifen (
isAttack ("P
FortressJiFenRank
rank (
nick (	
fightNum (
jifen ("+
MyFortressAttr

id (
level ("K
FightValueAdd

isReceived (
receiveTime (
	recvTimes ("K
NobilityAncestry

ancestryId (
status (
receiveTime ("1

SufferTank
tankId (
sufferCount ("*
MyCD
	beginTime (
endTime ("o
FortressJob
jobId (
index (
lordId (
nick (	
appointTime (
endTime ("°
MyFortressFightData
lordId ("
sufferTankMap (2.SufferTank#
destoryTankMap (2.SufferTank
myCD (2.MyCD
jifen (
fightNum (
winNum (
myReportKeys ('
myFortressAttr	 (2.MyFortressAttr
sufferTankCountForevel
 (
mplt ("å
MyPartyStatistics
partyId (
fightNum (
jifen (
winNum (
isAttack (#
destoryTankMap (2.SufferTank"v
FortressJobAppoint
jobId (
lordId (
appointTime (
endTime (
index (
nick (	">
EnergyStoneInlay
hole (
stoneId (
pos ("F
TreasureShopBuy

treasureId (
buyNum (
buyWeek ("(
ShopBuy
gid (
buyCount ("@
Shop
sty (
refreashTime (
buy (2.ShopBuy"Ÿ
DrillFightData
lordId (
lastEnrollDate (

successNum (
failNum (
exploit (
isRed (
	campRewad (
firstRecordKey (
secondRecordKey	 (
thirdRecordKey
 ("e
DrillResult
redRest (
redTotal (
blueRest (
	blueTotal (
redWin ("∞
DrillRecord
	reportKey (
attacker (	
	attackNum (

attackCamp (
defender (	
	defendNum (

defendCamp (
result (
time	 ("é
	DrillRank
rank (
lordId (
name (	
fightNum (

successNum (
failNum (
camp (
isReward ("?
DrillShopBuy
shopId (
buyNum (
restNum ("P
DrillImproveInfo
buffId (
buffLv (
exper (
ratio ("M
PushComment
state (
lastCommentTime (
shouldPushTime ("6
GameServerInfo
serverId (

serverName (	"3
CrossSysChatInfo
dayNum (
dayTime (	"Ø
Athlete
serverId (
roleId (
nick (	
groupId (
fight (
winNum (
failNum (
myReportKeys (
form	 (2.Form
equip
 (2.Equip
part (2.Part
science (2.Science
skill (2.Skill
effect (2.Effect

staffingId ( 
inlay (2.EnergyStoneInlay1
militaryScienceGrid (2.MilitaryScienceGrid)
militaryScience (2.MilitaryScience
portrait (
	partyName (	
level (
medal (2.Medal

medalBouns (2.MedalBouns

awakenHero (2.AwakenHero
leq (2
.LordEquip
militaryRank (#
secretWeapon (2.SecretWeapon
atkEft (2.AttackEffectPb%
graduateInfo (2.GraduateInfoPb
historyRoleId (
partyScience (2.Science

energyCore  (2	.ThreeInt"‚
JiFenPlayer
serverId (
roleId (
nick (	
jifen (
exchangeJifen (
mybet (2.MyBet 
crossTrends (2.CrossTrend#
CrossShopBuy (2.CrossShopBuy
lastUpdateCrossShopDate	 ("e
Rebel
rebelId (
rebelLv (
heroPick (
state (
type (
pos ("
	RebelRank
rank (
lordId (
name (	
killUnit (
	killGuard (

killLeader (
score ("≥
RoleRebelData
lordId (
name (	
lastUpdateWeek (
lastUpdateTime (
killNum (
killUnit (
	killGuard (

killLeader (
score	 (
	totalUnit
 (

totalGuard (
totalLeader (

totalScore (
weekRankTime (
totalRankTime ("∞
CrossRecord
	reportKey (
serverName1 (	
name1 (	
hp1 (
serverName2 (	
name2 (	
hp2 (
result (
time	 (
detail
 ("®
CrossRptAtk
	reportKey (
result (
detail (
first (
attacker (2.CrossRptMan
defencer (2.CrossRptMan
record (2.Record"Å
CrossJiFenRank
rank (

serverName (	
name (	
winNum (
failNum (
jifen (
myGroup ("O
CompteRound
roundNum (
win (
	reportKey (
detail ("ø

ComptePojo
pos (
serverId (
roleId (
nick (	
bet (
myBetNum (

serverName (	
fight (
portrait	 (
	partyName
 (	
level ("é
KnockoutCompetGroup
competGroupId (
c1 (2.ComptePojo
c2 (2.ComptePojo
win (!
compteRound (2.CompteRound"S
KnockoutBattleGroup
	groupType ()
competGroup (2.KnockoutCompetGroup"ã
FinalCompetGroup
competGroupId (
c1 (2.ComptePojo
c2 (2.ComptePojo
win (!
compteRound (2.CompteRound"÷
MyBet
myGroup (
stage (
	groupType (
competGroupId (
c1 (2.ComptePojo
c2 (2.ComptePojo
win (!
compteRound (2.CompteRound
betState	 (
betTime
 ("D

CrossTrend
trendId (

trendParam (	
	trendTime ("?
CrossShopBuy
shopId (
buyNum (
restNum ("]
CrossTopRank
rank (

serverName (	
name (	
fight (
roleId ("z
FamePojo

id (
name (	
serverId (

serverName (	
level (
fight (
portrait ("É
FameBattleReview
pos (
name (	
serverId (

serverName (	
level (
fight (
portrait ("f
	CrossFame
groupId (
famePojo (2	.FamePojo+
fameBattleReview (2.FameBattleReview"a
CrossFameInfo
	beginTime (	
endTime (	
	crossFame (2
.CrossFame
keyId ("J
CPFame
type (

serverName (	
name (	
portrait ("X

CPFameInfo
	beginTime (	
endTime (	
cpFame (2.CPFame
keyId ("
CDFame
championServer (	
secondServer (	
thirdServer (	
	hotServer (	
heroChampion (2	.FamePojo"X

CDFameInfo
keyId (
	beginTime (	
endTime (	
cdFame (2.CDFame"=
TankCarnivalReward
lineNum (
awards (2.Award"Q
PartSmeltRecord
attrs (2.PartSmeltAttr
save (
crit (2.Kv"8
PartSmeltAttr

id (
val (
newVal ("h
CPMemberReg
time (
name (	

lv (
fight (
partyId (
	partyName (	"}
CPPartyInfo
partyLv (
partyId (
	partyName (	
	memberNum (

totalFight (

serverName (	"∏
CPRecord
	reportKey (

partyName1 (	
name1 (	
serverName1 (	
hp1 (

partyName2 (	
name2 (	
serverName2 (	
hp2	 (
result
 (
rank (
time (
group (
isMy (
	serverId1 (
	serverId2 (
roleId1 (
roleId2 ("ï
CPRptAtk
	reportKey (
result (
first (
attacker (2.CrossRptMan
defencer (2.CrossRptMan
record (2.Record"§
CPRank
rank (
	partyName (	
name (	

fightCount (
fight (
jifen (
winCount (

serverName (	
rewardState	 ("<
CDMorale
buffId (
buffLv (
serverId ("/
ReceiveRank
serverId (
lordId ("ö
CDFinalRank
rank (
serverId (

serverName (	

totalScore (
totalWin (
	totalLost (
sort (
rankTime ("z
CDBattleMatch
fieldId (
redServerId (
redServerName (	
blueServerId (
blueServerName (	"f
CDTeamServerMatch
teamId (
batch (

battleTime (
battle (2.CDBattleMatch"z
CDTeamServerDistribution
teamId (
seedServerId (
seedServerName (	 
team (2.CDTeamServerMatch"A
CDMyTeamData
teamId (!
batch (2.CDMyTeamBatchData"I
CDMyTeamBatchData
batchId (
fieldId (

battleTime ("A
CDStrongholdFormData
strongholdId (
form (2.Form"z
CDTeamScore
teamId (

serverName (	
score (

totalFight (
serverId (

updateTime ("¢

CDHeroRank
rank (
nick (	

serverName (	
winNum (
lostNum (
fight (
lordId (
serverId (

updateTime	 ("ç
CDTeamBattleData
teamId (

serverName (	
armyNum (
	occupyNum (
winNum (
lostNum (
serverId ("’
CDBattleStronghold
point (

battleTime (
status (
redArmy (
redWin (
redLost (
blueArmy (
blueWin (
blueLost	 (
strongholdId
 (
fieldId ("ÿ
CDBattleField
fieldId (
fieldStatus (

battleTime (
redServerId (
blueServerId (
redServerName (	
blueServerName (	
result (
strongholdId	 (
batch
 ("Ô
CDRecord
	reportKey (
attacker (	
attackServer (	

attackArmy (
	attackNum (

attackCamp (
defender (	
defendServer (	

defendArmy	 (
	defendNum
 (

defendCamp (
result (
time (
strongholdId (
attackServerId (
defencServerId (

attackerId (

defencerId ("¡
CDStrongholdRank
rank (

serverName (	
nick (	
winNum (
lostNum (
fightNum (
lordId (
serverId (

updateTime	 (
strongholdId
 ("r
CDBattlePojo

serverName (	
totalMember (
totalMorale (

totalFight (
serverId ("¿
CDKnockoutBattle
battleGroupId (
fieldId (
state (
c1 (2.CDBattlePojo
c2 (2.CDBattlePojo
	beginTime (
batch (
myBet (
betNum	 ("”
CDBattleBet
battleGroupId (
	beginTime (
serverName1 (	
serverName2 (	
myBet (
betNum (
betCount (
winNum (
state	 ( 
strongholdState
 (2.TwoInt"≈
CDPlayer
serverId (
lordId (
level (
fight (

maxTankNum (
hero (2.Hero
part (2.Part
equip (2.Equip
skill	 (2.Skill
effect
 (2.Effect
science (2.Science

staffingLv ( 
inlay (2.EnergyStoneInlay)
militaryScience (2.MilitaryScience1
militaryScienceGrid (2.MilitaryScienceGrid
partyScience (2.Science
cdTank (2.Tank

betGroupId (
formStrongholdId (
buy (2.CrossShopBuy
updateCDShopDate (
jifen (
nick (	
winNum (
lostNum (

staffingId (
medal (2.Medal

medalBouns (2.MedalBouns 
awakenHeros (2.AwakenHero"G
	PayRebate
money (
rate (
recharge (
num ("˝
CPPartyMember
serverId (
roleId (
nick (	
fight (
level (
groupWinNum (
finalWinNum (

fightCount (
partyId	 (
	partyName
 (	
jifen (
regTime (
myReportKeys (#
crossShopBuy (2.CrossShopBuy
form (2.Form
equip (2.Equip
part (2.Part
science (2.Science
skill (2.Skill
effect (2.Effect

staffingId ( 
inlay (2.EnergyStoneInlay1
militaryScienceGrid (2.MilitaryScienceGrid)
militaryScience (2.MilitaryScience
state (
instForm (2.Form
jifenjiangli (
exchangeJifen ( 
crossTrends (2.CrossTrend
portrait (
medal (2.Medal

medalBouns  (2.MedalBouns

awakenHero! (2.AwakenHero
leq" (2
.LordEquip
militaryRank# (#
secretWeapon$ (2.SecretWeapon%
attackEffect% (2.AttackEffectPb%
graduateInfo& (2.GraduateInfoPb
partyScience' (2.Science

energyCore( (2	.ThreeInt"O
ServerSisuation
serverId (
groupKeyList (
finalKeyList ("±
CPParty
roleId (
order (
outCount (
formNum (
serverId (
partyId (
	partyName (	
partyLv (
warRank	 (
fight
 (
group (
isFinalGroup (
partyReportKey (

totalJifen (
fighters (
myPartySirPortrait ("&
	RankParty
rank (
key (	"g

GroupParty
group (
groupPartyMap (	
groupKeyList (
	rankParty (2
.RankParty"^
Reborn
round (
pos (
tankId (
count (

hp (
awake ("2

PirateGrid
has (
gridData (2.Atom"p

PirateData
count (

oneLottery (

allLottery (
grids (2.PirateGrid
isReset ("r
Medal
keyId (
medalId (
upLv (
upExp (
refitLv (
pos (
locked ("*
	MedalChip
chipId (
count (";
	MedalData
medalId (
upLv (
refitLv (",

MedalBouns
medalId (
state ("C
SectionReward
sectionType (
times (
recvId ("8
Day7Act
keyId (
status (
recved ("Ä
	DbDay7Act
recvAwardIds (
status (2.TwoInt
	tankTypes (2.TwoInt
lvUpDay (
equips (2.TwoInt"I
Lottery
lucky (
recvLuckyAwardIds (
lastResetDay ("Z
ActRebelRank
rank (
lordId (
name (	
killNum (
score ("g

AwakenHero
keyId (
heroId (
state (
skillLv (2.TwoInt
	failTimes ("D
SkillEffect
round (
key (

id (
state ("[
AirshipAttackInfo
partId (
partName (	
	armyCount (
	marchTime ("L
AirshipDetail
produceTime (

produceNum (

durability ("g
AirshipOccupy
partyId (
	partyName (	
lordId (
lordName (	
portrait ("f
AirshipBase

id (
safeEndTime (

teamLeader (
attackCount (
ruins ("e
Airship
base (2.AirshipBase
occupy (2.AirshipOccupy
detail (2.AirshipDetail"î
AirshipTeam
	airshipId (
lordId (
lordName (	
portrait (
armyNum (
fight (
state (
endTime ("ò
AirshipArmy
lordId (
	armyKeyId (
lordName (	
portrait (
	tankCount (
fight (
level (
	commander ("à
RptAtkAirship
result (
first (
record (2.Record

recordLord (2.TwoLong
	attackers (2
.RptAtkMan
	defencers (2
.RptAtkMan
attackerName (	
defencerName (	
	airshipId	 (
lostDurb
 (

remainDurb ("{
RecvAirshipProduceAwardRecord
recvTime (
nick (	
type (
awardId (
count (
mplt ("v
	RptAtkMan
lordId (
name (	
	commander (
tank (2.RptTank
mplt (

firstValue ("û
	LordEquip
keyId (
equip_id (
pos (
skillLv (2.TwoInt
isLock (
skillLvSecond (2.TwoInt
lordEquipSaveType ("W
LordEquipBuilding
equip_id (
period (
endTime (
tech_id ("_
LeqMatBuilding
pid (
count (
period (
complete (
endTime ("B
	Broadcast
nick (	
type (	

id (	
count (	")
HeroPut
partId (
heroId ("W
ActCumulativePayInfo
dayId (
totalPay (
addPay (
status ("H
Skin
skinId (
status (
	remaining (
count ("z
Quinn
type (

id (
count (
desc (	
sold (
dis (
price (
especial ("†

QuinnPanel
type (
quinn (2.Quinn
getType (
	getNumber (
getSum (
refreshTime (
award (2.Award
eggId (".
SecretWeaponBar
sid (
locked ("9
SecretWeapon

id (
bar (2.SecretWeaponBar"=
AttackEffectPb
type (
useId (
unlock ("ç
	LabInfoPb
labItemInfo (2.TwoInt
archInfo (2.TwoInt
techInfo (2.TwoInt

personInfo (2.TwoInt
resourceInfo (2.TwoInt

rewardInfo (%
graduateInfo (2.GraduateInfoPb
proInfo (2	.ThreeInt
spyInfo	 (2.SpyInfo"=
GraduateInfoPb
type (
graduateInfo (2.TwoInt"U

GrabRedBag
lordName (	
portrait (
	grabMoney (
grabTime ("B
RedBagSummary
uid (
lordName (	

remainGrab ("Ω

RedBagChat
time (
name (	
portrait (
staffing (
vip (
militaryRank (
bubble (
uid (

remainGrab	 (
type
 (
isSys ("£
	ActRedBag
uid (
lordName (	
portrait (

totalMoney (
remainMoney (
grabCnt (
sendTime (
grab (2.GrabRedBag"U
SpyInfo
areaId (
state (
taskId (
time (
spyId ("ä
RedPlanInfo
	pointInfo (2.TwoInt

rewardInfo (
	itemCount (
fuel (
shopInfo (2.TwoInt
version (	
fuelBuyCount (

nowPointId (
buyTime	 (
linePointInfo
 (2.TwoInt
	nowAreaId (
fuelTime ("q
TeamRoleInfo
roleId (
portrait (
nick (	
fight (
status (

serverName (	"h
FestivalInfo
	countInfo (2.TwoInt
loginRewardState (
	loginTime (
version (	"E
	LuckyInfo
version (	
useLuckyCount (
recharge ("X
LuckyGlobalInfo
version (	
poolGold ("
luckyLog (2.ActLuckyPoolLog"º
TeamInstanceInfo
	countInfo (2.TwoInt

rewardInfo (2.TwoInt
time (
taskInfo (2.TwoInt 
taskRewardState (2.TwoInt
bounty (
dayItemCount ("?
ActLuckyPoolLog
name (	
time (
goodInfo (	"ú
PartyRebelData
partyId (
	partyName (	
rank (
lastRank (
killUnit (
	killGuard (

killLeader (
score ("R
DialDailyGoalInfo
lastDay (
count (
rewardStatus (2.TwoInt")
TeamTaskData
taskInfo (2.KvLong"<
TeamTask
taskId (
schedule (
status ("a
HonourScore
roleId (
openTime (
score (
rankTime (
partyId ("7

HonourRank
rank (
nick (	
score ("=
	LeqScheme
type (
leq (2.TwoInt
name (	"J
SpyTaskReward
areaId (
award (2.Award

awardLevel ("<
	QueAnswer
keyId (
value (
	addtional (	"
WorldStaffing
exp ("W
WarActivityInfo
version (	
info (2.TwoInt
rewardState (2.TwoInt"¶
TacticsInfo
info (2.Tactics
tacticsSlice (2.TwoInt
tacticsItem (2.TwoInt
keyId (
combatId (!
tacticsForm (2.TacticsForm"n
Tactics
keyId (
	tacticsId (

lv (
exp (
use (
state (
bind ("Ÿ
PersonKingInfo
version (	!
killInfo (2.PersonRankInfo#

sourceInfo (2.PersonRankInfo#

creditInfo (2.PersonRankInfo&
totalKillInfo (2.PersonRankInfo!
	partyInfo (2.PartyRankInfo"S
PersonRankInfo
lordId (
totalNumber (
points (
time (">
PartyRankInfo
partyId (
points (
time ("a
KingRankRewardInfo
version (	
pointsStatus (2.TwoInt

rankStatus (2.TwoInt",
KingRankInfo
nick (	
points ("+
TacticsForm
index (
keyId ("C
WipeInfo
exploreType (
combatId (
buyCount ("I
WipeRewardInfo
exploreType (
award (2.Award
exp ("=

FriendGive
lordId (
count (
giveTime ("N
GetGiveProp
type (
propId (
num (
lastGiveTime ("C
DBFriendliness
lordId (
state (

createTime ("q

EnergyCore
level (
section (
exp (
state (
attMap (2.TwoInt
redExp ("ï
LordEnergyInfo
roleId (
nick (	
level (
fight (
part (2	.LordPart
enLevel (
vip (
allmoney ("J
LordPart
partId (
upLv (
refitLv (
smeltLv (B
com.game.pbBCommonPb