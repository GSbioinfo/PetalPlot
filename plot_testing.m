n=100;

c=[500,500];
r=450;
r2=100;
d2r= 57.2958;
xic=c(1) + r*sin(t);
yic=c(2) + r*cos(t);
xoc=c(1) + r2*sin(t);
yoc=c(2) + r2*cos(t);
t = linspace(0,2*pi,n);
axi1x1=c(1) + r2*sin(0);
axi1y1 = c(2) + r2*cos(0);
axi1x2 = c(1) + r*sin(0);
axi1y2 = c(2) + r*cos(0);
axi2x1=c(1) + r2*sin(120/57.2958);
axi2y1 = c(2) + r2*cos(120/57.2958);
axi2x2 = c(1) + r*sin(120/57.2958);
axi2y2 = c(2) + r*cos(120/57.2958);
axi3x1=c(1) + r2*sin(240/57.2958);
axi3y1 = c(2) + r2*cos(240/57.2958);
axi3x2 = c(1) + r*sin(240/57.2958);
axi3y2 = c(2) + r*cos(240/57.2958);
tx=[0:1:4];
tc=axi2y2-(-tan(1200/57.2958))*axi2x2;
ty=-tan(120/57.2958).*tx+tc;
xrad=rand(10,1)*(-10);
norm_dta= r2+(xrad-min(xrad))./(max(xrad)-min(xrad))*(r-r2);
plot(xic,yic,'--');
hold on
plot(xoc,yoc,'--')
plot([axi1x1,axi1x2],[axi1y1,axi1y2])
plot([axi2x1,axi2x2],[axi2y1,axi2y2])
plot([axi3x1,axi3x2],[axi3y1,axi3y2])
for i = 1:length(norm_dta);
    x1 = c(1) + (norm_dta(i)*sin(120/57.2958));
    y1 = c(2) + (norm_dta(i)*cos(120/57.2958));
    plot(x1,y1,'or');
end
%xlim([0,4]);
%ylim([0,4]);
hold off
