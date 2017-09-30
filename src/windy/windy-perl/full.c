//#include "EXTERN.h"
//#include "perl.h"
//#include "XSUB.h"
#include <stdio.h>
#include <windows.h>
typedef int bool;
typedef char *(__stdcall *Api_GetGtk_Bkn_ptr)(char * );
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
HINSTANCE dll;

void init()
{
  if (! (dll = LoadLibrary("Message.dll"))) {
    printf("cannot load dll.");return;
  }
if (! (Api_GetGtk_Bkn = (Api_GetGtk_Bkn_ptr)GetProcAddress(dll, "Api_GetGtk_Bkn"))) {
  printf("cannot load Api_GetGtk_Bkn");return;
}
if (! (Api_GetBkn32 = (Api_GetBkn32_ptr)GetProcAddress(dll, "Api_GetBkn32"))) {
  printf("cannot load Api_GetBkn32");return;
}
if (! (Api_GetLdw = (Api_GetLdw_ptr)GetProcAddress(dll, "Api_GetLdw"))) {
  printf("cannot load Api_GetLdw");return;
}
if (! (Api_GetRunPath = (Api_GetRunPath_ptr)GetProcAddress(dll, "Api_GetRunPath"))) {
  printf("cannot load Api_GetRunPath");return;
}
if (! (Api_GetOnlineQQlist = (Api_GetOnlineQQlist_ptr)GetProcAddress(dll, "Api_GetOnlineQQlist"))) {
  printf("cannot load Api_GetOnlineQQlist");return;
}
if (! (Api_GetQQlist = (Api_GetQQlist_ptr)GetProcAddress(dll, "Api_GetQQlist"))) {
  printf("cannot load Api_GetQQlist");return;
}
if (! (Api_GetSessionkey = (Api_GetSessionkey_ptr)GetProcAddress(dll, "Api_GetSessionkey"))) {
  printf("cannot load Api_GetSessionkey");return;
}
if (! (Api_GetClientkey = (Api_GetClientkey_ptr)GetProcAddress(dll, "Api_GetClientkey"))) {
  printf("cannot load Api_GetClientkey");return;
}
if (! (Api_GetLongClientkey = (Api_GetLongClientkey_ptr)GetProcAddress(dll, "Api_GetLongClientkey"))) {
  printf("cannot load Api_GetLongClientkey");return;
}
if (! (Api_GetCookies = (Api_GetCookies_ptr)GetProcAddress(dll, "Api_GetCookies"))) {
  printf("cannot load Api_GetCookies");return;
}
if (! (Api_GetPrefix = (Api_GetPrefix_ptr)GetProcAddress(dll, "Api_GetPrefix"))) {
  printf("cannot load Api_GetPrefix");return;
}
if (! (Api_Cache_NameCard = (Api_Cache_NameCard_ptr)GetProcAddress(dll, "Api_Cache_NameCard"))) {
  printf("cannot load Api_Cache_NameCard");return;
}
if (! (Api_DBan = (Api_DBan_ptr)GetProcAddress(dll, "Api_DBan"))) {
  printf("cannot load Api_DBan");return;
}
if (! (Api_Ban = (Api_Ban_ptr)GetProcAddress(dll, "Api_Ban"))) {
  printf("cannot load Api_Ban");return;
}
if (! (Api_Shutup = (Api_Shutup_ptr)GetProcAddress(dll, "Api_Shutup"))) {
  printf("cannot load Api_Shutup");return;
}
if (! (Api_IsShutup = (Api_IsShutup_ptr)GetProcAddress(dll, "Api_IsShutup"))) {
  printf("cannot load Api_IsShutup");return;
}
if (! (Api_SetNotice = (Api_SetNotice_ptr)GetProcAddress(dll, "Api_SetNotice"))) {
  printf("cannot load Api_SetNotice");return;
}
if (! (Api_GetNotice = (Api_GetNotice_ptr)GetProcAddress(dll, "Api_GetNotice"))) {
  printf("cannot load Api_GetNotice");return;
}
if (! (Api_GetNameCard = (Api_GetNameCard_ptr)GetProcAddress(dll, "Api_GetNameCard"))) {
  printf("cannot load Api_GetNameCard");return;
}
if (! (Api_SetNameCard = (Api_SetNameCard_ptr)GetProcAddress(dll, "Api_SetNameCard"))) {
  printf("cannot load Api_SetNameCard");return;
}
if (! (Api_QuitDG = (Api_QuitDG_ptr)GetProcAddress(dll, "Api_QuitDG"))) {
  printf("cannot load Api_QuitDG");return;
}
if (! (Api_DelFriend = (Api_DelFriend_ptr)GetProcAddress(dll, "Api_DelFriend"))) {
  printf("cannot load Api_DelFriend");return;
}
if (! (Api_Kick = (Api_Kick_ptr)GetProcAddress(dll, "Api_Kick"))) {
  printf("cannot load Api_Kick");return;
}
if (! (Api_JoinGroup = (Api_JoinGroup_ptr)GetProcAddress(dll, "Api_JoinGroup"))) {
  printf("cannot load Api_JoinGroup");return;
}
if (! (Api_QuitGroup = (Api_QuitGroup_ptr)GetProcAddress(dll, "Api_QuitGroup"))) {
  printf("cannot load Api_QuitGroup");return;
}
if (! (Api_UploadPic = (Api_UploadPic_ptr)GetProcAddress(dll, "Api_UploadPic"))) {
  printf("cannot load Api_UploadPic");return;
}
if (! (Api_GuidGetPicLink = (Api_GuidGetPicLink_ptr)GetProcAddress(dll, "Api_GuidGetPicLink"))) {
  printf("cannot load Api_GuidGetPicLink");return;
}
if (! (Api_Reply = (Api_Reply_ptr)GetProcAddress(dll, "Api_Reply"))) {
  printf("cannot load Api_Reply");return;
}
if (! (Api_SendMsg = (Api_SendMsg_ptr)GetProcAddress(dll, "Api_SendMsg"))) {
  printf("cannot load Api_SendMsg");return;
}
if (! (Api_Send = (Api_Send_ptr)GetProcAddress(dll, "Api_Send"))) {
  printf("cannot load Api_Send");return;
}
if (! (Api_OutPut = (Api_OutPut_ptr)GetProcAddress(dll, "Api_OutPut"))) {
  printf("cannot load Api_OutPut");return;
}
if (! (Api_IsEnable = (Api_IsEnable_ptr)GetProcAddress(dll, "Api_IsEnable"))) {
  printf("cannot load Api_IsEnable");return;
}
if (! (Api_Login = (Api_Login_ptr)GetProcAddress(dll, "Api_Login"))) {
  printf("cannot load Api_Login");return;
}
if (! (Api_Logout = (Api_Logout_ptr)GetProcAddress(dll, "Api_Logout"))) {
  printf("cannot load Api_Logout");return;
}
if (! (Api_TeaEncrypt = (Api_TeaEncrypt_ptr)GetProcAddress(dll, "Api_Teaº”√‹"))) {
  printf("cannot load Api_TeaEncrypt");return;
}
if (! (Api_TeaDecrypt = (Api_TeaDecrypt_ptr)GetProcAddress(dll, "Api_TeaΩ‚√‹"))) {
  printf("cannot load Api_TeaDecrypt");return;
}
if (! (Api_GetNick = (Api_GetNick_ptr)GetProcAddress(dll, "Api_GetNick"))) {
  printf("cannot load Api_GetNick");return;
}
if (! (Api_GetQQLevel = (Api_GetQQLevel_ptr)GetProcAddress(dll, "Api_GetQQLevel"))) {
  printf("cannot load Api_GetQQLevel");return;
}
if (! (Api_GNGetGid = (Api_GNGetGid_ptr)GetProcAddress(dll, "Api_GNGetGid"))) {
  printf("cannot load Api_GNGetGid");return;
}
if (! (Api_GidGetGN = (Api_GidGetGN_ptr)GetProcAddress(dll, "Api_GidGetGN"))) {
  printf("cannot load Api_GidGetGN");return;
}
if (! (Api_GetVersion = (Api_GetVersion_ptr)GetProcAddress(dll, "Api_GetVersion"))) {
  printf("cannot load Api_GetVersion");return;
}
if (! (Api_GetVersionName = (Api_GetVersionName_ptr)GetProcAddress(dll, "Api_GetVersionName"))) {
  printf("cannot load Api_GetVersionName");return;
}
if (! (Api_GetTimeStamp = (Api_GetTimeStamp_ptr)GetProcAddress(dll, "Api_GetTimeStamp"))) {
  printf("cannot load Api_GetTimeStamp");return;
}
if (! (Api_GetLog = (Api_GetLog_ptr)GetProcAddress(dll, "Api_GetLog"))) {
  printf("cannot load Api_GetLog");return;
}
if (! (Api_IfBlock = (Api_IfBlock_ptr)GetProcAddress(dll, "Api_IfBlock"))) {
  printf("cannot load Api_IfBlock");return;
}
if (! (Api_GetAdminList = (Api_GetAdminList_ptr)GetProcAddress(dll, "Api_GetAdminList"))) {
  printf("cannot load Api_GetAdminList");return;
}
if (! (Api_AddTaotao = (Api_AddTaotao_ptr)GetProcAddress(dll, "Api_AddTaotao"))) {
  printf("cannot load Api_AddTaotao");return;
}
if (! (Api_GetSign = (Api_GetSign_ptr)GetProcAddress(dll, "Api_GetSign"))) {
  printf("cannot load Api_GetSign");return;
}
if (! (Api_SetSign = (Api_SetSign_ptr)GetProcAddress(dll, "Api_SetSign"))) {
  printf("cannot load Api_SetSign");return;
}
if (! (Api_GetGroupListA = (Api_GetGroupListA_ptr)GetProcAddress(dll, "Api_GetGroupListA"))) {
  printf("cannot load Api_GetGroupListA");return;
}
if (! (Api_GetGroupListB = (Api_GetGroupListB_ptr)GetProcAddress(dll, "Api_GetGroupListB"))) {
  printf("cannot load Api_GetGroupListB");return;
}
if (! (Api_GetGroupMemberA = (Api_GetGroupMemberA_ptr)GetProcAddress(dll, "Api_GetGroupMemberA"))) {
  printf("cannot load Api_GetGroupMemberA");return;
}
if (! (Api_GetGroupMemberB = (Api_GetGroupMemberB_ptr)GetProcAddress(dll, "Api_GetGroupMemberB"))) {
  printf("cannot load Api_GetGroupMemberB");return;
}
if (! (Api_GetFriendList = (Api_GetFriendList_ptr)GetProcAddress(dll, "Api_GetFriendList"))) {
  printf("cannot load Api_GetFriendList");return;
}
if (! (Api_GetQQAge = (Api_GetQQAge_ptr)GetProcAddress(dll, "Api_GetQQAge"))) {
  printf("cannot load Api_GetQQAge");return;
}
if (! (Api_GetAge = (Api_GetAge_ptr)GetProcAddress(dll, "Api_GetAge"))) {
  printf("cannot load Api_GetAge");return;
}
if (! (Api_GetPersonalProfile = (Api_GetPersonalProfile_ptr)GetProcAddress(dll, "Api_GetPersonalProfile"))) {
  printf("cannot load Api_GetPersonalProfile");return;
}
if (! (Api_GetEmail = (Api_GetEmail_ptr)GetProcAddress(dll, "Api_GetEmail"))) {
  printf("cannot load Api_GetEmail");return;
}
if (! (Api_GetGender = (Api_GetGender_ptr)GetProcAddress(dll, "Api_GetGender"))) {
  printf("cannot load Api_GetGender");return;
}
if (! (Api_SendTyping = (Api_SendTyping_ptr)GetProcAddress(dll, "Api_SendTyping"))) {
  printf("cannot load Api_SendTyping");return;
}
if (! (Api_SendShake = (Api_SendShake_ptr)GetProcAddress(dll, "Api_SendShake"))) {
  printf("cannot load Api_SendShake");return;
}
if (! (Api_GetRadomOnlineQQ = (Api_GetRadomOnlineQQ_ptr)GetProcAddress(dll, "Api_GetRadomOnlineQQ"))) {
  printf("cannot load Api_GetRadomOnlineQQ");return;
}
if (! (Api_AddQQ = (Api_AddQQ_ptr)GetProcAddress(dll, "Api_AddQQ"))) {
  printf("cannot load Api_AddQQ");return;
}
if (! (Api_SetOLStatus = (Api_SetOLStatus_ptr)GetProcAddress(dll, "Api_SetOLStatus"))) {
  printf("cannot load Api_SetOLStatus");return;
}
if (! (Api_GetMC = (Api_GetMC_ptr)GetProcAddress(dll, "Api_GetMC"))) {
  printf("cannot load Api_GetMC");return;
}
if (! (Api_GroupInvitation = (Api_GroupInvitation_ptr)GetProcAddress(dll, "Api_GroupInvitation"))) {
  printf("cannot load Api_GroupInvitation");return;
}
if (! (Api_CreateDG = (Api_CreateDG_ptr)GetProcAddress(dll, "Api_CreateDG"))) {
  printf("cannot load Api_CreateDG");return;
}
if (! (Api_KickDG = (Api_KickDG_ptr)GetProcAddress(dll, "Api_KickDG"))) {
  printf("cannot load Api_KickDG");return;
}
if (! (Api_DGInvitation = (Api_DGInvitation_ptr)GetProcAddress(dll, "Api_DGInvitation"))) {
  printf("cannot load Api_DGInvitation");return;
}
if (! (Api_GetDGList = (Api_GetDGList_ptr)GetProcAddress(dll, "Api_GetDGList"))) {
  printf("cannot load Api_GetDGList");return;
}
if (! (Api_SendMusic = (Api_SendMusic_ptr)GetProcAddress(dll, "Api_SendMusic"))) {
  printf("cannot load Api_SendMusic");return;
}
if (! (Api_SendObjectMsg = (Api_SendObjectMsg_ptr)GetProcAddress(dll, "Api_SendObjectMsg"))) {
  printf("cannot load Api_SendObjectMsg");return;
}
if (! (Api_IsFriend = (Api_IsFriend_ptr)GetProcAddress(dll, "Api_IsFriend"))) {
  printf("cannot load Api_IsFriend");return;
}
if (! (Api_AddFriend = (Api_AddFriend_ptr)GetProcAddress(dll, "Api_AddFriend"))) {
  printf("cannot load Api_AddFriend");return;
}
if (! (Api_SelfDisable = (Api_SelfDisable_ptr)GetProcAddress(dll, "Api_SelfDisable"))) {
  printf("cannot load Api_SelfDisable");return;
}
if (! (Api_GetClientType = (Api_GetClientType_ptr)GetProcAddress(dll, "Api_GetClientType"))) {
  printf("cannot load Api_GetClientType");return;
}
if (! (Api_GetClientVer = (Api_GetClientVer_ptr)GetProcAddress(dll, "Api_GetClientVer"))) {
  printf("cannot load Api_GetClientVer");return;
}
if (! (Api_GetPubNo = (Api_GetPubNo_ptr)GetProcAddress(dll, "Api_GetPubNo"))) {
  printf("cannot load Api_GetPubNo");return;
}
if (! (Api_GetMainVer = (Api_GetMainVer_ptr)GetProcAddress(dll, "Api_GetMainVer"))) {
  printf("cannot load Api_GetMainVer");return;
}
if (! (Api_GetTXSSOVer = (Api_GetTXSSOVer_ptr)GetProcAddress(dll, "Api_GetTXSSOVer"))) {
  printf("cannot load Api_GetTXSSOVer");return;
}
if (! (Api_UploadVoice = (Api_UploadVoice_ptr)GetProcAddress(dll, "Api_UploadVoice"))) {
  printf("cannot load Api_UploadVoice");return;
}
if (! (Api_GuidGetVoiceLink = (Api_GuidGetVoiceLink_ptr)GetProcAddress(dll, "Api_GuidGetVoiceLink"))) {
  printf("cannot load Api_GuidGetVoiceLink");return;
}
if (! (Api_AddLogHandler = (Api_AddLogHandler_ptr)GetProcAddress(dll, "AddLogHandler"))) {
  printf("cannot load AddLogHandler");return;
}
if (! (Api_RemoveLogHandler = (Api_RemoveLogHandler_ptr)GetProcAddress(dll, "RemoveLogHandler"))) {
  printf("cannot load RemoveLogHandler");return;
}
}
void quit()
{
  
}
BOOL APIENTRY DllMain( HINSTANCE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
          init();
          break;
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
          break;
	case DLL_PROCESS_DETACH:
          quit();
          break;
	}
	return TRUE;
}
