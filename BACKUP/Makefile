# I am assuming the converted files are up-to-date; in theory could
# check them against the *-files.txt files but don't want to rerun
# portions of bc-unix-dump.pl unnecessarily

# converted file lists on all drives I recognize
converted=$(shell egrep -v '^\#|^$$' /home/barrycarter/BCGIT/BRIGHTON/mounts.txt | perl -anle 'print "$$F[0]/$$F[1]-converted.txt"')

# filelist.txt is the end product of all this
all: filelist.txt

# afad = all files, all directories

afad.txt: ${converted}
	nice -n 19 sort ${converted} > afad.txt

# everything previously backed up, sorted
# TODO: assuming the *.exclude files are up-to-date, but should check for that

previouslydone.txt.srt:
	nice -n 19 sort -t '\0' -k2nr /root/massbacks-idrive-saopaulo/*.exclude | nice -n 19 sort -t '\0' -k1,1 -u > previouslydone.txt.srt

# the files bc-chunk-backup2 uses to determine what to back up

backup0.txt: afad.txt previouslydone.txt.srt
	nice -n 19 join --check-order -a 1 -t '\0' afad.txt previouslydone.txt.srt | nice -n 19 sort -t '\0' -k2nr > backup0.txt

# create exclusions egrep file from annotated file
exclusions.txt: exclusions-commented.txt
	egrep -v '^\#|^ *$$' exclusions-commented.txt | perl -pnle 's/\$$/\0/' > exclusions.txt

# bc-chunk-backup2 creates statlist.txt and filelist.txt just usign one
# temporarily changed to 100G for bulk backup to idrive express drive
# (also renamed massbacks-idrive-saopaulo and started fresh)
filelist.txt: exclusions.txt backup0.txt
	nice -n 19 egrep -avf exclusions.txt backup0.txt | nice -n 19 bc-join-backup.pl | nice -n 19 bc-chunk-backup2.pl --checkfile --limit=100,000,000,000 --debug

# TODO: write up the meta-procedure for using this Makefile
