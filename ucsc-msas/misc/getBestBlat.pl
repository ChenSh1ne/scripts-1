#!/usr/bin/perl

use strict;
use warnings;

print "\nusage: perl getBestBlat.pl psl out\n";

my $p = shift;
my $o = shift;

unless( $p && $o ){ exit(1); }

open( my $P,'<', $p ) || die "\n$p doesn't exist\n";
open( my $O,'>', $o ) || die "\ncan't open $o\n";

my %scores;
my %fprint;

while(<$P>){

    chomp;
    
    my ($matches, $misMatches, $repMatches, 
	$nCount, $qNumInsert, $qBaseInsert, 
	$tNumInsert, $tBaseInsert, $strand, 
	$qName, $qSize, $qStart, $qEnd, 
	$tName, $tSize, $tStart, $tEnd, 
	$blockCount, $blockSizes, $qStarts, 
	$tStarts) = split("\t", $_);
    
#    my $pslScore = ($matches + ( $repMatches >> 1) ) -
#        $misMatches - $qNumInsert - $tNumInsert;

    my $pslScore = $matches;
    
    if( exists $scores{$qName} ){
	if( $pslScore > $scores{$qName} ){
	    $fprint{$qName} = join("\t",$qName,$tName,
				   $strand,$qSize,$qStart,
				   $qEnd,$tSize,$tStart,
				   $tEnd);
	}
    } else {
	$scores{$qName} = $pslScore;
	$fprint{$qName} = join("\t",$qName,$tName,
			       $strand,$qSize,$qStart,
			       $qEnd,$tSize,$tStart,
			       $tEnd);
    }

}


foreach my $scaf ( keys %fprint ){

    print $O $fprint{$scaf},"\n";

}    

close($O);
close($P);
