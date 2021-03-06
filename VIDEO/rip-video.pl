#!/bin/perl

# selectively rips a video (one frame per second) to display it faster

require "/usr/local/lib/bclib.pl";

# TODO: 1280x720 seems to be the best resolution for youtube (even
# though my own screen resolution is lower)

# 256x144 is 5x5 tiling which really seems nice
# TODO: do I want frames?

# TODO: use parallel for multiples

# get the name and create a subdir to store files
my($name) = @ARGV;
unless ($name) {die "Usage: $0 name";}
if ($#ARGV > 0) {die "ERROR: exactly one argument required";}
my($targetdir) = "$bclib{home}/VIDEOFRAMES/$name";
unless (-d $targetdir) {dodie("mkdir('$targetdir')");}
# TODO: this is an awful way to make <> now be STDIN
@ARGV = ();

# TODO: make this flexible?
my($size) = "256:144";

# warn "TESTING LOWER RESOLUTION";
# $size = "128:72";

open(A, ">$targetdir/rip.sh")||die("Can't open rip.sh, $!");

# the commands I will run (or at least print)
my(@cmds);

# montage = one for every 25 videos (M)
# video = one for every video (V)
# frame = one for every second of every video (F)

my($montage);
my($video);

my($out, $err, $res);

print "Reading data from STDIN...\n";

while (<>) {

  chomp;

  unless (-f $_) {die "STDIN: $_ is not a file";}

  # if 25 limit (or first run), reached, next montage
  if ($video%25 == 0) {
    $montage = sprintf("%08d",++$montage);
    $video = 0;
  }

  # increment video, but keep in %04d form
  $video = sprintf("%04d",++$video);


  # break this video in "one second" chunks (assuming 24 frames = one second)
  # TODO: better way to do this w/o assuming it's 24 fps?
  # /usr/bin/nice here forces non-shell version whose args I know
  push(@cmds, qq{/usr/bin/nice -n 19 ffmpeg -hide_banner -loglevel panic -i "$_" -vf "select=not(mod(n\\,24)), scale=$size" -vsync vfr $targetdir/M${montage}V${video}F%08d.jpg 1> /dev/null 2> /dev/null});

}

print A join("\n", @cmds),"\n";
print A "xmessage $0 has finished\n";
close(A);
print "Run or parallel run $targetdir/rip.sh\n";

=item notes

w/o parallel

2018-01-11 14:03:43.040278739 -0700 = latest for muppets tiny frames
2018-01-11 13:37:29.575183985 -0700 = first for muppets tiny frames

or 26m 13.465094754s = 1573.465094754s

(but system under unreliable load)

197756 total, so about 125.6818474456 per second

=cut
