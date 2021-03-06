#!/bin/perl

# Modified version of bc-parse-ofx.pl that uses MySQL, a custom table
# I created ages ago, and credit card statements (instead of generic
# bank statements)

# Options:

# --caponesucks: deal with Capital One errors of not closing tags

require "/usr/local/lib/bclib.pl";

($all,$name) = cmdfile();

# capital one error
if ($globopts{caponesucks}) {

  # Capital One fucks up their ofx even more ~22 Oct 2015
#  $all=~s%<([A-Z]+)>([^>]*?)<%<$1>$2</$1>\n<%sg;

  for $i ("ACCTID","DTSERVER","DTSTART","DTEND") {
    $all=~s%<$i>(.*?)<%<$i>$1</$i>\n<%is;
  }
}

# hash data that is fixed for entire file (not per-transaction)
$regex = "acctid|dtserver|dtstart|dtend";
$all=~s%<($regex)>\s*(.*?)\s*</\1>%$ofx{$1}=$2%iseg;

# only use last four digits
$ofx{ACCTID}=~s/^.*(.{4})$/$1/;

# determine existing transactions (to avoid dupes; can't use UNIQUE INDEX in MySQL for legacy 

# transactions
while ($all=~s%<STMTTRN>(.*?)</STMTTRN>%%is) {
  $trans = $1;

  debug("TRANS: $trans");

  %trans = ();
  # <h>obscure code + confusing variable re-use, woohoo!</h>
  if ($globopts{caponesucks}) {
    $trans=~s%<(.*?)>(.*?)(?=<)%$trans{$1}=$2%iseg;
  } else {
    $trans=~s%<(.*?)>(.*?)</\1>%$trans{$1}=$2%iseg;
  }

  debug("TRANS",%trans);

  # cleanup for MySQL
  $trans{DTPOSTED}=~s/^(\d{4})(\d{2})(\d{2}).*$/$1-$2-$3/;

  # Capital One puts the last four digits of the card number in the
  # MEMO field with the full name of the merchant (but truncates the
  # merchant name in the NAME field), so I use the MEMO field, but cut
  # out the card number

  unless ($trans{MEMO}=~s/^$ofx{ACCTID}: //) {$trans{MEMO}=$trans{NAME};}

  $trans{MEMO}=~s/\'//g;

  # query (credcardstatements2 is new version w/ good indicies, etc)
  push(@queries,
"INSERT IGNORE INTO credcardstatements2
 (whichcard, amount, type, date, transaction_id, merchant) VALUES
 ('$ofx{ACCTID}', $trans{TRNAMT}, '$trans{TRNTYPE}', '$trans{DTPOSTED}',
 '$trans{FITID}', '$trans{MEMO}');");
}

# this is probably overkill
# open(A,"|mysql test");
print "BEGIN;\n";
for $i (@queries) {print "$i;\n"}
print "COMMIT;\n";
# close(A);
