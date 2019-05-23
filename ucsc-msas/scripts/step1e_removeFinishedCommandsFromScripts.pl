#!/usr/bin/perl

use strict;
use warnings;

unless(scalar(@ARGV) == 3){ die "usage: perl all_remove_done.pl script outfile dir_with_finished_psls\n"; }

my($full,$out,$dir) = @ARGV;
my %done;

open(F,"<$full") || die "$full doesn't exist\n";
open(O,">$out")  || die "Can't open outfile $out\n";
opendir(D,$dir) || die "Directory $dir doesn't exist\n";

while(my $file = readdir(D)){

#    print $file,"\n";
    
    chomp($file);

    $done{$file} = 1;

}

closedir(D);

my @allfiles;
my @allcommands;

print O ". ~/.bashrc\n";

# Get all the possible outfiles, then reverse the array and move backwards to find the last 
while( my $script = <F> ){

    if( $script =~m/bashrc/ ){ next; }
        
    # Example doabunch line
    # lastz ./genomes/dsec_2bit//scaffold_5289.2bit ./genomes/dyak_2bit//v2_chrUn_585.2bit --masking=0 --hspthresh=3000 --gappedthresh=3000 --ydrop=9400 --gap=400,30 --inner=2000 --seed=12of19 --transition > ./lav/dsec_dyak/v2_chrUn_585.scaffold_5289.lav;perl ./check_file.pl ./lav/dsec_dyak/v2_chrUn_585.scaffold_5289.lav; if [ -e ./lav/dsec_dyak/v2_chrUn_585.scaffold_5289.lav ]; then lavToPsl ./lav/dsec_dyak/v2_chrUn_585.scaffold_5289.lav stdout | liftUp -type=.psl stdout ./genomes/dsec.lift error stdin | liftUp -nohead -pslQ -type=.psl stdout ./genomes/dyak.lift error stdin | gzip -c > ./psl/dsec_dyak/v2_chrUn_585.scaffold_5289.psl.gz; fi
	    
    my @line = split(/\//,$script);

    my $ofile = pop(@line);

    chomp($ofile);
    
    $ofile=~s/; fi//;

    unless( exists $done{$ofile} ){
	print O $script;
    }

}


close(O);
close(F);
