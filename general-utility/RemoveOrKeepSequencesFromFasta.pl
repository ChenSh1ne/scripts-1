#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($f, $l, $r, $o);
my ($F, $L, $O);

&init;

# Get Ids
my %keep;

while(<$L>){
    chomp;
    $keep{$_} = 1;
}

close($L);

# Read and keep / remove

my $id;
my $seq;

while(<$F>){

    chomp;

    if( $_ =~m/^>/ ){

	# not the first time through
	if( $id ){
	    
	    if( ( $r eq 'keep' && exists $keep{$id} ) ||
		( $r eq 'remove' && ! exists $keep{$id} ) ){
		
		print $O ">${id}\n${seq}\n";
	
	    }
	    
	    $seq = '';
	    ($id) = $_ =~/^(\S+)/ ;
	    $id =~s/^>//;
	    print "new id: $id\n";
	    
	} else {
	    ($id) = $_ =~/^(\S+)/ ;
	    $id =~s/^>//;
	    print "first id: $id\n";
	}
    } else {
	$seq .= $_;
    }
}

# Last one

if( ( $r eq 'keep' && exists $keep{$id} ) ||
    ( $r eq 'remove' && !exists $keep{$id} ) ){
    
    print $O "${id}\n${seq}\n";
    
}

close( $O );
close( $F );

################################ SUBROUTINES ###################################

sub init{

    GetOptions( 'in:s' => \$f,
		'out:s' => \$o,
		'keep:s' => \$r,
		'ids:s' => \$l );

    unless( $l && $f && $o && ( $r eq 'keep' || $r eq 'remove' ) ){ 
	&usage;
	exit 1;
    }


    open( $L, '<', $l ) || die "Cannot open $l\n";
    open( $F, '<', $f ) || die "Cannot open $f\n";
    open( $O, '>', $o ) || die "Cannot open $o\n";
    
}

sub usage{

    my $u =<<END;

usage: perl RemoveOrKeepSequencesFromFasta.pl --in infile.fa --ids ids.list 
                                              --keep <keep|remove> --out outfile.fa

in      Fasta file to filter
out     Output fasta file name
keep    Do you want to keep or remove the sequences from your infile?
ids     A list of sequence IDs, one per line, to keep or remove

This will match the first word of the sequence name and the first word of the
supplied IDs. 

END

print $u;

}
