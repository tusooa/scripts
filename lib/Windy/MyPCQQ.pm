
package Scripts::Windy::MyPCQQ;
use 5.012;
use Exporter;
use Win32::API;
use Encode qw/encode decode/;
use utf8;
our @ISA = qw/Exporter/;
our @EXPORT = qw//;
our %func;
our $dllfile = "Message.dll";

$func{"GetGtk_Bkn"} = Win32::API::More->new($dllfile, "char * Api_GetGtk_Bkn(char *  __arg_0)") or die "Cannot load func named GetGtk_Bkn: $^E\n";
push @EXPORT, "GetGtk_Bkn";sub GetGtk_Bkn
{
    $func{"GetGtk_Bkn"}->Call(@_);
}
$func{"GetBkn32"} = Win32::API::More->new($dllfile, "char * Api_GetBkn32(char *  __arg_0)") or die "Cannot load func named GetBkn32: $^E\n";
push @EXPORT, "GetBkn32";sub GetBkn32
{
    $func{"GetBkn32"}->Call(@_);
}
$func{"GetLdw"} = Win32::API::More->new($dllfile, "char * Api_GetLdw(char *  __arg_0)") or die "Cannot load func named GetLdw: $^E\n";
push @EXPORT, "GetLdw";sub GetLdw
{
    $func{"GetLdw"}->Call(@_);
}
$func{"GetRunPath"} = Win32::API::More->new($dllfile, "char * Api_GetRunPath()") or die "Cannot load func named GetRunPath: $^E\n";
push @EXPORT, "GetRunPath";sub GetRunPath
{
    $func{"GetRunPath"}->Call(@_);
}
$func{"GetOnlineQQlist"} = Win32::API::More->new($dllfile, "char * Api_GetOnlineQQlist()") or die "Cannot load func named GetOnlineQQlist: $^E\n";
push @EXPORT, "GetOnlineQQlist";sub GetOnlineQQlist
{
    $func{"GetOnlineQQlist"}->Call(@_);
}
$func{"GetQQlist"} = Win32::API::More->new($dllfile, "char * Api_GetQQlist()") or die "Cannot load func named GetQQlist: $^E\n";
push @EXPORT, "GetQQlist";sub GetQQlist
{
    $func{"GetQQlist"}->Call(@_);
}
$func{"GetSessionkey"} = Win32::API::More->new($dllfile, "char * Api_GetSessionkey(char *  __arg_0)") or die "Cannot load func named GetSessionkey: $^E\n";
push @EXPORT, "GetSessionkey";sub GetSessionkey
{
    $func{"GetSessionkey"}->Call(@_);
}
$func{"GetClientkey"} = Win32::API::More->new($dllfile, "char * Api_GetClientkey(char *  __arg_0)") or die "Cannot load func named GetClientkey: $^E\n";
push @EXPORT, "GetClientkey";sub GetClientkey
{
    $func{"GetClientkey"}->Call(@_);
}
$func{"GetLongClientkey"} = Win32::API::More->new($dllfile, "char * Api_GetLongClientkey(char *  __arg_0)") or die "Cannot load func named GetLongClientkey: $^E\n";
push @EXPORT, "GetLongClientkey";sub GetLongClientkey
{
    $func{"GetLongClientkey"}->Call(@_);
}
$func{"GetCookies"} = Win32::API::More->new($dllfile, "char * Api_GetCookies(char *  __arg_0)") or die "Cannot load func named GetCookies: $^E\n";
push @EXPORT, "GetCookies";sub GetCookies
{
    $func{"GetCookies"}->Call(@_);
}
$func{"GetPrefix"} = Win32::API::More->new($dllfile, "char * Api_GetPrefix()") or die "Cannot load func named GetPrefix: $^E\n";
push @EXPORT, "GetPrefix";sub GetPrefix
{
    $func{"GetPrefix"}->Call(@_);
}
$func{"Cache_NameCard"} = Win32::API::More->new($dllfile, "void Api_Cache_NameCard(char * __arg_0, char * __arg_1, char *  __arg_2)") or die "Cannot load func named Cache_NameCard: $^E\n";
push @EXPORT, "Cache_NameCard";sub Cache_NameCard
{
    $func{"Cache_NameCard"}->Call(@_);
}
$func{"DBan"} = Win32::API::More->new($dllfile, "void Api_DBan(char * __arg_0, char *  __arg_1)") or die "Cannot load func named DBan: $^E\n";
push @EXPORT, "DBan";sub DBan
{
    $func{"DBan"}->Call(@_);
}
$func{"Ban"} = Win32::API::More->new($dllfile, "void Api_Ban(char * __arg_0, char *  __arg_1)") or die "Cannot load func named Ban: $^E\n";
push @EXPORT, "Ban";sub Ban
{
    $func{"Ban"}->Call(@_);
}
$func{"Shutup"} = Win32::API::More->new($dllfile, "int Api_Shutup(char * __arg_0, char * __arg_1, char * __arg_2, int  __arg_3)") or die "Cannot load func named Shutup: $^E\n";
push @EXPORT, "Shutup";sub Shutup
{
    $func{"Shutup"}->Call(@_);
}
$func{"IsShutup"} = Win32::API::More->new($dllfile, "int Api_IsShutup(char * __arg_0, char * __arg_1, char * __arg_2)") or die "Cannot load func named IsShutup: $^E\n";
push @EXPORT, "IsShutup";sub IsShutup
{
    $func{"IsShutup"}->Call(@_);
}
$func{"SetNotice"} = Win32::API::More->new($dllfile, "void Api_SetNotice(char * __arg_0, char * __arg_1, char * __arg_2, char *  __arg_3)") or die "Cannot load func named SetNotice: $^E\n";
push @EXPORT, "SetNotice";sub SetNotice
{
    $func{"SetNotice"}->Call(@_);
}
$func{"GetNotice"} = Win32::API::More->new($dllfile, "char * Api_GetNotice(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetNotice: $^E\n";
push @EXPORT, "GetNotice";sub GetNotice
{
    $func{"GetNotice"}->Call(@_);
}
$func{"GetNameCard"} = Win32::API::More->new($dllfile, "char * Api_GetNameCard(char * __arg_0, char * __arg_1, char *  __arg_2)") or die "Cannot load func named GetNameCard: $^E\n";
push @EXPORT, "GetNameCard";sub GetNameCard
{
    $func{"GetNameCard"}->Call(@_);
}
$func{"SetNameCard"} = Win32::API::More->new($dllfile, "void Api_SetNameCard(char * __arg_0, char * __arg_1, char * __arg_2, char *  __arg_3)") or die "Cannot load func named SetNameCard: $^E\n";
push @EXPORT, "SetNameCard";sub SetNameCard
{
    $func{"SetNameCard"}->Call(@_);
}
$func{"QuitDG"} = Win32::API::More->new($dllfile, "void Api_QuitDG(char * __arg_0, char *  __arg_1)") or die "Cannot load func named QuitDG: $^E\n";
push @EXPORT, "QuitDG";sub QuitDG
{
    $func{"QuitDG"}->Call(@_);
}
$func{"DelFriend"} = Win32::API::More->new($dllfile, "int Api_DelFriend(char * __arg_0, char *  __arg_1)") or die "Cannot load func named DelFriend: $^E\n";
push @EXPORT, "DelFriend";sub DelFriend
{
    $func{"DelFriend"}->Call(@_);
}
$func{"Kick"} = Win32::API::More->new($dllfile, "int Api_Kick(char * __arg_0, char * __arg_1, char *  __arg_2)") or die "Cannot load func named Kick: $^E\n";
push @EXPORT, "Kick";sub Kick
{
    $func{"Kick"}->Call(@_);
}
$func{"JoinGroup"} = Win32::API::More->new($dllfile, "void Api_JoinGroup(char * __arg_0, char * __arg_1, char *  __arg_2)") or die "Cannot load func named JoinGroup: $^E\n";
push @EXPORT, "JoinGroup";sub JoinGroup
{
    $func{"JoinGroup"}->Call(@_);
}
$func{"QuitGroup"} = Win32::API::More->new($dllfile, "void Api_QuitGroup(char * __arg_0, char *  __arg_1)") or die "Cannot load func named QuitGroup: $^E\n";
push @EXPORT, "QuitGroup";sub QuitGroup
{
    $func{"QuitGroup"}->Call(@_);
}
$func{"UploadPic"} = Win32::API::More->new($dllfile, "char * Api_UploadPic(char * __arg_0, int __arg_1, char * __arg_2, unsigned char *  __arg_3)") or die "Cannot load func named UploadPic: $^E\n";
push @EXPORT, "UploadPic";sub UploadPic
{
    $func{"UploadPic"}->Call(@_);
}
$func{"GuidGetPicLink"} = Win32::API::More->new($dllfile, "char * Api_GuidGetPicLink(char *  __arg_0)") or die "Cannot load func named GuidGetPicLink: $^E\n";
push @EXPORT, "GuidGetPicLink";sub GuidGetPicLink
{
    $func{"GuidGetPicLink"}->Call(@_);
}
$func{"Reply"} = Win32::API::More->new($dllfile, "int Api_Reply(char * __arg_0, int __arg_1, char * __arg_2, char *  __arg_3)") or die "Cannot load func named Reply: $^E\n";
push @EXPORT, "Reply";sub Reply
{
    $func{"Reply"}->Call(@_);
}
$func{"SendMsg"} = Win32::API::More->new($dllfile, "int Api_SendMsg(char * __arg_0, int __arg_1, int __arg_2, char * __arg_3, char * __arg_4, char *  __arg_5)") or die "Cannot load func named SendMsg: $^E\n";
push @EXPORT, "SendMsg";sub SendMsg
{
    $func{"SendMsg"}->Call(@_);
}
$func{"Send"} = Win32::API::More->new($dllfile, "char * Api_Send(char *  __arg_0)") or die "Cannot load func named Send: $^E\n";
push @EXPORT, "Send";sub Send
{
    $func{"Send"}->Call(@_);
}
$func{"OutPut"} = Win32::API::More->new($dllfile, "int Api_OutPut(char *  __arg_0)") or die "Cannot load func named OutPut: $^E\n";
push @EXPORT, "OutPut";sub OutPut
{
    $func{"OutPut"}->Call(@_);
}
$func{"IsEnable"} = Win32::API::More->new($dllfile, "int Api_IsEnable()") or die "Cannot load func named IsEnable: $^E\n";
push @EXPORT, "IsEnable";sub IsEnable
{
    $func{"IsEnable"}->Call(@_);
}
$func{"Login"} = Win32::API::More->new($dllfile, "int Api_Login(char *  __arg_0)") or die "Cannot load func named Login: $^E\n";
push @EXPORT, "Login";sub Login
{
    $func{"Login"}->Call(@_);
}
$func{"Logout"} = Win32::API::More->new($dllfile, "void Api_Logout(char *  __arg_0)") or die "Cannot load func named Logout: $^E\n";
push @EXPORT, "Logout";sub Logout
{
    $func{"Logout"}->Call(@_);
}
$func{"Tea加密"} = Win32::API::More->new($dllfile, encode 'euc-cn', "char * Api_Tea加密(char * __arg_0, char *  __arg_1)") or die encode 'euc-cn', "Cannot load func named Tea加密: $^E\n";
push @EXPORT, "Tea加密";sub Tea加密
{
    $func{"Tea加密"}->Call(@_);
}
$func{"Tea解密"} = Win32::API::More->new($dllfile, encode 'euc-cn', "char * Api_Tea解密(char * __arg_0, char *  __arg_1)") or die encode 'euc-cn', "Cannot load func named Teadecrypt: $^E\n";
push @EXPORT, "Tea解密";sub Tea解密
{
    $func{"Tea解密"}->Call(@_);
}
$func{"GetNick"} = Win32::API::More->new($dllfile, "char * Api_GetNick(char *  __arg_0)") or die "Cannot load func named GetNick: $^E\n";
push @EXPORT, "GetNick";sub GetNick
{
    $func{"GetNick"}->Call(@_);
}
$func{"GetQQLevel"} = Win32::API::More->new($dllfile, "char * Api_GetQQLevel(char *  __arg_0)") or die "Cannot load func named GetQQLevel: $^E\n";
push @EXPORT, "GetQQLevel";sub GetQQLevel
{
    $func{"GetQQLevel"}->Call(@_);
}
$func{"GNGetGid"} = Win32::API::More->new($dllfile, "char * Api_GNGetGid(char *  __arg_0)") or die "Cannot load func named GNGetGid: $^E\n";
push @EXPORT, "GNGetGid";sub GNGetGid
{
    $func{"GNGetGid"}->Call(@_);
}
$func{"GidGetGN"} = Win32::API::More->new($dllfile, "char * Api_GidGetGN(char *  __arg_0)") or die "Cannot load func named GidGetGN: $^E\n";
push @EXPORT, "GidGetGN";sub GidGetGN
{
    $func{"GidGetGN"}->Call(@_);
}
$func{"GetVersion"} = Win32::API::More->new($dllfile, "int Api_GetVersion()") or die "Cannot load func named GetVersion: $^E\n";
push @EXPORT, "GetVersion";sub GetVersion
{
    $func{"GetVersion"}->Call(@_);
}
$func{"GetVersionName"} = Win32::API::More->new($dllfile, "char * Api_GetVersionName()") or die "Cannot load func named GetVersionName: $^E\n";
push @EXPORT, "GetVersionName";sub GetVersionName
{
    $func{"GetVersionName"}->Call(@_);
}
$func{"GetTimeStamp"} = Win32::API::More->new($dllfile, "int Api_GetTimeStamp()") or die "Cannot load func named GetTimeStamp: $^E\n";
push @EXPORT, "GetTimeStamp";sub GetTimeStamp
{
    $func{"GetTimeStamp"}->Call(@_);
}
$func{"GetLog"} = Win32::API::More->new($dllfile, "char * Api_GetLog()") or die "Cannot load func named GetLog: $^E\n";
push @EXPORT, "GetLog";sub GetLog
{
    $func{"GetLog"}->Call(@_);
}
$func{"IfBlock"} = Win32::API::More->new($dllfile, "int Api_IfBlock(char *  __arg_0)") or die "Cannot load func named IfBlock: $^E\n";
push @EXPORT, "IfBlock";sub IfBlock
{
    $func{"IfBlock"}->Call(@_);
}
$func{"GetAdminList"} = Win32::API::More->new($dllfile, "char * Api_GetAdminList(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetAdminList: $^E\n";
push @EXPORT, "GetAdminList";sub GetAdminList
{
    $func{"GetAdminList"}->Call(@_);
}
$func{"AddTaotao"} = Win32::API::More->new($dllfile, "char * Api_AddTaotao(char * __arg_0, char *  __arg_1)") or die "Cannot load func named AddTaotao: $^E\n";
push @EXPORT, "AddTaotao";sub AddTaotao
{
    $func{"AddTaotao"}->Call(@_);
}
$func{"GetSign"} = Win32::API::More->new($dllfile, "char * Api_GetSign(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetSign: $^E\n";
push @EXPORT, "GetSign";sub GetSign
{
    $func{"GetSign"}->Call(@_);
}
$func{"SetSign"} = Win32::API::More->new($dllfile, "char * Api_SetSign(char * __arg_0, char *  __arg_1)") or die "Cannot load func named SetSign: $^E\n";
push @EXPORT, "SetSign";sub SetSign
{
    $func{"SetSign"}->Call(@_);
}
$func{"GetGroupListA"} = Win32::API::More->new($dllfile, "char * Api_GetGroupListA(char *  __arg_0)") or die "Cannot load func named GetGroupListA: $^E\n";
push @EXPORT, "GetGroupListA";sub GetGroupListA
{
    $func{"GetGroupListA"}->Call(@_);
}
$func{"GetGroupListB"} = Win32::API::More->new($dllfile, "char * Api_GetGroupListB(char *  __arg_0)") or die "Cannot load func named GetGroupListB: $^E\n";
push @EXPORT, "GetGroupListB";sub GetGroupListB
{
    $func{"GetGroupListB"}->Call(@_);
}
$func{"GetGroupMemberA"} = Win32::API::More->new($dllfile, "char * Api_GetGroupMemberA(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetGroupMemberA: $^E\n";
push @EXPORT, "GetGroupMemberA";sub GetGroupMemberA
{
    $func{"GetGroupMemberA"}->Call(@_);
}
$func{"GetGroupMemberB"} = Win32::API::More->new($dllfile, "char * Api_GetGroupMemberB(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetGroupMemberB: $^E\n";
push @EXPORT, "GetGroupMemberB";sub GetGroupMemberB
{
    $func{"GetGroupMemberB"}->Call(@_);
}
$func{"GetFriendList"} = Win32::API::More->new($dllfile, "char * Api_GetFriendList(char *  __arg_0)") or die "Cannot load func named GetFriendList: $^E\n";
push @EXPORT, "GetFriendList";sub GetFriendList
{
    $func{"GetFriendList"}->Call(@_);
}
$func{"GetQQAge"} = Win32::API::More->new($dllfile, "int Api_GetQQAge(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetQQAge: $^E\n";
push @EXPORT, "GetQQAge";sub GetQQAge
{
    $func{"GetQQAge"}->Call(@_);
}
$func{"GetAge"} = Win32::API::More->new($dllfile, "int Api_GetAge(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetAge: $^E\n";
push @EXPORT, "GetAge";sub GetAge
{
    $func{"GetAge"}->Call(@_);
}
$func{"GetPersonalProfile"} = Win32::API::More->new($dllfile, "char * Api_GetPersonalProfile(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetPersonalProfile: $^E\n";
push @EXPORT, "GetPersonalProfile";sub GetPersonalProfile
{
    $func{"GetPersonalProfile"}->Call(@_);
}
$func{"GetEmail"} = Win32::API::More->new($dllfile, "char * Api_GetEmail(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetEmail: $^E\n";
push @EXPORT, "GetEmail";sub GetEmail
{
    $func{"GetEmail"}->Call(@_);
}
$func{"GetGender"} = Win32::API::More->new($dllfile, "int Api_GetGender(char * __arg_0, char *  __arg_1)") or die "Cannot load func named GetGender: $^E\n";
push @EXPORT, "GetGender";sub GetGender
{
    $func{"GetGender"}->Call(@_);
}
$func{"SendTyping"} = Win32::API::More->new($dllfile, "int Api_SendTyping(char * __arg_0, char *  __arg_1)") or die "Cannot load func named SendTyping: $^E\n";
push @EXPORT, "SendTyping";sub SendTyping
{
    $func{"SendTyping"}->Call(@_);
}
$func{"SendShake"} = Win32::API::More->new($dllfile, "int Api_SendShake(char * __arg_0, char *  __arg_1)") or die "Cannot load func named SendShake: $^E\n";
push @EXPORT, "SendShake";sub SendShake
{
    $func{"SendShake"}->Call(@_);
}
$func{"GetRadomOnlineQQ"} = Win32::API::More->new($dllfile, "char * Api_GetRadomOnlineQQ()") or die "Cannot load func named GetRadomOnlineQQ: $^E\n";
push @EXPORT, "GetRadomOnlineQQ";sub GetRadomOnlineQQ
{
    $func{"GetRadomOnlineQQ"}->Call(@_);
}
$func{"AddQQ"} = Win32::API::More->new($dllfile, "int Api_AddQQ(char * __arg_0, char * __arg_1, int  __arg_2)") or die "Cannot load func named AddQQ: $^E\n";
push @EXPORT, "AddQQ";sub AddQQ
{
    $func{"AddQQ"}->Call(@_);
}
$func{"SetOLStatus"} = Win32::API::More->new($dllfile, "int Api_SetOLStatus(char * __arg_0, int __arg_1, char *  __arg_2)") or die "Cannot load func named SetOLStatus: $^E\n";
push @EXPORT, "SetOLStatus";sub SetOLStatus
{
    $func{"SetOLStatus"}->Call(@_);
}
$func{"GetMC"} = Win32::API::More->new($dllfile, "char * Api_GetMC()") or die "Cannot load func named GetMC: $^E\n";
push @EXPORT, "GetMC";sub GetMC
{
    $func{"GetMC"}->Call(@_);
}
$func{"GroupInvitation"} = Win32::API::More->new($dllfile, "char * Api_GroupInvitation(char * __arg_0, char * __arg_1, char *  __arg_2)") or die "Cannot load func named GroupInvitation: $^E\n";
push @EXPORT, "GroupInvitation";sub GroupInvitation
{
    $func{"GroupInvitation"}->Call(@_);
}
$func{"CreateDG"} = Win32::API::More->new($dllfile, "char * Api_CreateDG(char *  __arg_0)") or die "Cannot load func named CreateDG: $^E\n";
push @EXPORT, "CreateDG";sub CreateDG
{
    $func{"CreateDG"}->Call(@_);
}
$func{"KickDG"} = Win32::API::More->new($dllfile, "char * Api_KickDG(char * __arg_0, char * __arg_1, char *  __arg_2)") or die "Cannot load func named KickDG: $^E\n";
push @EXPORT, "KickDG";sub KickDG
{
    $func{"KickDG"}->Call(@_);
}
$func{"DGInvitation"} = Win32::API::More->new($dllfile, "char * Api_DGInvitation(char * __arg_0, char * __arg_1, char *  __arg_2)") or die "Cannot load func named DGInvitation: $^E\n";
push @EXPORT, "DGInvitation";sub DGInvitation
{
    $func{"DGInvitation"}->Call(@_);
}
$func{"GetDGList"} = Win32::API::More->new($dllfile, "char * Api_GetDGList(char *  __arg_0)") or die "Cannot load func named GetDGList: $^E\n";
push @EXPORT, "GetDGList";sub GetDGList
{
    $func{"GetDGList"}->Call(@_);
}
$func{"SendMusic"} = Win32::API::More->new($dllfile, "int Api_SendMusic(char * __arg_0, int __arg_1, char * __arg_2, char * __arg_3, char * __arg_4, char * __arg_5, char * __arg_6, char * __arg_7, char * __arg_8, char * __arg_9, char * __arg_10, char *  __arg_11)") or die "Cannot load func named SendMusic: $^E\n";
push @EXPORT, "SendMusic";sub SendMusic
{
    $func{"SendMusic"}->Call(@_);
}
$func{"SendObjectMsg"} = Win32::API::More->new($dllfile, "int Api_SendObjectMsg(char * __arg_0, int __arg_1, char * __arg_2, char * __arg_3, char * __arg_4, int  __arg_5)") or die "Cannot load func named SendObjectMsg: $^E\n";
push @EXPORT, "SendObjectMsg";sub SendObjectMsg
{
    $func{"SendObjectMsg"}->Call(@_);
}
$func{"IsFriend"} = Win32::API::More->new($dllfile, "int Api_IsFriend(char * __arg_0, char * __arg_1)") or die "Cannot load func named IsFriend: $^E\n";
push @EXPORT, "IsFriend";sub IsFriend
{
    $func{"IsFriend"}->Call(@_);
}
$func{"AddFriend"} = Win32::API::More->new($dllfile, "int Api_AddFriend(char * __arg_0, char * __arg_1, char* __arg_2)") or die "Cannot load func named AddFriend: $^E\n";
push @EXPORT, "AddFriend";sub AddFriend
{
    $func{"AddFriend"}->Call(@_);
}
$func{"SelfDisable"} = Win32::API::More->new($dllfile, "void Api_SelfDisable()") or die "Cannot load func named SelfDisable: $^E\n";
push @EXPORT, "SelfDisable";sub SelfDisable
{
    $func{"SelfDisable"}->Call(@_);
}
$func{"GetClientType"} = Win32::API::More->new($dllfile, "int Api_GetClientType()") or die "Cannot load func named GetClientType: $^E\n";
push @EXPORT, "GetClientType";sub GetClientType
{
    $func{"GetClientType"}->Call(@_);
}
$func{"GetClientVer"} = Win32::API::More->new($dllfile, "int Api_GetClientVer()") or die "Cannot load func named GetClientVer: $^E\n";
push @EXPORT, "GetClientVer";sub GetClientVer
{
    $func{"GetClientVer"}->Call(@_);
}
$func{"GetPubNo"} = Win32::API::More->new($dllfile, "int Api_GetPubNo()") or die "Cannot load func named GetPubNo: $^E\n";
push @EXPORT, "GetPubNo";sub GetPubNo
{
    $func{"GetPubNo"}->Call(@_);
}
$func{"GetMainVer"} = Win32::API::More->new($dllfile, "int Api_GetMainVer()") or die "Cannot load func named GetMainVer: $^E\n";
push @EXPORT, "GetMainVer";sub GetMainVer
{
    $func{"GetMainVer"}->Call(@_);
}
$func{"GetTXSSOVer"} = Win32::API::More->new($dllfile, "int Api_GetTXSSOVer()") or die "Cannot load func named GetTXSSOVer: $^E\n";
push @EXPORT, "GetTXSSOVer";sub GetTXSSOVer
{
    $func{"GetTXSSOVer"}->Call(@_);
}
$func{"UploadVoice"} = Win32::API::More->new($dllfile, "char * Api_UploadVoice(char * __arg_0, int __arg_1)") or die "Cannot load func named UploadVoice: $^E\n";
push @EXPORT, "UploadVoice";sub UploadVoice
{
    $func{"UploadVoice"}->Call(@_);
}
$func{"GuidGetVoiceLink"} = Win32::API::More->new($dllfile, "char * Api_GuidGetVoiceLink(char * __arg_0, char * __arg_1)") or die "Cannot load func named GuidGetVoiceLink: $^E\n";
push @EXPORT, "GuidGetVoiceLink";sub GuidGetVoiceLink
{
    $func{"GuidGetVoiceLink"}->Call(@_);
}
$func{"AddLogHandler"} = Win32::API::More->new($dllfile, "char * Api_AddLogHandler(int __arg_0)") or die "Cannot load func named AddLogHandler: $^E\n";
push @EXPORT, "AddLogHandler";sub AddLogHandler
{
    $func{"AddLogHandler"}->Call(@_);
}
$func{"RemoveLogHandler"} = Win32::API::More->new($dllfile, "char * Api_RemoveLogHandler()") or die "Cannot load func named RemoveLogHandler: $^E\n";
push @EXPORT, "RemoveLogHandler";sub RemoveLogHandler
{
    $func{"RemoveLogHandler"}->Call(@_);
}
1;
