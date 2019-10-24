#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $vcf;
my $reg;
my $out = 'AlternateFastas.fa';
my $sam = 'all';
my $choose = 'alt';
my $format = 'fasta';
my $all = 0;
my $reference;
my $rel_pos = 0;

my @sam_ind;
my @sam_names;
my @VCF;
my $O;
my $R;
my %seqs;
my $start_pos;
my $end_pos;
my $chr; 
my $very_first = 0;
my $very_last = 0;
my $rp = 0;

# Run the &intialize subroutine to parse input
# Fills the arrays @VCF and @sam_ind and opens the outfile filehandle $O

&initialize;

$very_first = $start_pos;

# Line by line, process
foreach my $line ( @VCF ){

    print $line;
    #Example:
    #0     1     2         3   4   5    6      7                       8           9              10    
    #CHROM POS   ID        REF ALT QUAL FILTER INFO                    FORMAT      NA00001        NA00002
    #20    14370 rs6054257 G   A   29   PASS   NS=3;DP=14;AF=0.5;DB;H2 GT:GQ:DP:HQ 0|0:48:1:51,51 1|0:48:8:51,51 
    
    chomp $line;
    my @var = split("\t",$line);

    my $ref = $var[3];
    my $alt = $var[4];

    my $na = 0;
    my $nr = 0;

    # For now, only include biallelic SNP sites
    unless( length $alt > 1 || length $ref > 1 || $var[6] ne 'PASS' ){
	
	# Make sure it's not invariant in your sample set
	if( $sam ne 'all' ){
	    $nr = 0;
	    $na = 0;
	    
	    for( my $sample = 0; $sample < scalar @sam_ind; $sample++ ){
		if( $var[$sam_ind[$sample]] =~/^0\/0:/ ||
		    $var[$sam_ind[$sample]] =~/^0\|0:/ ){
		    $nr+=2;
		} elsif( $var[$sam_ind[$sample]] =~/^1\/1:/ ||
		         $var[$sam_ind[$sample]] =~/^1\|1:/ ){
		    $na+=2;
		} elsif( $var[$sam_ind[$sample]] =~/^0\/1:/ || 
			 $var[$sam_ind[$sample]] =~/^1\/0:/ ||
			 $var[$sam_ind[$sample]] =~/^0\|1:/ ||
			 $var[$sam_ind[$sample]] =~/^1\|0:/ ){
		    $nr++;
		    $na++;
		}
	    }

	    if( $nr/2 == scalar @sam_ind ){
#		print "Not including site because nr is $nr while na is $na and sam_ind is ",scalar @sam_ind,"\n";
		print $R $chr,"\t",$var[1],"\t",$var[2],"\t",$var[1]-$very_first,"\t",$ref,"\t",$alt,"\t0\n";
		next;
	    } elsif( $nr == 0 && $na == 0 ){
		print "Strange, na is $na and nr is $nr at site $var[1]\n";
		print $R $chr,"\t",$var[1],"\t",$var[2],"\t",$var[1]-$very_first,"\t",$ref,"\t",$alt,"\tNA\n";
		next;
	    }
	}
	
	# If you're getting all sequence ebtween variant sites, get the interspersed invariant sequence
	my $add;
	if( $all == 1 ){
	    my $cse = $chr.':'.$start_pos.'-'.($var[1] - 1);
	    $add = `samtools faidx $reference $cse`;
	    $add =~s/^>.*\n//;
	    $add =~s/\n//g;
	}

	#For each sample you want to include
	for( my $sample = 0; $sample < scalar @sam_ind; $sample++ ){

	    my $base = 'N';
	    
	    if( $var[$sam_ind[$sample]] =~/^0\/0/ || $var[$sam_ind[$sample]] =~/^0|0:/ ){
		$base = $ref;
	    } elsif( $var[$sam_ind[$sample]] =~/1\/1:/ || $var[$sam_ind[$sample]] =~/^1|1:/ ){
		$base = $alt;
	    } elsif( $var[$sam_ind[$sample]] =~/0\/1:/ || $var[$sam_ind[$sample]] =~/^0|1:/ || $var[$sam_ind[$sample]] =~/^1|0:/ ){
		if( $choose eq 'alt' ){
		    $base = $alt;
		} elsif( $choose eq 'ref' ){
		    $base = $ref;
		} elsif( $choose eq 'hf' ){
		    if( $na/($na+$nr) > $nr/($na+$nr) ){
			$base = $alt;
		    } elsif( $na/($na+$nr) < $nr/($na+$nr) ){
			$base = $ref;
		    } else {
			my @a = ($ref,$alt);
			$base = rand @a;
		    }
		} elsif( $choose eq 'N' ){
		    $base = 'N';
		} else {
		    my @a = ($ref,$alt);
		    $base = rand @a;
		}
	    }
	    
	    $seqs{$sam_names[$sample]} .= $add;
	    $seqs{$sam_names[$sample]} .= $base;

	}

	$start_pos = $var[1]+1;
	$very_last = $var[1]+1;
	$rp += length($add) + 1; # added bases plus variant base

	print $R $chr,"\t",$var[1],"\t",$var[2],"\t",$rp-1,"\t",$ref,"\t",$alt,"\t",sprintf('%03f',$na/($na+$nr)),"\n";
    }
}

# The last bit
if( $all == 1 ){
    my $cse = $chr.':'.$very_last.'-'.$end_pos;
    my $add = `samtools faidx $reference $cse`;
    $add =~s/^>.*\n//;
    $add =~s/\n//g;

    foreach my $s ( keys %seqs ){

	$seqs{$s} .= $add;
    }

}
# Write output file	
if( $format ne 'fasta' ){  
    print "Printing fasta format because I haven't written the PHYLIP part yet...\n";
}


foreach my $sample ( sort keys %seqs ){
	
    # Wrap lines every 80 characters
    my $SEQ = $seqs{$sample};
    $SEQ =~s/(.{0,80})/$1\n/g;
    chomp $SEQ;    
    print $O ">",$sample,"\n",$SEQ;
}

close($O);
    



############################################################################
# SUBROUTINES ##############################################################
############################################################################

sub initialize{

    GetOptions('vcf:s' => \$vcf,
	       'region:s' => \$reg,
	       'out:s' =>\$out,
	       'samples:s' => \$sam,
	       'pick_alleles:s' => \$choose,
	       'format:s' => \$format,
	       'all_sites:i' => \$all,
	       'reference:s' => \$reference,
	       'relative_pos:i' => \$rel_pos
	);

    unless( $vcf && $reg ){
	print "\n\nERROR: You must specify all arguments\n";
	die &usage;
    }

    if( $all == 1 && ! -f $reference ){
	print "\n\nERROR: You must provide a reference fasta file if you want all sites\n";
	die &usage;
    }
    # Test to make sure all input arguments are good and, if so, get variants
    # VCF must be bgzipped and indexed with tabix
    unless( -f "${vcf}.tbi" ){
	
	print "\n\nERROR: Your VCF must be bgzipped and tabix-indexed\n";
	die &usage;

    } else {

	print "VCF OK\n";
	# Region must be properly formatted
	unless( $reg =~m/\w:\d+-\d+/ || $reg =~m/\w/ ){

	    print "\n\nERROR: Your region must be specified as chromosome or chromosome:start-end\n";
	    die &usage;

	} else {
	    print "region OK\n";
	    # pick_alleles must be properly set
	    unless( $choose eq 'alt' || $choose eq 'ref' || $choose eq 'random' || $choose eq 'hf' || $choose eq 'N' ){
		print "\n\nERROR: Your method of choice must be alt, ref, random, N, or hf\n";
		die &usage;

	    } else {

		# How many variants are in this region? Maybe too many for your computer's memory!
		# backticks (``) call to the system and store the output into the variable
		my $n = `tabix $vcf $reg | wc -l | cut -f 1 -d " "`;
		chomp $n; 

		if( $n > 2000000 ){
		    # If there are a lot, check and see if you want to continue
		    print "\nWARNING: There are more than 2 million variants in this region ($n)\n";
		    print "Are you sure you have enough memory for this? yes/no\n\n";
		    my $a = <STDIN>; chomp $a;
		    if( $a eq 'no' ){
			die;
		    }
		}
		
		# If we're not dead, continue

		print "Small enough dataset ($n), continuing\n";

		# Which samples to include? Put into a hash - easy to randomly access
		my %sam_inc;

		if( $sam ne 'all' ){
    
		    open(my $S,'<',$sam) || die "\n\nERROR: Cannot open your sample file $sam...\n";
		    
		    while(<$S>){
			chomp;
			$sam_inc{$_} = 1;
		    }
		} 

		# Get the sample header line
		my $s = `tabix -H $vcf | grep CHROM`;
		
		# Remove trailing whitespace and newlines
		chomp $s;
		
		# Split the line into an array, by tab. So, $s[0] is #CHROM, $s[1] is POSITION, etc...
		my @s = split("\t",$s);

		# To keep track of samples included
		my %kept;

		# Find out where the desired samples are
		for( my $i = 9; $i < scalar(@s); $i++ ){
		    # If we want only a subsample, then find the indexes
		    if( $sam ne 'all' && exists $sam_inc{$s[$i]} ){
			push(@sam_ind,$i);
			push(@sam_names,$s[$i]);
			$kept{$s[$i]} = 1;
		    } elsif( $sam eq 'all' ) {
			# We want them all
			push(@sam_ind,$i);
			push(@sam_names,$s[$i]);
			$kept{$s[$i]} = 1;
		    }
		}

		if( $sam ne 'all' ){
		    foreach my $k ( sort keys %sam_inc ) {
			# Sample list names don't match samples in VCF
			unless( exists $kept{$k} ){
			    print "WARNING: Sample ",$sam_inc{$k},"  doesn't exist in your VCF!!\n";
			}
		    }
		}

		# Compare how many you wanted and how many are included
		if( $sam ne 'all' ){
		    print "Including ",scalar keys %kept," samples of the ",scalar keys %sam_inc," samples requested\n";
		} else {
		    print "Including ",scalar keys %kept," samples\n";
		}
		
		# Get all variants in this region
		my $v = `tabix $vcf $reg`;
		# Split the lines into an array @v. Each element is a single, tab-delimited VCF line
		@VCF = split("\n",$v);
	    }
	}
    }


    open( $O,'>',$out ) || die "ERROR: Cannot open outfile $out for some reason...\n";

# If you want relative positions file
    if( $rel_pos == 1 ){
	open($R,'>',${out}.'.relPos') || die "Cannot open relative positions file\n";
	print $R "#chr\tabs_pos\tsnp_id\trel_pos\tref\talt\tfreq(alt)\n";
    }

    # If you want to output the whole sequence, not just variant sites, need to get the
    # absolute start and end coordinates

    print "Using region $reg\n";
    if( $all == 1 ){
	if( $reg =~/^[^:]*$/ ){
	    print 
		$start_pos = 1;
	    $chr = $reg;
	    my $l = `samtools faidx $reference $reg`;
	    $l =~s/$>\w+\n//;
	    $l =~s/\n//g;
	    $end_pos = length $l;
	} elsif( $reg =~/^.*:[0-9]*?-[0-9]*$/ ){
	    my $s2 = $reg;
	    $s2 =~s/^(.*):([0-9]*)?-([0-9]*)$/$1\t$2\t$3/;
	    my @arr = split("\t",$s2); 
	    $chr = $arr[0]; $start_pos = $arr[1]; $end_pos = $arr[2]; 
	} else {
	    print "Not recognizing the regex\n";
	}
    }

    print "\n\nSuccessfully initialized. Printing output to ${out}.\n";
    print "Beginning to process ",scalar @VCF," variants\n\n";


}

sub usage{

    my $u=<<END;

  usage: perl MakeAltFastasFromVcf.pl -vcf <vcf.gz> -region <chr:start-end> -out <out.fa> 
      -samples <sam.list> -pick_alleles <random | alt | ref | hf | N> -format <phylip | fasta>
      -all_sites <0|1> -reference <ref.fasta -relative_pos <0|1>>

  This script will output a pseudo FASTA format file containing only variant sites.  

  vcf          A bgzipped, tabix-indexed VCF file containing your variant sites
  region       The region you would like to make a FASTA file for. This can be either
               chr:start-end, or just chr
  out          Output filename. Default: AlternateFastas.fa
  samples      A list of samples to include in the FASTA. These names must match the
               VCF header exactly. Only sites that are variable in this subset of samples
               will be included in the output. If no sample file is provided, then all
	       samples will be included.
  pick_alleles How to choose which allele to include at heterozygous sites. hf: highest 
               frequency allele in your sample set; N: set to N. Default: hf
  format       Output file format. Default:  fasta
  all_sites    Output all sequence sites (1), rather than just variant sites (0)? 
               Default:0.
  reference    If all_sites is set to 1, you must supply the reference genome fasta 
               sequence and it must be indexed with samtools faidx.
  relative_pos Output a file (out.relPos) containing variant site positions relative to
               the sequence start? Default: 0.  


END

print $u;
 
} 
