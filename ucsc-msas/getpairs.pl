
open( my $L, '<', 'spp_list' );

my @a;

while( <$L> ){

    chomp;

    push(@a,$_);
}


for( my $i = 0; $i < scalar @a; $i++ ){

    for( my $j = $i; $j < scalar @a; $j++ ){
	print $a[$i] , "\t", $a[$j], "\n";
    }
}
