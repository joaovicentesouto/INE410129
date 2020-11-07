#
# Copyright(C) 2020 Pedro Henrique Penna <pedrohenriquepenna@gmail.com>
#
# All rights reserved.
#

library("ggplot2")

# Plots a line chart.
plot.linespoint <- function(
  df,
  factor, respvar, param,
  title, subtitle = NULL,
  legend.title, legend.labels,
  axis.x.title, axis.x.breaks,
  axis.x.trans = "identity",
  axis.y.title, axis.y.limits = NULL,
  axis.y.trans = 'identity',
  axis.y.trans.fn = function(x) x,
  axis.y.breaks = trans_breaks(axis.y.trans,  axis.y.trans.fn),
  axis.y.trans.format = math_format()(1:10)
) {
	ggplot(
		data = df,
		aes(x = get(factor), y = get(respvar), group = get(param))
	) +
	geom_line() +
	geom_point(
		aes(shape = get(param), colour = get(param), fill = get(param)),
		size = 3.5
	) +
	labs(
		title = title,
		subtitle = subtitle,
		x = axis.x.title,
		y = axis.y.title
	) +
	scale_shape_manual(
		name = legend.title,
		labels = legend.labels,
		values = c(21, 22, 23, 25, 25)
	) +
	scale_colour_manual(
		name = legend.title,
		labels = legend.labels,
		values = c("grey25", "grey50", "black")
	) +
	scale_fill_manual(
		name = legend.title,
		labels = legend.labels,
		values = c("grey25", "grey50", "black")
	) +
	scale_x_continuous(
		breaks = axis.x.breaks,
		trans = axis.x.trans
	) +
	scale_y_continuous(
		limits = axis.y.limits,
		trans = axis.y.trans,
		breaks = axis.y.breaks,
		labels = trans_format(axis.y.trans, axis.y.trans.format)
	) +
	theme_classic()
}
