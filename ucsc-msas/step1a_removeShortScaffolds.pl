#!/usr/bin/perl

use strict;
use warnings;

print "\n\nusage: perl RemoveShortScaffolds.pl in.fa min_len out.fa\n\n";
print "This script will write any scaffolds longer than min_len in in.fa\n";
print "to out.fa\n";

my ($in,$len,$out) = @ARGV;

unless( $in && $len && $out ){ exit(1); }

open(my $I,'<',$in) || die "\n\nYour infile doesn't appear to exist\n";
open(my $O,'>',$out) || die "\n\nCannot open outfile $out\n";

my $seq = '';
my $header = '';

while(<$I>){

    chomp;
    if( $_ =~/^>/ ){

	if( $seq ){
	    if( length $seq > $len ){
		print $O $header,"\n",$seq,"\n";
	    }
	 
	    $header = $_;
	    
	    $seq = '';
	} else {
	    $header = $_;
	}

    } else {
	$seq .= $_;
    }
}

# Last sequence

if( length $seq > $len ){
    $seq =~s/(.{0,80})/$1/g;
    print $O $header,"\n",$seq,"\n";
}

close($I);
close($O);


      

    
