del *.lis *.rom *.map *.bin *.o *.sym
D:\z88dk\bin\zcc +msx -Cs -no-cleanup -v -m -g -s -subtype=rom -compiler=sdcc -SO3 --max-allocs-per-node10000 --reserve-regs-iy -create-app -pragma-define:CRT_MODEL=2 -o test.bin @zproject.lst --fsigned-char 
.\tools\FillFile.exe test_page0.bin 16384
copy /b test_page0.bin + /b test.rom /b test48Kb.rom
pause