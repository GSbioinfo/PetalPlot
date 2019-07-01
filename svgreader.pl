#!/usr/bin/perl 
use strict;
use warnings;
use Math::VecStat qw(min max);
use Data::Dumper qw(Dumper);
use POSIX;
my $file="/Users/gajendra/Dropbox/perltesting/stack.svg";
my @svgfile;
open my $in, "<:encoding(utf8)", $file or die "$file: $!";
my $iter=1;
while (my $line = <$in>) {
    push @svgfile,$line;
     $iter=$iter+1;
    
}
my @plotinfo = split /[\/]/, $file;
print Dumper @plotinfo;
my $infofile = $plotinfo[$#plotinfo] =~ s/.svg/.tsv/r;
$infofile = "maxsum_".$infofile;
$plotinfo[$#plotinfo]=$infofile;
my $readinfo= join"/",@plotinfo;
print "$readinfo\n";
my @defaul_im_size=(1000,1000);
my $outer_cir= ($defaul_im_size[0]/2)-($defaul_im_size[0]/2)*0.1;#450; #radius of outer circle upper limit 
my $inner_cir=($defaul_im_size[0])*0.1;
print $outer_cir, $inner_cir;
my $myx=50;
my @myy;
my $num_ticks=10;
my $spce= ($outer_cir-$inner_cir)/$num_ticks;
for (my $ix=0; $ix <= $num_ticks; $ix++){
    push @myy,$inner_cir+($spce*$ix);
}
print Dumper @myy;
open(my $fhinfo, '<:encoding(UTF-8)', $readinfo)
  or die "Could not open file '$readinfo' $!";
my %infohash;
my @maxval;
while (my $row = <$fhinfo>) {
    chomp $row;
    my @rowarray= split /\s+/,$row;
    push @maxval,$rowarray[$#rowarray];
}
my @mymax = max(@maxval);
print Dumper $mymax[0];


#my @svgkeys = sort(keys %svgfile);
my $des="/Users/gajendra/Dropbox/perltesting/newstack.svg";
open(DES,'>',$des) or die $!;
foreach my $iter (0..1){
    print  DES $svgfile[$iter];
}
my $tickint= $mymax[0]/$num_ticks;
print $tickint;
print "\n";
my $tickval=0;#$mymax[0];
foreach(@myy){
    my $newy=500-$_;
    
print  DES qq{\t<line x1="5" x2="55" y1="$newy" y2="$newy" stroke="black" stroke-width= "2"/>\n};
print  DES qq{\t<text x="5" y="$newy" dy="-2" font-family="arial" font-size="20px" fill="red">$tickval</text>\n};  
$tickval=$tickval+$tickint;
print $tickval;
print "\n";
}
foreach my $iter (2..$#svgfile){
    print  DES $svgfile[$iter];
}

close $in;
close $des;