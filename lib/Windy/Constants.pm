package Scripts::Windy::Constants;

use 5.012;
use Scripts::scriptFunctions;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/%EventRet %Events %Status/;

our %EventRet = (
    pass => 0,
    done => 1,
    stop => 2,
    'agree-one-side' => 30,
    'refused' => 20);
our %Status = (
    online => 10,
    away => 30,
    busy => 50,
    well => 60,
    'not-disturb' => 70,
    offline => 201,
);
our %Events = (
    'friend-msg' => 1,
    'group-msg' => 2,
    'discuss-msg' => 3,
    'sess-msg' => 4,
    'friend-one-side' => 1000,
    'add-friend' => 1001,
    'friend-status-change' => 1002,
    'lose-friend' => 1003,
    'signature-change' => 1004,
    'say-comment' => 1005,
    'typing' => 1006,
    'query' => 1007,
    'shake' => 1008,
    'join-group-o' => 2001,
    'invited-to-group-o' => 2002,
    'invited-to-group' => 2003,
    'permitted-into-group' => 2005,
    'quit-group-o' => 2006,
    'kicked-out-of-group-o' => 2007,
    'dismissed-group' => 2008,
    'be-group-admin' => 2009,
    'no-longer-group-admin' => 2010,
    'group-card-change' => 2011,
    'group-name-change' => 2012,
    'group-broadcast-change' => 2013,
    'quiet' => 2014,
    'speak' => 2015,
    'all-quiet' => 2016,
    'all-speak' => 2017,
    'anon-talk-on' => 2018,
    'anon-talk-off' => 2019,
    'mpq-loaded' => 10000,
    'mpq-restart' => 10001,
    'new-account' => 11000,
    'login' => 11001,
    'logout' => 11002,
    'logout-passive' => 11003,
    'logout-idle' => 11004,
    'plugin-load' => 12000,
    'plugin-enable' => 12001,
    'plugin-disable' => 12002,
    'plugin-clicked' => 12003,
    'receive-money' => 80001,
    'undefined' => -1,
);
