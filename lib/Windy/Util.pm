package Scripts::Windy::Util;

use 5.012;
use Exporter;
use Scripts::scriptFunctions;
use utf8;
use Encode qw/_utf8_on _utf8_off/;
use constant BACKEND => 'mojo';
use if BACKEND eq 'mpq', 'Scripts::Windy::Util::MPQ';
use if BACKEND eq 'mojo', 'Scripts::Windy::Util::Mojo';

our @ISA = qw/Exporter/;
our @EXPORT = qw/isGroupMsg msgText msgGroup msgGroupId
msgGroupHas msgSenderIsGroupAdmin msgStopping msgSender
uid uName isAt isAtId findUserInGroup isPrivateMsg
group invite friend $nextMessage $atPrefix $atSuffix
parseRichText $mainConf msgPosStart msgPosEnd
msgReceiver receiverName outputLog isMsg BACKEND $windyConf
sendTo/;
our @EXPORT_OK = qw//;

our $nextMessage = "\n\n";
our $mainConf = "windy-conf/main.conf";
our $windyConf = conf $mainConf;

1;
