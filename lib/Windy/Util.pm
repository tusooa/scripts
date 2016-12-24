package Scripts::Windy::Util;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
#no warnings qw/experimental/;
use constant BACKEND => $ENV{WINDY_BACKEND} =~ /^(?:mojo|mpq)$/ ? $ENV{WINDY_BACKEND} : 'mojo';
use Scripts::Windy::Util::Base;
use if BACKEND eq 'mpq', 'Scripts::Windy::Util::MPQ';
use if BACKEND eq 'mojo', 'Scripts::Windy::Util::Mojo';

our @ISA = qw/Exporter/;
our @EXPORT = qw/isGroupMsg msgText msgGroup msgGroupId
msgGroupHas msgSenderIsGroupAdmin msgStopping msgSender
uid uName isAt isAtId findUserInGroup isPrivateMsg
group invite friend $nextMessage $atPrefix $atSuffix
parseRichText $mainConf msgPosStart msgPosEnd
msgReceiver receiverName outputLog isMsg BACKEND $windyConf
sendTo replyToMsg $mainConf msgGroupMembers setGroupCard/;
our @EXPORT_OK = qw//;

1;
