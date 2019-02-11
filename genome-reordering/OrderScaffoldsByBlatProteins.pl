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
my %protein_locs;
my %best_hits;
my %scaf_hits;
my %scaf_lens;
my @allScafs;

my $O0;
my $O1;
my $O2;
my $O3;

print "\n\n0. INITIALIZING...\n\n";

&initialize;

# BLAT

print "5. BEGINNING TO BLAT\n\n";

my $results = ${prots}.'_to_'.${scafs}.'.psl';

my $skip = 'n';

# Don't re-run BLAT if you don't have to!
if( -e $results ){
    print "Results file already exists. Rerun (r) or continue to parsing (p)?\n\n";
    my $answer = <STDIN>;

    chomp($answer);
    
    if( $answer eq "p" ){
	$skip = 'y';
    } else {
	$skip = 'n';
    }
}

if( $skip eq 'n' ){   
    system( "blat -q=prot -t=dnax -dots=10 $scafs $prots $results" );
} else {
    print "\nSkipping BLATing\n";
}
    
# Parse BLAT results. Keep only top hit for each protein.
print "6. Finished BLATing, beginning to parse...\n";

open( my $PSL, '<', $results ) || die "ERROR: BLAT may have failed - results file $results doesn't exist\n";

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

# Print out parsed best hit results and save for later
# Each value in best_hits is an array ref with:
# score, proteinId, pctCover, scaf, scafStart, scafEnd, strand
# remember that protein_locs contains chrom, start, end, strand
foreach my $bh ( keys %best_hits ){

    my @info = ( @{$best_hits{$bh}}, @{$protein_locs{$bh}} );    
    shift @info;

#   print "info contains ",join(",",@info),"\n";
    
    print $O0 join( "\t", @info),"\n";
    push( @{$scaf_hits{$info[2]}}, \@info );

}

close($O0);

# Get best locations for each scaffold to each chromosome.
# scaf_hits is a hash of array references. Each ref contains 
# information on a best protein blat hit: 
# 0 - protein, 1 - scafStart, 2 - scafEnd, 3 - scafStrand, 4 - chr, 5 - chrStart, 6 - chrEnd, 7 - chrStrand
    
# What is the "best match" for a scaffold? Must pass minimum number of protein hits, plus
# Could have: 
#  1) equal num to more than one chr (put into low-confidence bin, with list)
#  2) no matches (put into unmapped bin)

# Process each scaffold from draft sequence

foreach my $scaf ( @allScafs ){

    if( ! exists $scaf_hits{$scaf} ){
	
	# No hits
	print $O3 $scaf,"\t",$scaf_lens{$scaf},"\n";

    } else {
	
	# At least one best hit...
	my %scaf_mins;
	my %scaf_maxs;
	my %scaf_strands;
	my %smids;
	
	my %chrs;
	my %chr_mins;
	my %chr_maxs;
	my %chr_strands;

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

	    push( @{$smids{$c}}, ($cend + $cstart) / 2 );
	    
	    
	    
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

	# Get the best matches, check if enough hits, get orientations
	my $best_chr;
	my $most_hits = 0;

	# Which chromosome has the most proteins that match the scaffold of interest?
	foreach my $chr ( keys %chrs ){
	    $most_hits = $chrs{$chr} if( $chrs{$chr} > $most_hits )
	}

	foreach my $chr ( keys %chrs ){
	    if( $chrs{$chr} == $most_hits ){
		if( $best_chr ){
		    print "WARNING: Scaffold $scaf has an equal number of best hits ($most_hits) ";
		    print "to at least two chromosomes, $best_chr and $chr\n";
		} else {
		    $best_chr = $chr;
		}
	    }
	}

	# Get orientation and relative location of the scaffold on the chromosome
	# set of hashes with chromosomes as keys: chrs, chr_mins, chr_maxs, chr_strands, 
	# scaf_mins, scaf_maxs, scaf_strands. Check if strands match (this will mean that
	# the scaf is in the same orientation as the chromosome). We'll use the majority
	# rule.
	
	my $ori;
	my @ss = split( '', $scaf_strands{$best_chr} );
	my @cs = split( '', $chr_strands{$best_chr} );

	my $nmatch = 0;
	my $nopp = 0;
	
	for( my $i = 0; $i < scalar @ss; $i++ ){
	    if( $ss[$i] eq $cs[$i] ){ 
		$nmatch++;
	    } else {
		$nopp++;
	    }
	}

	if( $nmatch / scalar @ss >= 0.8 ){
	    $ori = '+';
	} elsif( $nopp / scalar @ss >= 0.8 ){
	    $ori = '-';
	} else {
	    $ori = 'NA';
	    print "Conflicting strand information, potential inversion between $scaf and $best_chr:\n";
	    print "Scaff strands: ",$scaf_strands{$best_chr},"\n";
	    print "Chrom strands: ",$chr_strands{$best_chr},"\n";
	    
	}

	# Get midpoint of all hits
	my $sum = 0;
	foreach( @{$smids{$best_chr}} ){
	    $sum += $_;
	}

	my $median_pos = &median( @{$smids{$best_chr}} );
	
	# Print out information

	my $printout = join("\t", $scaf, $scaf_lens{$scaf}, $scaf_mins{$best_chr}, $scaf_maxs{$best_chr} )."\t";
	$printout .= join("\t", $best_chr, $chr_mins{$best_chr}, $chr_maxs{$best_chr})."\t";
	$printout .= join("\t", $ori, $chrs{$best_chr},$median_pos)."\n";
	
	if( $chrs{$best_chr} > $min_hits ){
	    print $O1 $printout;
	} else {
	    print $O2 $printout;
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
		'out:s' => \$out );

    # Check scaffolds file
    unless( $scafs && -e $scafs && $scafs =~m/.fa/ ){
	print "ERROR: You must provide a fasta file with draft scaffolds with --scaffolds\n";
	die &usage;
    } else {
	unless( -e ${scafs}.'.fai' ){
	    system("samtools faidx $scafs");
	}

	# Get all scaffolds in draft
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

	system( "awk '{print \$1}' $prots > a; mv a $prots; samtools faidx $prots" );

    }

    print "2. Proteins OK...\n";
    
    # Check gff file and read in
    unless( -e $gff ){
	print "ERROR: You must provide a GFF file containing protein location information with --reference_gff\n";
	die &usage;
    } else {
	open( my $GFF, '<', $gff );

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
			
			if( exists $protein_locs{$name} ){

			    # If the mRNA coordinates are larger than the existing
			    # coordinates, expand the range. So, these are pseudo
			    # coordinates.

			    if( $line[3] < $protein_locs{$name} -> [1] ){
				$protein_locs{$name} -> [1] = $line[3];
			    }

			    if( $line[4] > $protein_locs{$name} -> [2] ){
				$protein_locs{$name} -> [2] = $line[4];
			    }

			} else {
			    # New entry
			    my @loc = ( $line[0], $line[3], $line[4], $line[6] );
			    $protein_locs{$name} = \@loc;
			    
			}
		    }
		} # END getting name
	    } # END Processing an mRNA
	} # END Read GFF

	# Check that GFF and protein IDs match

	open( my $IDS, "grep \">\" $prots | awk '{print \$1}' | sed 's/>//g' |" );

	my $n = 0;
	
	while( <$IDS> ){
	    chomp;
	    if( ! exists $protein_locs{$_} ){
		print "WARNING: $_ doesn't exist in GFF\n";
		$n++;
	    }
	}

	
	print "\nWARNING: MISSING $n PROTEIN IDS IN GFF!!\n\n" if( $n > 0 );

 
    } # END Check GFF

    print "3. Finished checking GFF...\n";
    
    # Open output files
    open( $O0, '>', ${out}.'.parsedPsl' );
    print $O0 "#prot\tpctLen\tscaf\tscafStart\tscafEnd\tscafStrand\tchr\tchrStart\tchrEnd\tchrStrand\n";
        
    open( $O1, '>', ${out}.'.mapped' );
    print $O1 "#scaf\tscafLen\tscafMin\tscafMax\tchr\tchrMin\tchrMax\tstrand\tnum_proteins\tmedian_pos\n";

    open( $O2, '>', ${out}.'.uncertain' );
    print $O2 "#scaf\tscafLen\tscafMin\tscafMax\tchr\tchrMin\tchrMax\tstrand\tnum_proteins\tmedian_pos\n";
        
    open( $O3, '>', ${out}.'.unmapped' );
    print $O3 "#scaf\tscafLen\n";

    print "4. Finished opening all outfiles. Printing to ${out}...\n";
    
}


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
	                                    --maximum_distance <max_pct_distance>
                                            --out <outfile.mapping> 

This script will try and order draft sequence scaffolds to a reference genome sequence assembly using the
reference genome's annotated protein sequences. This should work fairly well for Lepidopterans because 
of the high degree of microsynteny between very distantly related species. This script depends on BLAT. 
It will output three files, one containing high-confidence mapping locations, one with low-confidence
mapping locations, and one with unmapped scaffolds. 

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

maximum_distance   The maximum difference in distance between successive protein hits on the scaffolds and
		   their distance apart on the reference chromosome. This is meant to help more accurately
		   describe the chromosome region that each scaffold spans. This is a percentage of the 
                   distance between the two proteins on the reference scaffold. i.e. if maximum_distance is
                   set to 50 and the distance between two proteins on the reference chromosome is 10 kb, 
		   then the script will include the two proteins if they map <= 15 kb apart on the 
		   draft scaffold.

out                Prefix for output files. Default: reordering. 

END

    print $u;

}
