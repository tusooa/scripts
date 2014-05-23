#!/usr/bin/env perl
use 5.012;
use LWP::Simple;
use utf8;
my $year = (localtime time)[5] + 1900;
#say $year;
#my %files = (#'/tmp/enh' => 'http://www.google.com/calendar/ical/en.australian%23holiday%40group.v.calendar.google.com/public/basic.ics',
#             '/tmp/cnh' => #'http://www.google.com/calendar/ical/china__zh_cn@holiday.calendar.google.com/public/basic.ics');
#             'http://ical.mac.com/ical/China32Holidays.ics');
open (OUT, '>', "$ENV{HOME}/.calendar/cal-holidays") or die "Cannot open file: $!\n";
say OUT "#ifndef _holidays_convert_ics_\n#define _holidays_convert_ics_\n\n";
my @content = split /\n/,get 'http://ical.mac.com/ical/China32Holidays.ics';

my $print = 1;
for (@content) {
    when (/^END:VEVENT/) {
        say OUT '' if $print;
        $print = 1;#reset $print value
    }
    when (/^DTSTART;VALUE=DATE:(\d{4})(\d{2})(\d{2})$/) {
        #$date=int($1).'/'int($2).'/'.int($3);
        $print = 0 if $year != int $1;#只打印今年的
        print OUT "$2/$3\t" if $print;
    }
    when (/^SUMMARY:/) {
        print OUT $' if $print;
    }
    when (/^RESOURCES;LANGUAGE=EN:/) {
        print OUT " ($')" if $print;
    }
}

say OUT "\n#endif /* _holidays_convert_ics_ */";

close OUT;
