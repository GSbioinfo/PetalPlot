package drawimage;
use GD::Image; 
use GD::SVG;
use Data::Dumper qw(Dumper);
use GD::Simple;
# create a new image
sub createimage{
my @def_size=@_;

#my $im = GD::Image->new($def_size[0],$def_size[1]);
my $im = GD::SVG::Image->new($def_size[0],$def_size[1]);
# allocate some colors
my $white = $im->colorAllocate(255,255,255);
my $black = $im->colorAllocate(0,0,0);       
my $red = $im->colorAllocate(255,0,0);      
my $blue = $im->colorAllocate(0,0,255);
 
# make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');
 
# Put a black frame around the picture
#$im->rectangle(0,0,99,99,$black);
 
# Draw a blue oval
#$im->arc(50,50,100,100,-90,0,$blue);
 
# And fill it with red
#$im->fill(50,50,$red);
 

 
# Convert the image to PNG and print it on standard output
return $im;

}
sub circ_out{
my ($x,$y,$in,$ou,$im)=@_;
#my $black = $im->colorAllocate(0,0,0); 
# Create a brush at an angle
#my $diagonal_brush = new GD::Image(5,5);
#my $white = $diagonal_brush->colorAllocate(255,255,255);
#my $black = $diagonal_brush->colorAllocate(0,0,0);
#$diagonal_brush->transparent($white);
#$diagonal_brush->line(0,0,1,1,$black); # NE diagonal
my $white = $im->colorAllocate(255,255,255);
my $black = $im->colorAllocate(0,0,0);
my $gray = $im->colorAllocateAlpha(127,127,127,60);
#$im->setStyle($white,$white,$white,$white,$white,$white,$white,
#                   $black,$black,
#                   gdTransparent,gdTransparent);
$im ->setThickness(1);
#$im->setStyle($black,
#                   gdTransparent,gdTransparent);                   
#$im->setBrush($diagonal_brush);
my $spce= ($ou-$in)/3;
for (my $ix=0; $ix <= 3; $ix++){
    my $hei=$in+($spce*$ix);
#$im->arc($x/2,$y/2,$hei*2,$hei*2,0,360,gdStyled);
$im->arc($x/2,$y/2,$hei*2,$hei*2,0,360,$black);
#$im->arc($x/2,$y/2,100,100,0,360,$gray);
}
}

sub addPnt{
my ($x,$y,$col,$crs,$im)=@_;

my $blue = $im->colorAllocate(mycolors::findcolor($col));
my $white = $im->colorAllocate(mycolors::findcolor("white"));
if($crs==1){
$im->filledArc($x,$y,20,20,0,360,$blue);
$im->filledArc($x,$y,10,10,0,360,$white);
}
else{
$im->filledArc($x,$y,20,20,0,360,$blue);  
}
#$im->fill($x,$y,$blue);
}

sub write_img{
my @im_wite = @_;
my $ofile=$im_wite[0];
my $im=$im_wite[1];
#open my $out, '>', 'stack.png' or die;
#open my $out, '>', 'stack.jpeg' or die;
open my $out, '>', $ofile or die;#'CD3_ribbon.svg' or die;
binmode $out;
#print $out $im->png();
#print $out $im->jpeg(95);
print $out $im->svg();
close $out;
}


sub axisdraw{

my ($def_size1,$def_size2,$outer_axis,$inner_axis,$angle,$im)=@_;

my %temhash=('im_size'=> [$def_size1,$def_size2],
                  'value'=> [$inner_axis,$outer_axis],
                  'theta'=> $angle);

my ($x1,$y1,$x2,$y2)=xytoradial::get_axis_xy(%temhash);

return ($x1,$y1,$x2,$y2);
#$im->line($x1,$y1,$x2,$y2,$blue);
#$im->fill($x,$y,$blue);
}
sub draw_line{
    my ($im, $imc, $u, $v, $color, $thickness) = @_;
}
sub draw_curv_lines{
    my %lhash = @_;
    my ($bsx1,$bsy1);
    my ($bsx2,$bsy2);
    #print Dumper \%lhash;
    my ($ax1,$ax2)=sort(keys %lhash);
    my @ax1vari=@{$lhash{$ax1}};
    my @ax2vari=@{$lhash{$ax2}};
    my $bez_angle=30;
    if (($ax1 eq "a1") && ($ax2 ne "a2")){
        my %tem1=('im_size'=> [$ax1vari[0],$ax1vari[1]],
                  'value'=> $ax1vari[4],
                  'theta'=> [0,$ax1vari[5]-$bez_angle]);
        ($bsx1,$bsy1)=xytoradial::get_xy_loc2(%tem1);
        my %tem2=('im_size'=> [$ax2vari[0],$ax2vari[1]],
                  'value'=> $ax2vari[4],
                  'theta'=> [0,$ax2vari[5]+$bez_angle]);
        ($bsx2,$bsy2)=xytoradial::get_xy_loc2(%tem2);
        
    }else{
       my %tem1=('im_size'=> [$ax1vari[0],$ax1vari[1]],
                  'value'=> $ax1vari[4],
                  'theta'=> [0,$ax1vari[5]+$bez_angle]);
        ($bsx1,$bsy1)=xytoradial::get_xy_loc2(%tem1);
        my %tem2=('im_size'=> [$ax2vari[0],$ax2vari[1]],
                  'value'=> $ax2vari[4],
                  'theta'=> [0,$ax2vari[5]-$bez_angle]);
        ($bsx2,$bsy2)=xytoradial::get_xy_loc2(%tem2); 
        #print "$ax1\t$tem1{'theta'}[1]\t$ax2\t$tem2{'theta'}[1]\n";
    }
    #print "$ax1vari[2]\t$ax1vari[3]\t$bsx1\t$bsy1\t$bsx2\t$bsy2\t$ax2vari[2]\t$ax2vari[3]\n";
return ($ax1vari[2],$ax1vari[3],$bsx1,$bsy1,$bsx2,$bsy2,$ax2vari[2],$ax2vari[3]);
}
sub draw_curv_lines2{
    my %lhash = @_;
    my ($bsx1,$bsy1);
    my ($bsx2,$bsy2);
    
    my ($ax1,$ax2)=sort(keys %lhash);
    my @ax1vari=@{$lhash{$ax1}};
    my @ax2vari=@{$lhash{$ax2}};
    my $bez_angle=30;
    
    if (($ax1 eq "a1") && ($ax2 ne "a2")){
        my %tem1=('im_size'=> [$ax1vari[0],$ax1vari[1]],
                  'value'=> $ax1vari[4],
                  'theta'=> [0,$ax1vari[5]-$bez_angle]);
        ($bsx1,$bsy1)=($ax1vari[6],$ax1vari[7]);
        my %tem2=('im_size'=> [$ax2vari[0],$ax2vari[1]],
                  'value'=> $ax2vari[4],
                  'theta'=> [0,$ax2vari[5]+$bez_angle]);
        ($bsx2,$bsy2)=($ax2vari[4],$ax2vari[5]);
    #print "($ax1vari[2],$ax1vari[3],$bsx1,$bsy1,$bsx2,$bsy2,$ax2vari[4],$ax2vari[5])\n";
        
    }else{
       my %tem1=('im_size'=> [$ax1vari[0],$ax1vari[1]],
                  'value'=> $ax1vari[4],
                  'theta'=> [0,$ax1vari[5]+$bez_angle]);
        ($bsx1,$bsy1)=($ax1vari[4],$ax1vari[5]);
        my %tem2=('im_size'=> [$ax2vari[0],$ax2vari[1]],
                  'value'=> $ax2vari[4],
                  'theta'=> [0,$ax2vari[5]-$bez_angle]);
        ($bsx2,$bsy2)=($ax2vari[6],$ax2vari[7]);
        #print "$ax1\t$tem1{'theta'}[1]\t$ax2\t$tem2{'theta'}[1]\n";
    
    }
    return ($ax1vari[2],$ax1vari[3],$bsx1,$bsy1,$bsx2,$bsy2,$ax2vari[2],$ax2vari[3]);
    #print "$ax1vari[2]\t$ax1vari[3]\t$bsx1\t$bsy1\t$bsx2\t$bsy2\t$ax2vari[2]\t$ax2vari[3]\n";

}
sub draw_stack{
    my %stack_x=@_;
    my ($bsx1,$bsy1);
    my ($bsx2,$bsy2);
    my ($bsx3,$bsy3);
    my ($bsx4,$bsy4);
}
1;