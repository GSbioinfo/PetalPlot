#!/usr/bin/perl 
eval "use GD";
use GD;
use Math::Bezier;
use strict;
use Math::VecStat qw(min);
use strict;
use warnings;
use Data::Dumper qw(Dumper);
use List::MoreUtils qw(uniq minmax );
use xytoradial;
use drawimage;  
use GD::Simple;
use POSIX;
use mycolors;

my $filename = 'data_file.txt';
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

my %point_data; 
my %temp_axis_names; 
my %axis_names;
my @allvalues;
my @rowarray; 
my @defaul_im_size=(1000,1000);
#-------------------x(c1),y(c2)----------

my $outer_cir=450; #radius of outer circle upper limit 
my $inner_cir=100; #radius of inner circle lower limit
my $outer_axis=490; #radius of outer circle upper limit 
my $inner_axis=49; #radius of inner circle lower limit
my @maxmin_lim= (-1,-6);
my $col="blue";
my @colorcode=mycolors::findcolor($col);
#print Dumper \@colorcode;
@allvalues=@maxmin_lim;
while (my $row = <$fh>) {
  chomp $row;
  @rowarray= split /\s+/,$row;
  push @allvalues,$rowarray[3];
  push @{$temp_axis_names{$rowarray[0]}}, $rowarray[1];
  push @{$point_data{$rowarray[0]}{$rowarray[2]}}, @rowarray[2..$#rowarray];
  #$point_data{$rowarray[0]}{$rowarray[1]}= \@rowarray;
  
}
for my $ky (keys %temp_axis_names){
my @chekaxis_names = uniq @{$temp_axis_names{$ky}};
#print Dumper \%point_data;

my $size=@chekaxis_names;
#print "$size\n";
if ($size>1){ 
    die "Same axis assigned two names";
}
#print "-----------------##################------------------\n";
if($size==1){
  push @{$axis_names{$ky}}, @chekaxis_names;  
}
}

#print Dumper \%axis_names;
my @minmax = (minmax @allvalues);
if($minmax[0]>$maxmin_lim[0]){ die "Minimum limit is higher than data minimum"; }
if($minmax[1]<$maxmin_lim[1]){ die "Maximum limit is higher than data maximum"; }
#print "$minmax[1]\n";

my %axs_ang = xytoradial::get_axis_angles(%axis_names);
#print "$axs_ang{'a1'}[0]\n";

my $img=drawimage::createimage(@defaul_im_size);
#my $blue = $img->colorAllocate(0,0,255);
drawimage::circ_out(($defaul_im_size[0],$defaul_im_size[1],$inner_cir,$outer_cir,$img));
my %axis_col= ('a1'=>"yellow",
                'a2'=>"black",
                'a3'=>"cyan");
foreach my $outkey (keys %point_data) {
  my ($x1,$y1,$x2,$y2)=drawimage::axisdraw(($defaul_im_size[0],$defaul_im_size[1],$outer_axis,$inner_axis,$axs_ang{$outkey}[1],$img));
  my ($reg,$green,$blue)=mycolors::findcolor($axis_col{$outkey});
  my $alpha=0;
  my $bl = $img->colorAllocateAlpha($reg,$green,$blue,$alpha);
  $img ->setThickness(4);
  $img->line($x1,$y1,$x2,$y2,$bl);
  #print Dumper \($x1,$y1,$x2,$y2);
  foreach my $innerkey (keys %{$point_data{$outkey}}) {
    my $tempvalue=$point_data{$outkey}{$innerkey}[1];
    my $norm_val= $inner_cir+($tempvalue-$minmax[0])/($minmax[1]-$minmax[0])*($outer_cir-$inner_cir);
    my %temhash=('im_size'=> [@defaul_im_size],
                  'value'=> $norm_val,
                  'theta'=> $axs_ang{$outkey});
  
  my @xycord=xytoradial::get_xy_loc(%temhash);
  my $crs=$point_data{$outkey}{$innerkey}[3];
  drawimage::addPnt(($xycord[0],$xycord[1],$point_data{$outkey}{$innerkey}[2],$crs,$img));
  #print Dumper \%temhash;
  }
}
my $filename1 = 'line_data.txt';
open(my $fh1, '<:encoding(UTF-8)', $filename1)
  or die "Could not open file '$filename1' $!";

my $stck_width=($defaul_im_size[0])*0.25;#100;
my %line_hash;
while (my $row = <$fh1>) {
  chomp $row;
  @rowarray= split /\s+/,$row;
  #print Dumper \@rowarray;
  push @{$line_hash{$rowarray[0]}}, @rowarray[1..$#rowarray];
  #$point_data{$rowarray[0]}{$rowarray[1]}= \@rowarray;
  
}
print Dumper \%line_hash;
my %line_axis_xy;

for my $lkey (keys %line_hash){
  my ($clone,$ax1,$ax2,$val1,$val2,$colr,$crs)=@{$line_hash{$lkey}};
  my %two_ax=($ax1=>$val1,
              $ax2=>$val2);
  
  my @line_cord;
  foreach my $tkey (keys %two_ax){
    my $nval=$inner_cir+($two_ax{$tkey}-$minmax[0])/($minmax[1]-$minmax[0])*($outer_cir-$inner_cir);
    my %tem1=('im_size'=> [@defaul_im_size],
                  'value'=> $nval,
                  'theta'=> $axs_ang{$tkey}[1],
                  'width'=> $stck_width);
    print Dumper \%tem1;
    my ($temx,$temy,$tempx1,$tempy1,$tempx2,$tempy2)=xytoradial::get_baz_cb(%tem1);
    push @line_cord, ($temx,$temy,$tempx1,$tempy1,$tempx2,$tempy2);
    push @{$line_axis_xy{$lkey}{$tkey}},($defaul_im_size[0],$defaul_im_size[1],$temx,$temy,$tempx1,$tempy1,$tempx2,$tempy2,$nval,$axs_ang{$tkey}[1]); 
  }
  #print Dumper \%line_axis_xy;
  my $bezier = Math::Bezier->new(drawimage::draw_curv_lines2(%{$line_axis_xy{$lkey}}));
  my @points= $bezier->curve(40);
  my @bezier_points;
  while (@points) {
    push @bezier_points, [ splice( @points, 0, 2 ) ];
  }
  my $bl=$img->colorAllocate(mycolors::findcolor($colr));
  $img ->setThickness(1);
  for my $iz (0 .. @bezier_points-2){
    #print Dumper \$bezier_points[$iz][0];
    $img->line($bezier_points[$iz][0],$bezier_points[$iz][1], $bezier_points[ $iz + 1 ][0],$bezier_points[ $iz + 1 ][1],$bl);
    }
  
}
 


drawimage::write_img($img);