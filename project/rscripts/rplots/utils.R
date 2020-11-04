#
# Copyright(C) 2020 Pedro Henrique Penna <pedrohenriquepenna@gmail.com>
#
# All rights reserved.
#

library("ggplot2")

# Saves a plot into a file.
plot.save <- function(
	directory = getwd(),
	filename = "plot.pdf",
	plot, width = 9, height = 4
) {
	filename <- paste(directory, filename, sep = "/")
	filename <- paste(filename, "pdf", sep = ".")

	ggsave(
		filename = filename,
		plot = plot,
		width = width,
		height = height
	)
}
