#ifndef LOADLIB_HPP
#define LOADLIB_HPP
#include <windows.h>
#include <stdlib.h>
#include <iostream>
HINSTANCE dll;

typedef char * (__stdcall *Api_GetGtk_Bkn_ptr)(char * );
Api_GetGtk_Bkn_ptr Api_GetGtk_Bkn;
typedef char * (__stdcall *Api_GetBkn32_ptr)(char * );
Api_GetBkn32_ptr Api_GetBkn32;
typedef char * (__stdcall *Api_GetLdw_ptr)(char * );
Api_GetLdw_ptr Api_GetLdw;
typedef char * (__stdcall *Api_GetRunPath_ptr)();
Api_GetRunPath_ptr Api_GetRunPath;
typedef char * (__stdcall *Api_GetOnlineQQlist_ptr)();
Api_GetOnlineQQlist_ptr Api_GetOnlineQQlist;
typedef char * (__stdcall *Api_GetQQlist_ptr)();
Api_GetQQlist_ptr Api_GetQQlist;
typedef char * (__stdcall *Api_GetSessionkey_ptr)(char * );
Api_GetSessionkey_ptr Api_GetSessionkey;
typedef char * (__stdcall *Api_GetClientkey_ptr)(char * );
Api_GetClientkey_ptr Api_GetClientkey;
typedef char * (__stdcall *Api_GetLongClientkey_ptr)(char * );
Api_GetLongClientkey_ptr Api_GetLongClientkey;
typedef char * (__stdcall *Api_GetCookies_ptr)(char * );
Api_GetCookies_ptr Api_GetCookies;
typedef char * (__stdcall *Api_GetPrefix_ptr)();
Api_GetPrefix_ptr Api_GetPrefix;
typedef void (__stdcall *Api_Cache_NameCard_ptr)(char * ,char * ,char * );
Api_Cache_NameCard_ptr Api_Cache_NameCard;
typedef void (__stdcall *Api_DBan_ptr)(char * ,char * );
Api_DBan_ptr Api_DBan;
typedef void (__stdcall *Api_Ban_ptr)(char * ,char * );
Api_Ban_ptr Api_Ban;
typedef bool (__stdcall *Api_Shutup_ptr)(char * ,char * ,char * ,int );
Api_Shutup_ptr Api_Shutup;
typedef bool (__stdcall *Api_IsShutup_ptr)(char *,char *, char *);
Api_IsShutup_ptr Api_IsShutup;
typedef void (__stdcall *Api_SetNotice_ptr)(char * ,char * ,char * ,char * );
Api_SetNotice_ptr Api_SetNotice;
typedef char * (__stdcall *Api_GetNotice_ptr)(char * ,char * );
Api_GetNotice_ptr Api_GetNotice;
typedef char * (__stdcall *Api_GetNameCard_ptr)(char * ,char * ,char * );
Api_GetNameCard_ptr Api_GetNameCard;
typedef void (__stdcall *Api_SetNameCard_ptr)(char * ,char * ,char * ,char * );
Api_SetNameCard_ptr Api_SetNameCard;
typedef void (__stdcall *Api_QuitDG_ptr)(char * ,char * );
Api_QuitDG_ptr Api_QuitDG;
typedef bool (__stdcall *Api_DelFriend_ptr)(char * ,char * );
Api_DelFriend_ptr Api_DelFriend;
typedef bool (__stdcall *Api_Kick_ptr)(char * ,char * ,char * );
Api_Kick_ptr Api_Kick;
typedef void (__stdcall *Api_JoinGroup_ptr)(char * ,char * ,char * );
Api_JoinGroup_ptr Api_JoinGroup;
typedef void (__stdcall *Api_QuitGroup_ptr)(char * ,char * );
Api_QuitGroup_ptr Api_QuitGroup;
typedef char * (__stdcall *Api_UploadPic_ptr)(char * ,int ,char * ,unsigned char * );
Api_UploadPic_ptr Api_UploadPic;
typedef char * (__stdcall *Api_GuidGetPicLink_ptr)(char * );
Api_GuidGetPicLink_ptr Api_GuidGetPicLink;
typedef int (__stdcall *Api_Reply_ptr)(char * ,int ,char * ,char * );
Api_Reply_ptr Api_Reply;
typedef int (__stdcall *Api_SendMsg_ptr)(char * ,int ,int ,char * ,char * ,char * );
Api_SendMsg_ptr Api_SendMsg;
typedef char * (__stdcall *Api_Send_ptr)(char * );
Api_Send_ptr Api_Send;
typedef int (__stdcall *Api_OutPut_ptr)(char * );
Api_OutPut_ptr Api_OutPut;
typedef bool (__stdcall *Api_IsEnable_ptr)();
Api_IsEnable_ptr Api_IsEnable;
typedef bool (__stdcall *Api_Login_ptr)(char * );
Api_Login_ptr Api_Login;
typedef void (__stdcall *Api_Logout_ptr)(char * );
Api_Logout_ptr Api_Logout;
typedef char * (__stdcall *Api_TeaEncrypt_ptr)(char * ,char * );
Api_TeaEncrypt_ptr Api_TeaEncrypt;
typedef char * (__stdcall *Api_TeaDecrypt_ptr)(char * ,char * );
Api_TeaDecrypt_ptr Api_TeaDecrypt;
typedef char * (__stdcall *Api_GetNick_ptr)(char * );
Api_GetNick_ptr Api_GetNick;
typedef char * (__stdcall *Api_GetQQLevel_ptr)(char * );
Api_GetQQLevel_ptr Api_GetQQLevel;
typedef char * (__stdcall *Api_GNGetGid_ptr)(char * );
Api_GNGetGid_ptr Api_GNGetGid;
typedef char * (__stdcall *Api_GidGetGN_ptr)(char * );
Api_GidGetGN_ptr Api_GidGetGN;
typedef int (__stdcall *Api_GetVersion_ptr)();
Api_GetVersion_ptr Api_GetVersion;
typedef char * (__stdcall *Api_GetVersionName_ptr)();
Api_GetVersionName_ptr Api_GetVersionName;
typedef int (__stdcall *Api_GetTimeStamp_ptr)();
Api_GetTimeStamp_ptr Api_GetTimeStamp;
typedef char * (__stdcall *Api_GetLog_ptr)();
Api_GetLog_ptr Api_GetLog;
typedef bool (__stdcall *Api_IfBlock_ptr)(char * );
Api_IfBlock_ptr Api_IfBlock;
typedef char * (__stdcall *Api_GetAdminList_ptr)(char * ,char * );
Api_GetAdminList_ptr Api_GetAdminList;
typedef char * (__stdcall *Api_AddTaotao_ptr)(char * ,char * );
Api_AddTaotao_ptr Api_AddTaotao;
typedef char * (__stdcall *Api_GetSign_ptr)(char * ,char * );
Api_GetSign_ptr Api_GetSign;
typedef char * (__stdcall *Api_SetSign_ptr)(char * ,char * );
Api_SetSign_ptr Api_SetSign;
typedef char * (__stdcall *Api_GetGroupListA_ptr)(char * );
Api_GetGroupListA_ptr Api_GetGroupListA;
typedef char * (__stdcall *Api_GetGroupListB_ptr)(char * );
Api_GetGroupListB_ptr Api_GetGroupListB;
typedef char * (__stdcall *Api_GetGroupMemberA_ptr)(char * ,char * );
Api_GetGroupMemberA_ptr Api_GetGroupMemberA;
typedef char * (__stdcall *Api_GetGroupMemberB_ptr)(char * ,char * );
Api_GetGroupMemberB_ptr Api_GetGroupMemberB;
typedef char * (__stdcall *Api_GetFriendList_ptr)(char * );
Api_GetFriendList_ptr Api_GetFriendList;
typedef int (__stdcall *Api_GetQQAge_ptr)(char * ,char * );
Api_GetQQAge_ptr Api_GetQQAge;
typedef int (__stdcall *Api_GetAge_ptr)(char * ,char * );
Api_GetAge_ptr Api_GetAge;
typedef char * (__stdcall *Api_GetPersonalProfile_ptr)(char * ,char * );
Api_GetPersonalProfile_ptr Api_GetPersonalProfile;
typedef char * (__stdcall *Api_GetEmail_ptr)(char * ,char * );
Api_GetEmail_ptr Api_GetEmail;
typedef int (__stdcall *Api_GetGender_ptr)(char * ,char * );
Api_GetGender_ptr Api_GetGender;
typedef int (__stdcall *Api_SendTyping_ptr)(char * ,char * );
Api_SendTyping_ptr Api_SendTyping;
typedef int (__stdcall *Api_SendShake_ptr)(char * ,char * );
Api_SendShake_ptr Api_SendShake;
typedef char * (__stdcall *Api_GetRadomOnlineQQ_ptr)();
Api_GetRadomOnlineQQ_ptr Api_GetRadomOnlineQQ;
typedef bool (__stdcall *Api_AddQQ_ptr)(char * ,char * ,bool );
Api_AddQQ_ptr Api_AddQQ;
typedef bool (__stdcall *Api_SetOLStatus_ptr)(char * ,int ,char * );
Api_SetOLStatus_ptr Api_SetOLStatus;
typedef char * (__stdcall *Api_GetMC_ptr)();
Api_GetMC_ptr Api_GetMC;
typedef char * (__stdcall *Api_GroupInvitation_ptr)(char * ,char * ,char * );
Api_GroupInvitation_ptr Api_GroupInvitation;
typedef char * (__stdcall *Api_CreateDG_ptr)(char * );
Api_CreateDG_ptr Api_CreateDG;
typedef char * (__stdcall *Api_KickDG_ptr)(char * ,char * ,char * );
Api_KickDG_ptr Api_KickDG;
typedef char * (__stdcall *Api_DGInvitation_ptr)(char * ,char * ,char * );
Api_DGInvitation_ptr Api_DGInvitation;
typedef char * (__stdcall *Api_GetDGList_ptr)(char * );
Api_GetDGList_ptr Api_GetDGList;
typedef bool (__stdcall *Api_SendMusic_ptr)(char * ,int ,char * ,char * ,char * ,char * ,char * ,char * ,char * ,char * ,char * ,char * );
Api_SendMusic_ptr Api_SendMusic;
typedef bool (__stdcall *Api_SendObjectMsg_ptr)(char * ,int ,char * ,char * ,char * ,int );
Api_SendObjectMsg_ptr Api_SendObjectMsg;
typedef bool (__stdcall *Api_IsFriend_ptr)(char *, char *);
Api_IsFriend_ptr Api_IsFriend;
typedef bool (__stdcall *Api_AddFriend_ptr)(char *, char *, char*);
Api_AddFriend_ptr Api_AddFriend;
typedef void (__stdcall *Api_SelfDisable_ptr)();
Api_SelfDisable_ptr Api_SelfDisable;
typedef int (__stdcall *Api_GetClientType_ptr)();
Api_GetClientType_ptr Api_GetClientType;
typedef int (__stdcall *Api_GetClientVer_ptr)();
Api_GetClientVer_ptr Api_GetClientVer;
typedef int (__stdcall *Api_GetPubNo_ptr)();
Api_GetPubNo_ptr Api_GetPubNo;
typedef int (__stdcall *Api_GetMainVer_ptr)();
Api_GetMainVer_ptr Api_GetMainVer;
typedef int (__stdcall *Api_GetTXSSOVer_ptr)();
Api_GetTXSSOVer_ptr Api_GetTXSSOVer;
typedef char * (__stdcall *Api_UploadVoice_ptr)(char *, int);
Api_UploadVoice_ptr Api_UploadVoice;
typedef char * (__stdcall *Api_GuidGetVoiceLink_ptr)(char *, char *);
Api_GuidGetVoiceLink_ptr Api_GuidGetVoiceLink;
typedef char * (__stdcall *Api_AddLogHandler_ptr)(int); //???
Api_AddLogHandler_ptr Api_AddLogHandler;
typedef char * (__stdcall *Api_RemoveLogHandler_ptr)();
Api_RemoveLogHandler_ptr Api_RemoveLogHandler;

void croak(const char * string)
{
  std::cout << string << std::endl;
  exit(1);
}

void loadLibs()
{
    if (! (dll = LoadLibrary("Message.dll"))) {
    croak("cannot load dll.");
  }
if (! (Api_GetGtk_Bkn = (Api_GetGtk_Bkn_ptr)GetProcAddress(dll, "Api_GetGtk_Bkn"))) {
  croak("cannot load Api_GetGtk_Bkn");
}
if (! (Api_GetBkn32 = (Api_GetBkn32_ptr)GetProcAddress(dll, "Api_GetBkn32"))) {
  croak("cannot load Api_GetBkn32");
}
if (! (Api_GetLdw = (Api_GetLdw_ptr)GetProcAddress(dll, "Api_GetLdw"))) {
  croak("cannot load Api_GetLdw");
}
if (! (Api_GetRunPath = (Api_GetRunPath_ptr)GetProcAddress(dll, "Api_GetRunPath"))) {
  croak("cannot load Api_GetRunPath");
}
if (! (Api_GetOnlineQQlist = (Api_GetOnlineQQlist_ptr)GetProcAddress(dll, "Api_GetOnlineQQlist"))) {
  croak("cannot load Api_GetOnlineQQlist");
}
if (! (Api_GetQQlist = (Api_GetQQlist_ptr)GetProcAddress(dll, "Api_GetQQlist"))) {
  croak("cannot load Api_GetQQlist");
}
if (! (Api_GetSessionkey = (Api_GetSessionkey_ptr)GetProcAddress(dll, "Api_GetSessionkey"))) {
  croak("cannot load Api_GetSessionkey");
}
if (! (Api_GetClientkey = (Api_GetClientkey_ptr)GetProcAddress(dll, "Api_GetClientkey"))) {
  croak("cannot load Api_GetClientkey");
}
if (! (Api_GetLongClientkey = (Api_GetLongClientkey_ptr)GetProcAddress(dll, "Api_GetLongClientkey"))) {
  croak("cannot load Api_GetLongClientkey");
}
if (! (Api_GetCookies = (Api_GetCookies_ptr)GetProcAddress(dll, "Api_GetCookies"))) {
  croak("cannot load Api_GetCookies");
}
if (! (Api_GetPrefix = (Api_GetPrefix_ptr)GetProcAddress(dll, "Api_GetPrefix"))) {
  croak("cannot load Api_GetPrefix");
}
if (! (Api_Cache_NameCard = (Api_Cache_NameCard_ptr)GetProcAddress(dll, "Api_Cache_NameCard"))) {
  croak("cannot load Api_Cache_NameCard");
}
if (! (Api_DBan = (Api_DBan_ptr)GetProcAddress(dll, "Api_DBan"))) {
  croak("cannot load Api_DBan");
}
if (! (Api_Ban = (Api_Ban_ptr)GetProcAddress(dll, "Api_Ban"))) {
  croak("cannot load Api_Ban");
}
if (! (Api_Shutup = (Api_Shutup_ptr)GetProcAddress(dll, "Api_Shutup"))) {
  croak("cannot load Api_Shutup");
}
if (! (Api_IsShutup = (Api_IsShutup_ptr)GetProcAddress(dll, "Api_IsShutup"))) {
  croak("cannot load Api_IsShutup");
}
if (! (Api_SetNotice = (Api_SetNotice_ptr)GetProcAddress(dll, "Api_SetNotice"))) {
  croak("cannot load Api_SetNotice");
}
if (! (Api_GetNotice = (Api_GetNotice_ptr)GetProcAddress(dll, "Api_GetNotice"))) {
  croak("cannot load Api_GetNotice");
}
if (! (Api_GetNameCard = (Api_GetNameCard_ptr)GetProcAddress(dll, "Api_GetNameCard"))) {
  croak("cannot load Api_GetNameCard");
}
if (! (Api_SetNameCard = (Api_SetNameCard_ptr)GetProcAddress(dll, "Api_SetNameCard"))) {
  croak("cannot load Api_SetNameCard");
}
if (! (Api_QuitDG = (Api_QuitDG_ptr)GetProcAddress(dll, "Api_QuitDG"))) {
  croak("cannot load Api_QuitDG");
}
if (! (Api_DelFriend = (Api_DelFriend_ptr)GetProcAddress(dll, "Api_DelFriend"))) {
  croak("cannot load Api_DelFriend");
}
if (! (Api_Kick = (Api_Kick_ptr)GetProcAddress(dll, "Api_Kick"))) {
  croak("cannot load Api_Kick");
}
if (! (Api_JoinGroup = (Api_JoinGroup_ptr)GetProcAddress(dll, "Api_JoinGroup"))) {
  croak("cannot load Api_JoinGroup");
}
if (! (Api_QuitGroup = (Api_QuitGroup_ptr)GetProcAddress(dll, "Api_QuitGroup"))) {
  croak("cannot load Api_QuitGroup");
}
if (! (Api_UploadPic = (Api_UploadPic_ptr)GetProcAddress(dll, "Api_UploadPic"))) {
  croak("cannot load Api_UploadPic");
}
if (! (Api_GuidGetPicLink = (Api_GuidGetPicLink_ptr)GetProcAddress(dll, "Api_GuidGetPicLink"))) {
  croak("cannot load Api_GuidGetPicLink");
}
if (! (Api_Reply = (Api_Reply_ptr)GetProcAddress(dll, "Api_Reply"))) {
  croak("cannot load Api_Reply");
}
if (! (Api_SendMsg = (Api_SendMsg_ptr)GetProcAddress(dll, "Api_SendMsg"))) {
  croak("cannot load Api_SendMsg");
}
if (! (Api_Send = (Api_Send_ptr)GetProcAddress(dll, "Api_Send"))) {
  croak("cannot load Api_Send");
}
if (! (Api_OutPut = (Api_OutPut_ptr)GetProcAddress(dll, "Api_OutPut"))) {
  croak("cannot load Api_OutPut");
}
if (! (Api_IsEnable = (Api_IsEnable_ptr)GetProcAddress(dll, "Api_IsEnable"))) {
  croak("cannot load Api_IsEnable");
}
if (! (Api_Login = (Api_Login_ptr)GetProcAddress(dll, "Api_Login"))) {
  croak("cannot load Api_Login");
}
if (! (Api_Logout = (Api_Logout_ptr)GetProcAddress(dll, "Api_Logout"))) {
  croak("cannot load Api_Logout");
}
 if (! (Api_TeaEncrypt = (Api_TeaEncrypt_ptr)GetProcAddress(dll, "Api_Tea\xbc\xd3\xc3\xdc"))) { // 加密
  croak("cannot load Api_TeaEncrypt");
}
 if (! (Api_TeaDecrypt = (Api_TeaDecrypt_ptr)GetProcAddress(dll, "Api_Tea\xbd\xe2\xc3\xdc"))) { // 解密
  croak("cannot load Api_TeaDecrypt");
}
if (! (Api_GetNick = (Api_GetNick_ptr)GetProcAddress(dll, "Api_GetNick"))) {
  croak("cannot load Api_GetNick");
}
if (! (Api_GetQQLevel = (Api_GetQQLevel_ptr)GetProcAddress(dll, "Api_GetQQLevel"))) {
  croak("cannot load Api_GetQQLevel");
}
if (! (Api_GNGetGid = (Api_GNGetGid_ptr)GetProcAddress(dll, "Api_GNGetGid"))) {
  croak("cannot load Api_GNGetGid");
}
if (! (Api_GidGetGN = (Api_GidGetGN_ptr)GetProcAddress(dll, "Api_GidGetGN"))) {
  croak("cannot load Api_GidGetGN");
}
if (! (Api_GetVersion = (Api_GetVersion_ptr)GetProcAddress(dll, "Api_GetVersion"))) {
  croak("cannot load Api_GetVersion");
}
if (! (Api_GetVersionName = (Api_GetVersionName_ptr)GetProcAddress(dll, "Api_GetVersionName"))) {
  croak("cannot load Api_GetVersionName");
}
if (! (Api_GetTimeStamp = (Api_GetTimeStamp_ptr)GetProcAddress(dll, "Api_GetTimeStamp"))) {
  croak("cannot load Api_GetTimeStamp");
}
if (! (Api_GetLog = (Api_GetLog_ptr)GetProcAddress(dll, "Api_GetLog"))) {
  croak("cannot load Api_GetLog");
}
if (! (Api_IfBlock = (Api_IfBlock_ptr)GetProcAddress(dll, "Api_IfBlock"))) {
  croak("cannot load Api_IfBlock");
}
if (! (Api_GetAdminList = (Api_GetAdminList_ptr)GetProcAddress(dll, "Api_GetAdminList"))) {
  croak("cannot load Api_GetAdminList");
}
if (! (Api_AddTaotao = (Api_AddTaotao_ptr)GetProcAddress(dll, "Api_AddTaotao"))) {
  croak("cannot load Api_AddTaotao");
}
if (! (Api_GetSign = (Api_GetSign_ptr)GetProcAddress(dll, "Api_GetSign"))) {
  croak("cannot load Api_GetSign");
}
if (! (Api_SetSign = (Api_SetSign_ptr)GetProcAddress(dll, "Api_SetSign"))) {
  croak("cannot load Api_SetSign");
}
if (! (Api_GetGroupListA = (Api_GetGroupListA_ptr)GetProcAddress(dll, "Api_GetGroupListA"))) {
  croak("cannot load Api_GetGroupListA");
}
if (! (Api_GetGroupListB = (Api_GetGroupListB_ptr)GetProcAddress(dll, "Api_GetGroupListB"))) {
  croak("cannot load Api_GetGroupListB");
}
if (! (Api_GetGroupMemberA = (Api_GetGroupMemberA_ptr)GetProcAddress(dll, "Api_GetGroupMemberA"))) {
  croak("cannot load Api_GetGroupMemberA");
}
if (! (Api_GetGroupMemberB = (Api_GetGroupMemberB_ptr)GetProcAddress(dll, "Api_GetGroupMemberB"))) {
  croak("cannot load Api_GetGroupMemberB");
}
if (! (Api_GetFriendList = (Api_GetFriendList_ptr)GetProcAddress(dll, "Api_GetFriendList"))) {
  croak("cannot load Api_GetFriendList");
}
if (! (Api_GetQQAge = (Api_GetQQAge_ptr)GetProcAddress(dll, "Api_GetQQAge"))) {
  croak("cannot load Api_GetQQAge");
}
if (! (Api_GetAge = (Api_GetAge_ptr)GetProcAddress(dll, "Api_GetAge"))) {
  croak("cannot load Api_GetAge");
}
if (! (Api_GetPersonalProfile = (Api_GetPersonalProfile_ptr)GetProcAddress(dll, "Api_GetPersonalProfile"))) {
  croak("cannot load Api_GetPersonalProfile");
}
if (! (Api_GetEmail = (Api_GetEmail_ptr)GetProcAddress(dll, "Api_GetEmail"))) {
  croak("cannot load Api_GetEmail");
}
if (! (Api_GetGender = (Api_GetGender_ptr)GetProcAddress(dll, "Api_GetGender"))) {
  croak("cannot load Api_GetGender");
}
if (! (Api_SendTyping = (Api_SendTyping_ptr)GetProcAddress(dll, "Api_SendTyping"))) {
  croak("cannot load Api_SendTyping");
}
if (! (Api_SendShake = (Api_SendShake_ptr)GetProcAddress(dll, "Api_SendShake"))) {
  croak("cannot load Api_SendShake");
}
if (! (Api_GetRadomOnlineQQ = (Api_GetRadomOnlineQQ_ptr)GetProcAddress(dll, "Api_GetRadomOnlineQQ"))) {
  croak("cannot load Api_GetRadomOnlineQQ");
}
if (! (Api_AddQQ = (Api_AddQQ_ptr)GetProcAddress(dll, "Api_AddQQ"))) {
  croak("cannot load Api_AddQQ");
}
if (! (Api_SetOLStatus = (Api_SetOLStatus_ptr)GetProcAddress(dll, "Api_SetOLStatus"))) {
  croak("cannot load Api_SetOLStatus");
}
if (! (Api_GetMC = (Api_GetMC_ptr)GetProcAddress(dll, "Api_GetMC"))) {
  croak("cannot load Api_GetMC");
}
if (! (Api_GroupInvitation = (Api_GroupInvitation_ptr)GetProcAddress(dll, "Api_GroupInvitation"))) {
  croak("cannot load Api_GroupInvitation");
}
if (! (Api_CreateDG = (Api_CreateDG_ptr)GetProcAddress(dll, "Api_CreateDG"))) {
  croak("cannot load Api_CreateDG");
}
if (! (Api_KickDG = (Api_KickDG_ptr)GetProcAddress(dll, "Api_KickDG"))) {
  croak("cannot load Api_KickDG");
}
if (! (Api_DGInvitation = (Api_DGInvitation_ptr)GetProcAddress(dll, "Api_DGInvitation"))) {
  croak("cannot load Api_DGInvitation");
}
if (! (Api_GetDGList = (Api_GetDGList_ptr)GetProcAddress(dll, "Api_GetDGList"))) {
  croak("cannot load Api_GetDGList");
}
if (! (Api_SendMusic = (Api_SendMusic_ptr)GetProcAddress(dll, "Api_SendMusic"))) {
  croak("cannot load Api_SendMusic");
}
if (! (Api_SendObjectMsg = (Api_SendObjectMsg_ptr)GetProcAddress(dll, "Api_SendObjectMsg"))) {
  croak("cannot load Api_SendObjectMsg");
}
if (! (Api_IsFriend = (Api_IsFriend_ptr)GetProcAddress(dll, "Api_IsFriend"))) {
  croak("cannot load Api_IsFriend");
}
if (! (Api_AddFriend = (Api_AddFriend_ptr)GetProcAddress(dll, "Api_AddFriend"))) {
  croak("cannot load Api_AddFriend");
}
if (! (Api_SelfDisable = (Api_SelfDisable_ptr)GetProcAddress(dll, "Api_SelfDisable"))) {
  croak("cannot load Api_SelfDisable");
}
if (! (Api_GetClientType = (Api_GetClientType_ptr)GetProcAddress(dll, "Api_GetClientType"))) {
  croak("cannot load Api_GetClientType");
}
if (! (Api_GetClientVer = (Api_GetClientVer_ptr)GetProcAddress(dll, "Api_GetClientVer"))) {
  croak("cannot load Api_GetClientVer");
}
if (! (Api_GetPubNo = (Api_GetPubNo_ptr)GetProcAddress(dll, "Api_GetPubNo"))) {
  croak("cannot load Api_GetPubNo");
}
if (! (Api_GetMainVer = (Api_GetMainVer_ptr)GetProcAddress(dll, "Api_GetMainVer"))) {
  croak("cannot load Api_GetMainVer");
}
if (! (Api_GetTXSSOVer = (Api_GetTXSSOVer_ptr)GetProcAddress(dll, "Api_GetTXSSOVer"))) {
  croak("cannot load Api_GetTXSSOVer");
}
if (! (Api_UploadVoice = (Api_UploadVoice_ptr)GetProcAddress(dll, "Api_UploadVoice"))) {
  croak("cannot load Api_UploadVoice");
}
if (! (Api_GuidGetVoiceLink = (Api_GuidGetVoiceLink_ptr)GetProcAddress(dll, "Api_GuidGetVoiceLink"))) {
  croak("cannot load Api_GuidGetVoiceLink");
}
if (! (Api_AddLogHandler = (Api_AddLogHandler_ptr)GetProcAddress(dll, "Api_AddLogHandler"))) {
  croak("cannot load Api_AddLogHandler");
}
if (! (Api_RemoveLogHandler = (Api_RemoveLogHandler_ptr)GetProcAddress(dll, "Api_RemoveLogHandler"))) {
  croak("cannot load Api_RemoveLogHandler");
}
}
#endif
