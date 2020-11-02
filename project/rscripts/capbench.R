#
# MIT License
#
# Copyright (c) 2011-2020 Pedro Henrique Penna <pedrohenriquepenna@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# R Libraries
library(ggplot2)
library(reshape2)
library(scales)
library(plyr)
library(tidyverse)

# My Utilities
source(file = "rscripts/rplots/lines.R")
source(file = "rscripts/rplots/theme.R")
source(file = "rscripts/rplots/utils.R")
source(file = "rscripts/consts.R")

#===============================================================================
# Experiment Information
#===============================================================================

args = commandArgs(trailingOnly=TRUE)

if (length(args) >= 3) {
	experiment.infile <- args[1]
	experiment.outdir <- args[2]
	experiment.outfile <- args[3]
} else {
	experiment.infile <- "./results/cooked/gf.csv"
	experiment.outdir <- "./img/results"
	experiment.outfile <- "gf"
}

#===============================================================================
# Input Reading
#===============================================================================

experiment.df <- read_delim(
	file = experiment.infile,
	col_names = TRUE,
	delim = ";"
)

#===============================================================================
# Filter 
#===============================================================================

# Changes number procs to worker procs 
experiment.df["nprocs"] <- (experiment.df["nprocs"] - 1)

#===============================================================================
# Pre-Processing
#===============================================================================

nanvix.df <- subset(
	x = experiment.df,
	subset = (api == "nanvix")
)
nanvix.df.melted <- melt(
	data = nanvix.df,
	id.vars = c("api",  "nprocs"),
	measure.vars = c("time"),
)
nanvix.df.cooked <- ddply(
	nanvix.df.melted,
	c("api",  "nprocs", "variable"),
	summarise,
	mean = mean(value),
	sd = sd(value),
	cv = sd(value)/mean(value)
)
nanvix.df.cooked$speedup <- nanvix.df.cooked$mean[1]/nanvix.df.cooked$mean
nanvix.df.cooked$mean <- nanvix.df.cooked$mean / MPPA.FREQ

baseline.df <- subset(
	x = experiment.df,
	subset = (api == "baseline")
)
baseline.df.melted <- melt(
	data = baseline.df,
	id.vars = c("api",  "nprocs"),
	measure.vars = c("time"),
)
baseline.df.cooked <- ddply(
	baseline.df.melted,
	c("api",  "nprocs", "variable"),
	summarise,
	mean = mean(value),
	sd = sd(value),
	cv = sd(value)/mean(value)
)
baseline.df.cooked$speedup <- baseline.df.cooked$mean[1]/baseline.df.cooked$mean

#===============================================================================
# Speedup Plot
#===============================================================================

plot.df <- rbind(nanvix.df.cooked, baseline.df.cooked)

plot.var.x <- "nprocs"
plot.var.y <- "speedup"
plot.factor <- "api"

# Titles
plot.title <- NULL
plot.subtitle <- NULL

# Legend
plot.legend.title <- "API Solution"
plot.legend.labels <- c("Kalray Runtime", "Nanvix LWMPI")

# X Axis
plot.axis.x.title <- "Number of Workers"
plot.axis.x.breaks <- seq(from = 1, to = 15, by = 1) 

# Y Axis
plot.axis.y.title <- "Speedup"
plot.axis.ymax <- 16
plot.axis.y.limits <- c(0, plot.axis.ymax)
plot.axis.y.breaks <- seq(from = 0, to = plot.axis.ymax, by = 2)

# Data Labels
plot.data.labels.digits <- 0

plot <- plot.linespoint(
	df = plot.df,
	factor = plot.var.x,
	respvar = plot.var.y,
	param = plot.factor,
	title = plot.title,
	subtitle = plot.subtitle,
	legend.title = plot.legend.title,
	legend.labels = plot.legend.labels,
	axis.x.title = plot.axis.x.title,
	axis.x.breaks = plot.axis.x.breaks,
	axis.y.title = plot.axis.y.title,
	axis.y.limits = plot.axis.y.limits,
	axis.y.breaks = plot.axis.y.breaks
) + plot.theme.title +
	plot.theme.legend.top.left +
	plot.theme.axis.x +
	plot.theme.axis.y +
	plot.theme.grid.wall +
	plot.theme.grid.major

if (length(args) >= 1) {
	plot.save(
		plot,
		directory = experiment.outdir,
		filename = paste(experiment.outfile, "speedup", sep = "-")
	)
} else {
	plot
}

#===============================================================================
# Time Plot
#===============================================================================

plot.df <-rbind(nanvix.df.cooked, baseline.df.cooked)

plot.var.x <- "nprocs"
plot.var.y <- "mean"
plot.factor <- "api"

# Titles
plot.title <- NULL
plot.subtitle <- NULL

# Legend
plot.legend.title <- "API Solution"
plot.legend.labels <- c("Kalray Runtime", "Nanvix LWMPI")

# X Axis
plot.axis.x.title <- "Number of Worders"
plot.axis.x.breaks <- seq(from = 1, to = 15, by = 1) 

# Y Axis
plot.axis.y.title <- "Time (s)"
plot.axis.ymax <- 1000
plot.axis.y.limits <- c(0.1, plot.axis.ymax)
plot.axis.y.breaks <- 10^c(-1:3)

# Data Labels
plot.data.labels.digits <- 0

plot <- plot.linespoint(
	df = plot.df,
	factor = plot.var.x,
	respvar = plot.var.y,
	param = plot.factor,
	title = plot.title,
	subtitle = plot.subtitle,
	legend.title = plot.legend.title,
	legend.labels = plot.legend.labels,
	axis.x.title = plot.axis.x.title,
	axis.x.breaks = plot.axis.x.breaks,
	axis.y.title = plot.axis.y.title,
	axis.y.limits = plot.axis.y.limits,
	axis.y.breaks = plot.axis.y.breaks,
	axis.y.trans = "log10",
	axis.y.trans.format = math_format(expr = 10^.x)
) + plot.theme.title +
	(
	 if (experiment.outfile == "gf") plot.theme.legend.top.right
	 else                            plot.theme.legend.bottom.left
	) +
	plot.theme.axis.x +
	plot.theme.axis.y +
	plot.theme.grid.wall +
	plot.theme.grid.major

if (length(args) >= 1) {
	plot.save(
		plot,
		directory = experiment.outdir,
		filename = paste(experiment.outfile, "time", sep = "-")
	)
} else {
	plot
}

#===============================================================================
# Statistics
#===============================================================================

# Max CoVs
print(max(nanvix.df.cooked$cv))
print(max(baseline.df.cooked$cv))
