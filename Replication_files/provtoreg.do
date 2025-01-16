gen regionplant=.
label variable regionplant "Region (CC.AA)"
replace regionplant=1  if provinceplant==4 | provinceplant==11 | provinceplant==14 | provinceplant==18 | provinceplant==21 | provinceplant==23 | provinceplant==29 | provinceplant==41
replace regionplant=2  if provinceplant==22 | provinceplant==44 | provinceplant==50
replace regionplant=3  if provinceplant==39
replace regionplant=4  if provinceplant==5 | provinceplant==9 | provinceplant==24 | provinceplant==34 | provinceplant==37 | provinceplant==40 | provinceplant==42 | provinceplant==47 | provinceplant==49
replace regionplant=5  if provinceplant==2 | provinceplant==13 | provinceplant==16 | provinceplant==19 | provinceplant==45
replace regionplant=6  if provinceplant==8 | provinceplant==17 | provinceplant==25 | provinceplant==43
replace regionplant=7  if provinceplant==28
replace regionplant=8  if provinceplant==3 | provinceplant==12 | provinceplant==46
replace regionplant=9  if provinceplant==6 | provinceplant==10
replace regionplant=10 if provinceplant==15 | provinceplant==27 | provinceplant==32 | provinceplant==36 
replace regionplant=11 if provinceplant==7
replace regionplant=12 if provinceplant==35 | provinceplant==38
replace regionplant=13 if provinceplant==26
replace regionplant=14 if provinceplant==31
replace regionplant=15 if provinceplant==1 | provinceplant==20 | provinceplant==48
replace regionplant=16 if provinceplant==33
replace regionplant=17 if provinceplant==30
replace regionplant=18 if provinceplant==51 | provinceplant==52
label define regionplantlb 1 "Andalusia"  2 "Aragon"  3 "Cantabria"  4 "Castile and Leon"  5 "Castile La-Mancha" 6 "Catalonia" 7 "Madrid"  8 "Valencia" 9 "Extremadura"  ///
						   10 "Galicia"  11 "Balearic Islands" 12 "Canary Islands" 13 "La Rioja" 14 "Navarre"  15 "Basque Country"  16 "Asturias" 17 "Murcia" 18 "Ceuta y Melilla", modify
label values regionplant regionplantlb
