SECTION code_user

PUBLIC search_slotset
PUBLIC setrompage0
PUBLIC recbios

; *** CONSTANTES ***

DEFC NEWKEY					=		0FBE5h
DEFC CHGMOD					=		05Fh

DEFC PTRFLG					=		0F416h
DEFC PTRFIL					=		0F864h
DEFC OUTDO					=		18h
DEFC FORCLR					=		0F3E9h
DEFC BAKCLR					=		0F3EAh
DEFC BDRCLR					=		0F3EBh
DEFC LINL40					=		0F3AEh
DEFC CLIKSW					=		0F3DBh
DEFC CSRY					=		0F3DCh
DEFC CSRX					=		0F3DDh

DEFC ENASLT                 =     024h


DEFC EXPTBL                 =     0FCC1h
DEFC SLTTBL                 =     0FCC5h
DEFC RDSLT                  =     000Ch
DEFC RGSAV                  =     0F3DFh

DEFC KEYROWS				=		11


;  *** VARIABLES ***

keys: DEFW 						0E000h								; Tecla actual
keysold: DEFW 					keys			+ KEYROWS			; Para tecla old
keytrigger: DEFW 				keysold			+ KEYROWS
keynotrigger: DEFW 				keytrigger		+ 1
keybutton1: DEFW 				keynotrigger	+ 1
keybutton2: DEFW 				keybutton1		+ 1

slotvar: DEFW                      keybutton2      + 1
slotram: DEFW                      slotvar         + 1

vdp_reg98: DEFW                    slotram         + 1
vdp_reg99: DEFW                    vdp_reg98       + 1
vdp_reg9A: DEFW                    vdp_reg99       + 1
vdp_reg9B: DEFW                    vdp_reg9A       + 1

vdp_reg98r: DEFW                   vdp_reg9B       + 1
vdp_reg99r: DEFW                   vdp_reg98r      + 1
vdp_reg9Ar: DEFW                   vdp_reg99r      + 1
vdp_reg9Br: DEFW                   vdp_reg9Ar      + 1

; *** LOADSCREEN *** 

; Esta rutina hace uso de la pagina baja de 48k
; Posiciona la misma
; Manda a la VRAM los datos
; Y vuelve a dejar la BIOS

;loadscreen:
;
;                        di                               ; Muy importante 
;                        call    setrompage0              ; Posicionamos la pagina de 16k bajos de nuestro rom en la zona 0-3FFFh
;
;
;
;                        ld      hl,DATA_VRAM
;                        ld      de,0
;                        ld      bc,04000h
;                        call    fillvram                ; Mandamos los 16k de Vram
;
;
;
;                        call    recbios                 ; Recuperamos la bios
;                        ret

; -----------------------
; SEARCH_SLOTSET
; Posiciona en pagina 2
; Nuestro ROM.
; -----------------------

search_slotset:
				        call	search_slot
				        ld		(slotvar),a
				
       				jp		ENASLT

; -----------------------
; SEARCH_SLOT
; Busca slot de nuestro rom
; Siempre que se ejecute
; En 04000h-07FFFh (pagina1)
; -----------------------

search_slot:
				
				        call	0138h
				        rrca
				        rrca
				        and		3
				        ld		c,a
				        ld		b,0
				        ld		hl,0FCC1h
				        add		hl,bc
				        ld		a,(hl)
				        and		080h
				        jr		z,search_slot0
				        or		c
				        ld		c,a
				        inc		hl
				        inc		hl
				        inc		hl
				        inc		hl
				        ld		a,(hl)
				        and		0Ch
search_slot0:
				        or		c
				        ld		h,080h
				        ret


; ---------------------
; SEARCH_SLOTRAM
; Busca el slot de la ram
; Y almacena
; ----------------------				
				
search_slotram:
				        call	0138h
				        rlca
				        rlca
				        and		3
				        ld		c,a
				        ld		b,0
				        ld		hl,0FCC1h
				        add		hl,bc
				        ld		a,(hl)
				        and		080h
				        jr		z,search_slotram0
				        or		c
				        ld		c,a
				        inc		hl
				        inc		hl
				        inc		hl
				        inc		hl
				        ld		a,(hl)
				        rlca
				        rlca
				        rlca
				        rlca
				        and		0Ch
search_slotram0:
				        or		c
				        ld		(slotram),a
    				
	        			ret
			
			
; ------------------------------
; SETROMPAGE0			
; Posiciona nuestro cartucho en 
; Pagina 0
; -----------------------------

setrompage0:	

				
        				ld		a,(slotvar)		
				        jr		setslotpage0	
				
			
			
; ------------------------------
; RECBIOS
; Posiciona la bios ROM
; -------------------------------
					
recbios:		
        				ld		a,(EXPTBL)
				
			

; ---------------------------
; SETSLOTPAGE0
; Posiciona el slot pasado 
; en pagina 0 del Z80
; A: Formato FxxxSSPP
; ----------------------------
            
setslotpage0:       
                    di

                    ld      b,a                 ; B = Slot param in FxxxSSPP format                
                    
                    
                    in      a,(0A8h)
                    and     011111100b
                    ld      d,a                 ; D = Primary slot value
                    
                    ld      a,b         
                    
                    and     03  
                    or      d
                    ld      d,a                 ; D = Final Value for primary slot 

                    
                    out     (0A8h),a
                    
                    ; Check if expanded
                    ld      a,b
                    bit     7,a
                    ret     z   
                    
                    and     03h                             
                    rrca
                    rrca
                    and     011000000b
                    ld      c,a                 
                    ld      a,d
                    and     00111111b
                    or      c
                    ld      c,a                 ; Primary slot value with main slot in page 3  

                    ld      a,b
                    and     00001100b
                    rrca
                    rrca    
                    and     03h
                    ld      b,a                 ; B = Expanded slot in page 3
                    ld      a,c
                    out     (0A8h),a            ; Slot : Main Slot, xx, xx, Main slot
                    ld      a,(0FFFFh)
                    cpl
                    and     011111100b
                    or      b
                    ld      (0FFFFh),a          ; Expanded slot selected 

                    ld      c,a

                                                ; Slot Final. Ram, rom c, rom c, Main
                    ld      a,d                 ; A = Final value
                    out     (0A8h),a

                    and     3                   ; Set value in STLTBL 
                    ld      de,SLTTBL    
                    add     a,e
                    ld      e,a
                    jr      nc,nocarry
                    inc     d
nocarry:
                    ld      a,c
                    ld      (de),a

                    ret

                    
setslotpage0_end:


; *** VRAM *** 



; -------------------
; INITVRAM
; Inicializa la VRAM
;  HL : Puntero
; A = 1 Escritura
; A = 0 Lectura
; -------------------

initvram:	
				or		a
				jp		z,initvramrd
initvramwr:		
				di				
				ld		a,(vdp_reg99)
				ld		c,a							
				out		(c),l
				set		6,h
				nop
				out		(c),h
				ret
				
initvramrd:
				di
				ld		a,(vdp_reg99)
				ld		c,a							
				out		(c),l
				res		6,h
				nop
				out		(c),h
				ret


; -------------------
; FILLVRAM
; HL :	 Origen datos
; DE :	 Destino Vram
; BC :	 Datos
; A: Page 
; -------------------


fillvram:	

	
				ex		de,hl
				push	de
				push	bc
				call	initvramwr	
				pop		bc
				pop		hl

fillvram_10:	
				ld		a,c				
				or		a
				ld		d,a
				
				ld		a,(vdp_reg98)			
				ld		c,a
				ld		a,b
				
				
				jp		z,fillvram_11

				
				ld		b,d
fillvram_10l:	
				outi				
				jp		nz,fillvram_10l
				or		a
				ret		z
     	
				
fillvram_11:	
	
fillvram_12:	
				ld		b,0
fillvram_12l:
				outi
				
				jp		nz,fillvram_12l
				dec		a
				jp		nz,fillvram_12
				ret
