#!/usr/bin/perl

use strict;
use warnings;

unless( scalar(@ARGV) == 2 ){ die &usage; }

my($gffs,$fas) = @ARGV;

open(GFF,"<$gffs") || die &usage;
open(FA,"<$fas") || die &usage;

my(@gffs,@fastas,$fadir);

# Read the fastas into a hash
while(<FA>){

    chomp;
    my $line = $_;
    my @line = split("/",$_);
    my $f = pop(@line);

    push(@fastas,$f);

    $fadir = join("/",@line);
    
}

# Process the GFF files one at a time for each input fasta
while(<GFF>){
    chomp;
    my $line = $_;

    print "Processing gff file $line\n";
    my @line = split("/",$_);
    my $gene = pop(@line);
    $gene =~ s/\.gff//;

    my %CDS;
    print "There are ",scalar(@fastas)," fasta files in the array\n";
    foreach my $fa (@fastas){
	print "Processing fasta file $fa\n";
	my $sample = $fa;
	system("gffread $line -x temp -g ${fadir}/${fa} -o gff");
	my $s = &get_seq("temp");
	$sample =~ s/\.fa//; $sample =~ s/\.fasta//;
	$CDS{$sample} = $s;
    }
    
    system("rm temp");
    open(T,">temp");
    foreach my $key (sort(keys(%CDS))){
	print T ">",$key,"\n",$CDS{$key};
    }
    close(T);

    print "Beginning to align sequences\n";
    system("muscle -in temp -out ${gene}.fa");
    system("rm temp");

} 
    


############################### SUBROUTINES #################################

sub usage{
    print "\n\nThis script is meant to produce alignments for MK tests\n";
    print "using specific input files: gffs and fastas. The gff files \n";
    print "contain only one gene's information (probably want longest CDS)\n";
    print "and the list must consist of the full paths to all the gffs you\n";
    print "want to process. These gffs are used by Cufflinks' gffread\n";
    print "utility to extract the alternate sequences from individual \n";
    print "fasta files. Fasta files should be named with the species \n";
    print "abbreviation first. For example: Dmel_RG22.fa. After extracting\n";
    print "the CDS sequences, the script will use MUSCLE to align the \n";
    print " sequences with default settings. The output is the alignment.";

    print "\n\nusage:./GenerateFastasForMk.pl <gff_list> <fasta_list>\n";
    print "\tgff_list\tlist of gffs to process FULL PATHS\n";
    print "\tfasta_list\tlist of fastas to extract gff seqs from FULL PATHS\n\n\n";
    
}

sub get_seq{
    
    my $seq;
    my $fasta = $_[0];
    
    open(F,"<$fasta") || die "No fasta file passed to subroutine\n";

    while(<F>){
	next if ($_ =~ /^>/);
	$seq.=$_;
    }

    return $seq;
}
