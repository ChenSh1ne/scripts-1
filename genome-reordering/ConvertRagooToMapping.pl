#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;

my $loc = 0;
my $ori = 0;
my $ragoo;
my $slens;
my $out;

my $O;           # output filehandle
my @slist;       # scaffold to chromosome (orderings) files
my %slens;       # scaffold lengths
my %stoc;        # key = scaffold, value = chromosome
my %chrmnmx;     # key = scaffold, value = array of min and max chrom coordinates
my %scfmnmx;     # key = scaffold, value = array of min and max scaf coordinates
my $misslen = 0; # how many bps in the unassigned scaffolds
my $nmiss = 0;   # how many unassigned scaffolds
my $ninc = 0;    # how many assigned scaffolds
my $totlen = 0;  # total length of assigned scaffolds

print "\n\n0. INITIALIZING...\n";

&initialize;

print "4. PROCESSING ORDERINGS FILES...\n";
foreach my $file ( @slist ){

    open( my $F, '<', "${ragoo}/orderings/${file}" ) || die "ERROR: Cannot open ${ragoo}/ordering/${file}\n";

    # file is something like Herato0101_orderings.txt, which contains lines like this:
    # draft        strand loc   ori
    # scaffold1682 -	  1.00	1.0
    # scaffold671  +	  0.83	1.0
    # scaffold258  +      0.02	1.0
    
    # get file base
    my $chr = $file;
    $chr =~s/_orderings.txt//;

    # Desired output columns. Going to substitute the scaffold number for median_pos,
    # because gwplotting will still order correctly
    # #scaf scafLen scafMin scafMax chr chrMin chrMax strand num_proteins median_pos

    my $snum = 1;

    # For every scaffold assigned to this chromosome
    while( <$F> ){

	chomp;
	my @l = split( "\t", $_ );

	# Some short scaffolds don't have an entry in intra...paf
	if( ! exists $slens{$l[0]} ){ 
	    print "---WARNING: ", $l[0]," doesn't have a length\n"; 
	    $slens{$l[0]} = 0;
	}

	# If we pass confidence thresholds
	if( $l[2] >= $loc && $l[3] >= $ori ){
	    
	    # Just check that we have high quality assignments
	    if( exists $scfmnmx{$l[0]} && exists $chrmnmx{$l[0]} ){
		print $O join( "\t", $l[0], $slens{$l[0]}, ${$scfmnmx{$l[0]}}[0], 
			       ${$scfmnmx{$l[0]}}[1], $chr, ${$chrmnmx{$l[0]}}[0],
			       ${$chrmnmx{$l[0]}}[1], $l[1], 'NA', $snum ), "\n";
	    
		$snum++;
		$ninc++;
		$totlen += $slens{$l[0]};
		
	    } else {
		# Doesn't pass match quality threshold
		$nmiss++;
		$misslen += $slens{$l[0]};
	    }
	} else {
	    # Doesn't pass confidence thresholds
	    $nmiss++;
	    $misslen += $slens{$l[0]};
	}
    }

    close( $F );
}

print "\nFINISHED\n\n---ORDERED SCAFFOLDS: $ninc scaffolds $totlen bp were ordered\n\n";
print "---UNORDERED SCAFFOLDS: $nmiss scaffolds totaling $misslen bp were not ordered\n\n\n";
close( $O );


######################## SUBROUTINES ##########################################

sub initialize{

    GetOptions( 'ragoo:s' => \$ragoo,
		'min_location:f' => \$loc,
		'min_orientation:f' => \$ori,
		'out:s' => \$out );
    

    unless( $ragoo && $out ){

	print "\n\nERROR: You must specify the RaGOO directory, the file containing\n";
	print "scaffold lengths, and the output file\n\n";
	die &usage;

    } else {

	print "1. PREPARING OUTPUT FILE...\n";
	# Output file
	open( $O, '>', $out ) || die "ERROR: Cannot open $out\n";
	print $O "#scaf\tscafLen\tscafMin\tscafMax\tchr\tchrMin\tchrMax\tstrand\tnum_proteins\tmedian_pos\n";

	print "2. GRABBING RAGOO OUTPUT...\n";
	# RaGOO ordering files
	opendir( my $D, "${ragoo}/orderings/" ) || die "ERROR: Cannot open ragoo directory ${ragoo}/orderings\n";
	@slist = grep { !/^\./ } readdir( $D );
	closedir( $D );

	# RaGOO grouping files
	opendir( my $G, "${ragoo}/groupings/" ) || die "ERROR: Cannot open ragoo directory ${ragoo}/groupings\n";
	my @flist = grep { /contigs\.txt$/ } readdir( $G );
	closedir( $G );

	foreach my $g ( @flist ){

	    chomp( $g );

	    ( my $cname = $g ) =~s/_contigs\.txt//;
 
	    open( my $G, '<', "${ragoo}/groupings/${g}" )  || die "ERROR: Cannot open groupings file $g\n";

	    while( <$G> ){

		chomp;
		my @l = split( "\t", $_ );
		$stoc{$l[0]} = $cname;
	    }

	    close( $G );
	}
	
	# Get min/mix coords for each scaffold on the appropriate
	# reference chromosome
	print "3. GETTING MIN/MAX HIT COORDINATES...\n";
	my $paf = "${ragoo}/chimera_break/intra_contigs_against_ref.paf";

	open( my $P, '<', $paf ) || 
	    die "ERROR: You must not have split chimeras, because ${ragoo}/chimera_break/ doesn't exist\n";

	while( my $p = <$P> ){

	    chomp( $p );
	    my @l = split( "\t", $p );
	    
	    # scaffold194 433243 289209 340919 + Hmel213001o 18127314 3820637 3871486 23731 53296 60 ...
	    # scaffold194 433243 184639 212014 + Hmel213001o 18127314 3714733 3741672 13994 28032 60 ...

	    $slens{$l[0]} = $l[1];

	    # Only analyze those hits to the assigned chromosome
	    if( $l[5] eq $stoc{$l[0]} && $l[11] > 30 ){

		# Get min and max of hit, compare to existing min and max
		if( exists $chrmnmx{$l[0]} ){
		    
		    if( $l[2] < ${$scfmnmx{$l[0]}}[0] ){ ${$scfmnmx{$l[0]}}[0] = $l[2]; }
		    if( $l[3] > ${$scfmnmx{$l[0]}}[1] ){ ${$scfmnmx{$l[0]}}[1] = $l[3]; }

		    if( $l[7] < ${$chrmnmx{$l[0]}}[0] ){ ${$chrmnmx{$l[0]}}[0] = $l[7]; }
		    if( $l[8] > ${$chrmnmx{$l[0]}}[1] ){ ${$chrmnmx{$l[0]}}[1] = $l[8]; }
		    
		} else {
		    
		    ${$scfmnmx{$l[0]}}[0] = $l[2];
		    ${$scfmnmx{$l[0]}}[1] = $l[3];

		    ${$chrmnmx{$l[0]}}[0] = $l[7];
		    ${$chrmnmx{$l[0]}}[1] = $l[8];

		}
	    }
	} # END OF PAF

	print "\nNOTE: Using ", scalar keys %chrmnmx," chromosome coords and ", scalar keys %scfmnmx," scaffold coords\n\n"; 
    }
}

sub usage{

    my $u =<<END;

usage: perl ConvertRagooToMapping.pl --ragoo <ragoo_outpu> 
				     --min_location <0.0> 
                                     --min_orientation <0.0> 
                                     --out <out.mapping>

This script will concatenate and massage the output from RaGOO to produce a
file for use in plotting with gwplotting. 

ragoo            Name of the RaGOO output directory (its default is 
                 ragoo_output)

min_location     Minimum location score required to include ordering info 
                 for a draft scaffold (column 3 in the RaGOO ordering files)

min_orientation  Minimum orientation score required to include ordering info
                 for a draft scaffold (column 4 in the RaGOO ordering files)

out              Output file name


END

    print $u;

}

