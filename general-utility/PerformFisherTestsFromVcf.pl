#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Text::NSP::Measures::2D::Fisher2::twotailed;

my $vcf;
my @variants;
my $region;
my $g1;
my @g1s;
my $g2;
my @g2s;
my $minA;
my $out;
my $O;
my %as;
my %seen;
my $add = 0;

&parseInOut;

foreach my $v (@variants){

    chomp $v;
    my @v = split("\t",$v);
    # Hmel210004 759765 INV00000066 T <INV> . PASS PRECISE;SVTYPE=INV;SVMETHOD=EMBL.DELLYv0.7.6;CHR2=Hmel210004;END=772988;PE=4;MAPQ=54;CT=5to5;CIPOS=-2,2;CIEND=-2,2;INSLEN=0;HOMLEN=2;SR=5;SRQ=0.965517;CONSENSUS=GGCCTCGACTTCGCGAGGTCATAAAAAGATGAACCTTACCTTGTATTTATGTCTCGTGAAATGTCCAGATAATTTTTTTCCTTCCAC;CE=1.95609 GT:GL:GQ:FT:RCL:RC:RCR:CN:DR:DV:RR:RV 0/0:0,-2.7079,-31.6986:27:PASS:988:2140:918:2:0:0:9:0

    # Remember that @g1s and @g2s contain the indices of the samples

    my $coords;
    my @c1 = split(";",$v[7]);
    my $end = $c1[4];
    $end =~s/END=//;

    unless( $v[2] =~/^TRA/ ){
	$coords = $v[0].":".$v[1]."-".$end;
    } else {
	my $c2 = $c1[3];
	$c2 =~s/CHR2=//;
	$coords = $v[0].":".$v[1].";".$c2.":".$end;
    }

    my $g1r = 0;
    my $g1a = 0;
    my $g2r = 0;
    my $g2a = 0;

    # Count up group 1 alleles
    foreach( @g1s ){
	
	if( $v[$_] =~/^0\/0/ ){
	    $g1r += 2;
	} elsif ( $v[$_] =~/^0\/1/ ){
	    $g1r ++;
	    $g1a ++;
	} elsif ( $v[$_] =~/^1\/1/ ){
	    $g1a += 2;
	} 
    }

    # Count up group 2 alleles
    foreach( @g2s ){
	
	if( $v[$_] =~/^0\/0/ ){
	    $g2r += 2;
	} elsif ( $v[$_] =~/^0\/1/ ){
	    $g2r ++;
	    $g2a ++;
	} elsif ( $v[$_] =~/^1\/1/ ){
	    $g2a += 2;
	} 
    }

    if( $g1r + $g1a >= $minA && $g2r + $g2a >= $minA ){
	# Proceed to testing
	unless( ($g1r == 0 && $g2r == 0) || ($g1a == 0 && $g2a == 0) ){

	    my $total = $g1r + $g1a + $g2r + $g2a;
	    my $g1t = $g1r + $g1a;
	    my $rTot = $g1r + $g2r;
	    
	    my $result = calculateStatistic( n11=>$g1r, n1p=>$g1t, np1=>$rTot, npp=>$total );
	    if( (my $errorCode = getErrorCode()) ){
		print "Skipping $v[2] because of the error $errorCode  - ".getErrorMessage();
		
	    } else {
		print $O join("\t",$v[2],$coords,$total,$g1r,$g1a,$g2r,$g2a,$result),"\n";
	    }
	} else{
	    print "Both groups fixed for the same allele at $v[2], no testing\n";
	}
    } else {
	print "Skipping $v[2] because there are too few alleles in at least one group\n\n";
    } 
}

#########################################################################################
################################## SUBROUTINES ##########################################
#########################################################################################

sub parseInOut{

    GetOptions( 'vcf:s' => \$vcf,
		'region:s' => \$region,
		'g1:s' => \$g1,
		'g2:s' => \$g2,
		'minA:f' => \$minA,
		'out:s' => \$out,
		'add:i' => \$add
	);

    # Get variants in defined region
    unless( $vcf =~/.gz$/ && -e ${vcf}.'.tbi' ){
	print "\n\nERROR: You must provide a tabix-indexed VCF file with -vcf\n\n";
	die &usage;
    } else {
	if( $region =~/.*:\d+-\d+/ || $region =~/\w/ ){
	    my $vs = `tabix $vcf $region`;
	    chomp $vs;
	    @variants = split("\n",$vs);
	    print "Processing ",scalar @variants," in the region $region\n";
	} else{
	    print "\n\nERROR: You must provide a range to process. It must be in\n";
	    print "the format chr:start-end\n\n";
	    die &usage;
	}
    }

    

    # Check groups
    unless( $g1 && $g2 ){
	print "\n\nERROR: You must provide two groups to split samples into with -g1 and -g2\n\n";
	die &usage;
    } else {

	my $h = `tabix -H $vcf | grep "CHROM"`;
	chomp $h;
	my @s = split("\t",$h);
	for( my $i = 9; $i < scalar @s; $i++ ){
	    $as{$s[$i]} = $i;
	}

	if( $minA > 2 * scalar @s ){
	    print "\n\nERROR: Minimum number of alleles cannot be larger that twice the number of samples\n\n";
	    die &usage;
	}

	open( my $G1,'<',$g1 ) || die "\n\nCan't open your g1 file\n\n";
	open( my $G2,'<',$g2 ) || die "\n\nCan't open your g2 file\n\n";
	

	while( <$G1> ){
	    chomp;
	    if( exists $as{$_} ){
		push(@g1s,$as{$_});
		unless( exists $seen{$_} ){
		    $seen{$_} = 1;
		} else {
		    die "\n\nERROR: Sample $_ is in list g1 twice\n";
		}
	    } else {
		print "WARNING: Sample $_ doesn't exist in the VCF, omitting\n";
		$minA--;
	    }
	}

	while( <$G2> ){
	    chomp;
	    if( exists $as{$_} ){
		unless( exists $seen{$_} ){
		    push(@g2s,$as{$_});
		} else { 
		    die "\n\nERROR: Sample $_ is in both g1 and g2 lists\n\n";
		}
	    } else {
		print "WARNING: Sample $_ doesn't exist in the VCF, omitting\n";
		$minA--;
	    }
	}
    }

    unless( $out ){
	print "\nPrinting output to default.txt\n";
	$out = 'default.txt';
    } 
    
    print "Including ",scalar @g1s," group 1 samples and ",scalar @g2s," group 2 samples\n";

    if( $add == 1 ){
	open( $O,'>>',$out) || die "ERROR: Can't open outfile for some reason\n\n";
	print "Appending results to $out\n";
    } else{
	open( $O,'>',$out) || die "ERROR: Can't open outfile for some reason\n\n";
	print $O "# ID\ttotal\tg1ref\tg1alt\tg2ref\tg2alt\tp\n";
    }
}


sub usage{

    my $u=<<END;

usage: perl PerformFisherTests.pl -vcf <vcf.gz> -region <chr:start-end> 
-minA <float> -out <out.txt> -g1 <list1.txt> -g2 <list2.txt> -add <0|1>

This script will calculate Fisher\'s Exact Test statistics on allele frequencies in two 
groups of samples from a VCF file. 

vcf      VCF file containing variant calls. Must be bgzipped and tabix indexed.
region   Region in which to use variants for FETs. e.g. Hmel210004:1000-5000 or just
         Hmel210004 to process the whole chr/scaff.
minA     The minimum number of called alleles required to perform the test. Variants 
         with < minA called alleles will be ignored.
out      Output file name.
g1, g2   Files containing lists of samples to include in each group. These names must
         match the sample names in the VCF header exactly. You do not need to use all 
         samples (i.e. g1+g2 does not need to equal the total number of samples in the 
         VCF). However, these lists must be non-overlapping.
add      Append to the output file, if it exists? 0: no, 1: yes

END

print $u;
exit 1;

}     


