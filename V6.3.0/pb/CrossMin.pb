
�
CrossMin.proto
Base.protoCommon.proto"�
CrossMinNotifyRq
type (
connectType (	
crossIp (	
port (
rpcPort (
serverId (2&
ext.Base�F (2.CrossMinNotifyRq"�
CrossMinGameServerRegRq
connectType (	
serverId (

serverName (	2-
ext.Base�F (2.CrossMinGameServerRegRq"�
CrossMinGameServerRegRs
crossServerName (	
crossServerId (
connectType (	2-
ext.Base�F (2.CrossMinGameServerRegRs"^
CrossMinHeartRq
serverId (

serverName (	2%
ext.Base�F (2.CrossMinHeartRq"h
CrossMinHeartRs
crossServerName (	
crossServerId (2%
ext.Base�F (2.CrossMinHeartRs"Z
CrossNotifyDisMissTeamRq
roleId (2.
ext.Base�F (2.CrossNotifyDisMissTeamRq"�
CrossSynTeamInfoRq
code (
roleId (
teamId (
	captainId (
teamType (
order (
teamInfo (2.TeamRoleInfo

actionType (2(
ext.Base�F (2.CrossSynTeamInfoRq"X
CrossSynNotifyKickOutRq
roleId (2-
ext.Base�F (2.CrossSynNotifyKickOutRq"t
CrossSynChangeStatusRq
roleId (
status (
role (2,
ext.Base�F (2.CrossSynChangeStatusRq"�
CrossSynTeamChatRq
roleId (
message (	
time (
name (	
role (

serverName (	2(
ext.Base�F (2.CrossSynTeamChatRq"�
CrossSynTeamInviteRq
nickName (	
sysId (
teamId (
param (	2*
ext.Base�F (2.CrossSynTeamInviteRq"^
CrossSynStageCloseToTeamRq
roldId (20
ext.Base�F (2.CrossSynStageCloseToTeamRq"h
CrossSynTaskRq
roleId (
taskType (
comNum (2$
ext.Base�F (2.CrossSynTaskRq"�
CrossSyncTeamFightBossRq
roleId (
stageId (
	isSuccess (
record (2.Record

recordLord (2.TwoLong
	tankCount (2.
ext.Base�F (2.CrossSyncTeamFightBossRq"�
CrossWorldChatRq
roleId (
content (	
time (
nickName (	
port (
bubble (
isGm (

lv (
staffing	 (
military
 (
vip (

serverName (	
fight (
	partyName (	2&
ext.Base�F (2.CrossWorldChatRq"B
CrossFightRq
roleId (2"
ext.Base�F (2.CrossFightRq"B
CrossFightRs
roleId (2"
ext.Base�F (2.CrossFightRs"x
CrossMineAttack
roleId (
army (2.Army
now (
load (2%
ext.Base�F (2.CrossMineAttack"�
CrossNpcMine
roleId (

attackTank (2.TwoInt
	deferTank (2.TwoInt
mplts (2.TwoLong
result (
atterReborn (
type (
attAkey (
pos	 (
rpt
 (2.RptAtkMine
atterFormNum (
now (2"
ext.Base�F (2.CrossNpcMine"�
	CrossMine
roleId (

attackTank (2.TwoInt
	deferTank (2.TwoInt
honor (
mplts (2.TwoLong
result (
atterReborn (
get (
type	 (
attAkey
 (
defAkey (
pos (
	defReborn (
rpt (2.RptAtkMine
atterFormNum (
deferFormNum (
suExp (
faExp (
now (
attForm (2.Form

attackName (	
attackLevel (2
ext.Base�F (2
.CrossMine"g
CrossTeamChatRq
roleId (
message (	
time (2%
ext.Base�F (2.CrossTeamChatRqB
com.game.pbB
CrossMinPb