library(RColorBrewer)
library(reshape2)
library(Hmisc)
scalmaxf<- function(x){
  if(x >= 0.1){
    y=seq(0,1,by=0.05)[findInterval(x,seq(0,1,by=0.05))+1]
  }
  else{
    y=seq(0,0.1,by=0.005)[findInterval(x,seq(0,0.1,by=0.005))+1] 
  }
  return(y)
}
#Data is from animal ZJ31 https://pubmed.ncbi.nlm.nih.gov/28087539/
set.seed(123)
tcr_data<- read.delim("Data_for_petalplot.tsv",header = T,sep = ",")
row.names(tcr_data)<- tcr_data$X
tcr_data<- tcr_data[,-1]
tcr_data_sele<- tcr_data[,grepl("[.]T|[.]B|[.]Gr|[.][M,m]ono",names(tcr_data))]
max_all<- max(colSums(tcr_data_sele))
#tcr_data_sele<- tcr_data[,!grepl("Mono",names(tcr_data))]
tcr_data_sele<- tcr_data_sele[order(tcr_data_sele$X20m.Gr),]
tcr_data_sele$CLONE_ID<- paste0("CLONE",sprintf("%0.4d",seq(1,length(tcr_data_sele$X1m.T))))
tcr_data_sele$COLOR<- rep(brewer.pal(12, "Paired"),length(tcr_data_sele$CLONE_ID)/10)[seq(1,length(tcr_data_sele$CLONE_ID))]
rownames(tcr_data_sele)<- tcr_data_sele$CLONE_ID
months<- paste0(gsub("m[.].*","",gsub("X|T.*","",names(tcr_data_sele[,grepl("[.]T",names(tcr_data_sele))]))),"m")
gtb_clones2<- tcr_data_sele[,c(grep("X2m",names(tcr_data_sele)))]
monmax<- data.frame(matrix(nrow = 0,ncol = 3))
names(monmax)<- c("Month","Maxval","ScaleMax")
for(mon in months){
  
if(grepl("3",mon)){
  xmon=paste0("X","3")
}else{
  xmon=paste0("X",mon)
}
gtb_clones2<- tcr_data_sele[,c(grep(xmon,names(tcr_data_sele)))]
  
if(sum(grep("[.][M,m]ono",names(gtb_clones2)))>0){
    gtb_clones2$GM<- pmax(gtb_clones2[,grep("[.][M,m]ono",names(gtb_clones2))],gtb_clones2[,grep("[.]Gr",names(gtb_clones2))])
}else{
    gtb_clones2$GM<- gtb_clones2[,grep("[.]Gr",names(gtb_clones2))]
}
gtb_clones2<- gtb_clones2[,!grepl("[.]Gr|[.][M,m]ono",names(gtb_clones2))]

names(gtb_clones2)<- c("T","B","GM")
gtb_clones2<- gtb_clones2[,c("GM","T","B")]
maxval<- data.frame(maxv=c(colSums(gtb_clones2)))

maxval$TIS<- rownames(maxval)
#maxval<- cbind(maxval,scalmax=unlist(lapply(maxval$maxv,function(x)scalmaxf(x))))
mval<- max(maxval$maxv)
mval<- scalmaxf(mval)
maxval$Rmax<- mval#round(maxval$maxv,digits = 3)

monmax<- rbind(monmax,data.frame(Month=mon,Maxval=max(maxval$maxv),ScaleMax=mval))
#maxval$Rmax<- round(max_all,digits = 3)
#mval<- max_all#max(maxval$maxv)
gtb_clones2<- gtb_clones2/mval
#rownames(gtb_clones2)<- gtb_clones2$CLONE_ID
cor(tcr_data)
colSums(gtb_clones2)
gtb_clones2$ZeroCount<- c(unname(apply(as.matrix(gtb_clones2),1,function(x)sum(x!=0))))
dataplot1<- data.frame(matrix(nrow = 0,ncol = length(names(gtb_clones2))))
names(dataplot1)<- names(gtb_clones2)
tempgtb<- gtb_clones2[gtb_clones2$ZeroCount==3,]
tempgtb<- tempgtb[order(tempgtb[,1],decreasing = T),]
dataplot1<- rbind(dataplot1,tempgtb)

tem1<- gtb_clones2[gtb_clones2$ZeroCount==1,]
for(zr1 in c(3,2,1)){
  tem4<- tem1[tem1[,zr1]!=0,]
  tem4<- tem4[order(tem4[,zr1],decreasing = T),]
  dataplot1<- rbind(dataplot1,tem4)
}
temp2<- gtb_clones2[gtb_clones2$ZeroCount==2,]
#temp2$Coname<- apply(temp2,1,function(x)names(temp2)[which(x==0)])

for(zr in c(2,3)){
  tem3<- temp2[temp2[,zr]==0,]
  tem3<- tem3[order(tem3[,1],decreasing = T),]
  dataplot1<- rbind(dataplot1,tem3)
}
tem3<- temp2[temp2[,1]==0,]
tem3<- tem3[order(tem3[,2],decreasing = T),]
dataplot1<- rbind(dataplot1,tem3)
dataplot1$CLONE_ID<- rownames(dataplot1)
dataplot1<- merge(dataplot1,tcr_data_sele[,c('CLONE_ID','COLOR')],by="CLONE_ID",sort = F)
#dataplot1$NCID<- paste0("NCID",sprintf("%0.4d",seq(1,length(dataplot1$CLONE_ID))))
#dataplot1$COLOR<- rep(brewer.pal(12, "Paired"),length(dataplot1$CLONE_ID)/10)[seq(1,length(dataplot1$CLONE_ID))]

#----
#dataplot<- rbind(dataplot,dataplot1)
axnames<-data.frame(Org=c("GM","T","B"),Axis=c('a1','a2','a3'))
mtem<- melt(dataplot1[,!grepl("Zero",names(dataplot1))])
petaldata<- data.frame(matrix(nrow = 0,ncol = 6))
names(petaldata)<- c('CLONE_ID','axis','value1','value2','COLOR') 
for(m in c(1,2,3)){
  tem<- mtem[mtem$variable==as.character(axnames$Org[m]),]
  tem<- tem[tem$value>0.00,]
  tem$value2<- cumsum(tem$value)
  tem$value1<- tem$value2-tem$value
  tem$axis<- axnames$Axis[m]
  #tem<- tem[order(tem$value,decreasing = T)[1:100],]
  petaldata<- rbind(petaldata,tem[,c('CLONE_ID','axis','value1','value2','COLOR')])
}

petaldata$COLOR<- sub("#","",petaldata$COLOR)
filenams<- "Petal_Plots/Petal_data_temp.txt"
write.table(petaldata,filenams,sep = '\t',quote = F,row.names = F,col.names = F)
filemax<- "Petal_Plots/maxsum_Petal_data_temp.tsv"
write.table(maxval,filemax,sep = '\t',quote = F,row.names = F,col.names = F)
outfilesvg="Petal_Plots/Petal_data_temp.svg"
run_perl=paste0("perl petal_plot_v4RG.pl ",filenams," ",outfilesvg)
outfilesvg2=paste0("Petal_Plots/Petal_data_",xmon,".svg")
run_perl=paste0("perl petal_plot_v4RG.pl ",filenams," ",outfilesvg)
run_perl2=paste0("perl petal_plot_v4RG.pl ",filenams," ",outfilesvg2)

system(run_perl)
system(run_perl2)
outfilename=paste0("Petal_Plots/Petal_data_",xmon,".png")
inkscp<- paste0("inkscape -z -e ",outfilename," -w 1000 -h 1000 ", outfilesvg)
system(inkscp,ignore.stderr = T)
}