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
# Replaces strings recursively.
#
function replace
{
	dir=$1
	oldstr=$2
	newstr=$3

	find $dir \( -type d -name .git -prune \) -o -type f -print0 \
		| xargs -0 $SED -i "s/$oldstr/$newstr/g"
}

#
# Turns on/off add-ons.
#
function switchAddons
{
	srcdir=$1
	on=$2
	off=$3
	curdir=$PWD

	cd $srcdir

		replace . "export ADDONS ?=$off" "export ADDONS ?=$on"

	cd $curdir
}

#
# Change repository.
#
function changeRepository
{
	if  [ "$1" == "benchmarks" ];
	then
		DIR_REMOTE=$BENCHMARKS_DIR_REMOTE
		DIR_SOURCE=$BENCHMARKS_DIR_SOURCE
		COMMIT=$BENCHMARKS_COMMIT
		HASH=$BENCHMARKS_HASH
	else
		echo "unknown target repository"
		exit 1
	fi

	OUTDIR=$DIR_RESULTS_RAW/$HASH
}

#
# Checkout source code.
#
function checkout
{
	srcdir=$1
	commit=$2
	curdir=$PWD

	cd $srcdir

		git checkout $commit
		git submodule update --recursive

	cd $curdir
}

#
# Populate base dir on remote.
#
function configureRemote
{
	platform=$1
	scripts=$2
	basedir=$3

	ssh $platform "rm -rf $basedir/* ; \
		mkdir -p $basedir/benchmarks"

	$UPLOAD $scripts/arch/$platform/run.sh $platform:$basedir
}

#
# Upload source code.
#
function upload
{
	platform=$1
	destdir=$2
	srcdir=$3

	ssh $platform "rm -rf $destdir/*"
	$UPLOAD $srcdir/* $platform:$destdir
}

#
# Download results.
#
function download
{
	platform=$1
	remotedir=$2
	localdir=$3
	localfile=$4

	scp "$platform:$remotedir/$localfile" $localdir/$localfile
}

#
# Run experiment.
#
function run
{
	platform=$1
	remotedir=$2
	srcdir=$3
	commit=$4
	img=$5
	exp=$6
	it=$7
	localdir=$8
	runlog=$9

	runlogfile=$exp-$runlog-$it

	checkout $srcdir $commit
	upload $platform $remotedir $srcdir

	ssh $platform "cd $remotedir && $RUN $remotedir img/$img && cat $runlog-* > $runlogfile"

	download $platform $remotedir $localdir "$runlogfile"
}

#===============================================================================

function run_tasks
{
	changeRepository benchmarks

	for exp in task;
	do
		IMG=mppa256-$exp-time.img

		cp $DIR_SOURCE/img/$IMG $DIR_SOURCE/img/mppa256.img

		addons_old=""

		for ntasks in {1..29};
		do
			addons_new=" -D__NTASKS=$ntasks -D__NITERATIONS=50 -D__NSKIP=10"
			switchAddons $DIR_SOURCE "$addons_new" "$addons_old"

			outdir=$OUTDIR-$exp-$ntasks

			mkdir -p $outdir

			run               \
				$PLATFORM     \
				$DIR_REMOTE   \
				$DIR_SOURCE   \
				$COMMIT       \
				$IMG          \
				$exp          \
				5             \
				$outdir       \
				$FILE_RUNLOG

			addons_old=$addons_new
		done

		# Rollback changes.
		switchAddons $DIR_SOURCE "" "$addons_old"
	done
}

#===============================================================================

configureRemote $PLATFORM $DIR_SCRIPTS $BASEDIR_REMOTE

case $1 in
	tasks)
		run_tasks
		;;
esac
