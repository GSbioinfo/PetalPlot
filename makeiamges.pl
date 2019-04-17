#!/usr/bin/perl
eval "use GD";
use GD;
 
# create a new image
my $im = new GD::Image(1000,1000);
 
# allocate some colors
my $white = $im->colorAllocate(255,255,255);
my $black = $im->colorAllocate(0,0,0);       
my $red = $im->colorAllocate(255,0,0);      
my $blue = $im->colorAllocate(0,0,255);
 
# make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');
 
# Put a black frame around the picture
$im->rectangle(0,0,99,99,$black);
 
# Draw a blue oval
$im->arc(50,50,95,75,0,360,$blue);
 
# And fill it with red
$im->fill(50,50,$red);
 

 
# Convert the image to PNG and print it on standard output

open my $out, '>', 'img.png' or die;
binmode $out;
print $out $im->png;