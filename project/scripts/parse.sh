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

DIR_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" >/dev/null 2>&1 && pwd  )"

source $DIR_SCRIPT/const.sh

#===============================================================================

#
# Concatenates run logs.
#
function concatenate {
	runlogs=$1

	cat $runlogs-*
}

#
# Filter raw results.
#
function filter {
	exp=$1
	col=$2

	grep "\[$exp\]" | \
	cut -d " " -f $col-
}

#
# Formats raw results.
#
function format {
	$SED -e "s/ /;/g"
}

#===============================================================================

hash=$BENCHMARKS_HASH

for exp in fn gf km;
do
	csvfile=$DIR_RESULTS_COOKED/$exp.csv

	# Write header.
	echo "exp;api;nprocs;time" > $csvfile

	for nprocs in {2..16};
	do
		f=$DIR_RESULTS_RAW/$exp-$(echo "$nprocs - 1" | bc).out

		cat $f                                    | \
			grep "total time"                     | \
			sed -E "s/[[:space:]]+/ /g"           | \
			cut -d" " -f 6                        | \
			sed -E "s/^/$exp;baseline;$nprocs;/g"   \
		>> $csvfile

		cat $DIR_RESULTS_RAW/$hash-procs-$nprocs/$exp-nanvix-cluster-* | \
			grep "total time"                                          | \
			sed -E "s/[[:space:]]+/ /g"                                | \
			cut -d" " -f 9                                             | \
			sed -E "s/^/$exp;nanvix;$nprocs;/g"                          \
		>> $csvfile
	done
done
