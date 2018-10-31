#include <msx.h>
#include "rodata.h"

/*
- rodata goes to low memory
- code starts at 0x4000 as usual
- BSS (uninitialised static/global variables) into RAM at 0xc000
*/

static int data_int = 1;
static int bss_int = 2;
static const int rodata_int = 3;

void changeBIOStoPage0(void) {
	__asm 
	extern search_slotset
	extern setrompage0

		call    search_slotset
		di                               ; Muy importante 
		call    setrompage0              ; Posicionamos la pagina de 16k bajos de nuestro rom en la zona 0-3FFFh
		
	__endasm;
}

void changePage0toBIOS(void) {
	__asm 
	extern recbios

		call    recbios                 ; Recuperamos la bios
		ei
        ret
	__endasm;
}

void main(void) {

    msx_text();
    msx_color(INK_WHITE, INK_GRAY, INK_BLACK);

    changeBIOStoPage0();

    data_int = rodata_int;
    bss_int = rodata_int2;

    changePage0toBIOS();

    if (data_int != 3) {
		msx_color(INK_WHITE, INK_MEDIUM_GREEN, INK_BLACK);
    } else {
	    if (bss_int != 4) {
			msx_color(INK_WHITE, INK_DARK_BLUE, INK_BLACK);
	    } else {
			msx_color(INK_WHITE, INK_MAGENTA, INK_BLACK);
	    }
    }
      
    while(1) {  } 
}
