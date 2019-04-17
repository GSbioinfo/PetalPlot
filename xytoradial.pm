package xytoradial;
use Data::Dumper qw(Dumper);
use POSIX;
our $RAD2DEG = 57.29577951;
sub get_axis_angles{
    my %axis_hash= @_;
    my $num_axis= keys %axis_hash;

    #print "$num_axis\n";
    if ($num_axis<3) {
    die "Number of axis are less than 3";
    }
    if ($num_axis==3) {
        my %axis_angle=(a1=> [1,-90], 
                        a2 => [2,30],
                        a3 => [3,150]);
        return %axis_angle;
    }
    if ($num_axis==4) {
        my %axis_angle=(a1=> -45, 
                        a2 => 45,
                        a3 => 135,
                        a4 => 225);
        return %axis_angle;
    }
}
sub normal{
    my @val=@_;

}
sub get_xy_loc{
    my %point_values= @_;
    my $c1= $point_values{'im_size'}[0]/2;
    my $c2= $point_values{'im_size'}[1]/2;
    my $rval = $point_values{'value'};
    my $theta= $point_values{'theta'}[1]/$RAD2DEG;
    my $yic= floor($c1+ $rval*sin($theta));
    my $xic= floor($c2+ $rval*cos($theta));
    return ($xic,$yic);
}
sub get_xy_loc2{
    my %point_values= @_;
    my $c1= $point_values{'im_size'}[0]/2;
    my $c2= $point_values{'im_size'}[1]/2;
    my $xrval = $point_values{'value'};
    my $theta= $point_values{'theta'}[1];
    my $rval=$xrval;#/cos($theta/$RAD2DEG);
    my $yic= floor($c1+ $rval*sin($theta/$RAD2DEG));
    my $xic= floor($c2+ $rval*cos($theta/$RAD2DEG));
    return ($xic,$yic);
}
sub get_axis_xy{
    my %point_values= @_;
    my $c1= $point_values{'im_size'}[0]/2;
    my $c2= $point_values{'im_size'}[1]/2;
    my $rval1 = $point_values{'value'}[0];
    my $rval2 = $point_values{'value'}[1];
    my $theta= $point_values{'theta'}/$RAD2DEG;
    my $y1= floor($c1+ $rval1*sin($theta));
    my $x1= floor($c2+ $rval1*cos($theta));
    my $y2= floor($c1+ $rval2*sin($theta));
    my $x2= floor($c2+ $rval2*cos($theta));
    return ($x1,$y1,$x2,$y2);
}

sub get_stack_cord{
    my %point_values= @_;
    my $a1= $point_values{'im_size'}[0]/2;
    my $a2= $point_values{'im_size'}[1]/2;
    my $rval1 = $point_values{'value'}[0];
    my $rval2 = $point_values{'value'}[1];
    my $theta= $point_values{'theta'}/$RAD2DEG;
    my $thick= $point_values{'width'};
    my $y1= floor($a1+ $rval1*sin($theta));
    my $x1= floor($a2+ $rval1*cos($theta));
    my $y2= floor($a1+ $rval2*sin($theta));
    my $x2= floor($a2+ $rval2*cos($theta));
    my $thet1= $point_values{'theta'}+90;
    my $thet2= $point_values{'theta'}-90;
    my $c1= $thick*cos($thet1/$RAD2DEG);
    my $b1= -$thick*sin($thet2/$RAD2DEG);
    my $c2= $thick*cos($thet2/$RAD2DEG);
    my $b2= -$thick*sin($thet1/$RAD2DEG);
    my $x1c1=floor($x1+$c1);
    my $y1b1=floor($y1+$b1);
    my $x1c2=floor($x1+$c2);
    my $y1b2=floor($y1+$b2);
    my $x2c1=floor($x2+$c1);
    my $y2b1=floor($y2+$b1);
    my $x2c2=floor($x2+$c2);
    my $y2b2=floor($y2+$b2);
    #print "($c1,$b1,$c2,$b2)\n";
    #return ($x1c1,$y1b1,$x2c1,$y2b1,$x1,$y1,$x1c2,$y1b2,$x2,$y2,$x2c2,$y2b2,$x1c1,$y1b1);
    return ($x1c1,$y1b1,$x1,$y1,$x1c2,$y1b2,$x2c2,$y2b2,$x2,$y2,$x2c1,$y2b1);
}

sub get_baz_cb{
    my %point_values= @_;
    
    my $a1= $point_values{'im_size'}[0]/2;
    my $a2= $point_values{'im_size'}[1]/2;
    my $rval1 = $point_values{'value'};
    my $theta= $point_values{'theta'}/$RAD2DEG;
    my $thick= $point_values{'width'};
    my $y1= floor($a1+ $rval1*sin($theta));
    my $x1= floor($a2+ $rval1*cos($theta));
    #my $y2= floor($a1+ $rval2*sin($theta));
    #my $x2= floor($a2+ $rval2*cos($theta));
    my $thet1= $point_values{'theta'}+90;
    my $thet2= $point_values{'theta'}-90;
    my $c1= $thick*cos($thet1/$RAD2DEG);
    my $b1= -$thick*sin($thet2/$RAD2DEG);
    my $c2= $thick*cos($thet2/$RAD2DEG);
    my $b2= -$thick*sin($thet1/$RAD2DEG);
    my $x1c1=floor($x1+$c1);
    my $y1b1=floor($y1+$b1);
    my $x1c2=floor($x1+$c2);
    my $y1b2=floor($y1+$b2);
    #my $x2c1=$x2+$c1;
    #my $y2b1=$y2+$b1;
    #my $x2c2=$x2+$c2;
    #my $y2b2=$y2+$b2;
    #print "($c1,$b1,$c2,$b2)\n";
    #return ($x1c1,$y1b1,$x2c1,$y2b1,$x1,$y1,$x1c2,$y1b2,$x2,$y2,$x2c2,$y2b2,$x1c1,$y1b1);
    return ($x1,$y1,$x1c1,$y1b1,$x1c2,$y1b2);
}

sub centre_curv_lines{
    my %lhash = @_;
    my ($bsx1,$bsy1);
    my ($bsx2,$bsy2);
    my ($x1,$y1);
    #print Dumper \%lhash;
    my ($ax1,$ax2)=sort(keys %lhash);
    my @ax1vari=@{$lhash{$ax1}};
    my @ax2vari=@{$lhash{$ax2}};
    my $bez_angle=0;
    if (($ax1 eq "a1") && ($ax2 ne "a2")){
        my %tem1=('im_size'=> [$ax1vari[0],$ax1vari[1]],
                  'value'=> $ax1vari[4],
                  'theta'=> [0,$ax1vari[5]]);
        my $y1= floor($a1+ $rval1*sin($theta));
        my $x1= floor($a2+ $rval1*cos($theta));
        ($bsx1,$bsy1)=xytoradial::get_xy_loc2(%tem1);
        my %tem2=('im_size'=> [$ax2vari[0],$ax2vari[1]],
                  'value'=> $ax2vari[4],
                  'theta'=> [0,$ax2vari[5]]);
        ($bsx2,$bsy2)=xytoradial::get_xy_loc2(%tem2);
        
    }else{
       my %tem1=('im_size'=> [$ax1vari[0],$ax1vari[1]],
                  'value'=> $ax1vari[4],
                  'theta'=> [0,$ax1vari[5]]);
        ($bsx1,$bsy1)=xytoradial::get_xy_loc2(%tem1);
        my %tem2=('im_size'=> [$ax2vari[0],$ax2vari[1]],
                  'value'=> $ax2vari[4],
                  'theta'=> [0,$ax2vari[5]]);
        ($bsx2,$bsy2)=xytoradial::get_xy_loc2(%tem2); 
        #print "$ax1\t$tem1{'theta'}[1]\t$ax2\t$tem2{'theta'}[1]\n";
    }
    #print "$ax1vari[2]\t$ax1vari[3]\t$bsx1\t$bsy1\t$bsx2\t$bsy2\t$ax2vari[2]\t$ax2vari[3]\n";
return ($ax1vari[2],$ax1vari[3],$bsx1,$bsy1,$bsx2,$bsy2,$ax2vari[2],$ax2vari[3]);
}


sub get_rib_cord{
   my %ribhash = @_;
   my %reter_hash;
   my @x1y1;
   my @x2y2;
   #print Dumper \%ribhash;
#my %tem1=('im_size'=> [@defaul_im_size],
#                  'cords'=> [$ax1vari[2],$ax1vari[3],$ax1vari[8],$ax1vari[9]],
#                  'bcs' => [$c1x,$b1x,$c2x,$b2x]
#                  'theta'=> $axs_ang{$ax1}[1]
#                   'tranthe' => 60
#                   'shiftangele'=> 60);
    #print Dumper \%ribhash;
    my $fact = $ribhash{'factor'};
    my $steps = $ribhash{'steps'};
    my $a1= $ribhash{'im_size'}[0]/2;
    my $a2= $ribhash{'im_size'}[1]/2;
    my ($x1,$y1,$x2,$y2)=@{$ribhash{'cords'}};
    my ($c1,$b1,$c2,$b2)=@{$ribhash{'bcs'}};
    my $th = $ribhash{'theta'};
    my $stheta1= $ribhash{'tranthe'};
    my $shangle = $ribhash{'shiftangele'};
    my $st_dist = $ribhash{'width'};
    
    my $step_angle= $shangle/$steps;
    my @ang_range= map{$step_angle*$_}1 ..$steps;
    my $rval1;
    my $rval2;
    
    if (abs($th)==90){
    $rval1 = floor(($y1-$a1)/sin($th/$RAD2DEG));
    $rval2 = floor(($y2-$a1)/sin($th/$RAD2DEG));   
    }else{
    $rval1 = floor(($x1-$a2)/cos($th/$RAD2DEG));
    $rval2 = floor(($x2-$a2)/cos($th/$RAD2DEG));
    }
    my $newr1 = floor($rval1/cos($sang/$RAD2DEG));
    my $newr2 = floor($rval2/cos($sang/$RAD2DEG));
    while (@ang_range){
        my $sang =shift(@ang_range);
        my $stheta = $stheta1+ ($fact*$sang);
        #print "$sang\t$stheta\t$fact\n";
        $newr1=$newr1+15;
        $newr2=$newr2+15;
    
    #print "$rval1\t$newr1\n";
        my ($bsx1,$bsy1,$bsx2,$bsy2);
        $bsx1 = floor($a2+ $newr1*cos($stheta/$RAD2DEG));#floor($x1+($c1));
        $bsy1 = floor($a1+ $newr1*sin($stheta/$RAD2DEG));#floor($y1+($b1));
        $bsx2 = floor($a2+ $newr2*cos($stheta/$RAD2DEG));#floor($x2+($c1));
        $bsy2 = floor($a1+ $newr2*sin($stheta/$RAD2DEG));#floor($y2+($b1));
        my $dis1 = sqrt(($bsx1-$x1)**2+($bsy1-$y1)**2);
        my $dis2 = sqrt(($bsx2-$x2)**2+($bsy2-$y2)**2);
        
    if ($fact == 1){
        
        push @x1y1,($bsx1,$bsy1);
        
        unshift @x2y2,($bsx2,$bsy2);
        
    }else{
        
        unshift @x1y1,($bsx1,$bsy1);
        
        push @x2y2,($bsx2,$bsy2);
         
    }
    
    }
    %reter_hash=('x1y1'=> [@x1y1],
                'x2y2'=> [@x2y2]);
    return %reter_hash;
}
sub get_rib_corda3a1{
   my %ribhash = @_;
   my %reter_hash;
   my @x1y1;
   my @x2y2;
   #print Dumper \%ribhash;
#my %tem1=('im_size'=> [@defaul_im_size],
#                  'cords'=> [$ax1vari[2],$ax1vari[3],$ax1vari[8],$ax1vari[9]],
#                  'bcs' => [$c1x,$b1x,$c2x,$b2x]
#                  'theta'=> $axs_ang{$ax1}[1]
#                   'tranthe' => 60
#                   'shiftangele'=> 60);
    #print Dumper \%ribhash;
    my $fact = $ribhash{'factor'};
    my $steps = $ribhash{'steps'};
    my $a1= $ribhash{'im_size'}[0]/2;
    my $a2= $ribhash{'im_size'}[1]/2;
    my ($x1,$y1,$x2,$y2)=@{$ribhash{'cords'}};
    my ($c1,$b1,$c2,$b2)=@{$ribhash{'bcs'}};
    my $th = $ribhash{'theta'};
    my $stheta1= $ribhash{'tranthe'};
    my $shangle = $ribhash{'shiftangele'};
    
    my $step_angle= $shangle/$steps;
    my @ang_range= map{$step_angle*$_}1..$steps;
    my $rval1;
    my $rval2;
    
    if (abs($th)==90){
    $rval1 = floor(($y1-$a1)/sin($th/$RAD2DEG));
    $rval2 = floor(($y2-$a1)/sin($th/$RAD2DEG));   
    }else{
    $rval1 = floor(($x1-$a2)/cos($th/$RAD2DEG));
    $rval2 = floor(($x2-$a2)/cos($th/$RAD2DEG));
    }
    my $newr1 = floor($rval1/cos($sang/$RAD2DEG));
    my $newr2 = floor($rval2/cos($sang/$RAD2DEG));
    while (@ang_range){
        my $sang =shift(@ang_range);
        my $stheta = $stheta1+ ($fact*$sang);
        #print "$sang\t$stheta\t$fact\n";
        $newr1=$newr1+15;
        $newr2=$newr2+15;
    
    #print "$rval1\t$newr1\n";
        my ($bsx1,$bsy1,$bsx2,$bsy2);
        $bsx1 = floor($a2+ $newr1*cos($stheta/$RAD2DEG));#floor($x1+($c1));
        $bsy1 = floor($a1+ $newr1*sin($stheta/$RAD2DEG));#floor($y1+($b1));
        $bsx2 = floor($a2+ $newr2*cos($stheta/$RAD2DEG));#floor($x2+($c1));
        $bsy2 = floor($a1+ $newr2*sin($stheta/$RAD2DEG));#floor($y2+($b1));
        
    
    if ($fact == -1){
        push @x1y1,($bsx1,$bsy1);
        unshift @x2y2,($bsx2,$bsy2);
        
        
    }else{
        unshift @x1y1,($bsx1,$bsy1);
        push @x2y2,($bsx2,$bsy2);
        
    }
    }
    %reter_hash=('x1y1'=> [@x1y1],
                'x2y2'=> [@x2y2]);
    return %reter_hash;
}
sub get_rib_cord_old{
   my %ribhash = @_;
   #print Dumper \%ribhash;
#my %tem1=('im_size'=> [@defaul_im_size],
#                  'cords'=> [$ax1vari[2],$ax1vari[3],$ax1vari[8],$ax1vari[9]],
#                  'bcs' => [$c1x,$b1x,$c2x,$b2x]
#                  'theta'=> $axs_ang{$ax1}[1]
#                   'tranthe' => 60
#                   'shiftangele'=> 60);
    #print Dumper \%ribhash;
    my $a1= $ribhash{'im_size'}[0]/2;
    my $a2= $ribhash{'im_size'}[1]/2;
    my ($x1,$y1,$x2,$y2)=@{$ribhash{'cords'}};
    my ($c1,$b1,$c2,$b2)=@{$ribhash{'bcs'}};
    my $th = $ribhash{'theta'};
    my $stheta= $ribhash{'tranthe'};
    my $shangle = $ribhash{'shiftangele'};
    my $rval1;
    my $rval2;
    if (abs($th)==90){
    $rval1 = floor(($y1-$a1)/sin($th/$RAD2DEG));
    $rval2 = floor(($y2-$a1)/sin($th/$RAD2DEG));   
    }else{
    $rval1 = floor(($x1-$a2)/cos($th/$RAD2DEG));
    $rval2 = floor(($x2-$a2)/cos($th/$RAD2DEG));
    }
    my $newr1 = floor($rval1/cos($shangle/$RAD2DEG));
    my $newr2 = floor($rval2/cos($shangle/$RAD2DEG));
    
    #print "$rval1\t$newr1\n";
    my ($bsx1,$bsy1,$bsx2,$bsy2);
    $bsx1 = floor($a2+ $newr1*cos($stheta/$RAD2DEG));#floor($x1+($c1));
    $bsy1 = floor($a1+ $newr1*sin($stheta/$RAD2DEG));#floor($y1+($b1));
    $bsx2 = floor($a2+ $newr2*cos($stheta/$RAD2DEG));#floor($x2+($c1));
    $bsy2 = floor($a1+ $newr2*sin($stheta/$RAD2DEG));#floor($y2+($b1));
    return ($bsx1,$bsy1,$bsx2,$bsy2);

}
1;