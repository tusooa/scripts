package MPQ;

require Exporter;
require DynaLoader;
use strict;
our $VERSION = '0.1';
our @ISA = qw(Exporter DynaLoader);
our @EXPORT = qw();
our @EXPORT_OK = qw//;

bootstrap MPQ;
sub dl_load_flags { 0x01 }
1;
