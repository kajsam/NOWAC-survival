/*Paper 1 - Cox regression with age as time-scale*/
use "C:\Users\imk023\OneDrive - UiT Office 365\PhD\Paper 1\STATA\ida1011_COX.dta" 

*lager variabel for antall år oppfølgingstid 
*installerer personage package
ssc inst personage
personage startdat enddat_new, gen (years_followup)
list startdat enddat_new emigdt doddt totaldod years_followup in 161100/161140

*setter alder som tidsvariabel
gen timeage=startald+years_followup
list timeage startald years_followup in 1/20

stset timeage, failure(totaldod==0) enter(startald)

*Run model unadjusted, save as MA0
stcox ib0.egenhels /*ref: meget god*/
estimates store MA0, title(egenhels)

/*Build model:
Dagitty(total effect): 
Minimal sufficient adjustment sets for estimating the total effect of SRH on Death:
Age, BMI, Blodpropp, DM, HF, Inntekt, MI, PA, Sivil status, Slag, Smoking, Utdanningslengde */

stcox ib0.egenhels ib2.bmi_WHOgr ib1.roykstat ib1.aktidag_gr ib1.blodpr_new ib1.diab_new ib1.hjerte_new ib1.inf_new ib1.slag_new ib0.skole_4gr ib0.brutto_new ib0.sivstat_new 
est store MA1, title(full model)

*remove sivstat_new
stcox ib0.egenhels ib2.bmi_WHOgr ib1.roykstat ib1.aktidag_gr ib1.blodpr_new ib1.diab_new ib1.hjerte_new ib1.inf_new ib1.slag_new ib0.skole_4gr ib0.brutto_new 
est store MA2, title(remove sivstat_new)

*remove skole_4gr
stcox ib0.egenhels ib2.bmi_WHOgr ib1.roykstat ib1.aktidag_gr ib1.blodpr_new ib1.diab_new ib1.hjerte_new ib1.inf_new ib1.slag_new ib0.brutto_new 
est store MA3, title(remove sivstat_new+skole_4gr)

*remove slag_new
stcox ib0.egenhels ib2.bmi_WHOgr ib1.roykstat ib1.aktidag_gr ib1.blodpr_new ib1.diab_new ib1.hjerte_new ib1.inf_new ib0.brutto_new 
est store MA4, title(remove sivstat_new+skole_4gr+slag_new)

*remove blodpropp
stcox ib0.egenhels ib2.bmi_WHOgr ib1.roykstat ib1.aktidag_gr ib1.diab_new ib1.hjerte_new ib1.inf_new ib0.brutto_new 
est store MA5, title(remove sivstat_new+skole_4gr+slag_new+blodpr_new)

*model tests

dir
est stat
est table MA0 MA1 MA2 MA3 MA4 MA5, eform star stat(N ll rank aic bic)

est restore MA5 /** Set model M4 to "current estimation result" **/
estat phtest
estat phtest, detail


*Merker at modellen er litt problemaitsk (PH assumptions)

*Prøver med SRH i tre kategorier og sivstat i 2 kategorier:

stcox ib0.egenhels_3gr /*ref meget god*/
est store MAS0, title (crude)

stcox ib0.egenhels_3gr ib1.aktidag_gr
est store MAS1, title (PA) 

stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat 
est store MAS2, title (PA+smoke)

stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr
est store MAS3, title (PA+smoke+BMI)

*log transform bmi_NEW 
gen lnBMI = log(bmi_NEW)
histogram lnBMI, frequency

*no
*new BMI cutoffs:
recode bmi_NEW (10/24.9999999=1 "BMI<25")(25/29.9999999=2 "25=<BMI<30")(30/73=3 "BMI>= 30"), gen(BMI_3gr)


stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr ib0.brutto_new
est store MAS4, title(PA+smoke+lnBMI+income)

stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr ib0.brutto_new ib0.sivstat_new2gr
est store MAS5, title(PA+smoke+lnBMI+income+partner)

stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr ib0.brutto_new ib0.sivstat_new2gr ib1.skole_4gr
est store MAS6, title(PA+smoke+lnBMI+income+partner+educ)

stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr ib0.brutto_new ib0.sivstat_new2gr ib1.skole_4gr ib1.slag_new
est store MAS7, title(PA+smoke+lnBMI+income+partner+educ+stroke)

stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr ib0.brutto_new ib0.sivstat_new2gr ib1.skole_4gr ib1.slag_new ib1.hjerte_new
est store MAS8, title(PA+smoke+lnBMI+income+educ+stroke+HF)

stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr ib0.brutto_new ib0.sivstat_new2gr ib1.skole_4gr ib1.slag_new ib1.hjerte_new ib1.inf_new
est store MAS9, title(PA+smoke+lnBMI+income+educ+stroke+HF+infarction)

stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr ib0.brutto_new ib0.sivstat_new2gr ib1.skole_4gr ib1.slag_new ib1.hjerte_new ib1.inf_new ib1.diab_new
est store MAS10, title(PA+smoke+lnBMI+income+educ+stroke+HF+infarction+diab)

stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr ib0.brutto_new ib0.sivstat_new2gr ib1.skole_4gr ib1.slag_new ib1.hjerte_new ib1.inf_new ib1.diab_new ib1.blodpr_new
est store MAS11, title(PA+smoke+lnBMI+income+educ+stroke+HF+infarction+diab+thrombosis)

dir
est stat
est table MAS0 MAS1 MAS2 MAS3 MAS4 MAS5 MAS6 MAS7 MAS8 MAS9 MAS10 MAS11, eform star stat(N ll rank aic bic)

est restore MAS11 /** Set model MAS11 to "current estimation result" **/
estat phtest
estat phtest, detail

*remove stroke from MAS11
stcox ib0.egenhels_3gr ib1.aktidag_gr ib1.roykstat ib1.BMI_3gr ib0.brutto_new ib0.sivstat_new2gr ib1.skole_4gr ib1.hjerte_new ib1.inf_new ib1.diab_new ib1.blodpr_new
est store MAS12, title(PA+smoke+lnBMI+income+educ+HF+infarction+diab+thrombosis)

dir
est stat
est table MAS0 MAS1 MAS2 MAS3 MAS4 MAS5 MAS6 MAS7 MAS8 MAS9 MAS10 MAS12, eform star stat(N ll rank aic bic)

est restore MAS12 /** Set model MAS12 to "current estimation result" **/
estat phtest
estat phtest, detail

stcox i.egenhels_3gr i.aktidag_gr i.roykstat i.brutto_new
est store MAS13, title(10 percent impact)
estat phtest, detail

*"Problematic" variables
*BMI
graph box bmi_NEW, over(bmi_WHOgr)

histogram bmi_NEW, frequency
(bin=50, start=10.140616, width=1.2472757)

*Logistic regression/Mixed model analysis
*Does smoking increase mortality risk?
logit dead packyear, or
logit 

*does the increased risk vary between groups of smoke status?
melogit dead packyear || roykstat:, or
*yes, it does 

save "C:\Users\imk023\OneDrive - UiT Office 365\PhD\Paper 1\STATA\ida1011_COX.dta", replace

