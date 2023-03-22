header:
	goto startup
	nop
	nop
	nop
	goto rtcc_isr  ; interrupts are vectored to address 0004

porta_outputs:
	; routine to set portb to all outputs
	; leaves page at 0

	bsf 3,5 ; use page 1
	clrf 5 ; set PORTB to all outputs
	bcf 3,5 ; use page 0
	return

portb_outputs:
	; routine to set portb to all outputs
	; leaves page at 0

	bsf 3,5 ; use page 1
	clrf 6 ; set PORTB to all outputs
	bcf 3,5 ; use page 0
	return

portb_inputs:
	; routine to set port a to 4 inputs
	; leaves page at 0 
	; upsets w

	bsf 3,5 ; use page 1

	movlw 255 ;
	movwf 6  ; set bottom 4 bits of trisa
	
	bcf 3,5 ; use page 0	
	return

porta_inputs:
	; routine to set port a to 4 inputs
	; leaves page at 0 
	; upsets w

	bsf 3,5 ; use page 1

	movlw 15 ;
	movwf 5  ; set bottom 4 bits of trisa
	
	bcf 3,5 ; use page 0	
	return


enable_interrupts:
	; sets the global interrupt enable bit
	bsf 11, 7 ; set bit 7 of INTCON reg
	return

disable_interrupts:
	; unsets the global interrupt enable bit
	bcf 11,7 ; unset bit 7 of INTCON reg
	return

startup:
	; startup for the board
	; disables interrupts, sets portb to output
	; Enables RT interrupt (for when interrupts enabled)
	; Sets prescalar to RTCC 1:256
	; then calls the labal called 'main'
	
	clrf 6	
	bsf 3,5   ; use page 1

	movlw 7 ; set option to RTCC prescaler 1:256
	movwf 1 ; 

	bcf 3,5	  ; use page 0

	bcf 11, 7	; Set INTCON to Global interrupt enable
	bsf 11, 5	; set RT int enable bit


	bcf 3, 0	; clear the carry bit (god knows why)

	goto main	; run the application	
	

rtcc_isr:
	; This is called when an interrupt happens

	bcf  11, 2 ; clear the interrupt bit
	retfie	; return from interrupt

; ***************************************************************



delay30us:
	; wait a short while
	clrwdt
	nop
	nop
	nop
	nop
	nop
	nop
nop
nop
nop
nop
nop
nop
	;nop
	;nop
	;nop

	return

delay10us:
	; wait a short while
	clrwdt
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop

	return

delay1ms:
	; wait 1ms
	; uses address 30 as a counter

	movlw 100
	movwf 30

	d1ms_loop:
		call delay10us
	decfsz 30,f
	goto d1ms_loop ; dec till zero
	return

delay1s:
	; wait 1 second
	; uses address 31 as a counter
	
	movlw 255
	movwf 31

	d18ms_loop0:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop ; dec till zero

	movlw 255
	movwf 31

	d18ms_loop2:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop2 ; dec till zero
	movlw 255
	movwf 31

	d18ms_loop3:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop3 ; dec till zero
	movlw 255
	movwf 31

	d18ms_loop4:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop4 ; dec till zero


	return		

delay18ms:
	; wait 18ms
	; uses address 31 as a counter
	
	movlw 18
	movwf 31

	d18ms_loop:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop ; dec till zero
	return	


outputMidi32:
	; output the value of register 32 to 
	; uses register 33 as working space

	; set f33 to f32,  but invert the bits (serial sends 1 is low, 0 is hi)
	movf 32,w
	xorlw 255
	movwf 33


	; write the start bit (a high)
	movlw 1
	movwf 5
	call delay30us


	; write f33 to porta
	movf 33,w	
	movwf 5

	; shift f33 right one
	
	
	rrf 33,f

	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us

	; write the stop bit (a low)
	movlw 0
	movwf 5
	call delay30us

	return

sendMidiOn:

	; send Midi note on, channel=0, note=100, volume=100
	movlw 144
	movwf 32
	call outputMidi32
	movf 34,w
	movwf 32
	call outputMidi32
	movlw 36
	movwf 32
	call outputMidi32
	return

sendMidiOff:

	; send Midi note off, channel=0, note=100, volume=100
	movlw 128
	movwf 32
	call outputMidi32
	movf 34,w
	movwf 32
	call outputMidi32
	movlw 36
	movwf 32
	call outputMidi32
	return

	
; ***************************************************************
; MEMORY MAP:
; 
; 30 counters for delay routines
; 31 counters for delay routines
; 32 Input value for outputMidi32
; 33 working register for outputMidi32
; 34 input value for sendMidiOn and Off

; 14 state counter for note 0
; 15 note number for note 0
; 16 state counter for note 1
; 17 note number for note 1
; 18 state 2
; 19 note 2
; 20 state 3
; 21 note 3
; 22 state 4
; 23 note 4
; 24 state 5
; 25 note 5
; 26 state 6
; 27 note 6
; 28 state 7
; 29 state 8
; 
; **************************************************************

; decrement the state value pointed to by fsr, if it goes to
; zero call sendMidiOff for that note

leak:
  movf 0,w
 ; IF *fsr != 0
  btfsc 3,2    
  goto leak_block_end

    ; IF state-- is zero
    decfsz 0,f
    goto leak_block2_end
   	;  Send midi off
	incf 4,f ; point to the note number
	movf 0,w
	movwf 34
	call sendMidiOff
	decf 4,f
 
    leak_block2_end:

  leak_block_end:

  return

; Called when the io bit for a note is high.
; reads the state value from whats at the fsr register
; reads the note value from the fsr + 1
; leaves fsr intact
; 
; when an an up edge is detected call sendMidiOn with the note number
lineHigh:
  ; test if state counter (*FSR)
  ; if its zero then this is an up edge, send midi and set state to 30.
  ; if its not zero set state to 30

  movf 0,w

  ;movf 0,f  ; consider the state value

  ; IF Z is set...
  btfss 3,2; 
  goto lineHigh_block1end

      ; up edge - copy note (*fsr+1) to f34 and call sendMidiOn
      incf 4,f ; FSR
      movf 0, w
      movwf 34
      decf 4,f ; FSR
      call sendMidiOn

      
  lineHigh_block1end:

  ; set state to 30 and return
  movlw 30
  movwf 0
  
  return

  
main:
	; at present dont do anything

	call disable_interrupts
	call porta_outputs
	call portb_inputs

	; set the irp to 0
	bcf 3,7

	; nice notes 50,55,62,65

	; initialise state values
	movlw 0
	movwf 14 
	movwf 16 
	movwf 18
	movwf 20 
	movwf 22
	movwf 24
	movwf 26
        movwf 28 

	; set the note numbers
	movlw 50
	movwf 15  

	movlw 52
	movwf 17  

	movlw 54
	movwf 19  

	movlw 57
	movwf 21  

	movlw 59
	movwf 23  

	movlw 62
	movwf 25  

	movlw 64
	movwf 27  

	movlw 66 
	movwf 29  


	main_loop:

		; WARNING logic for inputs is inverted at the moment

		; test bit 0
		movlw 14 
		movwf 4 ; set FSR
		btfss 6,0; test bit 0 of PORTB
			call lineHigh

		; test bit 1
		movlw 16 
		movwf 4 ; set FSR
		btfss 6,1; PORTB
			call lineHigh

		; test bit 2
		movlw 18
		movwf 4 ; set FSR 
		btfss 6,2; PORTB
			call lineHigh

		; test bit 3
		movlw 20 
		movwf 4 ; set FSR
		btfss 6,3; PORTB
			call lineHigh


		; test bit 4
		movlw 22 
		movwf 4 ; set FSR
		btfss 6,4; PORTB
			call lineHigh

		; test bit 5
		movlw 24 
		movwf 4 ; set FSR
		btfss 6,5;  PORTB
			call lineHigh

		; test bit 6
		movlw 26
		movwf 4 ; set FSR 
		btfss 6,6; PORTB
			call lineHigh

		; test bit 7
		movlw 28 
		movwf 4 ; set FSR
		btfss 6,7; PORTB
			call lineHigh


		; leak bit 0
		movlw 14
		movwf 4;  fsr
		call leak
	
		; leak bit 1
		movlw 16
		movwf 4; fsr
		call leak

		; leak bit 2
		movlw 18
		movwf 4;  fsr
		call leak
	
		; leak bit 3
		movlw 20
		movwf 4; fsr
		call leak
	
		; leak bit 4
		movlw 22
		movwf 4;  fsr
		call leak
	
		; leak bit 5
		movlw 24
		movwf 4; fsr
		call leak

		; leak bit 6
		movlw 26
		movwf 4;  fsr
		call leak
	
		; leak bit 7
		movlw 28
		movwf 4; fsr
		call leak
	
		call delay1ms


	goto main_loop

end
	
; generic.asm - generic surce file

header:
	goto startup
	nop
	nop
	nop
	goto rtcc_isr  ; interrupts are vectored to address 0004

porta_outputs:
	; routine to set portb to all outputs
	; leaves page at 0

	bsf 3,5 ; use page 1
	clrf 5 ; set PORTB to all outputs
	bcf 3,5 ; use page 0
	return

portb_outputs:
	; routine to set portb to all outputs
	; leaves page at 0

	bsf 3,5 ; use page 1
	clrf 6 ; set PORTB to all outputs
	bcf 3,5 ; use page 0
	return

portb_inputs:
	; routine to set port a to 4 inputs
	; leaves page at 0 
	; upsets w

	bsf 3,5 ; use page 1

	movlw 255 ;
	movwf 6  ; set bottom 4 bits of trisa
	
	bcf 3,5 ; use page 0	
	return

porta_inputs:
	; routine to set port a to 4 inputs
	; leaves page at 0 
	; upsets w

	bsf 3,5 ; use page 1

	movlw 15 ;
	movwf 5  ; set bottom 4 bits of trisa
	
	bcf 3,5 ; use page 0	
	return


enable_interrupts:
	; sets the global interrupt enable bit
	bsf 11, 7 ; set bit 7 of INTCON reg
	return

disable_interrupts:
	; unsets the global interrupt enable bit
	bcf 11,7 ; unset bit 7 of INTCON reg
	return

startup:
	; startup for the board
	; disables interrupts, sets portb to output
	; Enables RT interrupt (for when interrupts enabled)
	; Sets prescalar to RTCC 1:256
	; then calls the labal called 'main'
	
	clrf 6	
	bsf 3,5   ; use page 1

	movlw 7 ; set option to RTCC prescaler 1:256
	movwf 1 ; 

	bcf 3,5	  ; use page 0

	bcf 11, 7	; Set INTCON to Global interrupt enable
	bsf 11, 5	; set RT int enable bit


	bcf 3, 0	; clear the carry bit (god knows why)

	goto main	; run the application	
	

rtcc_isr:
	; This is called when an interrupt happens

	bcf  11, 2 ; clear the interrupt bit
	retfie	; return from interrupt

; ***************************************************************



delay30us:
	; wait a short while
	clrwdt
	nop
	nop
	nop
	nop
	nop
	nop
nop
nop
nop
nop
nop
nop
	;nop
	;nop
	;nop

	return

delay10us:
	; wait a short while
	clrwdt
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop
	;nop

	return

delay1ms:
	; wait 1ms
	; uses address 30 as a counter

	movlw 100
	movwf 30

	d1ms_loop:
		call delay10us
	decfsz 30,f
	goto d1ms_loop ; dec till zero
	return

delay1s:
	; wait 1 second
	; uses address 31 as a counter
	
	movlw 255
	movwf 31

	d18ms_loop0:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop ; dec till zero

	movlw 255
	movwf 31

	d18ms_loop2:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop2 ; dec till zero
	movlw 255
	movwf 31

	d18ms_loop3:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop3 ; dec till zero
	movlw 255
	movwf 31

	d18ms_loop4:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop4 ; dec till zero


	return		

delay18ms:
	; wait 18ms
	; uses address 31 as a counter
	
	movlw 18
	movwf 31

	d18ms_loop:
		call delay1ms
	decfsz 31, f
	goto d18ms_loop ; dec till zero
	return	


outputMidi32:
	; output the value of register 32 to 
	; uses register 33 as working space

	; set f33 to f32,  but invert the bits (serial sends 1 is low, 0 is hi)
	movf 32,w
	xorlw 255
	movwf 33


	; write the start bit (a high)
	movlw 1
	movwf 5
	call delay30us


	; write f33 to porta
	movf 33,w	
	movwf 5

	; shift f33 right one
	
	
	rrf 33,f

	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us
	; write f33 to porta
	movf 33,w	
	movwf 5
	; shift f33 right one
	rrf 33,f
	call delay30us

	; write the stop bit (a low)
	movlw 0
	movwf 5
	call delay30us

	return

sendMidiOn:

	; send Midi note on, channel=0, note=100, volume=100
	movlw 144
	movwf 32
	call outputMidi32
	movf 34,w
	movwf 32
	call outputMidi32
	movlw 36
	movwf 32
	call outputMidi32
	return

sendMidiOff:

	; send Midi note off, channel=0, note=100, volume=100
	movlw 128
	movwf 32
	call outputMidi32
	movf 34,w
	movwf 32
	call outputMidi32
	movlw 36
	movwf 32
	call outputMidi32
	return

	
; ***************************************************************
; MEMORY MAP:
; 
; 30 counters for delay routines
; 31 counters for delay routines
; 32 Input value for outputMidi32
; 33 working register for outputMidi32
; 34 input value for sendMidiOn and Off

; 14 state counter for note 0
; 15 note number for note 0
; 16 state counter for note 1
; 17 note number for note 1
; 18 state 2
; 19 note 2
; 20 state 3
; 21 note 3
; 22 state 4
; 23 note 4
; 24 state 5
; 25 note 5
; 26 state 6
; 27 note 6
; 28 state 7
; 29 state 8
; 
; **************************************************************

; decrement the state value pointed to by fsr, if it goes to
; zero call sendMidiOff for that note

leak:
  movf 0,w
 ; IF *fsr != 0
  btfsc 3,2    
  goto leak_block_end

    ; IF state-- is zero
    decfsz 0,f
    goto leak_block2_end
   	;  Send midi off
	incf 4,f ; point to the note number
	movf 0,w
	movwf 34
	call sendMidiOff
	decf 4,f
 
    leak_block2_end:

  leak_block_end:

  return

; Called when the io bit for a note is high.
; reads the state value from whats at the fsr register
; reads the note value from the fsr + 1
; leaves fsr intact
; 
; when an an up edge is detected call sendMidiOn with the note number
lineHigh:
  ; test if state counter (*FSR)
  ; if its zero then this is an up edge, send midi and set state to 30.
  ; if its not zero set state to 30

  movf 0,w

  ;movf 0,f  ; consider the state value

  ; IF Z is set...
  btfss 3,2; 
  goto lineHigh_block1end

      ; up edge - copy note (*fsr+1) to f34 and call sendMidiOn
      incf 4,f ; FSR
      movf 0, w
      movwf 34
      decf 4,f ; FSR
      call sendMidiOn

      
  lineHigh_block1end:

  ; set state to 30 and return
  movlw 30
  movwf 0
  
  return

  
main:
	; at present dont do anything

	call disable_interrupts
	call porta_outputs
	call portb_inputs

	; set the irp to 0
	bcf 3,7

	; nice notes 50,55,62,65

	; initialise state values
	movlw 0
	movwf 14 
	movwf 16 
	movwf 18
	movwf 20 
	movwf 22
	movwf 24
	movwf 26
        movwf 28 

	; set the note numbers
	movlw 50
	movwf 15  

	movlw 52
	movwf 17  

	movlw 54
	movwf 19  

	movlw 57
	movwf 21  

	movlw 59
	movwf 23  

	movlw 62
	movwf 25  

	movlw 64
	movwf 27  

	movlw 66 
	movwf 29  


	main_loop:

		; WARNING logic for inputs is inverted at the moment

		; test bit 0
		movlw 14 
		movwf 4 ; set FSR
		btfss 6,0; test bit 0 of PORTB
			call lineHigh

		; test bit 1
		movlw 16 
		movwf 4 ; set FSR
		btfss 6,1; PORTB
			call lineHigh

		; test bit 2
		movlw 18
		movwf 4 ; set FSR 
		btfss 6,2; PORTB
			call lineHigh

		; test bit 3
		movlw 20 
		movwf 4 ; set FSR
		btfss 6,3; PORTB
			call lineHigh


		; test bit 4
		movlw 22 
		movwf 4 ; set FSR
		btfss 6,4; PORTB
			call lineHigh

		; test bit 5
		movlw 24 
		movwf 4 ; set FSR
		btfss 6,5;  PORTB
			call lineHigh

		; test bit 6
		movlw 26
		movwf 4 ; set FSR 
		btfss 6,6; PORTB
			call lineHigh

		; test bit 7
		movlw 28 
		movwf 4 ; set FSR
		btfss 6,7; PORTB
			call lineHigh


		; leak bit 0
		movlw 14
		movwf 4;  fsr
		call leak
	
		; leak bit 1
		movlw 16
		movwf 4; fsr
		call leak

		; leak bit 2
		movlw 18
		movwf 4;  fsr
		call leak
	
		; leak bit 3
		movlw 20
		movwf 4; fsr
		call leak
	
		; leak bit 4
		movlw 22
		movwf 4;  fsr
		call leak
	
		; leak bit 5
		movlw 24
		movwf 4; fsr
		call leak

		; leak bit 6
		movlw 26
		movwf 4;  fsr
		call leak
	
		; leak bit 7
		movlw 28
		movwf 4; fsr
		call leak
	
		call delay1ms


	goto main_loop

end
	
