#!/usr/bin/env perl
use Scripts::Base;

my %types = (
    '文本型' => 'char *',
    '无' => 'void',
    '整数型' => 'int',
    '逻辑型' => 'bool',
    );

binmode STDOUT, ':unix';
my $type;
my $funcName;
my $first = 1;
my $argc = 0;
my @funcs;
my @cur;
while (<<>>) {
    for (utf8 $_) {
        if (/^Api_(\S+) 返回类型:(\S+)/) { # 函数定义行
            push @funcs, [@cur] if @cur;
            $type = $types{$2};
            $funcName = $1;
            @cur = ($type, $funcName);
            #$funcName =~ s/加密/Encrypt/;
            #$funcName =~ s/解密/Decrypt/;
=comment
            if (!$first) {
                if ($oldType eq 'void') {
                    say ');';
                    say 'return string();';
                } else {
                    say '));';
                }
            }
            say (($first ? q// : qq/}\n/). qq/if (func == "$funcName") {/);
            if ($type eq 'void') {
                #say qq/retval = string()/;
            } elsif ($type eq 'int') {
                say q/return to_string(/;
            } elsif ($type eq 'string') {
                say q/return encodeBase64(/;
            }
            say 'Api_'.$funcName.'(';
            $first = 0;
=cut
        } elsif (/^\.参数[^,]+, (.+?型)/) {
            my $argType = $types{$1};
            push @cur, $argType;
=comment            
            if ($argc != 0) { # not first arg
                print ',';
            }
            if ($argType eq 'int') {
                print 'stoi(';
            } elsif ($argType eq 'string') {
                print 'dec_s(';
            } else {
                die;
            }
            say 'args['.($argc++).'])';
=cut
        } else {
            # pass
        }
    }
}
push @funcs, [@cur];
use Data::Dumper;
print Dumper \@funcs;

# call-api.hpp.part
open CALL, '>', 'call-api.hpp.part' or die;
open DEF, '>', 'port/defs.hpp.part' or die;
open LOAD, '>', 'port/load.hpp.part' or die;

binmode CALL, ':unix';
binmode DEF, ':unix';
binmode LOAD, ':unix';

my %fHead = (
    'char *' => 'return encodeBase64(',
    'int' => 'return to_string(',
    'bool' => 'return to_string(',
    'void' => '',
    );
my %fTail = (
    'char *' => ');',
    'int' => ');',
    'bool' => ');',
    'void' => ";\nreturn string();",
    );
my %aFunc = ('char *' => 'dec_s', 'int' => 'stoi', 'bool' => 'stoi');
for (@funcs) {
    my @d = @$_;
    my $retType = shift @d;
    my $funcName = shift @d;
    my $libFN = $funcName;
    $funcName =~ s/加密/Encrypt/;
    $funcName =~ s/解密/Decrypt/;
    if ($funcName eq 'CrackIOSQQ') {
        next;
    }
    $libFN =~ s/加密/'\xbc\xd3\xc3\xdc'/e;
    $libFN =~ s/解密/'\xbd\xe2\xc3\xdc'/e;
    say DEF "typedef $retType (__stdcall * Api_${funcName}_ptr)("
        . (join ',', @d). ");\n"
        . "Api_${funcName}_ptr Api_${funcName};";
    say LOAD "if (! (Api_${funcName} = (Api_${funcName}_ptr)GetProcAddress(dll, ". qq/"Api_${libFN}"/ ."))) {\n"
        . qq/  croak("cannot load Api_${funcName}");\n}/;
    say CALL "if (func == " . qq/"${funcName}"/ .") {\n"
        . $fHead{$retType} . qq/Api_${funcName}(/
        . (join ', ', map { $aFunc{$d[$_]} . '(args[' . $_ . '])' } 0..$#d)
        . ')' . $fTail{$retType} . "\n}";
}
