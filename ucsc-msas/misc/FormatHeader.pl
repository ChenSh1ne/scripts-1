#!/usr/bin/perl

my $CL = shift;
my $FA = shift;
my $OF = shift;

my $SP = $FA;
$SP =~s/.fasta//;

my %L;

open(my $c,'<',$CL);

while(<$c>){
    chomp;
    my @a = split("\t",$_);
    $L{$a[0]} = $a[1];
}

open(my $f,'<',$FA);
open(my $o,'>',$OF);

while(my $n = <$f>){
    if($n =~/^>/){
	chomp($n);
	my @n = split(" ",$n);
	$n = $n[0];
	$n =~s/>//;
	print $o ">$SP:",$n,":1:+:",$L{$n},"\n";
    } else {
	print $o $n;
    }
}

close($FA);
close($OF);
close($CL);	


	
