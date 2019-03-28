; Código migrado a partir de la guia realizada por Ramones y que se puede encontrar en el siguiente enlace: 
; http://www.msxblog.es/tutorial-ensamblador-i-como-crear-una-rom-de-48k/


SECTION code_user

PUBLIC search_slotset
PUBLIC setrompage0
PUBLIC recbios

; *** CONSTANTES ***

DEFC ENASLT                 =     024h

DEFC EXPTBL                 =     0FCC1h
DEFC SLTTBL                 =     0FCC5h

;  *** VARIABLES ***

DEFC slotvar = $E000

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

; ------------------------------
; SETROMPAGE0			
; Posiciona nuestro cartucho en 
; Pagina 0
; -----------------------------

setrompage0:	

				
        				ld		a,(slotvar)		; Leemos el slot del juego	
				        jp		setslotpage0	; Situamos la pagina 0 del juego y volvemos
				
			
			
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
                    jr      nc,nocarryxx
                    inc     d
nocarryxx:
                    ld      a,c
                    ld      (de),a

                    ret

                    
setslotpage0_end:
