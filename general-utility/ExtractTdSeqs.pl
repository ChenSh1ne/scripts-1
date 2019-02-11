#!/usr/bin/perl

##########################################################################
# NWV 17 Jan 2013
# 
# This script is meant to take a bed file containing the coordinates of 
# tandem duplications and a genome file and output a new fasta file with
# the sequences of the tandemly-duplicated region (i.e. two copies of the
# TD region). This can then be used for, for instance, mapping RNA-seq or
# DNA-seq reads to the junctions.
#
##########################################################################

use strict;
use warnings;

print "\n\nusage: perl ExtractTdSeqs.pl <genome> <td_coords> <outfile> <radius>\n\n";

my($genome,$tds,$out,$rad) = @ARGV;

open(BED, "<$tds") || die "Can't open bed file: $!";
open(OUT, ">$out") || die "Can't open outfile: $!";


my %genome = &read_fasta($genome);



while (<BED>){
	chomp;
	my @line = split(/\t/, $_);
	print OUT ">$line[4]\n";
	my $seq1 = substr($genome{$line[0]}, $line[1], $rad);
	my $seq2 = substr($genome{$line[0]}, ($line[2]-$rad), $rad);
	print OUT $seq2.$seq1."\n";
}


###############
# subroutines #
###############

# This subroutine will read a fasta file into a hash,
# keeping as the ID only the string after ">" 
# until the first whitespace. It will return the hash.

sub read_fasta{
	my %sequence;
	my $header;
	my $seq;
	my $fasta = $_[0];
	
	open (FASTA, "<$fasta") || die "Can't open fasta file $fasta: #!";
		
	while (<FASTA>) {
		chomp($_);
 
		# Save the sequence name (first word after ">") in $header
		if (/>/) {
		    
		    if ($seq) {
			$sequence{$header}=$seq;
		    }
		    $header=$_;
		    $header =~ s/>//;
		    $header=~s/\s.*//;
		    $seq    = '';
		# otherwise continue pasting the sequence together.
		} else {
		    $_=~s/\s+//g;
			$seq.=$_;
		}
 
	}
# Store last sequence
	$sequence{$header}=$seq;
	return %sequence;
}
