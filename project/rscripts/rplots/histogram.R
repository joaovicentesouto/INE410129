#
# Copyright(C) 2020 Pedro Henrique Penna <pedrohenriquepenna@gmail.com>
#
# All rights reserved.
#

library("ggplot2")

# Plots a histogram.
plot.histogram <- function(
  df,
  factor, respvar,
  title, subtitle = NULL,
  axis.x.title,
  axis.x.trans = "identity",
  axis.y.title, axis.y.limits = NULL,
  axis.y.trans = 'identity',
  axis.y.trans.fn = function(x) x,
  axis.y.trans.format = math_format()(1:10),
  axis.y.labels = function(x) sprintf("%.1f", x)
) {
	ggplot(
		asset.df,
		aes(x = get(var))
	) +
	geom_density(alpha = 0.2, fill = "gray50", na.rm = TRUE) +
	labs(
		title = title,
		subtitle = subtitle,
		x = axis.x.title,
		y = axis.y.title
	) +
	scale_y_continuous(
		expand = c(0, 0),
		limits = axis.y.limits,
		breaks = scales::pretty_breaks(n = 5),
		labels = axis.y.labels
	) +
	theme_classic()
}
