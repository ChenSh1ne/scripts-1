#!/usr/bin/perl

use warnings;
use strict;

print "perl whats_missing.pl sp1 sp2\n";

my $s1 = shift;
my $s2 = shift;

my %all;
my %done;

my $psl = "psl/${s1}_${s2}/";
my  $lift = "genomes/${s1}_allfiles/${s1}.info";

open( my $L, '<', $lift );
while( <$L> ){ 
    chomp; 
    my @a = split( "\t", $_ ); 
    $all{$a[0]} = $a[1];
}

opendir( my $D, $psl );

while( readdir($D) ){

    chomp;

    my @s = split( /\./, $_ );

    $done{$s[0]} = 1;
}

foreach my $a ( keys %all ){

    unless( exists $done{$a} ){
	print $a,"\t",$all{$a},"\n";
    }
}

    

