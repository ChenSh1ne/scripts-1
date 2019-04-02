#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

# Global variables
my $scafs;
my $sizes;
my $prots;
my $gff;
my $min_hits = 1;
my $out = 'reordering';
my $minCov = 10;
my $maxDiff = 50;
my $misassembly = 10;
my %protein_locs;
my %best_hits;
my @best_chrs;
my %good_chrs;
my %scaf_hits;
my %scaf_lens;
my $skip = 0;
my @allScafs;

##### Many of these are used in subroutines, so must define as
##### global variable 
# Information relative to the target scaffold
my %scaf_mins;      # Keep track of leftmost hit coordinates
my %scaf_maxs;      # Keep track of rightmost hit coordinates
my %scaf_strands;   # Keep track of hit strands
my %smids;          # Keep track of midpoints of hits (relative to scaf)

# Information relative to the reference chromosome / scaffold
my %chrs;           # Keep track of which chrs the hits are from
my %chr_mins;       # Keep track of the leftmost protein locs
my %chr_maxs;       # Keep track of the rightmost protein locs
my %chr_strands;    # Keep track of protein strands
my %cmids;          # Keep track of midpoints of hits (relative to chr)


my $O0; # out.parsedPsl
my $O1; # out.mapped
my $O2; # out.uncertain
my $O3; # out.unmapped
my $O4; # out.misassembled

## 0. INITIALIZE ---------------------------------------------------------------
print "\n\n0. INITIALIZING...\n\n";

&initialize;

# Check if we've done BLATing before, and ask if we want to re-do

if( -e ${out}.'.parsedPsl' ){

    print "\n\nIt looks like you've already run BLAT because ${out}.parsedPsl already exists.\n";
    print "Choose an option:\n\n";
    print "\t0: Rerun BLAT and parsing\n";
    print "\t1: Use previous parsed results in ${out}.parsedPsl\n\n";

    $skip = <STDIN>;
    chomp $skip; 

}
 
## BLAT ------------------------------------------------------------------------

print "Skip is $skip\n";

if( $skip == 0 ){
    
    my $results = ${prots}.'_to_'.${scafs}.'.psl';

    print "5. BEGINNING TO BLAT\n\n";
    system( "blat -mask=lower -q=prot -t=dnax -dots=10 $scafs $prots $results" );

    print "6. Finished BLATing, beginning to parse...\n";
    my $bh = &parse_blat( $results );
    %best_hits = %$bh;

    # Print out parsed best hit results and save for later. This is out.parsedPsl.
    # Each value in best_hits is an array ref with:
    # score, proteinId, pctCover, scaf, scafStart, scafEnd, strand
    # remember that protein_locs contains chrom, start, end, strand

    open( $O0, '>', ${out}.'.parsedPsl' );
    print $O0 "#prot\tpctLen\tscaf\tscafStart\tscafEnd\tscafStrand\tchr\tchrStart\tchrEnd\tchrStrand\n";

    foreach $bh ( keys %best_hits ){
	
	my @info = ( @{$best_hits{$bh}}, @{$protein_locs{$bh}} );    
	shift @info;
	
	#   print "info contains ",join(",",@info),"\n";
	
	print $O0 join( "\t", @info),"\n";
	push( @{$scaf_hits{$info[2]}}, \@info );
	
    }

} else {

    # Simply read in BLAT results from the previous run's parsedPsl file
    print "\nSkipping BLATing and reading in parsed results from ${out}.parsedPsl\n";

    open( $O0, '<', ${out}.'.parsedPsl' ) || die "ERROR: Cannot open ${out}.parsedPsl\n";

    while( <$O0> ){

	chomp;
	my @info = split( "\t", $_ );
	push( @{$scaf_hits{$info[2]}}, \@info );
    }
}

close($O0);
   
## MAP ---------------------------------------------------------------------------

# Get best locations for each scaffold to each chromosome. scaf_hits is a hash of 
# array references. Each ref contains information on a best protein blat hit: 
# 0 - protein
# 1 - scafStart
# 2 - scafEnd
# 3 - scafStrand
# 4 - chr
# 5 - chrStart
# 6 - chrEnd
# 7 - chrStrand
    
# What is the "best match" for a scaffold? Must pass minimum number of protein hits.
# It could also have: 
#  1) equal num to more than one chr (put into "uncertain" bin)
#  2) no matches (put into "unmapped" bin)
#  3) many matches to different chromosomes, which may indicate a misassembly (put
#     into "misassembly" bin)

# Process each scaffold from draft sequence
foreach my $scaf ( @allScafs ){

    if( ! exists $scaf_hits{$scaf} ){
	
	# No reference protein hits to this scaffold, put in the "unmapped" bin
	print $O3 $scaf,"\t",$scaf_lens{$scaf},"\n";

    } else {
	
	# At least one best hit...

	# Information relative to the target scaffold
	undef %scaf_mins;      # Keep track of leftmost hit coordinates
	undef %scaf_maxs;      # Keep track of rightmost hit coordinates
	undef %scaf_strands;   # Keep track of hit strands
	undef %smids;          # Keep track of midpoints of hits (relative to scaf)

	# Information relative to the reference chromosome / scaffold
	undef %chrs;           # Keep track of which chrs the hits are from
	undef %chr_mins;       # Keep track of the leftmost protein locs
	undef %chr_maxs;       # Keep track of the rightmost protein locs
	undef %chr_strands;    # Keep track of protein strands
	undef %cmids;          # Keep track of midpoints of hits (relative to chr)
	
	# For this scaffold, go hit by hit
	foreach my $hit ( @{$scaf_hits{$scaf}} ){

	    # hit is an array ref with the following slots:
	    # 0:protein, 1:pct, 2:scaf, 3:scafStart, 4:scafEnd, 5:scafStrand,
	    # 6:chr, 7:chrStart, 8:chrEnd, 9:chrStrand
	    
	    my $c = $hit->[6];
	    my $sstrand = $hit->[5]; $sstrand =~s/^\+//;
	    my $sstart = $hit->[3];
	    my $send = $hit->[4];

	    my $cstart = $hit->[7];
	    my $cend = $hit->[8];
	    my $cstrand = $hit->[9];

	    push( @{$cmids{$c}}, ($cstart + $cend) / 2 );
	    push( @{$smids{$c}}, ($sstart + $send) / 2 );
	    
	    # Keeping track of all the hits on the scaffold that come from
 	    # particular reference chromosomes
	    if( exists $chrs{$c} ){
		
		$chrs{$c} += 1;
		$chr_mins{$c} = $cstart if( $cstart < $chr_mins{$c} );
		$chr_maxs{$c} = $cend if( $cend > $chr_maxs{$c} );
		$chr_strands{$c} .= $cstrand;
		$scaf_mins{$c} = $sstart if( $sstart < $scaf_mins{$c} );
		$scaf_maxs{$c} = $send if( $send > $scaf_maxs{$c} );
		$scaf_strands{$c} .= $sstrand;
		
	    } else {

		$chrs{$c} = 1;
		$chr_mins{$c} = $cstart;
		$chr_maxs{$c} = $cend;
		$chr_strands{$c} = $cstrand;
		$scaf_mins{$c} = $sstart;
		$scaf_maxs{$c} = $send;
		$scaf_strands{$c} = $sstrand;

	    }
	    
	} # END getting all hit info


	# Which chromosome has the most proteins that match the current
	# scaffold of interest? Is there evidence for misassembly?
	undef @best_chrs;
	my $most_hits = 0;
        undef %good_chrs;
	
	foreach my $chr ( keys %chrs ){
	    
	    if( $chrs{$chr} > $most_hits ){
		$most_hits = $chrs{$chr};
		undef @best_chrs; 
		push( @best_chrs, $chr );

	    } elsif( $chrs{$chr} == $most_hits ){
		push( @best_chrs, $chr );
	    } 

	    # Maybe misassembled
	    if( $chrs{$chr} >= $misassembly ){
		$good_chrs{$chr} = $chrs{$chr};
	    }
	    
	}


	# Get mapping information and test for misassemblies
	if( scalar @best_chrs > 1 ){
	    
#	    print "WARNING: Scaffold $scaf has an equal number of best hits ($most_hits) ";
#	    print "to ",scalar @best_chrs," chromosomes: ",join(",",@best_chrs),"\n";

	    # Print out information to "uncertain"
	    foreach my $bc ( @best_chrs ){
		my $info = &get_mapping_info( $scaf, $bc );
		print $O2 $info;
	    }
	    
	} else {

	    # If there's good evidence it's misassembled, print info to file	    
	    if( scalar keys %good_chrs > 1 ){

		# Just look at second best
		my $mohs = 0;
		my $sec_best;
	
#		print "$scaf has ", scalar keys %good_chrs, " good chroms\n";
		
		foreach my $gc ( keys %good_chrs ){

		    my $info = &get_mapping_info( $scaf, $gc );
		    print $O4 $info;

		    unless( $gc eq $best_chrs[0] ){
			if( $good_chrs{$gc} > $mohs ){
			    $mohs = $good_chrs{$gc};
			    $sec_best = $gc;
			}
		    }
		}

#		print "Sending $best_chrs[0] and $sec_best to compare_misassemblies\n";
		
		my $compare = &compare_misassemblies( $scaf, $best_chrs[0], $sec_best );
		print $compare->[2];
		
		
	    } else {
		
		# There is just one good hit
		my $info = &get_mapping_info( $scaf, $best_chrs[0] );

		# If there are enough hits, good to go to "mapped"
		if( $chrs{$best_chrs[0]} >= $min_hits ){
		    print $O1 $info;
		} else {
		    print $O2 $info;
		}
	    }
	}
    } #END Getting hits for those scaffolds with at least one hit   
}

close($O1);
close($O2);


print "7. FINISHED.\n";

# 1 matches
# 2 misMatches
# 3 repMatches
# 4 nCount
# 5 qNumInsert
# 6 qBaseInsert
# 7 tNumInsert
# 8 tBaseInsert
# 9 strand
# 10 qName
# 11 qSize
# 12 qStart
# 13 qEnd
# 14 tName
# 15 tSize
# 16 tStart
# 17 tEnd
# 18 blockCount
# 19 blockSizes
# 20 qStarts
# 21 tStarts


##################### SUBROUTINES #######################


sub initialize{

    GetOptions( 'scaffolds:s' => \$scafs,
		'scaffold_sizes:s' => \$sizes,
		'reference_proteins:s' => \$prots,
		'reference_gff:s' => \$gff,
		'minimum_matches:i' => \$min_hits,
		'minimum_coverage:i' => $minCov,
		'misassembly:i' => \$misassembly,
		'out:s' => \$out );

    # Check scaffolds file
    unless( $scafs && -e $scafs && $scafs =~m/.fa/ ){
	
	print "ERROR: You must provide a fasta file with draft scaffolds with --scaffolds\n";
	die &usage;
	
    } else {

	# Index fasta, if needed
	unless( -e ${scafs}.'.fai' ){
	    system("samtools faidx $scafs");
	}

	# Get all scaffolds and their sizes
	open( my $S, '<', $sizes ) || die "ERROR: $sizes doesn't exist\n";
	
	while( <$S> ){
	    chomp;
	    my @a = split( "\t", $_ );
	    
	    push( @allScafs, $a[0] );
	    $scaf_lens{$a[0]} = $a[1];
 
	}

	close($S);
    }

    print "1. Scaffolds OK...\n";
    
    # Check proteins file
    unless( $prots && -e $prots && $prots =~m/.fa/ ){
	
	print "ERROR: You must provide a fasta file reference protein sequences with --reference_proteins\n";
	die &usage;
	
    } else {

	# Keep only the first word in protein fasta header
	system( "awk '{print \$1}' $prots > a; mv a $prots; samtools faidx $prots" );

    }

    print "2. Proteins OK...\n";
    
    # Check gff file and read in
    unless( -e $gff ){
	
	print "ERROR: You must provide a GFF file containing protein location information with --reference_gff\n";
	die &usage;
	
    } else {

	# Hash ref
	my $plocs = &read_gff( $gff );

	# Dereference hash
	%protein_locs = %$plocs;
	
	# Check that GFF and protein IDs match
	open( my $IDS, "grep \">\" $prots | awk '{print \$1}' | sed 's/>//g' |" );

	my $n = 0;
	while( <$IDS> ){
	    chomp;
	    if( ! exists $protein_locs{$_} ){
#		print "WARNING: $_ doesn't exist in GFF\n";
		$n++;
	    }
	}

	print "\nWARNING: MISSING $n PROTEIN IDS IN GFF!!\n\n" if( $n > 0 );
 
    } # END Check GFF

    print "3. Finished checking GFF...\n";
    
    # Open output files
    open( $O1, '>', ${out}.'.mapped' );
    print $O1 "#scaf\tscafLen\tscafMin\tscafMax\tscafMid\tchr\tchrMin\tchrMax\tchrMedian\tstrand\tnum_proteins\n";

    open( $O2, '>', ${out}.'.uncertain' );
    print $O2 "#scaf\tscafLen\tscafMin\tscafMax\tscafMid\tchr\tchrMin\tchrMax\tchrMedian\tstrand\tnum_proteins\n";
        
    open( $O3, '>', ${out}.'.unmapped' );
    print $O3 "#scaf\tscafLen\n";

    open( $O4, '>', ${out}.'.misassembled' );
    print $O4 "#scaf\tscafLen\tscaf1min\tscaf1max\tscaf1mid\tchr1\tchr1min\tchr1max\tchr1med\tchr1strand\tscaf2min\tscaf2max\tscaf2med\tchr2\tchr2min\tchr2max\tchr2med\tchr2strand\n";

    print "4. Finished opening all outfiles. Printing to ${out}...\n";
    
}

# Get match information
sub get_mapping_info{

    # This subroutine requires:
    # scaf, chr

    my( $s, $c ) = @_;

    my $ori = &get_strand_info( $c );
    my $cmid = &median( @{$cmids{$c}} );
    my $smid = &median( @{$smids{$c}} );
    
    # Print out information
    
    my $printout = join("\t", $s, $scaf_lens{$s}, $scaf_mins{$c}, $scaf_maxs{$c}, $smid )."\t";
    $printout .= join("\t", $c, $chr_mins{$c}, $chr_maxs{$c}, $cmid )."\t";
    $printout .= join("\t", $ori, $chrs{$c} )."\n";
    
    return( $printout );
    
}

# Get strand info
sub get_strand_info{

    # Get orientation and relative location of the scaffold on the chromosome
    # set of hashes with chromosomes as keys: chrs, chr_mins, chr_maxs, chr_strands, 
    # scaf_mins, scaf_maxs, scaf_strands. Check if strands match (this will mean that
    # the scaf is in the same orientation as the chromosome). We'll use the majority
    # rule.
    
    my $a = shift;
    
    my @ss = split( '', $scaf_strands{$a} );
    my @cs = split( '', $chr_strands{$a} );
    
    my $nmatch = 0;
    my $nopp = 0;
    my $o;

    
    for( my $i = 0; $i < scalar @ss; $i++ ){
	if( $ss[$i] eq $cs[$i] ){ 
	    $nmatch++;
	} else {
	    $nopp++;
	}
    }
    
    # This is a hard cutoff, may need to modify 
    if( $nmatch / scalar @ss >= 0.8 ){
	$o = '+';
    } elsif( $nopp / scalar @ss >= 0.8 ){
	$o = '-';
    } else {
	$o = 'NA';
    }

    return( $o );

}

# Compare potential misassemblies
sub compare_misassemblies{

    # Return whether the mismatching scaffold regions overlap
    my ( $s, $c1, $c2 ) = @_;

    my $c1ori = &get_strand_info( $c1 );
    my $c2ori = &get_strand_info( $c2 );

    my $c1cmed = &median( @{$cmids{$c1}} );
    my $c2cmed = &median( @{$cmids{$c2}} );
    
    my $c1smed = &median( @{$smids{$c1}} );
    my $c2smed = &median( @{$smids{$c2}} );
    
    my $c1info = join( "\t", $s, $scaf_lens{$s}, $scaf_mins{$c1}, $scaf_maxs{$c1}, $c1smed, $c1, $chr_mins{$c1}, $chr_maxs{$c1}, $c1cmed, $c1ori );
    my $c2info = join( "\t", $s, $scaf_lens{$s}, $scaf_mins{$c2}, $scaf_maxs{$c2}, $c2smed, $c2, $chr_mins{$c2}, $chr_maxs{$c2}, $c2cmed, $c2ori );

    my $message = "Scaffold $s maps well to multiple chromosomes: ";
    $message .= $s . ":" . $scaf_mins{$c1} . "-" . $scaf_maxs{$c1} . "( median $c1smed )";
    $message .= " maps to " . $c1 . ":" . $chr_mins{$c1} . "-" . $chr_maxs{$c1} . "( median $c1cmed )";
    $message .= " with orientation $c1ori, while " . $s . ":" . $scaf_mins{$c2} . "-" . $scaf_maxs{$c2};
    $message .= " maps to " . $c2 . ":" . $chr_mins{$c2} . "-" . $chr_maxs{$c2} . "( median $c2cmed )";
    $message .= " with orientation ${c2ori}.\n";

    my @a = ( $c1info, $c2info, $message );

    return( \@a );       

}

# Parse BLAT results to get best hits
sub parse_blat{
    
    my $r = shift;
    open( my $PSL, '<', $r ) || die "ERROR: BLAT may have failed - results file $r doesn't exist\n";

    while( <$PSL> ){
	
	if( $_ =~m/^[0-9]/ ){
	    
	    chomp;
	    
	    my $line = [ split ( "\t", $_ ) ];
	    
	    # Get best hit and write parsed output to O0
	    # Must check: 1) passes filters like minId and 2) if better than previous hits
	    # (i.e. higher score).
	    unless( ! exists $protein_locs{$line->[9]} ){
		
		# Save scaffold length, percent query protein cover
		$scaf_lens{$line->[13]} = $line->[14];
		my $pct = sprintf("%.1f", 100 * ( $line->[12] - $line->[11] ) / $line->[10] );
		
		# Skip if too low coverage
		if( $pct < $minCov ){ next; }
		
		# hitInfo: score, protId, pctCover, scaf, scafStart, scafEnd, strand
		my @hitInfo = ( $line->[0], $line->[9], $pct, $line->[13],
				$line->[15], $line->[16], $line->[8]);
		
		# If we've already encountered this protein, check to see
		# if it's a better hit than what we already have.	    
		if( exists $best_hits{$line->[9]} ){
		    
		    # Compare scores. If it's a better score, replace info in best_hits. 
		    if( $line->[0] > $best_hits{$line->[9]}->[0] ){
			$best_hits{$line->[9]} = \@hitInfo;
		    }
		    
		} else {
		    # It's the first encounter of this protein hit
		    $best_hits{$line->[9]} = \@hitInfo;
		}
	    }
	}

    }

    return( \%best_hits );
	
}

# Read in information from the GFF file
sub read_gff{

    my $g = shift;
    my %results;
    
    open( my $GFF, '<', $g );

    while( <$GFF> ){
	
	next if( $_ =~/^#/ );
	
	chomp;
	my @line = split( "\t", $_ );
	
	# Process only mRNA records
	if( $line[2] eq 'mRNA' ){
	    
	    my @f9 = split( ";", $line[8] );
	    
	    # Get the protein ID associated with the mRNA
	    foreach my $name ( @f9 ){
		
		# Find the correct field
		if( $name =~m/^ID/ ){
		    
		    chomp( $name );
		    $name =~s/ID=//;
		    
		    # If we already have an mRNA entry for this protein,
		    # then check the coordinates.
		    
		    if( exists $results{$name} ){
			
			# If the mRNA coordinates are larger than the existing
			# coordinates, expand the range. So, these are pseudo
			# coordinates.
			
			if( $line[3] < $results{$name} -> [1] ){
			    $results{$name} -> [1] = $line[3];
			}
			
			if( $line[4] > $results{$name} -> [2] ){
			    $results{$name} -> [2] = $line[4];
			}
			
		    } else {
			# New entry
			my @loc = ( $line[0], $line[3], $line[4], $line[6] );
			$results{$name} = \@loc;
			
		    }
		}
	    } # END getting name
	} # END Processing an mRNA
    } # END Read GFF

    return( \%results );
}


# Get the median of a set of values
sub median{
    
    my @vals = sort {$a <=> $b} @_;
    my $len = @vals;

    if($len%2){
        return $vals[int($len/2)];
    } else {
        return ($vals[int($len/2)-1] + $vals[int($len/2)])/2;
    }
}
	    
    
sub usage{

    my $u=<<END;

usage: perl OrderScaffoldsByBlatProteins.pl --scaffolds <draft.fa> 
	                                    --scaffold_sizes <draft.chromSizes>
	                                    --reference_proteins <target_proteins.fa>
                                            --reference_gff <target.gff>
                                            --minimum_matches <min_num_hits>
	                                    --minimum_coverage <min_pct_match>
	                                    --misassembly <max_hits_other>
                                            --out <prefix> 

This script will try and order draft sequence scaffolds to a reference genome sequence assembly using the
reference genome's annotated protein sequences. This should work fairly well for Lepidopterans because 
of the high degree of microsynteny between very distantly related species. This script depends on BLAT. 
It will output five files: prefix.mapped, prefix.unmapped, prefix.parsedPsl, prefix.uncertain, and 
prefix.misassembled. These files contain, respectively: confidently mapped scaffolds, unmapped scaffolds,
the parsed BLAT results (save these, you can use them for future parsing runs), scaffolds with uncertain
locations (e.g. too few protein hits), and scaffolds that are potentially misassembled because they have 
many hits to multiple reference chromosomes / scaffolds. 

scaffolds          Fasta file containing draft scaffold sequences to order.

scaffold_sizes     A 2-column tab-delimited file containin scaffold name and length. You can generate this
                   file using UCSCtools faToTwoBit draft.fa draft.2bit; twoBitInfo draft.2bit draft.chromSizes

reference_proteins Fasta file containing all protein sequences from the reference genome. Ideally you should
                   only supply one isoform for each protein (e.g. the longest). I did not build that in to
                   this script because it varies a lot as to how genes and isoforms are labeled. So, this
                   script will use all supplied protein sequences.

reference_gff      GFF file from the reference genome (required for protein location information). I have
	           not extensively tested this on GFFs, and they can vary a lot, so double-check all the 
                   info is correct. This should work with properly-formatted GFF3 files. This script 
                   assumes that the protein ID in the fasta and the GFF "ID" tag match.

minimum_matches    Minimum number of (best) protein matches on a draft scaffold required to confidently
                   order that scaffold relative to the reference genome. 

minimum_coverage   Only include hits with minimum_coverage percent of the protein matching the target
                   scaffold. Default: 10. 

misassembly        Scaffolds with >= this number of best hits to a second chromosome will be flagged as
                   potentially misassembled.

out                Prefix for output files. Default: reordering. 

END

    print $u;

}
