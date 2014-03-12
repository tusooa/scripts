#!/usr/bin/env perl

# conky里面要用execp。
%colors = (
    0 => 'black',
    1 => 'red',
    2 => 'green',
    3 => 'yellow',
    4 => 'blue',
    5 => 'magenta',
    6 => 'cyan',
    7 => 'white',
);
$_ = join "",<STDIN>;
$_ .= "\${color}";
s/\e\[0m/\${color}/g;
s/\e\[[01]m//g;
s/\e\[[0-9;]*?3(\d)[0-9;]*?m/\${color$1}/g;
s/\${color}\s*(?=\${)//g;
print;
