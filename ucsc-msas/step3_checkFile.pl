#!/usr/bin/perl

use strict;
use warnings;

unless(scalar(@ARGV) == 1){ 
    print "\nusage: ./check_file.pl file\n\n";
    print "This script checks lav files to see that thereis an \"a\"\n";
    print "stanza. If there is no \"a\" stanza, it's not worth keeping\n";
    print "around for downstream analyses. This script expects that\n";
    print "the files are lav files and are kept in the sp1_sp2/ folder.\n\n";
    
    die;
}

my $file = shift;

open(F,"<$file");


my $flag = 0;
while(<F>){
    if( $_ =~m/a \{/ ){
	$flag = 1;
	last;
    }
}

if($flag == 0){

    system("rm $file");

}

close(F);
