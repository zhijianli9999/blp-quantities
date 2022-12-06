gl datadir = "/export/storage_adgandhi/MiscLi/factract"
gl rdir = "$datadir/raw"
gl idir = "$datadir/intermediate"
gl adir = "$datadir/analysis"
gl codedir = "/mnt/staff/zhli/blp-quantities"

///// testing
gl testmode = 0 //edit this
gl testtag
if ${testmode}==1{
	gl testtag = "_FL"
}

do ${codedir}/datawork/makesample.do
do ${codedir}/datawork/genvars_old.do
// do ${codedir}/datawork/genvars.do
