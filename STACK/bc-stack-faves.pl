#!/bin/perl

# This script downloads my favorite stack questions, ie:
# https://stackexchange.com/users/favorites/144803?page=2&sort=recent
# and checks to see if I have a "bookmark comment" for them

# bookmark comment: I use firefox's bookmark "tag" feature to annotate
# pages (including stack pages) on which I wish to take action

require "/usr/local/lib/bclib.pl";

# TODO: make this an argument and/or find it from username?
my($userid) = 144803;

# copy my bookmarks file (running SQL commands on it "in situ" is
# probably a bad idea), and then query it

# TODO: allow non-default profile as an option
system("cp /home/barrycarter/.mozilla/firefox/*.default/places.sqlite /tmp");

# this is the "magic query" to show bookmarks with tags (starting with "!")
# TODO: could further restrict query to stackexchange sites (but note
# stackoverflow and mathoverflow, so pattern isn't obvious?)

my($query) = << "MARK";
SELECT mb1.title AS tag, mp.url, mp.title FROM moz_bookmarks mb1
 JOIN moz_bookmarks mb2 ON (mb1.id = mb2.parent)
 JOIN moz_places mp ON (mb2.fk = mp.id)
WHERE mb1.parent = 4 AND tag LIKE '!%';
MARK
;

my(@res) = sqlite3hashlist($query, "/tmp/places.sqlite");
my(%marks);

# link url to record
for $i (@res) {$marks{$i->{url}} = $i;}

# TODO: lower 86400 in production

my($out,$err,$res);

# TODO: grab all pages, not just first 10 (also bad for users who have
# fewer than 10 pages of favorites!)

for $i (1..10) {

  ($out,$err,$res) = cache_command2("curl 'https://stackexchange.com/users/favorites/$userid?page=$i&sort=recent'", "age=86400");

#  debug("OUT($i): $out");

  my(@qs) = split(/<div class="favorite-container">/s, $out);

  for $j (@qs) {

    my(%data) = ();

    # TODO: this is a hideous way to get the time and user
    $j=~s%>([^>]*?)<span class="favorite-last-editor">(.*?)</span>%%sg;
    ($data{date}, $data{user}) = ($1,$2);

    for $k (keys %data) {
      $data{$k}=~s/<.*?>//g;
      $data{$k}=trim($data{$k});
    }

    # the first URL is the only one I need
    $j=~s/href="(.*?)"//;
    $data{url} = $1;

    # if I don't have it tagged, note and proceed
    unless ($marks{$data{url}}) {
      # page number is important
      print "\nPage: $i\n";
      print "UNMARKED: $data{url}\n";
      next;
    }

    # if I do have it tagged, show details
    $data{mark} = $marks{$data{url}}->{tag};

    # ignore certain tags (intentionally keeping these conditions
    # separate for now)

#    if ($data->{tag} eq "! JUST WATCHING") {next;}
    if ($data->{tag} eq "! DONE") {next;}

    print "\nPage: $i\n";
    for $k (keys %data) {
      print "$k: $data{$k}\n";
    }
  }
}
