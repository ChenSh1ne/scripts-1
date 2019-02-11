#!/usr/bin/perl

#########################################################
# NWV 19 March 2013
#
# Given a list of line numbers in file1 and the lines in 
# file2, this script will print lines in file2 present
# in file1.
#
# Ex.          
#
# file1:     file2:
# 
# 1          This
# 3          is
#            a
#            file
#
# output:
# 
# This
# a
#
# The input line number list must be 1-based.
######################################################## 


use strict;
use warnings;

unless(@ARGV == 3){ die &usage };

my($lines,$infile,$outfile) = @ARGV;
open(LINES,"<$lines") || die &usage;
open(IN,"<$infile")   || die &usage;
open(OUT,">$outfile") || die &usage;

my $count = 1;
my(%lines,@nums);
while(<LINES>){
    chomp;
    push(@nums,$_);
}

# Read the infile into a hash with keys as line numbers
while(<IN>){
    chomp;
    $lines{$count} = $_;
    $count++;
}

# For all values, print out the lines
foreach my $val (@nums){
    print OUT $lines{$val},"\n";
} 

close(OUT); close(LINES); close(IN);

sub usage{
    print "\n\nperl PrintLinesFromFile.pl\t<line_nums>";
    print "\t<infile>\t<outfile>\n\n";
}
