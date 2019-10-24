#!/usr/bin/perl

use strict;
use warnings;

unless(scalar(@ARGV) == 2){ die "usage: ./del_total_masked_fas.pl <sp> <dir>"; }

my $sp=shift;
my $dir=shift;

system("mkdir $dir/${sp}_completely_masked_files/");
    
opendir(DIR,$dir) || die "$dir doesn't exist!\n\n";

while(readdir DIR){
    if($_ =~/.fa$/ || $_ =~/.fasta$/){
	print "processing fasta file $_\n";
	my $fa = $_;
	my $seq = &readFa($_);

	my $count = $seq =~tr/[ACGT]//;

	if( $count < 100 ){
	    system("mv $dir/$fa $dir/${sp}_completely_masked_files");
	}
    }
}

closedir(DIR);


sub readFa{
    my %sequence;
    my $header;
    my $seq;
    my $fasta = shift;
    
    open (FASTA, "<${dir}/$fasta")
	or die "Can't open fasta file $fasta: #!";
		
    while (<FASTA>) {
	chomp($_);
	
	# Save the sequence name (first word after ">") in $header
	unless($_ =~ /^>/) {
	    $seq.=$_;
	}
    }
    return $seq;
}
