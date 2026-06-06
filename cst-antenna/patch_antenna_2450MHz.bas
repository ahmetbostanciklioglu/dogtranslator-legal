' =====================================================================
'  CST Studio Suite 2025 - VBA Makrosu
'  2.45 GHz Inset-Fed (Girintili Beslemeli) Mikroserit Yama Anten
'
'  Yazar  : (CST History List uyumlu otomatik kurulum makrosu)
'  Cozucu : Time Domain (Transient) - Hexahedral mesh
'  Altlik : FR-4 (er=4.4, h=1.6 mm, tand=0.02)
'  Iletken: Bakir (annealed, sigma=5.8e7 S/m, t=0.035 mm)
'  Besleme: 50 Ohm mikroserit hat + inset (girintili) gecis
'
'  KULLANIM:
'   1) CST Studio Suite 2025 -> Yeni "Microwave & RF / Antenna"
'      projesi acin (veya bos bir 3D proje).
'   2) Home sekmesi -> Macros -> Edit/Open Macros... (veya Alt+F11)
'   3) Bu dosyanin tamamini kopyalayip yapistirin VE "Run" deyin.
'      (Alternatif: Macros -> Run Macro -> bu .bas dosyasini secin)
'   4) Makro biter bitmez geometri, port, sinir kosullari, frekans
'      araligi ve uzak alan (farfield) monitorleri otomatik kurulur.
'   5) "Start Simulation" ile cozumu calistirin.
'
'  TUM OLCULER PARAMETRIKTIR -> Parametre tablosundan degistirip
'  Parameter Sweep / Optimizer ile akort edebilirsiniz.
' =====================================================================

Option Explicit

Sub Main ()

    ' ---------------------------------------------------------------
    ' 0) Birimler
    ' ---------------------------------------------------------------
    With Units
        .Geometry "mm"
        .Frequency "GHz"
        .Time "ns"
        .TemperatureUnit "Kelvin"
        .Voltage "V"
        .Current "A"
        .Resistance "Ohm"
        .Conductance "Siemens"
        .Capacitance "pF"
        .Inductance "nH"
    End With

    ' ---------------------------------------------------------------
    ' 1) Tasarim Parametreleri (analitik baslangic degerleri)
    '    Kaynak: Balanis, "Antenna Theory", mikroserit yama denklemleri
    ' ---------------------------------------------------------------
    ' --- Calisma frekansi ve malzeme ---
    StoreDoubleParameter "f0",    2.45     ' [GHz] merkez frekans (WLAN / ISM)
    StoreDoubleParameter "eps_r", 4.4      ' altlik bagil dielektrik sabiti
    StoreDoubleParameter "tand",  0.02     ' altlik kayip tanjanti
    StoreDoubleParameter "h_sub", 1.6      ' [mm] altlik kalinligi
    StoreDoubleParameter "t_met", 0.035    ' [mm] bakir kalinligi (35 um)

    ' --- Yama boyutlari (W, L) ---
    StoreParameter "W_patch", "37.234"     ' [mm] yama genisligi
    StoreParameter "L_patch", "28.809"     ' [mm] yama uzunlugu (rezonans)

    ' --- 50 Ohm besleme hatti ---
    StoreParameter "W_feed",  "3.083"      ' [mm] 50 Ohm hat genisligi
    StoreParameter "y_inset", "9.935"      ' [mm] inset (girinti) derinligi
    StoreParameter "g_inset", "1.0"        ' [mm] inset bosluk genisligi
    StoreParameter "L_feed",  "12.0"       ' [mm] besleme hattinin dis uzunlugu

    ' --- Altlik / toprak boyutu (kenar pay = 6*h) ---
    StoreParameter "marg",  "6*h_sub"               ' kenar payi
    StoreParameter "W_sub", "W_patch + marg"        ' altlik genisligi (x)
    StoreParameter "L_sub", "L_patch + L_feed + marg" ' altlik uzunlugu (y)

    ' --- Dalga kilavuzu portu boyutu (mikrosrt icin onerilen) ---
    StoreParameter "port_w", "W_feed + 6*h_sub"     ' port yanal genisligi
    StoreParameter "port_h", "h_sub + 6*h_sub"      ' port yuksekligi (toprak->ust)

    ' ---------------------------------------------------------------
    ' 2) Calisma frekans araligi
    ' ---------------------------------------------------------------
    Solver.FrequencyRange "2.0", "3.0"

    ' ---------------------------------------------------------------
    ' 3) Arka plan + Acik sinir kosullari (radyasyon icin)
    ' ---------------------------------------------------------------
    With Background
        .Type "Normal"
        .Epsilon "1.0"
        .Mu "1.0"
        .XminSpace "0.0"
        .XmaxSpace "0.0"
        .YminSpace "0.0"
        .YmaxSpace "0.0"
        .ZminSpace "0.0"
        .ZmaxSpace "0.0"
    End With

    With Boundary
        .Xmin "expanded open"
        .Xmax "expanded open"
        .Ymin "expanded open"
        .Ymax "expanded open"
        .Zmin "expanded open"
        .Zmax "expanded open"
        .Xsymmetry "none"
        .Ysymmetry "none"
        .Zsymmetry "none"
        .ApplyInAllDirections "False"
    End With

    ' ---------------------------------------------------------------
    ' 4) Malzemeler
    ' ---------------------------------------------------------------
    ' --- FR-4 altlik (kayipli dielektrik) ---
    With Material
        .Reset
        .Name "FR4_substrate"
        .Folder ""
        .Type "Normal"
        .SetMaterialUnit "GHz", "mm"
        .Epsilon "eps_r"
        .Mu "1.0"
        .Sigma "0.0"
        .TanD "tand"
        .TanDFreq "f0"
        .TanDGiven "True"
        .TanDModel "ConstTanD"
        .SetConstTanDStrategyEps "AutomaticOrder"
        .SetConstTanDModelOrderEps "3"
        .DispModelEps "None"
        .Rho "1900.0"
        .ThermalType "Normal"
        .ThermalConductivity "0.3"
        .Colour "0.85", "0.78", "0.55"
        .Transparency "30"
        .Create
    End With

    ' --- Bakir (kayipli metal) ---
    With Material
        .Reset
        .Name "Copper_ann"
        .Folder ""
        .Type "Lossy metal"
        .SetMaterialUnit "GHz", "mm"
        .Mu "1.0"
        .Sigma "5.8e7"
        .Rho "8930.0"
        .ThermalType "Normal"
        .ThermalConductivity "401.0"
        .Colour "0.85", "0.55", "0.3"
        .Transparency "0"
        .Create
    End With

    ' ---------------------------------------------------------------
    ' 5) Altlik (Substrate) -> z: 0 .. h_sub
    ' ---------------------------------------------------------------
    With Brick
        .Reset
        .Name "Substrate"
        .Component "Antenna"
        .Material "FR4_substrate"
        .Xrange "-W_sub/2", "W_sub/2"
        .Yrange "-L_sub/2", "L_sub/2"
        .Zrange "0", "h_sub"
        .Create
    End With

    ' ---------------------------------------------------------------
    ' 6) Toprak duzlemi (Ground) -> altlik altinda, z: -t_met .. 0
    ' ---------------------------------------------------------------
    With Brick
        .Reset
        .Name "Ground"
        .Component "Antenna"
        .Material "Copper_ann"
        .Xrange "-W_sub/2", "W_sub/2"
        .Yrange "-L_sub/2", "L_sub/2"
        .Zrange "-t_met", "0"
        .Create
    End With

    ' ---------------------------------------------------------------
    ' 7) Isiyan yama (Patch) -> z: h_sub .. h_sub+t_met
    '    Yama merkezde, y ekseni boyunca; besleme -y kenarindan girer.
    ' ---------------------------------------------------------------
    With Brick
        .Reset
        .Name "Patch"
        .Component "Antenna"
        .Material "Copper_ann"
        .Xrange "-W_patch/2", "W_patch/2"
        .Yrange "-L_patch/2", "L_patch/2"
        .Zrange "h_sub", "h_sub+t_met"
        .Create
    End With

    ' ---------------------------------------------------------------
    ' 8) Inset (girinti) bosluklarini yamadan oy (2 adet U yarigi)
    ' ---------------------------------------------------------------
    ' Sag bosluk
    With Brick
        .Reset
        .Name "InsetR"
        .Component "Antenna"
        .Material "Copper_ann"
        .Xrange "W_feed/2", "W_feed/2 + g_inset"
        .Yrange "-L_patch/2", "-L_patch/2 + y_inset"
        .Zrange "h_sub", "h_sub+t_met"
        .Create
    End With
    Solid.Subtract "Antenna:Patch", "Antenna:InsetR"

    ' Sol bosluk
    With Brick
        .Reset
        .Name "InsetL"
        .Component "Antenna"
        .Material "Copper_ann"
        .Xrange "-W_feed/2 - g_inset", "-W_feed/2"
        .Yrange "-L_patch/2", "-L_patch/2 + y_inset"
        .Zrange "h_sub", "h_sub+t_met"
        .Create
    End With
    Solid.Subtract "Antenna:Patch", "Antenna:InsetL"

    ' ---------------------------------------------------------------
    ' 9) 50 Ohm besleme hatti -> inset tabanindan altlik kenarina
    ' ---------------------------------------------------------------
    With Brick
        .Reset
        .Name "Feed"
        .Component "Antenna"
        .Material "Copper_ann"
        .Xrange "-W_feed/2", "W_feed/2"
        .Yrange "-L_sub/2", "-L_patch/2 + y_inset"
        .Zrange "h_sub", "h_sub+t_met"
        .Create
    End With
    ' Besleme hatti + yamayi birlestir (tek iletken)
    Solid.Add "Antenna:Patch", "Antenna:Feed"

    ' ---------------------------------------------------------------
    ' 10) Dalga Kilavuzu Portu (Waveguide Port) -> hattin dis ucunda
    '     Altlik -y kenari duzleminde, mikrosrt icin onerilen boyutta
    ' ---------------------------------------------------------------
    With Port
        .Reset
        .PortNumber "1"
        .Label "Feed_Port"
        .Folder ""
        .NumberOfModes "1"
        .AdjustPolarization "False"
        .PolarizationAngle "0.0"
        .ReferencePlaneDistance "0"
        .TextSize "50"
        .TextMaxLimit "0"
        .Coordinates "Free"
        .Orientation "ymin"
        .PortOnBound "False"
        .ClipPickedPortToBound "False"
        .Xrange "-port_w/2", "port_w/2"
        .Yrange "-L_sub/2", "-L_sub/2"
        .Zrange "0", "port_h"
        .XrangeAdd "0.0", "0.0"
        .YrangeAdd "0.0", "0.0"
        .ZrangeAdd "0.0", "0.0"
        .SingleEnded "False"
        .Create
    End With

    ' ---------------------------------------------------------------
    ' 11) Alan monitorleri (uzak alan / kazanc / yuzey akimi)
    ' ---------------------------------------------------------------
    ' Merkez frekansta uzak alan (farfield) -> kazanc, yon diyagrami
    With Monitor
        .Reset
        .Name "farfield_f0"
        .Domain "Frequency"
        .FieldType "Farfield"
        .Frequency "f0"
        .ExportFarfieldSource "False"
        .Create
    End With

    ' Bant kenarlari icin ek uzak alan monitorleri
    With Monitor
        .Reset
        .Name "farfield_low"
        .Domain "Frequency"
        .FieldType "Farfield"
        .Frequency "2.3"
        .Create
    End With
    With Monitor
        .Reset
        .Name "farfield_high"
        .Domain "Frequency"
        .FieldType "Farfield"
        .Frequency "2.6"
        .Create
    End With

    ' Yuzey akimi (H-alan) -> akim dagilimini gormek icin
    With Monitor
        .Reset
        .Name "h_field_f0"
        .Domain "Frequency"
        .FieldType "Hfield"
        .Frequency "f0"
        .Create
    End With

    ' ---------------------------------------------------------------
    ' 12) Mesh (Hexahedral) ayarlari - dogruluk icin
    ' ---------------------------------------------------------------
    With Mesh
        .MeshType "PBA"
        .SetCreator "High Frequency"
    End With
    With MeshSettings
        .SetMeshType "Hex"
        .Set "Version", 1
        .Set "StepsPerWaveNear", "20"
        .Set "StepsPerWaveFar", "20"
        .Set "StepsPerBoxNear", "20"
        .Set "StepsPerBoxFar", "10"
        .Set "RatioLimitGeometry", "20"
    End With

    ' ---------------------------------------------------------------
    ' 13) Transient (Time Domain) cozucu ayarlari
    ' ---------------------------------------------------------------
    With Solver
        .Method "Hexahedral"
        .CalculationType "TD-S"
        .StimulationPort "All"
        .StimulationMode "All"
        .SteadyStateLimit "-40"
        .MeshAdaption "False"
        .NormalizeToReferenceSignal "True"
        .AutoNormImpedance "False"
        .NormingImpedance "50"
        .UseBroadBandPhaseShift "False"
        .SuperFineNormImpedance "True"
    End With

    ' ---------------------------------------------------------------
    ' 14) Goruntuyu sigdir
    ' ---------------------------------------------------------------
    Plot.ZoomToStructure

    MsgBox "2.45 GHz inset-fed mikrosrt yama anten kuruldu!" & vbCrLf & vbCrLf & _
           "Sonraki adim: Home -> Start Simulation" & vbCrLf & _
           "Sonuclar: 1D Results -> S-Parameters (S1,1)" & vbCrLf & _
           "          Farfields -> farfield_f0 (Gain/Directivity)", _
           vbInformation, "CST - Anten Tasarimi Hazir"

End Sub
