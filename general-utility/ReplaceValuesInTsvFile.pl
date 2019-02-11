#!/usr/bin/perl

#######################################################################
# NWV 4 June 2013
#
# This script will take a 1-to-1 conversion table of IDs,
# read it into a hash, and replace the respective IDs in the specified
# tab-separated values (TSV) file.
#
######################################################################

use strict;
use warnings;

unless ( scalar @ARGV == 4 ){ die &usage; }

my($ids,$tsv,$col,$out) = @ARGV;

open (IDS,"<$ids") || die "Can't open IDs file\n\n",&usage;
open (TSV,"<$tsv") || die "Can't open TSV file\n\n",&usage;
open (OUT,">$out") || die "Can't open outfile\n\n",&usage;

my %ids;

while(<IDS>){
    chomp;
    my @line = split("\t",$_);
    $ids{$line[1]} = $line[0];
}

while(<TSV>){
    chomp;
    my @line = split("\t",$_);
    splice(@line,($col-1),1,$ids{$line[$col-1]});
    print OUT join("\t",@line),"\n";
}

close(OUT);
close(TSV);
close(IDS);



###############
# subroutines #
###############

sub usage{
    print "usage: perl ReplaceValuesInTsvFile.pl <values.txt> <infile.txt> <column> <outfile>\n\n";
    print "\tvalues.txt\t2-column file (tab-sep) of value pairs, new value - old value.\n";
    print "\tinfile.txt\ttab-separated table with for conversion\n";
    print "\tcolumn\t\tcolumn in input TSV with IDs for conversion (1-based)\n";
    print "\toutfile\t\toutput filename\n\n";
}
