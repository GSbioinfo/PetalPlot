=cod
my ($x1,$y1,$x2,$y2)=@line_cord;
  
  drawimage::draw_lines(($x1,$y1,$x2,$y2,$axs_ang{$outkey}))
  
  print Dumper \@line_cord;


my $bl=$img->colorAllocate(mycolors::findcolor($colr));
  if($crs==1){
    my $wht=$img->colorAllocate(mycolors::findcolor("white"));
    $img->setStyle($bl,$bl,$bl,$bl,
                   $wht,$wht,$wht,
                   gdTransparent,gdTransparent);
    for my $iz 
    $img->line($x1,$y1,$x2,$y2,gdStyled);
  }else{
    $img->line($x1,$y1,$x2,$y2,$bl);
  }


  if($crs==1){
    my $wht=$img->colorAllocate(mycolors::findcolor("white"));
    $img->setStyle($bl,$bl,$bl,$bl,
                   $wht,$wht,$wht,
                   gdTransparent,gdTransparent);
    for my $iz (0 .. @$bezier_points-2){ 
    $img->line($bezier_points[$iz], $bezier_points[ $iz + 1 ],gdStyled);
    }
  }else{
    for my $iz (0 .. @$bezier_points-2){
    $img->line($bezier_points$iz], $bezier_points[ $iz + 1 ],,$bl);
    }
  }