#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $gff;
my $paf;
my $inc;
my $out;

my $G;
my $O;
my %scafs;
my $osets;

&initialize;

# Go through GFF. 
# 1) Exclude annotations on scaffolds that are not included in the chromosome assembly.
# 2) Put in corrected chromosome coordinates
# 3) Add original coordinates to info field

# Have: $G (GFF filehandle), $O (output filehandle), %scafs (included scaffolds),
# and $osets (hash of arrays reference)

while( <$G> ){

    # Maintain header
    if( $_ =~/^#/ ){
	print $O $_;
    } else {

	chomp;
	my @anno = split( "\t", $_ );

	# scaffold329 maker gene 100981 101449 . - . ID=Hcyg013957;Name=Hcyg013957;...
	# scaffold329 maker mRNA 100981 101449 . - . ID=Hcyg013957-RA;Parent=Hcyg013957;Name=Hcyg013957-RA;...
	# scaffold329 maker exon 100981 101111 . - . ID=Hcyg013957-RA:3;Parent=Hcyg013957-RA;
	# scaffold329 maker exon 101204 101319 . - . ID=Hcyg013957-RA:2;Parent=Hcyg013957-RA;
	# scaffold329 maker exon 101420 101449 . - . ID=Hcyg013957-RA:1;Parent=Hcyg013957-RA;
	# scaffold329 maker CDS  101420 101449 . - 0 ID=Hcyg013957-RA:cds;Parent=Hcyg013957-RA;
	# scaffold329 maker CDS  101204 101319 . - 0 ID=Hcyg013957-RA:cds;Parent=Hcyg013957-RA;
	# scaffold329 maker CDS  101018 101111 . - 1 ID=Hcyg013957-RA:cds;Parent=Hcyg013957-RA;

	# Key points: get old pos info and add to gene and mRNA entries, put new chr info

	# If this scaffold is included, fix and print
	if( exists $osets->{$anno[0]} ){

	    # Get original position if needed
	    my $attr = $anno[8];
	    if( $anno[2] eq 'gene' || $anno[2] eq 'mRNA' ){
		$attr .= "OriPos=" . $anno[0] . ":" . $anno[3] . "-" . $anno[4] . "(" . $anno[6] . ")";
	    }
	    
	    # Make simpler
	    my $info = $osets->{$anno[0]};
	    
	    my $chr = $info->[0];
	    my $start;
	    my $end;
	    my $strand;

	    # Fix position. $osets->{$anno[0]} = \( $chr, $cstart, $cend, $strand )
	    if( $info->[3] eq '+' ){

		# OK!
		$start = $anno[3] + $info->[1];
		$end =   $anno[4] + $info->[1];
		$strand = $anno[6];

	    } else {

		# Opposite strand
		if( $anno[6] eq '+' ){
		    $strand = '-';
		} else {
		    $strand = '+';
		}

		# End of scaffold - position, swap start/end
		$start = $info->[2] - $anno[4] + 1;
		$end =   $info->[2] - $anno[3] + 1;

	    }

	    print $O join("\t", $chr, $anno[1], $anno[2], $start, $end, $anno[5], $strand, $anno[7], $attr) . "\n";
	    
	} #if( exists $osets->{$anno[0]} )...		
		
    } # not header

}

close($O);
system( "sort -k1,1 -k4,4n -k5,5n $out > a; mv a $out" );
close($G);

############### SUBROUTINES #################

sub initialize{

    GetOptions( 'gff:s' => \$gff,
		'paf:s' => \$paf,
		'included_scaffolds:s' => \$inc,
		'out:s' => \$out );

    # GFF supplied?
    if( ! $gff ){
	print "\n\nERROR: You must supply the GFF for the original draft scaffolds with --gff\n";
	die &usage;
    } else {
	open( $G, '<', $gff ) || die "\nERROR: Cannot open supplied GFF file $gff\n";
    }
    
    # Scaffolds included?
    if( ! $inc ){
	print "\n\nERROR: You must supply a list of scaffolds included in the chromosomes using --included_scaffolds\n";
	die &usage;
    } else {
	
	open( my $S, '<', $inc ) || die "\nERROR: Cannot open scaffolds list $inc\n";
	while( <$S> ){ chomp; $scafs{$_} = 1; }
	close( $S );
    }
    
    # PAF supplied?
    if( ! $paf ){
	print "\n\nERROR: You must supply the PAF for the original scaffolds mapped to the chromosome-level assembly with --paf\n";
	die &usage;
    } else {
	# hash reference, key = scaffold, value = (chr_start, chr_end, strand)
	$osets = &process_paf( $paf, \%scafs );
    }
    
    # Prepare output
    if( ! $out ){
	print "\nUsing default output chromosome.gff for output\n";
	$out = 'chromosome.gff';
    }

    open( $O, '>', $out ) || die "\nERROR: Cannot open output file $out\n";

}

# Shift positions and condense broken hits
sub process_paf{

    # At the end, need a hash of arrays with each scaffold's chr start, chr end, and strand
    # p is paf file name, s is a hash reference of included scaffolds 
    my ( $p, $s ) = @_;
    my %result;
    
    open( my $P, '<', $p ) || die "\nERROR: Cannot open provided PAF file $paf\n";

    while( <$P> ){

	chomp;
	my @l = split( "\t", $_ );

	# If this scaffold is included, continue
	if( exists $s->{$l[0]} ){

	    # If we've already processed this scaffold (sometimes there are
	    # multiple good hits because of, e.g. long gaps), then skip
	    if( exists $result{$l[0]} ){
		next;
	    } else {
		
		# PAF
		# #scaf       slen   sstart send   strand chr   clen     cstart  cend
		# scaffold194 433243 8      433223 +      chr13 17555946 3482820 3916035 ...
		# scaffold60  905936 32     905933 -      chr19 16276936 3145394 4051295 ...

		my $chr = $l[5];
		my $cstart;
		my $cend;
		my $strand = $l[4];

		# Handle + and - strands separately

		my $left_shift = $l[2];
		my $right_shift = $l[1] - $l[3];
	 
		if( $strand eq '+' ){
		    $cstart = $l[7] - $left_shift;
		    $cend = $l[8] + $right_shift;
		} else {
		    $cend = $l[8] + $left_shift;
		    $cstart = $l[7] - $right_shift;
		}
		my @a = ( $chr, $cstart, $cend, $strand );
		$result{$l[0]} = \@a; 

	    }

	} else {
	    # Not included in mapped scaffolds
	    next;
	}	
    } # while( <$P> )...

    return( \%result );
}

# Help message
sub usage{

    my $u =<<END;

usage: perl ApplyGffToChromosomes.pl --gff <draft.gff> --paf <draft_to_chr.paf> 
                  --mapped_scaffolds <scafs.txt> --out <chromosome.gff>

This script is meant to apply gene annotations from a draft genome to a chromosome-
level assembly of that draft genome. A typical pipeline would be:

1 - Assemble and annotate a draft genome.
2 - Use RaGOO to assign draft scaffolds to a chromosome-level reference, breaking 
    chimeric scaffolds and fixing the original GFF.
3 - Align all draft scaffolds to the RaGOO chromosome level assembly using minimap2. 
4 - Use this script with the original GFF (with annotations fixed for the chimeric
    scaffolds), the PAF from step 3, and a list of scaffolds that are actually 
    included in the chromosomes to assign gene models to chromosomes.

END

    print $u;


}


