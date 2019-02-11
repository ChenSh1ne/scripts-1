#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

my $vcf = '';     # VCF with SNP calls. Ensure bgzipped and tabix indexed.
my $out = '';     # Output filename
my $win = 0;      # Size of windows to calculate statistics in.
my $step = 0;     # Step size between starts of consecutive windows.
my $chr = '';     # Chromosome of region to analyze. Make sure matches VCF.
my $start = 0;    # Start coordinate of region to analyze
my $end = 0;      # End coordinate of region to analyze
my $samples;      # Sample filename
my $cutoff = 2;   # Coverage cutoff to use for calculations
my %all_samples;  # All samples in VCF. key = sample ID, value = field number in VCF
my %samples;      # Samples for analysis. key = field number in VCF, value = sample ID
my $coords;       # Coordinates for extraction
my $win_num = 1;  # Keep track for output file

&parseInOut;

# Iterate over all windows

while( ($start + $win) < $end ){


    # Get the coverage and major allele counts, plus the number
    # of sites with reduced coverage and the denominator for pi,
    # which is simply the total number of sites included in calcs
    
    my ($nsRC,$pi_denom,%siteClasses) = &getSiteClasses($chr,$start,($start+$win));

    # Use %siteClasses to calculate stats

    my($S,$pi_num,$TajD) = &calcStats(\%siteClasses);
    
    # print output

    # Watterson's theta for the whole window, all classes
    
    my $denom = 0;

    for( my $i = 1; $i < scalar(keys(%samples)); $i++){
	$denom += 1/$i;
    }

    # Print out all information. NEED TO ADD DIV.
    print O $win_num,"\t",$coords,"\t",$pi_denom,"\t";
    print O $nsRC/$pi_denom,"\t",$S,"\t";
    print O $pi_num/$pi_denom;
    print O "\t",$S/$denom,"\t",$TajD,"\n";
    
    $start = $start + $step;
    $win_num++;
}


############################## SUBROUTINES ##########################################

    
sub getSiteClasses{ 

    my($c,$s,$e) = @_;

    $coords = $c.":".$s."-".$e;

    my $region = `tabix $vcf "$coords"`;
    my @sites = split( "\n", $region );

    print "There are ",scalar @sites," sites in $coords\n";
    
    ## calculate coverage and major allele frequency for each site    
    # key is the number of samples the SNP is called in (coverage), 
    # value is array of the numbers of major alleles. nsRC is the number
    # of sites with coverage < num samples (i.e. reduced coverage)
    
    my %SC;
    my $nsRC = 0;

    # To make pi a "per-site" estimate, need # sites used in calculation
    # Exclude any filtered SNP sites and those with with coverage < 2
    
    my $piDenom = $win;

    foreach(@sites){
	my @snp = split("\t",$_);
#	if( $snp[6] eq 'PASS' ){
	    
	    # Keep track of the bases at that site and their frequency
	my %bases;
	my $gtstring;
	    # For each sample that we want to analyze
	foreach my $field (keys(%samples)){
	    my @gt = split(/:/,$snp[$field]);
	    $gtstring .= $gt[0];
	}

        for( my $a = 0; $a <= 3; $a++ ){
	    $bases{$a} = ( eval "\$gtstring =~tr/$a//" );
	    if( $bases{$a} == 0 ){ delete $bases{$a} }
	}

	print "There are ", scalar keys %bases," bases at site: ", join(',',keys %bases),"\n";
	# If it's a biallelic site, calc coverage and major allele count (MAC)
	if( scalar keys %bases == 2){
		        
	    my $coverage = 0;
	    my $MAC = 0;
	    
	    foreach my $base (keys(%bases)){
		
		$coverage += $bases{$base};

		if ($bases{$base} > $MAC){
		    $MAC = $bases{$base};
		}

	    }
	    
	    print "Coverage: ",$coverage,", MAC: ",$MAC,"\n";
	    
	    # %siteClasses is a hash of arrays; 
	    # key is coverage, values are frequencies
	    unless($coverage <= $cutoff){
		push (@{$SC{$coverage}}, $MAC);
		if($coverage < scalar(keys(%samples))){
		    $nsRC++;
		}
	    } else {
		# Coverage too low, so exclude site
		$piDenom--;
	    }
	    
	} elsif( scalar(keys(%bases)) > 2 ) {
	    print "Multiallelic site\n";
	    $piDenom--;
	} else {
	    #		print "There are ",scalar(keys(%bases))," bases at this site\n";
	}
	#	} else {
	#	    $piDenom--;
	#	}
    }
    
    return($nsRC,$piDenom,%SC);
}



## Calculate S, pi, thetaW, and Tajima's D statistics
    
sub calcStats{    

    # Copy %siteClasses from ref
    my $k = shift; my %SC = %{$k};

    my $num_site_classes = 0;  
    my $sumTD = 0; 	        
    my $segSites = 0;
    my $pi_numerator = 0;
    
    # For each site class (i.e. for c = 2 to # samples), calculate pi and
    # S. These will be put together at the end for this window's stats.
    
    foreach my $class (keys(%SC)){

	# If there are at least 3 segSites in the frequency class
	if(scalar(@{$SC{$class}}) > 2 ){

	    $segSites += scalar(@{$SC{$class}});

	    print "Num segSites in class ",$class,": ",scalar(@{$SC{$class}}),"\n";
	    # Include the coverage class in calculations
	    $num_site_classes++;
       
	    my ($tp,$td) = &calcTD($class,\@{$SC{$class}});
	    
	    $pi_numerator += $tp;
	    $sumTD += $td;
	}
    }

    my $norTD = 0;
    if ($num_site_classes > 0){
	$norTD = $sumTD/$num_site_classes;
    }    

    print "sumTD: ",$sumTD,", num_site_classes: ",$num_site_classes,", Normalized TD: ",$norTD,"\n";
    
    return($segSites,$pi_numerator,$norTD);


}


sub calcTD{

    my ($class,$k) = @_; my @MACs = @{$k};
    
    my $tempPi = 0;
    my $tempS = 0;
    
    # For each major allele count, get contribution to pi and S
	
    foreach my $MAC ( @MACs ){
        $tempPi += 2 * ($MAC/$class) * (1 - ($MAC/$class)); 
	# $tempPi += ($class/($class-1))*(1-(($MAC/$class)**2)+((1-$MAC/$class)**2));
	$tempS++;
    }

#    print "tempS calculation for class ",$class,": ",$tempS,"\n";
    ## thetaW
    # denominator of Watterson's estimator of theta for this site class
    # Remember that the site class is the effective number of samples
    # Calculate the denominator of Tajima's D statistic... see paper. 
    # Mostly algebra.
    
    my ($a1, $a2) = (0, 0);
    for (my $i = 1; $i < $class; $i++){
	$a1 += 1/$i;
	$a2 += 1/($i*$i);
    }
    my $b1 = ($class+1) / (3*($class-1));
    my $b2 = 2*($class**2 + $class + 3) / (9*$class*($class-1));
    my $c1 = $b1 - 1/$a1;
    my $c2 = $b2 - ($class + 2)/($a1*$class) + $a2/($a1**2);
    my $C = sqrt(($c1/$a1)*$tempS + ($c2/($a1**2+$a2))*$tempS*($tempS-1));
    
    # Actually calculate Tajima's D, as long as there are at least 3 seg
    # sites in the class
    
    my $TD = 0; 
    if($tempS > 2){
	$TD = ($tempPi - $tempS/$a1) / $C;
    }
    
    
    print "tempPi: ",$tempPi,", tempS/a1: ",$tempS/$a1,", C:",$C,", TD:",$TD,", tempS: ",$tempS,", class: ",$class,"\n";
    
    return($tempPi,$TD);

}

sub parseInOut{

    GetOptions('vcf:s'     => \$vcf,
	       'out:s'     => \$out,
	       'win:i'     => \$win,
	       'step:i'    => \$step,
	       'chr:s'     => \$chr,
	       'start:i'   => \$start,
	       'end:i'     => \$end,
	       'samples:s' => \$samples,
	       'cutoff:i'  => \$cutoff);

    unless($vcf){
	print "\n\nMust provide a tabix-indexed SNP VCF file with --vcf.\n";
	die &usage;
    } else {
	
	my $h = `tabix -H $vcf | tail -n 1`;

	if( length $h == 0 ){
	    print "Cannot use tabix on your VCF $vcf.\n";
	    die &usage;
	}
	
	chomp( $h );
	
	# Get all the sample names in the VCF file
	my @l = split( "\t", $h );
	for(my $i = 9; $i < scalar(@l); $i++){
	    $all_samples{$l[$i]} = $i;
	}
	
    }

    unless( $chr  ){
	print "\n\nYou must provide at least a chromosome to analyze with --chr\n";
	die &usage;
    } else {

	# Get the whole chromosome
	if( $end == 0 ){
	    my $fg = $chr . ",length";
	    my $c = `tabix -H $vcf | grep "$fg"`;

	    ##contig=<ID=scaffold8429,length=747>
	    $c =~s/.*length=([0-9]*)>/$1/;
	    $end = $c;
	}
		
	$coords = $chr.":".$start."-".$end;
    }

    unless($win > 0){
	print "\n\nYou must provide a window size with --win.\n";
	die &usage;
    }

    unless($step > 0){
	print "\n\nYou must provide a step size with --step.\n";
	die &usage;
    }
    
    if( $samples ){
	
	open( my $S, '<', $samples ) || die "\nCan't open the samples file!\n";

	while(<$S>){
	    chomp;
	    if( exists($all_samples{$_}) ){
		
		# %samples is key = field number and value is sample name
		$samples{$all_samples{$_}} = $_;
	    } else {
		print "\nWARNING: Sample ",$_," doesn't exist in VCF file! Omitting.\n";
	    }
	}

	close($S);
    } else {

	$samples = 'all';
	# All samples will be included
	foreach( keys %all_samples ){
	    $samples{$all_samples{$_}} = $_;
	}

	print "Using all ",scalar keys %samples," samples\n";
    }

    
    unless($out){
	print "\n\nPrinting output to pi_output.txt.\n";
	open(O,">pi_output.txt") || die "\n\nCan't open output file pi_output.txt\n";
	$out = 'pi_output.txt';
    } else {
	print "\n\nPrinting output to ",$out,"\n";
	open(O, ">$out") || die "\n\nCan't open outfile ",$out,"\n";
    }

    print O "# CalculatePopGenStatistics.pl --vcf ",$vcf," --out ",$out," --win ",$win,"\n";
    print O "# --step ",$step," --chr ",$chr," --start ",$start," --end ",$end,"\n";
    print O "# --samples ",$samples," --cutoff ",$cutoff,"\n";
    print O "# Executed ",scalar(localtime),"\n";
    print O "#window\tcoords\tS\tpi\tthetaW\tTajD\n";

}

sub usage{

    my $u=<<END;

  usage: ./CalculatePopGenStats.pl --vcf <vcf> --out <outfile> --win <win size> 
                                   --step <step size> --chr <chr> --start <start coord>
                                   --end <end coord> --samples <samples.txt> --cutoff <i>
 
       
  vcf       A bgzipped, tabix-indexed VCF file containing HAPLOID SNP calls. This
            script was really designed to work with SNP calls from the DPGP2 
            genomes, but could easily be modified to take diploid calls. This script
            thus depends on tabix for fast extraction of SNPs in the desired genomic 
            region. The VCF file file.vcf.gz must be tabix-indexed, and the file
            file.vcf.gz.tbi must be in the same directory as file.vcf.gz.

  out       Name of the output file. (default: pi_output.txt)

  win       The size of windows to calculate S, pi, thetaW, Tajima's D, and 
            divergence in. 

  step      The step size between consecutive windows. Ex: Window size = 10000 bp, 
            step = 50 bp. Window 1: 0-10000 bp, window 2: 50-10050 bp, window 3:
            100-10100 bp...

  chr       Chromosome to calculate statistics in.

  start     Start coordinate of the region on chr that you want to calculate stats.

  end       End coordinate of the region on chr that you want to caluclate stats.

  samples   A file containing a list of samples that you'd like to use in the 
            calculations, one per line. Ensure that the sample names are exactly as 
            they're found in the VCF file header. 

  cutoff    The coverage cutoff to use in calculations. That is, SNP sites that are
            called in fewer than <cutoff> samples will be ignored. Default: 2.

  This script will calculate nucleotide diversity per site (pi), the number of 
  segregating sites (S), Watterson's theta (thetaW), and Tajima's D in sliding 
  windows for a given region using equations from Langley et al. (2012) Genetics
  and Begun et al. (2007) PLoS Biology. These equations take into account the 
  fact that some sites are not called in all samples. 

END

print $u;

}


