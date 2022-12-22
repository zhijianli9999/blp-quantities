gl datadir = "/export/storage_adgandhi/MiscLi/factract"
gl rdir = "$datadir/raw"
gl idir = "$datadir/intermediate"
gl adir = "$datadir/analysis"
gl codedir = "/mnt/staff/zhli/blp-quantities"

//makesample makes samples for both testing and full
do ${codedir}/datawork/makesample.do

///// testing
gl testmode = 0 //edit this
gl testtag
if ${testmode}==1{
	gl testtag = "_FL17"
}

do ${codedir}/datawork/genvars.do
