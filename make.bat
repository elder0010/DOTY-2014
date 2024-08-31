@echo OFF
set KICKASS_PATH="bin\Kickass.jar"
del doty.prg
call java -jar %KICKASS_PATH% src\doty.asm -o doty_c.prg
cd bin
pucrunch.exe ..\doty_c.prg ..\doty.prg -x49152
cd..
del doty_dirstyle.d64
del doty.d64
del doty_c.prg
cd src\data
copy doty_dirstyle.d64 ..\..\
cd..
cd..
cd bin
c1541.exe -attach ..\doty_dirstyle.d64 8 -write ..\doty.prg doty
cd..
del doty.prg
rename doty_dirstyle.d64 doty.d64
