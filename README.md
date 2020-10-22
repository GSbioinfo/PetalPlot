# PetalPlot

This ploting tool allows pesentation of 3D data in 2D. 3 stacked barplots are presentated on three axis. 
Stacks (bands) in the stacked barplots that are common between axes are connected using ribbons.
Ribbions are assigned same as the color as that of stacks it is connecting. 
In current version of the script allows ploting of upto 3 axis. 
Data for the script can be provided independently as .txt file.
The R script "data-shaper_and_ploter.R" can be used to format you data for plotting

Input data format for the script in data_xyx.txt file "no header or line number"
CLONE0201	a1	0	0.0190976650851147	CAB2D6
CLONE0197	a1	0.0190976650851147	0.0366256043259522	FB9A99
CLONE0200	a1	0.0366256043259522	0.0539121373259692	FF7F00
CLONE0199	a1	0.0539121373259692	0.0699317281631714	FDBF6F
CLONE0179	a1	0.0699317281631714	0.0849907132758685	FFFF99
CLONE0167	a1	0.0849907132758685	0.0998453147686865	FFFF99
CLONE0183	a1	0.0998453147686865	0.114103116091457	B2DF8A
CLONE0169	a1	0.114103116091457	0.127927624140084	A6CEE3
CLONE0191	a1	0.127927624140084	0.141719430809531	FFFF99
CLONE0196	a1	0.141719430809531	0.155332681834138	33A02C
CLONE0175	a1	0.155332681834138	0.168445934885586	FDBF6F
CLONE0194	a1	0.168445934885586	0.181412960377482	1F78B4
CLONE0193	a1	0.181412960377482	0.194354476966772	A6CEE3
CLONE0192	a1	0.194354476966772	0.207227969815776	B15928
CLONE0177	a1	0.207227969815776	0.219899754248285	CAB2D6
CLONE0190	a1	0.219899754248285	0.232450134330933	6A3D9A
CLONE0189	a1	0.232450134330934	0.244957999575904	CAB2D6

--
first column:- ID of the stack in the stacked-barplot.
second column:- ID for the axis (a1-vertical, a2-right hand, a3-left hand)
third column:- stack start value (0 bottom of the plot)
fourth column:- stack end value (thickness of the stack)
fifth column:- color of the stack and ribbon (hex code)

You also need to provide maxsum_data_xyx.txt with following format "no header or line number"
0.178129428632835	a1	0.2
0.148599445598516	a2	0.2
0.133643436633031	a3	0.2

data-shaper_and_ploter.R can generate both data and maxsum files.

Data_for_petalplot.tsv has example data set


