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
use GD::SVG;
use POSIX;
use mycolors;

my $filename = 'stat_data.txt';
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

my %point_data; 
my @temp_axis_names; 
my %axis_names;
my @allvalues;
my @rowarray; 
my @defaul_im_size=(1000,1000);
#-------------------x(c1),y(c2)----------

my $outer_cir= ($defaul_im_size[0]/2)-($defaul_im_size[0]/2)*0.1;#450; #radius of outer circle upper limit 
my $inner_cir=($defaul_im_size[0])*0.1;#100; #radius of inner circle lower limit
my $outer_axis=($defaul_im_size[0]/2)*0.98;#490; #radius of outer circle upper limit 
my $inner_axis=($defaul_im_size[0])/2*0.098;#49; #radius of inner circle lower limit
my @maxmin_lim= (0,1);
my $col="blue";
my @colorcode=mycolors::findcolor($col);
#print Dumper \@colorcode;
@allvalues=@maxmin_lim;
my %clone_color_code;
while (my $row = <$fh>) {
  chomp $row;
  @rowarray= split /\s+/,$row;
  push @allvalues,($rowarray[2],$rowarray[3]);
  push @temp_axis_names, $rowarray[1];
  push @{$point_data{$rowarray[0]}{$rowarray[1]}}, @rowarray[2..3];
  @{$clone_color_code{$rowarray[0]}}=mycolors::findcolor($rowarray[4]);
  #$point_data{$rowarray[0]}{$rowarray[1]}= \@rowarray;
  
}

 
#print Dumper \%point_data;
my @chekaxis_names = uniq @temp_axis_names;
my $size=@chekaxis_names;
#print "$size\n";
if ($size<3){ 
   die "Less than 3 defined";
}

#print "-----------------##################------------------\n";
for my $ky (@temp_axis_names){
    push @{$axis_names{$ky}}, $ky;
}

#print Dumper \%axis_names;
my @minmax = (minmax @allvalues);
if($minmax[0]>$maxmin_lim[0]){ die "Minimum limit is higher than data minimum"; }
if($minmax[1]<$maxmin_lim[1]){ die "Maximum limit is higher than data maximum"; }
#print "$minmax[0]\n";

my %axs_ang = xytoradial::get_axis_angles(%axis_names);



#print Dumper \@test;

#print "$axs_ang{'a1'}[0]\n";

my $img=drawimage::createimage(@defaul_im_size);
#my $blue = $img->colorAllocate(0,0,255);
drawimage::circ_out(($defaul_im_size[0],$defaul_im_size[1],$inner_cir,$outer_cir,$img));

#my $poly = new GD::Polygon;

#$img->openPolygon($poly,$colx);
my %axis_col= ('a1'=>"yellow",
                'a2'=>"black",
                'a3'=>"cyan");
#print Dumper \%point_data;
foreach my $outkey (keys %axs_ang) {
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
  #drawimage::addPnt(($xycord[0],$xycord[1],$point_data{$outkey}{$innerkey}[2],$crs,$img));
  #print Dumper \%temhash;
  }
}
my %clone_stack_cord;
my $stck_width=($defaul_im_size[0])*0.05;#100;

for my $pkeys (keys %point_data){
my %tem=%{$point_data{$pkeys}};
#print Dumper \%tem;
for my $tmkey (keys %tem){
my %temrecod;
my @temval=@{$tem{$tmkey}};
my $nval1=$inner_cir+($temval[0]-$minmax[0])/($minmax[1]-$minmax[0])*($outer_cir-$inner_cir);
my $nval2=$inner_cir+($temval[1]-$minmax[0])/($minmax[1]-$minmax[0])*($outer_cir-$inner_cir);

%temrecod=('im_size'=> [@defaul_im_size],
            'value' => [$nval1,$nval2],
            'theta' => $axs_ang{$tmkey}[1],
            'width' => $stck_width/2
);
#print Dumper \%temrecod;
my @points=(xytoradial::get_stack_cord(%temrecod));
# @points = ($x1c1,$y1b1,$x1,$y1,$x1c2,$y1b2,$x2c2,$y2b2,$x2,$y2,$x2c1,$y2b1)
#               0    1     2  3    4     5     6     7    8   9   10    11 
push @{$clone_stack_cord{$pkeys}{$tmkey}}, @points;
my @test;
my $alpha=0;
$img ->setThickness(1);
my $bl = $img->colorAllocateAlpha(@{$clone_color_code{$pkeys}},$alpha);
my $poly = new GD::Polygon;
#my $poly = GD::SVG::Polygon->new;
while (@points) {
  my @newpnt= splice( @points, 0, 2 );
  #print "($newpnt[0], $newpnt[1])\n";
  $poly->addPt($newpnt[0], $newpnt[1]);
}
$img->filledPolygon($poly,$bl);
}
}
my %clone_ribion;
my $shif_angle=60;
for my $clonkey (keys %clone_stack_cord){
  my %temclone = %{$clone_stack_cord{$clonkey}};
  #print Dumper \%temclone;
  my @all_ax = sort(keys %temclone);
  if (@all_ax == 1){
    continue;
  }
  if (@all_ax == 2){
    my ($ax1, $ax2)= @all_ax;
    my @ax1vari = @{$temclone{$ax1}};
    my @ax2vari = @{$temclone{$ax2}};
    my ($bs1x1,$bs1y1,$bs1x2,$bs1y2);
    my ($bs2x1,$bs2y1,$bs2x2,$bs2y2);
    my ($c1x,$b1x,$c2x,$b2x);
    if (($ax1 eq "a1") && ($ax2 ne "a2")){
            # @points = ($x1c1,$y1b1,$x1,$y1,$x1c2,$y1b2,$x2c2,$y2b2,$x2,$y2,$x2c1,$y2b1)
      #               0    1     2  3    4     5     6     7    8   9   10    11 
       ($c1x,$b1x,$c2x,$b2x) = ($ax1vari[0]-$ax1vari[2],$ax1vari[1]-$ax1vari[3],$ax1vari[4]-$ax1vari[2],$ax1vari[5]-$ax1vari[3]);
       
        my %tem1=('axis' => $ax1,
                  'im_size'=> [@defaul_im_size],
                  'cords'=> [$ax1vari[2],$ax1vari[3],$ax1vari[8],$ax1vari[9]],
                  'bcs' => [-$c1x,-$b1x,-$c2x,-$b2x],
                  'theta'=> $axs_ang{$ax1}[1],
                  'tranthe' => $axs_ang{$ax1}[1]-$shif_angle,
                  'shiftangele'=> $shif_angle);
        ($bs1x1,$bs1y1,$bs1x2,$bs1y2)=xytoradial::get_rib_cord(%tem1);
        
        ($c1x,$b1x,$c2x,$b2x) = ($ax2vari[0]-$ax2vari[2],$ax2vari[1]-$ax2vari[3],$ax2vari[4]-$ax2vari[2],$ax2vari[5]-$ax2vari[3]);
        my %tem2=('axis' => $ax2,
                  'im_size'=> [@defaul_im_size],
                  'cords'=> [$ax2vari[2],$ax2vari[3],$ax2vari[8],$ax2vari[9]],
                  'bcs' => [$c1x,$b1x,$c2x,$b2x],
                  'theta'=> $axs_ang{$ax2}[1],
                  'tranthe' => $axs_ang{$ax2}[1]+$shif_angle,
                  'shiftangele'=> $shif_angle);
        ($bs2x1,$bs2y1,$bs2x2,$bs2y2)=xytoradial::get_rib_cord(%tem2);
        my @points1;
        my $bezier1 = Math::Bezier->new($ax1vari[4],$ax1vari[5],$bs1x1,$bs1y1,$bs2x1,$bs2y1,$ax2vari[0],$ax2vari[1]);
        push @points1, ($ax1vari[4],$ax1vari[5]);
        push @points1, $bezier1->curve(100);
        push @points1, ($ax2vari[0],$ax2vari[1]);
        my @bezier_points;
        while (@points1) {
            push @bezier_points, [ splice( @points1, 0, 2 ) ];
        }
        #push @{$clone_ribion{$clonkey}{'rib1'}}, @points1;
        push @bezier_points, [$ax2vari[10],$ax2vari[11]];
        my @points2;
        my $bezier2 = Math::Bezier->new($ax2vari[10],$ax2vari[11],$bs2x2,$bs2y2,$bs1x2,$bs1y2,$ax1vari[6],$ax1vari[7]);
        
        push @points2, ($ax2vari[10],$ax2vari[11]);
        @points2=$bezier2->curve(100);
        push @points2, ($ax1vari[6],$ax1vari[7]);
        my @bezier2_points2;
        while (@points2) {
            push @bezier_points, [ splice( @points2, 0, 2 ) ];
        }
        push @{$clone_ribion{$clonkey}{'rib1'}}, @bezier_points;
        #push @{$clone_ribion{$clonkey}{'rib1'}},( @points1,@points2);
        #print "$ax1\t$tem1{'theta'}[1]\t$ax2\t$tem2{'theta'}[1]\n";
    }else{
      # @points = ($x1c1,$y1b1,$x1,$y1,$x1c2,$y1b2,$x2c2,$y2b2,$x2,$y2,$x2c1,$y2b1)
      #               0    1     2  3    4     5     6     7    8   9   10    11 
       ($c1x,$b1x,$c2x,$b2x) = ($ax1vari[0]-$ax1vari[2],$ax1vari[1]-$ax1vari[3],$ax1vari[4]-$ax1vari[2],$ax1vari[5]-$ax1vari[3]);
        my %tem1=('axis' => $ax1,
                  'im_size'=> [@defaul_im_size],
                  'cords'=> [$ax1vari[2],$ax1vari[3],$ax1vari[8],$ax1vari[9]],
                  'bcs' => [$c1x,$b1x,$c2x,$b2x],
                  'theta'=> $axs_ang{$ax1}[1],
                  'tranthe' => $axs_ang{$ax1}[1]+$shif_angle,
                  'shiftangele'=> $shif_angle);
        
        ($bs1x1,$bs1y1,$bs1x2,$bs1y2)=xytoradial::get_rib_cord(%tem1);
        
        ($c1x,$b1x,$c2x,$b2x) = ($ax2vari[0]-$ax2vari[2],$ax2vari[1]-$ax2vari[3],$ax2vari[4]-$ax2vari[2],$ax2vari[5]-$ax2vari[3]);
        my %tem2=('axis' => $ax2,
                  'im_size'=> [@defaul_im_size],
                  'cords'=> [$ax2vari[2],$ax2vari[3],$ax2vari[8],$ax2vari[9]],
                  'bcs' => [-$c1x,-$b1x,-$c2x,-$b2x],
                  'theta'=> $axs_ang{$ax2}[1],
                  'tranthe' => $axs_ang{$ax2}[1]-$shif_angle,
                  'shiftangele'=> $shif_angle);
        
        ($bs2x1,$bs2y1,$bs2x2,$bs2y2)=xytoradial::get_rib_cord(%tem2);
        my @points1;
        my $bezier1 = Math::Bezier->new($ax1vari[0],$ax1vari[1],$bs1x1,$bs1y1,$bs2x1,$bs2y1,$ax2vari[4],$ax2vari[5]);
        push @points1, ($ax1vari[0],$ax1vari[1]);
        push @points1, $bezier1->curve(100);
        push @points1, ($ax2vari[4],$ax2vari[5]);
        my @bezier_points;
        while (@points1) {
            push @bezier_points, [ splice( @points1, 0, 2 ) ];
        }
        #push @{$clone_ribion{$clonkey}{'rib1'}}, @points1;
        push @bezier_points, [$ax2vari[6],$ax2vari[7]];
        my @points2;
        my $bezier2 = Math::Bezier->new($ax2vari[6],$ax2vari[7],$bs2x2,$bs2y2,$bs1x2,$bs1y2,$ax1vari[10],$ax1vari[11]);
        
        push @points2, ($ax2vari[6],$ax2vari[7]);
        @points2=$bezier2->curve(100);
        push @points2, ($ax1vari[10],$ax1vari[11]);
        my @bezier2_points2;
        while (@points2) {
            push @bezier_points, [ splice( @points2, 0, 2 ) ];
        }
        push @{$clone_ribion{$clonkey}{'rib1'}}, @bezier_points;
        #push @{$clone_ribion{$clonkey}{'rib1'}},( @points1,@points2);
        #print "$ax1\t$tem1{'theta'}[1]\t$ax2\t$tem2{'theta'}[1]\n";
    }
  }
  if (@all_ax == 3){
    my %axishash=('a1a2'=> ['a1','a2'],
                  'a2a3'=> ['a2','a3'],
                  'a3a1'=> ['a1','a3']);
    for my $ribkey (keys %axishash){
    my ($ax1, $ax2)= @{$axishash{$ribkey}};  
    
    my @ax1vari = @{$temclone{$ax1}};
    my @ax2vari = @{$temclone{$ax2}};
    my ($bs1x1,$bs1y1,$bs1x2,$bs1y2);
    my ($bs2x1,$bs2y1,$bs2x2,$bs2y2);
    my ($c1x,$b1x,$c2x,$b2x);
    if (($ax1 eq "a1") && ($ax2 ne "a2")){
            # @points = ($x1c1,$y1b1,$x1,$y1,$x1c2,$y1b2,$x2c2,$y2b2,$x2,$y2,$x2c1,$y2b1)
      #               0    1     2  3    4     5     6     7    8   9   10    11 
       ($c1x,$b1x,$c2x,$b2x) = ($ax1vari[0]-$ax1vari[2],$ax1vari[1]-$ax1vari[3],$ax1vari[4]-$ax1vari[2],$ax1vari[5]-$ax1vari[3]);
        my %tem1=('axis' => $ax1,
                  'im_size'=> [@defaul_im_size],
                  'cords'=> [$ax1vari[2],$ax1vari[3],$ax1vari[8],$ax1vari[9]],
                  'bcs' => [-$c1x,-$b1x,-$c2x,-$b2x],
                  'theta'=> $axs_ang{$ax1}[1],
                  'tranthe' => $axs_ang{$ax1}[1]-$shif_angle,
                  'shiftangele'=> $shif_angle);
        ($bs1x1,$bs1y1,$bs1x2,$bs1y2)=xytoradial::get_rib_cord(%tem1);
        
        ($c1x,$b1x,$c2x,$b2x) = ($ax2vari[0]-$ax2vari[2],$ax2vari[1]-$ax2vari[3],$ax2vari[4]-$ax2vari[2],$ax2vari[5]-$ax2vari[3]);
        my %tem2=('axis' => $ax2,
                  'im_size'=> [@defaul_im_size],
                  'cords'=> [$ax2vari[2],$ax2vari[3],$ax2vari[8],$ax2vari[9]],
                  'bcs' => [$c1x,$b1x,$c2x,$b2x],
                  'theta'=> $axs_ang{$ax2}[1],
                  'tranthe' => $axs_ang{$ax2}[1]+$shif_angle,
                  'shiftangele'=> $shif_angle);
        ($bs2x1,$bs2y1,$bs2x2,$bs2y2)=xytoradial::get_rib_cord(%tem2);
        my @points1;
        my $bezier1 = Math::Bezier->new($ax1vari[4],$ax1vari[5],$bs1x1,$bs1y1,$bs2x1,$bs2y1,$ax2vari[0],$ax2vari[1]);
        push @points1, ($ax1vari[4],$ax1vari[5]);
        push @points1, $bezier1->curve(100);
        push @points1, ($ax2vari[0],$ax2vari[1]);
        my @bezier_points;
        while (@points1) {
            push @bezier_points, [ splice( @points1, 0, 2 ) ];
        }
        #push @{$clone_ribion{$clonkey}{'rib1'}}, @points1;
        push @bezier_points, [$ax2vari[10],$ax2vari[11]];
        my @points2;
        my $bezier2 = Math::Bezier->new($ax2vari[10],$ax2vari[11],$bs2x2,$bs2y2,$bs1x2,$bs1y2,$ax1vari[6],$ax1vari[7]);
        
        push @points2, ($ax2vari[10],$ax2vari[11]);
        @points2=$bezier2->curve(100);
        push @points2, ($ax1vari[6],$ax1vari[7]);
        my @bezier2_points2;
        while (@points2) {
            push @bezier_points, [ splice( @points2, 0, 2 ) ];
        }
        push @{$clone_ribion{$clonkey}{$ribkey}}, @bezier_points;
        #push @{$clone_ribion{$clonkey}{'rib1'}},( @points1,@points2);
        #print "$ax1\t$tem1{'theta'}[1]\t$ax2\t$tem2{'theta'}[1]\n";
    }else{
      # @points = ($x1c1,$y1b1,$x1,$y1,$x1c2,$y1b2,$x2c2,$y2b2,$x2,$y2,$x2c1,$y2b1)
      #               0    1     2  3    4     5     6     7    8   9   10    11 
       ($c1x,$b1x,$c2x,$b2x) = ($ax1vari[0]-$ax1vari[2],$ax1vari[1]-$ax1vari[3],$ax1vari[4]-$ax1vari[2],$ax1vari[5]-$ax1vari[3]);
        my %tem1=('axis' => $ax1,
                  'im_size'=> [@defaul_im_size],
                  'cords'=> [$ax1vari[2],$ax1vari[3],$ax1vari[8],$ax1vari[9]],
                  'bcs' => [$c1x,$b1x,$c2x,$b2x],
                  'theta'=> $axs_ang{$ax1}[1],
                  'tranthe' => $axs_ang{$ax1}[1]+$shif_angle,
                  'shiftangele'=> $shif_angle);
        
        ($bs1x1,$bs1y1,$bs1x2,$bs1y2)=xytoradial::get_rib_cord(%tem1);
        
        ($c1x,$b1x,$c2x,$b2x) = ($ax2vari[0]-$ax2vari[2],$ax2vari[1]-$ax2vari[3],$ax2vari[4]-$ax2vari[2],$ax2vari[5]-$ax2vari[3]);
        my %tem2=('axis' => $ax2,
                  'im_size'=> [@defaul_im_size],
                  'cords'=> [$ax2vari[2],$ax2vari[3],$ax2vari[8],$ax2vari[9]],
                  'bcs' => [-$c1x,-$b1x,-$c2x,-$b2x],
                  'theta'=> $axs_ang{$ax2}[1],
                  'tranthe' => $axs_ang{$ax2}[1]-$shif_angle,
                  'shiftangele'=> $shif_angle);
        
        ($bs2x1,$bs2y1,$bs2x2,$bs2y2)=xytoradial::get_rib_cord(%tem2);
        my @points1;
        my $bezier1 = Math::Bezier->new($ax1vari[0],$ax1vari[1],$bs1x1,$bs1y1,$bs2x1,$bs2y1,$ax2vari[4],$ax2vari[5]);
        push @points1, ($ax1vari[0],$ax1vari[1]);
        push @points1, $bezier1->curve(100);
        push @points1, ($ax2vari[4],$ax2vari[5]);
        my @bezier_points;
        while (@points1) {
            push @bezier_points, [ splice( @points1, 0, 2 ) ];
        }
        #push @{$clone_ribion{$clonkey}{'rib1'}}, @points1;
        push @bezier_points, [$ax2vari[6],$ax2vari[7]];
        my @points2;
        my $bezier2 = Math::Bezier->new($ax2vari[6],$ax2vari[7],$bs2x2,$bs2y2,$bs1x2,$bs1y2,$ax1vari[10],$ax1vari[11]);
        
        push @points2, ($ax2vari[6],$ax2vari[7]);
        @points2=$bezier2->curve(100);
        push @points2, ($ax1vari[10],$ax1vari[11]);
        my @bezier2_points2;
        while (@points2) {
            push @bezier_points, [ splice( @points2, 0, 2 ) ];
        }
        push @{$clone_ribion{$clonkey}{$ribkey}}, @bezier_points;
        #push @{$clone_ribion{$clonkey}{'rib1'}},( @points1,@points2);
        #print "$ax1\t$tem1{'theta'}[1]\t$ax2\t$tem2{'theta'}[1]\n";
    }
    }

  }
  #print Dumper \@all_ax;
  
}
#print Dumper \%clone_ribion;
my $alpha=90;
$img ->setThickness(0);
for my $keyclo (keys %clone_ribion){
my %xtemhash = %{$clone_ribion{$keyclo}};
for my $rib (keys %xtemhash){
my @newtemarray = @{$xtemhash{$rib}};
my $bl = $img->colorAllocateAlpha(@{$clone_color_code{$keyclo}},$alpha);
my $poly = new GD::Polygon;

while (@newtemarray){
my @newploypt = splice(splice(@newtemarray, 0,2), 0,2); 
$poly->addPt($newploypt[0], $newploypt[1]);

}
$img->filledPolygon($poly,$bl);
}
}
#drawimage::circ_out(($defaul_im_size[0],$defaul_im_size[1],$inner_cir,$outer_cir,$img));
drawimage::write_img($img);



=code




my $filename1 = 'line_data.txt';
open(my $fh1, '<:encoding(UTF-8)', $filename1)
  or die "Could not open file '$filename1' $!";
my %line_hash;
while (my $row = <$fh1>) {
  chomp $row;
  @rowarray= split /\s+/,$row;
  #print Dumper \@rowarray;
  push @{$line_hash{$rowarray[0]}}, @rowarray[1..$#rowarray];
  #$point_data{$rowarray[0]}{$rowarray[1]}= \@rowarray;
  
}
#print Dumper \%line_hash;
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
                  'theta'=> $axs_ang{$tkey});
    
    my ($tempx,$tempy)=xytoradial::get_xy_loc(%tem1);
    push @line_cord, ($tempx,$tempy);
    push @{$line_axis_xy{$lkey}{$tkey}},($defaul_im_size[0],$defaul_im_size[1],$tempx,$tempy,$nval,$axs_ang{$tkey}[1]); 
  }
  my $bezier = Math::Bezier->new(drawimage::draw_curv_lines(%{$line_axis_xy{$lkey}}));
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
 


