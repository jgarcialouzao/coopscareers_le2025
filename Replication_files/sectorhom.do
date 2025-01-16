

*Create 2-digit sector of activity variable based on CNAE09  (76 categories)
gen sector2d=int(CNAE09/10)
*If CNAE09==0, use CNAE93 classification and its correspondence with CNAE09 to recover sector
replace sector2d=1  if CNAE09==0 & CNAE93 < 151
replace sector2d=10 if CNAE09==0 & CNAE93 >= 151 & CNAE93 < 159
replace sector2d=11 if CNAE09==0 & CNAE93==159
replace sector2d=12 if CNAE09==0 & CNAE93==160
replace sector2d=13 if CNAE09==0 & CNAE93 >= 171 & CNAE93 <= 176
replace sector2d=14 if CNAE09==0 & CNAE93 >= 177 & CNAE93 <= 182
replace sector2d=15 if CNAE09==0 & (CNAE93 == 183 | CNAE93 >= 191 & CNAE93<=193)
replace sector2d=16 if CNAE09==0 & CNAE93 >= 201 & CNAE93 <= 205
replace sector2d=17 if CNAE09==0 & CNAE93 >= 211 & CNAE93 <= 212
replace sector2d=18 if CNAE09==0 & CNAE93 >= 222 & CNAE93 <= 223
replace sector2d=19 if CNAE09==0 & CNAE93 >= 231 & CNAE93 <= 232  
replace sector2d=20 if CNAE09==0 & CNAE93 >= 241 & CNAE93 <= 247
replace sector2d=21 if CNAE09==0 & CNAE93 >= 233 & CNAE93 <= 240
replace sector2d=22 if CNAE09==0 & CNAE93 >= 251 & CNAE93 <= 252 
replace sector2d=23 if CNAE09==0 & CNAE93 >= 261 & CNAE93 <= 268
replace sector2d=24 if CNAE09==0 & CNAE93 >= 271 & CNAE93 <= 275
replace sector2d=25 if CNAE09==0 & CNAE93 >= 281 & CNAE93 <= 287 
replace sector2d=26 if CNAE09==0 & (CNAE93==300 | CNAE93 >= 311 & CNAE93 <= 313 | CNAE93>=321 & CNAE93<=323)
replace sector2d=27 if CNAE09==0 & CNAE93 >= 314 & CNAE93 <= 316 
replace sector2d=28 if CNAE09==0 & CNAE93 >= 291 & CNAE93 <= 297
replace sector2d=29 if CNAE09==0 & CNAE93 >= 341 & CNAE93 <= 343
replace sector2d=30 if CNAE09==0 & CNAE93 >= 351 & CNAE93 <= 355
replace sector2d=31 if CNAE09==0 & CNAE93==361
replace sector2d=32 if CNAE09==0 & (CNAE93>=331 &  CNAE93<=332) | CNAE93==334 | (CNAE93 >= 362 &  CNAE93 <= 366)
replace sector2d=33 if CNAE09==0 & (CNAE93==333 & CNAE93==335 |  CNAE93>=315 &  CNAE93<=316  | CNAE93==725)
replace sector2d=35 if CNAE09==0 & CNAE93 >= 401 &  CNAE93 <= 403
replace sector2d=36 if CNAE09==0 & CNAE93 == 410 
replace sector2d=37 if CNAE09==0 & CNAE93 == 900
replace sector2d=38 if CNAE09==0 & CNAE93 >= 371 &  CNAE93 <= 372 
replace sector2d=41 if CNAE09==0 & CNAE93==452
replace sector2d=42 if CNAE09==0 & CNAE93==451
replace sector2d=43 if CNAE09==0 & CNAE93>=453 &  CNAE93<=455
replace sector2d=45 if CNAE09==0 & CNAE93>=501 &  CNAE93<=504
replace sector2d=46 if CNAE09==0 & CNAE93 >= 511 &  CNAE93 <=517 
replace sector2d=47 if CNAE09==0 & (CNAE93==505 | (CNAE93 >=521 &  CNAE93<= 526))
replace sector2d=49 if CNAE09==0 & CNAE93 >= 601 &  CNAE93 <= 603
replace sector2d=50 if CNAE09==0 & CNAE93 >= 611 & CNAE93 <= 612
replace sector2d=51 if CNAE09==0 & CNAE93 >= 621 & CNAE93 <= 623
replace sector2d=52 if CNAE09==0 & CNAE93 >= 631 & CNAE93 <= 634
replace sector2d=53 if CNAE09==0 & CNAE93==641
replace sector2d=55 if CNAE09==0 & CNAE93 >= 551 & CNAE93 <= 552
replace sector2d=56 if CNAE09==0 & CNAE93 >= 553 & CNAE93 <= 555
replace sector2d=58 if CNAE09==0 & (CNAE93==221 | CNAE93 >= 722 & CNAE93 <= 724)
replace sector2d=59 if CNAE09==0 & CNAE93 >= 921 & CNAE93 <= 922
replace sector2d=60 if CNAE09==0 & CNAE93==724
replace sector2d=61 if CNAE09==0 & CNAE93==642
replace sector2d=62 if CNAE09==0 & (CNAE93==721 | CNAE93==726) 
replace sector2d=63 if CNAE09==0 &  CNAE93==748 | CNAE93==924
replace sector2d=64 if CNAE09==0 & CNAE93 >= 651 & CNAE93 <= 652
replace sector2d=65 if CNAE09==0 & CNAE93==660
replace sector2d=66 if CNAE09==0 & CNAE93 >= 671 & CNAE93<= 672
replace sector2d=68 if CNAE09==0 & CNAE93 >= 701 & CNAE93 <= 703
replace sector2d=69 if CNAE09==0 & CNAE93 ==741 
replace sector2d=71 if CNAE09==0 & CNAE93 >=742 & CNAE93<=743
replace sector2d=72 if CNAE09==0 & CNAE93 >= 731 & CNAE93 <= 732
replace sector2d=73 if CNAE09==0 & CNAE93 ==744
replace sector2d=74 if CNAE09==0 & CNAE93 >= 746 & CNAE93 <= 748
replace sector2d=75 if CNAE09==0 & CNAE93 ==852
replace sector2d=77 if CNAE09==0 & CNAE93 >= 711 & CNAE93 <= 714
replace sector2d=78 if CNAE09==0 & CNAE93 ==745
replace sector2d=79 if CNAE09==0 & (CNAE93 ==633  | CNAE93 == 746)
replace sector2d=81 if CNAE09==0 & CNAE93 ==747
replace sector2d=82 if CNAE09==0 & CNAE93 ==748
replace sector2d=84 if CNAE09==0 & CNAE93 ==753
replace sector2d=85 if CNAE09==0 & CNAE93 >= 801 & CNAE93 <= 804
replace sector2d=86 if CNAE09==0 & CNAE93 ==851
replace sector2d=87 if CNAE09==0 & CNAE93 ==853
replace sector2d=90 if CNAE09==0 & CNAE93 ==923
replace sector2d=91 if CNAE09==0 & CNAE93 ==925
replace sector2d=92 if CNAE09==0 & CNAE93 ==927
replace sector2d=93 if CNAE09==0 & CNAE93 ==926
replace sector2d=94 if CNAE09==0 & CNAE93 >= 911 & CNAE93 <= 913
replace sector2d=95 if CNAE09==0 & CNAE93 ==527 
replace sector2d=96 if CNAE09==0 & (CNAE93==930 | CNAE93 ==950)
replace sector2d=97 if CNAE09==0 & CNAE93==950
replace sector2d=99 if CNAE09==0 & CNAE93==990

*Create 1-digit sector 
gen sector1d=.
replace sector1d=1 if sector2d<10
replace sector1d=2 if sector2d>=10 & sector2d<=39
*replace sector1d=2 if sector2d>=35 & sector2d<=39
replace sector1d=3 if sector2d>=41 & sector2d<=43
replace sector1d=4 if sector2d>=45 & sector2d<=47
replace sector1d=5 if sector2d>=49 & sector2d<=53
replace sector1d=6 if sector2d>=55 & sector2d<=56
replace sector1d=7 if sector2d>=58 & sector2d<=63
replace sector1d=8 if sector2d>=64 & sector2d<=68
replace sector1d=9 if sector2d>=69 & sector2d<=75
replace sector1d=10 if (sector2d>=77 & sector2d<=82) | (sector2d>=95 & sector2d<=97)
replace sector1d=11 if sector2d>=85 & sector2d<=88
replace sector1d=12 if sector2d>=90 & sector2d<=94
replace sector1d=13 if sector2d==84
replace sector1d=14 if sector2d==99

label define sector1dlb  1 "Primary sector" 2 "Manufacturing" /*2 "Utilities"*/ 3 "Construction"  4 "Trade" 5 "Transportation and storage" 6 "Accommodation and food services" ///
						 7 "Information and communication"  8 "Financial, insurance and real estate activities"  9 "Professional, scientific and technical activities" ///
						 10 "Administrative, support and other services" 11 "Education, human health and social work" 12 "Entertainment" 13 "Social Security" 14 "Int. organizations", modify
label values sector1d sector1dlb

