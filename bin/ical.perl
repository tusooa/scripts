#!/usr/bin/env perl
use 5.012;
use Tie::iCal;
use LWP::Simple;
my $year = (localtime time)[5] + 1900;
my %files = ('/tmp/enh' => 'http://www.google.com/calendar/ical/en.australian%23holiday%40group.v.calendar.google.com/public/basic.ics', '/tmp/cnh' => 'ical.mac.com/ical/China32Public32Holidays.ics');
open (OUT, '>', "$ENV{HOME}/.calendar/cal-holidays") or die "Cannot open file: $!\n";
say OUT "#ifndef _holidays_\n#define _holidays_\n\n";
for my $file (keys %files)
{
	open (IN, '>', $file) or die "Cannot open $file: $!\n";
	print IN get $files{$file};
	close IN;
	tie my %events, 'Tie::iCal', $file or die "Failed to tie file!\n";
	my @items = map { $events{$_}->[1] } keys(%events);
	untie(%events);
	@items = sort { $a->{'DTSTART'}->[1] cmp $b->{'DTSTART'}->[1] } @items;
	for my $item (@items)
	{
		my $date=$item->{'DTSTART'}->[1];
		$date=~/($year)(\d{2})(\d{2})/ or next;
		$date=int($2)."/".int($3);
		my $holiday = $item->{SUMMARY};
		$holiday =~ s/^.+\((.+)\)\s*$/\1/;
		$holiday =~ s/\[.+\]//g;
                $holiday =~ s/&/&amp;/g;
		say OUT "$date\t$holiday";
	}
}
say OUT "\n#endif /* _holidays_ */";

close OUT;
