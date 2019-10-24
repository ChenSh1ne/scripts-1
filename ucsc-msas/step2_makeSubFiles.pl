#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $s1;
my $s2;
my $pieces;
my $dist;
my $scaf;
my $scaf_list;
my $whole = 0;
my $transition = 1;
my $step = 1;

# Test that the distance matrices exist!
## CHANGE THIS IF MISSING
my $dm = '/gpfs/data/kronforst-lab/nvankuren/programs/lastz/';

unless( -e ${dm}.'HumChimp.q' && -e ${dm}.'HoxD55.q' && -e ${dm}.'default.q' ){
    print "\n\nERROR: Cannot find the required distance matrices. You may need\n";
    print "to change the DM variable at the top of this script to point to the\n";
    print "correct directory. It is currently set to:\n";
    print $dm,"\n";
    die &usage;
}

# Proceed

my ( $Q, $M, $K, $Y, $L, $G, $H );
my ( $sp1Dir, $sp2Dir, $lavDir, $pslDir );

&initialize;

my @sp1;
my @sp2;


# All sp2 chrs
if( $whole == 0 ){
    opendir( my $DIR2, $sp2Dir );
    while( my $file = readdir( $DIR2 ) ){
	if( $file =~/.2bit$/ ){
	    push( @sp2, $file );
	}
    }
    closedir( $DIR2 );
}

# All sp1 chrs
if( ! $scaf && ! $scaf_list ){
    opendir( my $DIR1, $sp1Dir );
    while( my $file = readdir( $DIR1 ) ){
	if( $file =~/.2bit$/ ){
	    push( @sp1, $file );
	}
    }

    closedir( $DIR1 );
} elsif( $scaf ){
    push( @sp1, $scaf.'.2bit' );
} elsif( $scaf_list ){

    open( my $SL, '<', $scaf_list );
    while( <$SL> ){
	chomp;
	push( @sp1, $_.'.2bit' );
    }
    close($SL);
    
}
# Begin to actually print commands

if( -e 'cluster_scripts/doabunch' ){ system('rm cluster_scripts/doabunch'); }

open( my $O, ">>cluster_scripts/doabunch" );

if( $whole == 0 ){
    
    my $num_comp = 0;
    
    foreach my $s (@sp2){
	
	my $sp2file = $s;
	
	$sp2file =~s/\.2bit//;
	
	# For each sp1 2bit file
	foreach my $m (@sp1){
	    
	    my $sp1file = $m;
	    $sp1file=~s/\.2bit//;
	    
	    print $O "lastz ${sp1Dir}/${m} ${sp2Dir}/${s} --masking=${M} --hspthresh=${K} --gappedthresh=${L} ";
	    print $O "--ydrop=${Y} --gap=${G} --inner=${H} --seed=12of19 $transition --step=${step} --scores=${Q} > ";
	    print $O "${lavDir}/${sp1file}.${sp2file}.lav; perl scripts/step3_checkFile.pl ";
	    print $O "${lavDir}/${sp1file}.${sp2file}.lav; if [ -e ${lavDir}/${sp1file}.${sp2file}.lav ]; ";
	    print $O "then lavToPsl ${lavDir}/${sp1file}.${sp2file}.lav stdout | liftUp -type=.psl stdout ";
	    print $O "genomes/${s1}/${s1}.lift error stdin | liftUp -nohead -pslQ -type=.psl stdout ";
	    print $O "genomes/${s2}/${s2}.lift error stdin | gzip -c > ";
	    print $O "${pslDir}/${sp1file}.${sp2file}.psl.gz; rm ${lavDir}/${sp1file}.${sp2file}.lav; fi; echo \"Finished ${sp1file}.${sp2file}.psl.gz\"\n";
	    
	    $num_comp++;
	}
	
    }

    print "Finished printing doabunch. $num_comp total lines\n";
    print "Printing ",int($num_comp/$pieces)," lines per file\n";

    my $num_lines = int($num_comp/$pieces);
    
    system("shuf cluster_scripts/doabunch > cluster_scripts/a; mv cluster_scripts/a cluster_scripts/doabunch;");
    system("split -d -a 4 -l $num_lines cluster_scripts/doabunch cluster_scripts/${s1}_${s2}/${s1}_${s2}_");
    system("echo \"\. ~/\.bashrc\" > cluster_scripts/header");
    system("for i in cluster_scripts/${s1}_${s2}/${s1}_${s2}_*; do cat cluster_scripts/header \$i > cluster_scripts/a; mv cluster_scripts/a \$i; chmod +x \$i; done");


} else {

    foreach my $m (@sp1){
	
	my $sp1file = $m;
	$sp1file=~s/\.2bit//;
	
	print $O "lastz ${sp1Dir}/${m} ${sp2Dir}/${s2}.2bit --masking=${M} --hspthresh=${K} --gappedthresh=${L} ";
	print $O "--ydrop=${Y} --gap=${G} --inner=${H} --seed=12of19 $transition --step=${step} --scores=${Q} > ";
	print $O "${lavDir}/${sp1file}.${s2}.lav; perl scripts/step3_checkFile.pl ";
	print $O "${lavDir}/${sp1file}.${s2}.lav; if [ -e ${lavDir}/${sp1file}.${s2}.lav ]; ";
	print $O "then lavToPsl ${lavDir}/${sp1file}.${s2}.lav stdout | liftUp -type=.psl stdout ";
	print $O "genomes/${s1}/${s1}.lift error stdin | liftUp -nohead -pslQ -type=.psl stdout ";
	print $O "genomes/${s2}/${s2}.lift error stdin | gzip -c > ";
	print $O "${pslDir}/${sp1file}.${s2}.psl.gz; rm ${lavDir}/${sp1file}.${s2}.lav; fi; ";
	print $O "echo \"Finished ${sp1file}.${s2}.psl.gz\"\n";

    }

    system("split -d -a 4 -l 1 cluster_scripts/doabunch cluster_scripts/${s1}_${s2}/${s1}_${s2}_");
    system("echo \"\. ~/\.bashrc\" > cluster_scripts/header");
    system("for i in cluster_scripts/${s1}_${s2}/${s1}_${s2}_*; do cat cluster_scripts/header \$i > cluster_scripts/a; mv cluster_scripts/a \$i; chmod +x \$i; done");

}

close( $O );


sub initialize{

    GetOptions( 'species1:s' => \$s1,
		'species2:s' => \$s2,
		'pieces:i' => \$pieces,
		'whole:i' => \$whole,
		'scaf:s' => \$scaf,
		'scaf_list:s' => \$scaf_list,
		'step:i' => \$step,
		'transition:s' => \$transition,
		'distance:s' => \$dist
	);

    # Reference genomes and essential directories

    if( $scaf && $scaf_list ){
	print "\nERROR: You cannot use both scaf and scaf_list\n";
	die &usage;
    }

    # Use the whole genome as the target?
    if( $whole == 0 ){
	$sp2Dir = "genomes/${s2}/${s2}_2bit/";
    } else {
	$sp2Dir = "genomes/${s2}/";
    }

    # Transition and step OK?
    if( $transition == 1 ){
	$transition = '--transition';
    } elsif( $transition == 2 ){
	$transition = '--transition=2';
    } elsif( $transition == 0 ){
	$transition = '--notransition';
    } else {
	print "ERROR: transition may only be set to 0, 1,or 2.\n";
	die &usage;
    }

    unless( $step > 0 ){
	print "ERROR: step must be > 0\n";
	die &usage;
    }
    
    
    $sp1Dir = "genomes/${s1}/${s1}_2bit/";
    $lavDir = "lav/${s1}_${s2}";
    $pslDir = "psl/${s1}_${s2}";
    
    unless( -e $sp2Dir && -e $sp1Dir ){
	print "\n\nERROR: You must specify each species and ensure the reference genomes are set up properly\n";
	die &usage;
    } else {	
	unless( -d $lavDir ){ system("mkdir $lavDir"); }
	unless( -d $pslDir ){ system("mkdir $pslDir"); }
	unless( -d "cluster_scripts/${s1}_${s2}" ){ system("mkdir -p cluster_scripts/${s1}_${s2}"); }
    }

    # Number of scripts to produce
    unless( $pieces > 0 ){
	print "\n\nERROR: You must specify the number of script files to create with --pieces\n";
	die &usage;
    }

    # Set LASTZ parameters
    # Feel free to add different combinations of parameters
    my %possible_distances = ( 'near' => 1,
			       'medium' => 1,
			       'distant' => 1,
			       'fly' => 1,
			       'very_near' => 1,
			       'extremely_near' => 1
	);
    
    unless( exists $possible_distances{$dist} ){
	print "\n\nERROR: You must specify the evolutionary distance between your species as\n";
	print "one of ",join(", ", keys %possible_distances),"\n";
	die &usage;
    } else {
	if( $dist eq 'very_near' ){
	    $Q = $dm.'HumChimp.q';
	    $M = 254;
	    $K = 4500;
	    $Y = 15000;
	    $L = 3000;
	    $H = 0;
	    $G = '500,100';
	} elsif( $dist eq 'medium' ){
	    $Q = $dm.'HoxD55.q';
	    $M = 254;
	    $K = 3000;
	    $Y = 5600;
	    $L = 4000;
	    $H = 0;
	    $G = '400,30';
	} elsif( $dist eq 'distant' ){
	    $Q = $dm.'HoxD55.q';
	    $M = 254;
	    $K = 2200;
	    $Y = 3400;
	    $L = 6000;
	    $H = 2000;
	    $G = '400,30';
	} elsif( $dist eq 'fly' ){
	    $Q = $dm.'HoxD55.q';
	    $M = 254;
	    $K = 2200;
	    $Y = 3400;
	    $L = 4000;
	    $H = 2000;
	    $G = '400,30';
	} elsif( $dist eq 'near' ){
	    $Q = $dm . 'default.q';
	    $M = 254;
	    $K = 3000;
	    $Y = 9400;
	    $L = 3000;
	    $H = 0;
	    $G = '400,30';
	} elsif( $dist eq 'extremely_near' ){
	    $Q = $dm . 'HumChimp.q';
	    $M = 254;
	    $K = 6000;
	    $Y = 15000;
	    $L = 6000;
	    $H = 0;
	    $G = '600,150';
	}
    }
}


sub usage{

    my $u=<<END;

usage: perl step2_makeSubFiles.pl --species1 <sp1> --species2 <sp2> --pieces <100> --whole <0> --distance <near> --scaf <sp1_scaffold> --scaf_list <scaffold_list> --step <1> --transition <1>

This script makes files containing LASTZ commands for submission to the cluster, or for running on 
any computer with the correct directory structure. The scripts that it produces should be run from
the top of your working directory (e.g. that contains scripts, genomes, lav, etc. folders).

species1      The target species name (must be consistent with genome file setup from step1 scripts.
species2      The query species name.
pieces        The number of files to produce. LASTZ commands will be split evenly among these files.
whole         Should you use the whole genome of species2 as the query? Useful for comparing draft
              scaffolds to references, or extremely close sequences. (0|1, default 0)
scaf          If desired, you can make scripts for only one species1 scaffold. If used in 
              conjunction with whole, produces only a single command. Cannot be used in
              conjunction with scaf_list.
scaf_list     A list of species1 scaffolds to produce scripts for. Cannot be used in conjunction
              scaf.
step          Step size (lastz --step) between successive target seeds. Must be > 0. Default: 1.
transition    Allow 1 (1), 2 (2) or no (0) transitions between target and query seed match to 
              trigger a match. These correspond to lastz's --transition, --transition=2, and 
              --notransition options, respectively.
distance      The rough evolutionary distance between the two species that you are making scripts 
              for. This determines LASTZ parameters. This can be set to the following:

              extremely_near: Heliconius spp.
	      very_near: sister species
              near: Great Apes
              medium: mammal - marsupial or distant Papilionid species
	      fly: between medium and distant
              distant: mammal - monotreme or moth - butterfly

END
				       
}
