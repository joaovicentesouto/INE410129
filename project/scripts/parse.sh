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

csvfile=$DIR_RESULTS_COOKED/tasks.csv

# Write header.
echo "exp;ntasks;memory;dispatch;wait" > $csvfile

# Single dispatcher
hash=3771f3c 
for ntasks in {1..29};
do
	cat $DIR_RESULTS_RAW/$hash-task-$ntasks/task-nanvix-cluster-* | \
		grep "\[benchmarks\]\[task\]"                             | \
		$SED -E "s/[[:space:]]+/ /g"                              | \
		cut -d " " -f 7,8,9,10                                    | \
		$SED -E "s/^/single;/g"                                   | \
		$SED -E "s/ /;/g"                                           \
	>> $csvfile
done

# Single dispatcher
hash=48ebff6
for ntasks in {1..29};
do
	cat $DIR_RESULTS_RAW/$hash-task-$ntasks/task-nanvix-cluster-* | \
		grep "\[benchmarks\]\[task\]"                             | \
		$SED -E "s/[[:space:]]+/ /g"                              | \
		cut -d " " -f 7,8,9,10                                    | \
		$SED -E "s/^/multiple;/g"                                 | \
		$SED -E "s/ /;/g"                                           \
	>> $csvfile
done

# Single dispatcher
hash=48ebff6
for ntasks in {1..29};
do
	if [[ $ntasks != 11 ]];
	then
		cat $DIR_RESULTS_RAW/$hash-thread-$ntasks/thread-nanvix-cluster-* | \
			grep "\[benchmarks\]\[thread\]"                               | \
			$SED -E "s/[[:space:]]+/ /g"                                  | \
			cut -d " " -f 7,8,9,10                                        | \
			$SED -E "s/^/thread;/g"                                       | \
			$SED -E "s/ /;/g"                                               \
		>> $csvfile
	fi
done

