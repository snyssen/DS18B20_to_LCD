@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "F:\WORK\uK\AVR\Projects\ibutton-number-read\labels.tmp" -fI -W+ie -o "F:\WORK\uK\AVR\Projects\ibutton-number-read\ibutton-number-read.hex" -d "F:\WORK\uK\AVR\Projects\ibutton-number-read\ibutton-number-read.obj" -e "F:\WORK\uK\AVR\Projects\ibutton-number-read\ibutton-number-read.eep" -m "F:\WORK\uK\AVR\Projects\ibutton-number-read\ibutton-number-read.map" "F:\WORK\uK\AVR\Projects\ibutton-number-read\main.asm"