# PetalPlot

This ploting tool allows pesentation of 3D data in 2D. 3 stacked barplots are presentated on three axis. 
Stacks (bands) in the stacked barplots that are common between axes are connected using ribbons.
Ribbions are assigned same as the color as that of stacks it is connecting. 
In current version of the script allows ploting of upto 3 axis. 
Data for the script can be provided independently as .txt file.
The R script "data-shaper_and_ploter.R" can be used to format you data for plotting

Petal_data_temp.txt in folder "Petal_Plots" Input data format for the script in "no header or line number"

first column:- ID of the stack in the stacked-barplot.
second column:- ID for the axis (a1-vertical, a2-right hand, a3-left hand)
third column:- stack start value (0 bottom of the plot)
fourth column:- stack end value (thickness of the stack)
fifth column:- color of the stack and ribbon (hex code)

You also need to provide maxsum_Petal_data_temp.txt "no header or line number"


data-shaper_and_ploter.R can generate both data and maxsum files.

Data_for_petalplot.tsv has example data set


