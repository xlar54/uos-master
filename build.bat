del ".\target\*.bin"
del ".\target\*.prg"
del ".\target\*.d64"

cls
echo ===================================================
echo ===================================================
echo ===================================================

64tass -a ./src/uos.asm -o ./target/uos.prg -L uos.lst
64tass -a ./src/uos-gfx.asm -o ./target/uos-gfx.prg -L uos-gfx.lst
64tass -a ./src/uos-drv1351.asm -o ./target/uos-drv1351.prg -L uos-drv1351.lst
64tass -a ./src/uos-sprites.asm -o ./target/uos-sprites.prg -L uos-sprites.lst
64tass -a ./src/uos-reu.asm -o ./target/uos-reu.prg -L uos-reu.lst
64tass -a ./src/uos-desktop.asm -o ./target/uos-desktop.prg -L uos-desktop.lst



c1541 -format "uos,sh" d64 ./target/uos.d64
c1541 -attach ./target/uos.d64 -write ./target/uos.prg uos
c1541 -attach ./target/uos.d64 -write ./target/uos-gfx.prg uos-gfx
c1541 -attach ./target/uos.d64 -write ./target/uos-drv1351.prg uos-drv1351
c1541 -attach ./target/uos.d64 -write ./target/uos-sprites.prg uos-sprites
c1541 -attach ./target/uos.d64 -write ./target/uos-reu.prg uos-reu
c1541 -attach ./target/uos.d64 -write ./target/uos-desktop.prg uos-desktop