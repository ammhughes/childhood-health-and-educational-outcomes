clear all
set maxvar 30000

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy"

*start with standard alspac data file with swapped id
use "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\data\alspac\summary\applications\B2953\dev\B2953_Child_Phenotypes\B2953 Child Phenotypes\ROOT FILES OF ID-SWAPPED DATA\Howe_19Nov18.dta", clear
*merge in linked education data
merge 1:1 qlet cidB2953 using "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\data\alspac\summary\applications\B2953\dev\B2953_Child_Phenotypes\B2953 Child Phenotypes\ROOT FILES OF ID-SWAPPED DATA\Howe_19Nov18_linkage.dta", nogen

****DROP THE UNUSABLE PEOPLE WITH ONLY MISSING VALUES
drop if qlet==""
*6,815 observations deleted

save Phenotypes_and_NPD.dta, replace

*PREP:

*SDQ subscale for ADHD
*Useful paper on use  of the measure for distinguishing ADHD from other things: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4990620/
*Not considering early childhood, so don't need to worry about singleton-only restriction at age 5.

*Hyperactivity/inattention SDQ subscore:

*6y9m
fre kq348b kq347b kq346b kq345b 
*Label a complete-case one for now:
clonevar SDQ_HI_subscore_kq=kq345b
replace SDQ_HI_subscore_kq=. if SDQ_HI_subscore_kq<0
label var SDQ_HI_subscore_kq "Hyperactivity/inattention SDQ subscale, no missingness allowed"
tab SDQ_HI_subscore_kq

*9y6m
fre ku706c ku706b ku706a 
clonevar SDQ_HI_subscore_ku=ku706a
replace SDQ_HI_subscore_ku=. if SDQ_HI_subscore_ku<0
label var SDQ_HI_subscore_ku "Hyperactivity/inattention SDQ subscale, no missingness allowed"
tab SDQ_HI_subscore_ku

*11y8m
fre kw6601c kw6601b kw6601a 
clonevar SDQ_HI_subscore_kw=kw6601a 
replace SDQ_HI_subscore_kw=. if SDQ_HI_subscore_kw<0
label var SDQ_HI_subscore_kw "Hyperactivity/inattention SDQ subscale, no missingness allowed"
tab SDQ_HI_subscore_kw

*For schools ones, cc versions exist:
fre sa162c sa162b sa162a 
clonevar SDQ_HI_subscore_schoolyear3=sa162a
replace SDQ_HI_subscore_schoolyear3=. if SDQ_HI_subscore_schoolyear3<0
label var SDQ_HI_subscore_schoolyear3 "Hyperactivity/inattention SDQ subscale, no missingness allowed"
tab SDQ_HI_subscore_schoolyear3

fre se162c se162b se162a  
clonevar SDQ_HI_subscore_schoolyear6=se162a
replace SDQ_HI_subscore_schoolyear6=. if SDQ_HI_subscore_schoolyear6<0
label var SDQ_HI_subscore_schoolyear6 "Hyperactivity/inattention SDQ subscale, no missingness allowed"
tab SDQ_HI_subscore_schoolyear6

*13y
fre ta7025c 
*The only derived var is prorated. Make a new complete case one, removing poeple missing 1 or more of those items:
*ta7001          byte    %12.0g     ta7001     I2: Teenager has been restless, overactive and can't stay still for long
*ta7009          byte    %12.0g     ta7009     I10: Teenager is constantly fidgeting or squirming
*ta7014          byte    %12.0g     ta7014     I15: Teenager is easily distracted, concentration wanders
*ta7020          byte    %12.0g     ta7020     I21: Teenager thinks things out before acting
*ta7024          byte    %12.0g     ta7024     I25: Teenager sees tasks through to end, has good attention span

*First three scored 0 1 2 for not true -->certainly true, last to reverse-scored
*Addition protocolis here, p13: https://depts.washington.edu/dbpeds/Screening%20Tools/Strengths_and_Difficulties_Questionnaire.pdf

capture drop SDQ_HI_subscore_ta
clonevar SDQ_HI_subscore_ta=ta7025c 
*To missing for globally unsuable ones:
recode SDQ_HI_subscore_ta -10=. -1=. 
*Remove prorated: where any individual items are 9 'don't know'
replace SDQ_HI_subscore_ta=. if inlist(9, ta7001, ta7009, ta7014, ta7020, ta7024)
label var SDQ_HI_subscore_ta "Hyperactivity/inattention SDQ subscale, no missingness allowed"
fre SDQ_HI_subscore_ta ta7025c 

*16
list tc4001 tc4009 tc4014 tc4020 tc4024 if tc4025c==-1
capture drop SDQ_HI_subscore_tc
clonevar SDQ_HI_subscore_tc=tc4025c 
*To missing for globally unsuable ones:
recode SDQ_HI_subscore_tc -10=. -1=. 
*Remove prorated: where any individual items are 9 ('don't know')
replace SDQ_HI_subscore_tc=. if inlist(9, tc4001, tc4009, tc4014, tc4020, tc4024)
label var SDQ_HI_subscore_tc "Hyperactivity/inattention SDQ subscale, no missingness allowed"
fre SDQ_HI_subscore_tc tc4025c 

*Standardize all of them
foreach t in kq ku kw schoolyear3 schoolyear6 ta tc {
egen zSDQHI_`t'=std(SDQ_HI_subscore_`t')
}
summ zSDQHI_*


*DEPRESSION/INTERNALIZING: MFQ

*Child-reported symptoms only.
summ MFQsummscoreF10 MFQsummscoreTF1 MFQsummscoreTF2 MFQsummscoreCCS, detail
*Stay away from DAWBA for now

***ERRORS DETECTED IN EARLIER DERIVED VERSIONS: F10 AND CCS. FIX THOSE AFTER MAKING PRORATED VERSIONS

*PRORATED VERSIONS.
*F10: FOUR DUMMY ITEMS HERE
fre fddp110-fddp126
*Current coding is 1=true 2=sometimes 3=not at all
*Needs to be: "not true" = 0 points "somewhat true" = 1 point "true" = 2 points
*Recode and add up, but leave out dummy items 2, 8, 11 and 17
fre fddp111 fddp117 fddp120 fddp126
foreach var of varlist fddp110 fddp112 fddp113 fddp114 fddp115 fddp116 fddp118 fddp119 fddp121 fddp122 fddp123 fddp124 fddp125 {
gen `var'_v2=`var'
recode `var'_v2 3=0 2=12 1=2
recode `var'_v2 12=1
}
*Check it:
tab fddp125 fddp125_v2

*Summary score with prorating to allow 1 missingness:
gen nmiss_MFQsummscoreF10=0
replace nmiss_MFQsummscoreF10=. if fddp110==. | fddp110==-2 | fddp110==-9
foreach var of varlist fddp110 fddp112 fddp113 fddp114 fddp115 fddp116 fddp118 fddp119 fddp121 fddp122 fddp123 fddp124 fddp125 {
replace nmiss_MFQsummscoreF10=nmiss_MFQsummscoreF10+1 if `var'==-1
}
fre nmiss_MFQsummscoreF10

gen MFQsummscoreF10_1miss=0
*code to missing for people not there or who skipped whole task:
replace MFQsummscoreF10_1miss=. if fddp110==-9 |  fddp110==-2 |  fddp110==.
foreach var of varlist fddp110 fddp112 fddp113 fddp114 fddp115 fddp116 fddp118 fddp119 fddp121 fddp122 fddp123 fddp124 fddp125 {
replace  MFQsummscoreF10_1miss= MFQsummscoreF10_1miss+`var'_v2 if `var'_v2>-1
}
fre MFQsummscoreF10_1miss if nmiss_MFQsummscoreF10==1
*Now upweight for people missing exactly 1:
replace  MFQsummscoreF10_1miss=MFQsummscoreF10_1miss*(13/12) if nmiss_MFQsummscoreF10==1
tab MFQsummscoreF10_1miss
label variable MFQsummscoreF10_1miss "MFQ summary score at age 10 F10: 1 item-level missingness allowed"
summ MFQsummscoreF10_1miss, det

*New version of CC variable:
gen MFQsummscoreF10_cc=0
*code to missing for people not there or who skipped whole task:
replace MFQsummscoreF10_cc=. if fddp110==-9 |  fddp110==-2 |  fddp110==.
foreach var of varlist fddp110 fddp112 fddp113 fddp114 fddp115 fddp116 fddp118 fddp119 fddp121 fddp122 fddp123 fddp124 fddp125 {
replace  MFQsummscoreF10_cc= MFQsummscoreF10_cc+`var'_v2 if `var'_v2>-1
}
fre MFQsummscoreF10_cc if nmiss_MFQsummscoreF10==1
*Replace to missing also for people missing exactly 1:
replace  MFQsummscoreF10_cc=. if nmiss_MFQsummscoreF10==1

tab MFQsummscoreF10_cc
label variable MFQsummscoreF10_cc "MFQ summary score at age 10 F10: complete cases only"
summ MFQsummscoreF10_cc, det


*TF1: 
*Three dummy items ff6501 ff6507 ff6510  
fre ff6500 ff6502 ff6503 ff6504 ff6505 ff6506 ff6508 ff6509  ff6511 ff6512 ff6513 ff6514 ff6515
*Needs to be: "not true" = 0 points "somewhat true" = 1 point "true" = 2 points

*Recode and add up the real questions:
foreach var of varlist ff6500 ff6502 ff6503 ff6504 ff6505 ff6506 ff6508 ff6509  ff6511 ff6512 ff6513 ff6514 ff6515  {
gen `var'_v2=`var'
recode `var'_v2 3=0 2=12 1=2
recode `var'_v2 12=1
}
*Identify case-missigness
gen nmiss_MFQsummscoreTF1=0
*code to missing for people not there or who skipped whole task:
replace nmiss_MFQsummscoreTF1=. if ff6500==-10 |  ff6500==-6 |  ff6500==-5 |  ff6500==.
foreach var of varlist ff6500 ff6502 ff6503 ff6504 ff6505 ff6506 ff6508 ff6509  ff6511 ff6512 ff6513 ff6514 ff6515 {
replace nmiss_MFQsummscoreTF1=nmiss_MFQsummscoreTF1+1 if `var'==-1
}
fre nmiss_MFQsummscoreTF1

*Summary score allownig 1 item missing
gen MFQsummscoreTF1_1miss=0
replace MFQsummscoreTF1_1miss=. if ff6500<-1 |  ff6500==.
foreach var of varlist ff6500 ff6502 ff6503 ff6504 ff6505 ff6506 ff6508 ff6509  ff6511 ff6512 ff6513 ff6514 ff6515 {
replace  MFQsummscoreTF1_1miss= MFQsummscoreTF1_1miss+`var'_v2 if `var'_v2>-1
}
fre MFQsummscoreTF1_1miss if nmiss_MFQsummscoreTF1==1
*Now upweight for people missing exactly 1:
replace  MFQsummscoreTF1_1miss=MFQsummscoreTF1_1miss*(13/12) if nmiss_MFQsummscoreTF1==1

tab MFQsummscoreTF1_1miss
label variable MFQsummscoreTF1 "MFQ summary score at age 12.5 TF1: 1 item-level missingness allowed"
summ MFQsummscoreTF1_1miss, det

*New version of CC variable:

gen MFQsummscoreTF1_cc=0
replace MFQsummscoreTF1_cc=. if ff6500<-1 |  ff6500==.
foreach var of varlist ff6500 ff6502 ff6503 ff6504 ff6505 ff6506 ff6508 ff6509  ff6511 ff6512 ff6513 ff6514 ff6515 {
replace  MFQsummscoreTF1_cc= MFQsummscoreTF1_cc+`var'_v2 if `var'_v2>-1
}
fre MFQsummscoreTF1_cc if nmiss_MFQsummscoreTF1==1
*Replace to missing also people missing exactly 1:
replace  MFQsummscoreTF1_cc=. if nmiss_MFQsummscoreTF1==1

tab MFQsummscoreTF1_cc
label variable MFQsummscoreTF1 "MFQ summary score at age 12.5 TF1: complete cases only"
summ MFQsummscoreTF1_cc, det

*TF2:
*Check coding of the rest:
fre fg7200-fg7225
*Current coding is 1=true 2=sometimes 3=not at all
*Needs to be: "not true" = 0 points "somewhat true" = 1 point "true" = 2 points

*Dummy items: 
fre fg7211 fg7217 fg7220

*Recode and add up the real questions:
foreach var of varlist fg7210 fg7212 fg7213 fg7214 fg7215 fg7216 fg7218 fg7219 fg7221 fg7222 fg7223 fg7224 fg7225 {
gen `var'_v2=`var'
recode `var'_v2 3=0 2=12 1=2
recode `var'_v2 12=1
}
*Identify case-missigness: here coded -2:
gen nmiss_MFQsummscoreTF2=0
*code to missing for people not there or who skipped whole task:
replace nmiss_MFQsummscoreTF2=. if fg7212==-10 |  fg7212==-6 |  fg7212==-5 |  fg7212==.
foreach var of varlist fg7210 fg7212 fg7213 fg7214 fg7215 fg7216 fg7218 fg7219 fg7221 fg7222 fg7223 fg7224 fg7225 {
replace nmiss_MFQsummscoreTF2=nmiss_MFQsummscoreTF2+1 if `var'==-2
}
fre nmiss_MFQsummscoreTF2

*Summary score allownig 1 item missing
gen MFQsummscoreTF2_1miss=0
replace MFQsummscoreTF2_1miss=. if fg7210<=-10 |fg7210<=-6 |fg7210<=-5 | fg7210<=-3 |  fg7210==.
foreach var of varlist fg7210 fg7212 fg7213 fg7214 fg7215 fg7216 fg7218 fg7219 fg7221 fg7222 fg7223 fg7224 fg7225 {
replace  MFQsummscoreTF2_1miss= MFQsummscoreTF2_1miss+`var'_v2 if `var'_v2>-1
}
fre MFQsummscoreTF2_1miss if nmiss_MFQsummscoreTF2==1
*Now upweight for people missing exactly 1:
replace  MFQsummscoreTF2_1miss=MFQsummscoreTF2_1miss*(13/12) if nmiss_MFQsummscoreTF2==1

tab MFQsummscoreTF2_1miss
label variable MFQsummscoreTF2_1miss "MFQ summary score at age 13.5 TF2: 1 item-level missingness allowed"
summ MFQsummscoreTF2_1miss, det

*New version of complete case variable:
gen MFQsummscoreTF2_cc=0
replace MFQsummscoreTF2_cc=. if fg7210==-10 |fg7210==-6 |fg7210==-5 | fg7210==-3 |  fg7210==.
foreach var of varlist fg7210 fg7212 fg7213 fg7214 fg7215 fg7216 fg7218 fg7219 fg7221 fg7222 fg7223 fg7224 fg7225 {
replace  MFQsummscoreTF2_cc= MFQsummscoreTF2_cc+`var'_v2 if `var'_v2>-1
}
fre MFQsummscoreTF2_cc if nmiss_MFQsummscoreTF2==1
*Now upweight for people missing exactly 1:
replace  MFQsummscoreTF2_cc=. if nmiss_MFQsummscoreTF2==1

tab MFQsummscoreTF2_cc
label variable MFQsummscoreTF2_cc "MFQ summary score at age 13.5 TF2: complete cases only"
summ MFQsummscoreTF2_cc, det


*CCS:
*Check coding of the rest:
fre ccs4500-ccs4516
*Current coding is 1=true 2=sometimes 3=not at all
*Needs to be: "not true" = 0 points "somewhat true" = 1 point "true" = 2 points

*Dummy items: four
fre ccs4501 ccs4507 ccs4510 ccs4516

*Recode and add up the real questions:
foreach var of varlist ccs4500 ccs4502 ccs4503 ccs4504 ccs4505 ccs4506 ccs4508 ccs4509 ccs4511 ccs4512 ccs4513 ccs4514 ccs4515 {
gen `var'_v2=`var'
recode `var'_v2 3=0 2=12 1=2
recode `var'_v2 12=1
}
*Identify case-missigness: here coded -2:
gen nmiss_MFQsummscoreCCS=0
*code to missing for people not there or who skipped whole task:
replace nmiss_MFQsummscoreTF2=. if ccs4500==-10 |  ccs4500==.
foreach var of varlist ccs4500 ccs4502 ccs4503 ccs4504 ccs4505 ccs4506 ccs4508 ccs4509 ccs4511 ccs4512 ccs4513 ccs4514 ccs4515 {
replace nmiss_MFQsummscoreCCS=nmiss_MFQsummscoreCCS+1 if `var'==-1
}
fre nmiss_MFQsummscoreCCS

*Summary score allownig 1 item missing
gen MFQsummscoreCCS_1miss=0
replace MFQsummscoreCCS_1miss=. if ccs4500==-10 |  ccs4500==.
foreach var of varlist ccs4500 ccs4502 ccs4503 ccs4504 ccs4505 ccs4506 ccs4508 ccs4509 ccs4511 ccs4512 ccs4513 ccs4514 ccs4515 {
replace  MFQsummscoreCCS_1miss= MFQsummscoreCCS_1miss+`var'_v2 if `var'_v2>-1
}
fre MFQsummscoreCCS_1miss if nmiss_MFQsummscoreCCS==1
*Now upweight for people missing exactly 1:
replace  MFQsummscoreCCS_1miss=MFQsummscoreCCS_1miss*(13/12) if nmiss_MFQsummscoreCCS==1

tab MFQsummscoreCCS_1miss
label variable MFQsummscoreCCS_1miss "MFQ summary score at age 16.5 ccs: 1 item-level missingness allowed"
summ MFQsummscoreCCS_1miss, det

*Summary score allownig 1 item missing
gen MFQsummscoreCCS_cc=0
replace MFQsummscoreCCS_cc=. if ccs4500==-10 |  ccs4500==.
foreach var of varlist ccs4500 ccs4502 ccs4503 ccs4504 ccs4505 ccs4506 ccs4508 ccs4509 ccs4511 ccs4512 ccs4513 ccs4514 ccs4515 {
replace  MFQsummscoreCCS_cc= MFQsummscoreCCS_cc+`var'_v2 if `var'_v2>-1
}
fre MFQsummscoreCCS_cc if nmiss_MFQsummscoreCCS==1
*Missing also for people missing exactly 1:
replace  MFQsummscoreCCS_cc=. if nmiss_MFQsummscoreCCS==1

tab MFQsummscoreCCS_cc
label variable MFQsummscoreCCS_cc "MFQ summary score at age 16.5 ccs: complete cases only"
summ MFQsummscoreCCS_cc, det

*FIX CC VERSIONS: F10 TF1 and CCS
drop MFQsummscoreF10
*4th dummy item fddp126 included
gen MFQsummscoreF10=0
foreach var of varlist fddp110 fddp112 fddp113 fddp114 fddp115 fddp116 fddp118 fddp119 fddp121 fddp122 fddp123 fddp124 fddp125 {
replace  MFQsummscoreF10= MFQsummscoreF10+`var'_v2 if `var'_v2>-1
replace  MFQsummscoreF10=. if `var'<0
}
tab MFQsummscoreF10
*3.3% over threshold using complete cases
label variable MFQsummscoreF10 "MFQ summary score at age 10 F10: no missingness allowed"

*TF1: different error: 0 rather than missing for people with negative codes or whole missingness 
*Hence, currently 0s for people not there at all
replace  MFQsummscoreTF1=. if ff6500==.
replace  MFQsummscoreTF1=. if ff6500<-1

drop MFQsummscoreCCS
*item 11 rather than 10 left out, also 4th dummy item 16 included
gen MFQsummscoreCCS=0
foreach var of varlist ccs4500 ccs4502 ccs4503 ccs4504 ccs4505 ccs4506 ccs4508 ccs4509 ccs4511 ccs4512 ccs4513 ccs4514 ccs4515  {
replace  MFQsummscoreCCS= MFQsummscoreCCS+`var'_v2 if `var'_v2>-1
replace  MFQsummscoreCCS=. if `var'<0
}
tab MFQsummscoreCCS
*MUCH MORE SCORING >=12 THRESHOLD AT AGE 16 - 20% vs 6% AT EARLIER TIMEPOINTS.
label variable MFQsummscoreCCS "MFQ summary score at age 16 CCS: no missingness allowed"

*Compare CC and prorated:
foreach t in F10 TF1 TF2 CCS {
summ MFQsummscore`t' MFQsummscore`t'_1miss MFQsummscore`t'_cc 
fre nmiss_MFQsummscore`t'
count if MFQsummscore`t'==. & MFQsummscore`t'_1miss!=.
count if MFQsummscore`t'_cc==. & MFQsummscore`t'_1miss!=.
}

**************************************
*Standardize all of them
foreach t in F10 TF1 TF2 CCS {
egen zMFQ_`t'_cc=std(MFQsummscore`t'_cc)
egen zMFQ_`t'_1miss=std(MFQsummscore`t'_1miss)
}
summ zMFQ_*

***************************************

*ASD - binary measure plus SCDC scores at various points
*Hard measure: add mother ever-report of diagnosis at 9.5y and the cases from record linkage:
*Mother report of ever diagnosed:
fre ku360
*86 cases from record linkage:
tab ku360 autism
*not great agreement - of the 86 with yes from the external souce, a bit less than half have a 1 for mother report of doctor diagnosis at 9.5y
gen ASD_DL=.
replace ASD_DL=0 if ku360==1
replace ASD_DL=1 if ku360==2
fre ASD_DL
replace ASD_DL=. if ASD_DL<0
replace ASD_DL=1 if autism==1
fre ASD_DL

*Mother-reported SCDC from 7, 10 and 13 and 16.5
*Need to decide about missingness allowed.
*Also, error in your cloned age7 one, so redo using kr554a not kr554b:
drop SSCMsummscorekr
clonevar SSCMsummscorekr=kr554a
recode SSCMsummscorekr -6=.
label variable SSCMsummscorekr "SCDC summ score, parent report, age 7 kr: no missingness allowed"
*All these based on cmplete case:
summ SSCMsummscorekr SSCMsummscorekv SSCMsummscoretb SSCMsummscoretc

****COMPLETE-CASE AND 1-ITEM MISSINGNESS VERSIONS FOR ALL AGES.
*missigness
gen nmiss_SSCMsummscorekr=0
replace nmiss_SSCMsummscorekr=. if kr539==-6 | kr539==.

foreach num of numlist 539/550 {
replace nmiss_SSCMsummscorekr=nmiss_SSCMsummscorekr+1 if kr`num'==-1
}
tab nmiss_SSCMsummscorekr

*New cc version: need to re-jig 1 to 0, 2 to 1 etc as scale is supposed to run 0-24
gen SSCMsummscorekr_cc=0
replace SSCMsummscorekr_cc=. if nmiss_SSCMsummscorekr!=0
fre SSCMsummscorekr_cc
foreach num of numlist 539/550 {
*fre kr`num'
replace SSCMsummscorekr_cc=SSCMsummscorekr_cc+((kr`num')-1)
}
tab SSCMsummscorekr_cc
summ SSCMsummscorekr_cc
label variable SSCMsummscorekr_cc "SCDC summ score, parent report, age 7 kr: complete case"

*Version allowing 1 item missingness.
gen SSCMsummscorekr_1miss=0
replace SSCMsummscorekr_1miss=. if nmiss_SSCMsummscorekr==. 
fre SSCMsummscorekr_1miss
foreach num of numlist 539/550 {
*fre kr`num'
replace SSCMsummscorekr_1miss=SSCMsummscorekr_1miss+((kr`num')-1) if kr`num'>0
}
*Uprate:
replace SSCMsummscorekr_1miss=SSCMsummscorekr_1miss*(12/11) if nmiss_SSCMsummscorekr==1
tab SSCMsummscorekr_1miss
summ SSCMsummscorekr_1miss
label variable SSCMsummscorekr_1miss "SCDC summ score, parent report, age 7 kr: 1 item missigness allowed"

*Check and drop original:
summ SSCMsummscorekr SSCMsummscorekr_cc
drop SSCMsummscorekr

*Age 10: 
fre kv8520-kv8531
*missigness
gen nmiss_SSCMsummscorekv=0
replace nmiss_SSCMsummscorekv=. if kv8520==-10 | kv8520==.

foreach num of numlist 8520/8531 {
replace nmiss_SSCMsummscorekv=nmiss_SSCMsummscorekv+1 if kv`num'==-1
}
tab nmiss_SSCMsummscorekv
*New cc version: need to re-jig 1 to 0, 2 to 1 etc as scale is supposed to run 0-24
gen SSCMsummscorekv_cc=0
replace SSCMsummscorekv_cc=. if nmiss_SSCMsummscorekv!=0
fre SSCMsummscorekv_cc
foreach num of numlist 8520/8531 {
*fre kv`num'
replace SSCMsummscorekv_cc=SSCMsummscorekv_cc+((kv`num')-1)
}
tab SSCMsummscorekv_cc
summ SSCMsummscorekv_cc
label variable SSCMsummscorekv_cc "SCDC summ score, parent report, age 10 kv: complete case"

*Version allowing 1 item missingness.
gen SSCMsummscorekv_1miss=0
replace SSCMsummscorekv_1miss=. if nmiss_SSCMsummscorekv==. 
fre SSCMsummscorekv_1miss
foreach num of numlist 8520/8531 {
*fre kv`num'
replace SSCMsummscorekv_1miss=SSCMsummscorekv_1miss+((kv`num')-1) if kv`num'>0
}
*Uprate:
replace SSCMsummscorekv_1miss=SSCMsummscorekv_1miss*(12/11) if nmiss_SSCMsummscorekv==1
tab SSCMsummscorekv_1miss
summ SSCMsummscorekv_1miss
label variable SSCMsummscorekv_1miss "SCDC summ score, parent report, age 10 kv: 1 item missigness allowed"

*Check and drop original:
summ SSCMsummscorekv SSCMsummscorekv_cc
drop SSCMsummscorekv

*Age 13
*missigness
gen nmiss_SSCMsummscoretb=0
replace nmiss_SSCMsummscoretb=. if tb8520==-10 | tb8520==.

foreach num of numlist 8520/8531 {
replace nmiss_SSCMsummscoretb=nmiss_SSCMsummscoretb+1 if tb`num'==-1
}
tab nmiss_SSCMsummscoretb
*New cc version: need to re-jig 1 to 0, 2 to 1 etc as scale is supposed to run 0-24
gen SSCMsummscoretb_cc=0
replace SSCMsummscoretb_cc=. if nmiss_SSCMsummscoretb!=0
fre SSCMsummscoretb_cc
foreach num of numlist 8520/8531 {
*fre tb`num'
replace SSCMsummscoretb_cc=SSCMsummscoretb_cc+((tb`num')-1)
}
tab SSCMsummscoretb_cc
summ SSCMsummscoretb_cc
label variable SSCMsummscoretb_cc "SCDC summ score, parent report, age 13 tb: complete case"

*Version allowing 1 item missingness.
gen SSCMsummscoretb_1miss=0
replace SSCMsummscoretb_1miss=. if nmiss_SSCMsummscoretb==. 
fre SSCMsummscoretb_1miss
foreach num of numlist 8520/8531 {
*fre tb`num'
replace SSCMsummscoretb_1miss=SSCMsummscoretb_1miss+((tb`num')-1) if tb`num'>0
}
*Uprate:
replace SSCMsummscoretb_1miss=SSCMsummscoretb_1miss*(12/11) if nmiss_SSCMsummscoretb==1
tab SSCMsummscoretb_1miss
summ SSCMsummscoretb_1miss
label variable SSCMsummscoretb_1miss "SCDC summ score, parent report, age 13 tb: 1 item missigness allowed"

*Check and drop original:
summ SSCMsummscoretb SSCMsummscoretb_cc
drop SSCMsummscoretb

*Age 16:
fre tc4050-tc4061
*missigness
gen nmiss_SSCMsummscoretc=0
replace nmiss_SSCMsummscoretc=. if tc4050==-10 | 4050==.

foreach num of numlist 4050/4061 {
replace nmiss_SSCMsummscoretc=nmiss_SSCMsummscoretc+1 if tc`num'==-1
}
tab nmiss_SSCMsummscoretc
*New cc version: need to re-jig 1 to 0, 2 to 1 etc as scale is supposed to run 0-24
gen SSCMsummscoretc_cc=0
replace SSCMsummscoretc_cc=. if nmiss_SSCMsummscoretc!=0
fre SSCMsummscoretc_cc
foreach num of numlist 4050/4061 {
*fre tc`num'
replace SSCMsummscoretc_cc=SSCMsummscoretc_cc+((tc`num')-1)
}
tab SSCMsummscoretc_cc
summ SSCMsummscoretc_cc
label variable SSCMsummscoretc_cc "SCDC summ score, parent report, age 16 tc: complete case"

*Version allowing 1 item missingness.
gen SSCMsummscoretc_1miss=0
replace SSCMsummscoretc_1miss=. if nmiss_SSCMsummscoretc==. 
fre SSCMsummscoretc_1miss
foreach num of numlist 4050/4061 {
*fre tc`num'
replace SSCMsummscoretc_1miss=SSCMsummscoretc_1miss+((tc`num')-1) if tc`num'>0
}
*Uprate:
replace SSCMsummscoretc_1miss=SSCMsummscoretc_1miss*(12/11) if nmiss_SSCMsummscoretc==1
tab SSCMsummscoretc_1miss
summ SSCMsummscoretc_1miss
label variable SSCMsummscoretc_1miss "SCDC summ score, parent report, age 16 tc: 1 item missigness allowed"

*Check and drop original:
summ SSCMsummscoretc SSCMsummscoretc_cc
drop SSCMsummscoretc

**********************************************************
*Standardize them
foreach t in kr kv tb tc {
egen zSCDC_`t'_1miss=std(SSCMsummscore`t'_1miss)
egen zSCDC_`t'_cc=std(SSCMsummscore`t'_cc)
}
summ zSCDC_*

************************************************************

*ASTHMA - Raquel's derived vars for asthma in past 12 months:
fre as*
*Already cleaned
fre as_81 as_91 as_103 as_128 as_157 as_166 eas_198

*Migraine
recode MigrainesF10 -1=. 2=0
fre MigrainesF10

*Measured BMI at clinics
foreach var in f7ms026a f9ms026a fdms026a fems026a ff2039 fg3139 fh3019 {
replace `var'=. if `var'<0
}
*For F8, need to derive - height in cm:
summ f8lf020 f8lf021, det
gen F8_BMI=f8lf021/((f8lf020/100)^2)
replace F8_BMI=. if f8lf020<0 | f8lf021<0
label variable F8_BMI "BMI at F8, from lung function-related f8lf020 and f8lf021"
summ F8_BMI

*Self-report measures? Leave for now - N not great anyway
summ f7ms026a f9ms026a fdms026a fems026a ff2039 fg3139 fh3019

*Use zanthro to standardize measured BMI.
*Needs: 
*spec of reference chart - we want bmi for age, so "ba", and UK 1990 reference standards
*gender, age in years, specification of gender coding

*Age in years at clinics: derive from months
summ f7003c f8003c f9003c fd003c fe003c ff0011a fg0011a fh0011a
gen  ageyrs_F7=f7003c
gen  ageyrs_F8=f8003c
gen  ageyrs_F9=f9003c
gen  ageyrs_F10=fd003c 
gen  ageyrs_F11=fe003c 
gen  ageyrs_TF1=ff0011a 
gen  ageyrs_TF2=fg0011a 
gen  ageyrs_TF3=fh0011a

foreach var in ageyrs_F7 ageyrs_F8 ageyrs_F9 ageyrs_F10 ageyrs_F11 ageyrs_TF1 ageyrs_TF2 ageyrs_TF3 {
replace `var'=. if `var'<0
replace `var'=`var'/12
summ `var'
}
*Standarize the BMI measures
egen zbmi_F7 = zanthro(f7ms026a, ba, UK), xvar(ageyrs_F7) gender(gender) gencode(male=1, female=2)
*Not sure this is comparable so leave for now
*egen zbmi_F8 = zanthro(F8_BMI, ba, UK), xvar(ageyrs_F8) gender(gender) gencode(male=1, female=2)
egen zbmi_F9 = zanthro(f9ms026a, ba, UK), xvar(ageyrs_F9) gender(gender) gencode(male=1, female=2)
egen zbmi_F10 = zanthro(fdms026a, ba, UK), xvar(ageyrs_F10) gender(gender) gencode(male=1, female=2)
egen zbmi_F11 = zanthro(fems026a, ba, UK), xvar(ageyrs_F11) gender(gender) gencode(male=1, female=2)
egen zbmi_TF1 = zanthro(ff2039, ba, UK), xvar(ageyrs_TF1) gender(gender) gencode(male=1, female=2)
egen zbmi_TF2 = zanthro(fg3139, ba, UK), xvar(ageyrs_TF2) gender(gender) gencode(male=1, female=2)
egen zbmi_TF3 = zanthro(fh3019, ba, UK), xvar(ageyrs_TF3) gender(gender) gencode(male=1, female=2)

foreach var in zbmi_F7 zbmi_F9 zbmi_F10 zbmi_F11 zbmi_TF1 zbmi_TF2 zbmi_TF3 {
label variable `var'  "age-and-gender-standardized BMI, using UK 1990 growth reference chart"
}

foreach var in zbmi_F7 zbmi_F9 zbmi_F10 zbmi_F11 zbmi_TF1 zbmi_TF2 zbmi_TF3 {
summ `var'
}
*************

*GCSEs:
foreach var in gender  ks4_ptscnewe ks4_fiveac ks4_lev2em {
replace `var'=. if `var'<0
}

**ABSENCES:
*arranged by calendar year.

*Key variables for each calendar year are total reported absences, total sessions, and the % of absence using those two. Code to . the -10s:
foreach year in 2007 2008 2009 {
foreach var in lab_totalabsence`year' lab_totalsessionsposs`year' lab_percentofsessionsmissed`year' {
recode `var' -10=.
fre `var'
}
}
foreach year in 2007 2008 2009 {
foreach var in lab_totalabsence`year' lab_totalsessionsposs`year' lab_percentofsessionsmissed`year' {
summ `var', det
tab ks4year, summ (`var')
*OK - so in later years, excess zeros for people who were too old to have data. Not a problem, as get a missing for % 
}
}
*Arranged by calendar year, so different ones for different school years depending on when the kid was born, and more info for younger participants:
foreach year in 2007 2008 2009 {
summ lab_totalabsence`year' lab_totalsessionsposs`year' lab_percentofsessionsmissed`year' if ks4year==12 
summ lab_totalabsence`year' lab_totalsessionsposs`year' lab_percentofsessionsmissed`year' if ks4year==13 
summ lab_totalabsence`year' lab_totalsessionsposs`year' lab_percentofsessionsmissed`year' if ks4year==14
}

*DERIVED VARIABLE FOR % ABSENCE EXISTS, although there are two issues with it:
*Firstly, they coded to missing anyone with a 0 for number of sessions absent, even though presumably there would have been some:
foreach year in 2007 2008 2009 {
count if lab_percentofsessionsmissed`year'==. & (lab_totalsessionsposs`year'!=0 &  lab_totalsessionsposs`year'!=.)
list lab_totalabsence`year' lab_totalsessionsposs`year' lab_percentofsessionsmissed`year' if lab_percentofsessionsmissed`year'==. & (lab_totalsessionsposs`year'!=0 &  lab_totalsessionsposs`year'!=.)
}
*Secondly, includes implausible values for possible sessions, nobody has been given a missing % on this basis.

*Weird outliers, not about exam period in year 11:
foreach year in 2007 2008 2009 {
summ lab_totalsessionsposs`year' if ks4year==12, det
summ lab_totalsessionsposs`year' if ks4year==13, det
summ lab_totalsessionsposs`year' if ks4year==14, det
}

*rename the existing derived vars:
rename lab_percentofsessionsmissed2007 lab_propofsessionsmissed2007
rename lab_percentofsessionsmissed2008 lab_propofsessionsmissed2008
rename lab_percentofsessionsmissed2009 lab_propofsessionsmissed2009
*Called it 'prop' as isn't a percentage

*NOW REARRANGE TO ALIGN WITH SCHOOL YEARS:
foreach varstem in lab_totalabsence lab_totalsessionsposs lab_propofsessionsmissed {
*Year 11
gen `varstem'year11=`varstem'2007 if ks4year==12
replace `varstem'year11=`varstem'2008 if ks4year==13
replace `varstem'year11=`varstem'2009 if ks4year==14
summ `varstem'year11, det
*Year 10
gen `varstem'year10=`varstem'2007 if ks4year==13
replace `varstem'year10=`varstem'2008 if ks4year==14
summ `varstem'year10, det
*Year 9
gen `varstem'year9=`varstem'2007 if ks4year==14
summ `varstem'year9
}
summ lab_totalabsenceyear*
summ lab_totalsessionspossyear*
summ lab_propofsessionsmissedyear*

*Look at the poss sessions in more detail:
summ lab_totalsessionspossyear*, det

hist lab_totalsessionspossyear11
hist lab_totalsessionspossyear10
hist lab_totalsessionspossyear9

***FOR EACH OF THE TOTAL SESSIONS POSS VARIABLES, BY SCHOOL YEAR:
foreach year in year11 year10 year9 {
summ lab_totalsessionsposs`year' if lab_totalsessionsposs`year'!=0, det
return list
count if lab_totalsessionsposs`year'!=0 & lab_totalsessionsposs`year'!=. & (lab_totalsessionsposs`year'<230 | lab_totalsessionsposs`year'>320)
list lab_totalsessionsposs`year' lab_totalabsence`year' lab_propofsessionsmissed`year'  ks4_nftype ks4_toe_code if lab_totalsessionsposs`year'!=0 & lab_totalsessionsposs`year'!=. & lab_totalsessionsposs`year'<230 
list lab_totalsessionsposs`year' lab_totalabsence`year' lab_propofsessionsmissed`year'  ks4_nftype ks4_toe_code if lab_totalsessionsposs`year'!=0 & lab_totalsessionsposs`year'!=. &  lab_totalsessionsposs`year'>320
}
*low values - does to some extent seem to be about school type, e.g. PRUs records only part of the year evidently.
foreach year in year11 year10 year9 {
tab ks4_toe_code, summ (lab_totalsessionsposs`year' )
}
*still contain infomration, so decision to just trim top outliers, those above plausible values
*If only recorded to end of May, that's minus the last 6 weeks of term = 33 weeks = 330 sessions. NB using 32 gives you 14, 20, 3 trimmed so no difference
foreach year in year11 year10 year9 {
count if lab_totalsessionsposs`year'!=0 & lab_totalsessionsposs`year'!=. &  lab_totalsessionsposs`year'>330
}
*14, 9, 3

*flag outliers. zeros for possible sessions contain no info
capture drop totalsessionsposs_outlier*
foreach year in year11 year10 year9 {
gen totalsessionsposs_outlier`year'=.
replace totalsessionsposs_outlier`year'=lab_totalsessionsposs`year' if lab_totalsessionsposs`year'==0
*Then the implausiblt high ones:
summ lab_totalsessionsposs`year' if lab_totalsessionsposs`year'!=0, det
return list
replace totalsessionsposs_outlier`year'=lab_totalsessionsposs`year' if lab_totalsessionsposs`year'>330 & lab_totalsessionsposs`year'!=.
}

*Examine what's left:
foreach year in year11 year10 year9 {
summ lab_totalsessionsposs`year' if totalsessionsposs_outlier`year'==., det
}
*Fine.

*new variables for absence as a percent of total sessions, but coded to missing for implausible root vars
foreach year in year11 year10 year9 {
gen percent_absence`year'=(lab_totalabsence`year'/lab_totalsessionsposs`year')*100 if totalsessionsposs_outlier`year'==.
*check nobody has it who shouldnt
list percent_absence`year' if totalsessionsposs_outlier`year'!=.
}
summ percent_absenceyear*, det
*Good

*Log-transform for imputation, adding 1 for the zeros now this is in percent: 
foreach var in percent_absenceyear11 percent_absenceyear10 percent_absenceyear9 {
gen log_`var'=log(`var'+1)
sum log_`var', det
}
hist log_percent_absenceyear11 
hist log_percent_absenceyear10 
hist log_percent_absenceyear9
 
*Check against existing derived vars: Note the group which was given missing for proportion absent if they had a zero for number of absences
foreach year in year11 year10 year9 {
list lab_totalabsence`year' lab_totalsessionsposs`year' lab_propofsessionsmissed`year' percent_absence`year' if lab_propofsessionsmissed`year'==. & percent_absence`year'!=. 
count if lab_propofsessionsmissed`year'==. & percent_absence`year'!=. 
}
*Post-imputation, untransform and remove the 0.01, then make y1011 and y91011 versions by combining and / by 2 or 3

*extra: as well as total absence, prep for type-specific: authorised, unauthorised
summ lab_totalabsence2007 lab_totalabsence2008 lab_totalabsence2009
summ lab_totalauthabsence2007 lab_totalauthabsence2008 lab_totalauthabsence2009
summ lab_totalunauthabsence2007 lab_totalunauthabsence2008 lab_totalunauthabsence2009

foreach var of varlist lab_totalauthabsence2007-lab_totalunauthabsence2009 {
replace `var'=. if `var'<0
}
*map these onto school years as for total absence.
*again, the absence variables appear to be suffixed with the year in which the academic year ENDS (eg 2007 for 2006/2007)
*we actually have data on absences in y10 for the middle cohort, and y9 and y10 for the youngest cohort.

*Make variables for all absence types for everyone:
capture drop year11_totalabsence year11_totalauthabsence year11_totalunauthabsence
*y11
foreach type in total totalauth totalunauth {
gen year11_`type'absence=lab_`type'absence2007 if ks4year==12
replace year11_`type'absence=lab_`type'absence2008 if ks4year==13
replace year11_`type'absence=lab_`type'absence2009 if ks4year==14
}
*y10
foreach type in total totalauth totalunauth {
gen year10_`type'absence=.
replace year10_`type'absence=lab_`type'absence2007 if ks4year==13
replace year10_`type'absence=lab_`type'absence2008 if ks4year==14
}
*year 9 for the youngest group:
foreach type in total totalauth totalunauth {
gen year9_`type'absence=.
replace year9_`type'absence=lab_`type'absence2007 if ks4year==14
}

*Check they add up:
list year11_totalabsence year11_totalauthabsence year11_totalunauthabsence if year11_totalabsence!=.
list year10_totalabsence year10_totalauthabsence year10_totalunauthabsence if year10_totalabsence!=.
list year9_totalabsence year9_totalauthabsence year9_totalunauthabsence if year9_totalabsence!=.

*code to missing for those where possible sessions was an implausible value
foreach year in 9 10 11 {
foreach type in total totalauth totalunauth {
replace year`year'_`type'absence=. if totalsessionsposs_outlieryear`year'!=.
}
}
*nb wouldn't affect a binary measure of any vs none for unauthorized

summ year11_*absence, det
*Seriously skewed - how to deal with that?

hist year11_totalabsence
hist year11_totalunauthabsence
hist year11_totalauthabsence

*For unauthorized, so many 0s that only legit thing is to use it as a binary.
foreach year in 11 10 9 {
gen year`year'_unauthabsence_BINARY = year`year'_totalunauthabsence
recode year`year'_unauthabsence_BINARY 1/1000=1
fre year`year'_unauthabsence_BINARY 
}

*****************************************************************************************************

*EXTRA ADDITIONS:

*drop borrowed bmi score:
drop scoresum scoresum_maternal

*Extra school experience vars found by Tim C:
merge 1:1 cidB2953 qlet using "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\data\alspac\summary\applications\B2953\dev\B2953_Child_Phenotypes\B2953 Child Phenotypes\ROOT FILES OF ID-SWAPPED DATA\Howe_13Feb19.dta"

*restrict to the 15,616 without withdrawn consent: i.e. the ones in the file with recently identified vars
drop if _merge!=3
drop _merge

*SAVE POINT
save Phenotypes_and_NPD.dta, replace


************************************************************************************************************

*PGS/INSTRUMENTED ASSOCIATIONS: PREP


*ASTHMA: update: 6 genome-wide signification SNPs only. Now the only one using 10-7 threshold in ASD
clear
import delimited scores_from_plink\asthma_score.profile, delimiter(whitespace, collapse) 
*convert the ids into one which can be merged on, by stripping off the qlet from cidB2953
split iid, p("M" "A" "B")
gen qlet=substr(iid,-1,1)
rename iid1 cidB2953
destring cidB2953, replace
*Drop the useless stuff (NOT what the labels imply!)
drop v1 fid iid pheno
*Rename to fix weird shift in variable names:
rename scoresum asthma_score
rename cnt asthma_cnt
*Standardize the score for comparison:
egen zasthma_score=std(asthma_score)
save "scores_from_plink\asthma_score.dta", replace

*MIGRAINE
clear
import delimited scores_from_plink\migraine_score.profile, delimiter(whitespace, collapse) 
*convert the ids into one which can be merged on, by stripping off the qlet from cidB2953
split iid, p("M" "A" "B")
gen qlet=substr(iid,-1,1)
rename iid1 cidB2953
destring cidB2953, replace
*Drop the useless stuff (NOT what the labels imply!)
drop v1 fid iid pheno
*Rename
rename scoresum migraine_score
rename cnt migraine_cnt
*Standardize the score for comparison:
egen zmigraine_score=std(migraine_score)
save "scores_from_plink\migraine_score.dta", replace

*YENGOBMI
*Clumped normal betas, made from clumping the whole-GWAS data.
clear
import delimited scores_from_plink\yengobmi_score.profile, delimiter(whitespace, collapse) 
*convert the ids into one which can be merged on, by stripping off the qlet from cidB2953
split iid, p("M" "A" "B")
gen qlet=substr(iid,-1,1)
rename iid1 cidB2953
destring cidB2953, replace
*Drop the useless stuff (NOT what the labels imply!)
drop v1 fid iid pheno
*Rename
rename scoresum yengobmi_score
rename cnt yengobmi_cnt
*Standardize the score for comparison:
egen zyengobmi_score=std(yengobmi_score)
save "scores_from_plink\yengobmi_score.dta", replace

*ASD
clear
import delimited scores_from_plink\asd_score.profile, delimiter(whitespace, collapse) 
*convert the ids into one which can be merged on, by stripping off the qlet from cidB2953
split iid, p("M" "A" "B")
gen qlet=substr(iid,-1,1)
rename iid1 cidB2953
destring cidB2953, replace
*Drop the useless stuff (NOT what the labels imply!)
drop v1 fid iid pheno
*Rename to fix weird shift in variable names:
rename scoresum asd_score
rename cnt asd_cnt
*Standardize the score for comparison:
egen zasd_score=std(asd_score)
save "scores_from_plink\asd_score.dta", replace

*ADHD: update, 9-SNP version of ones genom-wide sig in Europeans only
clear
import delimited scores_from_plink\adhd_score.profile, delimiter(whitespace, collapse) 
*convert the ids into one which can be merged on, by stripping off the qlet from cidB2953
split iid, p("M" "A" "B")
gen qlet=substr(iid,-1,1)
rename iid1 cidB2953
destring cidB2953, replace
*Drop the useless stuff (NOT what the labels imply!)
drop v1 fid iid pheno
*Rename to fix weird shift in variable names:
rename scoresum adhd_score
rename cnt adhd_cnt
*Standardize the score for comparison:
egen zadhd_score=std(adhd_score)
save "scores_from_plink\adhd_score.dta", replace

*DEPRESS (versions with 10-8 and 10-7 p-value thresholds)
clear
import delimited scores_from_plink\depress_score.profile, delimiter(whitespace, collapse) 
*convert the ids into one which can be merged on, by stripping off the qlet from cidB2953
split iid, p("M" "A" "B")
gen qlet=substr(iid,-1,1)
rename iid1 cidB2953
destring cidB2953, replace
*Drop the useless stuff (NOT what the labels imply!)
drop v1 fid iid pheno
*Rename to fix weird shift in variable names:
rename scoresum depress_score
rename cnt depress_cnt
*Standardize the score for comparison:
egen zdepress_score=std(depress_score)
save "scores_from_plink\depress_score.dta", replace


*Outliers check
clear
import delimited scores_from_plink\nooutliers_yengobmi_score.profile, delimiter(whitespace, collapse) 
*convert the ids into one which can be merged on, by stripping off the qlet from cidB2953
split iid, p("M" "A" "B")
gen qlet=substr(iid,-1,1)
rename iid1 cidB2953
destring cidB2953, replace
*Drop the useless stuff (NOT what the labels imply!)
drop v1 fid iid pheno
*Rename
rename scoresum nooutliers_yengobmi_score
rename cnt nooutliers_yengobmi_cnt
*Standardize the score for comparison:
egen znooutliers_yengobmi_score=std(nooutliers_yengobmi_score)
save "scores_from_plink\nooutliers_yengobmi_score.dta", replace

*************************************************

*COMBINE:

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

*set maxvar 30000
use "Phenotypes_and_NPD.dta", clear

merge 1:1 cidB2953 qlet using scores_from_plink\asthma_score.dta
*For now, only care about the children so drop the observations corresponding to the mothers, i.e. _merge==2
drop if _merge==2
drop _merge

merge 1:1 cidB2953 qlet using scores_from_plink\migraine_score.dta
*For now, only care about the children so drop the observations corresponding to the mothers, i.e. _merge==2
drop if _merge==2
drop _merge

merge 1:1 cidB2953 qlet using scores_from_plink\yengobmi_score.dta
*For now, only care about the children so drop the observations corresponding to the mothers, i.e. _merge==2
drop if _merge==2
drop _merge

merge 1:1 cidB2953 qlet using scores_from_plink\asd_score.dta
*For now, only care about the children so drop the observations corresponding to the mothers, i.e. _merge==2
drop if _merge==2
drop _merge

merge 1:1 cidB2953 qlet using scores_from_plink\adhd_score.dta
*For now, only care about the children so drop the observations corresponding to the mothers, i.e. _merge==2
drop if _merge==2
drop _merge

merge 1:1 cidB2953 qlet using scores_from_plink\depress_score.dta
*For now, only care about the children so drop the observations corresponding to the mothers, i.e. _merge==2
drop if _merge==2
drop _merge

*Outliers checks
merge 1:1 cidB2953 qlet using scores_from_plink\nooutliers_yengobmi_score.dta
*For now, only care about the children so drop the observations corresponding to the mothers, i.e. _merge==2
drop if _merge==2
drop _merge


*TERTILES
foreach pgs in zasthma_score zmigraine_score zyengobmi_score zadhd_score zdepress_score zasd_score {
xtile `pgs'_tertiles = `pgs', nquantiles(3)
}

save  "Phenotypes_and_NPD_and_PGSs.dta", replace

***********************************************
*ADD THE PCs (available for unrelated individuals only, so using these will mean restricting the sample):
clear
import delimited "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\\059\working\data\Mandy\PCs\PCs_children1000G.csv"

split newids, p("_A" "_B")
gen qlet=substr(newids,-1,1)
fre qlet
rename newids1 cidB2953
destring cidB2953, replace
*Drop the useless stuff 
drop newids

****RENAME THE PCs:
foreach num of numlist 3/22 {
local i=`num'-2
rename v`num' v`i'
rename v`i' PC`i'
label variable PC`i' "PC`i' - unrelated individuals only"
}

save "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\\059\working\data\Mandy\PCs\PCs_children1000G.dta", replace

***********************************************

use  "Phenotypes_and_NPD_and_PGSs.dta", clear

merge 1:1 cidB2953 qlet using "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\\059\working\data\Mandy\PCs\PCs_children1000G.dta"
**Drop the small unusable group newly entered from the genetic file 
drop if _merge==2
drop _merge

*Note on the PCs: these are calculated for UNRELATED INDIVIDUALS ONLY, whereas the PGSs are from bgen files which included the further 10% of 
*children who were >0.05 related. So, using the current PCs will restrict sample to related individuals.

save  "Phenotypes_and_NPD_and_PGSs.dta", replace

***************************************************************************************************************************************************

*FINAL BITS OF PREP 

*sort out school type. Will restrict to standard schools in an SA
*FWIW, nobody in analytic sample is missing this (makes sense, as excluding where school id unknown)
fre ks4_toe_code ks4_nftype
replace ks4_toe_code=. if ks4_toe_code<0
replace ks4_nftype=. if ks4_nftype<0
fre ks4_toe_code ks4_nftype

foreach var in k2_stype k3_stype ks4_nftype ks4_toe_code {
replace `var'=. if `var'<0
fre `var'
}
*Which to use? Has three purposes:
*included in imputations
*descriptive stats
*exclusion of non-mainstream schools for an SA

*For 2 and 3, ks4 is most relevant
*For 1...about the same, but could have more than one.
*Least missingness in the ks4 one.

*Categorize school types:

*For ks2:
gen ks2_stype_v2=k2_stype
recode ks2_stype_v2 1/5=1 7=2 11=3 
label var ks2_stype_v2 "grouped ks2 school type"
label define ks2_stype_v2 1"community, voluntary aided/controlled, foundation" 2"community special" 3"other independent"
label values ks2_stype_v2 ks2_stype_v2
fre ks2_stype_v2

*For ks3:
gen ks3_stype_v2=k3_stype
recode ks3_stype_v2 1/5=1 6=1 28=1 7=2 14=2
label var ks3_stype_v2 "grouped ks3 school type"
label define ks3_stype_v2 1"community, vol aided/controlled, foundation, CTC, academy" 2"community special, pupil referral unit"
label values ks3_stype_v2 ks3_stype_v2
fre ks3_stype_v2

*NOTE: NO INDEPENDENT SCHOOLS REPRESENTED IN KS2 OR KS3 VARIABLES, ALSO MORE MISSINGNESS - BECAUSE THEY DIDN'T DECLARE.
*SO JUST USE THE KS4 ONE FOR NOW.

*For ks4:
gen ks4_stype_v2=ks4_toe_code
recode ks4_stype_v2 1/5=1 6=1 28=1 11=2 7=3 14=3 18=3 50=3
label var ks4_stype_v2 "grouped ks4 school type"
label define ks4_stype_v2 1"community, vol aided/controlled, foundation, CTC, academy" 2"other independent" 3"community special, pupil referral unit, further ed, other"
label values ks4_stype_v2 ks4_stype_v2
fre ks4_stype_v2

*******************************************************************

*INSAMPLE FLAG

capture drop ingensample
gen ingensample=1
replace ingensample=0 if inlist(., zasthma_score, zmigraine_score, zyengobmi_score, zasd_score, zadhd_score, zdepress_score)
fre ingensample
*N=8797 with genetic data

*If using the PCs, necessarily restricting to unrelated ppl (941 of 8797 cases)
replace ingensample=0 if inlist(., PC1)
fre ingensample
*7856

*Restrict analytic sample to people with GCSE records. Will use those to impute missingness in absence variables
replace ingensample=0 if inlist(., ks4_ptscnewe)
fre ingensample

*remove 11 for missing school - need the id to cluster by school, and can't impute that
recode ks4sch -1=.
replace ingen=0 if ks4sch==. 
replace ingen=0 if ks4sch==-1 

*******************************************************************

*Covar prep: 

*Family socioeconomic: maternal and paternal education, household social class, housing tenure.
*Maternal: age, parity, smoking during pregnancy, pre-pregnancy BMI.

rename Maternal_age maternal_age

fre c645a homeownership maternal_age b032 smokedinpreg 

*smokedinpreg needs to be 0/1 rather than 1/2 for imputation:

*Overall:
gen smokedinpregv2=.
replace smokedinpregv2=0 if (smoked_firsttrimester==1 & smoked_secondtrimester==1 & smoked_thirdtrimester==1)
replace smokedinpregv2=1 if (smoked_firsttrimester==2 | smoked_secondtrimester==2 | smoked_thirdtrimester==2)
replace smokedinpregv2=. if (smoked_firsttrimester==. & smoked_secondtrimester==. & smoked_thirdtrimester==.)
*label define smokedinpregv2 0"no" 1"yes, any form"
*label values smokedinpregv2 smokedinpregv2
*label variable smokedinpregv2 "Mother smoked in any trimester - includes pipe and 'other' tobacco"
fre smokedinpregv2
*loads of missing.
*Assume that anyone who didn't smoke at the 1st or 2nd but has a missing for the third didn't start then:
replace smokedinpregv2=0 if (smoked_firsttrimester==1 & smoked_secondtrimester==1 & smoked_thirdtrimester==.)
*Who's left?
count  if  smokedinpregv2==. & !(smoked_firsttrimester==. & smoked_secondtrimester==. & smoked_thirdtrimester==.)
*All of the remaining ones with partial info hasve only a no at the 3rd.
list smoked_firsttrimester smoked_secondtrimester smoked_thirdtrimester if  smokedinpregv2==. & !(smoked_firsttrimester==. & smoked_secondtrimester==. & smoked_thirdtrimester==.)
fre smokedinpregv2

*For maternal education, c645a:
*in data collection/processing, mothers who didn't declare anything should be grouped with CSE, since that's the minimum qual possible.
capture drop maternaleduc
clonevar maternaleduc = c645a
*Remove the small missing group:
replace maternaleduc=. if maternaleduc<0
fre maternaleduc

rename b032 maternalparity
recode maternalparity  -1=. -7=. -2=.
fre maternalparity

*Categorize parity: 0, 1, 2, 3+?
gen maternalparity_CATEG=maternalparity
recode maternalparity_CATEG 3/22=3
label define maternalparity_CATEG 0"0" 1"1" 2"2"  3"3 ore more"
label values maternalparity_CATEG maternalparity_CATEG
fre maternalparity_CATEG

*rename c994 maternalage
*No! use this one, which is already a composite you made from questionnaires a and b, so less missingness:
summ maternal_age
*Needs fixing though
recode maternal_age -1=.

gen maternaltenure_simple=homeownership
label var maternaltenure_simple "housing tenure in pregnancy - mortgage or owned/council rented/private or HR rented/other"
recode maternaltenure_simple -1=. 0=1 4/5=3 6=4
tab maternaltenure_simple 

*For mediation with paramed, maternal educ, maternaltenure_simple and maternalparity_CATEG needs to be coded as dummies.
forvalues n=0/5 {
gen maternaleduc_dummy`n'=0
replace maternaleduc_dummy`n'=1 if maternaleduc==`n'
}

forvalues n=1/4 {
gen maternaltenure_dummy`n'=0
replace maternaltenure_dummy`n'=1 if maternaltenure_simple==`n'
}

forvalues n=0/3 {
gen maternalparity_CATEG_dummy`n'=0
replace maternalparity_CATEG_dummy`n'=1 if maternalparity_CATEG==`n'
}

global covars "i.gender i.maternaleduc i.maternaltenure_simple maternal_age i.maternalparity_CATEG i.smokedinpreg"


*For flowchart:
*All
count
*Alive at 1yr, consent not withdrawn as of November 2018
count if kz011b==1
*N=14,862
*usable gentic data:
count if kz011b==1 & zasthma_score!=.
count if kz011b==1 & zasthma_score==.
*8,791
count if kz011b==1 & zasthma_score!=. & PC1!=.
count if kz011b==1 & zasthma_score!=. & PC1==.
*7,851
count if kz011b==1 & zasthma_score!=. & PC1!=. & ks4_ptscnewe!=.
count if kz011b==1 & zasthma_score!=. & PC1!=. & ks4_ptscnewe==.
*6124
count if kz011b==1 & zasthma_score!=. & PC1!=. & ks4_ptscnewe!=. & ks4sch!=. 
*6133

*INSAMPLE FLAG

capture drop ingensample
gen ingensample=1
replace ingensample=0 if inlist(., zasthma_score, zmigraine_score, zyengobmi_score, zasd_score, zadhd_score, zdepress_score)
fre ingensample
*N=8797 with genetic data

*But if using the PCs, necessarily restricting to unrelated ppl (941 of 8797 cases)
replace ingensample=0 if inlist(., PC1)
fre ingensample
*7856

*no GCSE records
replace ingensample=0 if inlist(., ks4_ptscnewe)
fre ingensample

*11 with missing school ID
recode ks4sch -1=.
replace ingen=0 if ks4sch==. 
replace ingen=0 if ks4sch==-1 
*6113

*last pre-imputation save point:
save "Phenotypes_and_NPD_and_PGSs.dta", replace


**************************************************************************************************************************************
**************************************************************************************************************************************

*ENTRY POINT FOR IMPUTATION 
*using untransformed psych measures, needed for descriptive stats - transform in mi passive
clear all

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

set maxvar 30000

use "Phenotypes_and_NPD_and_PGSs.dta", clear

fre ingen
*6113

summ SDQ_HI_subscore_ku  SDQ_HI_subscore_ta  MFQsummscoreF10_1miss MFQsummscoreTF1_1miss SSCMsummscorekv_1miss SSCMsummscoretb_1miss if ingen==1
*Variable	Obs	Mean	Std. Dev.	Min	Max			
*SDQ_HI_sub~u	4,248	2.859699	2.208274	0	10
*SDQ_HI_sub~a	3,959	2.893407	2.199213	0	10
*MFQs~0_1miss	4,432	3.966964	3.441371	0	21
*MFQs~1_1miss	4,160	3.94984		3.880031	0	24
*SSCM~v_1miss	4,372	2.234946	3.395721	0	24		
*SSCM~b_1miss	4,093	2.493548	3.543348	0	24


*Should've done this earlier:
rename MigrainesF10 migraine10
rename as_128 asthma10
rename as_157 asthma13
rename zyengobmi_score zbmi_score
rename zbmi_F10 bmi10
rename zbmi_TF1 bmi13

*log_year*_totalabsence log_year*_authabsence*

keep cidB2953 kz011b qlet gender smokedinpregv2 maternaltenure_simple maternalparity_CATEG maternaleduc maternal_age  ks4_ptscnewe ks4_stype_v2 ///
log_percent_absenceyear11 log_percent_absenceyear10 log_percent_absenceyear9 year*_unauthabsence_BINARY  ///
SDQ_HI_subscore_ku  SDQ_HI_subscore_ta  MFQsummscoreF10_1miss MFQsummscoreTF1_1miss SSCMsummscorekv_1miss SSCMsummscoretb_1miss bmi10 bmi13 ASD_DL asthma10 migraine10 asthma13 ks4sch ingensample ///
zasthma_score zmigraine_score zbmi_score zadhd_score zdepress_score zasd_score PC* ///
dw042 inc33eq inc47eq c755 c765 e140 e310 ///
ks4year ks4_age_start ks4_month_part ks4_yeargrp ks4_actyrgrp 


*TRIM OFF PEOPLE WHO CONTRIBUTE NOTHING AND STOP IT FROM RUNNING

*Drop people not alive at 1yr:
fre kz011b
drop if kz011b!=1

*Drop if sex is missing:
drop if gender==.

count

*log_year11_totalabsence log_year10_totalabsence log_year9_totalabsence* 

mi set flong
mi register imputed smokedinpregv2 maternaltenure_simple maternalparity_CATEG maternaleduc maternal_age ks4_ptscnewe ks4_stype_v2 ///
year*_unauthabsence_BINARY log_percent_absenceyear11 log_percent_absenceyear10 log_percent_absenceyear9  ///
SDQ_HI_subscore_ku  SDQ_HI_subscore_ta  MFQsummscoreF10_1miss MFQsummscoreTF1_1miss SSCMsummscorekv_1miss SSCMsummscoretb_1miss bmi10 bmi13 ASD_DL asthma10 migraine10 asthma13

mi register imputed inc33eq inc47eq c755 c765 
summ inc33eq inc47eq
fre c755 c765
recode c755 -1=. 65=.
recode c765 -1=. 65=.

summ dw042, det
recode dw042 -3=.

mi register imputed zasthma_score zmigraine_score zbmi_score zadhd_score zdepress_score zasd_score PC* 

recode ks4sch -1=. -10=.
summ ks4sch 
summ ks4sch if ingen==1

*SRH in late preg: cheeky, but include as continuous
fre e140 e310
recode e140 -1=.
recode e310 -1=.
mi register imputed e140 e310

*These are useful just for working out who is in which cohort, in case you need to check
mi register regular ks4year ks4_age_start ks4_month_part ks4_yeargrp ks4_actyrgrp 

*Check nothing dodgy in anything:
fre smokedinpregv2 ASD_DL asthma10 migraine10 asthma13 maternalparity_CATEG maternaleduc c755 c765 maternaltenure_simple
summ maternal_age SDQ_HI_subscore_ku  SDQ_HI_subscore_ta  MFQsummscoreF10_1miss MFQsummscoreTF1_1miss SSCMsummscorekv_1miss SSCMsummscoretb_1miss bmi10 bmi13 ASD_DL asthma10 migraine10 asthma13 ///
 ks4_ptscnewe log_percent_absenceyear11 log_percent_absenceyear10 log_percent_absenceyear9 inc33eq inc47eq e140 e310

capture mi xtset, clear
capture erase impstats.dta

*IMPUTATION
mi impute chained (logit) smokedinpregv2 ASD_DL asthma10 migraine10 asthma13 (ologit) maternalparity_CATEG maternaleduc c755 c765 e140 e310 (mlogit) maternaltenure_simple ks4_stype_v2 ///
(truncreg, ll(0) ul(10)) SDQ_HI_subscore_ku SDQ_HI_subscore_ta  ///
(truncreg, ll(0) ul(24)) MFQsummscoreF10_1miss SSCMsummscorekv_1miss MFQsummscoreTF1_1miss SSCMsummscoretb_1miss ///
(truncreg, ll(0)) inc33eq inc47eq  ///
(reg) bmi10 bmi13  ///
(truncreg, ll(15) ul(46)) maternal_age ///
(truncreg, ll(0) ul(540)) ks4_ptscnewe ///
(truncreg, ll(0) ul(4.615102)) log_percent_absenceyear11 log_percent_absenceyear10 log_percent_absenceyear9 ///
(reg) zasthma_score zmigraine_score zbmi_score zadhd_score zdepress_score zasd_score PC* ///
 = i.gender, add(50) rseed(100) dots savetrace(impstats.dta) augment 

*PREP IN MI PASSIVE:

*Transform in mi passive for the ones you'll actually use:
mi passive: egen zSDQHI_ku=std(SDQ_HI_subscore_ku)
mi passive: egen zSDQHI_ta=std(SDQ_HI_subscore_ta)

mi passive: egen zMFQ_F10_1miss=std(MFQsummscoreF10_1miss)
mi passive: egen zMFQ_TF1_1miss=std(MFQsummscoreTF1_1miss)

mi passive: egen zSCDC_kv_1miss=std(SSCMsummscorekv_1miss)
mi passive: egen zSCDC_tb_1miss=std(SSCMsummscoretb_1miss)

mi rename zSDQHI_ku adhd10
mi rename zSDQHI_ta adhd13
mi rename zSCDC_kv_1miss asd10
mi rename zSCDC_tb_1miss asd13
mi rename zMFQ_F10_1miss depress10
mi rename zMFQ_TF1_1miss depress13

*For mediation with paramed, maternal educ, maternaltenure_simple and maternalparity_CATEG needs to be coded as dummies.
*Redo within passive as dropped them before imputation

forvalues n=1/5 {
mi passive: gen maternaleduc_dummy`n'=0
mi passive: replace maternaleduc_dummy`n'=1 if maternaleduc==`n'
}

forvalues n=1/4 {
mi passive: gen maternaltenure_dummy`n'=0
mi passive: replace maternaltenure_dummy`n'=1 if maternaltenure_simple==`n'
}

forvalues n=0/3 {
mi passive: gen maternalparity_CATEG_dummy`n'=0
mi passive: replace maternalparity_CATEG_dummy`n'=1 if maternalparity_CATEG==`n'
}

*For descriptive tables, make one for untransformed percent absence:
foreach year in 11 10 9 {
mi passive: gen percent_absenceyear`year'=(2.71^log_percent_absenceyear`year')-1
mi xeq: sum percent_absenceyear`year'
mi estimate: mean percent_absenceyear`year'
mi estimate: mean percent_absenceyear`year' if ingen==1
}

*FROM THIS, CAN ADD TOGETHER ABSENCE ACROSS MULTIPLE YEARS AND THEN RE-LOG TRANSFORM

*Year 10 and 11 average
mi passive: gen percent_absenceyear1011=(percent_absenceyear10+percent_absenceyear11)/2
mi passive: gen log_percent_absenceyear1011=log(percent_absenceyear1011+1)
mi estimate: mean percent_absenceyear1011
mi estimate: mean percent_absenceyear1011 if ingen==1

*Years 9 10 11 average
mi passive: gen percent_absenceyear91011=(percent_absenceyear9+percent_absenceyear10+percent_absenceyear11)/3
mi passive: gen log_percent_absenceyear91011=log(percent_absenceyear91011+1)
mi estimate: mean percent_absenceyear91011
mi estimate: mean percent_absenceyear91011 if ingen==1


save "JAN2020_50_IMPs.dta", replace

**************************************************************************************************************************************
**************************************************************************************************************************************
**************************************************************************************************************************************
**************************************************************************************************************************************


*ENTRY POINT: Observational:

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

use "JAN2020_50_IMPs.dta", clear

global covars "i.gender i.maternaleduc i.maternaltenure_simple maternal_age i.maternalparity_CATEG i.smokedinpreg"

fre ingen

*OBSERVATIONAL: HEALTH CONDS --> GCSEs:

*GCSEs: cap score lovely and normal
summ ks4_ptscnewe if ingen==1 , det

*NB: using _1miss or _cc versions of MFQ make so little difference had to check at 4th decimal place

*drop(_cons *gender* *maternal_age* *maternal* *smokedinpreg*)

*Exposure variables renamed prior to imputation
*Also fix the labels
label variable migraine10 "Migraines, age 10"
label variable adhd10 "SDQ-HI score, age 10"
label variable adhd13 "SDQ-HI score, age 13"
label variable asd10 "SCDC score, age 10"
label variable asd13 "SCDC score, age 13"
label variable depress10 "MFQ score, age 10"
label variable depress13 "MFQ score, age 13"
label variable asthma10 "Asthma, age 10"
label variable asthma13 "Asthma, age 13"
label variable bmi10 "BMI z-score, age 10"
label variable bmi13 "BMI z-score, age 13"

*global renamedexp migraine10 adhd10 depress10 asd10 migraine10 asthma10  bmi10 adhd13 depress13 asd13 bmi13 
*display "$renamedexp"

*Leave out teacher SDQ for now: zSDQHI_schoolyear6
eststo clear
foreach healthcond in adhd10 depress10 asd10 migraine10 asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13   {
eststo `healthcond'GCSEs: mi estimate, post: reg ks4_ptscnewe `healthcond' $covars if ingensample==1, cluster(ks4sch)
estimates store `healthcond'
}

*Coefplot guide: http://repec.sowi.unibe.ch/stata/coefplot/getting-started.html

*For separate ages combined:
label variable migraine10 "Migraines"
label variable adhd10 "SDQ-HI score"
label variable adhd13 "SDQ-HI score"
label variable asd10 "SCDC score"
label variable asd13 "SCDC score"
label variable depress10 "MFQ score"
label variable depress13 "MFQ score"
label variable asthma10 "Asthma"
label variable asthma13 "Asthma"
label variable bmi10 "BMI"
label variable bmi13 "BMI"

coefplot adhd10 depress10 asd10 asthma10 bmi10 migraine10, keep (adhd10 depress10 asd10 asthma10 migraine10 bmi10)  ///
xline(0) legend(off) grid(none) title("Age 10", size(med) pos(9) color(black)) graphregion(color(white))
graph save graphs\health10GCSES.gph, replace

coefplot adhd13 depress13 asd13 asthma13 bmi13, bylabel(Health at 13) keep (adhd13 depress13 asd13 asthma13 bmi13) ///
xline(0) legend(off) grid(none) title("Age 13", size(med) pos(9) color(black)) graphregion(color(white))
graph save graphs\health13GCSES.gph, replace

graph combine graphs\health10GCSES.gph graphs\health13GCSES.gph, ycommon title({bf: Figure 1: Phenotypic associations of childhood health and educational attainment at age 16}, color(black) size(small) justification(left)) rows(2) graphregion(color(white)) ///
/*
caption("Coefficients represent change in GCSE points with presence of the health condition, or per S.D. increase in continuous exposures" "Educational attainment: GCSE capped points score, range 0-540, mean 332.3" ///
"SDQ-HI: Strengths and Difficulties Questionnaire hyperactiity subscale, for ADHD symptoms" ///
"MFQ: Mood and Feelings Questionnaire, for depressive symptoms" ///
"SCDC: Social Communication Disorder Checklist, for autistic social traits" ///
"BMI: age and gender standardized using 1990 UK Growth Reference. Values represent S.D. difference from reference mean" ///
, size (vsmall) justification(right))
*/
graph save graphs\healthtoGCSES.gph, replace
graph export graphs\healthtoGCSES.tif, replace width(1200)

*Observational - Health at both ages --> GCSEs
capture erase "results\imputed_HealthtoGCSEs_estout.xls"
estout using "results\imputed_HealthtoGCSEss_estout.xls", cells ("b(fmt(2)) ci(fmt(2))") ///
keep(*adhd10* *depress10* *asd10* *migraine10* *asthma10* *bmi10* *adhd13* *depress13* *asd13* *asthma13* *bmi13*) replace ///
title(Observational: Health at ages 10 and 13 and GCSEs) note("adjusted for gender, maternal education, maternal housing tenure, maternal age, maternal parity, whether smoked in pregnancy")


************************************************************************************
*SOCIAL/GENDER PATTERNING OF GCSEs AND ABSENCES

*For paragraph: girls first!
foreach var in ks4_ptscnewe percent_absenceyear1011 {
mi estimate, post: mean `var' if ingensample==1 & gender==2, cluster(ks4sch)
mi estimate, post: mean `var' if ingensample==1 & gender==1, cluster(ks4sch)
}
foreach group in 5 1 {
foreach var in ks4_ptscnewe percent_absenceyear1011 {
mi estimate, esampvaryok  post: mean `var' if ingensample==1 & maternaleduc==`group', cluster(ks4sch)
}
}
*Gender effects:
*On GCSEs
eststo clear
eststo GCSEs:  mi estimate, post: regress ks4_ptscnewe i.gender if ingensample==1, cluster(ks4sch)
esttab, b(%9.2f) ci(%9.2f) compress
*And on absence:
eststo clear
eststo absencey1011: mi estimate, post: regress log_percent_absenceyear1011 i.gender if ingensample==1, cluster(ks4sch)
esttab, b(%9.4f) ci(%9.4f) compress eform wide

*Gender-adjusted SEP effects on GCSEs:
foreach covar in i.maternaleduc i.maternaltenure_simple maternal_age i.maternalparity_CATEG i.smokedinpreg i.ks4_stype_v2 {
eststo clear
eststo GCSEs:  mi estimate, post: regress ks4_ptscnewe i.gender `covar' if ingensample==1, cluster(ks4sch)
esttab, b(%9.1f) ci(%9.1f) compress wide noparentheses nostar
}
*Gender-adjusted SEP effects on absence:
foreach covar in i.maternaleduc i.maternaltenure_simple maternal_age i.maternalparity_CATEG i.smokedinpreg i.ks4_stype_v2 {
eststo clear
eststo GCSEs:  mi estimate, post: regress log_percent_absenceyear1011 i.gender `covar' if ingensample==1, cluster(ks4sch)
esttab, b(%9.3f) ci(%9.3f) compress eform wide noparentheses nostar
}

mi estimate, post: mean percent_absenceyear1011 if ingensample==1 & gender==1, cluster(ks4sch)
mi estimate, post: mean percent_absenceyear1011 if ingensample==1 & gender==2, cluster(ks4sch)

*ABSENCES --> GCSEs
*Less adjusted:
eststo clear
mi estimate, post: regress ks4_ptscnewe percent_absenceyear1011 i.gender if ingensample==1, cluster(ks4sch) 
esttab, b(%9.3f) ci(%9.3f) compress wide noparentheses nostar

**To get per-day effect: divide by 1.9


************************************************************************************

*HEALTH CONDS --> ABSENCES:

**eform all of these so that coeffs on the log scale are for percent change

capture erase "results\imputed_HealthtoAbsences_y10y11_estout.txt"
capture erase "results\imputed_HealthtoAbsences_y10y11_estout.xls"
*Age 10 and Age 13
eststo clear
foreach healthcond in adhd10 depress10 asd10 migraine10  asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13  {
eststo `healthcond': mi estimate, post: regress log_percent_absenceyear1011 `healthcond' $covars if ingensample==1, cluster(ks4sch)
}
estout using "results\imputed_HealthtoAbsences_y10y11_estout.xls", cells ("b(fmt(4)) ci_l(fmt(4)) ci_u(fmt(4))") ///
keep(*adhd10* *depress10* *asd10* *migraine10* *asthma10* *bmi10* *adhd13* *depress13* *asd13* *asthma13* *bmi13*) replace eform  ///
title(Observational: health at 10 and 13 to year11 absences) note("adjusted for gender, maternal education, maternal housing tenure, maternal age, maternal parity, whether smoked in pregnancy", "absences: logged days")

coefplot adhd10* depress10* asd10* asthma10* bmi10* migraine10*, eform keep (adhd10 depress10 asd10 asthma10 bmi10 migraine10)  ///
xline(1) legend(off) grid(none) title("Age 10", size(med) pos(9) color(black)) graphregion(color(white))
graph save graphs\health10absence_y10y11.gph, replace

coefplot adhd13 depress13 asd13 asthma13 bmi13, bylabel(Health at 13) eform keep (adhd13 depress13 asd13 asthma13 bmi13) ///
xline(1) legend(off) grid(none) title("Age 13", size(med) pos(9) color(black)) graphregion(color(white))
graph save graphs\health13absence_y10y11.gph, replace

graph combine graphs\health10absence_y10y11.gph graphs\health13absence_y10y11.gph, ycommon xcommon title({bf: Figure 2: Phenotypic associations of childhood health and school absence at age 14-16}, color(black) size(small) justification(left)) rows(2) graphregion(color(white)) 
graph save graphs\healthtoabsence_y10y11.gph, replace
graph export graphs\healthtoabsence_y10y11.tif, replace width(1200)

/*
caption("Coefficients represent percent change in absenteeism with presence of the health condition, or per S.D. increase in continuous exposures" ///
"SDQ-HI: Strengths and Difficulties Questionnaire hyperactiity subscale, for ADHD symptoms" ///
"MFQ: Mood and Feelings Questionnaire, for depressive symptoms" ///
"SCDC: Social Communication Disorder Checklist, for autistic social traits" ///
"BMI: age and gender standardized using 1990 UK Growth Reference. Values represent S.D. difference from reference mean" ///
, size (vsmall) justification(right))
*/

**************************************************************************************************************************************
******************************************************************************************************************************************

*ENTRY POINT: MEDIATION:

*PARAMED WITHIN EACH IMPUTED DATASETS
*THEN COMBINE IN EXCEL AND CALCULATE CIs OF PROPORTIONS THERE

*Paramed: syntax and explanaiton here: file://ads.bris.ac.uk/filestore/MyFiles/Staff19/sh5327/Documents/paramed.pdf
clear all
cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

set maxvar 30000

*This one uses IMPUTED DATASETS
use "JAN2020_50_IMPs.dta", clear

/*
*Should've done this earlier:
rename migraine10 migraine10
rename adhd10 adhd10
rename adhd13 adhd13
rename asd10 asd10
rename asd13 asd13
rename depress10 depress10
rename depress13 depress13
rename asthma10 asthma10
rename asthma13 asthma13
rename zbmi_score zbmi_score
rename bmi10 bmi10
rename bmi13 bmi13
*/

*covars macro already defined, but need to be specified differently for paramed anyway

*******************************************************************************************
*can't restrict to analytic sample with if, so drop anyone outside of it
replace ingen=0 if ks4sch==.
replace ingen=0 if ks4sch==-1
drop if ingen!=1
**************************************************************************************************

*Drop m=0, as makes things more complicated later:
drop if _mi_m==0

*Make variables for the parameters, then fill 1-50.
*Update: for within-imputation variance, need to square within-imputation SE:

foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
foreach effect in cde nie te {
gen `exp'_`effect' = .
gen `exp'_`effect'_se = .
gen `exp'_`effect'_v = .
gen `exp'_`effect'_p = .
*With continuous mediator only, doesn't give you nde so don't need to worry about parameters for that, at least if you specify nointer
}
}

*NEED TO BLOCK-REPEAT PER PARAMETER: 
*can't loop through using the common part because it doesn't work trying to loop through matrix names

levelsof _mi_m, local(levels) 
foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
foreach out in ks4_ptscnewe {
foreach med in log_percent_absenceyear1011 {
*Loop through each dataset
foreach l of local levels {
preserve
keep if _mi_m == `l'
paramed `out', avar(`exp') mvar(`med') cvars(gender maternaleduc_dummy*  maternaltenure_dummy* maternalparity_CATEG_dummy* maternal_age smokedinpreg) a0(0) a1(1) m(1) yreg(linear) mreg(linear) nointer
mat results = e(effects)
mat list results 
restore
*Now fill this in, using each time the contents of the latest (temporary) matrix
replace `exp'_cde = results[1,1] in `l'
replace `exp'_cde_se = results[1,2] in `l'
replace `exp'_cde_p = results[1,3] in `l'
replace `exp'_nie = results[2,1] in `l'
replace `exp'_nie_se = results[2,2] in `l'
replace `exp'_nie_p = results[2,3] in `l'
replace `exp'_te = results[3,1] in `l'
replace `exp'_te_se = results[3,2] in `l'
replace `exp'_te_p = results[3,3] in `l'
*Check it:
list `exp'_cde `exp'_cde_se `exp'_cde_v  `exp'_cde_p `exp'_nie `exp'_nie_se `exp'_nie_v `exp'_nie_p `exp'_te `exp'_te_se `exp'_te_v `exp'_te_p in 1/50
}
}
}
}

*Next thing: FOR WITHIN-IMPUTATION VARIANCE, mean of the variance in each imp, i.e. saved means of the parameters:

foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
*mean across imps of variance of each parameter
foreach effect in cde nie te {
*gen variance
replace `exp'_`effect'_v=`exp'_`effect'_se^2  
*summ across imps
sum `exp'_`effect'_v 
gen vwithinimp_`exp'_`effect'=r(mean)
list  vwithinimp_`exp'_`effect' in 1/11
}
}

*For BETWEEN-IMPUTATION VARIANCE: 
*'This is estimated by taking the variance of the parameter of interest estimated over imputed datasets. 
*This formula is equal to the formula for the (sample) variance which is commonly used in statistics. 
*Between-imp variance=sqrt(Σ((imp-specific parameter - pooled parameter)^2))/N-1)

*So, for pooled parameters, across-imp mean of the betas:
foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
foreach effect in cde nie te {
sum `exp'_`effect'
gen mean_`exp'_`effect'=r(mean)
list  mean_`exp'_`effect' in 1/11
*For the squared diff
gen `exp'_`effect'_sqdiff=(`exp'_`effect'-mean_`exp'_`effect')^2
list `exp'_`effect'_sqdiff in 1/11
*Correct that missing in n=11
*Take the sum of that:
egen sigma_`exp'_`effect'_sqdiff=sum(`exp'_`effect'_sqdiff)
list sigma_`exp'_`effect'_sqdiff in 1/11
*All the same - good
*Now for between-imp variance, divide by N-1 and take sqrt:
gen vbimp_`exp'_`effect'=sqrt(sigma_`exp'_`effect'_sqdiff/49)
list vbimp_`exp'_`effect' in 1/11
}
}

*For TOTAL, formula is V-within + V-between + (V-between/m)
foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
foreach effect in cde nie te {
gen v_total_`exp'_`effect'= vwithinimp_`exp'_`effect' +  vbimp_`exp'_`effect' +  (vbimp_`exp'_`effect'/50)
gen se_total_`exp'_`effect'= sqrt(v_total_`exp'_`effect')
list mean_`exp'_`effect' se_total_`exp'_`effect' in 1/11
}
}
*for the CI
foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
foreach effect in cde nie te {
gen lci_`exp'_`effect'=mean_`exp'_`effect' -(1.96*se_total_`exp'_`effect')
gen uci_`exp'_`effect'=mean_`exp'_`effect' +(1.96*se_total_`exp'_`effect')
*P value
gen p_`exp'_`effect'=2*normal(-abs(mean_`exp'_`effect'/se_total_`exp'_`effect'))
list mean_`exp'_`effect' lci_`exp'_`effect' uci_`exp'_`effect' p_`exp'_`effect' in 1
}
}

foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
display "`exp'"
list mean_`exp'_cde lci_`exp'_cde uci_`exp'_cde p_`exp'_cde  in 1
list mean_`exp'_nie lci_`exp'_nie uci_`exp'_nie p_`exp'_nie  in 1
list mean_`exp'_te  lci_`exp'_te uci_`exp'_te p_`exp'_te in 1
}

*Rearrange these better:
gen exp=""
gen effect=""
gen mean=.
gen lci=.
gen uci=.
gen p=.
local k=0
foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
foreach effect in cde nie te {
local k=`k'+1
replace effect="`effect'" in `k'
replace exp="`exp'" in `k'
replace mean=mean_`exp'_`effect' in `k'
replace lci=lci_`exp'_`effect' in `k'
replace uci=uci_`exp'_`effect' in `k'
replace p=p_`exp'_`effect' in `k'
}
}

*SECTION OFF AND SAVE:
preserve
keep mean_* lci_* uci_* p_* exp effect mean lci uci p
keep in 1/33
save "mediation_results_y10y11.dta", replace
*Export coeffs for tables:
export delimited using results/paramedcoeffs_y10y11, delimiter (",") replace
restore

***********************************************************************************************************

*ENTRY POINT: COEFF PLOTS FOR MEDIATION MODELS

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy"
use "mediation_results_y10y11.dta", clear

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\graphs\"

*For coefplot, add results to a matrix.
*Local to replace in better names:
local adhd10title "SDQ-HI score at 10" 
local adhd13title "SDQ-HI score at 13" 
local depress10title "MFQ score at 10" 
local depress13title "MFQ score at 13" 
local asd10title "SCDC score at 10" 
local asd13title "SCDC score at 13"
local migraine10title= "migraines at 10"
local asthma10title "asthma at 10" 
local asthma13title "asthma at 13" 
local bmi10title "BMI z-score at 10" 
local bmi13title "BMI z-score at 13" 

*Separately by exposure:
foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
matrix `exp'paramed=J(3,3,.)
matrix rownames `exp'paramed= direct indirect total
local k=1
foreach effect in cde nie te {
scalar m = mean_`exp'_`effect'
display m
matrix `exp'paramed [`k',1] =m
scalar l = lci_`exp'_`effect'
display l
matrix `exp'paramed [`k',2] =l
scalar u = uci_`exp'_`effect'
display u
matrix `exp'paramed [`k',3] =u
local k=`k'+1
}
matlist `exp'paramed
coefplot (matrix( `exp'paramed [,1]), ci((2 3))) , xline(0) legend(off) grid(none) graphregion(color(white)) title("``exp'title'", size(med) pos(11))
graph save `exp'paramed_y10y11.gph, replace 
}

foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
graph use `exp'paramed_y10y11.gph, nodraw
}

graph combine adhd10paramed_y10y11.gph adhd13paramed_y10y11.gph depress10paramed_y10y11.gph depress13paramed_y10y11.gph asd10paramed_y10y11.gph asd13paramed_y10y11.gph   ///
asthma10paramed_y10y11.gph asthma13paramed_y10y11.gph migraine10paramed_y10y11.gph bmi10paramed_y10y11.gph bmi13paramed_y10y11.gph, xcommon colfirst rows(4) graphregion(color(white))  ///
title({bf: Figure 3: Mediation of phenotypic associations of health with GCSEs by absenteeism at age 14-16}, color(black) size(small)) 

graph save mediation_y10y11.gph, replace
graph export mediation_y10y11.tif , replace width(1200)

/*
caption("Coefficients represent change in GCSE points with presence of health condition, or per S.D. increase in continuous exposures" "GCSE capped points score: range 0-540, mean 332.3, S.D. 87.4" ///
"SDQ-HI: Strengths and Difficulties Questionnaire hyperactiity subscale, for ADHD symptoms" ///
"MFQ: Mood and Feelings Questionnaire, for depressive symptoms" ///
"SCDC: Social Communication Disorder Checklist, for autistic social traits" ///
"BMI: age and gender standardized using 1990 UK Growth Reference. Values represent S.D. difference from reference mean" ///
, size (vsmall) justification(right))
*/

*caption("{bf:Percent of total effects of health on GCSE score mediated by absence at age 14-16:}" "SDQ-HI at 10: 6.1%, MFQ at 10: 10.9%, SCDC at 10: 10.8%, Migraines at 10: 67.4%, Asthma at 10: -175.8%, BMI z-score at 10: 48.5%" ///
*"SDQ-HI at 13: 7.9%, MFQ at 13: 37.7%, SCDC at 13: 12.6%, Asthma at 13: 277.1%, BMI z-score at 13: 35.7%", size (vsmall) justification(left))


**********************************************************************************************
**********************************************************************************************

*ENTRY POINT: PREDICTION OF PHENOTYPES BY POLYGENIC SCORES

clear all
cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"
set maxvar 30000

*This one uses IMPUTED DATASETS
use "JAN2020_50_IMPs.dta", clear


*GET R2.

*use mibeta for contin exposures:
foreach exp in adhd depress asd bmi {
mibeta `exp'10 z`exp'_score if ingensample==1, cluster(ks4sch)
mibeta `exp'13 z`exp'_score if ingensample==1, cluster(ks4sch)
}
foreach exp in adhd depress asd bmi {
mi xeq 1: regress `exp'10 z`exp'_score if ingensample==1, cluster(ks4sch)
mi xeq 1: regress `exp'13 z`exp'_score if ingensample==1, cluster(ks4sch)
}


*Manually for the binary ones.
*Code below adapted from this: https://stats.idre.ucla.edu/stata/faq/how-can-i-estimate-r-squared-for-a-model-estimated-with-multiply-imputed-data/
*Migraines last as lack of a 13 measure stops the loop
foreach exp in asthma migraine  {
	foreach age in 10 13 {
	capture gen `exp'`age'_pseudo_r2=.
		forvalues m = 1/50 {
		logistic `exp'`age' z`exp'_score if(_mi_m==`m') & ingensample==1, cluster(ks4sch)
		replace `exp'`age'_pseudo_r2 = e(r2_p) in `m' 
		mean (`exp'`age'_pseudo_r2)
}
}
}

foreach exp in asthma migraine  {
	foreach age in 10 13 {
		mean (`exp'`age'_pseudo_r2)
}
}


******************************************************************************************************************

*ENTRY POINT: GENETIC ANALYSES FOR STRAIGHT PGS ASSOCIATIONS.
*FOR GCSEs, can do in the m=0, but for absences need imputed data

clear all
set maxvar 30000

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

use "JAN2020_50_IMPs.dta", clear

*PREDICTION OF GCSEs AND ABSENCES: DIRECT ASSOCIATIONS WITH THE OUTCOMES

label variable zadhd_score "ADHD PGS"
label variable zdepress_score "depression PGS"
label variable zasd_score "ASD PGS"
label variable zmigraine_score  "migraine PGS"
label variable zbmi_score "BMI PGS"
label variable zasthma_score "asthma PGS"

***********************************************************
*For abstract, express this in terms of S.D. units:
egen zks4_ptscnewe=std(ks4_ptscnewe) if ingensample==1

*PGS TO GCSEs
eststo clear
foreach pgs in zadhd_score zdepress_score zasd_score zmigraine_score zasthma_score zbmi_score {
eststo `pgs': mi estimate, post: reg zks4_ptscnewe `pgs' i.gender PC1-PC20  if ingensample==1, cluster(ks4sch)
}
esttab, b(%9.2f) ci(%9.2f) keep(zadhd_score zdepress_score zasd_score zmigraine_score zasthma_score zbmi_score) compress
***********************************************************

*PGS TO GCSEs
capture erase results\PGSs_to_GCSEs.txt
capture erase results\PGSs_to_GCSEs.xls
eststo clear
foreach pgs in zadhd_score zdepress_score zasd_score zmigraine_score zasthma_score zbmi_score {
eststo `pgs': mi estimate, post: reg ks4_ptscnewe `pgs' i.gender PC1-PC20  if ingensample==1, cluster(ks4sch)
outreg2 using "results\PGSs_to_GCSEs.xls", stats (coef ci_low ci_high) dec(2) sideway nor nocons noobs noaster append label  keep (`pgs') ctitle(GCSE points) title(Direct associations: standardized PGSs to GCSEs) addnote("Adjusted for gender and PC1-PC20")
}
esttab, b(%9.2f) ci(%9.2f) keep(zadhd_score zdepress_score zasd_score zmigraine_score zasthma_score zbmi_score) compress

coefplot zadhd_score zdepress_score zasd_score zmigraine_score zasthma_score zbmi_score, keep (zadhd_score zdepress_score zasd_score zmigraine_score zasthma_score zbmi_score)  ///
xline(0) legend(off) grid(none) graphregion(color(white)) title("GCSE points score", color(black) size(medsmall) pos(11))
graph save graphs\PGStoGCSEs.gph, replace


******************************************************************************************************************************

*PGS TO ABSENCES

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

use "JAN2020_50_IMPs.dta", clear

capture erase "results\PGSs_to_absences_y10y11.xls"
capture erase "results\PGSs_to_absences_y10y11.txt"

label variable zadhd_score "ADHD PGS"
label variable zdepress_score "depression PGS"
label variable zasd_score "ASD PGS"
label variable zmigraine_score  "migraine PGS"
label variable zbmi_score "BMI PGS"
label variable zasthma_score "asthma PGS"


*TOTAL ABSENCE 
*eform coeffs for % change
eststo clear
foreach pgs in zadhd_score zdepress_score zasd_score zmigraine_score zasthma_score zbmi_score {
eststo `pgs': mi estimate, post: regress log_percent_absenceyear1011 `pgs' i.gender PC1-PC20 if ingensample==1, cluster(ks4sch)
outreg2 using "results\PGSs_to_absences_y10y11.xls", stats (coef ci_low ci_high) sideway eform dec(4) nor nocons noobs noaster append label  keep (`pgs') ctitle(logged days) title(Direct associations: PGSs to age 14-16 absences)  addnote("Adjusted for gender and PC1-PC20")
}
esttab, b(%9.2f) ci(%9.2f) keep(zadhd_score zdepress_score zasd_score zmigraine_score zasthma_score zbmi_score) compress

coefplot zadhd_score zdepress_score zasd_score zasthma_score zmigraine_score  zbmi_score, eform keep (zadhd_score zdepress_score zasd_score zasthma_score zmigraine_score zbmi_score)  ///
xline(1.0) legend(off) grid(none) graphregion(color(white)) title("School absence at age 14-16", color(black) size(medsmall) pos(11))
graph save graphs\PGStoabsence_y10y11.gph, replace

graph combine graphs\PGStoGCSEs.gph graphs\PGStoabsence_y10y11.gph, ycommon colfirst rows(2) graphregion(color(white)) ///
title({bf} Figure 4: Association of polygenic scores with GCSEs and absenteeism age 14-16, color(black) size(medsmall) justification(left)) 
***caption("GCSE capped points score: range 0-540, mean X. Absences in year 11: range 0-297, median 17." "GCSE coefficients show change in capped points score per S.D. polygenic score." "Absenteeism coefficients show proportional change in days of absenteeism per S.D. change in polygenic score (1.0 corresponds to no change)", size (vsmall) span)
graph save graphs\PGStoGCSEsandabsence_y10y11.gph, replace
graph export graphs\PGStoGCSEsandabsence_y10y11.tif, width(1200) replace


*PGS OUTLIER CHECK:
use "JAN2020_50_IMPs.dta", clear
*To speed this up, drop anyone not in the usable sample:
keep if ingensample==1
merge m:1 cidB2953 qlet using scores_from_plink\nooutliers_yengobmi_score.dta
fre qlet if _merge==2
*DROP ALL THE MOTHERS
drop if qlet=="M"
*and remaining unmatched
drop if _merge==2
drop _merge
count if _mi_m==.
mi register regular nooutliers_yengobmi_cnt nooutliers_yengobmi_score znooutliers_yengobmi_score


*PGS TO ABSENCES: uses IMPUTED DATASETS, since MISSINGNESS IN ABSENCES
*eform coeffs for % change
eststo clear
foreach pgs in zbmi_score znooutliers_yengobmi_score {
eststo `pgs': mi estimate, post: regress log_percent_absenceyear1011 `pgs' i.gender PC1-PC20 if ingensample==1, cluster(ks4sch)
}
esttab, b(%9.4f) ci(%9.4f) keep(zbmi_score znooutliers_yengobmi_score) compress eform

*IV models
eststo clear
foreach exp in bmi  {
foreach age in 10 13 {
eststo z`exp'`age': mi estimate, post cmdok: ivreg ks4_ptscnewe (`exp'`age'=z`exp'_score) gender PC* if ingensample==1, cluster(ks4sch)
eststo znooutliers_yengo`exp'`age': mi estimate, post cmdok: ivreg ks4_ptscnewe (`exp'`age'=znooutliers_yengo`exp'_score) gender PC* if ingensample==1, cluster(ks4sch)
}
}
esttab, b(%9.4f) ci(%9.4f) keep(*bmi*) compress 

eststo clear
foreach exp in bmi  {
foreach age in 10 13 {
eststo z`exp'`age': mi estimate, post cmdok: ivreg log_percent_absenceyear1011 (`exp'`age'=z`exp'_score) gender PC* if ingensample==1, cluster(ks4sch) 
eststo znooutliers_yengo`exp'`age': mi estimate, post cmdok: ivreg log_percent_absenceyear1011 (`exp'`age'=znooutliers_yengo`exp'_score) gender PC* if ingensample==1, cluster(ks4sch) 
}
}
esttab, b(%9.4f) ci(%9.4f) keep(*bmi*) eform compress

***********************************************************************************************************************************************************************************

*ENTRY POINT: MR MODELS WITH IMPUTED EXPOSURE DATA.

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

use "JAN2020_50_IMPs.dta", clear

global covars "i.gender i.maternaleduc i.maternaltenure_simple maternal_age i.maternalparity_CATEG i.smokedinpreg"

/*
mi estimate, post cmdok: ivreg2 ks4_ptscnewe (adhd13=zadhd_score) gender PC* if ingensample==1, cluster(ks4sch)
*Doesn't give you the postestimation parts for ivreg2
*Manual strategy doesn't work either. Bollocks
mi estimate, post cmdok: ivreg ks4_ptscnewe (adhd10=zadhd_score) gender PC* if ingensample==1, cluster(ks4sch)
mi estimate, post cmdok: estat endogenous
mi estimate, post cmdok: estat firststage
*/

*Exposure vars renamed before imputation

*Average across imps
foreach exp in adhd depress asd asthma bmi migraine {
foreach age in 10 13 {
gen `exp'`age'_cdf=.
forvalues m = 1/50 {
ivreg2 ks4_ptscnewe (`exp'`age'=z`exp'_score) gender PC* if(_mi_m==`m') & ingensample==1, cluster(ks4sch)
replace `exp'`age'_cdf = e(cdf) in `m' 
}
}
}

*average the F-stats across 50 for each:
foreach exp in adhd depress asd asthma bmi migraine {
foreach age in 10 13 {
summ `exp'`age'_cdf
return list
}
}

*Psych traits all unusable								.						
*So can do actual MR for BMI, asthma, migraines.

*For abstract, express this in terms of S.D. units:
capture egen zks4_ptscnewe=std(ks4_ptscnewe) if ingensample==1

foreach exp in bmi  {
foreach age in 10 13 {
mi estimate, post cmdok: ivreg zks4_ptscnewe (`exp'`age'=z`exp'_score) gender PC* if ingensample==1, cluster(ks4sch)
}
}
*Normal scale:
foreach exp in bmi  {
foreach age in 10 13 {
mi estimate, post cmdok: ivreg ks4_ptscnewe (`exp'`age'=z`exp'_score) gender PC* if ingensample==1, cluster(ks4sch)
}
}
eststo clear
foreach exp in bmi  {
foreach age in 10 13 {
eststo `exp'`age': mi estimate, post cmdok: ivreg log_percent_absenceyear1011 (`exp'`age'=z`exp'_score) gender PC* if ingensample==1, cluster(ks4sch) 
}
}
esttab, b(%9.4f) ci(%9.4f) keep(*bmi*) compress wide eform noparen nostar

***********************************************************************************************************************************************************************************

*TWOSAMPLE MR FROM R: IMPORT RESULTS TO GET COMPARABLE GRAPHS WITH COEFPLOT

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\TwoSample"

import delimited \\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\TwoSample\TWOSAMPLERESULTS_13August.csv, clear 

replace health_condition="ASD" if health_condition=="Autism Spectrum Disorder"
rename b beta

*Make lci and uci
gen lci=b-(1.96*se)
gen uci=b+(1.96*se)

*Individual
local i=-5
foreach exp in ADHD Depression ASD Migraine Asthma BMI  {
local i=`i'+5
matrix `exp'twosampleresults=J(5,3,.)
matrix rownames `exp'twosampleresults= "IVW" "weighted median" "weighted mode" "MR-Egger" "MR-Egger intercept"
foreach j in 1 2 3 4 5 {
local k= `i'+`j'
scalar b = beta in `k'
display b
matrix `exp'twosampleresults [`j',1] =b 
scalar l = lci in `k'
display l
matrix `exp'twosampleresults [`j',2] =l
scalar u = uci in `k'
display u
matrix `exp'twosampleresults [`j',3] =u
matlist `exp'twosampleresults
}
}
*Graphs - only first  with yaxis 
*ylabel(none) 
*xscale(r(-2 1)) 
foreach exp in ADHD Depression ASD  {
coefplot (matrix( `exp'twosampleresults [,1]), ci((2 3))) , ylabel(,labsize(small)) xline(0) legend(off) grid(none) graphregion(color(white)) title(`exp', size(med) color(black) pos(11))
graph save `exp'twosampleresults, replace
}
foreach exp in Migraine Asthma BMI  {
coefplot (matrix( `exp'twosampleresults [,1]), ci((2 3))) , ylabel(,labsize(small)) xline(0)  legend(off) grid(none) graphregion(color(white)) title(`exp', size(med) color(black) pos(11))
graph save `exp'twosampleresults, replace
}
graph combine ADHDtwosampleresults.gph  Depressiontwosampleresults.gph ASDtwosampleresults.gph  Migrainetwosampleresults.gph Asthmatwosampleresults.gph  BMItwosampleresults.gph, colfirst cols(2) graphregion(color(white)) ///
xcommon title({bf} Figure 5: Results of Two Sample Mendelian Randomization, size(small) color(black) justification(left))
graph save twosampleresults.gph, replace
graph export twosampleresults.tif, width(1200) replace

*Or just the original ones:
graph combine Migrainetwosampleresults.gph Asthmatwosampleresults.gph  BMItwosampleresults.gph, colfirst cols(1) graphregion(color(white)) ///
xcommon title({bf} Figure 5: Results of Two Sample Mendelian Randomization, size(medsmall) color(black) justification(left))
graph save twosampleresults.gph, replace
graph export twosampleresults.tif, width(1200) replace



/*
coefplot adhd10 depress10 asd10 asthma10 bmi10 migraine10, keep (adhd10 depress10 asd10 asthma10 bmi10 migraine10)  ///
xline(0) legend(off) grid(none) title("Age 10", size(med) pos(9))
graph save graphs\health10GCSES.gph, replace

coefplot adhd13 depress13 asd13 asthma13 bmi13, bylabel(Health at 13) keep (adhd13 depress13 asd13 asthma13 bmi13) ///
xline(0) legend(off) grid(none) title("Age 13", size(med) pos(9))
graph save graphs\health13GCSES.gph, replace

graph combine health10GCSES.gph health13GCSES.gph, ycommon title({bf} "Figure 1: Childhood health and educational attainment (GCSE points) at age 16", size(medsmall) justification(left)) rows(2)
*/

*Combined
*THIS LOOKS EVEN WORSE
local i=-5
matrix twosampleresults=J(30,3,.)
foreach exp in ADHD Depression ASD Migraine Asthma BMI {
local i=`i'+5
*matrix rownames `exp'twosampleresults= "`exp' IVW" "`exp' weighted median" "`exp' weighted mode" "`exp' MR-Egger" "`exp' MR-Egger intercept"
*matrix rownames `exp'twosampleresults= "IVW" "weighted median" "weighted mode" "MR-Egger" "MR-Egger intercept"
foreach j in 1 2 3 4 5 {
local k= `i'+`j'
scalar b = beta in `k'
display b
matrix twosampleresults [`k',1] =b 
scalar l = lci in `k'
display l
matrix twosampleresults [`k',2] =l
scalar u = uci in `k'
display u
matrix twosampleresults [`k',3] =u
matlist twosampleresults
}
coefplot (matrix( twosampleresults [,1]), ci((2 3))) , xline(0) legend(off) grid(none) graphregion(color(white)) title("``exp'title'", size(med) pos(11))
graph save twosampleresults, replace
}
*Combine:
coefplot (matrix(ADHDtwosampleresults [,1]), ci((2 3)) offset(3)) ///
(matrix( Depressiontwosampleresults [,1]), ci((2 3)) offset(4)) ///
(matrix( ASDtwosampleresults [,1]), ci((2 3)) offset(4)) ///
(matrix( Migrainetwosampleresults [,1]), ci((2 3)) offset(4)) ///
(matrix( Asthmatwosampleresults [,1]), ci((2 3)) offset(4)) ///
(matrix( BMItwosampleresults [,1]), ci((2 3))) ///
, xline(0) legend(off) grid(none) graphregion(color(white)) title("title", size(med) pos(11))


***********************************************************************************************************************************************************************************

*OUTLIER CHECK:
use "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\JAN2020_50_IMPs.dta", clear
*To speed this up, drop anyone not in the usable sample:
keep if ingensample==1
merge m:1 cidB2953 qlet using scores_from_plink\nooutliers_yengobmi_score.dta
fre qlet if _merge==2
*DROP ALL THE MOTHERS
drop if qlet=="M"
*and remaining unmatched
drop if _merge==2
drop _merge
count if _mi_m==.
mi register regular nooutliers_yengobmi_cnt nooutliers_yengobmi_score znooutliers_yengobmi_score

*Now rerun regressions with the new PGS.

foreach exp in bmi {
mi xeq 1: regress `exp'10 znooutliers_yengobmi_score if ingensample==1, cluster(ks4sch)
mi xeq 1: regress `exp'13 znooutliers_yengobmi_score if ingensample==1, cluster(ks4sch)
}
label variable znooutliers_yengobmi_score "BMI PGS"

pwcorr znooutliers_yengobmi_score zbmi_score

*Coeffs
*PGS TO GCSEs
eststo clear
foreach pgs in zbmi_score znooutliers_yengobmi_score {
eststo `pgs': mi estimate, post: reg ks4_ptscnewe `pgs' i.gender PC1-PC20  if ingensample==1, cluster(ks4sch)
}
esttab, b(%9.4f) ci(%9.4f) keep(zbmi_score znooutliers_yengobmi_score) compress

*PGS TO ABSENCES
*eform coeffs for % change
eststo clear
foreach pgs in zbmi_score znooutliers_yengobmi_score {
eststo `pgs': mi estimate, post: regress log_percent_absenceyear11 `pgs' i.gender PC1-PC20 if ingensample==1, cluster(ks4sch)
}
esttab, b(%9.4f) ci(%9.4f) keep(zbmi_score znooutliers_yengobmi_score) compress eform

*IV models
eststo clear
foreach exp in bmi  {
foreach age in 10 13 {
eststo z`exp'`age': mi estimate, post cmdok: ivreg ks4_ptscnewe (`exp'`age'=z`exp'_score) gender PC* if ingensample==1, cluster(ks4sch)
eststo znooutliers_yengo`exp'`age': mi estimate, post cmdok: ivreg ks4_ptscnewe (`exp'`age'=znooutliers_yengo`exp'_score) gender PC* if ingensample==1, cluster(ks4sch)
}
}
esttab, b(%9.4f) ci(%9.4f) keep(*bmi*) compress 

eststo clear
foreach exp in bmi  {
foreach age in 10 13 {
eststo z`exp'`age': mi estimate, post cmdok: ivreg log_percent_absenceyear11 (`exp'`age'=z`exp'_score) gender PC* if ingensample==1, cluster(ks4sch) 
eststo znooutliers_yengo`exp'`age': mi estimate, post cmdok: ivreg log_year11_totalabsence (`exp'`age'=znooutliers_yengo`exp'_score) gender PC* if ingensample==1, cluster(ks4sch) 
}
}
esttab, b(%9.4f) ci(%9.4f) keep(*bmi*) eform compress

***********************************************************************************************************************************************************************************

**ENTRY POINT: MRROBUST CHECKS. NEED DOSAGE DATA.

set maxvar 30000

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\robustness_checks"

*clear all 

*set maxvar 30000

*FIRST CHECK SAME STRAND USED IN GWAS vs ALSPAC FOR ALL 6., USING SNPSTATS FILE,
*FOR HARMONIZATION STAGE, CAN LOOP THROUGH FOR ALL 6

*From dosage data, strip off just SNP-level info 
*merge with coeffs from the GWAS
*where effect_allele!=alleleA, reverse the sign of the beta from the GWAS
*in the one case where GWAS betas were on the OR scale (adhd only), first take the log of this (se always relates to the log-odds, even when OR reported)

*PRELIMINARIES:

*You will need relevant info from the SNPstats file, but the concatenated one is massive and takes ages to load, so make a trimmed one with only relevant SNPS:

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\gwas_snps"

foreach exp in adhd asd depress asthma migraine yengobmi {
import delimited `exp'_supp.txt, clear 
gen phenotype="`exp'"
rename snp pgs_snp
save `exp'_supp.dta, replace
}
*append:
use adhd_supp.dta, clear
foreach exp in asd depress asthma migraine yengobmi {
append using `exp'_supp.dta, force
}
*Tidy up:
replace effect_allele=effect_alleleexposure if effect_allele==""
replace other_allele=other_alleleexposure if other_allele==""
drop effect_alleleexposure other_alleleexposure eafexposure chr pos
*save and drop temp ones
save relevantsnps_May2019.dta, replace
foreach exp in asd depress asthma migraine yengobmi {
erase `exp'_supp.dta
}

use relevantsnps_May2019.dta, clear
*Merge this with snpstats on _n
merge 1:1 _n using "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\data\alspac\summary\applications\B2953\dev\release_candidate\data\B2953\genetics\SNP-Stats_FULLY_QCd_VERSION\SNPStats_chr1to22_FILTERED.dta"
drop _merge

gen x=0
levelsof pgs_snp, local(pgs_rsid)
foreach snp of local pgs_rsid {
	replace x = 1 if rsid == "`snp'"
}
fre x
keep if x==1
keep rsid-chromosome

save "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\data\alspac\summary\applications\B2953\dev\release_candidate\data\B2953\genetics\SNP-Stats_FULLY_QCd_VERSION\SNPStats_PGS_SNPs_only.dta", replace


*POST-PRELIMINARIES ENTRY POINT

clear all 
set maxvar 30000
cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\robustness_checks\"

*PART 1: STRIP OFF SNP-LEVEL INFO AND HARMONIZE C.F. GWAS BETAS
foreach exp in asd depress asthma migraine yengobmi {
*Import dosage data and strip off snp-level part
import delimited `exp'_SNPs_ALL_reformat.dosage, delimiter(whitespace) clear 
keep rsid alleleb allelea
rename alleleb alleleb_ipd
rename allelea allelea_ipd
gen exposure="`exp'"
save `exp'_temp.dta, replace
*merge in SNP-level info from the GWAS, for external betas and to compare orientation:
import delimited `exp'_supp.txt, clear 
rename snp rsid 
merge 1:1 rsid using `exp'_temp.dta
drop _merge
*merge in relevant lines from the massive SNPstats file:
merge 1:1 rsid using "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\data\alspac\summary\applications\B2953\dev\release_candidate\data\B2953\genetics\SNP-Stats_FULLY_QCd_VERSION\SNPStats_PGS_SNPs_only.dta"
keep if _merge==3
drop _merge

*Harmonization:
*For the ones currently on OR scale - only ADHD - first get this off the OR scale.
*Nope - already did that upstream when exporting coeffs from R
list rsid effect_allele other_allele alleleb_ipd allelea_ipd a_allele b_allele minor_allele major_allele maf 
*To identify is GWAS snps are on the same strand as in ALSPAC, see if the effect allele is in either of the options from ALSPAC.
*Palindromic SNPs give you no information here (will always be represented in both) so just looking at the other ones.
gen strandcons=0
replace strandcons=1 if effect_allele==a_allele | effect_allele==b_allele
fre strandcons
*All 1 for adhd, asd, dep, asthma, migraine, yengo
*Check there's not a huge number of palindromes such that strand inference might be wrong
capture drop palindromic ambiguous
list effect_allele other_allele alleleb_ipd allelea_ipd
gen palindromic=0
replace palindromic=1 if effect_allele=="A" & other_allele=="T"
replace palindromic=1 if effect_allele=="T" & other_allele=="A"
replace palindromic=1 if effect_allele=="C" & other_allele=="G"
replace palindromic=1 if effect_allele=="G" & other_allele=="C"
fre palindromic
*You're sure about the strands matching (from strandcons check above), harmonize the betas by adding -ves to ones where effect_allele is not the reference allele in ALSPAC.
*The reference allele in the dosage file you used for the score is the first column, labelled alleleb.
*This is because it was created in qctool, where the dosage count is a count of the second allele, i.e. alleleb. 
*In order to use with plink, YOU MANUALLY FLIPPED IT, following Kaitlin's code, to get it into the earlier column. 
*So THIS is the one you care about - the earlier one, labelled alleleb
*Now harmonize everything by adding -ve sign where alleles are flipped:
gen harm_ext_beta_`exp'=betaexposure
*replace harm_ext_beta_`exp'= -(betaexposure) if effect_allele!=alleleb_ipd
replace harm_ext_beta_`exp'= -(betaexposure) if effect_allele!=alleleb_ipd & effect_allele==allelea_ipd
*rename the original:
rename betaexposure orig_ext_beta_`exp'
rename seexposure ext_se_`exp'
rename pvalexposure ext_p_`exp'

*Save it and erase the intermediary:
save `exp'_harmonized_snplevelinfo.dta, replace
erase `exp'_temp.dta
}

/*
cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\robustness_checks"

*Extra check: using EAF for palindromes where we know eaf:
foreach exp in asthma migraine yengobmi {
use `exp'_harmonized_snplevelinfo.dta, clear
capture drop ambiguous
gen ambiguous=0 
replace ambiguous=1 if palindromic==1 & eaf>0.42 & eaf<0.58
list rsid effect_allele other_allele alleleb_ipd allelea_ipd eaf a_allele b_allele minor_allele major_allele maf if palindromic==1 & ambiguous==0
list rsid effect_allele other_allele alleleb_ipd allelea_ipd eaf if ambiguous==1
drop if ambiguous==1
save `exp'_harmonized_snplevelinfo_trimmed.dta, replace
}
*0 for asthma, 1 for migraine, 21 for BMI
*migraine: rs1024905
*bmi: rs10887578 rs12380502 rs12597712 rs13209968 rs138289 rs1454687 rs1521527 rs1554194 rs1554790 rs17100323 rs189843 rs1903579 rs2163188 rs2396625 rs4483850 rs4783241 rs486359 rs6011457 rs6595205 rs676749

*/

**************************************************************************************************************************************************************

*PART 2: PREP USING IPD DATA FROM DOSAGE FILES:

*Later, will merge in the relevant phenotype vars for each:
global exp_list "migraine10 asthma10 asthma13 bmi10 bmi13 adhd10 adhd13 zSCDC_kr_1miss asd13 depress10 depress13"  

foreach exp in adhd asd depress asthma migraine yengobmi {
*Import: nonames option to preserve ids
import delimited dosage/`exp'_SNPs_ALL_reformat.dosage, delimiter(whitespace) varnames(nonames) clear 
*Transpose
sxpose, clear force
*Rename all snp vars with the rsid
rename _var1 idvar
foreach var of varlist _var* {
list `var' in 2
local rsid=`var' in 2
display "`rsid'"
rename `var' `rsid'
}
*Remove the stuff which isn't actually observation=person
drop in 1/5
*encode the SNP variables:
destring rs*, replace 
*Sort out the id for merging with phenotype data:
*convert the ids into one which can be merged on, by stripping off the qlet from cidB2953
split idvar, p("M" "A" "B")
gen qlet=substr(idvar,-1,1)
rename idvar1 cidB2953
*Drop the unsplit one
drop idvar
destring cidB2953, replace
*Drop mothers
drop if qlet=="M"
count
*Save it:
save `exp'_ipd_for_mrrobust.dta, replace
}

**************************************************************************************************************************************************************
**************************************************************************************************************************************************************

*PART 3: ACTUAL ROBUSTNESS CHECKS USING HARMONIZED EXTERNAL BETAS

*OUTCOME: GCSEs

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\robustness_checks\"

*Using the trimmed lists, for each exp save the order of snps in a global macro for later
foreach exp in adhd asd depress asthma migraine yengobmi {
use `exp'_harmonized_snplevelinfo.dta, clear
levelsof rsid, local(`exp'_snps)
display "`exp'_snps"
local `exp'_snplist_temp: subinstr local `exp'_snps "char(34)" "char(32)", all
local `exp'_snplist_temp2: subinstr local `exp'_snplist_temp "rs" "  rs", all
global `exp'_snplist: subinstr local `exp'_snplist_temp2 "  " ""
display $`exp'_snplist
}

**for consistency, do this in imputed data. Save coeffs and SEs from mi estimate, post: regress
*Start with big imputed file, then merge in phenotype
*To speed this up, drop anyone not in the usable sample:
*keep if ingensample==1
***************************************************
foreach exp in adhd asd depress asthma migraine yengobmi {
use "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\JAN2020_50_IMPs.dta", clear
*To speed this up, drop anyone not in the usable sample:
keep if ingensample==1
merge m:1 cidB2953 qlet using `exp'_ipd_for_mrrobust.dta
drop if _mi_m==.
drop _merge
mi register regular rs*
*At this point, merge in the SNP-level info with the harmonized betas:
merge 1:1 _n using "`exp'_harmonized_snplevelinfo.dta"
drop _merge
*Generate empty variables for SNP-level associations:
gen Beta_`exp'=.
gen seBeta_`exp'=.
gen BetaGCSEs=.
gen seBetaGCSEs=.
*And the parameters from the MR checks:
gen exp = ""
gen ivw = .
gen ivw_se = .
gen ivw_p = .
gen egger_slope = .
gen egger_slope_se = .
gen egger_slope_p = .
gen egger_cons = .
gen egger_cons_se = .
gen egger_cons_p = .
gen median = .
gen median_se = .
gen median_p = .
gen modal = .
gen modal_se = .
gen modal_p = .
*FILL THEM IN, keeping the correct order by using the snplist macro:
local k=0
foreach var in $`exp'_snplist {
local k=`k'+1
*SNP-level associations with outcome
mi estimate, post: regress ks4_ptscnewe `var' i.gender PC1-PC20  if ingensample==1, cluster(ks4sch)
replace BetaGCSEs=_b[`var'] in `k'
replace seBetaGCSEs=_se[`var'] in `k'
}
*Now the actual checks, using those coefficients:
*MR robust takes the outcome before the phenotype
 qui replace exp = "`exp'" in 1
*IVW
mregger BetaGCSEs harm_ext_beta_`exp' [aw=1/(ext_se_`exp'^2)], ivw
replace ivw = _b[harm_ext_beta_`exp'] in 1
replace ivw_se = _se[harm_ext_beta_`exp'] in 1
replace ivw_p = 2*normal(-abs(ivw/ivw_se)) in 1
			 *egger with I^2_GX statistic
mregger BetaGCSEs harm_ext_beta_`exp' [aw=1/(seBetaGCSEs^2)], gxse(ext_se_`exp')
replace egger_slope = _b[slope] in 1
replace egger_slope_se = _se[slope] in 1
replace egger_slope_p = 2*normal(-abs(egger_slope/egger_slope_se)) in 1
replace egger_cons = _b[_cons] in 1
replace egger_cons_se = _se[_cons] in 1
replace egger_cons_p = 2*normal(-abs(egger_cons/egger_cons_se)) in 1
*median
mrmedian BetaGCSEs seBetaGCSEs  harm_ext_beta_`exp' ext_se_`exp', weighted
replace median = _b[beta] in 1
replace median_se = _se[beta] in 1
replace median_p = 2*normal(-abs(median/median_se)) in 1
*mode
mrmodal BetaGCSEs seBetaGCSEs  harm_ext_beta_`exp' ext_se_`exp', weighted
replace modal = _b[beta] in 1
replace modal_se = _se[beta] in 1
replace modal_p = 2*normal(-abs(modal/modal_se)) in 1
*save full version:
save `exp'_all_for_mrrobust.dta, replace
*Export results as a separate dataset:
keep exp-modal_p
drop if exp==""
save `exp'_results_from_egger_etc.dta, replace
}

*Append and export
use adhd_results_from_egger_etc.dta, clear
foreach exp in asd depress asthma migraine yengobmi {
append using `exp'_results_from_egger_etc.dta
}
 export delimited using "Robustness_checks_JAN2020", replace
 
***************************************************************************************************************
***************************************************************************************************************
 
 *OUTCOME: ABSENCE
 
 cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\robustness_checks\"

 *Using the trimmed lists, for each exp save the order of snps in a global macro for later
foreach exp in adhd asd depress asthma migraine yengobmi {
use `exp'_harmonized_snplevelinfo.dta, clear
levelsof rsid, local(`exp'_snps)
display "`exp'_snps"
local `exp'_snplist_temp: subinstr local `exp'_snps "char(34)" "char(32)", all
local `exp'_snplist_temp2: subinstr local `exp'_snplist_temp "rs" "  rs", all
global `exp'_snplist: subinstr local `exp'_snplist_temp2 "  " ""
display $`exp'_snplist
}

 foreach exp in adhd asd depress asthma migraine yengobmi {
use "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\JAN2020_50_IMPs.dta", clear
*To speed this up, drop anyone not in the usable sample:
keep if ingensample==1
merge m:1 cidB2953 qlet using `exp'_ipd_for_mrrobust.dta
drop if _mi_m==.
drop _merge
mi register regular rs*
*At this point, merge in the SNP-level info with the harmonized betas:
merge 1:1 _n using "`exp'_harmonized_snplevelinfo.dta"
drop _merge
*Generate empty variables for SNP-level associations:
gen Beta_`exp'=.
gen seBeta_`exp'=.
gen BetaAbsence=.
gen seBetaAbsence=.
*And the parameters from the MR checks:
gen exp = ""
gen ivw = .
gen ivw_se = .
gen ivw_p = .
gen egger_slope = .
gen egger_slope_se = .
gen egger_slope_p = .
gen egger_cons = .
gen egger_cons_se = .
gen egger_cons_p = .
gen median = .
gen median_se = .
gen median_p = .
gen modal = .
gen modal_se = .
gen modal_p = .
*FILL THEM IN, keeping the correct order by using the snplist macro:
local k=0
foreach var in $`exp'_snplist {
local k=`k'+1
*SNP-level associations with outcome
mi estimate, post: regress log_percent_absenceyear1011 `var' i.gender PC1-PC20  if ingensample==1, cluster(ks4sch)
replace BetaAbsence=_b[`var'] in `k'
replace seBetaAbsence=_se[`var'] in `k'
}
*Now the actual checks, using those coefficients:
*MR robust takes the outcome before the phenotype
 qui replace exp = "`exp'" in 1
*IVW
mregger BetaAbsence harm_ext_beta_`exp' [aw=1/(ext_se_`exp'^2)], ivw
replace ivw = _b[harm_ext_beta_`exp'] in 1
replace ivw_se = _se[harm_ext_beta_`exp'] in 1
replace ivw_p = 2*normal(-abs(ivw/ivw_se)) in 1
			 *egger with I^2_GX statistic
mregger BetaAbsence harm_ext_beta_`exp' [aw=1/(seBetaAbsence^2)], gxse(ext_se_`exp')
replace egger_slope = _b[slope] in 1
replace egger_slope_se = _se[slope] in 1
replace egger_slope_p = 2*normal(-abs(egger_slope/egger_slope_se)) in 1
replace egger_cons = _b[_cons] in 1
replace egger_cons_se = _se[_cons] in 1
replace egger_cons_p = 2*normal(-abs(egger_cons/egger_cons_se)) in 1
*median
mrmedian BetaAbsence seBetaAbsence  harm_ext_beta_`exp' ext_se_`exp', weighted
replace median = _b[beta] in 1
replace median_se = _se[beta] in 1
replace median_p = 2*normal(-abs(median/median_se)) in 1
*mode
mrmodal BetaAbsence seBetaAbsence  harm_ext_beta_`exp' ext_se_`exp', weighted
replace modal = _b[beta] in 1
replace modal_se = _se[beta] in 1
replace modal_p = 2*normal(-abs(modal/modal_se)) in 1
*save full version:
save `exp'_absence_all_for_mrrobust.dta, replace
*Export results as a separate dataset:
keep exp-modal_p
drop if exp==""
save `exp'_absence_results_from_egger_etc.dta, replace
}

*Append and export results of checks:
use adhd_absence_results_from_egger_etc.dta, clear
foreach exp in asd depress asthma migraine yengobmi {
append using `exp'_absence_results_from_egger_etc.dta
}
 export delimited using "Absences_Robustness_checks_JAN2020", replace
 
 
 *Pleiotropy in the absence-BMI associations!
use yengobmi_absence_all_for_mrrobust.dta, clear
keep rsid BetaAbsence seBetaAbsence harm_ext_beta_yengobmi ext_se_yengobmi
keep in 1/965

*https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5985452/
rename BetaAbsence Beta_ZY
rename seBetaAbsence se_Beta_ZY
rename harm_ext_beta_yengobmi Beta_ZX
rename ext_se_yengobmi se_Beta_ZX

gen Beta_XY=Beta_ZY/Beta_ZX

*Get variances:
gen var_Beta_ZX=se_Beta_ZX^2
gen var_Beta_ZY=se_Beta_ZY^2
*Other terms:
gen Beta_squared_ZX=Beta_ZX^2
gen Beta_squared_ZY=Beta_ZY^2
gen Beta_foured_ZX=Beta_ZX^4

*So...
gen a=var_Beta_ZY/Beta_squared_ZX
gen b=(Beta_squared_ZY/Beta_foured_ZX)*var_Beta_ZX
gen var_Beta_XY=a+b
gen se_Beta_XY=sqrt(a+b)

*Check it
list Beta_XY se_Beta_XY
summ  Beta_XY
*Variable	Obs	Mean	Std. Dev. 	Min		Max
*Beta_XY	965    .1363428    1.161571  -4.832944   3.935823

*Which of these are outliers?
*IVW estimate: 0.096042693 se: 0.03329492

gen yengobmi_ivw=0.096042693
gen yengobmi_ivw_se=0.03329492

gen beta_SNP_diff=Beta_XY-yengobmi_ivw
gen se_SNP_diff=sqrt((se_Beta_XY^2)+(0.03329492^2))
gen p_SNP_diff=2*normal(-abs(beta_SNP_diff/se_SNP_diff))

*Look at the p values:
sort p_SNP_diff
list rsid beta_SNP_diff  se_SNP_diff p_SNP_diff

*critical p=.00005181
display 0.05/965

keep rsid Beta_XY se_Beta_XY beta_SNP_diff se_SNP_diff p_SNP_diff

export delimited using "Absences_outlier_identification", replace

******************************************************************************************************************************

*SCHOOL TYPE CHECKS

*ENTRY POINT: Observational:

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

use "JAN2020_50_IMPs.dta", clear

global covars "i.gender i.maternaleduc i.maternaltenure_simple maternal_age i.maternalparity_CATEG i.smokedinpreg"

fre ingen

*OBSERVATIONAL: HEALTH CONDS --> GCSEs:

*NB: using _1miss or _cc versions of MFQ make so little difference had to check at 4th decimal place

*Exposure variables renamed prior to imputation
*Also fix the labels
label variable migraine10 "Migraines, age 10"
label variable adhd10 "SDQ-HI score, age 10"
label variable adhd13 "SDQ-HI score, age 13"
label variable asd10 "SCDC score, age 10"
label variable asd13 "SCDC score, age 13"
label variable depress10 "MFQ score, age 10"
label variable depress13 "MFQ score, age 13"
label variable asthma10 "Asthma, age 10"
label variable asthma13 "Asthma, age 13"
label variable bmi10 "BMI z-score, age 10"
label variable bmi13 "BMI z-score, age 13"

capture erase results\typespecific_schools_health_to_GCSEs.txt
capture erase results\typespecific_schools_health_to_GCSEs.xls
capture erase results\typespecific_schools_health_to_absence.txt
capture erase results\typespecific_schools_health_to_absence.xls

foreach type in 1 2 3 {
*Restrict by type
preserve
keep if  ks4_stype_v2==`type'
**TABLES 2 AND 3
eststo clear
foreach healthcond in adhd10 depress10 asd10 migraine10 asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13   {
*GCSEs
eststo `healthcond': mi estimate, post: reg ks4_ptscnewe `healthcond' $covars if ingensample==1, cluster(ks4sch)
outreg2 using results\typespecific_schools_health_to_GCSEs.xls, stats (coef ci_low ci_high) sideway dec(2) nor nocons noobs noaster append label  keep (adhd10 depress10 asd10 migraine10 asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13) ctitle(GCSE points) 
*Absence
eststo `healthcond'absence: mi estimate, post: reg log_percent_absenceyear1011 `healthcond' $covars if ingensample==1, cluster(ks4sch)
outreg2 using results\typespecific_schools_health_to_absence.xls, stats (coef ci_low ci_high) sideway eform dec(4) nor nocons noobs noaster append label  keep (adhd10 depress10 asd10 migraine10 asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13) ctitle(logged days) 
}
restore
}

*************************************************
*MEDIATION

*Paramed: syntax and explanaiton here: file://ads.bris.ac.uk/filestore/MyFiles/Staff19/sh5327/Documents/paramed.pdf
clear all
cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

set maxvar 30000

*Drop by school type:

foreach type in 1 2 3 {
use "JAN2020_50_IMPs.dta", clear
*Restrict by type
keep if  ks4_stype_v2==`type'
*can't restrict to analytic sample with if, so drop anyone outside of it
replace ingen=0 if ks4sch==.
replace ingen=0 if ks4sch==-1
drop if ingen!=1
********************************************
*Drop m=0, as makes things more complicated later:
drop if _mi_m==0
********************************************
*Make variables for the parameters, then fill 1-50.
*Update: for within-imputation variance, need to square within-imputation SE:
foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
foreach effect in cde nie te {
gen `exp'_`effect' = .
gen `exp'_`effect'_se = .
gen `exp'_`effect'_v = .
gen `exp'_`effect'_p = .
*With continuous mediator only, doesn't give you nde so don't need to worry about parameters for that, at least if you specify nointer
}
}
*NEED TO BLOCK-REPEAT PER PARAMETER: 
*can't loop through using the common part because it doesn't work trying to loop through matrix names
levelsof _mi_m, local(levels) 
foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
foreach out in ks4_ptscnewe {
foreach med in log_percent_absenceyear1011 {
*Loop through each dataset
foreach l of local levels {
preserve
keep if _mi_m == `l'
paramed `out', avar(`exp') mvar(`med') cvars(gender maternaleduc_dummy*  maternaltenure_dummy* maternalparity_CATEG_dummy* maternal_age smokedinpreg) a0(0) a1(1) m(1) yreg(linear) mreg(linear) nointer
mat results = e(effects)
mat list results 
restore
*Now fill this in, using each time the contents of the latest (temporary) matrix
replace `exp'_cde = results[1,1] in `l'
replace `exp'_cde_se = results[1,2] in `l'
replace `exp'_cde_p = results[1,3] in `l'
replace `exp'_nie = results[2,1] in `l'
replace `exp'_nie_se = results[2,2] in `l'
replace `exp'_nie_p = results[2,3] in `l'
replace `exp'_te = results[3,1] in `l'
replace `exp'_te_se = results[3,2] in `l'
replace `exp'_te_p = results[3,3] in `l'
*Check it:
list `exp'_cde `exp'_cde_se `exp'_cde_v  `exp'_cde_p `exp'_nie `exp'_nie_se `exp'_nie_v `exp'_nie_p `exp'_te `exp'_te_se `exp'_te_v `exp'_te_p in 1/50
}
}
}
}
*Next thing: FOR WITHIN-IMPUTATION VARIANCE, mean of the variance in each imp, i.e. saved means of the parameters:
foreach exp in adhd10 depress10 asd10 bmi10 asthma10 migraine10 adhd13 depress13 asd13 bmi13 asthma13  {
*mean across imps of variance of each parameter
foreach effect in cde nie te {
*gen variance
replace `exp'_`effect'_v=`exp'_`effect'_se^2  
*summ across imps
sum `exp'_`effect'_v 
gen vwithinimp_`exp'_`effect'=r(mean)
list  vwithinimp_`exp'_`effect' in 1/11
}
}
*For BETWEEN-IMPUTATION VARIANCE: 
*'This is estimated by taking the variance of the parameter of interest estimated over imputed datasets. 
*This formula is equal to the formula for the (sample) variance which is commonly used in statistics. 
*Between-imp variance=sqrt(Σ((imp-specific parameter - pooled parameter)^2))/N-1)
*So, for pooled parameters, across-imp mean of the betas:
foreach exp in adhd10 depress10 asd10 migraine10 asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13  {
foreach effect in cde nie te {
sum `exp'_`effect'
gen mean_`exp'_`effect'=r(mean)
list  mean_`exp'_`effect' in 1/11
*For the squared diff
gen `exp'_`effect'_sqdiff=(`exp'_`effect'-mean_`exp'_`effect')^2
list `exp'_`effect'_sqdiff in 1/11
*Correct that missing in n=11
*Take the sum of that:
egen sigma_`exp'_`effect'_sqdiff=sum(`exp'_`effect'_sqdiff)
list sigma_`exp'_`effect'_sqdiff in 1/11
*All the same - good
*Now for between-imp variance, divide by N-1 and take sqrt:
gen vbimp_`exp'_`effect'=sqrt(sigma_`exp'_`effect'_sqdiff/49)
list vbimp_`exp'_`effect' in 1/11
}
}
*For TOTAL, formula is V-within + V-between + (V-between/m)
foreach exp in adhd10 depress10 asd10 migraine10 asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13  {
foreach effect in cde nie te {
gen v_total_`exp'_`effect'= vwithinimp_`exp'_`effect' +  vbimp_`exp'_`effect' +  (vbimp_`exp'_`effect'/50)
gen se_total_`exp'_`effect'= sqrt(v_total_`exp'_`effect')
list mean_`exp'_`effect' se_total_`exp'_`effect' in 1/11
}
}
*for the CI
foreach exp in adhd10 depress10 asd10 migraine10 asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13  {
foreach effect in cde nie te {
gen lci_`exp'_`effect'=mean_`exp'_`effect' -(1.96*se_total_`exp'_`effect')
gen uci_`exp'_`effect'=mean_`exp'_`effect' +(1.96*se_total_`exp'_`effect')
*P value
gen p_`exp'_`effect'=2*normal(-abs(mean_`exp'_`effect'/se_total_`exp'_`effect'))
list mean_`exp'_`effect' lci_`exp'_`effect' uci_`exp'_`effect' p_`exp'_`effect' in 1
}
}

foreach exp in adhd10 depress10 asd10 migraine10 asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13  {
display "`exp'"
list mean_`exp'_cde lci_`exp'_cde uci_`exp'_cde p_`exp'_cde  in 1
list mean_`exp'_nie lci_`exp'_nie uci_`exp'_nie p_`exp'_nie  in 1
list mean_`exp'_te  lci_`exp'_te uci_`exp'_te p_`exp'_te in 1
}
*Rearrange these better:
gen exp=""
gen effect=""
gen mean=.
gen lci=.
gen uci=.
gen p=.
local k=0
foreach exp in adhd10 depress10 asd10 migraine10 asthma10 bmi10 adhd13 depress13 asd13 asthma13 bmi13  {
foreach effect in cde nie te {
local k=`k'+1
replace effect="`effect'" in `k'
replace exp="`exp'" in `k'
replace mean=mean_`exp'_`effect' in `k'
replace lci=lci_`exp'_`effect' in `k'
replace uci=uci_`exp'_`effect' in `k'
replace p=p_`exp'_`effect' in `k'
}
}
*SECTION OFF AND SAVE:
preserve
keep mean_* lci_* uci_* p_* exp effect mean lci uci p
keep in 1/33
*Export coeffs for tables:
export delimited using results/type`type'schools_paramedcoeffs, delimiter (",") replace
restore
clear
}

******************************************

*SCHOOL TYPE CHECKS: GENETIC ANALYSES FOR STRAIGHT PGS ASSOCIATIONS.

clear all
set maxvar 30000

cd "\\rdsfcifs.acrc.bris.ac.uk\MRC-IEU-research\projects\ieu2\p6\059\working\data\Mandy\"

use "JAN2020_50_IMPs.dta", clear

*PREDICTION OF GCSEs AND ABSENCES

label variable zadhd_score "ADHD PGS"
label variable zasd_score "ASD PGS"
label variable zdepress_score "depression PGS"
label variable zmigraine_score  "migraine PGS"
label variable zasthma_score "asthma PGS"
label variable zbmi_score "BMI PGS"

capture erase results\typespecific_schools_pgs_to_GCSEs.txt
capture erase results\typespecific_schools_pgs_to_GCSEs.xls
capture erase results\typespecific_schools_pgs_to_absence.txt
capture erase results\typespecific_schools_pgs_to_absence.xls

*PGS to GCSEs and absences
foreach type in 1 2 3 {
*Restrict by type
preserve
keep if  ks4_stype_v2==`type'
eststo clear
foreach pgs in zadhd_score zdepress_score zasd_score zmigraine_score zasthma_score zbmi_score {
*GCSEs
*eststo `pgs': mi estimate, post: reg ks4_ptscnewe `pgs' i.gender PC1-PC20  if ingensample==1, cluster(ks4sch)
*outreg2 using "results\typespecific_schools_pgs_to_GCSEs.xls", stats (coef ci_low ci_high) dec(2) sideway nor nocons noobs noaster append label  keep (`pgs') ctitle(GCSE points) title(Direct associations: standardized PGSs to GCSEs) addnote("Adjusted for gender and PC1-PC20")
*Absence
eststo `healthcond'absence: mi estimate, post: reg log_percent_absenceyear1011 `pgs' i.gender PC1-PC20 if ingensample==1, cluster(ks4sch)
outreg2 using results\typespecific_schools_pgs_to_absence.xls, stats (coef ci_low ci_high) sideway eform dec(4) nor nocons noobs noaster append label  keep (`pgs') ctitle(logged days) title(Direct associations: PGSs to year10 absences)  addnote("Adjusted for gender and PC1-PC20")
}
restore
}
