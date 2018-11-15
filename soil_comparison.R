# If the libraries below are not already installed, uncomment the code below to install them
# source("https://bioconductor.org/biocLite.R")
# biocLite("ALDEx2")
# biocLite("ggplot2")

# load the libraries
library(ALDEx2)
library(ggplot2)
# set the working dir
setwd("~/Downloads/")

# We are going to use project ERP106650 - Comparison of copper contaminated soils, with similar uncontaminated controls
soil.counts <- read.delim("ERP106650_IPR_abundances_v4.1.tsv", sep="\t", row.names=1, header=T)
soil.conditions <-scan("ERP106650.conds", what=" ")

# generate Monte-Carlo instances of the probability of observing each count
# given the actual read count and the observed read count.
# use a prior of 0.5, corresponding to maximal uncertainty about the read count
# this returns a set of clr values, one for each mc instance
d.x <- aldex.clr(reads=soil.counts[,2:ncol(soil.counts)], conds=soil.conditions, mc.samples=128)

## Note - the ncol value should be 3 for GO, 2 for IPR and 1 for taxonomy, becasue these fies have different numbers of columns
## before the actual data

# calculate effect sizes for each mc instance, report the expected value
d.eff <- aldex.effect(d.x, soil.conditions)
# perform parametric or non-parametric tests for difference
# report the expected value of the raw and BH-corrected P value
# Given the n numbers and number of variables, these are very unlikely to come out as significant
# The effect size is the stat we are interested in, as it is the most robust
d.tt <- aldex.ttest(d.x, soil.conditions)
# concatenate everything into one file
res.all <- data.frame(d.eff,d.tt)

# get 'significant' set
sig <- res.all$wi.eBH < 0.1
eff <- abs(res.all$effect) > 1

effect_thresh=1
res.all$label = rep(0,nrow(res.all))
#res.all[which(res.all$wi.eBH < 1),"label"] = "Significant"
#res.all[which(res.all$wi.eBH < 0.1 & abs(res.all$effect) > effect_thresh),"label"] = "Strong effect"
res.all[which(abs(res.all$effect) > effect_thresh),"label"] = "Strong effect"
res.all[which(res.all$label == 0), "label"] = "Not significant"

# Draw the effect plot
print(ggplot(res.all, aes(x=diff.win, y=diff.btw, colour=label))
      + geom_point(alpha=0.7, size=1)
      + geom_abline(intercept = 0, slope = effect_thresh, linetype=4, colour="red")
      + geom_abline(intercept = 0, slope = -effect_thresh, linetype=4, colour="red")
      + theme_bw()
      + guides(colour=FALSE)
      + scale_colour_manual(values=c("black", "red", "steelblue"))
      + ylab("Median Log2 difference between groups")
      + xlab("Median Log2 dispersion within groups"))

# list the features where the effect size is greater than -1 or +1
features <- res.all[abs(res.all$effect) > 1,]
# find those with effect size greater than one (enriched in copper contaminated soil vs uncontaminated)
sig.up = rownames(features[features$effect>0,])
obs.up = soil.counts[sig.up,1,]
# find those with effect size less than one (enriched in uncontaminated soil vs copper contaminated)
sig.down =rownames(features[features$effect<0,])
obs.down = soil.counts[sig.down,1:2]

# get the row names as well as lables and print the results
ipr_down = data.frame(Name=soil.counts[sig.down,1])
rownames(ipr_down) = rownames(soil.counts[sig.down,])
print("Factors enriched in uncontaminated vs copper contaminated soil")
print(ipr_down)

ipr_up = data.frame(Name=soil.counts[sig.up,1])
rownames(ipr_up) = rownames(soil.counts[sig.up,])
print("Factors enriched in copper contaminated vs uncontaminated soil")
print(ipr_up)

### Ugly graph if there are problems with ggplot
# plot all in transparent grey
# low BH-corrected p values as red
# effect sizes > 1 as blue+red
#plot.new()
#par(fig=c(0,1,0,1), new=TRUE)
#plot(x.all$diff.win, x.all$diff.btw, col=rgb(0,0,0,0.3), pch=19,
#     cex=0.5, ylim=c(-8,8), xlim=c(0,8), xlab="dispersion", ylab="difference",
#     main="Effect plot")
#points(x.all$diff.win[sig], x.all$diff.btw[sig], col=rgb(1,0,0,0.3), pch=19, cex=0.5 )
#points(x.all$diff.win[eff], x.all$diff.btw[eff], col=rgb(0,0,1,0.6), pch=21, cex=0.7 )
#abline(0,1, lty=2, lwd=2, col=rgb(0,0,0,0.4))
#abline(0,-1, lty=2, lwd=2, col=rgb(0,0,0,0.4))

