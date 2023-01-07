gl datadir = "/export/storage_adgandhi/MiscLi/factract"
gl rdir = "$datadir/raw"
gl idir = "$datadir/intermediate"
gl adir = "$datadir/analysis"
gl codedir = "/mnt/staff/zhli/blp-quantities"


*****basically never have to re-run:
// do ${codedir}/datawork/readtracts.do
// do ${codedir}/datawork/findnbrs.do
*****

// do ${codedir}/datawork/makesample.do

foreach tt in 2 1 0{
	gl testtag
	if `tt'==1{
		gl testtag = "_FL17"
	}
	if `tt'==2{
		gl testtag = "_FL"
	}
	do ${codedir}/datawork/genvars.do
}


// do $codedir/datawork/eda.do
