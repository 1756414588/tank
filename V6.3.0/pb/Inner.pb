
›:
Inner.proto
Base.protoCommon.protoSerialize.proto"T

RegisterRq
serverId (

serverName (	2 
ext.BaseÈ (2.RegisterRq"=

RegisterRs
state (2 
ext.BaseÍ (2.RegisterRs"•
VerifyRq
keyId (
serverId (
token (	

curVersion (	
deviceNo (	
	channelId (
clientId (	2
ext.BaseÎ (2	.VerifyRq"«
VerifyRs
keyId (
platId (	
platNo (
childNo (

curVersion (	
deviceNo (	
serverId (
	channelId (
clientId	 (	2
ext.BaseÏ (2	.VerifyRs"t
UseGiftCodeRq
code (	
serverId (
lordId (
platNo (2#
ext.BaseÌ (2.UseGiftCodeRq"t
UseGiftCodeRs
award (	
serverId (
lordId (
state (2#
ext.BaseÓ (2.UseGiftCodeRs"±
	PayBackRq
platNo (
platId (	
orderId (	
serialId (	
serverId (
roleId (
amount (
packId (2
ext.BaseÔ (2
.PayBackRq",
	PayBackRs2
ext.Base (2
.PayBackRs"d
PayConfirmRq
platNo (
orderId (	
addGold (2"
ext.BaseÒ (2.PayConfirmRq"2
PayConfirmRs2"
ext.BaseÚ (2.PayConfirmRs"ó
SendToMailRq
type (
	channelNo (	
online (

to (	
sendName (	
moldId (	
title (	
contont (	
award	 (	
marking
 (	
alv (
blv (
avip (
bvip (
partys (	2"
ext.BaseÛ (2.SendToMailRq"Q
SendToMailRs
marking (	
code (2"
ext.BaseÙ (2.SendToMailRs"Ç
ForbiddenRq
marking (	
forbiddenId (
nick (	
lordId (
time (2!
ext.Baseı (2.ForbiddenRq"0
ForbiddenRs2!
ext.Baseˆ (2.ForbiddenRs"L
NoticeRq
marking (	
content (	2
ext.Base˜ (2	.NoticeRq"*
NoticeRs2
ext.Base¯ (2	.NoticeRs"c
GetLordBaseRq
marking (	
lordId (
type (2#
ext.Base˘ (2.GetLordBaseRq"4
GetLordBaseRs2#
ext.Base˙ (2.GetLordBaseRs"|
BackLordBaseRq
marking (	
code (
type (
towInt (2.TwoInt2$
ext.Base˚ (2.BackLordBaseRq"6
BackLordBaseRs2$
ext.Base¸ (2.BackLordBaseRs"à
BackBuildingRq
marking (	
code (
type (
ware1 (
ware2 (
tech (
factory1 (
factory2 (
refit	 (
command
 (
workShop (
leqm (
mill (2.Mill2$
ext.Base˝ (2.BackBuildingRq"6
BackBuildingRs2$
ext.Base˛ (2.BackBuildingRs"p

BackPartRq
marking (	
code (
type (
part (2.Part2 
ext.Baseˇ (2.BackPartRq".

BackPartRs2 
ext.BaseÄ (2.BackPartRs"h
ModVipRq
marking (	
lordId (
type (
value (2
ext.BaseÅ (2	.ModVipRq"*
ModVipRs2
ext.BaseÇ (2	.ModVipRs":
RecalcResourceRq2&
ext.BaseÉ (2.RecalcResourceRq":
RecalcResourceRs2&
ext.BaseÑ (2.RecalcResourceRs"ì
CensusBaseRq
marking (	
alv (
blv (
vip (
type (

id (
count (2"
ext.BaseÖ (2.CensusBaseRq"2
CensusBaseRs2"
ext.BaseÜ (2.CensusBaseRs"t
BackEquipRq
marking (	
code (
type (
equip (2.Equip2!
ext.Baseá (2.BackEquipRq"0
BackEquipRs2!
ext.Baseà (2.BackEquipRs"â
	ModLordRq
marking (	
lordId (
type (
keyId (
value (
value2 (2
ext.Baseâ (2
.ModLordRq",
	ModLordRs2
ext.Baseä (2
.ModLordRs"h
ForbidByIdRq
marking (	
forbiddenId (
lordId (2"
ext.Baseã (2.ForbidByIdRq"2
ForbidByIdRs2"
ext.Baseå (2.ForbidByIdRs"ó
NotifyCrossOnLineRq
crossIp (	
port (
	beginTime (	
	crossType (
serverId (2)
ext.Baseç (2.NotifyCrossOnLineRq"S
ReloadParamRq
marking (	
type (2#
ext.Baseè (2.ReloadParamRq"4
ReloadParamRs2#
ext.Baseê (2.ReloadParamRs"m
NotifyServerRegRq
regType (
serverIp (	
port (2'
ext.Baseë (2.NotifyServerRegRq"M
NotifyServerRegRs
regType (2'
ext.Baseí (2.NotifyServerRegRs"`
MergeServerRegRq
serverId (

serverName (	2&
ext.Baseì (2.MergeServerRegRq":
MergeServerRegRs2&
ext.Baseî (2.MergeServerRegRs"F
NotifyServerTransferRq2,
ext.Baseï (2.NotifyServerTransferRq"F
NotifyServerTransferRs2,
ext.Baseñ (2.NotifyServerTransferRs"m
TransferCommonDataRq
party (2
.SerPParty
isLast (2*
ext.Baseó (2.TransferCommonDataRq"W
TransferCommonDataRs
failPartyId (2*
ext.Baseò (2.TransferCommonDataRs"s
TransferPlayerDataRq
player (2.FullPlayerData
isLast (2*
ext.Baseô (2.TransferPlayerDataRq"R
TransferPlayerDataRs
lordId (2*
ext.Baseö (2.TransferPlayerDataRs"`
GetRankBaseRq
marking (	
type (
num (2#
ext.Baseõ (2.GetRankBaseRq"4
GetRankBaseRs2#
ext.Baseú (2.GetRankBaseRs"Ä
BackRankBaseRq
marking (	
code (
type (
rankData (2	.RankData2$
ext.Baseù (2.BackRankBaseRq"6
BackRankBaseRs2$
ext.Baseû (2.BackRankBaseRs"`
GetPartyMembersRq
marking (	
	partyName (	2'
ext.Baseü (2.GetPartyMembersRq"<
GetPartyMembersRs2'
ext.Base† (2.GetPartyMembersRs"Ä
BackPartyMembersRq
marking (	
code (!
partyMember (2.PartyMember2(
ext.Base° (2.BackPartyMembersRq">
BackPartyMembersRs2(
ext.Base¢ (2.BackPartyMembersRs"n
ModPartyMemberJobRq
marking (	
lordId (
job (2)
ext.Base£ (2.ModPartyMemberJobRq"@
ModPartyMemberJobRs2)
ext.Base§ (2.ModPartyMemberJobRs"q

BackFormRq
marking (	
code (
type (
Forms (2.Form2 
ext.Base• (2.BackFormRq"D

BackFormRs
Forms (2.Form2 
ext.Base¶ (2.BackFormRs"ò
ServerErrorLogRq
serverId (
dataType (

errorCount (
	errorDesc (	
	errorTime (2&
ext.Baseß (2.ServerErrorLogRq":
ServerErrorLogRs2&
ext.Base® (2.ServerErrorLogRs"j
	ModPropRq
marking (	
lordId (
type (
props (	2
ext.Base© (2
.ModPropRq",
	ModPropRs2
ext.Base™ (2
.ModPropRs"[
	ModNameRq
marking (	
lordId (
name (	2
ext.Base´ (2
.ModNameRq",
	ModNameRs2
ext.Base¨ (2
.ModNameRs"]
ChangePlatNoRq
	srcLordId (

destLordId (2$
ext.BaseØ (2.ChangePlatNoRq"6
ChangePlatNoRs2$
ext.Base∞ (2.ChangePlatNoRs"p
LordRelevanceRq
marking (	
	srcLordId (

destLordId (2%
ext.Base± (2.LordRelevanceRq"8
LordRelevanceRs2%
ext.Base≤ (2.LordRelevanceRs"W
HotfixClassRq
marking (	
hotfixId (	2#
ext.Base≥ (2.HotfixClassRq"4
HotfixClassRs2#
ext.Base¥ (2.HotfixClassRs"6
ExecutHotfixRq2$
ext.Baseµ (2.ExecutHotfixRq"6
ExecutHotfixRs2$
ext.Base∂ (2.ExecutHotfixRs"r
AddAttackFreeBuffRq
second (
lordId (
sendMail (2)
ext.Base∑ (2.AddAttackFreeBuffRq"@
AddAttackFreeBuffRs2)
ext.Base∏ (2.AddAttackFreeBuffRs"Y
GetEnergyBaseRq
marking (	
lordId (2%
ext.Baseπ (2.GetEnergyBaseRq"8
GetEnergyBaseRs2%
ext.Base∫ (2.GetEnergyBaseRs"p
BackEnergyRq
marking (	
code (
info (2.LordEnergyInfo2"
ext.Baseª (2.BackEnergyRq"2
BackEnergyRs2"
ext.Baseº (2.BackEnergyRsB
com.game.pbBInnerPb