
��

Game.proto
Base.protoCommon.proto"�
BeginGameRq
serverId (
keyId (
token (	
deviceNo (	

curVersion (	
clientId (	2!
ext.Base� (2.BeginGameRq"[
BeginGameRs
state (
time (
name (	2!
ext.Base� (2.BeginGameRs"_
CreateRoleRq
portrait (
nick (	
sex (2"
ext.Base� (2.CreateRoleRq"a
CreateRoleRs
state (
nick (	
portrait (2"
ext.Base� (2.CreateRoleRs".

GetNamesRq2 
ext.Base� (2.GetNamesRq"<

GetNamesRs
name (	2 
ext.Base� (2.GetNamesRs"0
RoleLoginRq2!
ext.Base� (2.RoleLoginRq"�
RoleLoginRs
state (
war (
boss (
staffing (
fortress (
drill (

crossFight (

crossParty (

crossDrill	 (2!
ext.Base� (2.RoleLoginRs",
	GetLordRq2
ext.Base� (2
.GetLordRq"�
	GetLordRs
lordId (
nick (	
portrait (
level (
exp (
vip (
pos (
gold (
ranks	 (
command
 (
fame (
fameLv (
honour (
combat (
pros (
prosMax (
prosTime (
power (
	powerTime (
newState (
fight (
equip (
fitting (
metal (
plan (
mineral (
tool (
draw (
	equipEplr (
partEplr (
extrEplr (
timeEplr  (
equipBuy! (
partBuy" (
	extrReset# (
huangbao$ (
	clickFame% (
buyFame& (
sex' (
buyPower( (
	newerGift) (

buildCount* (
olTime+ (
ctTime, (
olAward- (

gm. (
topup/ (
guider0 (
partyTipAward1 (
staffing2 (

staffingLv3 (
staffingExp4 (
ruins5 (2.Ruins
militaryEplr6 (
militaryBuy7 (
createRoleTime8 (
scout9 (
energyStoneEplrId: (
energyStoneBuy; (
timeBuy< (
openServerDay= (
	tankDrive> (
chariotDrive? (
artilleryDrive@ (
rocketDriveA (
	detergentB (

grindstoneC (
polishingMtrD (
maintainOilE (
	grindToolF (
medalUpCdTimeG (
	medalEplrH (
medalBuyI (
scoutCdTimeJ (
partMatrialK (2.TwoInt
underAttackL (
	oldLordIdM (
bubbleIdN (
precisionInstrumentO (
mysteryStoneP (
bountyQ (
corundumMatrialR (
inertGasS (
	activeBoxT (

tacticsBuyU (
tacticsResetV (2
ext.Base� (2
.GetLordRs",
	GetTimeRq2
ext.Base� (2
.GetTimeRq"K
	GetTimeRs
time (
openPay (2
ext.Base� (2
.GetTimeRs",
	GetTankRq2
ext.Base� (2
.GetTankRq"�
	GetTankRs
tank (2.Tank
queue_1 (2.TankQue
queue_2 (2.TankQue
refit (2	.RefitQue2
ext.Base� (2
.GetTankRs",
	GetArmyRq2
ext.Base� (2
.GetArmyRq"A
	GetArmyRs
army (2.Army2
ext.Base� (2
.GetArmyRs",
	GetFormRq2
ext.Base� (2
.GetFormRq"A
	GetFormRs
form (2.Form2
ext.Base� (2
.GetFormRs"P
	SetFormRq
form (2.Form
clean (2
ext.Base� (2
.SetFormRq"P
	SetFormRs
form (2.Form
fight (2
ext.Base� (2
.SetFormRs"N
RepairRq
tankId (

repairType (2
ext.Base� (2	.RepairRq"F
RepairRs
count (
cur (2
ext.Base� (2	.RepairRs"4
GetResourceRq2#
ext.Base� (2.GetResourceRq"
GetResourceRs
iron (
oil (
copper (
silicon (
stone (2#
ext.Base� (2.GetResourceRs"4
GetBuildingRq2#
ext.Base� (2.GetBuildingRq"�
GetBuildingRs
ware1 (
ware2 (
tech (
factory1 (
factory2 (
refit (
command (
workShop (
leqm	 (
queue
 (2	.BuildQue
upBuildTime (
onBuild (
mill (2.Mill2#
ext.Base� (2.GetBuildingRs"a
UpBuildingRq
type (

buildingId (
pos (2"
ext.Base� (2.UpBuildingRq"�
UpBuildingRs
gold (
iron (
oil (
copper (
silicon (
queue (2	.BuildQue2"
ext.Base� (2.UpBuildingRs".

LoadDataRq2 
ext.Base� (2.LoadDataRq"?

LoadDataRs
success (2 
ext.Base� (2.LoadDataRs"^
BuildTankRq
tankId (
count (
which (2!
ext.Base� (2.BuildTankRq"�
BuildTankRs
queue (2.TankQue
oil (
iron (
copper (
silicon (2!
ext.Base� (2.BuildTankRs"(
HeartRq2
ext.Base� (2.HeartRq"(
HeartRs2
ext.Base� (2.HeartRs"\
CancelQueRq
type (
keyId (
which (2!
ext.Base� (2.CancelQueRq"�
CancelQueRs
oil (
iron (
copper (
silicon (
stone (
award (2.Award2!
ext.Base� (2.CancelQueRs",
	GetPropRq2
ext.Base� (2
.GetPropRq"Z
	GetPropRs
prop (2.Prop
queue (2.PropQue2
ext.Base� (2
.GetPropRs"K
	BuyPropRq
propId (
count (2
ext.Base� (2
.BuyPropRq"I
	BuyPropRs
gold (
count (2
ext.Base� (2
.BuyPropRs"Z
	UsePropRq
propId (
count (
param (	2
ext.Base� (2
.UsePropRq"k
	UsePropRs
count (
effect (2.Effect
award (2.Award2
ext.Base� (2
.UsePropRs"�

SpeedQueRq
type (
cost (
keyId (
which (
propId (
	propCount (2 
ext.Base� (2.SpeedQueRq"\

SpeedQueRs
gold (
count (
endTime (2 
ext.Base� (2.SpeedQueRs"O
BuildPropRq
propId (
count (2!
ext.Base� (2.BuildPropRq"�
BuildPropRs
queue (2.PropQue
stone (
	skillBook (
heroChip (
atom2 (2.Atom22!
ext.Base� (2.BuildPropRs"O
RefitTankRq
tankId (
count (2!
ext.Base� (2.RefitTankRq"�
RefitTankRs
queue (2	.RefitQue
oil (
iron (
copper (
silicon (2!
ext.Base� (2.RefitTankRs".

GetEquipRq2 
ext.Base� (2.GetEquipRq"E

GetEquipRs
equip (2.Equip2 
ext.Base� (2.GetEquipRs"?
SellEquipRq
keyId (2!
ext.Base� (2.SellEquipRq"?
SellEquipRs
stone (2!
ext.Base� (2.SellEquipRs"V
	UpEquipRq
keyId (
pos (
from (2
ext.Base� (2
.UpEquipRq"E
	UpEquipRs

lv (
exp (2
ext.Base� (2
.UpEquipRs"f
	OnEquipRq
from (
fromPos (
toPos (

to (2
ext.Base� (2
.OnEquipRq",
	OnEquipRs2
ext.Base� (2
.OnEquipRs"2
UpCapacityRq2"
ext.Base� (2.UpCapacityRq"@
UpCapacityRs
gold (2"
ext.Base� (2.UpCapacityRs"T

AllEquipRq

on (
pos (
off (2 
ext.Base� (2.AllEquipRq".

AllEquipRs2 
ext.Base� (2.AllEquipRs",
	GetPartRq2
ext.Base� (2
.GetPartRq"A
	GetPartRs
part (2.Part2
ext.Base� (2
.GetPartRs",
	GetChipRq2
ext.Base� (2
.GetChipRq"A
	GetChipRs
chip (2.Chip2
ext.Base� (2
.GetChipRs"D
CombinePartRq
partId (2#
ext.Base� (2.CombinePartRq"I
CombinePartRs
part (2.Part2#
ext.Base� (2.CombinePartRs"T
ExplodePartRq
keyId (
quality (2#
ext.Base� (2.ExplodePartRq"�
ExplodePartRs
fitting (
plan (
mineral (
tool (
stone (
award (2.Award2#
ext.Base� (2.ExplodePartRs"F
OnPartRq
keyId (
pos (2
ext.Base� (2	.OnPartRq"*
OnPartRs2
ext.Base� (2	.OnPartRs"d
ExplodeChipRq
chipId (
count (
quality (2#
ext.Base� (2.ExplodeChipRq"E
ExplodeChipRs
fitting (2#
ext.Base� (2.ExplodeChipRs"U
UpPartRq
keyId (
pos (
metal (2
ext.Base� (2	.UpPartRq"Y
UpPartRs
success (
stone (
metal (2
ext.Base� (2	.UpPartRs"Z
RefitPartRq
keyId (
pos (
draw (2!
ext.Base� (2.RefitPartRq">
RefitPartRs
upLv (2!
ext.Base� (2.RefitPartRs"2
GetScienceRq2"
ext.Base� (2.GetScienceRq"i
GetScienceRs
science (2.Science
queue (2.ScienceQue2"
ext.Base� (2.GetScienceRs"M
UpgradeScienceRq
	scienceId (2&
ext.Base� (2.UpgradeScienceRq"�
UpgradeScienceRs
queue (2.ScienceQue
oil (
iron (
copper (
silicon (
stone (2&
ext.Base� (2.UpgradeScienceRs"0
GetCombatRq2!
ext.Base� (2.GetCombatRq"�
GetCombatRs
combat (2.Combat
explore (2.Combat
section (2.Section
combatId (
equipEplrId (

partEplrId (

extrEplrId (

timePrlrId (
extrMark	 (
wipeTime
 (
militaryEplrId (
energyStoneEplrId (
medalEplrId (
	tacticsId (2!
ext.Base� (2.GetCombatRs"q

DoCombatRq
type (
combatId (
form (2.Form
wipe (2 
ext.Base� (2.DoCombatRq"�

DoCombatRs
result (
record (2.Record
award (2.Award
haust (2.RptTank
exp (2 
ext.Base� (2.DoCombatRs"2
GetMyHerosRq2"
ext.Base� (2.GetMyHerosRq"�
GetMyHerosRs
hero (2.Hero
	coinCount (
resCount (
lockHero (

awakenHero (2.AwakenHero2"
ext.Base� (2.GetMyHerosRs"R
HeroDecomposeRq
type (

id (2%
ext.Base� (2.HeroDecomposeRq"O
HeroDecomposeRs
award (2.Award2%
ext.Base� (2.HeroDecomposeRs"C
HeroLevelUpRq
keyId (2#
ext.Base� (2.HeroLevelUpRq"I
HeroLevelUpRs
hero (2.Hero2#
ext.Base� (2.HeroLevelUpRs"I
HeroImproveRq
hero (2.Hero2#
ext.Base� (2.HeroImproveRq"I
HeroImproveRs
hero (2.Hero2#
ext.Base� (2.HeroImproveRs"B
LotteryHeroRq
type (2#
ext.Base� (2.LotteryHeroRq"x
LotteryHeroRs
hero (2.Hero
stone (
gold (
stoneAdd (2#
ext.Base� (2.LotteryHeroRs"@
BuyExploreRq
type (2"
ext.Base� (2.BuyExploreRq"O
BuyExploreRs
count (
gold (2"
ext.Base� (2.BuyExploreRs"D
ResetExtrEprRq
type (2$
ext.Base� (2.ResetExtrEprRq"6
ResetExtrEprRs2$
ext.Base� (2.ResetExtrEprRs"0
GetFriendRq2!
ext.Base� (2.GetFriendRq"\
GetFriendRs
friend (2.Friend
	giveCount (2!
ext.Base� (2.GetFriendRs"B
AddFriendRq
friendId (2!
ext.Base� (2.AddFriendRq"0
AddFriendRs2!
ext.Base� (2.AddFriendRs"B
DelFriendRq
friendId (2!
ext.Base� (2.DelFriendRq"0
DelFriendRs2!
ext.Base� (2.DelFriendRs"F
BlessFriendRq
friendId (2#
ext.Base� (2.BlessFriendRq"A
BlessFriendRs
exp (2#
ext.Base� (2.BlessFriendRs".

GetBlessRq2 
ext.Base� (2.GetBlessRq"E

GetBlessRs
bless (2.Bless2 
ext.Base� (2.GetBlessRs"F
AcceptBlessRq
friendId (2#
ext.Base� (2.AcceptBlessRq"[
AcceptBlessRs
energy (
award (2.Award2#
ext.Base� (2.AcceptBlessRs".

GetStoreRq2 
ext.Base� (2.GetStoreRq"E

GetStoreRs
store (2.Store2 
ext.Base� (2.GetStoreRs"~
RecordStoreRq
pos (
enemy (
friend (
isMine (
type (2#
ext.Base� (2.RecordStoreRq"K
RecordStoreRs
store (2.Store2#
ext.Base� (2.RecordStoreRs"G
MarkStoreRq
store (2.Store2!
ext.Base� (2.MarkStoreRq"0
MarkStoreRs2!
ext.Base� (2.MarkStoreRs",
	GetMailRq2
ext.Base� (2
.GetMailRq"A
	GetMailRs
mail (2.Mail2
ext.Base� (2
.GetMailRs"Q

SendMailRq
type (
mail (2.Mail2 
ext.Base� (2.SendMailRq"C

SendMailRs
mail (2.Mail2 
ext.Base� (2.SendMailRs"A
RewardMailRq
keyId (2"
ext.Base� (2.RewardMailRq"I
RewardMailRs
award (2.Award2"
ext.Base� (2.RewardMailRs"Z
	DelMailRq
keyId (
type (
delType (2
ext.Base� (2
.DelMailRq",
	DelMailRs2
ext.Base� (2
.DelMailRs"F
RewardAllMailRq
type (2%
ext.Base�- (2.RewardAllMailRq"O
RewardAllMailRs
award (2.Award2%
ext.Base�- (2.RewardAllMailRs"Y
CollectionsMailRq
keyId (
type (2'
ext.Base�- (2.CollectionsMailRq"K
CollectionsMailRs
keyId (2'
ext.Base�- (2.CollectionsMailRs"E

SyncMailRq
award (2.Award2 
ext.Base� (2.SyncMailRq"Y
CombatBoxRq
type (

id (
which (2!
ext.Base� (2.CombatBoxRq"G
CombatBoxRs
award (2.Award2!
ext.Base� (2.CombatBoxRs".

BuyPowerRq2 
ext.Base� (2.BuyPowerRq"K

BuyPowerRs
gold (
power (2 
ext.Base� (2.BuyPowerRs"*
UpRankRq2
ext.Base� (2	.UpRankRq"9
UpRankRs
stone (2
ext.Base� (2	.UpRankRs"A
UpCommandRq
useGold (2!
ext.Base� (2.UpCommandRq"]
UpCommandRs
success (
gold (
book (2!
ext.Base� (2.UpCommandRs",
	BuyProsRq2
ext.Base� (2
.BuyProsRq":
	BuyProsRs
gold (2
ext.Base� (2
.BuyProsRs":
	BuyFameRq
type (2
ext.Base� (2
.BuyFameRq"g
	BuyFameRs
gold (
stone (
fameLv (
fame (2
ext.Base� (2
.BuyFameRs"0
ClickFameRq2!
ext.Base� (2.ClickFameRq"N
ClickFameRs
fameLv (
fame (2!
ext.Base� (2.ClickFameRs".

GetSkillRq2 
ext.Base� (2.GetSkillRq"E

GetSkillRs
skill (2.Skill2 
ext.Base� (2.GetSkillRs"8
	UpSkillRq

id (2
ext.Base� (2
.UpSkillRq"K
	UpSkillRs

lv (
	bookCount (2
ext.Base� (2
.UpSkillRs"2
ResetSkillRq2"
ext.Base� (2.ResetSkillRq"N
ResetSkillRs
gold (
book (2"
ext.Base� (2.ResetSkillRs"A
DestroyMillRq
pos (2#
ext.Base� (2.DestroyMillRq"E
DestroyMillRs
prosMax (2#
ext.Base� (2.DestroyMillRs"B
SeachPlayerRq
nick (	2#
ext.Base� (2.SeachPlayerRq"G
SeachPlayerRs
man (2.Man2#
ext.Base� (2.SeachPlayerRs"0
GetEffectRq2!
ext.Base� (2.GetEffectRq"I
GetEffectRs
effect (2.Effect2!
ext.Base� (2.GetEffectRs"L
DoSomeRq
str (	
mail (2.Mail2
ext.Base� (2	.DoSomeRq";
DoSomeRs
success (2
ext.Base� (2	.DoSomeRs";

DelStoreRq
pos (2 
ext.Base� (2.DelStoreRq".

DelStoreRs2 
ext.Base� (2.DelStoreRs"M
DoLotteryRq
type (
count (2!
ext.Base� (2.DoLotteryRq"�
DoLotteryRs
award (2.Award
	isDisplay (
displayAward (2.Award

cd (
gold (
stoneAdd (
exploreLucky (2!
ext.Base� (2.DoLotteryRs".

GetArenaRq2 
ext.Base� (2.GetArenaRq"�

GetArenaRs
count (
score (
rank (
lastRank (
winCount (
coldTime (

rankPlayer (2.RankPlayer
champion (	
fight	 (
buyCount
 (
award (
unread (2 
ext.Base� (2.GetArenaRs":
	DoArenaRq
rank (2
ext.Base� (2
.DoArenaRq"�
	DoArenaRs
result (
record (2.Record
award (2.Award
form (2.Form
coldTime (
score (
firstValue1 (
firstValue2 (2
ext.Base� (2
.DoArenaRs".

BuyArenaRq2 
ext.Base� (2.BuyArenaRq"K

BuyArenaRs
count (
gold (2 
ext.Base� (2.BuyArenaRs"2
ArenaAwardRq2"
ext.Base� (2.ArenaAwardRq"I
ArenaAwardRs
award (2.Award2"
ext.Base� (2.ArenaAwardRs">

UseScoreRq
propId (2 
ext.Base� (2.UseScoreRq"=

UseScoreRs
score (2 
ext.Base� (2.UseScoreRs"E
InitArenaRq
form (2.Form2!
ext.Base� (2.InitArenaRq"}
InitArenaRs
rank (
count (

rankPlayer (2.RankPlayer
fight (2!
ext.Base� (2.InitArenaRs"=

ReadMailRq
keyId (2 
ext.Base� (2.ReadMailRq".

ReadMailRs2 
ext.Base� (2.ReadMailRs"<
GetLotteryEquipRq2'
ext.Base� (2.GetLotteryEquipRq"a
GetLotteryEquipRs#
lotteryEquip (2.LotteryEquip2'
ext.Base� (2.GetLotteryEquipRs"R
GetPartyRankRq
page (
type (2$
ext.Base� (2.GetPartyRankRq"p
GetPartyRankRs
party (2
.PartyRank
	partyRank (2
.PartyRank2$
ext.Base� (2.GetPartyRankRs"?

GetPartyRq
partyId (2 
ext.Base� (2.GetPartyRq"u

GetPartyRs
party (2.Party
donate (
job (
	enterTime (2 
ext.Base� (2.GetPartyRs":
GetPartyMemberRq2&
ext.Base� (2.GetPartyMemberRq"]
GetPartyMemberRs!
partyMember (2.PartyMember2&
ext.Base� (2.GetPartyMemberRs"6
GetPartyHallRq2$
ext.Base� (2.GetPartyHallRq"Y
GetPartyHallRs!
partyDonate (2.PartyDonate2$
ext.Base� (2.GetPartyHallRs"<
GetPartyScienceRq2'
ext.Base� (2.GetPartyScienceRq"z
GetPartyScienceRs!
partyDonate (2.PartyDonate
science (2.Science2'
ext.Base� (2.GetPartyScienceRs"6
GetPartyWealRq2$
ext.Base� (2.GetPartyWealRq"�
GetPartyWealRs
everWeal (
live (
resource (2.Weal
getResource (2.Weal
liveTask (2	.LiveTask2$
ext.Base� (2.GetPartyWealRs"T
GetPartyTrendRq
page (
type (2%
ext.Base� (2.GetPartyTrendRq"O
GetPartyTrendRs
trend (2.Trend2%
ext.Base� (2.GetPartyTrendRs"6
GetPartyShopRq2$
ext.Base� (2.GetPartyShopRq"U
GetPartyShopRs
	partyProp (2
.PartyProp2$
ext.Base� (2.GetPartyShopRs"G
DonatePartyRq
	resouceId (2#
ext.Base� (2.DonatePartyRq"�
DonatePartyRs
stone (
iron (
silicon (
copper (
oil (
gold (
isBuild (2#
ext.Base� (2.DonatePartyRs"P
UpPartyBuildingRq

buildingId (2'
ext.Base� (2.UpPartyBuildingRq"d
UpPartyBuildingRs

buildingId (

buildingLv (2'
ext.Base� (2.UpPartyBuildingRs"|
SetPartyJobRq
jobName1 (	
jobName2 (	
jobName3 (	
jobName4 (	2#
ext.Base� (2.SetPartyJobRq"4
SetPartyJobRs2#
ext.Base� (2.SetPartyJobRs"E
BuyPartyShopRq
keyId (2$
ext.Base� (2.BuyPartyShopRq"M
BuyPartyShopRs
award (2.Award2$
ext.Base� (2.BuyPartyShopRs"D
WealDayPartyRq
type (2$
ext.Base� (2.WealDayPartyRq"�
WealDayPartyRs
award (2.Award
stone (
iron (
silicon (
copper (
oil (2$
ext.Base� (2.WealDayPartyRs":
PartyApplyListRq2&
ext.Base� (2.PartyApplyListRq"[
PartyApplyListRs

partyApply (2.PartyApply2&
ext.Base� (2.PartyApplyListRs"C
PartyApplyRq
partyId (2"
ext.Base� (2.PartyApplyRq"2
PartyApplyRs2"
ext.Base� (2.PartyApplyRs"[
PartyApplyJudgeRq
lordId (
judge (2'
ext.Base� (2.PartyApplyJudgeRq"<
PartyApplyJudgeRs2'
ext.Base� (2.PartyApplyJudgeRs"h
CreatePartyRq
	partyName (	
type (
	applyType (2#
ext.Base� (2.CreatePartyRq"�
CreatePartyRs
party (2.Party
stone (
iron (
silicon (
copper (
oil (
gold (2#
ext.Base� (2.CreatePartyRs"0
QuitPartyRq2!
ext.Base� (2.QuitPartyRq"0
QuitPartyRs2!
ext.Base� (2.QuitPartyRs"^
DonateScienceRq
	scienceId (
	resouceId (2%
ext.Base� (2.DonateScienceRq"�
DonateScienceRs
science (2.Science
stone (
iron (
silicon (
copper (
oil (
gold (2%
ext.Base� (2.DonateScienceRs"f
WealResourcePartyRq
	scienceId (
	resouceId (2)
ext.Base� (2.WealResourcePartyRq"@
WealResourcePartyRs2)
ext.Base� (2.WealResourcePartyRs"E
CannlyApplyRq
partyId (2#
ext.Base� (2.CannlyApplyRq"4
CannlyApplyRs2#
ext.Base� (2.CannlyApplyRs"0
ApplyListRq2!
ext.Base� (2.ApplyListRq"A
ApplyListRs
partyId (2!
ext.Base� (2.ApplyListRs"E
SeachPartyRq
	partyName (	2"
ext.Base� (2.SeachPartyRq"Q
SeachPartyRs
	partyRank (2
.PartyRank2"
ext.Base� (2.SeachPartyRs">
DoneGuideRq
step (2!
ext.Base� (2.DoneGuideRq"=
DoneGuideRs
pos (2!
ext.Base� (2.DoneGuideRs"8
GetMapRq
area (2
ext.Base� (2	.GetMapRq"�
GetMapRs
data (2.MapData
	partyMine (2
.PartyMine 
mineInfo (2.WorldMineInfo(
freeTimeInfo (2.WorldFreeTimeInfo
area (2
ext.Base� (2	.GetMapRs";

ScoutPosRq
pos (2 
ext.Base� (2.ScoutPosRq"g

ScoutPosRs
mail (2.Mail
cdTime (

scoutCount (2 
ext.Base� (2.ScoutPosRs"R
AttackPosRq
pos (
form (2.Form2!
ext.Base� (2.AttackPosRq"E
AttackPosRs
army (2.Army2!
ext.Base� (2.AttackPosRs"I

MoveHomeRq
type (
pos (2 
ext.Base� (2.MoveHomeRq"X

MoveHomeRs
pos (
gold (
count (2 
ext.Base� (2.MoveHomeRs";
	RetreatRq
keyId (2
ext.Base� (2
.RetreatRq"i
	RetreatRs
atom2 (2.Atom2

honourGold (
heroGold (2
ext.Base� (2
.RetreatRs",
	GetSignRq2
ext.Base� (2
.GetSignRq"\
	GetSignRs
logins (
signs (
display (2
ext.Base� (2
.GetSignRs"6
SignRq
signId (2
ext.Base� (2.SignRq"=
SignRs
award (2.Award2
ext.Base� (2.SignRs"6
GetMajorTaskRq2$
ext.Base� (2.GetMajorTaskRq"K
GetMajorTaskRs
task (2.Task2$
ext.Base� (2.GetMajorTaskRs"S
TaskAwardRq
taskId (
	awardType (2!
ext.Base� (2.TaskAwardRq"\
TaskAwardRs
award (2.Award
task (2.Task2!
ext.Base� (2.TaskAwardRs"R
SloganPartyRq
type (
slogan (	2#
ext.Base� (2.SloganPartyRq"4
SloganPartyRs2#
ext.Base� (2.SloganPartyRs"A
UpMemberJobRq
job (2#
ext.Base� (2.UpMemberJobRq"A
UpMemberJobRs
job (2#
ext.Base� (2.UpMemberJobRs"D
CleanMemberRq
lordId (2#
ext.Base� (2.CleanMemberRq"4
CleanMemberRs2#
ext.Base� (2.CleanMemberRs"B
ConcedeJobRq
lordId (2"
ext.Base� (2.ConcedeJobRq"2
ConcedeJobRs2"
ext.Base� (2.ConcedeJobRs"S
SetMemberJobRq
lordId (
job (2$
ext.Base� (2.SetMemberJobRq"C
SetMemberJobRs
job (2$
ext.Base� (2.SetMemberJobRs"8
PartyJobCountRq2%
ext.Base� (2.PartyJobCountRq"�
PartyJobCountRs
job1 (
job2 (
job3 (
job4 (
	cpLegatus (2%
ext.Base� (2.PartyJobCountRs"}
PartyApplyEditRq
	applyType (
applyLv (
fight (
slogan (	2&
ext.Base� (2.PartyApplyEditRq":
PartyApplyEditRs2&
ext.Base� (2.PartyApplyEditRs":
GetPartyCombatRq2&
ext.Base� (2.GetPartyCombatRq"~
GetPartyCombatRs!
partyCombat (2.PartyCombat
count (
getAward (2&
ext.Base� (2.GetPartyCombatRs"_
DoPartyCombatRq
combatId (
form (2.Form2%
ext.Base� (2.DoPartyCombatRq"�
DoPartyCombatRs!
partyCombat (2.PartyCombat
award (2.Award
exp (
build (
result (
record (2.Record2%
ext.Base� (2.DoPartyCombatRs"H
PartyctAwardRq
combatId (2$
ext.Base� (2.PartyctAwardRq"M
PartyctAwardRs
award (2.Award2$
ext.Base� (2.PartyctAwardRs"B
GetMailListRq
type (2#
ext.Base� (2.GetMailListRq"Q
GetMailListRs
mailShow (2	.MailShow2#
ext.Base� (2.GetMailListRs"Q
GetMailByIdRq
keyId (
type (2#
ext.Base� (2.GetMailByIdRq"^
GetMailByIdRs
mail (2.Mail
friendState (2#
ext.Base� (2.GetMailByIdRs"4
GetInvasionRq2#
ext.Base� (2.GetInvasionRq"Q
GetInvasionRs
invasion (2	.Invasion2#
ext.Base� (2.GetInvasionRs"*
GetAidRq2
ext.Base� (2	.GetAidRq"=
GetAidRs
aid (2.Aid2
ext.Base� (2	.GetAidRs"M

SetGuardRq
lordId (
keyId (2 
ext.Base� (2.SetGuardRq".

SetGuardRs2 
ext.Base� (2.SetGuardRs"P

GuardPosRq
pos (
form (2.Form2 
ext.Base� (2.GuardPosRq"C

GuardPosRs
army (2.Army2 
ext.Base� (2.GuardPosRs",
	GetChatRq2
ext.Base� (2
.GetChatRq"A
	GetChatRs
chat (2.Chat2
ext.Base� (2
.GetChatRs"k
DoChatRq
channel (
	shareType (
target (
msg (	2
ext.Base� (2	.DoChatRq"*
DoChatRs2
ext.Base� (2	.DoChatRs"[
	SynChatRq
chat (2.Chat
screenPlayerName (	2
ext.Base� (2
.SynChatRq"6
GetDayiyTaskRq2$
ext.Base� (2.GetDayiyTaskRq"j
GetDayiyTaskRs
	taskDayiy (2
.TaskDayiy
task (2.Task2$
ext.Base� (2.GetDayiyTaskRs"4
GetLiveTaskRq2#
ext.Base� (2.GetLiveTaskRq"w
GetLiveTaskRs
taskLive (2	.TaskLive
task (2.Task
endTime (2#
ext.Base� (2.GetLiveTaskRs"B
AcceptTaskRq
taskId (2"
ext.Base� (2.AcceptTaskRq"2
AcceptTaskRs2"
ext.Base� (2.AcceptTaskRs"6
AcceptNoTaskRq2$
ext.Base� (2.AcceptNoTaskRq"6
AcceptNoTaskRs2$
ext.Base� (2.AcceptNoTaskRs"<

SearchOlRq
name (	2 
ext.Base� (2.SearchOlRq"A

SearchOlRs
man (2.Man2 
ext.Base� (2.SearchOlRs"Q
GetReportRq
name (	
	reportKey (2!
ext.Base� (2.GetReportRq"X
GetReportRs
report (2.Report
state (2!
ext.Base� (2.GetReportRs"�
ShareReportRq
channel (
	reportKey (
tankData (2	.TankData
heroId (
	medalData (2
.MedalData
awakenHeroKeyId (2#
ext.Base� (2.ShareReportRq"4
ShareReportRs2#
ext.Base� (2.ShareReportRs"I
TaskLiveAwardRq
awardId (2%
ext.Base� (2.TaskLiveAwardRq"l
TaskLiveAwardRs
award (2.Award
taskLive (2	.TaskLive2%
ext.Base� (2.TaskLiveAwardRs":
TaskDaylyResetRq2&
ext.Base� (2.TaskDaylyResetRq":
TaskDaylyResetRs2&
ext.Base� (2.TaskDaylyResetRs">
RefreshDayiyTaskRq2(
ext.Base� (2.RefreshDayiyTaskRq"r
RefreshDayiyTaskRs
	taskDayiy (2
.TaskDayiy
task (2.Task2(
ext.Base� (2.RefreshDayiyTaskRs"Q
RetreatAidRq
lordId (
keyId (2"
ext.Base� (2.RetreatAidRq"2
RetreatAidRs2"
ext.Base� (2.RetreatAidRs"E
GetExtremeRq
	extremeId (2"
ext.Base� (2.GetExtremeRq"d
GetExtremeRs
first (2.Extreme
last3 (2.Extreme2"
ext.Base� (2.GetExtremeRs"Z
ExtremeRecordRq
	extremeId (
which (2%
ext.Base� (2.ExtremeRecordRq"Q
ExtremeRecordRs
record (2.Record2%
ext.Base� (2.ExtremeRecordRs"^
	SetDataRq
type (
value (
form (2.Form2
ext.Base� (2
.SetDataRq",
	SetDataRs2
ext.Base� (2
.SetDataRs":
NewGetLiveTaskRq2&
ext.Base�- (2.NewGetLiveTaskRq"�
NewGetLiveTaskRs
taskLive (2	.TaskLive
task (2.Task
endTime (
states (2&
ext.Base�- (2.NewGetLiveTaskRs"O
NewTaskLiveAwardRq
awardId (2(
ext.Base�- (2.NewTaskLiveAwardRq"�
NewTaskLiveAwardRs
award (2.Award
taskLive (2	.TaskLive
states (2(
ext.Base�- (2.NewTaskLiveAwardRs"E
	SynMailRq
show (2	.MailShow2
ext.Base� (2
.SynMailRq"Q
SynInvasionRq
invasion (2	.Invasion2#
ext.Base� (2.SynInvasionRq">
	PtcFormRq
combatId (2
ext.Base� (2
.PtcFormRq"P
	PtcFormRs
state (
form (2.Form2
ext.Base� (2
.PtcFormRs"0
BeginWipeRq2!
ext.Base� (2.BeginWipeRq"0
BeginWipeRs2!
ext.Base� (2.BeginWipeRs",
	EndWipeRq2
ext.Base� (2
.EndWipeRq"U
	EndWipeRs
combatId (
award (2.Award2
ext.Base� (2
.EndWipeRs"6
GetGuideGiftRq2$
ext.Base� (2.GetGuideGiftRq"`
GetGuideGiftRs
award (2.Award
	newerGift (2$
ext.Base� (2.GetGuideGiftRs"H
	GetRankRq
type (
page (2
ext.Base� (2
.GetRankRq"i
	GetRankRs
rank (
rankData (2	.RankData
maxFight (2
ext.Base� (2
.GetRankRs">
GetPartyLiveRankRq2(
ext.Base� (2.GetPartyLiveRankRq"]
GetPartyLiveRankRs
	partyLive (2
.PartyLive2(
ext.Base� (2.GetPartyLiveRankRs"E
SynPartyOutRq
partyId (2#
ext.Base� (2.SynPartyOutRq"[
SynPartyAcceptRq
partyId (
accept (2&
ext.Base� (2.SynPartyAcceptRq"F
SetPortraitRq
portrait (2#
ext.Base� (2.SetPortraitRq"4
SetPortraitRs2#
ext.Base� (2.SetPortraitRs"@
GetLotteryExploreRq2)
ext.Base� (2.GetLotteryExploreRq"o
GetLotteryExploreRs

singleFree (
lottery (2.Lottery2)
ext.Base� (2.GetLotteryExploreRs"6
PartyRecruitRq2$
ext.Base� (2.PartyRecruitRq"6
PartyRecruitRs2$
ext.Base� (2.PartyRecruitRs".

BuyBuildRq2 
ext.Base� (2.BuyBuildRq"<

BuyBuildRs
gold (2 
ext.Base� (2.BuyBuildRs"A

SynBlessRq
man (2.Man2 
ext.Base� (2.SynBlessRq"K
	SynArmyRq
	armyStatu (2
.ArmyStatu2
ext.Base� (2
.SynArmyRq"<
GetActivityListRq2'
ext.Base� (2.GetActivityListRq"Y
GetActivityListRs
activity (2	.Activity2'
ext.Base� (2.GetActivityListRs"a
GetActivityAwardRq

activityId (
keyId (2(
ext.Base� (2.GetActivityAwardRq"U
GetActivityAwardRs
award (2.Award2(
ext.Base� (2.GetActivityAwardRs".

ActLevelRq2 
ext.Base� (2.ActLevelRq"S

ActLevelRs#
activityCond (2.ActivityCond2 
ext.Base� (2.ActLevelRs"D
ActAttackRq

activityId (2!
ext.Base� (2.ActAttackRq"d
ActAttackRs
state (#
activityCond (2.ActivityCond2!
ext.Base� (2.ActAttackRs".

ActFightRq2 
ext.Base� (2.ActFightRq"b

ActFightRs
state (#
activityCond (2.ActivityCond2 
ext.Base� (2.ActFightRs"0
ActCombatRq2!
ext.Base� (2.ActCombatRq"d
ActCombatRs
state (#
activityCond (2.ActivityCond2!
ext.Base� (2.ActCombatRs"0
ActHonourRq2!
ext.Base� (2.ActHonourRq"d
ActHonourRs
state (#
activityCond (2.ActivityCond2!
ext.Base� (2.ActHonourRs"<

GiftCodeRq
code (	2 
ext.Base� (2.GiftCodeRq"T

GiftCodeRs
award (2.Award
state (2 
ext.Base� (2.GiftCodeRs"2
ActPartyLvRq2"
ext.Base� (2.ActPartyLvRq"f
ActPartyLvRs
state (#
activityCond (2.ActivityCond2"
ext.Base� (2.ActPartyLvRs":
ActPartyDonateRq2&
ext.Base� (2.ActPartyDonateRq"�
ActPartyDonateRs 
hallResource (2
.CondState
hallGold (2
.CondState#
scienceResource (2
.CondState
scienceGold (2
.CondState2&
ext.Base� (2.ActPartyDonateRs"2
ActCollectRq2"
ext.Base� (2.ActCollectRq"�
ActCollectRs
stone (2
.CondState
iron (2
.CondState
oil (2
.CondState
copper (2
.CondState
silicon (2
.CondState2"
ext.Base� (2.ActCollectRs":
ActCombatSkillRq2&
ext.Base� (2.ActCombatSkillRq"n
ActCombatSkillRs
state (#
activityCond (2.ActivityCond2&
ext.Base� (2.ActCombatSkillRs"8
ActPartyFightRq2%
ext.Base� (2.ActPartyFightRq"l
ActPartyFightRs
state (#
activityCond (2.ActivityCond2%
ext.Base� (2.ActPartyFightRs"<
GetActionCenterRq2'
ext.Base� (2.GetActionCenterRq"Y
GetActionCenterRs
activity (2	.Activity2'
ext.Base� (2.GetActionCenterRs"4
GetActMechaRq2#
ext.Base� (2.GetActMechaRq"k
GetActMechaRs
mechaSingle (2.Mecha
mechaTen (2.Mecha2#
ext.Base� (2.GetActMechaRs"C
DoActMechaRq
mechaId (2"
ext.Base� (2.DoActMechaRq"Y
DoActMechaRs
crit (
twoInt (2.TwoInt2"
ext.Base� (2.DoActMechaRs"I
AssembleMechaRq
mechaId (2%
ext.Base� (2.AssembleMechaRq"O
AssembleMechaRs
award (2.Award2%
ext.Base� (2.AssembleMechaRs",
	OlAwardRq2
ext.Base� (2
.OlAwardRq"O
	OlAwardRs

id (
award (2.Award2
ext.Base� (2
.OlAwardRs"D
ActInvestRq

activityId (2!
ext.Base� (2.ActInvestRq"d
ActInvestRs
state (#
activityCond (2.ActivityCond2!
ext.Base� (2.ActInvestRs"B

DoInvestRq

activityId (2 
ext.Base� (2.DoInvestRq"<

DoInvestRs
gold (2 
ext.Base� (2.DoInvestRs"8
ActPayRedGiftRq2%
ext.Base� (2.ActPayRedGiftRq"l
ActPayRedGiftRs
state (#
activityCond (2.ActivityCond2%
ext.Base� (2.ActPayRedGiftRs":
ActEveryDayPayRq2&
ext.Base� (2.ActEveryDayPayRq"n
ActEveryDayPayRs
state (#
activityCond (2.ActivityCond2&
ext.Base� (2.ActEveryDayPayRs"4
ActPayFirstRq2#
ext.Base� (2.ActPayFirstRq"h
ActPayFirstRs
state (#
activityCond (2.ActivityCond2#
ext.Base� (2.ActPayFirstRs".

ActQuotaRq2 
ext.Base� (2.ActQuotaRq"E

ActQuotaRs
quota (2.Quota2 
ext.Base� (2.ActQuotaRs"Q
	DoQuotaRq
quotaId (

activityId (2
ext.Base� (2
.DoQuotaRq"Q
	DoQuotaRs
award (2.Award
gold (2
ext.Base� (2
.DoQuotaRs"|
	SynGoldRq
gold (
addGold (
addTopup (
vip (
serialId (	2
ext.Base� (2
.SynGoldRq">
ActPurpleEqpCollRq2(
ext.Base� (2.ActPurpleEqpCollRq"c
ActPurpleEqpCollRs#
activityCond (2.ActivityCond2(
ext.Base� (2.ActPurpleEqpCollRs":
ActPurpleEqpUpRq2&
ext.Base� (2.ActPurpleEqpUpRq"Y
ActPurpleEqpUpRs
	condState (2
.CondState2&
ext.Base� (2.ActPurpleEqpUpRs"8
ActCrazyArenaRq2%
ext.Base� (2.ActCrazyArenaRq"l
ActCrazyArenaRs
state (#
activityCond (2.ActivityCond2%
ext.Base� (2.ActCrazyArenaRs"<
ActCrazyUpgradeRq2'
ext.Base� (2.ActCrazyUpgradeRq"[
ActCrazyUpgradeRs
	condState (2
.CondState2'
ext.Base� (2.ActCrazyUpgradeRs"8
ActPartEvolveRq2%
ext.Base� (2.ActPartEvolveRq"O
ActPartEvolveRs
quota (2.Quota2%
ext.Base� (2.ActPartEvolveRs"6
ActFlashSaleRq2$
ext.Base� (2.ActFlashSaleRq"M
ActFlashSaleRs
quota (2.Quota2$
ext.Base� (2.ActFlashSaleRs"H
ActCostGoldRq

activityId (2#
ext.Base� (2.ActCostGoldRq"h
ActCostGoldRs
state (#
activityCond (2.ActivityCond2#
ext.Base� (2.ActCostGoldRs"4
ActContuPayRq2#
ext.Base� (2.ActContuPayRq"h
ActContuPayRs
state (#
activityCond (2.ActivityCond2#
ext.Base� (2.ActContuPayRs"6
ActFlashMetaRq2$
ext.Base� (2.ActFlashMetaRq"M
ActFlashMetaRs
quota (2.Quota2$
ext.Base� (2.ActFlashMetaRs"0
ActDayPayRq2!
ext.Base� (2.ActDayPayRq"d
ActDayPayRs
state (#
activityCond (2.ActivityCond2!
ext.Base� (2.ActDayPayRs"0
ActDayBuyRq2!
ext.Base� (2.ActDayBuyRq"G
ActDayBuyRs
quota (2.Quota2!
ext.Base� (2.ActDayBuyRs"B

SynApplyRq

applyCount (2 
ext.Base� (2.SynApplyRq"H
GetPartyLvRankRq
page (2&
ext.Base� (2.GetPartyLvRankRq"z
GetPartyLvRankRs
party (2.PartyLvRank!
partyLvRank (2.PartyLvRank2&
ext.Base� (2.GetPartyLvRankRs"6
ActMonthSaleRq2$
ext.Base� (2.ActMonthSaleRq"M
ActMonthSaleRs
quota (2.Quota2$
ext.Base� (2.ActMonthSaleRs"0
ActGiftOLRq2!
ext.Base� (2.ActGiftOLRq"d
ActGiftOLRs
state (#
activityCond (2.ActivityCond2!
ext.Base� (2.ActGiftOLRs"8
ActMonthLoginRq2%
ext.Base� (2.ActMonthLoginRq"l
ActMonthLoginRs
state (#
activityCond (2.ActivityCond2%
ext.Base� (2.ActMonthLoginRs"P
GetActAmyRebateRq

activityId (2'
ext.Base� (2.GetActAmyRebateRq"[
GetActAmyRebateRs
	amyRebate (2
.AmyRebate2'
ext.Base� (2.GetActAmyRebateRs"V
GetActAmyfestivityRq

activityId (2*
ext.Base� (2.GetActAmyfestivityRq"v
GetActAmyfestivityRs
state (#
activityCond (2.ActivityCond2*
ext.Base� (2.GetActAmyfestivityRs"`
DoActAmyRebateRq
rebateId (

activityId (2&
ext.Base� (2.DoActAmyRebateRq"_
DoActAmyRebateRs
gold (
award (2.Award2&
ext.Base� (2.DoActAmyRebateRs"c
DoActAmyfestivityRq
keyId (

activityId (2)
ext.Base� (2.DoActAmyfestivityRq"W
DoActAmyfestivityRs
award (2.Award2)
ext.Base� (2.DoActAmyfestivityRs"8
GetActFortuneRq2%
ext.Base� (2.GetActFortuneRq"�
GetActFortuneRs
score (
fortune (2.Fortune
free (
displayList (	2%
ext.Base� (2.GetActFortuneRs"@
GetActFortuneRankRq2)
ext.Base� (2.GetActFortuneRankRq"�
GetActFortuneRankRs
score (%
actPlayerRank (2.ActPlayerRank
open (
	rankAward (2
.RankAward
status (2)
ext.Base� (2.GetActFortuneRankRs"I
DoActFortuneRq
	fortuneId (2$
ext.Base� (2.DoActFortuneRq"\
DoActFortuneRs
score (
award (2.Award2$
ext.Base� (2.DoActFortuneRs"\
GetRankAwardRq

activityId (
rankType (2$
ext.Base� (2.GetRankAwardRq"M
GetRankAwardRs
award (2.Award2$
ext.Base� (2.GetRankAwardRs"D
GetActBeeRq

activityId (2!
ext.Base� (2.GetActBeeRq"�
GetActBeeRs
stone (2
.CondState
iron (2
.CondState
oil (2
.CondState
copper (2
.CondState
silicon (2
.CondState2!
ext.Base� (2.GetActBeeRs"L
GetActBeeRankRq

activityId (2%
ext.Base� (2.GetActBeeRankRq"�
GetActBeeRankRs
open (
beeRank (2.BeeRank
	rankAward (2
.RankAward2%
ext.Base� (2.GetActBeeRankRs"d
GetRankAwardListRq

activityId (
rankType (2(
ext.Base� (2.GetRankAwardListRq"k
GetRankAwardListRs
open (
	rankAward (2
.RankAward2(
ext.Base� (2.GetRankAwardListRs".

EveLoginRq2 
ext.Base� (2.EveLoginRq"_

EveLoginRs
display (
accept (
logins (2 
ext.Base� (2.EveLoginRs":
AcceptEveLoginRq2&
ext.Base� (2.AcceptEveLoginRq"a
AcceptEveLoginRs
logins (
award (2.Award2&
ext.Base� (2.AcceptEveLoginRs"8
GetActProfotoRq2%
ext.Base� (2.GetActProfotoRq"�
GetActProfotoRs
profoto (2.Profoto
trust (2.Profoto
parts (2.Profoto2%
ext.Base� (2.GetActProfotoRs"7
DoActProfotoRq2%
ext.Base� (2.GetActProfotoRq"f
DoActProfotoRs
award (2.Award
parts (2.Profoto2$
ext.Base� (2.DoActProfotoRs"8
UnfoldProfotoRq2%
ext.Base� (2.UnfoldProfotoRq"�
UnfoldProfotoRs
award (2.Award
profoto (2.Profoto
trust (2.Profoto2%
ext.Base� (2.UnfoldProfotoRs":
GetActPartDialRq2&
ext.Base� (2.GetActPartDialRq"�
GetActPartDialRs
score (
fortune (2.Fortune
free (
displayList (	2&
ext.Base� (2.GetActPartDialRs"B
GetActPartDialRankRq2*
ext.Base� (2.GetActPartDialRankRq"�
GetActPartDialRankRs
score (
open (
status (%
actPlayerRank (2.ActPlayerRank
	rankAward (2
.RankAward2*
ext.Base� (2.GetActPartDialRankRs"K
DoActPartDialRq
	fortuneId (2%
ext.Base� (2.DoActPartDialRq"^
DoActPartDialRs
score (
award (2.Award2%
ext.Base� (2.DoActPartDialRs"6
ActEnemySaleRq2$
ext.Base� (2.ActEnemySaleRq"M
ActEnemySaleRs
quota (2.Quota2$
ext.Base� (2.ActEnemySaleRs":
ActUpEquipCritRq2&
ext.Base� (2.ActUpEquipCritRq"Q
ActUpEquipCritRs
quota (2.Quota2&
ext.Base� (2.ActUpEquipCritRs"J
DoActTankRaffleRq
type (2'
ext.Base� (2.DoActTankRaffleRq"b
DoActTankRaffleRs
color (
award (2.Award2'
ext.Base� (2.DoActTankRaffleRs">
GetActTankRaffleRq2(
ext.Base� (2.GetActTankRaffleRq"L
GetActTankRaffleRs
free (2(
ext.Base� (2.GetActTankRaffleRs"N
WarRegRq
form (2.Form
fight (2
ext.Base� (2	.WarRegRq"N
WarRegRs
fight (
army (2.Army2
ext.Base� (2	.WarRegRs"2
WarMembersRq2"
ext.Base� (2.WarMembersRq"Q
WarMembersRs
	memberReg (2
.MemberReg2"
ext.Base� (2.WarMembersRs"@
WarPartiesRq
page (2"
ext.Base� (2.WarPartiesRq"^
WarPartiesRs
partyReg (2	.PartyReg
total (2"
ext.Base� (2.WarPartiesRs">
WarReportRq
type (2!
ext.Base� (2.WarReportRq"L
WarReportRs
record (2
.WarRecord2!
ext.Base� (2.WarReportRs"0
WarCancelRq2!
ext.Base� (2.WarCancelRq"0
WarCancelRs2!
ext.Base� (2.WarCancelRs"R
SynWarRecordRq
record (2
.WarRecord2$
ext.Base� (2.SynWarRecordRq"8
GetActDestroyRq2%
ext.Base� (2.GetActDestroyRq"Y
GetActDestroyRs
destoryTank (2
.CondState2%
ext.Base� (2.GetActDestroyRs"@
GetActDestroyRankRq2)
ext.Base� (2.GetActDestroyRankRq"�
GetActDestroyRankRs
score (
open (
status (%
actPlayerRank (2.ActPlayerRank
	rankAward (2
.RankAward2)
ext.Base� (2.GetActDestroyRankRs"8
ActReFristPayRq2%
ext.Base� (2.ActReFristPayRq"W
ActReFristPayRs
	condState (2
.CondState2%
ext.Base� (2.ActReFristPayRs"F
ActGiftPayRq

activityId (2"
ext.Base� (2.ActGiftPayRq"f
ActGiftPayRs
state (#
activityCond (2.ActivityCond2"
ext.Base� (2.ActGiftPayRs">
GetPartyAmyPropsRq2(
ext.Base� (2.GetPartyAmyPropsRq"S
GetPartyAmyPropsRs
prop (2.Prop2(
ext.Base� (2.GetPartyAmyPropsRs"c
SendPartyAmyPropRq
sendId (
prop (2.Prop2(
ext.Base� (2.SendPartyAmyPropRq"S
SendPartyAmyPropRs
prop (2.Prop2(
ext.Base� (2.SendPartyAmyPropRs"4
WarWinAwardRq2#
ext.Base� (2.WarWinAwardRq"K
WarWinAwardRs
award (2.Award2#
ext.Base� (2.WarWinAwardRs":
	WarRankRq
page (2
ext.Base� (2
.WarRankRq"d
	WarRankRs
warRank (2.WarRank
	selfParty (2.WarRank2
ext.Base� (2
.WarRankRs"2
WarWinRankRq2"
ext.Base� (2.WarWinRankRq"�
WarWinRankRs
winRank (2.WarWinRank
winCount (
canGet (
fight (2"
ext.Base� (2.WarWinRankRs"G
UseAmyPropRq
prop (2.Prop2"
ext.Base� (2.UseAmyPropRq"I
UseAmyPropRs
award (2.Award2"
ext.Base� (2.UseAmyPropRs"C
SynWarStateRq
state (2#
ext.Base� (2.SynWarStateRq"C
GetWarFightRq
index (2#
ext.Base� (2.GetWarFightRq"M
GetWarFightRs
rpt (2
.RptAtkWar2#
ext.Base� (2.GetWarFightRs"2
GetActTechRq2"
ext.Base� (2.GetActTechRq"G
GetActTechRs
tech (2.Tech2"
ext.Base� (2.GetActTechRs"@
DoActTechRq
techId (2!
ext.Base� (2.DoActTechRq"G
DoActTechRs
award (2.Award2!
ext.Base� (2.DoActTechRs"G
GetActGeneralRq
actId (2%
ext.Base� (2.GetActGeneralRq"
GetActGeneralRs
score (
general (2.General
count (
luck (2%
ext.Base� (2.GetActGeneralRs"X
DoActGeneralRq
	generalId (
actId (2$
ext.Base� (2.DoActGeneralRq"k
DoActGeneralRs
score (
award (2.Award
count (2$
ext.Base� (2.DoActGeneralRs"O
GetActGeneralRankRq
actId (2)
ext.Base� (2.GetActGeneralRankRq"�
GetActGeneralRankRs
open (
score (
status (%
actPlayerRank (2.ActPlayerRank
	rankAward (2
.RankAward2)
ext.Base� (2.GetActGeneralRankRs"2
ActVipGiftRq2"
ext.Base� (2.ActVipGiftRq"O
ActVipGiftRs
quotaVip (2	.QuotaVip2"
ext.Base� (2.ActVipGiftRs"6
ActPayContu4Rq2$
ext.Base� (2.ActPayContu4Rq"j
ActPayContu4Rs
state (#
activityCond (2.ActivityCond2$
ext.Base� (2.ActPayContu4Rs"<
DoPartyTipAwardRq2'
ext.Base� (2.DoPartyTipAwardRq"S
DoPartyTipAwardRs
award (2.Award2'
ext.Base� (2.DoPartyTipAwardRs"8
GetActEDayPayRq2%
ext.Base� (2.GetActEDayPayRq"m
GetActEDayPayRs
state (
	goldBoxId (
	propBoxId (2%
ext.Base� (2.GetActEDayPayRs"6
DoActEDayPayRq2$
ext.Base� (2.DoActEDayPayRq"M
DoActEDayPayRs
award (2.Award2$
ext.Base� (2.DoActEDayPayRs"C
DoActVipGiftRq
vip (2$
ext.Base� (2.DoActVipGiftRq"[
DoActVipGiftRs
award (2.Award
gold (2$
ext.Base� (2.DoActVipGiftRs",
	GetBossRq2
ext.Base� (2
.GetBossRq"�
	GetBossRs
cdTime (
hurtRank (
killer (	
	autoFight (
bless1 (
bless2 (
bless3 (
hurt (
which	 (
bossHp
 (
state (
	totalHurt (2
ext.Base� (2
.GetBossRs"<
GetBossHurtRankRq2'
ext.Base� (2.GetBossHurtRankRq"�
GetBossHurtRankRs
hurtRank (2	.HurtRank
hurt (
rank (
canGet (2'
ext.Base� (2.GetBossHurtRankRs"Q
SetBossAutoFightRq
	autoFight (2(
ext.Base� (2.SetBossAutoFightRq">
SetBossAutoFightRs2(
ext.Base� (2.SetBossAutoFightRs"I
BlessBossFightRq
index (2&
ext.Base� (2.BlessBossFightRq"T
BlessBossFightRs

lv (
gold (2&
ext.Base� (2.BlessBossFightRs"0
FightBossRq2!
ext.Base� (2.FightBossRq"�
FightBossRs
result (
record (2.Record
award (2.Award
coldTime (
hurt (
rank (
which (
bossHp (2!
ext.Base� (2.FightBossRs";
BuyBossCdRq	
s (2!
ext.Base� (2.BuyBossCdRq">
BuyBossCdRs
gold (2!
ext.Base� (2.BuyBossCdRs"8
BossHurtAwardRq2%
ext.Base� (2.BossHurtAwardRq"O
BossHurtAwardRs
award (2.Award2%
ext.Base� (2.BossHurtAwardRs"4
ComposeSantRq2#
ext.Base� (2.ComposeSantRq"K
ComposeSantRs
award (2.Award2#
ext.Base� (2.ComposeSantRs"
SynResourceRq
iron (
oil (
copper (
silicon (
stone (2#
ext.Base� (2.SynResourceRq"8
GetTipFriendsRq2%
ext.Base� (2.GetTipFriendsRq"K
GetTipFriendsRs
man (2.Man2%
ext.Base� (2.GetTipFriendsRs"H
AddTipFriendsRq
lordId (2%
ext.Base� (2.AddTipFriendsRq"8
AddTipFriendsRs2%
ext.Base� (2.AddTipFriendsRs"=
BuyArenaCdRq	
s (2"
ext.Base� (2.BuyArenaCdRq"@
BuyArenaCdRs
gold (2"
ext.Base� (2.BuyArenaCdRs"6
BuyAutoBuildRq2$
ext.Base� (2.BuyAutoBuildRq"Y
BuyAutoBuildRs
gold (
upBuildTime (2$
ext.Base� (2.BuyAutoBuildRs"E
SetAutoBuildRq
state (2$
ext.Base� (2.SetAutoBuildRq"\
SetAutoBuildRs
onBuild (
upBuildTime (2$
ext.Base� (2.SetAutoBuildRs"W

SynBuildRq
queue (2	.BuildQue
state (2 
ext.Base� (2.SynBuildRq"F
ActFesSaleRq

activityId (2"
ext.Base� (2.ActFesSaleRq"I
ActFesSaleRs
quota (2.Quota2"
ext.Base� (2.ActFesSaleRs"@
GetActConsumeDialRq2)
ext.Base� (2.GetActConsumeDialRq"�
GetActConsumeDialRs
score (
fortune (2.Fortune
free (
count (
displayList (	2)
ext.Base� (2.GetActConsumeDialRs"H
GetActConsumeDialRankRq2-
ext.Base� (2.GetActConsumeDialRankRq"�
GetActConsumeDialRankRs
score (
open (
status (%
actPlayerRank (2.ActPlayerRank
	rankAward (2
.RankAward2-
ext.Base� (2.GetActConsumeDialRankRs"Q
DoActConsumeDialRq
	fortuneId (2(
ext.Base� (2.DoActConsumeDialRq"d
DoActConsumeDialRs
score (
award (2.Award2(
ext.Base� (2.DoActConsumeDialRs"B
GetActVacationlandRq2*
ext.Base� (2.GetActVacationlandRq"�
GetActVacationlandRs
topup (
	villageId (
village (2.Village#
villageAward (2.VillageAward2*
ext.Base� (2.GetActVacationlandRs"U
BuyActVacationlandRq
	villageId (2*
ext.Base� (2.BuyActVacationlandRq"B
BuyActVacationlandRs2*
ext.Base� (2.BuyActVacationlandRs"P
DoActVacationlandRq
landId (2)
ext.Base� (2.DoActVacationlandRq"W
DoActVacationlandRs
award (2.Award2)
ext.Base� (2.DoActVacationlandRs":
GetActPartCashRq2&
ext.Base� (2.GetActPartCashRq"O
GetActPartCashRs
cash (2.Cash2&
ext.Base� (2.GetActPartCashRs"B
DoPartCashRq
cashId (2"
ext.Base� (2.DoPartCashRq"c
DoPartCashRs
award (2.Award
costList (2.Award2"
ext.Base� (2.DoPartCashRs"<
GetActEquipCashRq2'
ext.Base� (2.GetActEquipCashRq"Q
GetActEquipCashRs
cash (2.Cash2'
ext.Base� (2.GetActEquipCashRs"D
DoEquipCashRq
cashId (2#
ext.Base� (2.DoEquipCashRq"e
DoEquipCashRs
award (2.Award
costList (2.Award2#
ext.Base� (2.DoEquipCashRs"@
GetActPartResolveRq2)
ext.Base� (2.GetActPartResolveRq"r
GetActPartResolveRs
state (!
partResolve (2.PartResolve2)
ext.Base� (2.GetActPartResolveRs"Q
DoActPartResolveRq
	resolveId (2(
ext.Base� (2.DoActPartResolveRq"U
DoActPartResolveRs
award (2.Award2(
ext.Base� (2.DoActPartResolveRs"H
RefshPartCashRq
cashId (2%
ext.Base� (2.RefshPartCashRq"M
RefshPartCashRs
cash (2.Cash2%
ext.Base� (2.RefshPartCashRs"J
RefshEquipCashRq
cashId (2&
ext.Base� (2.RefshEquipCashRq"O
RefshEquipCashRs
cash (2.Cash2&
ext.Base� (2.RefshEquipCashRs"o
SynStaffingRq
staffing (

staffingLv (
staffingExp (2#
ext.Base� (2.SynStaffingRq"4
GetStaffingRq2#
ext.Base� (2.GetStaffingRq"V
GetStaffingRs
ranking (
worldLv (2#
ext.Base� (2.GetStaffingRs"6
GetActGambleRq2$
ext.Base� (2.GetActGambleRq"�
GetActGambleRs
topup (
count (
price (!
topupGamble (2.TopupGamble2$
ext.Base� (2.GetActGambleRs"4
DoActGambleRq2#
ext.Base� (2.DoActGambleRq"B
DoActGambleRs
gold (2#
ext.Base� (2.DoActGambleRs"B
GetActPayTurntableRq2*
ext.Base� (2.GetActPayTurntableRq"�
GetActPayTurntableRs
topup (
count (
paycount (!
topupGamble (2.TopupGamble2*
ext.Base� (2.GetActPayTurntableRs"O
DoActPayTurntableRq
count (2)
ext.Base� (2.DoActPayTurntableRq"W
DoActPayTurntableRs
award (2.Award2)
ext.Base� (2.DoActPayTurntableRs"6
GetSeniorMapRq2$
ext.Base� (2.GetSeniorMapRq"
GetSeniorMapRs
data (2.SeniorMapData
count (
limit (
buy (2$
ext.Base� (2.GetSeniorMapRs"h
AtkSeniorMineRq
pos (
form (2.Form
type (2%
ext.Base� (2.AtkSeniorMineRq"\
AtkSeniorMineRs
army (2.Army
count (2%
ext.Base� (2.AtkSeniorMineRs"E
SctSeniorMineRq
pos (2%
ext.Base� (2.SctSeniorMineRq"M
SctSeniorMineRs
mail (2.Mail2%
ext.Base� (2.SctSeniorMineRs"0
ScoreRankRq2!
ext.Base� (2.ScoreRankRq"|
ScoreRankRs
	scoreRank (2
.ScoreRank
score (
canGet (
rank (2!
ext.Base� (2.ScoreRankRs":
ScorePartyRankRq2&
ext.Base� (2.ScorePartyRankRq"�
ScorePartyRankRs
	scoreRank (2
.ScoreRank
score (
canGet (
rank (2&
ext.Base� (2.ScorePartyRankRs"0
BuySeniorRq2!
ext.Base� (2.BuySeniorRq"Z
BuySeniorRs
count (
gold (
buy (2!
ext.Base� (2.BuySeniorRs"2
ScoreAwardRq2"
ext.Base� (2.ScoreAwardRq"I
ScoreAwardRs
award (2.Award2"
ext.Base� (2.ScoreAwardRs"<
PartyScoreAwardRq2'
ext.Base� (2.PartyScoreAwardRq"S
PartyScoreAwardRs
award (2.Award2'
ext.Base� (2.PartyScoreAwardRs":
GetActCarnivalRq2&
ext.Base� (2.GetActCarnivalRq"�
GetActCarnivalRs
portrait (2
.CondState
payFrist (2
.CondState
payTopup (2
.CondState2&
ext.Base� (2.GetActCarnivalRs"2
GetActPrayRq2"
ext.Base� (2.GetActPrayRq"G
GetActPrayRs
pray (2.Pray2"
ext.Base� (2.GetActPrayRs"T
DoActPrayRq

prayCardId (
prayId (2!
ext.Base� (2.DoActPrayRq"E
DoActPrayRs
pray (2.Pray2!
ext.Base� (2.DoActPrayRs"T
ActPrayAwardRq
type (
prayId (2$
ext.Base� (2.ActPrayAwardRq"[
ActPrayAwardRs
gold (
award (2.Award2$
ext.Base� (2.ActPrayAwardRs"H
GetActPartyDonateRankRq2-
ext.Base� (2.GetActPartyDonateRankRq"�
GetActPartyDonateRankRs
party (2.ActPartyRank
open (
status (#
actPartyRank (2.ActPartyRank
	rankAward (2
.RankAward2-
ext.Base� (2.GetActPartyDonateRankRs"T
GetPartyRankAwardRq

activityId (2)
ext.Base� (2.GetPartyRankAwardRq"W
GetPartyRankAwardRs
award (2.Award2)
ext.Base� (2.GetPartyRankAwardRs"S
MultiHeroImproveRq
hero (2.Hero2(
ext.Base� (2.MultiHeroImproveRq"S
MultiHeroImproveRs
hero (2.Hero2(
ext.Base� (2.MultiHeroImproveRs"K
TipGuyRq
lordId (
chatMsg (	2
ext.Base� (2	.TipGuyRq":
TipGuyRs
result (2
ext.Base� (2	.TipGuyRs"Z

LockPartRq
keyId (
pos (
locked (2 
ext.Base� (2.LockPartRq">

LockPartRs
result (2 
ext.Base� (2.LockPartRs"<
GetActNewRaffleRq2'
ext.Base� (2.GetActNewRaffleRq"j
GetActNewRaffleRs
free (
tankId (
lockId (2'
ext.Base� (2.GetActNewRaffleRs"H
DoActNewRaffleRq
type (2&
ext.Base� (2.DoActNewRaffleRq"n
DoActNewRaffleRs
gold (
color (
award (2.Award2&
ext.Base� (2.DoActNewRaffleRs"H
LockNewRaffleRq
tankId (2%
ext.Base� (2.LockNewRaffleRq"H
LockNewRaffleRs
result (2%
ext.Base� (2.LockNewRaffleRs"B
GetMilitaryScienceRq2*
ext.Base� (2.GetMilitaryScienceRq"m
GetMilitaryScienceRs)
militaryScience (2.MilitaryScience2*
ext.Base� (2.GetMilitaryScienceRs"@
GetActTankExtractRq2)
ext.Base� (2.GetActTankExtractRq"�
GetActTankExtractRs!
tankExtract (2.TankExtract!
tankFormula (2.TankFormula
free (
commonAward (2.Award
seniorAward (2.Award2)
ext.Base� (2.GetActTankExtractRs"M
DoActTankExtractRq
price (2(
ext.Base� (2.DoActTankExtractRq"c
DoActTankExtractRs
gold (
award (2.Award2(
ext.Base� (2.DoActTankExtractRs"h
FormulaTankExtractRq
tankFormulaId (
count (2*
ext.Base� (2.FormulaTankExtractRq"l
FormulaTankExtractRs
grab (2.Grab
tank (2.Tank2*
ext.Base� (2.FormulaTankExtractRs"[
UpMilitaryScienceRq
militaryScienceId (2)
ext.Base� (2.UpMilitaryScienceRq"�
UpMilitaryScienceRs
militaryScienceId (
level (
atom2 (2.Atom22)
ext.Base� (2.UpMilitaryScienceRs"J
GetMilitaryScienceGridRq2.
ext.Base� (2.GetMilitaryScienceGridRq"}
GetMilitaryScienceGridRs1
militaryScienceGrid (2.MilitaryScienceGrid2.
ext.Base� (2.GetMilitaryScienceGridRs"z
FitMilitaryScienceRq
militaryScienceId (
tankId (
pos (2*
ext.Base� (2.FitMilitaryScienceRq"�
FitMilitaryScienceRs1
militaryScienceGrid (2.MilitaryScienceGrid)
militaryScience (2.MilitaryScience2*
ext.Base� (2.FitMilitaryScienceRs"_
MilitaryRefitTankRq
tankId (
count (2)
ext.Base� (2.MilitaryRefitTankRq"W
MilitaryRefitTankRs
atom2 (2.Atom22)
ext.Base� (2.MilitaryRefitTankRs"B
GetActTankCarnivalRq2*
ext.Base� (2.GetActTankCarnivalRq"}
GetActTankCarnivalRs
free (
row (2.Atom
equate (2.Equate2*
ext.Base� (2.GetActTankCarnivalRs"N
DoActTankCarnivalRq
fire (2)
ext.Base� (2.DoActTankCarnivalRq"l
DoActTankCarnivalRs
atom (2.Atom
award (2.Award2)
ext.Base� (2.DoActTankCarnivalRs"D
GetMilitaryMaterialRq2+
ext.Base� (2.GetMilitaryMaterialRq"q
GetMilitaryMaterialRs+
militaryMaterial (2.MilitaryMaterial2+
ext.Base� (2.GetMilitaryMaterialRs"R
UnLockMilitaryGridRq
tankId (2*
ext.Base� (2.UnLockMilitaryGridRq"�
UnLockMilitaryGridRs1
militaryScienceGrid (2.MilitaryScienceGrid
atom2 (2.Atom22*
ext.Base� (2.UnLockMilitaryGridRs"2
GetPendantRq2"
ext.Base� (2.GetPendantRq"j
GetPendantRs
pendant (2.Pendant
portrait (2	.Portrait2"
ext.Base� (2.GetPendantRs"J
GetFortressBattlePartyRq2.
ext.Base� (2.GetFortressBattlePartyRq"}
GetFortressBattlePartyRs1
fortressBattleParty (2.FortressBattleParty2.
ext.Base� (2.GetFortressBattlePartyRs"l
SetFortressBattleFormRq
form (2.Form
fight (2-
ext.Base� (2.SetFortressBattleFormRq"�
SetFortressBattleFormRs
fight (
army (2.Army
form (2.Form2-
ext.Base� (2.SetFortressBattleFormRs"L
GetFortressBattleDefendRq2/
ext.Base� (2.GetFortressBattleDefendRq"�
GetFortressBattleDefendRs#
fortressSelf (2.FortressSelf'
fortressDefend (2.FortressDefend
cdTime (2/
ext.Base� (2.GetFortressBattleDefendRs"b
FortressBattleRecordRq
type (
page (2,
ext.Base� (2.FortressBattleRecordRq"g
FortressBattleRecordRs
record (2.FortressRecord2,
ext.Base� (2.FortressBattleRecordRs"Y
SynFortressBattleStateRq
state (2.
ext.Base� (2.SynFortressBattleStateRq"D
BuyFortressBattleCdRq2+
ext.Base� (2.BuyFortressBattleCdRq"R
BuyFortressBattleCdRs
gold (2+
ext.Base� (2.BuyFortressBattleCdRs"_
AttackFortressRq
lordId (
form (2.Form2&
ext.Base� (2.AttackFortressRq"�
AttackFortressRs
record (2.FortressRecord'
rptAtkFortress (2.RptAtkFortress
coldTime (
tank (2.Tank2&
ext.Base� (2.AttackFortressRs"F
GetFortressPartyRankRq2,
ext.Base� (2.GetFortressPartyRankRq"�
GetFortressPartyRankRs-
fortressPartyRank (2.FortressPartyRank/
myFortressPartyRank (2.FortressPartyRank2,
ext.Base� (2.GetFortressPartyRankRs"b
GetFortressJiFenRankRq
page (
type (2,
ext.Base� (2.GetFortressJiFenRankRq"�
GetFortressJiFenRankRs-
fortressJiFenRank (2.FortressJiFenRank/
myFortressJiFenRank (2.FortressJiFenRank2,
ext.Base� (2.GetFortressJiFenRankRs"\
GetFortressCombatStaticsRq
type (20
ext.Base� (2.GetFortressCombatStaticsRq"�
GetFortressCombatStaticsRs
twoInt (2.TwoInt
fightNum (
winNum (20
ext.Base� (2.GetFortressCombatStaticsRs"]
GetFortressFightReportRq
	reportKey (2.
ext.Base� (2.GetFortressFightReportRq"s
GetFortressFightReportRs'
rptAtkFortress (2.RptAtkFortress2.
ext.Base� (2.GetFortressFightReportRs"<
GetFortressAttrRq2'
ext.Base� (2.GetFortressAttrRq"e
GetFortressAttrRs'
myFortressAttr (2.MyFortressAttr2'
ext.Base� (2.GetFortressAttrRs"F
UpFortressAttrRq

id (2&
ext.Base� (2.UpFortressAttrRq"c
UpFortressAttrRs

id (
level (
gold (2&
ext.Base� (2.UpFortressAttrRs">
GetFightValueAddRq2(
ext.Base� (2.GetFightValueAddRq"g
GetFightValueAddRs

isReceived (
receiveTime (2(
ext.Base� (2.GetFightValueAddRs"F
ReceiveFigthValueAddRq2,
ext.Base� (2.ReceiveFigthValueAddRq"]
ReceiveFigthValueAddRs
award (2.Award2,
ext.Base� (2.ReceiveFigthValueAddRs"D
GetNobilityAncestryRq2+
ext.Base� (2.GetNobilityAncestryRq"k
GetNobilityAncestryRs
status (
timeRemaining (2+
ext.Base� (2.GetNobilityAncestryRs"B
DoNobilityAncestryRq2*
ext.Base� (2.DoNobilityAncestryRq"r
DoNobilityAncestryRs
effect (2.Effect
timeRemaining (2*
ext.Base� (2.DoNobilityAncestryRs":
GetFortressJobRq2&
ext.Base� (2.GetFortressJobRq"]
GetFortressJobRs!
fortressJob (2.FortressJob2&
ext.Base� (2.GetFortressJobRs"Y
FortressAppointRq
jobId (
nick (	2'
ext.Base� (2.FortressAppointRq"<
FortressAppointRs2'
ext.Base� (2.FortressAppointRs"D
GetFortressWinPartyRq2+
ext.Base� (2.GetFortressWinPartyRq"h
GetFortressWinPartyRs
partyId (
	partyName (	2+
ext.Base� (2.GetFortressWinPartyRs">
GetMyFortressJobRq2(
ext.Base� (2.GetMyFortressJobRq"a
GetMyFortressJobRs!
fortressJob (2.FortressJob2(
ext.Base� (2.GetMyFortressJobRs"a
SynFortressSelfRq#
fortressSelf (2.FortressSelf2'
ext.Base� (2.SynFortressSelfRq"F
GetThisWeekMyWarJiFenRankRq2'
ext.Base� (2.SynFortressSelfRq"m
GetThisWeekMyWarJiFenRankRs
rank (
jifen (21
ext.Base� (2.GetThisWeekMyWarJiFenRankRs".

GetScoutRq2 
ext.Base� (2.GetScoutRq"=

GetScoutRs
scout (2 
ext.Base� (2.GetScoutRs"B
GetRoleEnergyStoneRq2*
ext.Base� (2.GetRoleEnergyStoneRq"W
GetRoleEnergyStoneRs
prop (2.Prop2*
ext.Base� (2.GetRoleEnergyStoneRs"D
GetEnergyStoneInlayRq2+
ext.Base� (2.GetEnergyStoneInlayRq"f
GetEnergyStoneInlayRs 
inlay (2.EnergyStoneInlay2+
ext.Base� (2.GetEnergyStoneInlayRs"q
CombineEnergyStoneRq
stoneId (
count (
batch (2*
ext.Base� (2.CombineEnergyStoneRq"V
CombineEnergyStoneRs

successNum (2*
ext.Base� (2.CombineEnergyStoneRs"d
OnEnergyStoneRq
pos (
hole (
stoneId (2%
ext.Base� (2.OnEnergyStoneRq"8
OnEnergyStoneRs2%
ext.Base� (2.OnEnergyStoneRs">
GetAltarBossDataRq2(
ext.Base� (2.GetAltarBossDataRq"�
GetAltarBossDataRs
nextStateTime (
hurtRank (
	autoFight (
bless1 (
bless2 (
bless3 (
hurt (
which (
bossHp	 (
state
 (
fightCdTime (
bossLv (2(
ext.Base� (2.GetAltarBossDataRs"F
GetAltarBossHurtRankRq2,
ext.Base� (2.GetAltarBossHurtRankRq"�
GetAltarBossHurtRankRs
hurtRank (2	.HurtRank
hurt (
rank (
canGet (2,
ext.Base� (2.GetAltarBossHurtRankRs"[
SetAltarBossAutoFightRq
	autoFight (2-
ext.Base� (2.SetAltarBossAutoFightRq"H
SetAltarBossAutoFightRs2-
ext.Base� (2.SetAltarBossAutoFightRs"S
BlessAltarBossFightRq
index (2+
ext.Base� (2.BlessAltarBossFightRq"^
BlessAltarBossFightRs

lv (
gold (2+
ext.Base� (2.BlessAltarBossFightRs"8
CallAltarBossRq2%
ext.Base� (2.CallAltarBossRq"�
CallAltarBossRs
state (
which (
bossLv (
bossHp (
nextStateTime (2%
ext.Base� (2.CallAltarBossRs":
BuyAltarBossCdRq2&
ext.Base� (2.BuyAltarBossCdRq"H
BuyAltarBossCdRs
gold (2&
ext.Base� (2.BuyAltarBossCdRs":
FightAltarBossRq2&
ext.Base� (2.FightAltarBossRq"�
FightAltarBossRs
result (
record (2.Record
cdTime (
hurt (
rank (
which (
bossHp (2&
ext.Base� (2.FightAltarBossRs"B
AltarBossHurtAwardRq2*
ext.Base� (2.AltarBossHurtAwardRq"Y
AltarBossHurtAwardRs
award (2.Award2*
ext.Base� (2.AltarBossHurtAwardRs"B
GetTreasureShopBuyRq2*
ext.Base� (2.GetTreasureShopBuyRq"w
GetTreasureShopBuyRs
openWeek (!
shopBuy (2.TreasureShopBuy2*
ext.Base� (2.GetTreasureShopBuyRs"_
BuyTreasureShopRq

treasureId (
count (2'
ext.Base� (2.BuyTreasureShopRq"N
BuyTreasureShopRs
huangbao (2'
ext.Base� (2.BuyTreasureShopRs"6
GetDrillDataRq2$
ext.Base� (2.GetDrillDataRq"�
GetDrillDataRs
status (
	enrollNum (
camp (
myArmy (
exploit (

isEnrolled (
redWin (

redExploit (
blueExploit	 (2$
ext.Base� (2.GetDrillDataRs"4
DrillEnrollRq2#
ext.Base� (2.DrillEnrollRq"4
DrillEnrollRs2#
ext.Base� (2.DrillEnrollRs"_
ExchangeDrillTankRq
tankId (
count (2)
ext.Base� (2.ExchangeDrillTankRq"_
ExchangeDrillTankRs
tankId (
count (2)
ext.Base� (2.ExchangeDrillTankRs"e
GetDrillRecordRq
type (
which (
page (2&
ext.Base� (2.GetDrillRecordRq"v
GetDrillRecordRs
result (2.DrillResult
record (2.DrillRecord2&
ext.Base� (2.GetDrillRecordRs"W
GetDrillFightReportRq
	reportKey (2+
ext.Base� (2.GetDrillFightReportRq"m
GetDrillFightReportRs'
rptAtkFortress (2.RptAtkFortress2+
ext.Base� (2.GetDrillFightReportRs"H
GetDrillRankRq
rankType (2$
ext.Base� (2.GetDrillRankRq"�
GetDrillRankRs
successCamp (
myCamp (
myRank (

successNum (
failNum (

canGetRank (

canGetPart (
ranks (2
.DrillRank
killTank	 (2.TwoInt

getExploit
 (2$
ext.Base� (2.GetDrillRankRs"H
DrillRewardRq

rewardType (2#
ext.Base� (2.DrillRewardRq"K
DrillRewardRs
award (2.Award2#
ext.Base� (2.DrillRewardRs"6
GetDrillShopRq2$
ext.Base� (2.GetDrillShopRq"j
GetDrillShopRs
buy (2.DrillShopBuy
treasureShopId (2$
ext.Base� (2.GetDrillShopRs"_
ExchangeDrillShopRq
shopId (
count (2)
ext.Base� (2.ExchangeDrillShopRq"p
ExchangeDrillShopRs
exploit (
shopId (
count (2)
ext.Base� (2.ExchangeDrillShopRs"<
GetDrillImproveRq2'
ext.Base� (2.GetDrillImproveRq"`
GetDrillImproveRs"
improve (2.DrillImproveInfo2'
ext.Base� (2.GetDrillImproveRs"F
DrillImproveRq
buffId (2$
ext.Base� (2.DrillImproveRq"Z
DrillImproveRs"
improve (2.DrillImproveInfo2$
ext.Base� (2.DrillImproveRs"6
GetDrillTankRq2$
ext.Base� (2.GetDrillTankRq"P
GetDrillTankRs
	drillTank (2.Tank2$
ext.Base� (2.GetDrillTankRs"6
GetPushStateRq2$
ext.Base� (2.GetPushStateRq"]
GetPushStateRs
state (
shouldPushTime (2$
ext.Base� (2.GetPushStateRs"J
PushCommentRq
commentState (2#
ext.Base� (2.PushCommentRq"[
PushCommentRs
state (
shouldPushTime (2#
ext.Base� (2.PushCommentRs"B
GetCrossServerListRq2*
ext.Base� (2.GetCrossServerListRq"k
GetCrossServerListRs'
gameServerInfo (2.GameServerInfo2*
ext.Base� (2.GetCrossServerListRs"B
GetCrossFightStateRq2*
ext.Base� (2.GetCrossFightStateRq"d
GetCrossFightStateRs
	beginTime (	
state (2*
ext.Base� (2.GetCrossFightStateRs"I
CrossFightRegRq
groupId (2%
ext.Base� (2.CrossFightRegRq"8
CrossFightRegRs2%
ext.Base� (2.CrossFightRegRs"<
GetCrossRegInfoRq2'
ext.Base� (2.GetCrossRegInfoRq"�
GetCrossRegInfoRs
jyGroupPlayerNum (
dfGroupPlayerNum (
myGroup (2'
ext.Base� (2.GetCrossRegInfoRs":
CancelCrossRegRq2&
ext.Base� (2.CancelCrossRegRq":
CancelCrossRegRs2&
ext.Base� (2.CancelCrossRegRs"6
GetCrossFormRq2$
ext.Base� (2.GetCrossFormRq"K
GetCrossFormRs
form (2.Form2$
ext.Base� (2.GetCrossFormRs"Z
SetCrossFormRq
form (2.Form
fight (2$
ext.Base� (2.SetCrossFormRq"Z
SetCrossFormRs
form (2.Form
fight (2$
ext.Base� (2.SetCrossFormRs"Z
GetCrossPersonSituationRq
page (2/
ext.Base� (2.GetCrossPersonSituationRq"o
GetCrossPersonSituationRs!
crossRecord (2.CrossRecord2/
ext.Base� (2.GetCrossPersonSituationRs"N
GetCrossJiFenRankRq
page (2)
ext.Base� (2.GetCrossJiFenRankRq"�
GetCrossJiFenRankRs'
crossJiFenRank (2.CrossJiFenRank
jifen (
myRank (2)
ext.Base� (2.GetCrossJiFenRankRs"M
GetCrossReportRq
	reportKey (2&
ext.Base� (2.GetCrossReportRq"]
GetCrossReportRs!
crossRptAtk (2.CrossRptAtk2&
ext.Base� (2.GetCrossReportRs"p
GetCrossKnockCompetInfoRq
groupId (
	groupType (2/
ext.Base� (2.GetCrossKnockCompetInfoRq"�
GetCrossKnockCompetInfoRs
groupId (
	groupType (1
knockoutCompetGroup (2.KnockoutCompetGroup2/
ext.Base� (2.GetCrossKnockCompetInfoRs"]
GetCrossFinalCompetInfoRq
groupId (2/
ext.Base� (2.GetCrossFinalCompetInfoRq"�
GetCrossFinalCompetInfoRs
groupId (+
finalCompetGroup (2.FinalCompetGroup2/
ext.Base� (2.GetCrossFinalCompetInfoRs"�
BetBattleRq
myGroup (
stage (
	groupType (
competGroupId (
pos (2!
ext.Base� (2.BetBattleRq"U
BetBattleRs
myBet (2.MyBet
gold (2!
ext.Base� (2.BetBattleRs".

GetMyBetRq2 
ext.Base� (2.GetMyBetRq"E

GetMyBetRs
myBet (2.MyBet2 
ext.Base� (2.GetMyBetRs"|
ReceiveBetRq
myGroup (
stage (
	groupType (
competGroupId (2"
ext.Base� (2.ReceiveBetRq"]
ReceiveBetRs

crossJifen (
myBet (2.MyBet2"
ext.Base� (2.ReceiveBetRs"6
GetCrossShopRq2$
ext.Base� (2.GetCrossShopRq"f
GetCrossShopRs

crossJifen (
buy (2.CrossShopBuy2$
ext.Base� (2.GetCrossShopRs"_
ExchangeCrossShopRq
shopId (
count (2)
ext.Base� (2.ExchangeCrossShopRq"�
ExchangeCrossShopRs

crossJifen (
shopId (
count (
restNum (2)
ext.Base� (2.ExchangeCrossShopRs"8
GetCrossTrendRq2%
ext.Base� (2.GetCrossTrendRq"m
GetCrossTrendRs

crossJifen (

crossTrend (2.CrossTrend2%
ext.Base� (2.GetCrossTrendRs"O
GetCrossFinalRankRq
group (2)
ext.Base� (2.GetCrossFinalRankRq"�
GetCrossFinalRankRs
group (#
crossTopRank (2.CrossTopRank
myRank (
state (
myJiFen (2)
ext.Base� (2.GetCrossFinalRankRs"M
ReceiveRankRwardRq
group (2(
ext.Base� (2.ReceiveRankRwardRq"d
ReceiveRankRwardRs
group (
award (2.Award2(
ext.Base� (2.ReceiveRankRwardRs"D
GetCrossRankRq
type (2$
ext.Base� (2.GetCrossRankRq"�
GetCrossRankRs%
crossFameInfo (2.CrossFameInfo

cpFameInfo (2.CPFameInfo

cdFameInfo (2.CDFameInfo2$
ext.Base� (2.GetCrossRankRs"6
GetRebelDataRq2$
ext.Base� (2.GetRebelDataRq"�
GetRebelDataRs
state (

changeTime (
killNum (
restUnit (
	restGuard (

restLeader (

unitRebels (2.Rebel
guardRebels (2.Rebel
leaderRebels	 (2.Rebel
restBoss
 (

bossRebels (2.Rebel2$
ext.Base� (2.GetRebelDataRs"V
GetRebelRankRq
rankType (
page (2$
ext.Base� (2.GetRebelRankRq"�
GetRebelRankRs
killUnit (
	killGuard (

killLeader (
score (
rank (
	getReward (
lastRank (

rebelRanks (2
.RebelRank2$
ext.Base� (2.GetRebelRankRs"O
RebelRankRewardRq
	awardType (2'
ext.Base� (2.RebelRankRewardRq"S
RebelRankRewardRs
award (2.Award2'
ext.Base� (2.RebelRankRewardRs"A
RebelIsDeadRq
pos (2#
ext.Base� (2.RebelIsDeadRq"Q
RebelIsDeadRs
pos (
isDead (2#
ext.Base� (2.RebelIsDeadRs"<
GetTankCarnivalRq2'
ext.Base� (2.GetTankCarnivalRq"M
GetTankCarnivalRs
freeNum (2'
ext.Base� (2.GetTankCarnivalRs"S
TankCarnivalRewardRq
allLine (2*
ext.Base� (2.TankCarnivalRewardRq"�
TankCarnivalRewardRs
allLine (
equateId ($
rewards (2.TankCarnivalReward2*
ext.Base� (2.TankCarnivalRewardRs">
GetPowerGiveDataRq2(
ext.Base� (2.GetPowerGiveDataRq"M
GetPowerGiveDataRs
state (2(
ext.Base� (2.GetPowerGiveDataRs"6
GetFreePowerRq2$
ext.Base� (2.GetFreePowerRq"N
GetFreePowerRs
reward (2.Award2$
ext.Base� (2.GetFreePowerRs"T
PartQualityUpRq
keyId (
pos (2%
ext.Base� (2.PartQualityUpRq"�
PartQualityUpRs
partId (
upLv (
refitLv (
atom2 (2.Atom2
smeltLv (
smeltExp (
award (2.Award2%
ext.Base� (2.PartQualityUpRs"\
SmeltPartRq
keyId (
pos (
option (2!
ext.Base� (2.SmeltPartRq"�
SmeltPartRs
smeltLv (
smeltExp (
attr (2.PartSmeltAttr
saved (
atom2 (2.Atom2
expMult (
krypton (2.Award2!
ext.Base� (2.SmeltPartRs"T
SaveSmeltPartRq
keyId (
pos (2%
ext.Base� (2.SaveSmeltPartRq"e
SaveSmeltPartRs
attr (2.PartSmeltAttr
saved (2%
ext.Base� (2.SaveSmeltPartRs"�
TenSmeltPartRq
keyId (
pos (
option (

saveAttrId (
times (2$
ext.Base� (2.TenSmeltPartRq"�
TenSmeltPartRs!
records (2.PartSmeltRecord 
result (2.PartSmeltRecord
smeltLv (
smeltExp (
attr (2.PartSmeltAttr
atom2 (2.Atom2
saved (
krypton (2.Award2$
ext.Base� (2.TenSmeltPartRs"G
SynCrossStateRq
state (2%
ext.Base� (2.SynCrossStateRq"D
GetCollectCharacterRq2+
ext.Base� (2.GetCollectCharacterRq"y
GetCollectCharacterRs
actProp (2.Atom2
	changeNum (2.TwoInt2+
ext.Base� (2.GetCollectCharacterRs"X
CollectCharacterCombineRq

id (2/
ext.Base� (2.CollectCharacterCombineRq"e
CollectCharacterCombineRs
actProp (2.Atom22/
ext.Base� (2.CollectCharacterCombineRs"V
CollectCharacterChangeRq

id (2.
ext.Base� (2.CollectCharacterChangeRq"�
CollectCharacterChangeRs
actProp (2.Atom2
	changeNum (2.TwoInt
award (2.Award2.
ext.Base� (2.CollectCharacterChangeRs"2
GetActM1a2Rq2"
ext.Base� (2.GetActM1a2Rq"C
GetActM1a2Rs
hasFree (2"
ext.Base� (2.GetActM1a2Rs"L
DoActM1a2Rq

id (
single (2!
ext.Base� (2.DoActM1a2Rq"f
DoActM1a2Rs
hasFree (
gold (
award (2.Award2!
ext.Base� (2.DoActM1a2Rs"W
M1a2RefitTankRq
tankId (
count (2%
ext.Base� (2.M1a2RefitTankRq"O
M1a2RefitTankRs
atom2 (2.Atom22%
ext.Base� (2.M1a2RefitTankRs"0
GetFlowerRq2!
ext.Base� (2.GetFlowerRq"e
GetFlowerRs
actProp (2.Atom2
	changeNum (2.TwoInt2!
ext.Base� (2.GetFlowerRs">
WishFlowerRq

id (2"
ext.Base� (2.WishFlowerRq"~
WishFlowerRs
actProp (2.Atom2
	changeNum (2.TwoInt
award (2.Award2"
ext.Base� (2.WishFlowerRs"h
AllEnergyStoneRq
pos (
holeAndStoneId (2.TwoInt2&
ext.Base� (2.AllEnergyStoneRq":
AllEnergyStoneRs2&
ext.Base� (2.AllEnergyStoneRs"V
EquipQualityUpRq
pos (
keyId (2&
ext.Base� (2.EquipQualityUpRq"{
EquipQualityUpRs
equipId (

lv (
exp (
atom2 (2.Atom22&
ext.Base� (2.EquipQualityUpRs"6
GetPayRebateRq2$
ext.Base� (2.GetPayRebateRq"U
GetPayRebateRs
	payRebate (2
.PayRebate2$
ext.Base� (2.GetPayRebateRs"4
DoPayRebateRq2#
ext.Base� (2.DoPayRebateRq"S
DoPayRebateRs
	payRebate (2
.PayRebate2#
ext.Base� (2.DoPayRebateRs">
GetPirateLotteryRq2(
ext.Base� (2.GetPirateLotteryRq"j
GetPirateLotteryRs
data (2.PirateData
awardId (2(
ext.Base� (2.GetPirateLotteryRs"J
DoPirateLotteryRq
type (2'
ext.Base� (2.DoPirateLotteryRq"}
DoPirateLotteryRs
data (2.PirateData
awards (2.Award
gold (2'
ext.Base� (2.DoPirateLotteryRs"B
ResetPirateLotteryRq2*
ext.Base� (2.ResetPirateLotteryRq"]
ResetPirateLotteryRs
data (2.PirateData2*
ext.Base� (2.ResetPirateLotteryRs".

GetMedalRq2 
ext.Base� (2.GetMedalRq"E

GetMedalRs
medal (2.Medal2 
ext.Base� (2.GetMedalRs"6
GetMedalChipRq2$
ext.Base� (2.GetMedalChipRq"U
GetMedalChipRs
	medalChip (2
.MedalChip2$
ext.Base� (2.GetMedalChipRs"K
CombineMedalRq
medalChipId (2$
ext.Base� (2.CombineMedalRq"M
CombineMedalRs
medal (2.Medal2$
ext.Base� (2.CombineMedalRs"V
ExplodeMedalRq
keyId (
quality (2$
ext.Base� (2.ExplodeMedalRq"N
ExplodeMedalRs
awards (2.Award2$
ext.Base� (2.ExplodeMedalRs"n
ExplodeMedalChipRq
chipId (
count (
quality (2(
ext.Base� (2.ExplodeMedalChipRq"V
ExplodeMedalChipRs
awards (2.Award2(
ext.Base� (2.ExplodeMedalChipRs"H
	OnMedalRq
keyId (
pos (2
ext.Base� (2
.OnMedalRq"D
	OnMedalRs
medals (2.Medal2
ext.Base� (2
.OnMedalRs"\
LockMedalRq
keyId (
pos (
locked (2!
ext.Base� (2.LockMedalRq"@
LockMedalRs
locked (2!
ext.Base� (2.LockMedalRs"H
	UpMedalRq
keyId (
pos (2
ext.Base� (2
.UpMedalRq"�
	UpMedalRs
hitState (
atom (2.Atom2
cdTime (
upLv (
upExp (2
ext.Base� (2
.UpMedalRs":
BuyMedalCdTimeRq2&
ext.Base� (2.BuyMedalCdTimeRq"X
BuyMedalCdTimeRs
cdTime (
gold (2&
ext.Base� (2.BuyMedalCdTimeRs"N
RefitMedalRq
keyId (
pos (2"
ext.Base� (2.RefitMedalRq"Y
RefitMedalRs
refitLv (
atom (2.Atom22"
ext.Base� (2.RefitMedalRs"N
TransMedalRq
keyId (
pos (2"
ext.Base� (2.TransMedalRq"`
TransMedalRs
medal (2.Medal
atom2 (2.Atom22"
ext.Base� (2.TransMedalRs"<
GetPirateChangeRq2'
ext.Base� (2.GetPirateChangeRq"�
GetPirateChangeRs
actProp (2.Atom2
	changeNum (2.TwoInt
awardId (2'
ext.Base� (2.GetPirateChangeRs"F
DoPirateChangeRq

id (2&
ext.Base� (2.DoPirateChangeRq"�
DoPirateChangeRs
actProp (2.Atom2
	changeNum (2.TwoInt
award (2.Award2&
ext.Base� (2.DoPirateChangeRs":
BuyScoutCdTimeRq2&
ext.Base� (2.BuyScoutCdTimeRq"X
BuyScoutCdTimeRs
cdTime (
gold (2&
ext.Base� (2.BuyScoutCdTimeRs">
GetActPirateRankRq2(
ext.Base� (2.GetActPirateRankRq"�
GetActPirateRankRs
open (
score (
status (%
actPlayerRank (2.ActPlayerRank
	rankAward (2
.RankAward2(
ext.Base� (2.GetActPirateRankRs"8
GetMedalBounsRq2%
ext.Base� (2.GetMedalBounsRq"Y
GetMedalBounsRs

medalBouns (2.MedalBouns2%
ext.Base� (2.GetMedalBounsRs"N
DoMedalBounsRq
costMedalKeyId (2$
ext.Base� (2.DoMedalBounsRq"6
DoMedalBounsRs2$
ext.Base� (2.DoMedalBounsRs":
GetActRechargeRq2&
ext.Base� (2.GetActRechargeRq"U
GetActRechargeRs
dayState (2.TwoInt2&
ext.Base� (2.GetActRechargeRs"E
DoActRechargeRq
day (2%
ext.Base� (2.DoActRechargeRq"O
DoActRechargeRs
award (2.Award2%
ext.Base� (2.DoActRechargeRs"L
GetSectionRewardRq
type (2(
ext.Base� (2.GetSectionRewardRq"e
GetSectionRewardRs%
sectionReward (2.SectionReward2(
ext.Base� (2.GetSectionRewardRs"H
DoSectionRewardRq

id (2'
ext.Base� (2.DoSectionRewardRq"S
DoSectionRewardRs
award (2.Award2'
ext.Base� (2.DoSectionRewardRs"<
ActContuPayMoreRq2'
ext.Base� (2.ActContuPayMoreRq"p
ActContuPayMoreRs
state (#
activityCond (2.ActivityCond2'
ext.Base� (2.ActContuPayMoreRs"H
GetActEnergyStoneDialRq2-
ext.Base� (2.GetActEnergyStoneDialRq"�
GetActEnergyStoneDialRs
score (
fortune (2.Fortune
free (
displayList (	2-
ext.Base� (2.GetActEnergyStoneDialRs"P
GetActEnergyStoneDialRankRq21
ext.Base� (2.GetActEnergyStoneDialRankRq"�
GetActEnergyStoneDialRankRs
score (
open (
status (%
actPlayerRank (2.ActPlayerRank
	rankAward (2
.RankAward21
ext.Base� (2.GetActEnergyStoneDialRankRs"Y
DoActEnergyStoneDialRq
	fortuneId (2,
ext.Base� (2.DoActEnergyStoneDialRq"l
DoActEnergyStoneDialRs
score (
award (2.Award2,
ext.Base� (2.DoActEnergyStoneDialRs"@
GetActBossRq
type (2"
ext.Base� (2.GetActBossRq"�
GetActBossRs
	bossState (
bossEndTime (

bossBagNum (
bossCallTimes (
callLordName (	
bossName (	
bossIcon (
	callTimes (
actProp	 (2.Atom2
attackCd
 (
bagNum (2"
ext.Base� (2.GetActBossRs"4
CallActBossRq2#
ext.Base� (2.CallActBossRq"]
CallActBossRs
	callTimes (
atom (2.Atom22#
ext.Base� (2.CallActBossRs"X
AttackActBossRq
useId (
useGold (2%
ext.Base� (2.AttackActBossRq"�
AttackActBossRs
attackCd (
atom (2.Atom2
award (2.Award
	bossState (

bossBagNum (
bagNum (2%
ext.Base� (2.AttackActBossRs"6
BuyActBossCdRq2$
ext.Base� (2.BuyActBossCdRq"T
BuyActBossCdRs
cdTime (
gold (2$
ext.Base� (2.BuyActBossCdRs"L
GetActBossRankRq
rankType (2&
ext.Base� (2.GetActBossRankRq"�
GetActBossRankRs
score (%
actPlayerRank (2.ActPlayerRank
open (
	rankAward (2
.RankAward
status (2&
ext.Base� (2.GetActBossRankRs"}
UsePropChooseRq
propId (
count (
chooseId (

chooseType (2%
ext.Base� (2.UsePropChooseRq"^
UsePropChooseRs
count (
award (2.Award2%
ext.Base� (2.UsePropChooseRs"B
GetActHilarityPrayRq2*
ext.Base� (2.GetActHilarityPrayRq"p
GetActHilarityPrayRs
keyId (
status (
value (2*
ext.Base� (2.GetActHilarityPrayRs"Y
ReceiveActHilarityPrayRq
keyId (2.
ext.Base� (2.ReceiveActHilarityPrayRq"�
ReceiveActHilarityPrayRs
keyId (
status (
value (
awards (2.Award2.
ext.Base� (2.ReceiveActHilarityPrayRs"N
GetActHilarityPrayActionRq20
ext.Base� (2.GetActHilarityPrayActionRq"�
GetActHilarityPrayActionRs
actProp (2.Atom2
index (
time (
propId (20
ext.Base� (2.GetActHilarityPrayActionRs"i
DoActHilarityPrayActionRq
index (
prop (2/
ext.Base� (2.DoActHilarityPrayActionRq"�
DoActHilarityPrayActionRs
actProp (2.Atom2
index (
time (
propId (2/
ext.Base� (2.DoActHilarityPrayActionRs"e
ReceiveActHilarityPrayActionRq
index (24
ext.Base� (2.ReceiveActHilarityPrayActionRq"}
ReceiveActHilarityPrayActionRs
index (
awards (2.Award24
ext.Base� (2.ReceiveActHilarityPrayActionRs"a
SpeedActHilarityPrayActionRq
index (22
ext.Base� (2.SpeedActHilarityPrayActionRq"}
SpeedActHilarityPrayActionRs
index (
time (
gold (22
ext.Base� (2.SpeedActHilarityPrayActionRs"N

LockHeroRq
heroId (
locked (2 
ext.Base� (2.LockHeroRq".

LockHeroRs2 
ext.Base� (2.LockHeroRs":
GetDay7ActTipsRq2&
ext.Base� (2.GetDay7ActTipsRq"[
GetDay7ActTipsRs
tips (
	lvUpIsUse (2&
ext.Base� (2.GetDay7ActTipsRs"?
GetDay7ActRq
day (2"
ext.Base� (2.GetDay7ActRq"N
GetDay7ActRs
day7Acts (2.Day7Act2"
ext.Base� (2.GetDay7ActRs"M
RecvDay7ActAwardRq
keyId (2(
ext.Base� (2.RecvDay7ActAwardRq"m
RecvDay7ActAwardRs
awards (2.Award
atom2 (2.Atom22(
ext.Base� (2.RecvDay7ActAwardRs"4
Day7ActLvUpRq2#
ext.Base� (2.Day7ActLvUpRq"K
Day7ActLvUpRs
award (2.Award2#
ext.Base� (2.Day7ActLvUpRs">
GetOverRebateActRq2(
ext.Base� (2.GetOverRebateActRq"r
GetOverRebateActRs
gambleId (
payNum (
hasIndex (2(
ext.Base� (2.GetOverRebateActRs"<
DoOverRebateActRq2'
ext.Base� (2.DoOverRebateActRq"c
DoOverRebateActRs
Index (
awards (2.Award2'
ext.Base� (2.DoOverRebateActRs"c
SynInnerModPropsRq
type (
props (2.Atom22(
ext.Base� (2.SynInnerModPropsRq">
GetWorshipGodActRq2(
ext.Base� (2.GetWorshipGodActRq"f
GetWorshipGodActRs
count (
record (2.TwoInt2(
ext.Base� (2.GetWorshipGodActRs"<
DoWorshipGodActRq2'
ext.Base� (2.DoWorshipGodActRq"^
DoWorshipGodActRs
time (

proportion (2'
ext.Base� (2.DoWorshipGodActRs"@
GetWorshipTaskActRq2)
ext.Base� (2.GetWorshipTaskActRq"z
GetWorshipTaskActRs
awardId (
taskNum (2.TwoInt
count (2)
ext.Base� (2.GetWorshipTaskActRs">
DoWorshipTaskActRq2(
ext.Base� (2.DoWorshipTaskActRq"U
DoWorshipTaskActRs
award (2.Award2(
ext.Base� (2.DoWorshipTaskActRs"2
GetSettingRq2"
ext.Base� (2.GetSettingRq"E
GetSettingRs
	closeType (2"
ext.Base� (2.GetSettingRs"U
SetSettingRq
	closeType (
isOpen (2"
ext.Base� (2.SetSettingRq"2
SetSettingRs2"
ext.Base� (2.SetSettingRs"W
RecvLotteryluckyAwardRq
keyId (2-
ext.Base� (2.RecvLotteryluckyAwardRq"_
RecvLotteryluckyAwardRs
award (2.Award2-
ext.Base� (2.RecvLotteryluckyAwardRs"G
ActRebelIsDeadRq
pos (2&
ext.Base� (2.ActRebelIsDeadRq"W
ActRebelIsDeadRs
pos (
isDead (2&
ext.Base� (2.ActRebelIsDeadRs"<
GetActMergeGiftRq2'
ext.Base� (2.GetActMergeGiftRq"Z
GetActMergeGiftRs
conds (2.ActivityCond2'
ext.Base� (2.GetActMergeGiftRs"H
SynDay7ActTipsRq
tips (2&
ext.Base� (2.SynDay7ActTipsRq"J
GetActRebelRankRq
page (2'
ext.Base� (2.GetActRebelRankRq"�
GetActRebelRankRs
killNum (
score (
rank (
	getReward (!

rebelRanks (2.ActRebelRank2'
ext.Base� (2.GetActRebelRankRs"B
ActRebelRankRewardRq2*
ext.Base� (2.ActRebelRankRewardRq"Y
ActRebelRankRewardRs
award (2.Award2*
ext.Base� (2.ActRebelRankRewardRs"B
HeroAwakenRq
heroId (2"
ext.Base� (2.HeroAwakenRq"S
HeroAwakenRs

awakenHero (2.AwakenHero2"
ext.Base� (2.HeroAwakenRs"[
HeroAwakenSkillLvRq

id (
keyId (2)
ext.Base� (2.HeroAwakenSkillLvRq"�
HeroAwakenSkillLvRs
keyId (
lvState (
skill (2.TwoInt
	failTimes (
atom2 (2.Atom22)
ext.Base� (2.HeroAwakenSkillLvRs"4
GetShopInfoRq2#
ext.Base� (2.GetShopInfoRq"I
GetShopInfoRs
shop (2.Shop2#
ext.Base� (2.GetShopInfoRs"_
BuyShopGoodsRq
sty (
gid (
count (2$
ext.Base� (2.BuyShopGoodsRq"D
BuyShopGoodsRs
gold (2$
ext.Base� (2.BuyShopGoodsRs"8
GetActCollegeRq2%
ext.Base� (2.GetActCollegeRq"�
GetActCollegeRs

id (
point (

totalPoint (
actProp (2.Atom2
freeTime (

buyPropNum (2%
ext.Base� (2.GetActCollegeRs"M
BuyActPropRq

id (
count (2"
ext.Base� (2.BuyActPropRq"o
BuyActPropRs
atom2 (2.Atom2
freeTime (

buyPropNum (2"
ext.Base� (2.BuyActPropRs"V
DoActCollegeRq
times (
useGold (2$
ext.Base� (2.DoActCollegeRq"�
DoActCollegeRs

id (
point (

totalPoint (
actProp (2.Atom2
freeTime (
award (2.Award2$
ext.Base� (2.DoActCollegeRs"6
GetMonthSignRq2$
ext.Base� (2.GetMonthSignRq"i
GetMonthSignRs

today_sign (
days (
day_ext (2$
ext.Base� (2.GetMonthSignRs"0
MonthSignRq2!
ext.Base� (2.MonthSignRq"i
MonthSignRs

today_sign (
days (
award (2.Award2!
ext.Base� (2.MonthSignRs"L
DrawMonthSignExtRq
days (2(
ext.Base� (2.DrawMonthSignExtRq"t
DrawMonthSignExtRs
days (
day_ext (
award (2.Award2(
ext.Base� (2.DrawMonthSignExtRs"L
CreateAirshipTeamRq

id (2)
ext.Base� (2.CreateAirshipTeamRq"z
CreateAirshipTeamRs!
airshipTeam (2.AirshipTeam
atom2 (2.Atom22)
ext.Base� (2.CreateAirshipTeamRs"x
JoinAirshipTeamRq

teamLeader (
	airshipId (
form (2.Form2'
ext.Base� (2.JoinAirshipTeamRq"Q
JoinAirshipTeamRs
army (2.Army2'
ext.Base� (2.JoinAirshipTeamRs"2
CancelTeamRq2"
ext.Base� (2.CancelTeamRq"2
CancelTeamRs2"
ext.Base� (2.CancelTeamRs"P
GetAirshipTeamListRq
self (2*
ext.Base� (2.GetAirshipTeamListRq"_
GetAirshipTeamListRs
teams (2.AirshipTeam2*
ext.Base� (2.GetAirshipTeamListRs"Y
GetAirshipTeamDetailRq
	airshipId (2,
ext.Base� (2.GetAirshipTeamDetailRq"c
GetAirshipTeamDetailRs
armys (2.AirshipArmy2,
ext.Base� (2.GetAirshipTeamDetailRs"�
SetPlayerAttackSeqRq
lordId (
	armyKeyId (
step (
isGuard (
guardAishipId (2*
ext.Base� (2.SetPlayerAttackSeqRq"B
SetPlayerAttackSeqRs2*
ext.Base� (2.SetPlayerAttackSeqRs"H
StartAirshipTeamMarchRq2-
ext.Base� (2.StartAirshipTeamMarchRq"H
StartAirshipTeamMarchRs2-
ext.Base� (2.StartAirshipTeamMarchRs"f
GuardAirshipRq

id (
form (2.Form
fight (2$
ext.Base� (2.GuardAirshipRq"K
GuardAirshipRs
army (2.Army2$
ext.Base� (2.GuardAirshipRs"v
GetAirshpTeamArmyRq
	airshipId (
lordId (
	armyKeyId (2)
ext.Base� (2.GetAirshpTeamArmyRq"U
GetAirshpTeamArmyRs
army (2.Army2)
ext.Base� (2.GetAirshpTeamArmyRs"H
GetAirshipGuardRq

id (2'
ext.Base� (2.GetAirshipGuardRq"Y
GetAirshipGuardRs
armys (2.AirshipArmy2'
ext.Base� (2.GetAirshipGuardRs"B
ScoutAirshipRq

id (2$
ext.Base� (2.ScoutAirshipRq"�
ScoutAirshipRs
commanderCount (
	tankCount (

fightCount (
validEndTime (
atom2 (2.Atom22$
ext.Base� (2.ScoutAirshipRs"i
RecvAirshipProduceAwardRq

id (
useProp (2/
ext.Base� (2.RecvAirshipProduceAwardRq"�
RecvAirshipProduceAwardRs
produceTime (

produceNum (
award (2.Award
atom2 (2.Atom22/
ext.Base� (2.RecvAirshipProduceAwardRs"p
AppointAirshipCommanderRq

airship_id (
lordId (2/
ext.Base� (2.AppointAirshipCommanderRq"p
AppointAirshipCommanderRs

airship_id (
lordId (2/
ext.Base� (2.AppointAirshipCommanderRs"N
GetPartyAirshipCommanderRq20
ext.Base� (2.GetPartyAirshipCommanderRq"c
GetPartyAirshipCommanderRs
kv (2.KvLong20
ext.Base�  (2.GetPartyAirshipCommanderRs"M
RebuildAirshipRq
	airshipId (2&
ext.Base�  (2.RebuildAirshipRq"w
RebuildAirshipRs
	airshipId (

durability (
atom (2.Atom22&
ext.Base�  (2.RebuildAirshipRs"E
GetAirshipRq
	airshipId (2"
ext.Base�  (2.GetAirshipRq"M
GetAirshipRs
airship (2.Airship2"
ext.Base�  (2.GetAirshipRs"Q
GetAirshipPlayerRq
	airshipId (2(
ext.Base�  (2.GetAirshipPlayerRq"k
GetAirshipPlayerRs
validEndTime (
remianFreeCnt (2(
ext.Base�  (2.GetAirshipPlayerRs"v
GetAirshipGuardArmyRq
	airshipId (
lordId (
keyId (2+
ext.Base�  (2.GetAirshipGuardArmyRq"Y
GetAirshipGuardArmyRs
army (2.Army2+
ext.Base�  (2.GetAirshipGuardArmyRs"Q
SynAirshipTeamArmyRq
state (2*
ext.Base� (2.SynAirshipTeamArmyRq"]
SynAirshipTeamRq
	airshipId (
status (2&
ext.Base� (2.SynAirshipTeamRq"Q
SynAirshipChangeRq
	airshipId (2(
ext.Base� (2.SynAirshipChangeRq"q
"GetRecvAirshipProduceAwardRecordRq
	airshipId (28
ext.Base�  (2#.GetRecvAirshipProduceAwardRecordRq"�
"GetRecvAirshipProduceAwardRecordRs/
records (2.RecvAirshipProduceAwardRecord28
ext.Base�  (2#.GetRecvAirshipProduceAwardRecordRs">
GetLordEquipInfoRq2(
ext.Base�  (2.GetLordEquipInfoRq"�
GetLordEquipInfoRs
puton (2
.LordEquip
store (2
.LordEquip
prop (2.Prop 
leqb (2.LordEquipBuilding
free (
employ_tech_id (
employ_end_time (
unlock_tech_max	 ("
	mat_queue
 (2.LeqMatBuilding
buyCount (2(
ext.Base�  (2.GetLordEquipInfoRs"I
PutonLordEquipRq
keyId (2&
ext.Base�  (2.PutonLordEquipRq"R
PutonLordEquipRs
le (2
.LordEquip2&
ext.Base�  (2.PutonLordEquipRs"C
TakeOffEquipRq
pos (2$
ext.Base�  (2.TakeOffEquipRq"N
TakeOffEquipRs
le (2
.LordEquip2$
ext.Base�  (2.TakeOffEquipRs":
ShareLordEquipRq2&
ext.Base�  (2.ShareLordEquipRq":
ShareLordEquipRs2&
ext.Base�  (2.ShareLordEquipRs"H
ProductEquipRq
equip_id (2$
ext.Base�  (2.ProductEquipRq"n
ProductEquipRs 
leqb (2.LordEquipBuilding
cost (2.Atom22$
ext.Base�  (2.ProductEquipRs">
CollectLordEquipRq2(
ext.Base�  (2.CollectLordEquipRq"^
CollectLordEquipRs

lord_equip (2
.LordEquip2(
ext.Base�  (2.CollectLordEquipRs"^
ResloveLordEquipRq
keyId (
quality (2(
ext.Base�  (2.ResloveLordEquipRq"U
ResloveLordEquipRs
award (2.Award2(
ext.Base�  (2.ResloveLordEquipRs"6
UseTechnicalRq2$
ext.Base�  (2.UseTechnicalRq"Y
UseTechnicalRs
tech_id (
end_time (2$
ext.Base�  (2.UseTechnicalRs"M
EmployTechnicalRq
tech_id (2'
ext.Base�  (2.EmployTechnicalRq"t
EmployTechnicalRs
tech_id (
employ_end_time (
gold (2'
ext.Base�  (2.EmployTechnicalRs"F
LordEquipSpeedByGoldRq2,
ext.Base�  (2.LordEquipSpeedByGoldRq"T
LordEquipSpeedByGoldRs
gold (2,
ext.Base�  (2.LordEquipSpeedByGoldRs"V
LockLordEquipRq
keyId (
puton (2%
ext.Base�  (2.LockLordEquipRq"W
LockLordEquipRs
	lordEquip (2
.LordEquip2%
ext.Base�  (2.LockLordEquipRs"e
ProductLordEquipMatRq
quality (
costId (2+
ext.Base�! (2.ProductLordEquipMatRq"y
ProductLordEquipMatRs
cost (2.Atom2
lemb (2.LeqMatBuilding2+
ext.Base�! (2.ProductLordEquipMatRs":
BuyMaterialProRq2&
ext.Base�! (2.BuyMaterialProRq"Z
BuyMaterialProRs
gold (
buyCount (2&
ext.Base�! (2.BuyMaterialProRs"U
CollectLeqMaterialRq
	queue_idx (2*
ext.Base�! (2.CollectLeqMaterialRq"�
CollectLeqMaterialRs
	queue_idx (
award (2.Award
lemb (2.LeqMatBuilding2*
ext.Base�! (2.CollectLeqMaterialRs"6
GetLembQueueRq2$
ext.Base�! (2.GetLembQueueRq"U
GetLembQueueRs
lemb (2.LeqMatBuilding2$
ext.Base�! (2.GetLembQueueRs"i
SynUnlockTechnicalRq
unlock_tech_max (
free (2*
ext.Base� (2.SynUnlockTechnicalRq"h
LordEquipChangeRq
type (
keyId (
puton (2'
ext.Base�! (2.LordEquipChangeRq"o
LordEquipChangeRs
num (
gold (
le (2
.LordEquip2'
ext.Base�! (2.LordEquipChangeRs"L
LordEquipChangeFreeTimeRq2/
ext.Base�! (2.LordEquipChangeFreeTimeRq"p
LordEquipChangeFreeTimeRs
remainingTime (
num (2/
ext.Base�! (2.LordEquipChangeFreeTimeRs"r
LordEquipInheritRq
keyId (
puton (
consumekeyId (2(
ext.Base�! (2.LordEquipInheritRq"d
LordEquipInheritRs
gold (
le (2
.LordEquip2(
ext.Base�! (2.LordEquipInheritRs"�
SetLordEquipUseTypeRq
type (
keyId (
puton (
operationType (2+
ext.Base�! (2.SetLordEquipUseTypeRq"\
SetLordEquipUseTypeRs
le (2
.LordEquip2+
ext.Base�! (2.SetLordEquipUseTypeRs"D
GetActSmeltPartCritRq2+
ext.Base�" (2.GetActSmeltPartCritRq"[
GetActSmeltPartCritRs
quota (2.Quota2+
ext.Base�" (2.GetActSmeltPartCritRs"H
GetActSmeltPartMasterRq2-
ext.Base�" (2.GetActSmeltPartMasterRq"�
GetActSmeltPartMasterRs
props (2.Atom2
point (
	broadcast (2
.Broadcast2-
ext.Base�" (2.GetActSmeltPartMasterRs"]
LotteryInSmeltPartMasterRq
times (20
ext.Base�" (2.LotteryInSmeltPartMasterRq"�
LotteryInSmeltPartMasterRs
props (2.Atom2
point (
award (2.Award20
ext.Base�" (2.LotteryInSmeltPartMasterRs"P
GetActSmeltPartMasterRankRq21
ext.Base�" (2.GetActSmeltPartMasterRankRq"�
GetActSmeltPartMasterRankRs
open (
score (
status (%
actPlayerRank (2.ActPlayerRank
	rankAward (2
.RankAward21
ext.Base�" (2.GetActSmeltPartMasterRankRs"F
GetPlayerBackMessageRq2,
ext.Base�# (2.GetPlayerBackMessageRq"�
GetPlayerBackMessageRs
backTime (
status (
today (
endTime (2,
ext.Base�# (2.GetPlayerBackMessageRs"Y
GetPlayerBackAwardsRq
awardTypeId (2+
ext.Base�# (2.GetPlayerBackAwardsRq"y
GetPlayerBackAwardsRs
award (2.Award
status (
gold (2+
ext.Base�# (2.GetPlayerBackAwardsRs"@
GetPlayerBackBuffRq2)
ext.Base�# (2.GetPlayerBackBuffRq"r
GetPlayerBackBuffRs
buff (
backTime (
buffTime (2)
ext.Base�# (2.GetPlayerBackBuffRs"L
GetActCumulativePayInfoRq2/
ext.Base�# (2.GetActCumulativePayInfoRq"�
GetActCumulativePayInfoRs"
pay (2.ActCumulativePayInfo
status (
keyId (
awardId (
day (2/
ext.Base�# (2.GetActCumulativePayInfoRs"[
GetActCumulativePayAwardRq
day (20
ext.Base�# (2.GetActCumulativePayAwardRq"e
GetActCumulativePayAwardRs
award (2.Award20
ext.Base�# (2.GetActCumulativePayAwardRs"O
ActCumulativeRePayRq
day (2*
ext.Base�# (2.ActCumulativeRePayRq"B
ActCumulativeRePayRs2*
ext.Base�# (2.ActCumulativeRePayRs"J
GetActMedalofhonorInfoRq2.
ext.Base�# (2.GetActMedalofhonorInfoRq"
GetActMedalofhonorInfoRs
count (

medalHonor (
targetId (2.
ext.Base�# (2.GetActMedalofhonorInfoRs"Q
OpenActMedalofhonorRq
pos (2+
ext.Base�# (2.OpenActMedalofhonorRq"�
OpenActMedalofhonorRs
	chickenId (

medalHonor (
award (2.Award2+
ext.Base�# (2.OpenActMedalofhonorRs"
SearchActMedalofhonorTargetsRq
forceResult (

searchType (24
ext.Base�# (2.SearchActMedalofhonorTargetsRq"v
SearchActMedalofhonorTargetsRs
targetId (
gold (24
ext.Base�# (2.SearchActMedalofhonorTargetsRs"h
BuyActMedalofhonorItemRq

id (
buyCount (2.
ext.Base�# (2.BuyActMedalofhonorItemRq"u
BuyActMedalofhonorItemRs

medalHonor (
award (2.Award2.
ext.Base�# (2.BuyActMedalofhonorItemRs"T
GetActMedalofhonorRankAwardRq23
ext.Base�# (2.GetActMedalofhonorRankAwardRq"k
GetActMedalofhonorRankAwardRs
award (2.Award23
ext.Base�# (2.GetActMedalofhonorRankAwardRs"R
GetActMedalofhonorRankInfoRq22
ext.Base�# (2.GetActMedalofhonorRankInfoRq"�
GetActMedalofhonorRankInfoRs
score (%
actPlayerRank (2.ActPlayerRank
open (
	rankAward (2
.RankAward
status (22
ext.Base�# (2.GetActMedalofhonorRankInfoRs"<
GetMonopolyInfoRq2'
ext.Base�# (2.GetMonopolyInfoRq"�
GetMonopolyInfoRs
event (
pos (
energy (
finishRound (
	drawRound (
drawFreeEnergySec (2'
ext.Base�# (2.GetMonopolyInfoRs"?
ThrowDiceRq
point (2!
ext.Base�# (2.ThrowDiceRq"�
ThrowDiceRs
pos (
energy (
finishRound (
atom2 (2.Atom2
award (2.Award
buyId (2!
ext.Base�# (2.ThrowDiceRs"I
BuyOrUseEnergyRq
isBuy (2&
ext.Base�# (2.BuyOrUseEnergyRq"o
BuyOrUseEnergyRs
energy (
gold (
atom2 (2.Atom22&
ext.Base�# (2.BuyOrUseEnergyRs"M
BuyDiscountGoodsRq
buyId (2(
ext.Base�# (2.BuyDiscountGoodsRq"c
BuyDiscountGoodsRs
gold (
award (2.Award2(
ext.Base�# (2.BuyDiscountGoodsRs"E
SelectDialogRq
dlgId (2$
ext.Base�# (2.SelectDialogRq"]
SelectDialogRs
energy (
award (2.Award2$
ext.Base�# (2.SelectDialogRs"S
DrawFinishCountAwardRq
cnt (2,
ext.Base�# (2.DrawFinishCountAwardRq"]
DrawFinishCountAwardRs
award (2.Award2,
ext.Base�# (2.DrawFinishCountAwardRs":
DrawFreeEnergyRq2&
ext.Base�# (2.DrawFreeEnergyRq"e
DrawFreeEnergyRs
drawFreeEnergySec (
energy (2&
ext.Base�# (2.DrawFreeEnergyRs"D
GetActScrtWpnStdCntRq2+
ext.Base�# (2.GetActScrtWpnStdCntRq"n
GetActScrtWpnStdCntRs
cnt (
cond (2.ActivityCond2+
ext.Base�# (2.GetActScrtWpnStdCntRs"6
GetActStrokeRq2$
ext.Base�# (2.GetActStrokeRq"�
GetActStrokeRs

activityId (
	beginTime (
endTime (

serverTime (

id (2$
ext.Base�# (2.GetActStrokeRs"N
DrawActStrokeAwardRq

id (2*
ext.Base�# (2.DrawActStrokeAwardRq"e
DrawActStrokeAwardRs

id (
award (2.Award2*
ext.Base�# (2.DrawActStrokeAwardRs"B
GetActVipCountInfoRq2*
ext.Base�# (2.GetActVipCountInfoRq"x
GetActVipCountInfoRs
twoInt (2.TwoInt
cond (2.ActivityCond2*
ext.Base�# (2.GetActVipCountInfoRs"F
GetActLotteryExploreRq2,
ext.Base�# (2.GetActLotteryExploreRq"r
GetActLotteryExploreRs
score (
cond (2.ActivityCond2,
ext.Base�# (2.GetActLotteryExploreRs">
GetActRedBagInfoRq2(
ext.Base�$ (2.GetActRedBagInfoRq"�
GetActRedBagInfoRs

activityId (
money (
stage (
prop (2.Atom2
	worldChat (2.RedBagChat
	partyChat (2.RedBagChat2(
ext.Base�$ (2.GetActRedBagInfoRs"[
DrawActRedBagStageAwardRq
stage (2/
ext.Base�$ (2.DrawActRedBagStageAwardRq"c
DrawActRedBagStageAwardRs
award (2.Award2/
ext.Base�$ (2.DrawActRedBagStageAwardRs">
GetActRedBagListRq2(
ext.Base�$ (2.GetActRedBagListRq"^
GetActRedBagListRs
redBag (2.RedBagSummary2(
ext.Base�$ (2.GetActRedBagListRs"?
GrabRedBagRq
uid (2"
ext.Base�$ (2.GrabRedBagRq"a
GrabRedBagRs
	grabMoney (
redBag (2
.ActRedBag2"
ext.Base�$ (2.GrabRedBagRs"p
SendActRedBagRq
propId (
grabCnt (
isPartyRedBag (2%
ext.Base�$ (2.SendActRedBagRq"p
SendActRedBagRs
atom2 (2.Atom2
summary (2.RedBagSummary2%
ext.Base�$ (2.SendActRedBagRs"<
GetMilitaryRankRq2'
ext.Base�' (2.GetMilitaryRankRq"�
GetMilitaryRankRs
militaryRank (
sortRank (
militaryExploit (
mpltGotToday (2'
ext.Base�' (2.GetMilitaryRankRs":
UpMilitaryRankRq2&
ext.Base�' (2.UpMilitaryRankRq"z
UpMilitaryRankRs
militaryRank (
militaryExploit (
curRank (2&
ext.Base�' (2.UpMilitaryRankRs":
GetHeroPutInfoRq2&
ext.Base�' (2.GetHeroPutInfoRq"U
GetHeroPutInfoRs
heroPut (2.HeroPut2&
ext.Base�' (2.GetHeroPutInfoRs"^
SetHeroPutRq
partId (

id (
heroId (2"
ext.Base�' (2.SetHeroPutRq"M
SetHeroPutRs
heroPut (2.HeroPut2"
ext.Base�' (2.SetHeroPutRs"K
UpLoadStoreRq
store (2.Store2#
ext.Base�' (2.UpLoadStoreRq"4
UpLoadStoreRs2#
ext.Base�' (2.UpLoadStoreRs"D
GetSecretWeaponInfoRq2+
ext.Base�( (2.GetSecretWeaponInfoRq"c
GetSecretWeaponInfoRs
weapon (2.SecretWeapon2+
ext.Base�( (2.GetSecretWeaponInfoRs"N
UnlockWeaponBarRq
weaponId (2'
ext.Base�( (2.UnlockWeaponBarRq"i
UnlockWeaponBarRs
weapon (2.SecretWeapon
gold (2'
ext.Base�( (2.UnlockWeaponBarRs"l
LockedWeaponBarRq
weaponId (
barIdx (
lock (2'
ext.Base�( (2.LockedWeaponBarRq"[
LockedWeaponBarRs
weapon (2.SecretWeapon2'
ext.Base�( (2.LockedWeaponBarRs"P
StudyWeaponSkillRq
weaponId (2(
ext.Base�( (2.StudyWeaponSkillRq"�
StudyWeaponSkillRs
atom2 (2.Atom2
gold (
weapon (2.SecretWeapon2(
ext.Base�( (2.StudyWeaponSkillRs"<
GetAttackEffectRq2'
ext.Base�( (2.GetAttackEffectRq"]
GetAttackEffectRs
effect (2.AttackEffectPb2'
ext.Base�( (2.GetAttackEffectRs"H
UseAttackEffectRq

id (2'
ext.Base�( (2.UseAttackEffectRq"<
UseAttackEffectRs2'
ext.Base�( (2.UseAttackEffectRs"B
GetCrossPartyStateRq2*
ext.Base� (2.GetCrossPartyStateRq"d
GetCrossPartyStateRs
	beginTime (	
state (2*
ext.Base� (2.GetCrossPartyStateRs"Q
SynCrossPartyStateRq
state (2*
ext.Base� (2.SynCrossPartyStateRq"L
GetCrossPartyServerListRq2/
ext.Base� (2.GetCrossPartyServerListRq"u
GetCrossPartyServerListRs'
gameServerInfo (2.GameServerInfo2/
ext.Base� (2.GetCrossPartyServerListRs"8
CrossPartyRegRq2%
ext.Base� (2.CrossPartyRegRq"8
CrossPartyRegRs2%
ext.Base� (2.CrossPartyRegRs":
GetCPMyRegInfoRq2&
ext.Base� (2.GetCPMyRegInfoRq"I
GetCPMyRegInfoRs
isReg (2&
ext.Base� (2.GetCPMyRegInfoRs"D
GetCrossPartyMemberRq2+
ext.Base� (2.GetCrossPartyMemberRq"�
GetCrossPartyMemberRs
	partyNums (
myPartyMemberNum (!
cpMemberReg (2.CPMemberReg
group (2+
ext.Base� (2.GetCrossPartyMemberRs"G
GetCrossPartyRq
group (2%
ext.Base� (2.GetCrossPartyRq"�
GetCrossPartyRs
group (!
cpPartyInfo (2.CPPartyInfo
totalRegPartyNum (
groupRegPartyNum (2%
ext.Base� (2.GetCrossPartyRs"W
GetCPSituationRq
group (
page (2&
ext.Base� (2.GetCPSituationRq"t
GetCPSituationRs
group (
page (
cpRecord (2	.CPRecord2&
ext.Base� (2.GetCPSituationRs"h
GetCPOurServerSituationRq
type (
page (2/
ext.Base� (2.GetCPOurServerSituationRq"�
GetCPOurServerSituationRs
type (
page (
cpRecord (2	.CPRecord2/
ext.Base� (2.GetCPOurServerSituationRs"G
GetCPReportRq
	reportKey (2#
ext.Base� (2.GetCPReportRq"Q
GetCPReportRs
cpRptAtk (2	.CPRptAtk2#
ext.Base� (2.GetCPReportRs"L
GetCPRankRq
type (
page (2!
ext.Base� (2.GetCPRankRq"�
GetCPRankRs
type (
page (
cpRank (2.CPRank
mySelf (2.CPRank
myJiFen (2!
ext.Base� (2.GetCPRankRs"J
ReceiveCPRewardRq
type (2'
ext.Base� (2.ReceiveCPRewardRq"a
ReceiveCPRewardRs
type (
award (2.Award2'
ext.Base� (2.ReceiveCPRewardRs"0
GetCPShopRq2!
ext.Base� (2.GetCPShopRq"[
GetCPShopRs
jifen (
buy (2.CrossShopBuy2!
ext.Base� (2.GetCPShopRs"Y
ExchangeCPShopRq
shopId (
count (2&
ext.Base� (2.ExchangeCPShopRq"y
ExchangeCPShopRs
jifen (
shopId (
count (
restNum (2&
ext.Base� (2.ExchangeCPShopRs"0
GetCPFormRq2!
ext.Base� (2.GetCPFormRq"T
GetCPFormRs
form (2.Form
fight (2!
ext.Base� (2.GetCPFormRs"T
SetCPFormRq
form (2.Form
fight (2!
ext.Base� (2.SetCPFormRq"T
SetCPFormRs
form (2.Form
fight (2!
ext.Base� (2.SetCPFormRs"f
SynCPSituationRq
gruop (
cpRecord (2	.CPRecord2&
ext.Base� (2.SynCPSituationRq"2
GetCPTrendRq2"
ext.Base� (2.GetCPTrendRq"b
GetCPTrendRs
jifen (

crossTrend (2.CrossTrend2"
ext.Base� (2.GetCPTrendRs"B
GetCrossDrillStateRq2*
ext.Base� (2.GetCrossDrillStateRq"�
GetCrossDrillStateRs
durationTime (	
state (
reg (
teamData (2.CDMyTeamData2*
ext.Base� (2.GetCrossDrillStateRs"Q
SynCrossDrillStateRq
state (2*
ext.Base� (2.SynCrossDrillStateRq"<
GetCDServerListRq2'
ext.Base� (2.GetCDServerListRq"e
GetCDServerListRs'
gameServerInfo (2.GameServerInfo2'
ext.Base� (2.GetCDServerListRs"8
CrossDrillRegRq2%
ext.Base� (2.CrossDrillRegRq"8
CrossDrillRegRs2%
ext.Base� (2.CrossDrillRegRs">
GetCrossDrillBetRq2(
ext.Base� (2.GetCrossDrillBetRq"Y
GetCrossDrillBetRs
bet (2.CDBattleBet2(
ext.Base� (2.GetCrossDrillBetRs"4
GetCDMoraleRq2#
ext.Base� (2.GetCDMoraleRq"O
GetCDMoraleRs
morale (2	.CDMorale2#
ext.Base� (2.GetCDMoraleRs"L
ImproveCDMoraleRq
buffId (2'
ext.Base� (2.ImproveCDMoraleRq"w
ImproveCDMoraleRs
morale (2	.CDMorale
gold (
resource (2'
ext.Base� (2.ImproveCDMoraleRs":
GetCDFinalRankRq2&
ext.Base� (2.GetCDFinalRankRq"e
GetCDFinalRankRs
state (
rank (2.CDFinalRank2&
ext.Base� (2.GetCDFinalRankRs"B
ReceiveCDFinalRankRq2*
ext.Base� (2.ReceiveCDFinalRankRq"Y
ReceiveCDFinalRankRs
award (2.Award2*
ext.Base� (2.ReceiveCDFinalRankRs"@
GetCDDistributionRq2)
ext.Base� (2.GetCDDistributionRq"o
GetCDDistributionRs-

distribute (2.CDTeamServerDistribution2)
ext.Base� (2.GetCDDistributionRs":
GetCDTeamScoreRq2&
ext.Base� (2.GetCDTeamScoreRq"[
GetCDTeamScoreRs
	teamScore (2.CDTeamScore2&
ext.Base� (2.GetCDTeamScoreRs"8
GetCDHeroRankRq2%
ext.Base� (2.GetCDHeroRankRq"t
GetCDHeroRankRs
rank (
state (
heroRank (2.CDHeroRank2%
ext.Base� (2.GetCDHeroRankRs"@
ReceiveCDHeroRankRq2)
ext.Base� (2.ReceiveCDHeroRankRq"W
ReceiveCDHeroRankRs
award (2.Award2)
ext.Base� (2.ReceiveCDHeroRankRs"H
GetCDTeamDataRq
teamId (2%
ext.Base� (2.GetCDTeamDataRq"_
GetCDTeamDataRs%

battleData (2.CDTeamBattleData2%
ext.Base� (2.GetCDTeamDataRs"O
GetCDBattlefieldRq
fieldId (2(
ext.Base� (2.GetCDBattlefieldRq"�
GetCDBattlefieldRs
fieldId (
fieldStatus (
redServerName (	
blueServerName (	
ratio ('

stronghold (2.CDBattleStronghold2(
ext.Base� (2.GetCDBattlefieldRs"f
GetCDRecordRq
strongholdId (
type (
page (2#
ext.Base� (2.GetCDRecordRq"�
GetCDRecordRs
strongholdId (
type (
page (
record (2	.CDRecord2#
ext.Base� (2.GetCDRecordRs"G
GetCDReportRq
	reportKey (2#
ext.Base� (2.GetCDReportRq"]
GetCDReportRs'
rptAtkFortress (2.RptAtkFortress2#
ext.Base� (2.GetCDReportRs"Z
GetCDStrongholdRankRq
strongholdId (2+
ext.Base� (2.GetCDStrongholdRankRq"�
GetCDStrongholdRankRs
strongholdId (
myRank (
winNum (
lostNum (
rank (2.CDStrongholdRank2+
ext.Base� (2.GetCDStrongholdRankRs"0
GetCDTankRq2!
ext.Base� (2.GetCDTankRq"E
GetCDTankRs
tank (2.Tank2!
ext.Base� (2.GetCDTankRs"Y
ExchangeCDTankRq
tankId (
count (2&
ext.Base� (2.ExchangeCDTankRq"Y
ExchangeCDTankRs
tankId (
count (2&
ext.Base� (2.ExchangeCDTankRs"A
GetCDFormRq
fieldId (2!
ext.Base� (2.GetCDFormRq"U
GetCDFormRs#
form (2.CDStrongholdFormData2!
ext.Base� (2.GetCDFormRs"j
SetCDFormRq
strongholdId (
form (2.Form
clean (2!
ext.Base� (2.SetCDFormRq"j
SetCDFormRs
strongholdId (
form (2.Form
fight (2!
ext.Base� (2.SetCDFormRs"8
GetCDKnockoutRq2%
ext.Base� (2.GetCDKnockoutRq"j
GetCDKnockoutRs
stage (!
battle (2.CDKnockoutBattle2%
ext.Base� (2.GetCDKnockoutRs"o
CrossDrillBetRq
battleGroupId (
target (
betNum (2%
ext.Base� (2.CrossDrillBetRq"�
CrossDrillBetRs
battleGroupId (
target (
betNum (
betCount (
gold (2%
ext.Base� (2.CrossDrillBetRs"M
ReceiveCDBetRq
battleGroupId (2$
ext.Base� (2.ReceiveCDBetRq"\
ReceiveCDBetRs
battleGroupId (
jifen (2$
ext.Base� (2.ReceiveCDBetRs"0
GetCDShopRq2!
ext.Base� (2.GetCDShopRq"s
GetCDShopRs
jifen (
buy (2.CrossShopBuy
canBuyTreasure (2!
ext.Base� (2.GetCDShopRs"Y
ExchangeCDShopRq
shopId (
count (2&
ext.Base� (2.ExchangeCDShopRq"y
ExchangeCDShopRs
jifen (
shopId (
count (
restNum (2&
ext.Base� (2.ExchangeCDShopRs"X
GetCDTeamBattleResultRq
teamId (2-
ext.Base� (2.GetCDTeamBattleResultRq"e
GetCDTeamBattleResultRs

battleData (2.TwoInt2-
ext.Base� (2.GetCDTeamBattleResultRs"<

GetSkinsRq
type (2 
ext.Base�- (2.GetSkinsRq"C

GetSkinsRs
skin (2.Skin2 
ext.Base�- (2.GetSkinsRs"K
	BuySkinRq
skinId (
count (2
ext.Base�- (2
.BuySkinRq"O
	BuySkinRs
gold (
skin (2.Skin2
ext.Base�- (2
.BuySkinRs"K
	UseSkinRq
skinId (
count (2
ext.Base�- (2
.UseSkinRq"i
	UseSkinRs
count (
effect (2.Effect
skin (2.Skin2
ext.Base�- (2
.UseSkinRs">
GetActChooseGiftRq2(
ext.Base�. (2.GetActChooseGiftRq"|
GetActChooseGiftRs
awardId (
limit (
left (
states (2(
ext.Base�. (2.GetActChooseGiftRs"H
DoActChooseGiftRq

id (2'
ext.Base�. (2.DoActChooseGiftRq"i
DoActChooseGiftRs
limit (
left (
states (2'
ext.Base�. (2.DoActChooseGiftRs"@
GetActBrotherTaskRq2)
ext.Base�. (2.GetActBrotherTaskRq"g
GetActBrotherTaskRs
buffId (
task (2.TwoInt2)
ext.Base�. (2.GetActBrotherTaskRs"J
UpBrotherBuffRq
buffType (2%
ext.Base�. (2.UpBrotherBuffRq"H
UpBrotherBuffRs
buffId (2%
ext.Base�. (2.UpBrotherBuffRs"H
GetBrotherAwardRq

id (2'
ext.Base�. (2.GetBrotherAwardRq"S
GetBrotherAwardRs
task (2.TwoInt2'
ext.Base�. (2.GetBrotherAwardRs"U
ShowQuinnRq
showType (
	isRefresh (2!
ext.Base�. (2.ShowQuinnRq"�
ShowQuinnRs
quinn (2.Quinn
getType (
	getNumber (
getPrice (
hasMoney (
hasRefreshes (
hasStars (
award (2.Award2!
ext.Base�. (2.ShowQuinnRs"<

BuyQuinnRq
type (2 
ext.Base�. (2.BuyQuinnRq"m

BuyQuinnRs
award (2.Award
eggs (2.Award
hasMoney (2 
ext.Base�. (2.BuyQuinnRs"8
GetQuinnAwardRq2%
ext.Base�. (2.GetQuinnAwardRq"O
GetQuinnAwardRs
award (2.Award2%
ext.Base�. (2.GetQuinnAwardRs"a
PlugInScoutMineValidCodeRq
	validCode (	20
ext.Base�> (2.PlugInScoutMineValidCodeRq"N
PlugInScoutMineValidCodeRs20
ext.Base�> (2.PlugInScoutMineValidCodeRs"D
GetFightLabItemInfoRq2+
ext.Base�. (2.GetFightLabItemInfoRq"x
GetFightLabItemInfoRs
item (2.TwoInt
resource (2	.ThreeInt2+
ext.Base�. (2.GetFightLabItemInfoRs"<
GetFightLabInfoRq2'
ext.Base�. (2.GetFightLabInfoRq"�
GetFightLabInfoRs
	freeCount (
presonCount (2	.ThreeInt
techInfo (2.TwoInt
archInfo (2.TwoInt2'
ext.Base�. (2.GetFightLabInfoRs"h
SetFightLabPersonCountRq
presonCount (2.TwoInt2.
ext.Base�. (2.SetFightLabPersonCountRq"�
SetFightLabPersonCountRs
	freeCount (
presonCount (2	.ThreeInt
resource (2	.ThreeInt2.
ext.Base�. (2.SetFightLabPersonCountRs"X
UpFightLabTechUpLevelRq
techId (2-
ext.Base�. (2.UpFightLabTechUpLevelRq"�
UpFightLabTechUpLevelRs
techId (
level (
	freeCount (
itemInfo (2	.ThreeInt2-
ext.Base�. (2.UpFightLabTechUpLevelRs"Q
ActFightLabArchActRq
ActId (2*
ext.Base�. (2.ActFightLabArchActRq"�
ActFightLabArchActRs
archInfo (2.TwoInt
techInfo (2.TwoInt
itemInfo (2	.ThreeInt
presonCount (2	.ThreeInt
resource (2	.ThreeInt2*
ext.Base�. (2.ActFightLabArchActRs"X
GetFightLabResourceRq

resourceId (2+
ext.Base�. (2.GetFightLabResourceRq"~
GetFightLabResourceRs
resource (2	.ThreeInt
itemInfo (2	.ThreeInt2+
ext.Base�. (2.GetFightLabResourceRs"L
GetFightLabGraduateInfoRq2/
ext.Base�. (2.GetFightLabGraduateInfoRq"w
GetFightLabGraduateInfoRs
info (2	.ThreeInt
rewardId (2/
ext.Base�. (2.GetFightLabGraduateInfoRs"e
UpFightLabGraduateUpRq
type (
skillId (2,
ext.Base�. (2.UpFightLabGraduateUpRq"�
UpFightLabGraduateUpRs
type (
skillId (
level (
dearItemInfo (2	.ThreeInt2,
ext.Base�/ (2.UpFightLabGraduateUpRs"P
GetFightLabGraduateRewardRq21
ext.Base�/ (2.GetFightLabGraduateRewardRq"y
GetFightLabGraduateRewardRs
rewardId (
award (2.Award21
ext.Base�/ (2.GetFightLabGraduateRewardRs"B
GetFightLabSpyInfoRq2*
ext.Base�/ (2.GetFightLabSpyInfoRq"]
GetFightLabSpyInfoRs
spyinfo (2.SpyInfo2*
ext.Base�/ (2.GetFightLabSpyInfoRs"R
ActFightLabSpyAreaRq
areaId (2*
ext.Base�/ (2.ActFightLabSpyAreaRq"k
ActFightLabSpyAreaRs
spyinfo (2.SpyInfo
gold (2*
ext.Base�/ (2.ActFightLabSpyAreaRs"R
RefFightLabSpyTaskRq
areaId (2*
ext.Base�/ (2.RefFightLabSpyTaskRq"`
RefFightLabSpyTaskRs
taskId (
gold (2*
ext.Base�/ (2.RefFightLabSpyTaskRs"a
ActFightLabSpyTaskRq
areaId (
spyId (2*
ext.Base�/ (2.ActFightLabSpyTaskRq"k
ActFightLabSpyTaskRs
spyinfo (2.SpyInfo
gold (2*
ext.Base�/ (2.ActFightLabSpyTaskRs"^
GctFightLabSpyTaskRewardRq
areaId (20
ext.Base�/ (2.GctFightLabSpyTaskRewardRq"�
GctFightLabSpyTaskRewardRs
spyinfo (2.SpyInfo
award (2.Award

awardLevel (20
ext.Base�/ (2.GctFightLabSpyTaskRewardRs"Z
ResetFightLabGraduateUpRq
type (2/
ext.Base�/ (2.ResetFightLabGraduateUpRq"�
ResetFightLabGraduateUpRs
info (2	.ThreeInt
itemInfo (2	.ThreeInt
gold (2/
ext.Base�/ (2.ResetFightLabGraduateUpRs"D
GetAllSpyTaskRewardRq2+
ext.Base�/ (2.GetAllSpyTaskRewardRq"g
GetAllSpyTaskRewardRs!
	taskAward (2.SpyTaskReward2+
ext.Base�/ (2.GetAllSpyTaskRewardRs"8
GetGiftRewardRq2%
ext.Base�/ (2.GetGiftRewardRq"O
GetGiftRewardRs
award (2.Award2%
ext.Base�/ (2.GetGiftRewardRs":
GetRedPlanInfoRq2&
ext.Base�0 (2.GetRedPlanInfoRq"�
GetRedPlanInfoRs
fuel (
	itemCount (
areaInfo (
shopInfo (
fuelBuyCount (
isfirst (
	nowAreaId (
fuelTime (2&
ext.Base�0 (2.GetRedPlanInfoRs"D
MoveRedPlanRq
areaId (2#
ext.Base�0 (2.MoveRedPlanRq"�
MoveRedPlanRs
nextPointId (
award (2.Award
	awardType (
	itemCount (
fuel (

rewardInfo (
isfirst (
historyPoint (
perfect	 (2#
ext.Base�0 (2.MoveRedPlanRs"X
RedPlanRewardRq
goodsid (
count (2%
ext.Base�0 (2.RedPlanRewardRq"t
RedPlanRewardRs
	itemCount (
award (2.Award
shopInfo (2%
ext.Base�0 (2.RedPlanRewardRs":
RedPlanBuyFuelRq2&
ext.Base�0 (2.RedPlanBuyFuelRq"l
RedPlanBuyFuelRs
fuelBuyCount (
gold (
fuel (2&
ext.Base�0 (2.RedPlanBuyFuelRs"H
GetRedPlanBoxRq
areaId (2%
ext.Base�0 (2.GetRedPlanBoxRq"c
GetRedPlanBoxRs
award (2.Award

rewardInfo (2%
ext.Base�0 (2.GetRedPlanBoxRs"R
GetRedPlanAreaInfoRq
areaId (2*
ext.Base�0 (2.GetRedPlanAreaInfoRq"�
GetRedPlanAreaInfoRs
pointIds (
areaInfo (

rewardInfo (
	nowAreaId (
isfirst (
historyPoint (2*
ext.Base�0 (2.GetRedPlanAreaInfoRs"J
RefRedPlanAreaRq
areaId (2&
ext.Base�0 (2.RefRedPlanAreaRq"�
RefRedPlanAreaRs
award (2.Award
	awardType (
	itemCount (
fuel (2&
ext.Base�0 (2.RefRedPlanAreaRs"I
GetGuideRewardRq
index (2&
ext.Base�1 (2.GetGuideRewardRq"`
GetGuideRewardRs
award (2.Award
count (2&
ext.Base�1 (2.GetGuideRewardRs"D
CreateTeamRq
teamType (2"
ext.Base�2 (2.CreateTeamRq"c
CreateTeamRs
teamId (
roleInfo (2.TeamRoleInfo2"
ext.Base�2 (2.CreateTeamRs">

JoinTeamRq
teamId (2 
ext.Base�2 (2.JoinTeamRq".

JoinTeamRs2 
ext.Base�2 (2.JoinTeamRs"0
LeaveTeamRq2!
ext.Base�2 (2.LeaveTeamRq"0
LeaveTeamRs2!
ext.Base�2 (2.LeaveTeamRs"<
	KickOutRq
roleId (2
ext.Base�2 (2
.KickOutRq",
	KickOutRs2
ext.Base�2 (2
.KickOutRs"4
DismissTeamRq2#
ext.Base�2 (2.DismissTeamRq"4
DismissTeamRs2#
ext.Base�2 (2.DismissTeamRs"@

FindTeamRq
teamType (2 
ext.Base�2 (2.FindTeamRq".

FindTeamRs2 
ext.Base�2 (2.FindTeamRs"B
ChangeMemberStatusRq2*
ext.Base�2 (2.ChangeMemberStatusRq"B
ChangeMemberStatusRs2*
ext.Base�2 (2.ChangeMemberStatusRs"Z
ExchangeOrderRq
roleOne (
roleTwo (2%
ext.Base�2 (2.ExchangeOrderRq"8
ExchangeOrderRs2%
ext.Base�2 (2.ExchangeOrderRs"?

TeamChatRq
message (	2 
ext.Base�2 (2.TeamChatRq"<

TeamChatRs
time (2 
ext.Base�2 (2.TeamChatRs"J
LookMemberInfoRq
roleId (2&
ext.Base�2 (2.LookMemberInfoRq"^
LookMemberInfoRs
form (2.Form
fight (2&
ext.Base�2 (2.LookMemberInfoRs"G
InviteMemberRq
stageId (2$
ext.Base�2 (2.InviteMemberRq"6
InviteMemberRs2$
ext.Base�2 (2.InviteMemberRs"�
SynTeamInfoRq
teamId (
	captainId (
teamType (
order (
teamInfo (2.TeamRoleInfo

actionType (2#
ext.Base� (2.SynTeamInfoRq"F
SynNotifyDisMissTeamRq2,
ext.Base� (2.SynNotifyDisMissTeamRq">
SynNotifyKickOutRq2(
ext.Base� (2.SynNotifyKickOutRq"\
SynChangeStatusRq
roleId (
status (2'
ext.Base� (2.SynChangeStatusRq"E
SynTeamOrderRq
order (2$
ext.Base� (2.SynTeamOrderRq"�
SynTeamChatRq
roleId (
message (	
time (
name (	

serverName (	2#
ext.Base� (2.SynTeamChatRq"D
SynStageCloseToTeamRq2+
ext.Base� (2.SynStageCloseToTeamRq"e
TeamInstanceExchangeRq
goodid (
count (2,
ext.Base�2 (2.TeamInstanceExchangeRq"�
TeamInstanceExchangeRs
	itemCount (
award (2.Award
buyInfo (2.ShopBuy2,
ext.Base�2 (2.TeamInstanceExchangeRs">
GetBountyShopBuyRq2(
ext.Base�2 (2.GetBountyShopBuyRq"
GetBountyShopBuyRs
openWeek (
shopInfo (2.ShopBuy
	itemCount (2(
ext.Base�2 (2.GetBountyShopBuyRs"D
GetTaskRewardStatusRq2+
ext.Base�2 (2.GetTaskRewardStatusRq"a
GetTaskRewardStatusRs
taskInfo (2	.TeamTask2+
ext.Base�2 (2.GetTaskRewardStatusRs"H
GetTaskRewardRq
taskId (2%
ext.Base�2 (2.GetTaskRewardRq"O
GetTaskRewardRs
award (2.Award2%
ext.Base�2 (2.GetTaskRewardRs"8
TeamFightBossRq2%
ext.Base�2 (2.TeamFightBossRq"8
TeamFightBossRs2%
ext.Base�2 (2.TeamFightBossRs"�
SyncTeamFightBossRq
award (2.Award
count (2.TwoInt
record (2.Record
	isSuccess (

recordLord (2.TwoLong
	tankCount (2)
ext.Base� (2.SyncTeamFightBossRq"F
GetTeamFightBossInfoRq2,
ext.Base�2 (2.GetTeamFightBossInfoRq"t
GetTeamFightBossInfoRs
dayItemCount (
count (2.TwoInt2,
ext.Base�2 (2.GetTeamFightBossInfoRs"<
GetFestivalInfoRq2'
ext.Base�2 (2.GetFestivalInfoRq"�
GetFestivalInfoRs
actProp (2.Atom2
loginRewardState (

limitCount (2'
ext.Base�2 (2.GetFestivalInfoRs"[
GetFestivalRewardRq

id (
count (2)
ext.Base�2 (2.GetFestivalRewardRq"�
GetFestivalRewardRs
actProp (2.Atom2

limitCount (
gold (
award (2.Award
	decrAward (2.Award2)
ext.Base�2 (2.GetFestivalRewardRs"J
GetFestivalLoginRewardRq2.
ext.Base�2 (2.GetFestivalLoginRewardRq"{
GetFestivalLoginRewardRs
loginRewardState (
award (2.Award2.
ext.Base�2 (2.GetFestivalLoginRewardRs"<
GetActLuckyInfoRq2'
ext.Base�3 (2.GetActLuckyInfoRq"x
GetActLuckyInfoRs

luckyCount (
poolgold (
rechargegold (2'
ext.Base�3 (2.GetActLuckyInfoRs"O
GetActLuckyRewardRq
count (2)
ext.Base�3 (2.GetActLuckyRewardRq"�
GetActLuckyRewardRs

luckyCount (
award (2.Award
luckyId (
poolgold (2)
ext.Base�3 (2.GetActLuckyRewardRs"J
ActLuckyPoolGoldChangeRq2.
ext.Base�3 (2.ActLuckyPoolGoldChangeRq"\
ActLuckyPoolGoldChangeRs
poolgold (2.
ext.Base�3 (2.ActLuckyPoolGoldChangeRs"B
GetActLuckyPoolLogRq2*
ext.Base�3 (2.GetActLuckyPoolLogRq"e
GetActLuckyPoolLogRs!
luckLog (2.ActLuckyPoolLog2*
ext.Base�3 (2.GetActLuckyPoolLogRs"K
GetRebelBoxAwardRq
pos (2(
ext.Base�4 (2.GetRebelBoxAwardRq"h
GetRebelBoxAwardRs
	leftCount (
award (2.Award2(
ext.Base�4 (2.GetRebelBoxAwardRs"I
GrabRebelRedBagRq
uid (2'
ext.Base�4 (2.GrabRebelRedBagRq"k
GrabRebelRedBagRs
	grabMoney (
redBag (2
.ActRedBag2'
ext.Base�4 (2.GrabRebelRedBagRs"T
ResetMilitaryScienceRq
type (2,
ext.Base�5 (2.ResetMilitaryScienceRq"�
ResetMilitaryScienceRs
award (2.Award
gold ()
militaryScience (2.MilitaryScience1
militaryScienceGrid (2.MilitaryScienceGrid2,
ext.Base�5 (2.ResetMilitaryScienceRs"h
PartConvertRq
pos (
pos2 (
keyIds (2.TwoInt2#
ext.Base�5 (2.PartConvertRq"^
PartConvertRs
	newPartId (2.TwoInt
gold (2#
ext.Base�5 (2.PartConvertRs"i
TankConvertRq
count (
	srcTankId (
	dstTankId (2#
ext.Base�6 (2.TankConvertRq"4
TankConvertRs2#
ext.Base�6 (2.TankConvertRs"B
GetTankConvertInfoRq2*
ext.Base�6 (2.GetTankConvertInfoRq"Q
GetTankConvertInfoRs
count (2*
ext.Base�6 (2.GetTankConvertInfoRs":
GetDrawingCashRq2&
ext.Base�7 (2.GetDrawingCashRq"O
GetDrawingCashRs
cash (2.Cash2&
ext.Base�7 (2.GetDrawingCashRs"N
RefshDrawingCashRq
cashId (2(
ext.Base�7 (2.RefshDrawingCashRq"S
RefshDrawingCashRs
cash (2.Cash2(
ext.Base�7 (2.RefshDrawingCashRs"H
DoDrawingCashRq
cashId (2%
ext.Base�7 (2.DoDrawingCashRq"i
DoDrawingCashRs
award (2.Award
costList (2.Award2%
ext.Base�7 (2.DoDrawingCashRs"T
UpEquipStarLvRq
keyId (
pos (2%
ext.Base�8 (2.UpEquipStarLvRq"y
UpEquipStarLvRs
equip (2.Equip
award (2.Award
	needKeyId (2%
ext.Base�8 (2.UpEquipStarLvRs"F
GetActFortuneDayInfoRq2,
ext.Base�9 (2.GetActFortuneDayInfoRq"t
GetActFortuneDayInfoRs
count (
rewardStatus (2.TwoInt2,
ext.Base�9 (2.GetActFortuneDayInfoRs"S
GetFortuneDayAwardRq
awardId (2*
ext.Base�9 (2.GetFortuneDayAwardRq"Y
GetFortuneDayAwardRs
award (2.Award2*
ext.Base�9 (2.GetFortuneDayAwardRs"F
GetEnergyDialDayInfoRq2,
ext.Base�9 (2.GetEnergyDialDayInfoRq"t
GetEnergyDialDayInfoRs
count (
rewardStatus (2.TwoInt2,
ext.Base�9 (2.GetEnergyDialDayInfoRs"Y
GetEnergyDialDayAwardRq
awardId (2-
ext.Base�9 (2.GetEnergyDialDayAwardRq"_
GetEnergyDialDayAwardRs
award (2.Award2-
ext.Base�9 (2.GetEnergyDialDayAwardRs"<
GetActEquipDialRq2'
ext.Base�9 (2.GetActEquipDialRq"�
GetActEquipDialRs
score (
fortune (2.Fortune
free (
displayList (	2'
ext.Base�9 (2.GetActEquipDialRs"D
GetActEquipDialRankRq2+
ext.Base�9 (2.GetActEquipDialRankRq"�
GetActEquipDialRankRs
score (
open (
status (%
actPlayerRank (2.ActPlayerRank
	rankAward (2
.RankAward2+
ext.Base�9 (2.GetActEquipDialRankRs"M
DoActEquipDialRq
	fortuneId (2&
ext.Base�9 (2.DoActEquipDialRq"`
DoActEquipDialRs
score (
award (2.Award2&
ext.Base�9 (2.DoActEquipDialRs"D
GetEquipDialDayInfoRq2+
ext.Base�9 (2.GetEquipDialDayInfoRq"r
GetEquipDialDayInfoRs
count (
rewardStatus (2.TwoInt2+
ext.Base�9 (2.GetEquipDialDayInfoRs"W
GetEquipDialDayAwardRq
awardId (2,
ext.Base�9 (2.GetEquipDialDayAwardRq"]
GetEquipDialDayAwardRs
award (2.Award2,
ext.Base�9 (2.GetEquipDialDayAwardRs"B
GetActMedalResolveRq2*
ext.Base�9 (2.GetActMedalResolveRq"t
GetActMedalResolveRs
state (!
partResolve (2.PartResolve2*
ext.Base�9 (2.GetActMedalResolveRs"S
DoActMedalResolveRq
	resolveId (2)
ext.Base�9 (2.DoActMedalResolveRq"W
DoActMedalResolveRs
award (2.Award2)
ext.Base�9 (2.DoActMedalResolveRs"c
BuyInBuckRq

activityId (
goodId (
count (2!
ext.Base�9 (2.BuyInBuckRq"|
BuyInBuckRs
award (2.Award
	changeNum (2.TwoInt
actProp (2.Atom22!
ext.Base�9 (2.BuyInBuckRs">
GetActNewPayInfoRq2(
ext.Base�9 (2.GetActNewPayInfoRq"U
GetActNewPayInfoRs
info (2.TwoInt2(
ext.Base�9 (2.GetActNewPayInfoRs"4
ActTechInfoRq2#
ext.Base�9 (2.ActTechInfoRq"K
ActTechInfoRs
quota (2.Quota2#
ext.Base�9 (2.ActTechInfoRs"6
ActBuildInfoRq2$
ext.Base�9 (2.ActBuildInfoRq"M
ActBuildInfoRs
quota (2.Quota2$
ext.Base�9 (2.ActBuildInfoRs"@
GetActNew2PayInfoRq2)
ext.Base�9 (2.GetActNew2PayInfoRq"W
GetActNew2PayInfoRs
info (2.TwoInt2)
ext.Base�9 (2.GetActNew2PayInfoRs"2
GetBoxInfoRq2"
ext.Base�: (2.GetBoxInfoRq"I
GetBoxInfoRs
info (2.TwoInt2"
ext.Base�: (2.GetBoxInfoRs"6
BuyBoxRq

id (2
ext.Base�: (2	.BuyBoxRq"f
BuyBoxRs
info (2.TwoInt
award (2.Award
gold (2
ext.Base�: (2	.BuyBoxRs">
GetScoutFreeTimeRq2(
ext.Base�; (2.GetScoutFreeTimeRq"�
GetScoutFreeTimeRs
time (

scoutCount (
scoutFailCount (
isVerification (2(
ext.Base�; (2.GetScoutFreeTimeRs"A
VCodeScoutRq
imgId (2"
ext.Base�; (2.VCodeScoutRq"
VCodeScoutRs
award (2.Award
time (
scoutFailCount (
status (2"
ext.Base�; (2.VCodeScoutRs"M
RefreshScoutImgRq
isFirst (2'
ext.Base�; (2.RefreshScoutImgRq"m
RefreshScoutImgRs
kindOne (
kindTwo (
imgId (2'
ext.Base�; (2.RefreshScoutImgRs"M
SynActiveBoxDropRq
boxId (2(
ext.Base� (2.SynActiveBoxDropRq"O
GetActiveBoxAwardRq
boxId (2)
ext.Base�< (2.GetActiveBoxAwardRq"W
GetActiveBoxAwardRs
award (2.Award2)
ext.Base�< (2.GetActiveBoxAwardRs"T
SynHonourSurviveOpenRq
type (2,
ext.Base� (2.SynHonourSurviveOpenRq"�
SynUpdateSafeAreaRq
xbegin (
ybegin (
xend (
yend (
phase (2)
ext.Base� (2.SynUpdateSafeAreaRq"�
SynNextSafeAreaRq
pos (
length (
	startTime (
endTime (
phase (2'
ext.Base� (2.SynNextSafeAreaRq"F
GetHonourRankRq
type (2%
ext.Base�< (2.GetHonourRankRq"�
GetHonourRankRs
rank (
score (
	partyName (	
awardStatus (
rankList (2.HonourRank2%
ext.Base�< (2.GetHonourRankRs"U
GetHonourRankAwardRq
	awardType (2*
ext.Base�< (2.GetHonourRankAwardRq"Y
GetHonourRankAwardRs
award (2.Award2*
ext.Base�< (2.GetHonourRankAwardRs"O
HonourCollectInfoRq
keyId (2)
ext.Base�< (2.HonourCollectInfoRq"i
HonourCollectInfoRs

honourGold (
honourScore (2)
ext.Base�< (2.HonourCollectInfoRs"<
GetHonourStatusRq2'
ext.Base�< (2.GetHonourStatusRq"L
GetHonourStatusRs
status (2'
ext.Base�< (2.GetHonourStatusRs"D
HonourScoreGoldInfoRq2+
ext.Base�< (2.HonourScoreGoldInfoRq"t
HonourScoreGoldInfoRs
score (
awardId (
status (2+
ext.Base�< (2.HonourScoreGoldInfoRs"S
GetHonourScoreGoldRq
awardId (2*
ext.Base�< (2.GetHonourScoreGoldRq"Y
GetHonourScoreGoldRs
award (2.Award2*
ext.Base�< (2.GetHonourScoreGoldRs"R
QuickUpMedalRq
keyId (
pos (2$
ext.Base�< (2.QuickUpMedalRq"�
QuickUpMedalRs
luckyUp (
luckyHit (
atom (2.Atom2
cdTime (
upLv (
upExp (
state (2$
ext.Base�< (2.QuickUpMedalRs"D
GetLoginWelfareInfoRq2+
ext.Base�< (2.GetLoginWelfareInfoRq"q
GetLoginWelfareInfoRs
days (
status (
index (2+
ext.Base�< (2.GetLoginWelfareInfoRs"W
GetLoginWelfareAwardRq
awardId (2,
ext.Base�< (2.GetLoginWelfareAwardRq"^
GetLoginWelfareAwardRs
awards (2.Award2,
ext.Base�< (2.GetLoginWelfareAwardRs"U
SetLeqSchemeRq
	leqScheme (2
.LeqScheme2$
ext.Base�< (2.SetLeqSchemeRq"U
SetLeqSchemeRs
	leqScheme (2
.LeqScheme2$
ext.Base�< (2.SetLeqSchemeRs"H
PutonLeqSchemeRq
type (2&
ext.Base�< (2.PutonLeqSchemeRq"d
PutonLeqSchemeRs
leq (2
.LordEquip
resolve (2&
ext.Base�< (2.PutonLeqSchemeRs"<
GetAllLeqSchemeRq2'
ext.Base�< (2.GetAllLeqSchemeRq"[
GetAllLeqSchemeRs
	leqScheme (2
.LeqScheme2'
ext.Base�< (2.GetAllLeqSchemeRs"I
GetNewHeroInfoRq
keyId (2&
ext.Base�< (2.GetNewHeroInfoRq"Y
GetNewHeroInfoRs
gold (
stafExp (2&
ext.Base�< (2.GetNewHeroInfoRs"D
ClearHeroCdRq
heroId (2#
ext.Base�< (2.ClearHeroCdRq"B
ClearHeroCdRs
gold (2#
ext.Base�< (2.ClearHeroCdRs"0
GetHeroCdRq2!
ext.Base�< (2.GetHeroCdRq"k
GetHeroCdRs
heroCd (2.TwoLong
heroClearCount (2.TwoInt2!
ext.Base�< (2.GetHeroCdRs":
GetHeroEndTimeRq2&
ext.Base�< (2.GetHeroEndTimeRq"Y
GetHeroEndTimeRs
heroEndTime (2.TwoLong2&
ext.Base�< (2.GetHeroEndTimeRs"<
GetAllPcbtAwardRq2'
ext.Base�= (2.GetAllPcbtAwardRq"u
GetAllPcbtAwardRs
donate (
combatId (
award (2.Award2'
ext.Base�= (2.GetAllPcbtAwardRs"@
DonateAllPartyResRq2)
ext.Base�= (2.DonateAllPartyResRq"�
DonateAllPartyResRs
stone (
iron (
silicon (
copper (
oil (
build (
isBuild (2)
ext.Base�= (2.DonateAllPartyResRs"[
DonateAllPartyScienceRq
	scienceId (2-
ext.Base�= (2.DonateAllPartyScienceRq"�
DonateAllPartyScienceRs
stone (
iron (
silicon (
copper (
oil (
build (
science (2.Science2-
ext.Base�= (2.DonateAllPartyScienceRs"T
QueSendAnswerRq
answer (2
.QueAnswer2%
ext.Base�= (2.QueSendAnswerRq"b
QueSendAnswerRs
award (2.Award
	queStatus (2%
ext.Base�= (2.QueSendAnswerRs"@
GetQueAwardStatusRq2)
ext.Base�= (2.GetQueAwardStatusRq"S
GetQueAwardStatusRs
	queStatus (2)
ext.Base�= (2.GetQueAwardStatusRs">
GetWorldStaffingRq2(
ext.Base�? (2.GetWorldStaffingRq"`
GetWorldStaffingRs
worldExp (
dayExp (2(
ext.Base�? (2.GetWorldStaffingRs"@
GetNewPayEverydayRq2)
ext.Base�@ (2.GetNewPayEverydayRq"�
GetNewPayEverydayRs
days (
activity (2	.Activity#
activityCond (2.ActivityCond2)
ext.Base�@ (2.GetNewPayEverydayRs">
GetPartyRechargeRq2(
ext.Base�@ (2.GetPartyRechargeRq"�
GetPartyRechargeRs
	totalGold (
partyId (#
activityCond (2.ActivityCond2(
ext.Base�@ (2.GetPartyRechargeRs"B
GetWarActivityInfoRq2*
ext.Base�@ (2.GetWarActivityInfoRq"w
GetWarActivityInfoRs
info (2.TwoInt
rewardState (2.TwoInt2*
ext.Base�@ (2.GetWarActivityInfoRs"R
GetWarActivityRewardRq

id (2,
ext.Base�@ (2.GetWarActivityRewardRq"{
GetWarActivityRewardRs
award (2.Award
rewardState (2.TwoInt2,
ext.Base�@ (2.GetWarActivityRewardRs">
GetFeedAltarBossRq2(
ext.Base�A (2.GetFeedAltarBossRq"`
GetFeedAltarBossRs 
contributeCount (2.TwoInt2(
ext.Base�A (2.GetFeedAltarBossRs"X
GetFeedAltarContriButeRq
type (2.
ext.Base�A (2.GetFeedAltarContriButeRq"�
GetFeedAltarContriButeRs
stone (
iron (
silicon (
copper (
oil (

contribute ( 
contributeCount (2.TwoInt
exp (2.
ext.Base�A (2.GetFeedAltarContriButeRs"2
GetTacticsRq2"
ext.Base�B (2.GetTacticsRq"�
GetTacticsRs
tactics (2.Tactics
tacticsSlice (2.TwoInt
tacticsItem (2.TwoInt!
facticsForm (2.TacticsForm2"
ext.Base�B (2.GetTacticsRs"~
UpgradeTacticsRq
keyId (
consumeKeyId (
tacticsSlice (2.TwoInt2&
ext.Base�B (2.UpgradeTacticsRq"�
UpgradeTacticsRs
tactics (2.Tactics
consumeKeyId (
tacticsSlice (2.TwoInt
award (2.Award2&
ext.Base�B (2.UpgradeTacticsRs"?
TpTacticsRq
keyId (2!
ext.Base�B (2.TpTacticsRq"b
TpTacticsRs
tactics (2.Tactics
atom2 (2.Atom22!
ext.Base�B (2.TpTacticsRs"K
AdvancedTacticsRq
keyId (2'
ext.Base�B (2.AdvancedTacticsRq"n
AdvancedTacticsRs
tactics (2.Tactics
atom2 (2.Atom22'
ext.Base�B (2.AdvancedTacticsRs"M
ComposeTacticsRq
	tacticsId (2&
ext.Base�B (2.ComposeTacticsRq"t
ComposeTacticsRs
tactics (2.Tactics
tacticsSlice (2.TwoInt2&
ext.Base�B (2.ComposeTacticsRs"X
SetTacticsFormRq
index (
keyId (2&
ext.Base�B (2.SetTacticsFormRq"X
SetTacticsFormRs
index (
keyId (2&
ext.Base�B (2.SetTacticsFormRs"K
BindTacticsFormRq
keyId (2'
ext.Base�B (2.BindTacticsFormRq"W
BindTacticsFormRs
tactics (2.Tactics2'
ext.Base�B (2.BindTacticsFormRs"H
GetPsnKillRankRq
type (2&
ext.Base�C (2.GetPsnKillRankRq"�
GetPsnKillRankRs
	startTime (
endTime (
totalNumber (
points (
status (2.TwoInt2&
ext.Base�C (2.GetPsnKillRankRs"4
GetAllRanksRq2#
ext.Base�C (2.GetAllRanksRq"z
GetAllRanksRs
points (

partyPoint ( 
firstRankInfo (2	.KvString2#
ext.Base�C (2.GetAllRanksRs"D
GetRanksInfoRq
type (2$
ext.Base�C (2.GetRanksInfoRq"�
GetRanksInfoRs
myRank (
myPoint (
status (#
kingRankInfo (2.KingRankInfo2$
ext.Base�C (2.GetRanksInfoRs"L
GetKingRankAwardRq
type (2(
ext.Base�C (2.GetKingRankAwardRq"e
GetKingRankAwardRs
award (2.Award
status (2(
ext.Base�C (2.GetKingRankAwardRs"B
GetKingAwardRq

id (2$
ext.Base�C (2.GetKingAwardRq"f
GetKingAwardRs
award (2.Award
status (2.TwoInt2$
ext.Base�C (2.GetKingAwardRs"y
FriendGivePropRq
type (
propId (
count (
friendId (2&
ext.Base�C (2.FriendGivePropRq"Q
FriendGivePropRs
atom2 (2.Atom22&
ext.Base�C (2.FriendGivePropRs"4
GetWipeInfoRq2#
ext.Base�C (2.GetWipeInfoRq"M
GetWipeInfoRs
info (2	.WipeInfo2#
ext.Base�C (2.GetWipeInfoRs"M
SetWipeInfoRq
info (2	.WipeInfo2#
ext.Base�C (2.SetWipeInfoRq"M
SetWipeInfoRs
info (2	.WipeInfo2#
ext.Base�C (2.SetWipeInfoRs"6
GetWipeRewarRq2$
ext.Base�D (2.GetWipeRewarRq"�
GetWipeRewarRs#

rewardInfo (2.WipeRewardInfo
gold (
partBuy (
partEplr (
equipBuy (
	equipEplr (
medalBuy (
	medalEplr (
militaryBuy	 (
militaryEplr
 (
energyStoneBuy (
energyStoneEplrId (

tacticsBuy (
tacticsReset (2$
ext.Base�D (2.GetWipeRewarRs"Y
SyncFreeTimeInfoRq
time (
pos (2(
ext.Base� (2.SyncFreeTimeInfoRq"W
SyncActNewPayInfoRq
info (2.TwoInt2)
ext.Base� (2.SyncActNewPayInfoRq"Y
SyncActNew2PayInfoRq
info (2.TwoInt2*
ext.Base� (2.SyncActNew2PayInfoRq"L
SynBrotherRq

id (
nick (	2"
ext.Base� (2.SynBrotherRq"V
SynAirShipFightTaskRq
taskType (2+
ext.Base� (2.SynAirShipFightTaskRq"@
SynLoginElseWhereRq2)
ext.Base� (2.SynLoginElseWhereRq"U
SynPlugInScoutMineRq
	validCode (	2*
ext.Base� (2.SynPlugInScoutMineRq"Y
SynSendActRedBagRq
chat (2.RedBagChat2(
ext.Base� (2.SynSendActRedBagRq"`
SynWorldStaffingRq
worldExp (
dayExp (2(
ext.Base� (2.SynWorldStaffingRq"Y
SynWarActivityInfoRq
info (2.TwoInt2*
ext.Base� (2.SynWarActivityInfoRq"]
SynFeedAltarContriButeExpRq
exp (21
ext.Base� (2.SynFeedAltarContriButeExpRq"M
SynTacticsRq
tactics (2.Tactics2"
ext.Base� (2.SynTacticsRq"U
SynFriendlinessRq
friend (2.Friend2'
ext.Base� (2.SynFriendlinessRq"U
RebelBoosStateRq
	boosState (2.Rebel2&
ext.Base� (2.RebelBoosStateRq"U
RebelBoosEffectRq
effect (2.Effect2'
ext.Base� (2.RebelBoosEffectRq"i
SynCrossServerInfoRq
state (
crossMineState (2*
ext.Base� (2.SynCrossServerInfoRq"8
GetActTicDialRq2%
ext.Base�D (2.GetActTicDialRq"�
GetActTicDialRs
score (
fortune (2.Fortune
free (
displayList (	2%
ext.Base�D (2.GetActTicDialRs"@
GetActTicDialRankRq2)
ext.Base�D (2.GetActTicDialRankRq"�
GetActTicDialRankRs
score (
open (
status (%
actPlayerRank (2.ActPlayerRank
	rankAward (2
.RankAward2)
ext.Base�D (2.GetActTicDialRankRs"I
DoActTicDialRq
	fortuneId (2$
ext.Base�D (2.DoActTicDialRq"\
DoActTicDialRs
score (
award (2.Award2$
ext.Base�D (2.DoActTicDialRs"@
GetTicDialDayInfoRq2)
ext.Base�D (2.GetTicDialDayInfoRq"n
GetTicDialDayInfoRs
count (
rewardStatus (2.TwoInt2)
ext.Base�D (2.GetTicDialDayInfoRs"S
GetTicDialDayAwardRq
awardId (2*
ext.Base�D (2.GetTicDialDayAwardRq"Y
GetTicDialDayAwardRs
award (2.Award2*
ext.Base�D (2.GetTicDialDayAwardRs"2
EnergyCoreRq2"
ext.Base�D (2.EnergyCoreRq"n
EnergyCoreRs
coreInfo (2	.ThreeInt
state (
redExp (2"
ext.Base�D (2.EnergyCoreRs"T
SmeltCoreEquipRq
equip (2	.ThreeInt2&
ext.Base�D (2.SmeltCoreEquipRq"�
SmeltCoreEquipRs
coreInfo (2	.ThreeInt
atom (2.Atom2
state (
redExp (2&
ext.Base�D (2.SmeltCoreEquipRs"B
GetCrossServerInfoRq2*
ext.Base�D (2.GetCrossServerInfoRq"�
GetCrossServerInfoRs
state (
info (2.GameServerInfo
crossMineState (2*
ext.Base�D (2.GetCrossServerInfoRs"@
GetCrossSeniorMapRq2)
ext.Base�D (2.GetCrossSeniorMapRq"�
GetCrossSeniorMapRs
data (2.SeniorMapData
count (
limit (
buy (2)
ext.Base�D (2.GetCrossSeniorMapRs"O
SctCrossSeniorMineRq
pos (2*
ext.Base�D (2.SctCrossSeniorMineRq"W
SctCrossSeniorMineRs
mail (2.Mail2*
ext.Base�D (2.SctCrossSeniorMineRs"r
AtkCrossSeniorMineRq
pos (
form (2.Form
type (2*
ext.Base�D (2.AtkCrossSeniorMineRq"f
AtkCrossSeniorMineRs
army (2.Army
count (2*
ext.Base�D (2.AtkCrossSeniorMineRs":
CrossScoreRankRq2&
ext.Base�D (2.CrossScoreRankRq"�
CrossScoreRankRs
	scoreRank (2
.ScoreRank
score (
canGet (
rank (2&
ext.Base�D (2.CrossScoreRankRs"<
CrossScoreAwardRq2'
ext.Base�D (2.CrossScoreAwardRq"S
CrossScoreAwardRs
award (2.Award2'
ext.Base�D (2.CrossScoreAwardRs"F
CrossServerScoreRankRq2,
ext.Base�D (2.CrossServerScoreRankRq"�
CrossServerScoreRankRs
	scoreRank (2
.ScoreRank
canGet (
score (
rank (2,
ext.Base�D (2.CrossServerScoreRankRs"H
CrossServerScoreAwardRq2-
ext.Base�D (2.CrossServerScoreAwardRq"_
CrossServerScoreAwardRs
award (2.Award2-
ext.Base�D (2.CrossServerScoreAwardRsB
com.game.pbBGamePb