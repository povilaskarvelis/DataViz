# DataViz

Data visualization functions for Matlab (a little project started during the pandemic).

## Functions for visualizing 2-level factorial data (conditions x groups)

**daviolinplot**, **daboxplot**, and **dabarplot** are lightweight functions written to address limitations of the built-in Matlab tools and to encourage good data visualization practices (highlighting features of the the data that are important for both interpreting the effects and spotting possible issues with the data). 

All three functions: 
- Are created for 2-level factorial data but also work with one-factor data
- Can handle different input types (cell or numeric arrays)
- Are easily customizable for emphasizing data features and maximizing reliability
- Export many handles for furher optimization
- Go hand in hand with 2-way (mixed) ANOVA analysis

## daviolinplot.m 

**daviolinplot** is the best option for highlighitng data distribution properties. It combines boxplots, kernel density, and data scatter to produce different hybrids of violin plots, half-violin plots, raincloud plots, and dotplots. Kernel density highlights the overall shape of the data distribution which is relevant for noticing violations of the normality assumption. Dotplots are similar in that regard but additionally they convey the exact number of datapoints across the distribution. 

Note: dotplots usually require some tweaking to make them look presentable. You may have to play around with bin number ('bins') and marker size ('scattersize') to make it look right.

The examples below illustrate most of the functionality and options (see daviolinplot_demo.m for the code).

![](daviolinplot/daviolinplot_examples.png)


## daboxplot.m

**daboxplot** is the second best option for highlighting data distribution properties. It mainly does this via different options for combining boxplots with jittered data. It is also offers many options when it comes to stylistic aspects of the plots.

The examples below illustrate most of the functionality and options (see daboxplot_demo.m for the code).

![](daboxplot/daboxplot_examples.png)

The below examples illustrate more recently added options:
- Indicate means on each box (to show skewness)
- Link the boxes within each group (to emphasize interaction effects)

![](daboxplot/daboxplot_examples2.png)


## dabarplot.m

**dabarplot** is the third best option for highlighting data distribution properties. However, it still encourages to add error bars (you can choose between standard error, within-subject error, or standard deviation) and jittered data. Overall, it is still best suited for situations where visualizing data distribution is not as important, when the emphasis is not on hypothesis testing and statistical significance, but on the effect size. Using stacked plots and adding number values to the plot can be particularly effective in conveying effect sizes. 

The examples below illustrate most of the functionality and options (see dabarplot_demo.m for the code).

![](dabarplot/dabarplot_examples.png)
