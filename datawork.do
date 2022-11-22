gl datadir = "/export/storage_adgandhi/MiscLi/factract"
gl rdir = "$datadir/raw"
gl idir = "$datadir/intermediate"
gl adir = "$datadir/analysis"
gl codedir = "/mnt/staff/zhli/blp-quantities"

///// testing
gl testmode = 0 //edit this

gl auxstate = "FL" //pick one state to test 

gl testtag ""
if "$testmode"=="1"{
	gl testtag "_${auxstate}"
}

do ${codedir}/makesample.do
do ${codedir}/genvars.do
