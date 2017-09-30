SV *
GetGtk_Bkn(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetGtk_Bkn(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetBkn32(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetBkn32(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetLdw(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetLdw(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetRunPath()
CODE: 
  RETVAL = newSVpv(Api_GetRunPath(), 0);
OUTPUT:
  RETVAL

SV *
GetOnlineQQlist()
CODE: 
  RETVAL = newSVpv(Api_GetOnlineQQlist(), 0);
OUTPUT:
  RETVAL

SV *
GetQQlist()
CODE: 
  RETVAL = newSVpv(Api_GetQQlist(), 0);
OUTPUT:
  RETVAL

SV *
GetSessionkey(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetSessionkey(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetClientkey(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetClientkey(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetLongClientkey(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetLongClientkey(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetCookies(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetCookies(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetPrefix()
CODE: 
  RETVAL = newSVpv(Api_GetPrefix(), 0);
OUTPUT:
  RETVAL

void
Cache_NameCard(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  char *  __arg_2
CODE: 
  Api_Cache_NameCard(__arg_0, __arg_1, __arg_2);

void
DBan(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  Api_DBan(__arg_0, __arg_1);

void
Ban(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  Api_Ban(__arg_0, __arg_1);

bool
Shutup(__arg_0, __arg_1, __arg_2, __arg_3)
  char * __arg_0
  char * __arg_1
  char * __arg_2
  int  __arg_3
CODE: 
  RETVAL = Api_Shutup(__arg_0, __arg_1, __arg_2, __arg_3);
OUTPUT:
  RETVAL

bool
IsShutup(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  char * __arg_2
CODE: 
  RETVAL = Api_IsShutup(__arg_0, __arg_1, __arg_2);
OUTPUT:
  RETVAL

void
SetNotice(__arg_0, __arg_1, __arg_2, __arg_3)
  char * __arg_0
  char * __arg_1
  char * __arg_2
  char *  __arg_3
CODE: 
  Api_SetNotice(__arg_0, __arg_1, __arg_2, __arg_3);

SV *
GetNotice(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_GetNotice(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
GetNameCard(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  char *  __arg_2
CODE: 
  RETVAL = newSVpv(Api_GetNameCard(__arg_0, __arg_1, __arg_2), 0);
OUTPUT:
  RETVAL

void
SetNameCard(__arg_0, __arg_1, __arg_2, __arg_3)
  char * __arg_0
  char * __arg_1
  char * __arg_2
  char *  __arg_3
CODE: 
  Api_SetNameCard(__arg_0, __arg_1, __arg_2, __arg_3);

void
QuitDG(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  Api_QuitDG(__arg_0, __arg_1);

bool
DelFriend(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = Api_DelFriend(__arg_0, __arg_1);
OUTPUT:
  RETVAL

bool
Kick(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  char *  __arg_2
CODE: 
  RETVAL = Api_Kick(__arg_0, __arg_1, __arg_2);
OUTPUT:
  RETVAL

void
JoinGroup(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  char *  __arg_2
CODE: 
  Api_JoinGroup(__arg_0, __arg_1, __arg_2);

void
QuitGroup(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  Api_QuitGroup(__arg_0, __arg_1);

SV *
UploadPic(__arg_0, __arg_1, __arg_2, __arg_3)
  char * __arg_0
  int __arg_1
  char * __arg_2
  unsigned char *  __arg_3
CODE: 
  RETVAL = newSVpv(Api_UploadPic(__arg_0, __arg_1, __arg_2, __arg_3), 0);
OUTPUT:
  RETVAL

SV *
GuidGetPicLink(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GuidGetPicLink(__arg_0), 0);
OUTPUT:
  RETVAL

int
Reply(__arg_0, __arg_1, __arg_2, __arg_3)
  char * __arg_0
  int __arg_1
  char * __arg_2
  char *  __arg_3
CODE: 
  RETVAL = Api_Reply(__arg_0, __arg_1, __arg_2, __arg_3);
OUTPUT:
  RETVAL

int
SendMsg(__arg_0, __arg_1, __arg_2, __arg_3, __arg_4, __arg_5)
  char * __arg_0
  int __arg_1
  int __arg_2
  char * __arg_3
  char * __arg_4
  char *  __arg_5
CODE: 
  RETVAL = Api_SendMsg(__arg_0, __arg_1, __arg_2, __arg_3, __arg_4, __arg_5);
OUTPUT:
  RETVAL

SV *
Send(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_Send(__arg_0), 0);
OUTPUT:
  RETVAL

int
OutPut(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = Api_OutPut(__arg_0);
OUTPUT:
  RETVAL

bool
IsEnable()
CODE: 
  RETVAL = Api_IsEnable();
OUTPUT:
  RETVAL

bool
Login(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = Api_Login(__arg_0);
OUTPUT:
  RETVAL

void
Logout(__arg_0)
  char *  __arg_0
CODE: 
  Api_Logout(__arg_0);

SV *
TeaEncrypt(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_TeaEncrypt(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
TeaDecrypt(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_TeaDecrypt(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
GetNick(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetNick(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetQQLevel(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetQQLevel(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GNGetGid(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GNGetGid(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GidGetGN(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GidGetGN(__arg_0), 0);
OUTPUT:
  RETVAL

int
GetVersion()
CODE: 
  RETVAL = Api_GetVersion();
OUTPUT:
  RETVAL

SV *
GetVersionName()
CODE: 
  RETVAL = newSVpv(Api_GetVersionName(), 0);
OUTPUT:
  RETVAL

int
GetTimeStamp()
CODE: 
  RETVAL = Api_GetTimeStamp();
OUTPUT:
  RETVAL

SV *
GetLog()
CODE: 
  RETVAL = newSVpv(Api_GetLog(), 0);
OUTPUT:
  RETVAL

bool
IfBlock(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = Api_IfBlock(__arg_0);
OUTPUT:
  RETVAL

SV *
GetAdminList(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_GetAdminList(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
AddTaotao(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_AddTaotao(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
GetSign(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_GetSign(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
SetSign(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_SetSign(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
GetGroupListA(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetGroupListA(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetGroupListB(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetGroupListB(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
GetGroupMemberA(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_GetGroupMemberA(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
GetGroupMemberB(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_GetGroupMemberB(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
GetFriendList(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetFriendList(__arg_0), 0);
OUTPUT:
  RETVAL

int
GetQQAge(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = Api_GetQQAge(__arg_0, __arg_1);
OUTPUT:
  RETVAL

int
GetAge(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = Api_GetAge(__arg_0, __arg_1);
OUTPUT:
  RETVAL

SV *
GetPersonalProfile(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_GetPersonalProfile(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
GetEmail(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = newSVpv(Api_GetEmail(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

int
GetGender(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = Api_GetGender(__arg_0, __arg_1);
OUTPUT:
  RETVAL

int
SendTyping(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = Api_SendTyping(__arg_0, __arg_1);
OUTPUT:
  RETVAL

int
SendShake(__arg_0, __arg_1)
  char * __arg_0
  char *  __arg_1
CODE: 
  RETVAL = Api_SendShake(__arg_0, __arg_1);
OUTPUT:
  RETVAL

SV *
GetRadomOnlineQQ()
CODE: 
  RETVAL = newSVpv(Api_GetRadomOnlineQQ(), 0);
OUTPUT:
  RETVAL

bool
AddQQ(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  bool  __arg_2
CODE: 
  RETVAL = Api_AddQQ(__arg_0, __arg_1, __arg_2);
OUTPUT:
  RETVAL

bool
SetOLStatus(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  int __arg_1
  char *  __arg_2
CODE: 
  RETVAL = Api_SetOLStatus(__arg_0, __arg_1, __arg_2);
OUTPUT:
  RETVAL

SV *
GetMC()
CODE: 
  RETVAL = newSVpv(Api_GetMC(), 0);
OUTPUT:
  RETVAL

SV *
GroupInvitation(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  char *  __arg_2
CODE: 
  RETVAL = newSVpv(Api_GroupInvitation(__arg_0, __arg_1, __arg_2), 0);
OUTPUT:
  RETVAL

SV *
CreateDG(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_CreateDG(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
KickDG(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  char *  __arg_2
CODE: 
  RETVAL = newSVpv(Api_KickDG(__arg_0, __arg_1, __arg_2), 0);
OUTPUT:
  RETVAL

SV *
DGInvitation(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  char *  __arg_2
CODE: 
  RETVAL = newSVpv(Api_DGInvitation(__arg_0, __arg_1, __arg_2), 0);
OUTPUT:
  RETVAL

SV *
GetDGList(__arg_0)
  char *  __arg_0
CODE: 
  RETVAL = newSVpv(Api_GetDGList(__arg_0), 0);
OUTPUT:
  RETVAL

bool
SendMusic(__arg_0, __arg_1, __arg_2, __arg_3, __arg_4, __arg_5, __arg_6, __arg_7, __arg_8, __arg_9, __arg_10, __arg_11)
  char * __arg_0
  int __arg_1
  char * __arg_2
  char * __arg_3
  char * __arg_4
  char * __arg_5
  char * __arg_6
  char * __arg_7
  char * __arg_8
  char * __arg_9
  char * __arg_10
  char *  __arg_11
CODE: 
  RETVAL = Api_SendMusic(__arg_0, __arg_1, __arg_2, __arg_3, __arg_4, __arg_5, __arg_6, __arg_7, __arg_8, __arg_9, __arg_10, __arg_11);
OUTPUT:
  RETVAL

bool
SendObjectMsg(__arg_0, __arg_1, __arg_2, __arg_3, __arg_4, __arg_5)
  char * __arg_0
  int __arg_1
  char * __arg_2
  char * __arg_3
  char * __arg_4
  int  __arg_5
CODE: 
  RETVAL = Api_SendObjectMsg(__arg_0, __arg_1, __arg_2, __arg_3, __arg_4, __arg_5);
OUTPUT:
  RETVAL

bool
IsFriend(__arg_0, __arg_1)
  char * __arg_0
  char * __arg_1
CODE: 
  RETVAL = Api_IsFriend(__arg_0, __arg_1);
OUTPUT:
  RETVAL

bool
AddFriend(__arg_0, __arg_1, __arg_2)
  char * __arg_0
  char * __arg_1
  char* __arg_2
CODE: 
  RETVAL = Api_AddFriend(__arg_0, __arg_1, __arg_2);
OUTPUT:
  RETVAL

void
SelfDisable()
CODE: 
  Api_SelfDisable();

int
GetClientType()
CODE: 
  RETVAL = Api_GetClientType();
OUTPUT:
  RETVAL

int
GetClientVer()
CODE: 
  RETVAL = Api_GetClientVer();
OUTPUT:
  RETVAL

int
GetPubNo()
CODE: 
  RETVAL = Api_GetPubNo();
OUTPUT:
  RETVAL

int
GetMainVer()
CODE: 
  RETVAL = Api_GetMainVer();
OUTPUT:
  RETVAL

int
GetTXSSOVer()
CODE: 
  RETVAL = Api_GetTXSSOVer();
OUTPUT:
  RETVAL

SV *
UploadVoice(__arg_0, __arg_1)
  char * __arg_0
  int __arg_1
CODE: 
  RETVAL = newSVpv(Api_UploadVoice(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
GuidGetVoiceLink(__arg_0, __arg_1)
  char * __arg_0
  char * __arg_1
CODE: 
  RETVAL = newSVpv(Api_GuidGetVoiceLink(__arg_0, __arg_1), 0);
OUTPUT:
  RETVAL

SV *
AddLogHandler(__arg_0)
  int __arg_0
CODE: 
  RETVAL = newSVpv(Api_AddLogHandler(__arg_0), 0);
OUTPUT:
  RETVAL

SV *
RemoveLogHandler()
CODE: 
  RETVAL = newSVpv(Api_RemoveLogHandler(), 0);
OUTPUT:
  RETVAL

