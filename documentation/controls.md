# Controls

<!-- vscode-markdown-toc -->
* [General](#general)
* [Playback](#playback)
* [Pattern Editor](#pattern-editor)
   * [Order Editor](#order-editor)
   * [Instrument List](#instrument-list)
* [Instrument Editor](#instrument-editor)
   * [Macro Editor](#macro-editor)
   * [Waveform Editor](#waveform-editor)
   * [Voice Editor](#voice-editor)
   * [FM Instrument Dialog](#fm-instrument-dialog)
* [Drum Editor](#drum-editor)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->



## <a name='general'></a>General

```
 [']                    Edit order
 [HOME]                 Jump to first row of pattern
 [CTRL]+[HOME]          Jump to beginning (order step 0) of song
 [ENTER]                Play pattern and loop
		
 [F1]	                  Play song from current pattern/order
 [F1]+[SHIFT] or [F6]   Play song in step-mode from current pattern/order
 [F2]				Open instrument editor
 [F3]				Open drum editor
 [F4]				Open track manager
 [F5]				Open file dialog
 [F5]+[SHIFT] or [F10]	 "Open the configuration editor
 [CTRL]+[D]			Edit order
 [CTRL]+[N]			Edit song name
 [CTRL]+[B]			Edit song author
 [CTRL]+[M]			<b>[Diff]</b> Change the volume balance between PSG and SCC using the left/right cursor keys
 [CTRL]+[I] or [CTRL]+[TAB]	"Enter the instrument list
 [CTRL]+[P]			Set current pattern number
 [CTRL]+[S]			Set song speed
 [CTRL]+[O]			Set octave
 [CTRL]+[T]			Set step visualization size
 [CTRL]+[A]			Set edit step
 [CTRL]+[0..8]		Mute/Unmute track. '0' is for FM drums
 [ALT]+[0..8]		<b>[New]</b> Solo/Unsolo track. '0' is for FM drums"]

```

## <a name='playback'></a>Playback
```
 [CTRL]+[0..8]		Mute/Unmute track. '0' is for FM drums
 [ALT]+[0..8]		<b>[New]</b> Solo/Unsolo track. '0' is for FM drums
 [ESC]				Stop playback on current order and pattern position
 [SPACE]				Stop playback return to the order and pattern position before playback start
 [F1]				Return to normal playback after starting looped ## 
```

## <a name='pattern-editor'></a>Pattern Editor

```
 [ESC]	 			Reset cursor to the start of the current pattern
 - MOVE -",		
 [TAB]	 			Move to next track
 [SHIFT]+[TAB]	 	Move to previous track
 [ALT]+[LEFT]	 	Move to previous track
 [ALT]+[RIGHT]	 	Move to next track
 [ALT]+[UP]			Move number of steps up
 [ALT]+[DOWN]		Move number of steps down
 [PAGEUP]	 		Move number of steps up", 			EMU
 [PAGEDOWN]	 		Move number of steps down",		EMU
 - SELECT -",		
 [SHIFT]+<arrow keys>","Select
 [SHIFT]+[ALT]+<arrow keys>","<b>[?]</b> Select
 [CTRL]+[Q]			Expand selection to pattern end
 - EDIT -",		
 [CTRL]+[C]			Copy
 [CTRL]+[V]			Paste
 [CTRL]+[SHIFT]+[V]	 "Paste (Mix)
 [CTRL]+[Z]			Undo
 [CTRL]+[Y]			Redo
 [INS]				Insert row
 [BACKSPACE]			Delete row
 [DEL]				Delete value or values inside selection	
 [A]					Note-Release
 [1]					Note-Sustain
 [SHIFT]+[A]			Note-Sustain
 [SHIFT]+[1]			Note-Release
 [SHIFT]				Enter a note with 1 octave higher
 [CTRL]+[,]/[.]		Transpose selected notes by semitone down/up
 [CTRL]+[<]/[>]		Transpose selected notes by octave down/up
 - MISC -",		
 [SPACE]				Toggle keyjazz mode
 [CTRL]+[DOWN]		Select previous pattern
 [CTRL]+[UP]			Select next pattern
 [CTRL]+[LEFT]		Select previous order
 [CTRL]+[RIGHT]		Select next order
 [CTRL]+[0..8]		Mute/Unmute track
 [ALT]+[0..8]		Solo/Unsolo track
 [CTRL]+[G]			<b>[Deprecated]</b> Copy current pattern to the first available empty pattern
 [NUMKEY 0..8]		<b>[Duplicate]</b> Set octave"]

```

### <a name='order-editor'></a>Order Editor
```
 [ESC]				Exit order editor
 [UP]				Move to previous order
 [DOWN]				Move to next order
 [LEFT]/[RIGHT]		Set pattern number
 [R]					Set restart/loop position
 [INS]				<b>[?]</b> Insert new row with pattern number + 1
 [CTRL]+[INS]		Insert a new position in the order after the last position. Inserted pattern number is the pattern number from the last order position + 1
 [CTRL]+[G]			Clone pattern

```

### <a name='instrument-list'></a>Instrument List
```
 [ESC]				Exit instrument list
 [UP]				Move to previous instrument
 [DOWN]				Move to next instrument
 [LEFT]				Move to previous page
 [RIGHT]				Move to next page
 [SPACE]/[ENTER]		<b>[Duplicate]</b> Select the current instrument as default
 [0..9]/[A..V]		Set the corresponding instrument as default

```

## <a name='instrument-editor'></a>Instrument Editor

```
 [ESC]				Exit instrument editor
 [F5]				Open instrument file dialog
 [TAB] or [CTRL]+[I]	"<b>[Duplicate]</b> Go to the instrument selection menu
 [CTRL]+[L]			Set macro length
 [CTRL]+[R]			Set macro restart/loop position
 [CTRL]+[D]			Set instrument name
 [CTRL]+[O]			Set octave (used for keyjazz mode)
 [CTRL]+[UP]			Select next instrument
 [CTRL]+[DOWN]		Select previous instrument
 [CTRL]+[T]			Select playback chip (keyjazz mode)
 [CTRL]+[F]			Jump to waveform editor", 		 	SCC
 [CTRL]+[W]			Set waveform",					 	SCC
 [CTRL]+[LEFT]		Select previous waveform", 	 	SCC
 [CTRL]+[RIGHT]		Select next waveform", 		 	SCC
 [CTRL]+[F]			Jump to FM instrument editor",	 	FM
 [CTRL]+[W]			Open FM instrument dialog", 	 	FM
 [CTRL]+[LEFT]		Select previous FM instrument", 	FM
 [CTRL]+[RIGHT]		Select next FM instrument",	 	FM
```

### <a name='macro-editor'></a>Macro Editor

```
 [CTRL]+[C]			Copy instrument
 [CTRL]+[V]			Paste instrument
 [R]					Set restart/loop position
 [T]					Toggle tone output
 [N]					Toggle noise output
 [V]					<b>[?]</b> Toggle voice", 			FM
 [-]					Set the deviation type to 'subtract' for the current value at the cursor (tone,noise or volume) for the current macro row
 [+]					Set the deviation type to 'add' for the current value at the cursor (tone,noise or volume) for the current macro row
 [_]/[=]				Set the deviation type to 'absolute' for the current value at the cursor (tone,noise or volume) for the current macro row
```

### <a name='waveform-editor'></a>Waveform Editor
```
 [ESC]				Exit waveform editor
 <cursor keys up/down>","Increase/decrease the current waveform column in steps of 8
 [SHIFT]+<cursor keys up/down>","Increase/decrease the current waveform column in steps of 1
 [CTRL]+[C]			Copy waveform
 [CTRL]+[V]			Paste waveform
```

### <a name='voice-editor'></a>Voice Editor
```
 [ESC]				Exit voice editor
 [UP]/[DOWN]			Select FM parameter
 [LEFT]/[RIGHT]		Set FM parameter
```

### <a name='fm-instrument-dialog'></a>FM Instrument Dialog
```
 [ESC]				Exit dialog
 [UP]				Move to previous instrument
 [DOWN]				Move to next instrument
 [LEFT]	 			Move to previous category
 [RIGHT]	 		Move to next category
 [ENTER]				Select instrument
```

## <a name='drum-editor'></a>Drum Editor
```
 [ESC]				Exit drum editor
 [B]					Toggle basedrum
 [S]					Toggle snare
 [T]					Toggle tom
 [C]					Toggle cymbal
 [H]					Toggle hi-hat
 [ENTER]				Toggle percussion bit
```

