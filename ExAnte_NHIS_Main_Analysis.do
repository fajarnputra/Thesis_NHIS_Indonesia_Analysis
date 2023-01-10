/*
********************************************************************************
DO FILE FOR THESIS
	Sumber Data		: IFLS 4 dan 5
	tanggal modif.	: 11 October 2019

** Catatan Untuk Do-file yang menghitung pengeluaran perkapita rumah tangga 
** menggunakan do file lainnya yang terdapat pada folder
** expenditure_per_capita yang terdapat di folder yang digunakan. 
** (Karena terlalu panjang sehingga dipisah dari do file utama.
********************************************************************************
*/

clear
#delimit ;
capture log close ;
set more off ;
cd "D:\FAJAR\THESIS_REAL\DATA_TESIS_LENGKAP\Data" ;
log using catatan_baru, replace text ;


*** PERSIAPAN DATA/ MANAGEMEN DATA *** ;


**************************************** KEPEMILIKAN ASURANSI IFLS4 dan IFLS5 ***************************************************************** ;

/* buku 3b bagian AK (asuransi kesehatan) Wave 4 (2007)*/ ;
use ifls_4\b3b_ak1.dta, clear ;
replace aktype = "X" if ak01 == 3 ;
reshape wide ak02 ak03x ak03 ak04 ak05, i(pidlink) j(aktype) s ;
gen Jenis_Asuransi7 = "JKN" ;
replace Jenis_Asuransi7 = "NON" if ak01 == 3 ;
replace Jenis_Asuransi7 = "Mixed" if (ak02C == 1 | ak02D == 1 | ak02E == 1 | ak02G == 1) | ((ak02A == 1 | ak02B == 1 | ak02H == 1) & 
(ak02C == 1 | ak02D == 1 | ak02E == 1 | ak02G == 1)) ;
tab Jenis_Asuransi7 ;
save tahun2007.dta, replace

/* buku 3b bagian AK (asuransi kesehatan) Wave 5 (2014)*/ ;
use ifls_5\b3b_ak1.dta, clear ; 
replace aktype = "X" if ak01 == 3 ;
drop if aktype == "" ;
reshape wide ak02 ak03x ak03 ak04 ak05, i(pidlink) j(aktype) s ;
gen Jenis_Asuransi14 = "JKN" ;
replace Jenis_Asuransi14 = "NON" if ak01 == 3 ;
replace Jenis_Asuransi14 = "Mixed" if (ak02C == 1 | ak02D == 1 | ak02E == 1 | ak02G == 1) | ((ak02A == 1 | ak02B == 1 | ak02H == 1 | 
ak02I == 1 | ak02J == 1 | ak02K == 1 | ak02L == 1) & (ak02C == 1 | ak02D == 1 | ak02E == 1 | ak02G == 1)) ;
tab Jenis_Asuransi14 ;
save tahun2014.dta, replace ;

/* Merge file IFLS4 dan IFLS5 */ ;
/* master IFLS5 using IFLS4 */ ;
merge m:m pidlink using tahun2007.dta ;
keep if _m==3 ; 
drop _m ;
tab Jenis_Asuransi7 Jenis_Asuransi14 ;
** drop pidlink, hhid07 atau hhid14_9 yg duplicate ;
drop if pidlink == "." ;
drop if hhid07 == "." ;
drop if hhid14_9 == "." ;
drop hhid14 ;
save asuransi45.dta, replace ;

******************************************************* RISKY HEALTH BEHAVIORS ************************************************************* ;

******************************************************************** ATIVITITAS FISIK ;
/* dengan data yang jalan kaki 07*/ ;
use ifls_4\b3b_kk2.dta, clear ;
keep if kktype == "C" ; rename kk02m dumjln7 ; rename kk02n1 jlncat17 ; rename kk02n2 jlncat27 ; rename kk02o jlnfreq7 ; drop kktype ; drop if jlnfreq7 == 9 ;
save jalan_4.dta, replace ;

/* dengan data yang jalan kaki 14*/ ;
use ifls_5\b3b_kk2.dta, clear ;
keep if kktype == "C" ; rename kk02m dumjln14 ; rename kk02n1 jlncat114 ; rename kk02n2 jlncat214 ; rename kk02o jlnfreq14 ; drop kktype ;
drop hhid14 ;
save jalan_5.dta, replace ;

*********************************************************************** SMOKING BEHAVIOR ;
/* IFLS 4 */
use ifls_4/b3b_km, clear ;
drop if (km08x == 8 | km08x == 9) | (km09x == 8 | km09x == 9) ;
drop if km08 == 95 | km08 == 98 ; drop if km04 == 3 ;
replace km08 = 0 if km08 == . ;
replace km09 = 0 if km09 == . ;
gen dumrokok7 = 0 ;
replace dumrokok7 = 1 if km01a == 1; 
keep km08 km09 dumrokok hhid07 pidlink ; rename km08 km087 ; rename km09 km097 ;
save rokok_4.dta, replace ;

/* IFLS 5 */
use ifls_5/b3b_km, clear ;
drop if (km08x == 8) | (km09x == 8) ;
drop if km08 == 95 | km08 == 98 ; drop if km09 == 999998 | km09 == 999999 ; drop if km04 == 3 ;
replace km08 = 0 if km08 == . ;
replace km09 = 0 if km09 == . ;
gen dumrokok14 = 0 ;
replace dumrokok14 = 1 if km01a == 1; 
keep km08 km09 dumrokok hhid14_9 pidlink ; rename km08 km0814 ; rename km09 km0914 ;
save rokok_5.dta, replace ;


***************************************************** KOMSUMSI MAKANAN BERISIKO ;

****** FREKUENSI MAKAN ;
** Ternyata yang IFLS4 GA SELENGKAP IFLS5 ;
use ifls_4/b3b_fm, clear ;
keep hhid07 pidlink fmtype fm03 ;
reshape wide fm03, i(pidlink) j(fmtype) s ;
foreach bro in fm03* { ;
		rename `bro' `bro'7 ;
		};
save makan_4.dta, replace ;

use ifls_5/b3b_fm2, clear ;
keep hhid14_9 pidlink fmtype fm03 ;
reshape wide fm03, i(pidlink) j(fmtype) s ;
foreach bro in fm03* { ;
		rename `bro' `bro'14 ;
		};
save makan_5.dta, replace ;

***************************************************** BMI TUBUH & LINGKAR PINGGANG ;
use ifls_4/bus1_1, clear ;
keep hhid07 pidlink us06 ; rename us06 us067 ; drop if us067 == .; duplicates drop pidlink, force ;
save tubuh1_4.dta, replace ;
use ifls_4/bus1_2, clear ;
keep hhid07 pidlink us06a us04 ; rename us06a us06a7 ; rename us04 us047 ; duplicates drop pidlink hhid07, force ;
save tubuh2_4.dta, replace ;

use ifls_5/bus_us, clear ;
keep hhid14_9 pidlink us06 us04 us06a_cd us06a ; rename us06 us0614 ; rename us06a us06a14 ; rename us04 us0414 ;
save tubuh_5.dta, replace ;


****************************** MERGE RIKSY HEALTH BEHAVIORS ;
**** IFLS 4 ;
use jalan_4.dta, clear ;
merge m:m pidlink hhid07 using rokok_4 ; keep if _m==3 ; drop _m ;
merge m:m pidlink hhid07 using makan_4 ; keep if _m==3 ; drop _m ;
merge m:m pidlink hhid07 using tubuh1_4 ; keep if _m==3 ; drop _m ;
merge m:m pidlink hhid07 using tubuh2_4 ; keep if _m==3 ; drop _m ;
drop if pidlink == "no change" ;
save riskbhvr_4.dta, replace ;
**** IFLS 5 ;
use jalan_5.dta, clear ;
merge m:m pidlink hhid14_9 using rokok_5 ; keep if _m==3 ; drop _m ;
merge m:m pidlink hhid14_9 using makan_5 ; keep if _m==3 ; drop _m ;
merge m:m pidlink hhid14_9 using tubuh_5 ; keep if _m==3 ; drop _m ;
save riskbhvr_5.dta, replace ;
merge m:m pidlink using riskbhvr_4 ; keep if _m==3 ; drop _m ;
save riskbhvr45.dta, replace ;


********************************************************* CONTROL VARIABLES ************************************************************* ;

*********** IFLS4 | Merge dataset yang nantinya untuk generate variabel kontrol ;
use ifls_4\bk_ar1, clear ; save 4_ar1, replace ;
use ifls_4\bk_sc, clear ; save 4_sc, replace ;
use ifls_4\b1_ks2, clear ; keep if ks2type == "E" ; save 4_ks2, replace ;
use ifls_4\b2_hr1, clear ; keep if hrtype == "E" ; save 4_hr1, replace ;
use 4_sc, clear ;
merge m:m hhid07 using 4_ks2 ; keep if _m==3 ; drop _m ;
merge m:m hhid07 using 4_hr1 ; keep if _m==3 ; drop _m ;

** SPECIFIC CONTROL VARIABLES ;
** RURAL/URBAN ;
gen urban7 = sc05 ; replace urban7 = 0 if urban7 == 2 ;
** Vehicle assets ;
drop if hr11 == 99 ;
gen vehicle7 = hr11 ; replace vehicle7 = 0 if vehicle7 == . ;
** transportation expenses ;
gen transport7 = ks06 ;
** keep variable untuk mempermudah merge nantinya ;
drop if hhid07 == "." ;
keep hhid07 urban7 vehicle7 transport7 ;
save 4_scks2hr1, replace ;

** COMMON CONTROL VARIABLES ;
use 4_ar1, clear ;
** INCOME PER CAPITA;
** HH SIZE ;
keep if (ar01a == 1 | ar01a == 2 | ar01a == 5 | ar01a == 11) ;
gen hitung = 1 ;
egen hhsize7 = sum(hitung), by (hhid07_9) ;
drop if ar15bx == 8 | ar15bx == 9 ;
replace ar15b = 0 if ar15bx == 6 ;
egen inc_all = sum(ar15b), by (hhid07_9) ;
gen incpercap7 = inc_all / hhsize7 ;
replace incpercap7 = . if ar15bx == . ;
** AGE ;
**drop if ar09 > 94 & ar09 < 1000 ;
drop if ar09 == 998 | ar09 == 999 ;
gen age7 = ar09 ;
** GENDER ;
gen gender = ar07; 
replace gender = 0 if gender == 3 ;
** MARRIED STATUS ;
drop if ar13 == 8 | ar13 == 9 ;
gen married7 = 0 ;
replace married7 = 1 if ar13 == 2 ;
** EDUCATION ;
drop if (ar16 == 14 & ar17 == 98) | (ar16 == 17 & ar17 == 99) | ar16 == 95 | ar16 == 98 | ar16 == 99 ;
gen noschool7 = 0 ;
gen sd7 = 0 ;
gen smp7 = 0 ;
gen smak7 = 0 ;
gen univ7 = 0 ;
replace noschool7 = 1 if ar16 == 1 | ar16 == 90 | (ar16 == 14 & ar17 != 7) | (ar16 == 17 & ar17 != 7) ;
replace sd7 = 1 if ar16 == 2 | ar16 == 11 | ar16 == 72 | (ar16 == 14 & ar17 == 7) | (ar16 == 17 & ar17 == 7) ;
replace smp7 = 1 if ar16 == 3 | ar16 == 4 | ar16 == 12 | ar16 == 73 ;
replace smak7 = 1 if ar16 == 5 | ar16 == 6 | ar16 == 15 | ar16 == 74 ;
replace univ7 = 1 if ar16 == 13 | ar16 == 60 | ar16 == 61 | ar16 == 62 | ar16 == 63 ;
** EMPLOYMENT STATUS ;
drop if ar15a == 8 | ar15a == 9 ;
gen labor7 = 0 ;
replace labor7 = 1 if ar15a == 1 ;

** keep variable yang hanya diperlukan untuk mempermudah merge;
drop if pidlink == "." ;
keep pidlink hhid07 hhsize7 incpercap7 age7 gender married7 noschool7 sd7 smp7 smak7 univ7 labor7 ;
duplicates drop pidlink hhid07, force ;
save 4_ar1, replace ;

** TIMEPREF DAN RISKPREF IFLS4 ;
use ifls_4\b3a_si.dta, clear ;
drop if si21a == 9 | si21b == 9 | si21c == 9 | si21d == 9 | si21e == 9 ;
drop if si21a == 2 & si21e == 1 ;
gen timepref7 = 1 ;
replace timepref7 = 2 if (si21a == 1 & si21b == 2 & si21d == 2) | (si21a == 2 & si21e == 3 & si21b == 2 & si21d == 2) ;
replace timepref7 = 3 if (si21a == 1 & si21b == 2 & si21d == 1) | (si21a == 2 & si21e == 3 & si21b == 2 & si21d == 1) ;
replace timepref7 = 4 if (si21a == 1 & si21b == 1 & si21c == 2) | (si21a == 2 & si21e == 3 & si21b == 1 & si21c == 2) ;
replace timepref7 = 5 if (si21a == 1 & si21b == 1 & si21c == 1) | (si21a == 2 & si21e == 3 & si21b == 1 & si21c == 1) ;

gen riskpref7 = 0 ;
replace riskpref7 = 1 if si03 == 2 | si04 == 2 | si13 == 2 | si14 == 2 ;
replace riskpref7 = 2 if (si03 == 2 & si13 == 2) | (si03 == 2 & si14 == 2) | (si03 == 2 & si05 == 2) 
| (si04 == 2 & si14 == 2) | (si04 == 2 & si13 == 2) 
| (si13 == 2 & si15 == 2) ;
replace riskpref7 = 3 if (si04 == 2 & si13 == 2 & si15 == 2) | (si03 == 2 & si13 == 2 & si15 == 2) 
| (si03 == 2 & si05 == 2 & si13 == 2) | (si03 == 2 & si05 == 2 & si14 == 2) ;
replace riskpref7 = 4 if (si03 == 2 & si05 == 2 & si13 == 2 & si15 == 2) ;
keep hhid07 pidlink timepref7 riskpref7 ;
save 4_timepref.dta, replace ;

*** MERGE SPECIFIC & COMMON CONTROL VAR IFLS4 ;
use 4_ar1, clear ;
merge 1:1 hhid07 pidlink using 4_timepref ; keep if _m == 3 ; drop _m ;
merge m:1 hhid07 using 4_scks2hr1 ; keep if _m == 3 ; drop _m ;
merge m:1 hhid07 using expenditure_per_capita\OUT\1306_hhchar07 ; keep if _m == 3 ; drop _m ;
rename expm expen7 ; rename expmjt expenjt7 ;
save 4_ar1_m, replace ;


*********** IFLS5 | Merge dataset yang nantinya untuk generate variabel kontrol ;
use ifls_5\bk_ar1, clear ; save 5_ar1, replace ;
use ifls_5\bk_sc1, clear ; save 5_sc, replace ;
use ifls_5\b1_ks2, clear ; keep if ks2type == "E" ; save 5_ks2, replace ;
use ifls_5\b2_hr1, clear ; keep if hrtype == "E" ; save 5_hr1, replace;
use 5_sc, clear ;
merge m:m hhid14 using 5_ks2 ; keep if _m==3 ; drop _m ;
merge m:m hhid14 using 5_hr1 ; keep if _m==3 ; drop _m ;

** SPECIFIC CONTROL VARIABLES ;
** RURAL/URBAN ;
gen urban14 = sc05 ; replace urban14 = 0 if urban14 == 2 ;
** Vehicle assets ;
drop if hr11 == 99 ;
gen vehicle14 = hr11 ; replace vehicle14 = 0 if vehicle14 == . ;
** transportation expenses ;
gen transport14 = ks06 ;
drop if transport14 == . ;
** keep variable untuk mempermudah merge nantinya ;
drop if hhid14_9 == "." ;
keep hhid14_9 urban14 vehicle14 transport14 ;
save 5_scks2hr1, replace ;

** COMMON CONTROL VARIABLES ;
use 5_ar1, clear ;
** INCOME PER CAPITA (0);
** HH SIZE (1);
keep if (ar01a == 1 | ar01a == 2 | ar01a == 5 | ar01a == 11) ;
gen hitungs = 1 ;
egen hhsize14 = sum(hitungs), by (hhid14_9) ;
drop if ar15bx == 8 | ar15bx == 9 ;
replace ar15b = 0 if ar15bx == 6 ;
egen inco_all = sum(ar15b), by (hhid14_9) ;
gen incpercap14 = inco_all / hhsize14 ;
replace incpercap14 = . if ar15bx == . ;
** AGE (0);
**drop if ar09 > 94 & ar09 < 1000 ;
drop if ar09 == 998 | ar09 == 999 ;
gen age14 = ar09 ;
** GENDER (GA PERLU KARENA UDAH DI ANALISIS DI IFLS4) ;
** MARRIED STATUS ;
drop if ar13 == 8 | ar13 == 9 ;
gen married14 = 0 ;
replace married14 = 1 if ar13 == 2 ;
** EDUCATION ;
drop if (ar16 == 14 & ar17 == 98) | (ar16 == 17 & ar17 == 98) | ar16 == 95 | ar16 == 98 | ar16 == 99 ;
gen noschool14 = 0 ;
gen sd14 = 0 ;
gen smp14 = 0 ;
gen smak14 = 0 ;
gen univ14 = 0 ;
replace noschool14 = 1 if ar16 == 1 | ar16 == 90 | (ar16 == 14 & ar17 != 7) | (ar16 == 17 & ar17 != 7) ;
replace sd14 = 1 if ar16 == 2 | ar16 == 11 | ar16 == 72 | (ar16 == 14 & ar17 == 7) | (ar16 == 17 & ar17 == 7) ;
replace smp14 = 1 if ar16 == 3 | ar16 == 4 | ar16 == 12 | ar16 == 73 ;
replace smak14 = 1 if ar16 == 5 | ar16 == 6 | ar16 == 15 | ar16 == 74 ;
replace univ14 = 1 if ar16 == 13 | ar16 == 60 | ar16 == 61 | ar16 == 62 | ar16 == 63 ;
** EMPLOYMENT STATUS ;
drop if ar15a == 8 | ar15a == 9 ;
gen labor14 = 0 ;
replace labor14 = 1 if ar15a == 1 ;
** keep variable untuk mempermudah merge nantinya ;
drop if pidlink == "." ;
keep pidlink hhid14_9 hhsize14 incpercap14 age14 married14 noschool14 sd14 smp14 smak14 univ14 labor14 ;
save 5_ar1, replace ;

** TIMEPREF DAN RISKPREF IFLS5 ;
use ifls_5\b3a_si.dta, clear ;
drop if si21a == 9 | si21b == 9 | si21c == 9 | si21d == 9 | si21e == 9 ;
drop if si21a == 2 & si21e == 1 ;
gen timepref14 = 1 ;
replace timepref14 = 2 if (si21a == 1 & si21b == 2 & si21d == 2) | (si21a == 2 & si21e == 3 & si21b == 2 & si21d == 2) ;
replace timepref14 = 3 if (si21a == 1 & si21b == 2 & si21d == 1) | (si21a == 2 & si21e == 3 & si21b == 2 & si21d == 1) ;
replace timepref14 = 4 if (si21a == 1 & si21b == 1 & si21c == 2) | (si21a == 2 & si21e == 3 & si21b == 1 & si21c == 2) ;
replace timepref14 = 5 if (si21a == 1 & si21b == 1 & si21c == 1) | (si21a == 2 & si21e == 3 & si21b == 1 & si21c == 1) ;
replace timepref14 = . if si21e == 9 ;
drop if timepref14 == . ;

gen riskpref14 = 0 ;
replace riskpref14 = 1 if si03 == 2 | si04 == 2 | si13 == 2 | si14 == 2 ;
replace riskpref14 = 2 if (si03 == 2 & si13 == 2) | (si03 == 2 & si14 == 2) | (si03 == 2 & si05 == 2) 
| (si04 == 2 & si14 == 2) | (si04 == 2 & si13 == 2) 
| (si13 == 2 & si15 == 2) ;
replace riskpref14 = 3 if (si04 == 2 & si13 == 2 & si15 == 2) | (si03 == 2 & si13 == 2 & si15 == 2) 
| (si03 == 2 & si05 == 2 & si13 == 2) | (si03 == 2 & si05 == 2 & si14 == 2) ;
replace riskpref14 = 4 if (si03 == 2 & si05 == 2 & si13 == 2 & si15 == 2) ;
keep hhid14_9 pidlink timepref14 riskpref14 ;
save 5_timepref.dta, replace ;

*** MERGE SPECIFIC & COMMON CONTROL VAR IFLS5 ;
use 5_ar1, clear ;
merge 1:1 pidlink hhid14_9 using 5_timepref ; keep if _m == 3 ; drop _m ;
merge m:1 hhid14_9 using 5_scks2hr1 ; keep if _m == 3 ; drop _m ;
merge m:1 hhid14_9 using expenditure_per_capita\OUT\1306_hhchar14 ; keep if _m == 3 ; drop _m ;
rename expm expen14 ; rename expmjt expenjt14 ;
save 5_ar1_m, replace ;

*** MERGE IFLS4 & IFLS5 ;
merge m:m pidlink using 4_ar1_m ; keep if _m == 3 ; drop _m ;
save control45.dta, replace ;

*************************************** MERGE SELURUH DATASET (ASURANSI, HEALTH BEHAVIOR, CONTROL VAR)******************************************  ;

merge 1:1 pidlink hhid07 hhid14_9 using riskbhvr45.dta ; keep if _m == 3 ; drop _m ;
merge 1:1 pidlink hhid07 hhid14_9 using asuransi45.dta ; keep if _m == 3 ; drop _m ;
save walk_control45, replace ;




***BAGIAN CLEANING DATA (SELURUH VARIABEL PENELITIAN SUDAH TERSEDIA DI DATASET) ;

************************* cleaning variable yang tak digunakan di dataset utama ;
use walk_control45, clear ;

drop version module ak01 ak02A ak03xA ak03A ak04A ak05A ak02B ak03xB ak03B ak04B ak05B 
ak02C ak03xC ak03C ak04C ak05C ak02D ak03xD ak03D ak04D ak05D ak02E ak03xE ak03E 
ak04E ak05E ak02G ak03xG ak03G ak04G ak05G ak02H ak03xH ak03H ak04H ak05H ak02I 
ak03xI ak03I ak04I ak05I ak02J ak03xJ ak03J ak04J ak05J ak02K ak03xK ak03K ak04K 
ak05K ak02L ak03xL ak03L ak04L ak05L ak02X ak03xX ak03X ak04X ak05X ;

** drop jika observasi memiliki asuransi sosial (JKN) dan swasta ;
drop if (Jenis_Asuransi14 == "Mixed" | Jenis_Asuransi7 == "Mixed") ;
** real price ;
replace km0914 = km0914/1.67 ;
replace expen14 = expen14/1.55 ;
replace expenjt14 = expenjt14/1.55 ;
replace transport14 = transport14/1.43 ;

** save data awal dalam wide ;
save data_final\full_control45_wide, replace ;

** reshape dari wide menjadi long ;
gen individu = _n ;
reshape long dumjln jlnfreq km08 km09 hhsize incpercap age noschool sd smp smak univ married labor urban vehicle transport jlncat1 jlncat2 
 Jenis_Asuransi timepref riskpref us06 us04 us06a dumrokok fm03A fm03B fm03C fm03D fm03E fm03F fm03G fm03H fm03I 
fm03J fm03K fm03L fm03M fm03N fm03O fm03Q fm03P expen expenjt, i(individu) j(year) ;
replace year = 2014 if year == 14 ; replace year = 2007 if year == 7 ;
replace dumjln = 0 if dumjln== 3 ; 
gen asuransi = 0 ;
replace asuransi = 1 if Jenis_Asuransi == "JKN" ;
gen kategori_jalan = 0 if jlncat2 == . ;
replace kategori_jalan = 1 if jlncat2 == 11 ; replace kategori_jalan = 2 if jlncat2 == 12 | jlncat2 == 21 ;
replace kategori_jalan = 3 if jlncat2 == 22 ;

** melengkapi data yang formatnya kurang tepat ;
replace jlnfreq = 0 if jlnfreq == . ;
replace jlncat1 = 0 if jlncat1 == . ;
gen bmi = us06/((us04/100)^2) ;
gen dum_bmi = 0 ;
replace dum_bmi = 1 if bmi >= 25 ;

rename km08 konsrokok ;
rename km09 spendrokok ;
gen spendrokokribu = spendrokok/1000 ;
gen incpercapjt = incpercap/1000000 ;
gen transportjt = transport/1000000 ;

gen dumrisk = 0 ;
gen dumtime = 0 ;
** 1 jika individu merupakan present oriented (very impatient) ;
replace dumtime = 1 if timepref == 5 ;
** 1 jika individu merupakan very risk averse ;
replace dumrisk = 1 if riskpref == 0 ;
replace expen = expen/hhsize ;
replace expenjt = expenjt/hhsize ;

order individu year dumjln jlnfreq konsrokok spendrokokribu asuransi dumtime dumrisk expenjt 
age hhsize noschool sd smp smak univ married gender labor urban vehicle ;

recode dumjln (1=0) (0=1) ;
gen intensity = 1 if jlncat2 == 11 ;
replace intensity = 0 if intensity == . ;
replace intensity = . if dumjln == 1 ;

save data_final\full_control45_long, replace ;

***************************************************** ANALISIS DATA LONG (REGRESSION) *************************************************** ;

use data_final\full_control45_long, clear ;
xtset individu year ;
replace vehicle = 1 if vehicle >= 1 ;

************************************** REGRESI UTAMA LENGKAP (UNTUK HALAMAN ANALISIS DAN PEMBAHASAN)************************************* ;


********* dumjln & jlnfreq ;

** probabilitas jalan kaki (dummy jalan)
xtprobit dumjln asuransi, vce(robust) ;
outreg2 using regresi_dumjln, replace excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk, vce(robust) ;
outreg2 using regresi_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , vce(robust) ;
outreg2 using regresi_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;

**UNTUK ESTIMASI Marginal Effect Dummy Jalan (dum_jln) ;
quietly xtprobit dumjln asuransi, vce(robust) ;
margins, dydx(*) post ;
outreg2 using marginal_coba.xml, replace dec(3) ;
quietly xtprobit dumjln asuransi vehicle dumtime dumrisk, vce(robust) ;
margins, dydx(*) post ;
outreg2 using marginal_coba.xml, append dec(3) ;
quietly xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , vce(robust) ;
margins, dydx(*) post ;
outreg2 using marginal_coba.xml, append dec(3) ;


** frekuensi jalan
xtoprobit jlnfreq asuransi, vce(robust) ;
outreg2 using regresi_jlnfreq, replace excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk, vce(robust) ;
outreg2 using regresi_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , vce(robust) ;
outreg2 using regresi_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;




************ konsumsi dan spending rokok ;

** Pengujian antara PLS/FEM/REM untuk Variable Dependen Konsumsi Rokok (REgresi Linear) ;
xtreg konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , fe ;
estimates store fixed ;
xtreg konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , re ;
estimates store random ;
hausman fixed random ;
** Pengujian antara PLS/FEM/REM untuk Variable Dependen Konsumsi Rokok (Negative Binomial) ;
xtnbreg konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , fe ;
estimates store fixed ;
xtnbreg konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , re ;
estimates store random ;
hausman fixed random ;
** Pengujian antara PLS/FEM/REM untuk Variable Dependen Pengeluaran Rokok / Hari ;
xtreg spendrokokribu asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban, fe ;
estimates store fixed ;
xtreg spendrokokribu asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban, re ;
estimates store random ;
hausman fixed random ; 


** Regresi Variable Konsumsi Rokok ; 
** Fixed Effect ;
xtreg konsrokok asuransi , fe vce(robust) ;
outreg2 using regresi_konsrokok_fem, replace excel dec(3) pdec(3) e(F r2) ctitle(Smoke (Cigarette per day)) noni ;
xtreg konsrokok asuransi dumtime dumrisk , fe vce(robust) ;
outreg2 using regresi_konsrokok_fem, append excel dec(3) pdec(3) e(F r2) ctitle(Smoke (Cigarette per day)) noni ;
xtreg konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , fe vce(robust) ;
outreg2 using regresi_konsrokok_fem, append excel dec(3) pdec(3) e(F r2) ctitle(Smoke (Cigarette per day)) noni ;
** Fixed Effect Negative Binomial ;
xtnbreg konsrokok asuransi , fe ;
outreg2 using regresi_konsrokok_nbreg, replace excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Cigarette per day)) noni ;
xtnbreg konsrokok asuransi dumtime dumrisk , fe ;
outreg2 using regresi_konsrokok_nbreg, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Cigarette per day)) noni ;
xtnbreg konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , fe ;
outreg2 using regresi_konsrokok_nbreg, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Cigarette per day)) noni ;
** Tobit Model ;
xttobit konsrokok asuransi , ll(0) ;
outreg2 using regresi_konsrokok_tobit, replace excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk , ll(0) ;
outreg2 using regresi_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , ll(0) ;
outreg2 using regresi_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;

** Regresi Variable Pengeluaran Rokok ; 
** Fixed Effect ;
xtreg spendrokokribu asuransi , fe vce(robust) ;
outreg2 using regresi_spendrokok_fem, replace excel dec(3) pdec(3) e(F r2) ctitle(Smoke (Spending per week)) noni ;
xtreg spendrokokribu asuransi dumtime dumrisk , fe vce(robust) ;
outreg2 using regresi_spendrokok_fem, append excel dec(3) pdec(3) e(F r2) ctitle(Smoke (Spending per week)) noni ;
xtreg spendrokokribu asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , fe vce(robust) ;
outreg2 using regresi_spendrokok_fem, append excel dec(3) pdec(3) e(F r2) ctitle(Smoke (Spending per week)) noni ;
** Tobit Model ;
xttobit spendrokokribu asuransi , ll(0) ;
outreg2 using regresi_spendrokok_tobit, replace excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk , ll(0) ;
outreg2 using regresi_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , ll(0) ;
outreg2 using regresi_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;


**************************************************** REGRESI UTAMA LENGKAP (UNTUK HALAMAN LAMPIRAN)************************************* ;

** ini nanti estimasi detail untuk 4 model utama pada lampiran, dummy fisik probit, ordered probit fisik, tobit spending, tobit konsumsi ;
** dumjln ;
xtprobit dumjln asuransi, vce(robust) ;
outreg2 using full_dumjln, replace excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt age , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt age hhsize , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married gender , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;
xtprobit dumjln asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , vce(robust) ;
outreg2 using full_dumjln, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (dummy)) noni ;

** jlnfreq ;
xtoprobit jlnfreq asuransi, vce(robust) ;
outreg2 using full_jlnfreq, replace excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk expenjt , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk expenjt age , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk expenjt age hhsize , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married gender , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;
xtoprobit jlnfreq asuransi vehicle dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , vce(robust) ;
outreg2 using full_jlnfreq, append excel dec(3) pdec(3) e(chi2 ) ctitle(Physical activity (Frequency)) noni ;

** konsrokok ;
xttobit konsrokok asuransi , ll(0) ;
outreg2 using full_konsrokok_tobit, replace excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk expenjt , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk expenjt age , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk expenjt age hhsize , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married  , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender  , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;
xttobit konsrokok asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , ll(0) ;
outreg2 using full_konsrokok_tobit, append excel dec(3) pdec(3) e(chi2 ) ctitle(Smoke (Cigarette per day)) noni ;

** spendrokokribu ;
xttobit spendrokokribu asuransi , ll(0) ;
outreg2 using full_spendrokok_tobit, replace excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk expenjt , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk expenjt age , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk expenjt age hhsize , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;
xttobit spendrokokribu asuransi dumtime dumrisk expenjt age hhsize sd smp smak univ married gender labor urban , ll(0) ;
outreg2 using full_spendrokok_tobit, append excel dec(3) pdec(3) e(chi2 r2) ctitle(Smoke (Spending per week)) noni ;


 
log close ;

