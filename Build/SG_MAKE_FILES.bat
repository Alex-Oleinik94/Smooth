cd SrcUnits
MKDIR Temp
cd Temp
rm -f *
cd ..
cd ..
"./../Binaries/Main" -crf ../build/srcunits/temp/SaGeRMFiles.inc
"./../Binaries/Main" -CFTPUARU ../data/fonts/Tahoma.sgf ../build/srcunits/temp tahoma_font ../build/srcunits/temp/SaGeRMFiles.inc
"./../Binaries/Main" -CFTPUARU "../data/fonts/Times New Roman.sgf" ../build/srcunits/temp times_new_roman_font ../build/srcunits/temp/SaGeRMFiles.inc
"./../Binaries/Main" -CFTPUARU ../data/textures/ComboBoxImage.sgia ../build/srcunits/temp combo_box_image ../build/srcunits/temp/SaGeRMFiles.inc
"./../Binaries/Main" -CFTPUARU ../data/textures/KillKostia/Block.sgia ../build/srcunits/temp KillKostia_Block ../build/srcunits/temp/SaGeRMFiles.inc
"./../Binaries/Main" -CFTPUARU ../data/textures/KillKostia/Bullet.sgia ../build/srcunits/temp KillKostia_Bullet ../build/srcunits/temp/SaGeRMFiles.inc
"./../Binaries/Main" -CFTPUARU ../data/textures/KillKostia/Skull.sgia ../build/srcunits/temp KillKostia_Skull ../build/srcunits/temp/SaGeRMFiles.inc
"./../Binaries/Main" -CFTPUARU "../data/textures/KillKostia/Standart Kostia.sgia" ../build/srcunits/temp KillKostia_sk ../build/srcunits/temp/SaGeRMFiles.inc
"./../Binaries/Main" -CFTPUARU ../data/textures/KillKostia/You.sgia ../build/srcunits/temp KillKostia_You ../build/srcunits/temp/SaGeRMFiles.inc
