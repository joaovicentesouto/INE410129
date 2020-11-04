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
source(file = "rscripts/rplots/bars.R")
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
	experiment.infile <- "./results/cooked/tasks.csv"
	experiment.outdir <- "./img/results"
	experiment.outfile <- "tasks"
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

# Update memory used by multiple dispatcher.
experiment.df <- experiment.df %>%
	mutate(memory = ifelse(exp == "multiple", 114688, memory))

# Sum dispatch and wait times
experiment.df$time <- (experiment.df$dispatch + experiment.df$wait)/MPPA.FREQ/MICRO
experiment.df$memory <- experiment.df$memory/KB

#===============================================================================
# Pre-Processing
#===============================================================================

time.df.melted <- melt(
	data = experiment.df,
	id.vars = c("exp",  "ntasks"),
	measure.vars = c("time"),
)
time.df.cooked <- ddply(
	time.df.melted,
	c("exp",  "ntasks", "variable"),
	summarise,
	mean = mean(value),
	sd = sd(value),
	cv = sd(value)/mean(value)
)

memory.df.melted <- melt(
	data = experiment.df,
	id.vars = c("exp",  "ntasks"),
	measure.vars = c("memory"),
)
memory.df.cooked <- ddply(
	memory.df.melted,
	c("exp",  "ntasks", "variable"),
	summarise,
	mean = mean(value),
	sd = sd(value),
	cv = sd(value)/mean(value)
)

print(time.df.cooked)
print(head(memory.df.cooked))

#===============================================================================
# Time Plot
#===============================================================================

plot.df <- time.df.cooked

plot.var.x <- "ntasks"
plot.var.y <- "mean"
plot.factor <- "exp"

# Titles
plot.title <- NULL
plot.subtitle <- NULL

# Legend
plot.legend.title <- "Type of Execution Flow"
plot.legend.labels <- c("Multiple Dispathers", "Single Dispatcher", "Threads")

# X Axis
plot.axis.x.title <- "Number of Tasks"
plot.axis.x.breaks <- seq(from = 1, to = 29, by = 1)

# Y Axis
plot.axis.y.title <- expression(paste("Time (", mu, "s)"))
plot.axis.ymin <- 2^8
plot.axis.ymax <- 2^14
plot.axis.y.limits <- c(plot.axis.ymin, plot.axis.ymax)
plot.axis.y.breaks <- 2^c(-1:14)

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
	axis.y.trans = "log2",
	axis.y.trans.format = math_format(expr = 2^.x)
) + plot.theme.title +
	plot.theme.legend.bottom.right +
	plot.theme.axis.x +
	plot.theme.axis.y +
	plot.theme.grid.wall +
	plot.theme.grid.major

plot.save(
	plot,
	directory = experiment.outdir,
	filename = paste(experiment.outfile, "time", sep = "-")
)

#===============================================================================
# Memory Plot
#===============================================================================

plot.df <- memory.df.cooked

plot.var.x <- "ntasks"
plot.var.y <- "mean"
plot.factor <- "exp"

# Titles
plot.title <- NULL
plot.subtitle <- NULL

# Legend
plot.legend.title <- "Execution Flow"
plot.legend.labels <- c("Multiple Dispathers", "Single Dispatcher", "Threads")

# X Axis
plot.axis.x.title <- "Number of Tasks"
plot.axis.x.breaks <- seq(from = 1, to = 29, by = 1)

# Y Axis
plot.axis.y.title <- "Memory (KB)"
plot.axis.ymin <- 8 
plot.axis.ymax <- 232 
plot.axis.y.limits <- c(plot.axis.ymin, plot.axis.ymax)
plot.axis.y.breaks <- seq(from = plot.axis.ymin, to = plot.axis.ymax, by = 28)

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
) + plot.theme.title +
	plot.theme.legend.bottom.right +
	plot.theme.axis.x +
	plot.theme.axis.y +
	plot.theme.grid.wall +
	plot.theme.grid.major

plot.save(
	plot,
	directory = experiment.outdir,
	filename = paste(experiment.outfile, "memory", sep = "-")
)
