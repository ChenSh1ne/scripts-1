#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $f1;
my $c1;
my $f2;
my $c2;
my $out;
my $F1;
my $F2;
my $O;
my $numf1;
my $numf2;

my %all;
my %file1;
my %file2;


&parseInOut;

foreach my $k (sort(keys(%all))){

    if( exists($file1{$k})){
	print $O $file1{$k};
    } else {
	print $O "NA","\tNA" x ($numf1-1);
    }

    if( exists($file2{$k})){
	print $O "\t",$file2{$k},"\n";
    } else {
	print $O "\tNA" x $numf2,"\n";
    }
}

close($O);



sub parseInOut{

    GetOptions('file1:s' => \$f1,
	       'file2:s' => \$f2,
	       'col1:i'  => \$c1,
	       'col2:i'  => \$c2,
	       'out:s'   => \$out);

    unless( $f1 && $f2 && $c1 >=0 && $c2 >=0 ){
	print "You must supply all arguments\n";
	die &usage;
    }

    open($F1,'<',$f1) || die "Cannot open file 1 $f1\n";
    open($F2,'<',$f2) || die "Cannot open file 2 $f2\n";
    
    unless( $out ){
	$out = 'default.txt';
    }

    open($O,'>',$out) || die "Cannot open outfile $out\n";

    ########## Read files into hashes

    while( my $line = <$F1> ){
	chomp($line);
	my @l = split("\t",$line);
	$numf1 = scalar(@l);
	$all{$l[$c1]} = 1;
	$file1{$l[$c1]} = $line;
    }

    while( my $line = <$F2> ){
	chomp($line);
	my @l = split("\t",$line);
	$numf2 = scalar(@l);
	$all{$l[$c2]} = 1;
	$file2{$l[$c2]} = $line;
    }

    close($F1);
    close($F2);

}

sub usage{

    my $u=<<END;

usage: perl JoinFilesBySharedValue.pl -file1 <file1.tsv> -col1 <int> -file2 <file2.tsv> 
                                      -col2 <int> -out <out.txt>

This script will join two tab-separated files by shared values in specified columns. 
Columns must be defined as 0-based columns. The output file will be in the order of
file1 columns, file2 columns. One line for each unique value in the two files will 
be written to the output file. If a file does not contain a line with a matching value,
the proper number of fields will be filled with NA. 

END

print $u;

}
