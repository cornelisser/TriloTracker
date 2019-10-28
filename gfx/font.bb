;/////////////////////////////////////////////////////
; Main GUI
;/////////////////////////////////////////////////////
; character set
Global smallfont=LoadFont("Verdana",12,False,False,False)
Global largefont=LoadFont("Verdana",22,False,False,False)
;main window
Global mainWin =  CreateWindow("[ ] Tile converter - (c) Trilobyte 2009",100,100,600,600,Desktop())
Global mainPanel = CreatePanel(0,0,600,600,mainWin)
Global bmpCanvas = CreateCanvas(0,0,512,128,mainPanel)
Global infoCanvas = CreateCanvas(514,76,80,80,mainPanel)
Global selectionCanvas = CreateCanvas(0,132,512,128,mainPanel)
Global outputCanvas = CreateCanvas(0,264,512,128,mainPanel)
Global outputText = CreateTextArea(0,264+4+128,512,128,mainPanel)

Global loadBMPbutton = CreateButton("Load BMP",518,2,70,30,mainPanel)
Global leveldownbutton = CreateButton("<<",518,36,35,30,mainPanel)
Global levelupbutton = CreateButton(">>",518+35,36,35,30,mainPanel)
Global exportBMPbutton = CreateButton("Export BMP",518,264,70,30,mainPanel)

Global tile_strip			= CreateImage (16,16,256)
MaskImage tile_strip,255,40,255
Global tile_strip2			= CreateImage (16,16,256)
MaskImage tile_strip2,255,40,255

Global selectionBank = CreateBank (256)
Global bmpPalette = CreateBank(256*3)   		; for each entry the r,g and b values are stored seperatly
Global bmpImageBank = CreateBank(256*192*8) 
Global screen2_patterns = CreateBank(8*256)     ; patterns
Global screen2_colors = CreateBank(8*256)		; patterns

Global current_level = 0

For x=0 To 255 
	PokeByte selectionBank,x,0
Next

load_tileset("font.bmp")
show()

;For port = 9938 To 9958
Global	tcp = OpenTCPStream ("127.0.0.1",9952)
;	If tcp 
;		Exit
;	EndIf
;Next




;/////////////////////////////////////////////////////
;
;
; Main routine
;
;
;//////////////////////////////////////////////////////
Repeat
	eid = WaitEvent()
	edata = EventData()
	esource = EventSource()

	Select eid
	
	
		;/////////////////////////////////////////////////////
		; Gadget handle
		; (Sliders/buttons etc.)
		;/////////////////////////////////////////////////////
		Case $401;	gadget action	
			If esource = loadBMPButton
				load_tileset("")
			Else If esource = exportBMPbutton
				export()
			Else If esource = leveldownbutton And current_level > 0
				current_level = current_level -1
			Else If esource = levelupbutton And current_level < 32
				current_level = current_level + 1
			EndIf
			show()

			
			
			
					
		;/////////////////////////////////////////////////////
		; Menu selection
		; 
		;/////////////////////////////////////////////////////
		Case $1001; 
		;	process_menu(edata)
	
		;/////////////////////////////////////////////////////
		; Mouse down
		; (Canvases)
		;/////////////////////////////////////////////////////			
		Case $201; mouse down
				process_mousedown(esource)


			
		;/////////////////////////////////////////////////////
		; Mouse over canvas
		; (Canvases)
		;/////////////////////////////////////////////////////						
		Case $203;	
		;	process_mouseover(esource)
			If MouseDown(1) Or MouseDown(2)
				process_mousedown(esource)
			EndIf
		
		show()
	
	End Select		
Until eid = $803 And esource = mainWin

End

Function load_tileset(file$)
	;If file$ = ""
		file$ = "font.bmp"
	;EndIf	
	
	If file$<>""	
		filein=ReadFile(file$)
		If filein
			TFormFilter 0
			tile_strip = LoadAnimImage(file$,8,8,0,256)
			tile_strip_small = CopyImage(tile_strip)
			MaskImage tile_strip,255,40,255
			MaskImage tile_strip_small,255,40,255
			ScaleImage(tile_strip,2.0,2.0)
			
			For x=0 To 255 
				PokeByte selectionBank,x,0
			Next
		
		
		; Fileinfo
			bmpFileType$ = Chr$(ReadByte(filein))+Chr$(ReadByte(filein))
			bmpFileSize = ReadInt(filein)
			bmpFileReserved1 = ReadShort(filein)
			bmpFileReserved2 = ReadShort(filein)
			bmpFileOffset = ReadInt(filein)
		; headerinfo
			bmpHeaderSize = ReadInt(filein)
			bmpHeaderWidth = ReadInt(filein)
			bmpHeaderHeight = ReadInt(filein)
			bmpHeaderPlanes = ReadShort(filein)
			bmpHeaderBitCount = ReadShort(filein)
			bmpHeaderCompression = ReadInt(filein)
			bmpHeaderSizeImage = ReadInt(filein)
			bmpHeaderXpelPerMeter = ReadInt(filein)
			bmpHeaderYpelPerMeter = ReadInt(filein)
			bmpHeaderClrUsed = ReadInt(filein)
			bmpHeaderClrImportant = ReadInt(filein)
		; colorpalette  (true color is not supported)
			Select bmpHeaderBitCount
				Case 8	; 256 colors
					For c=0 To 255
						PokeByte(bmpPalette,(c*3)+2,(ReadByte(filein)))			; b
						PokeByte(bmpPalette,(c*3)+1,(ReadByte(filein)))			; G
						PokeByte(bmpPalette,(c*3)+0,(ReadByte(filein)))			; r
						ReadByte(filein) ; 4th byte is empty
					Next
				Case 4	; 16 colors
					For c=0 To 15
						PokeByte(bmpPalette,(c*3)+2,(ReadByte(filein)))			; b
						PokeByte(bmpPalette,(c*3)+1,(ReadByte(filein)))			; G
						PokeByte(bmpPalette,(c*3)+0,(ReadByte(filein)))			; r
						ReadByte(filein) ; 4th byte is empty
					Next
			End Select	
			
		; image data
			Select bmpHeaderBitCount
				Case 8	; 256 colors		
					For x=0 To bmpHeaderSizeImage -1
						PokeByte(bmpImageBank,x,ReadByte(filein))
					Next
				Case 4	; 16 colors
					For x=0 To bmpHeaderSizeImage -1
						value = ReadByte(filein)
						PokeByte(bmpImageBank,(x*2)+1,(value And 15))
						PokeByte(bmpImageBank,(x*2),(value Shr 4))
					Next				
			End Select					
			
			
			CloseFile filein

			file2$ = "data\l"+current_level+"sel.bin"
			filein = ReadFile(file2$)
			If filein
				For r = 0 To 255
					PokeByte(selectionBank,r,ReadByte(filein))
				Next
				CloseFile filein
			EndIf

			
		EndIf
		
		
		
		
	EndIf
End Function 


Function show()
	SetBuffer CanvasBuffer(bmpCanvas)

	For t=0 To 255 
		DrawImage tile_strip,(t Mod 32)*16,(t/32)*16,t
	Next
	
	
	FlipCanvas bmpCanvas
	
	SetBuffer CanvasBuffer(selectionCanvas)

	Color 255,0,0
	For t=0 To 255 
		DrawImage tile_strip,(t Mod 32)*16,(t/32)*16,t
		If (PeekByte(selectionBank,t) > 0 )
			Color 255,0,0
			Rect (t Mod 32)*16,(t/32)*16,16,16,0
			Color 200,200,200
			Line (t Mod 32)*16,(t/32)*16,16+(t Mod 32)*16,16+(t/32)*16
			Line 16+(t Mod 32)*16,(t/32)*16,(t Mod 32)*16,16+(t/32)*16

		EndIf
	Next

	
	Color 255,255,255
	Text 0,0,tcp
	

	If	tcp
	Text 0,32,"Bytes available:" + ReadAvail(tcp)
	Text 16,16,"from openMSX:"+TCPStreamIP(tcp)+"/"+TCPStreamPort(tcp)+"/"+temp$

	
	
	temp$ = ReadString$(tcp)
	If	Not(temp$ = "")

	Text 16,47,"from openMSX:"+TCPStreamIP(tcp)+"/"+TCPStreamPort(tcp)+temp$
	EndIf

;	WriteLine tcp,"<?xml version="+Chr$(66)+"1.0"+Chr$(66)+" encoding="+Chr$(66)+"UTF-8"+Chr$(66)+"?>"+Chr$(10)

WriteString tcp,"<openmsx-control>"+Chr$(10)	
WriteString tcp,"<command>reset</command>"+Chr$(10)
WriteString tcp,"</openmsx-control>"+Chr$(10)


	EndIf
	


	
;WriteLine tcp,"<openmsx-control>"	
;WriteLine tcp,"<command>debug write {Main RAM} 0x0000 10</command>"	
	
	
	
	
	FlipCanvas selectionCanvas
	
	tmp = 0
	SetBuffer CanvasBuffer(outputCanvas)
	Color 0,0,0
	Rect 0,0,512,128,1
	For t=0 To 255 
		If (PeekByte(selectionBank,t) = 0 )
			DrawImage tile_strip,(tmp Mod 32)*16,(tmp/32)*16,t
			tmp = tmp +1
		EndIf
	Next
	FlipCanvas outputCanvas	
	
	SetBuffer CanvasBuffer(infoCanvas)
	Color 190,190,190
	Rect 0,0,80,80,1
	Color 255,255,255
	Text 0,0,"Level"+current_level
	FlipCanvas infoCanvas

End Function

Function process_mousedown(esource)
	If esource = selectionCanvas
		tile = (MouseX(selectionCanvas)/16)+((MouseY(selectionCanvas)/16)*32)
		If tile >= 0 And tile < 256
			If MouseDown(1)
				PokeByte(selectionBank,tile,1)
			Else
				PokeByte(selectionBank,tile,0)
			EndIf
		EndIf
	EndIf
End Function


Function export()
		t2 = 0
		For t = 0 To 255
				If PeekByte(selectionbank,t) = 0
					x = t Mod 32
					y = t / 32

					For tile_y = 0 To 7
						col_0 = 0
						col_1 = 255
						pat = 0
							For tile_x = 0 To 7
							value = PeekByte(bmpImageBank,(x*8)+tile_x+((64-8-(y*8))*256)+((7-tile_y)*256))
							If value <> 255
									
								If col_0 = 255
									col_0 = value
								Else If (col_1 = 255) And (col_0 <> value)
									col_1 = value
								EndIf
								
								If value = col_1
									pat = pat + (128 Shr tile_x)
								EndIf
						
							EndIf

						
						Next
						x2 = t2 Mod 32
						y2 = t2 / 32
						AddTextAreaText (outputtext,x2+","+y2+Chr(13)+Chr(10))
						PokeByte(screen2_patterns,(x2*8)+(y2*8*32)+tile_y,pat)
						value = (col_1 Shl 4) + col_0
						PokeByte(screen2_colors,(x2*8)+(y2*8*32)+tile_y,value)
					Next
					t2 = t2 + 1
				EndIf 
		Next

		tmpbank = CreateBank(512)
		tilecount = 0

		offset = 0
		count = 1
		mode = 0
		For t=0 To 255
			If (PeekByte(selectionBank,t)= 0)
				If mode=0
					mode=1
					count = 1
				Else
					count = count + 1
				EndIf
			Else If (PeekByte(selectionBank,t) = 1)
				If mode=0
					offset = offset + 1
				Else
					mode = 0
					PokeByte(tmpbank,tilecount*2,offset)
					;PokeByte(tmpbank,tilecount*2,t)

					PokeByte(tmpbank,(tilecount*2)+1,(count-1))
					tilecount = tilecount +1
					offset = 1
					count = 0
				EndIf
			EndIf
		Next
		If count > 0
					PokeByte(tmpbank,tilecount*2,offset)
					;PokeByte(tmpbank,tilecount*2,t)
					PokeByte(tmpbank,(tilecount*2)+1,(count-1))
					tilecount = tilecount +1
		EndIf
		file$ = "data\l"+current_level+"sel.bin"
		If file$<>""	
			fileout=WriteFile(file$)
			If fileout	
				For x= 0 To 255
					WriteByte(fileout,PeekByte(selectionbank,x))
				Next	
				CloseFile fileout
			EndIf	
		EndIf

		file$ = "fontpat.bin"
		If file$<>""	
			fileout=WriteFile(file$)
			If fileout	
				tileoffset = 0
			
				;WriteByte(fileout,(tilecount*2)+1)
				For z= 0 To (tilecount*2)-1
				;	WriteByte(fileout,PeekByte(tmpbank,z))				; # tiles to skip
					z = z  + 1
				;	WriteByte(fileout,PeekByte(tmpbank,z)+1)			; # tiles to copy
					c = PeekByte(tmpbank,z)+1
					For x=0 To (c*8)-1
						WriteByte(fileout,PeekByte(screen2_patterns,(x+(tileoffset*8))))
					Next
					tileoffset = tileoffset+c
					
					
				Next
				;WriteByte(fileout,255)
				CloseFile fileout
			EndIf	
		EndIf	
		file$ = "fontcol.Bin"
		If file$<>""	
			fileout=WriteFile(file$)
			If fileout
				tileoffset = 0

			
				;WriteByte(fileout,(tilecount*2)+1)
				For z= 0 To (tilecount*2)-1
					WriteByte(fileout,PeekByte(tmpbank,z))				; # tiles to skip
					z = z  + 1
					WriteByte(fileout,PeekByte(tmpbank,z)+1)			; # tiles to copy
					c = PeekByte(tmpbank,z)+1
					For x=0 To (c*8)-1
						WriteByte(fileout,PeekByte(screen2_colors,(x+(tileoffset*8))))
					Next
					tileoffset = tileoffset+c
					
					
				Next
				WriteByte(fileout,255)
				CloseFile fileout
			EndIf	
		EndIf

;		file$ = "data\l"+current_level+"set.asm"
;		If file$<>""	
;			fileout=WriteFile(file$)
;			If fileout
;				WriteLine(fileout, " ; Data   !Attention number of tiles needs to be added with 1!")
;				offset = 0
;				count = 1
;				mode = 0
;				For t=0 To 255
;					If (PeekByte(selectionBank,t)= 0)
;						If mode=0
;							mode=1
;							count = 1
;						Else
;							count = count + 1
;						EndIf
;					Else If (PeekByte(selectionBank,t) = 1)
;						If mode=0
;							offset = offset + 1
;						Else
;							mode = 0
;							WriteLine(fileout," db "+offset+", "+(count-1))
;							offset = 1
;							count = 0
;						EndIf
;					EndIf
;				Next
;				If count > 0
;					WriteLine(fileout," db "+offset+", "+(count-1))
;				EndIf
;				
;				For x= 0 To (tilecount*2)-1
;					WriteLine(fileout,PeekByte(tmpbank,x))
;				Next
;				
;				
;				CloseFile fileout
;			EndIf
;		EndIf
	
;		tempBank = CreateBank(256)
;		file$ = "data\tilesets\tiledat.asm"
;		If file$<>""	
;			fileout=WriteFile(file$)
;			If fileout
;				WriteLine(fileout," ; Tileset construction data. Add 1 to number of tiles to copy")
;				WriteLine(fileout,"_tilesetdata:")
;
;				For l = 0 To 31
;					WriteLine(fileout," dw tilesetdata_lev"+l)
;				Next
;				
;				For l = 0 To 31
;					WriteLine(fileout,"tilesetdata_lev"+l+":")
;					file2$ = "data\tilesets\l"+l+"sel.bin"
;					filein = ReadFile(file2$)
;					If filein
;						For r = 0 To 255
;							PokeByte(tempBank,r,ReadByte(filein))
;						Next
;						offset = 0
;						count = 1
;						mode = 0
;						For t=0 To 255
;							If (PeekByte(tempBank,t)= 0)
;								If mode=0
;									mode=1
;									count = 1
;								Else
;									count = count + 1
;								EndIf
;							Else If (PeekByte(tempBank,t) = 1)
;								If mode=0
;									offset = offset + 1
;								Else
;									mode = 0
;									WriteLine(fileout,"   db "+offset+", "+(count-1))
;									offset = 1
;									count = 0
;								EndIf
;							EndIf
;						Next
;						If count > 0
;							WriteLine(fileout,"   db "+offset+", "+(count-1))
;						EndIf
;						
;						
;					;	CloseFile filein
;					Else
;						WriteLine(fileout,"  ; nut'ing")			
;					EndIf
;				Next		
;			EndIf
;		EndIf
End Function