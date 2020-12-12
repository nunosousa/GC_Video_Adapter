EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Device:C C?
U 1 1 5F7750A2
P 2450 6100
AR Path="/5F739D99/5F7750A2" Ref="C?"  Part="1" 
AR Path="/5F9522C1/5F7750A2" Ref="C?"  Part="1" 
AR Path="/5F73A390/5F7750A2" Ref="C47"  Part="1" 
F 0 "C47" H 2565 6146 50  0000 L CNN
F 1 "1uC" H 2565 6055 50  0000 L CNN
F 2 "" H 2488 5950 50  0001 C CNN
F 3 "~" H 2450 6100 50  0001 C CNN
F 4 "tbd" H 2450 6100 50  0001 C CNN "Manufacturer Part Number"
	1    2450 6100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5F7750A9
P 2900 6100
AR Path="/5F739D99/5F7750A9" Ref="C?"  Part="1" 
AR Path="/5F9522C1/5F7750A9" Ref="C?"  Part="1" 
AR Path="/5F73A390/5F7750A9" Ref="C48"  Part="1" 
F 0 "C48" H 3015 6146 50  0000 L CNN
F 1 "0.1uC" H 3015 6055 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 2938 5950 50  0001 C CNN
F 3 "~" H 2900 6100 50  0001 C CNN
F 4 "tbd" H 2900 6100 50  0001 C CNN "Manufacturer Part Number"
	1    2900 6100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5F7750AF
P 2450 6250
AR Path="/5F739D99/5F7750AF" Ref="#PWR?"  Part="1" 
AR Path="/5F9522C1/5F7750AF" Ref="#PWR?"  Part="1" 
AR Path="/5F73A390/5F7750AF" Ref="#PWR057"  Part="1" 
F 0 "#PWR057" H 2450 6000 50  0001 C CNN
F 1 "GND" H 2455 6077 50  0000 C CNN
F 2 "" H 2450 6250 50  0001 C CNN
F 3 "" H 2450 6250 50  0001 C CNN
	1    2450 6250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5F7750B5
P 2900 6250
AR Path="/5F739D99/5F7750B5" Ref="#PWR?"  Part="1" 
AR Path="/5F9522C1/5F7750B5" Ref="#PWR?"  Part="1" 
AR Path="/5F73A390/5F7750B5" Ref="#PWR058"  Part="1" 
F 0 "#PWR058" H 2900 6000 50  0001 C CNN
F 1 "GND" H 2905 6077 50  0000 C CNN
F 2 "" H 2900 6250 50  0001 C CNN
F 3 "" H 2900 6250 50  0001 C CNN
	1    2900 6250
	1    0    0    -1  
$EndComp
Wire Wire Line
	2900 5950 2900 5900
Wire Wire Line
	2900 5900 2450 5900
Wire Wire Line
	2450 5900 2450 5950
Wire Wire Line
	2450 5900 2000 5900
Wire Wire Line
	2000 5900 2000 5950
Connection ~ 2450 5900
$Comp
L power:GND #PWR?
U 1 1 5F7750C8
P 2000 6250
AR Path="/5F739D99/5F7750C8" Ref="#PWR?"  Part="1" 
AR Path="/5F9522C1/5F7750C8" Ref="#PWR?"  Part="1" 
AR Path="/5F73A390/5F7750C8" Ref="#PWR056"  Part="1" 
F 0 "#PWR056" H 2000 6000 50  0001 C CNN
F 1 "GND" H 2005 6077 50  0000 C CNN
F 2 "" H 2000 6250 50  0001 C CNN
F 3 "" H 2000 6250 50  0001 C CNN
	1    2000 6250
	1    0    0    -1  
$EndComp
$Comp
L Device:Ferrite_Bead FB?
U 1 1 5F7750CF
P 3450 5900
AR Path="/5F739D99/5F7750CF" Ref="FB?"  Part="1" 
AR Path="/5F9522C1/5F7750CF" Ref="FB?"  Part="1" 
AR Path="/5F73A390/5F7750CF" Ref="FB1"  Part="1" 
F 0 "FB1" V 3176 5900 50  0000 C CNN
F 1 "Ferrite_Bead" V 3267 5900 50  0000 C CNN
F 2 "Inductor_SMD:L_0805_2012Metric_Pad1.15x1.40mm_HandSolder" V 3380 5900 50  0001 C CNN
F 3 "~" H 3450 5900 50  0001 C CNN
F 4 "tbd" H 3450 5900 50  0001 C CNN "Manufacturer Part Number"
	1    3450 5900
	0    1    1    0   
$EndComp
Wire Wire Line
	3300 5900 2900 5900
Connection ~ 2900 5900
Text HLabel 1400 5900 0    50   Input ~ 0
+3.3V
Connection ~ 2000 5900
Wire Wire Line
	3650 5900 3600 5900
Text Label 3650 5900 0    50   ~ 0
+3.3V_DEC
$Comp
L Device:CP C?
U 1 1 5F7750DC
P 1450 6100
AR Path="/5F7750DC" Ref="C?"  Part="1" 
AR Path="/5F9522C1/5F7750DC" Ref="C?"  Part="1" 
AR Path="/5F739D99/5F7750DC" Ref="C?"  Part="1" 
AR Path="/5F73A390/5F7750DC" Ref="C45"  Part="1" 
F 0 "C45" H 1568 6146 50  0000 L CNN
F 1 "100uCP" H 1568 6055 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.00mm" H 1488 5950 50  0001 C CNN
F 3 "http://www.rubycon.co.jp/en/catalog/e_pdfs/aluminum/e_zlh.pdf" H 1450 6100 50  0001 C CNN
F 4 "16ZLH100MEFC5X11" H 1450 6100 50  0001 C CNN "Manufacturer Part Number"
	1    1450 6100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5F7750E2
P 1450 6250
AR Path="/5F7750E2" Ref="#PWR?"  Part="1" 
AR Path="/5F9522C1/5F7750E2" Ref="#PWR?"  Part="1" 
AR Path="/5F739D99/5F7750E2" Ref="#PWR?"  Part="1" 
AR Path="/5F73A390/5F7750E2" Ref="#PWR055"  Part="1" 
F 0 "#PWR055" H 1450 6000 50  0001 C CNN
F 1 "GND" H 1455 6077 50  0000 C CNN
F 2 "" H 1450 6250 50  0001 C CNN
F 3 "" H 1450 6250 50  0001 C CNN
	1    1450 6250
	1    0    0    -1  
$EndComp
Wire Wire Line
	1400 5900 1450 5900
Wire Wire Line
	1450 5950 1450 5900
Connection ~ 1450 5900
Wire Wire Line
	1450 5900 2000 5900
$Comp
L Device:CP C35
U 1 1 5F775948
P 2000 6100
F 0 "C35" H 2118 6146 50  0000 L CNN
F 1 "10uCP" H 2118 6055 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D4.0mm_P1.50mm" H 2038 5950 50  0001 C CNN
F 3 "https://www.nichicon.co.jp/english/products/pdfs/e-usa_usr.pdf" H 2000 6100 50  0001 C CNN
F 4 "USA1C100MDD1TP" H 2000 6100 50  0001 C CNN "Manufacturer Part Number"
	1    2000 6100
	1    0    0    -1  
$EndComp
$EndSCHEMATC
