#!/usr/bin/perl

use strict;
use warnings;

my %dsim = &read_fasta('dsim.fasta');
my %dere = &read_fasta('dere.fasta');
my %dyak = &read_fasta('dyak.fasta');
my %dsec = &read_fasta('dsec.fasta');

print "Done loading outgroup sequences\n";
print "Beginning to process VCF files\n";

my $vcf = '../DPGP2_SNP_Calls_6-2015/DPGP2.r6.06.StrictFilter.20150812.simple.vcf.gz';
#my $vcf = 'test.vcf.gz';

open( my $f, "zcat $vcf|" ) || die "Can't find vcf file\n";

open( my $out, ">", "ancestral_states.txt" ) || die "Can't open anc states file\n";
print $out "# Generated using GetAncestralSnpStates.pl on ",scalar(localtime),"\n";
print $out "# Used VCF file $vcf\n";
print $out "# RS: reference allele state (0 = ancestral, 1 = derived), AS: alt allele state\n";
print $out "# SNP_ID\tchr\tpos\tdmel_RS\tdmel_AS\tdmel_ref\tdmel_alt\tdsim\tdsec\tdyak\tdere\tsupport\n";

my $kt = 0;

while(<$f>){
    unless( $_ =~/^#/ ){
	chomp;
	my @l = split("\t",$_);

	unless( $l[4] =~m/,/ ){
	
	    # Ex line: 
	    # X 870 dv00000000 C T ...
	    
	    print $out $l[2],"\t",$l[0],"\t",$l[1],"\t";
	    
	    my $e = substr($dere{$l[0]},$l[1]-1,1);
	    my $s = substr($dsec{$l[0]},$l[1]-1,1);
	    my $i = substr($dsim{$l[0]},$l[1]-1,1);
	    my $y = substr($dyak{$l[0]},$l[1]-1,1);
	    my $ref = $l[3];
	    my $alt = $l[4];

	    my $rest = join("\t",$ref,$alt,$i,$s,$y,$e);

	    # Determine if there is conflicting/consistent information
	    # regarding the ancestral state at this postion

	    # This subroutine returns the base that is the ancestral state
	    
	    my ($anc,$str) = &getAnc($e,$s,$i,$y);

	    # Deal with special case where each clade is consistent, but not with
	    # each other (e.g. anc = A_G and str = none_weak, and the first part 
	    # is the dere/dyak state, second is dsec/dsim state

	    if ( $anc =~/_/ ){

		my @bs = split("_",$anc);
		
		# If they conflict, no support
		if ( ($bs[0] eq $ref && $bs[1] eq $alt) || 
		     ( $bs[0] eq $alt && $bs[1] eq $ref) ){
		    print $out "NA\tNA\t",$rest,"\tnone\n";
		} elsif ( $bs[0] eq $ref || $bs[1] eq $ref ){
		    print $out "0\t1\t",$rest,"\tweak\n";
		} elsif ( $bs[0] eq $alt || $bs[1] eq $alt ){
		    print $out "1\t0\t",$rest,"\tweak\n";
		} else { # bs[0] ne alt or ref, and bs[1] ne alt or ref
		    print $out "NA\tNA\t",$rest,"\tnone\n";
		}
	    } elsif ( $anc eq 'N' ){
		print $out "NA\tNA\t",$rest,"\tnone\n";
	    } elsif ( $ref eq $anc ){
		print $out "0\t1\t",$rest,"\t",$str,"\n";
	    } elsif ( $alt eq $anc ){
		print $out "1\t0\t",$rest,"\t",$str,"\n";
	    } elsif ( $ref ne $anc && $alt ne $anc ){
		print $out "NA\tNA\t",$rest,"\tnone\n";
	    } else {
		die "No idea what's going on: anc = $anc, ref = $ref, alt = $alt\n";
	    }
	}
    }
    
    if($kt % 10000 == 0 ){ print "Processed $kt records\n"; }
    $kt++;
}

close($f);


############################ SUBROUTINES #########################	    

sub getAnc{

    my($ere,$sec,$sim,$yak) = @_;
    my $base;
    my $strength;
    my ($is,$ie,$iy,$se,$sy,$ey);
    
    my $flag = 0;
    my %bases;

    foreach($ere,$sim,$sec,$yak){
	unless( $_ eq '-' || $_ eq 'N' ){
	    $bases{$_} += 1;
	    $flag = 1; # There is at least one called base in the
	               # outgroup species.
	}
    }

    if ( $flag == 1 ){

	# Are the species pairs consistent with each other?
	if( $sim eq $sec && $sim ne '-' && $sim ne 'N' ){ $is = 1; } else { $is = 0; }
	if( $sim eq $ere && $sim ne '-' && $sim ne 'N' ){ $ie = 1; } else { $ie = 0; }
	if( $sim eq $yak && $sim ne '-' && $sim ne 'N' ){ $iy = 1; } else { $iy = 0; }
	if( $sec eq $ere && $sec ne '-' && $sec ne 'N' ){ $is = 1; } else { $se = 0; }
	if( $sec eq $yak && $sec ne '-' && $sec ne 'N' ){ $is = 1; } else { $sy = 0; }
	if( $ere eq $yak && $ere ne '-' && $ere ne 'N' ){ $ey = 1; } else { $ey = 0; }

	# Get maximum number of consistent species
	my @vals = sort {$b <=> $a} values(%bases);
	my $max = $vals[0];
	
	if ( $max == 4 || $max == 3 ){

	    my @b = keys(%bases);
	    $strength = 'strong';

	    if(scalar(@b) == 1){
		$base = $b[0];
	    } else {
		if ( $bases{$b[0]} > $bases{$b[1]} ){
		    $base = $b[0];
		} else {
		    $base = $b[1];
		} 
	    }  
		
	} elsif ( $max == 2 ){

	    # If both clades are consistent, but have different
	    # states, it's a special case.

	    if ( $ey == 1 && $is == 1 ){
		$strength = 'none_weak';
		$base = $ere."_".$sec;
	    
	    # If the species are from the same clade
	    } elsif ( $ey == 1 || $is == 1){
		$strength = 'weak';
		if ( $ey == 1 ){
		    $base = $ere;
		} else {
		    $base = $sec;
		}
	    # Else they're from different clades
	    } else {
		$strength = 'strong';
		if ( $ie == 1 || $iy == 1 ){
		    $base = $sim;
		} elsif ( $se == 1 || $sy == 1 ){
		    $base = $ere;
		}
	    }	    
	} elsif ( $max == 1 ){

	    $strength = 'weak';
	    
	    if ( $ere =~/[ATCG]/ ){ 
		$base = $ere; 
	    } elsif ( $yak =~/[ATCG]/ ){ 
		$base = $yak; 
	    } elsif ( $sim =~/[ATCG]/ ){ 
		$base = $sim; 
	    } elsif ( $sec =~/[ATCG]/ ){ 
		$base = $sec; 
	    } else { 
		die "There's a problem: no species is ATCG: dere = $ere, dsim = $sim, dsec = $sec, dyak = $yak\n";
	    }
	}
	
    } elsif ( $flag == 0){
	$base = 'N';
	$strength = 'none';
    } else { 
	die "wtf: ancestral state is off: sim = $sim, sec = $sec, ere = $ere, yak = $yak, base = $base\n"; 
    }

    
    unless ( defined($base) && defined($strength) ){
	print "Something's wrong: base = $base and strength = $strength, but\n";
	die "sim = $sim, sec = $sec, ere = $ere, and yak = $yak\n";
    }

    return($base,$strength);
    
}

    
sub read_fasta{
    my %sequence;
    my $header;
    my $seq;
    my $fasta = $_[0];
    
    open (FASTA, "<$fasta")
	or die "Can't open fasta file $fasta: #!";
    
    while (<FASTA>) {
	chomp($_);
	
	# Save the sequence name (first word after ">") in $header
	if ($_ =~ /^>/) {
	    # if we have something in $seq
	    if ($seq) {
		$sequence{$header}=$seq;
	    }
	    $header = $_;
	    $header=~s/^>//;
	    $header=~s/\s.*//;
	    $seq    = '';
	    # otherwise continue pasting the sequence together.
	} else {
	    $seq.=$_;
	}
	
    }
    # Store last sequence
    $sequence{$header}=$seq;
    return %sequence;
}
