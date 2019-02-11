#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $cs; # chromSizes file
my $CS; # chromSizes filehandle
my $id = 'intervals'; # directory to write interval files to
my $max;# maximum number of bases to put into any one file
my $pre = 'def';# interval file prefix
my $F;

&parseInOut;


my $gt = 0;
my $fnum = 1;
my $tot = 0;
my $start = 1;
my $end;

my $fname = $id.'/'.${pre}.'.'.${fnum}.'.intervals';
open( $F,'>',$fname ) || die "\nERROR: Cannot open your first file for some reason... fname = $fname\n\n";

while( <$CS> ){

    chomp;
    my ($c,$l) = split("\t",$_);


    # There are 3 scenarios
    # 1. tot + l < max : add the whole scaffold to this file
    # 2. tot + l > max : add part, close old file, open new file
    
    if( $tot + $l > $max ){
  
	# Don't put small pieces at the end of intervals files
	if( $max - $tot > 50000 ){
	    print $F "${c}:1-".($max - $tot)."\n";
	    $start = $max - $tot + 1;
	    print "Split scaffold $c into two files $fnum and ",$fnum + 1,"\n";
	    close($F);
	} else { # Start a new file
	    $start = 1;
	    close($F);
	}
	
	$fnum++;
	$tot = 0;
	$fname = ${id}.'/'.${pre}.'.'.${fnum}.'.intervals';
	open( $F,'>',$fname ) || die "\nERROR: Cannot open your file for some reason... fname = $fname\n\n";
#	print "Processing interval file $fnum\n";

	# If the chromosome can be split into multiple max-sized chunks...
	my $flag = 0;
	while( $l - $start > 50000 && $flag == 0){
	    if( $l - $start > $max ){
		print $F "${c}:${start}-".($start+$max)."\n";
		$start = $start + $max;
		$fnum++;
		$tot = 0;
		$fname = ${id}.'/'.${pre}.'.'.${fnum}.'.intervals';
		open( $F,'>',$fname ) || die "\nERROR: Cannot open your file for some reason... fname = $fname\n\n";
#		print "Processing interval file $fnum\n";

	    } elsif( $l - $start < $max ){
		print $F "${c}:${start}-${l}\n";
		$tot += $l - $start;
		$flag = 1;
	    }
	}

    } else { # tot + l < max, so just add to the current file
	print $F "${c}:1-${l}\n";
	$tot += $l;
    }
}

close($F);   
	
    
###################################################################################################
################################### SUBROUTINES ###################################################
###################################################################################################

sub parseInOut{

    GetOptions('chroms:s' => \$cs,
	       'dir:s' => \$id,
	       'prefix:s' => \$pre,
	       'maximum:s' => \$max);

    # Get chromosome sizes filehandle

    unless( $cs ){
	print "\n\nERROR: You must provide a file with chromosome IDs and sizes with -chroms\n\n";
	die &usage;
    } else {
	open( $CS,'<',$cs ) || die "\n\nERROR: Cannot open your chroms file\n\n";
	print "\nUsing $cs for chromosome sizes\n\n";
    }

    # Get or open directory for output files
    unless( -d $id ){
	system("mkdir $id");
    }

    unless( $max > 0 ){
	print "\n\nERROR: You must provide a maximum value to include in each interval file with -maximum\n\n";
	die &usage;
    } elsif( $max < 1000000 ){
	print "\n$max is a pretty small interval. Are you sure you want to use it? enter yes or a new value > $max\n";
	my $nv = <>;
	chomp $nv;
	if( $nv > $max ){
	    $max = $nv;
	}
    }

    print "\nWriting interval files to ${id}/${pre}.x.intervals with a maximum of $max bases per file\n";

}


sub usage{

    my $u=<<END;

    usage: perl SplitIntoIntervals.pl -chroms <file.chromSizes> -dir <outdir> -prefix <out_pre> -maximum <int>

    This script will produce a set of interval files from a chromosome file for use in GATK tools
    with the -L option. 

    chroms      A file containing the chromosome / scaffold sizes in your reference genome file. This should
                be a list oof chromosome ID and size (tab-separated):
                e.g. chr1     12907778
                     chr2     1786890
                     ...
    dir         Name of the directory you want to write the interval files to. It will be created if it does
                not already exist. Default: intervals.
    prefix      Prefix of the intervals to write to. Output files will be, e.g. dir/prefix.1.intervals,
                dir/prefix.2.intervals, etc.
    maximum     The maximum number of bases to include in a particular interval file. If adding one more 
                chromosome or scaffold to the current interval will surpass the maximum threshold, the 
                subsequent scaffold will be split between two consecutive interval files.

END

print $u;

}
