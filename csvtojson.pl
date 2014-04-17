#!/usr/bin/perl

use strict;
use warnings;

use Text::CSV;
use JSON;

my $csv = Text::CSV->new ({ binary => 1, sep_char=>';'});
open my $FH, "<", "test.csv" or die "cannot open test.csv: $!";
my @data; #here we will put the end result, i.e. something which we will convert to json

#parse first line to get the adresses
#the first line of our csv contains the addresses,
#and the rest contains date;value1;value2;value3;...
my $addresses = $csv->getline($FH);
#put all addresses in the data
push(@data, {'address' => $_}) foreach (@$addresses);
#the first entry in the csv is just "datum", so we drop it
shift(@data);

my @measurements = $csv->getline_all($FH);
#we skip the first line, since it only contains the addresses
#measurements is a list of arrayrefs

foreach my $col (1..$#data+1) {
  my @entry;
  foreach my $line (0..$#{$measurements[0]}) {
    #(date, value)
    push (@entry, [$measurements[0]->[$line][0], $measurements[0]->[$line][$col]]);
 }
 push(@{$data[$col-1]{'measurements'}}, @entry);
}
close $FH;

my $json = encode_json(\@data); #convert the data to json
print $json;
open  OUTFILE, "+>feinstaub.json", or die "Could not open feinstaub.json";
print OUTFILE "$json \n";
close OUTFILE
