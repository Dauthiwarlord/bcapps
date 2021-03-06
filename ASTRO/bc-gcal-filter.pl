#!/bin/perl

# filters out dates I need/want from gcal

# TODO: add DST start/end times, gcal does NOT have these?

require "/usr/local/lib/bclib.pl";

# find all holiday-like options
my(@options) = `gcal -hh | egrep -- '-holidays|-months' | egrep -v 'cc-holidays|include-holidays'`;
map(s/\s//g, @options);
my($options) = join(" ", @options);

# countries/areas (TODO: calling gcal -hh is redundant)
# did this to get mardi gras, sigh
my(@areas) = `gcal -hh | egrep -i 'holidays in '`;
map(s/^\s+(.*?)\s*\=.*$/$1/s, @areas);
my($areas) = join("+", @areas);

# this gives me every event "forever", so I can filter on complete list
my($out, $err, $res) = cache_command2("gcal --holiday-list=long --cc-holidays=$areas --date-format='%Y%>02#M%>02#D%1%2' -u $options 2014+2099 | sort | uniq", "age=9999999");

for $i (split(/\n/, $out)) {
  if ($i=~/eternal holiday list:\s+the year \d{4} is (a|no) leap year/i){next;}
  $i=~/^(.*?)\s+\((.*?)\)\s+[\+\-\*\#]\s+(\d+)/||warn("BAD LINE: $i");
  $cal{$3}{$1}{$2} = 1;
}

for $i (sort keys %cal) {
  for $j (sort keys %{$cal{$i}}) {
    my($k) = join(",", sort keys %{$cal{$i}{$j}});
    print "$i $j $k\n";
  }
}

=item comments

: below helps list dates and calendars
bc-gcal-filter.pl | perl -pnle 's/\d//g' | sort | uniq

Important calendars:

Ast

Dates I need from some cals: (* = included in multicult)

* Bah Bah<E1>'i New Year's Day 171
Chi Buddha's Birthday
Chi Chinese New Year's Day
Chi Confucius' Birthday
Chi Cycle 78/31-09 Jia-Wu/Horse [and similar]
Chr All Saints' Day
Chr Ash Wednesday
Chr Boxing Day
Chr Christmas Day
Chr Christmas Eve
Chr Easter Sunday
Chr Good Friday
Chr Palm Sunday
Chr St Valentine's Day
Chr Sylvester/New Year's Eve
* EG Coptic New Year's Day 1731
* ET Ethiopic New Year's Day 
Heb Hannukah/Festival of Lights
Heb Pesach/Passover
Heb Rosh Hashana/New Year's Day
Heb Yom Kippur/Atonement Day
* IN Indian New Year's Day 
* Isl Islamic New Year's Day 
Jap Buddha's Birthday
* Jap Cycle /- Bing-Shen/Monkey [and similar]
* Jap Japanese New Year's Day
* Per Noruz/Persian New Year's Day 
* TH Thai New Year's Day 
Zod ZhongQi-/Aquarius[] : [and similar, maybe]

=cut


