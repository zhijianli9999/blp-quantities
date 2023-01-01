gl datadir = "/export/storage_adgandhi/MiscLi/factract"
gl rdir = "$datadir/raw"
gl idir = "$datadir/intermediate"
gl adir = "$datadir/analysis"
gl codedir = "/mnt/staff/zhli/blp-quantities"


*****basically never have to re-run:
// do ${codedir}/datawork/readtracts.do
// do ${codedir}/datawork/findnbrs.do
*****

do ${codedir}/datawork/makesample.do


foreach tt in 1 0{
	gl testmode = `tt'
	gl testtag
	if ${testmode}==1{
		gl testtag = "_FL17"
	}
	do ${codedir}/datawork/genvars.do
}


do $codedir/datawork/eda.do
