#!/usr/bin/perl

use strict;
use warnings;

print "\n\nusage: perl GetUnfinishedCommands.pl sp1_sp2\n\n";

my $s = shift;
my %finished;

unless( $s ){ die; }

open( my $F,"cat output/${s}/* | grep Finished |" ) || die "\nCan't open pipe to output folder\n";

while( <$F> ){
    
    chomp;
    my @a = split(" ",$_);
    $finished{$a[1]} = 1;

}

open( my $S, "cat cluster_scripts/${s}/* | grep -v bashrc |" ) || die "\nCan't open pipe to scripts folder\n";
open( my $O, '>', "${s}.unfinished" ) || die "\nCan't open outfile\n";

while( my $cmd = <$S> ){
    
    chomp($cmd);
    
    my @a = split(" ",$cmd);

    my $id = pop @a;

    $id =~s/\"$//;

    unless( exists $finished{$id} ){
	print $O $cmd,"\n";
    }
}

    



