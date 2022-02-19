<a href="trilotracker.md">< back</a>

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
   * [Waveform Hex-Editor](#waveform-hexeditor)
   * [Voice Editor](#voice-editor)
   * [FM Instrument Dialog](#fm-instrument-dialog)
* [Drum Editor](#drum-editor)
* [Sample Editor](#sample-editor)
<!-- vscode-markdown-toc-config
      numbering=false
      autoSave=true
      /vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->



## <a name='general'></a>General


Key(s) | Function
------- | -------
 `[']` | Edit order
 `[HOME]` | Jump to first row of pattern
 `[CTRL]`+`[HOME]` | Jump to beginning (order step 0) of song
 `[ENTER]` | Play pattern and loop
 `[F1]` | Play song from current pattern/order
 `[F1]`+`[SHIFT]` | Play song in step-mode from current pattern/order
 `[F2]` | Open instrument editor
 `[F3]` | Open drum editor [FM]
 `[F3]` | Open sample editor [SCC]
 `[F4]` | Open track manager
 `[F5]` | Open file dialog
 `[F5]`+`[SHIFT]` | Open the configuration editor
 `[CTRL]`+`[D]` | Edit order
 `[CTRL]`+`[N]` | Edit song name
 `[CTRL]`+`[B]` | Edit song author
 `[CTRL]`+`[M]` | Change the volume balance using the left/right cursor keys
 `[CTRL]`+`[I]` or `[CTRL]`+`[TAB]` | Enter the instrument list
 `[CTRL]`+`[P]` | Set current pattern number
 `[CTRL]`+`[S]` | Set song speed
 `[CTRL]`+`[O]` | Set octave
 `[CTRL]`+`[T]` | Set step visualization size
 `[CTRL]`+`[A]` | Set edit step
 `[CTRL]`+`[0..9]` | Mute/Un-mute track. '0' and '9' is for FM drums
 `[ALT]`+`[0..9]` | Solo/Un-solo track. '0' and '9' is for FM drums



## <a name='playback'></a>Playback

Key(s) | Function
------- | -------
 `[CTRL]`+`[0..8]` or `[0..8]` | Mute/Un-mute track. '0' is for FM drums
 `[ALT]`+`[0..8]` | Solo/Un-solo track. '0' is for FM drums
 `[ESC]` | Stop playback on current order and pattern position
 `[SPACE]` | Stop playback return to the order and pattern position before playback start
 `[F1]` | Return to normal playback after starting looped


## <a name='pattern-editor'></a>Pattern Editor


Key(s) | Function
------- | -------
 `[ESC]` | Reset cursor to the start of the current pattern
 | - MOVE - | 
 `[TAB]` | Move to next track
 `[SHIFT]`+`[TAB]` | Move to previous track
 `[ALT]`+`[LEFT]` | Move to previous track
 `[ALT]`+`[RIGHT]` | Move to next track
 `[ALT]`+`[UP]` | Move number of steps up
 `[ALT]`+`[DOWN]` | Move number of steps down
 `[PAGEUP]` | Move number of steps up **[EMULICIOUS]**
 `[PAGEDOWN]` | Move number of steps down **[EMULICIOUS]**
 | - SELECT - | 
 `[SHIFT]`+`[Cursor keys]` | Select
 `[SHIFT]`+`[ALT]`+`[Cursor keys]` | Select with move
 `[CTRL]`+`[Q]` | Expand selection to pattern end
 | - EDIT - | 
 `[CTRL]`+`[C]` | Copy
 `[CTRL]`+`[V]` | Paste
 `[CTRL]`+`[SHIFT]`+`[V]` | Paste (Transparent)
 `[CTRL]`+`[Z]` | Undo
 `[CTRL]`+`[Y]` | Redo
 `[INS]` | Insert row
 `[BACKSPACE]` | Delete row
 `[DEL]` | Delete value or values inside selection | 
 `[A]` | Note-Release
 `[1]` | Note-Sustain
 `[SHIFT]`+`[A]` | Note-Sustain
 `[SHIFT]`+`[1]` | Note-Release
 `[F]` | Force volume to 0 (workaround)
 `[SHIFT]` | Enter a note with 1 octave higher
 `[CTRL]`+`[,]`/`[.]` | Transpose selected notes by semitone down/up
 `[CTRL]`+`[<]`/`[>]` | Transpose selected notes by octave down/up
 | - MISC - | 
 `[SPACE]` | Toggle key-jazz mode
 `[CTRL]`+`[DOWN]` | Select previous pattern
 `[CTRL]`+`[UP]` | Select next pattern
 `[CTRL]`+`[LEFT]` | Select previous order
 `[CTRL]`+`[RIGHT]` | Select next order
 `[CTRL]`+`[0..8]` | Mute/Un-mute track
 `[ALT]`+`[0..8]` | Solo/Un-solo track
 `[NUMKEY 0..8]` | Set octave



### <a name='order-editor'></a>Order Editor

Key(s) | Function
------- | -------
 `[ESC]` | Exit order editor
 `[UP]` | Move to previous order
 `[DOWN]` | Move to next order
 `[LEFT]`/`[RIGHT]` | Set pattern number
 `[R]` | Set restart/loop position
 `[BACKSPACE]` | Delete pattern row
 `[INS]` | <b>`[?]`</b> Insert new row with pattern number + 1
 `[CTRL]`+`[INS]` | Insert a new position in the order after the last position. Inserted pattern number is the pattern number from the last order position + 1
 `[CTRL]`+`[G]` | Clone pattern



### <a name='instrument-list'></a>Instrument List

Key(s) | Function
------- | -------
 `[ESC]` | Exit instrument list
 `[UP]` | Move to previous instrument
 `[DOWN]` | Move to next instrument
 `[LEFT]` | Move to previous page
 `[RIGHT]` | Move to next page
 `[SPACE]`/`[ENTER]` | <b>`[Duplicate]`</b> Select the current instrument as default
 `[0..9]`/`[A..V]` | Set the corresponding instrument as default



## <a name='instrument-editor'></a>Instrument Editor
Key(s) | Function
------- | -------
 `[ESC]` | Exit instrument editor
 `[F5]` | Open instrument file dialog
 `[TAB]` or `[CTRL]`+`[I]` | <b>`[Duplicate]`</b> Go to the instrument selection menu
 `[CTRL]`+`[L]` | Set macro length
 `[CTRL]`+`[R]` | Set macro restart/loop position
 `[CTRL]`+`[N]` | Set instrument name
 `[CTRL]`+`[O]` | Set octave (used for key-jazz mode)
 `[CTRL]`+`[UP]` | Select next instrument
 `[CTRL]`+`[DOWN]` | Select previous instrument
 `[CTRL]`+`[T]` | Select playback chip (key-jazz mode)
 `[CTRL]`+`[F]` | Jump to waveform editor **[SCC]**
 `[CTRL]`+`[E]` | Jump to waveform hex editor **[SCC]**
 `[CTRL]`+`[W]` | Set waveform **[SCC]**
 `[CTRL]`+`[LEFT]` | Select previous waveform **[SCC]**
 `[CTRL]`+`[RIGHT]` | Select next waveform **[SCC]**
 `[CTRL]`+`[F]` | Jump to FM instrument editor **[FM]**
 `[CTRL]`+`[W]` | Open FM instrument dialog **[FM]**
 `[CTRL]`+`[LEFT]` | Select previous FM instrument **[FM]**
 `[CTRL]`+`[RIGHT]` | Select next FM instrument **[FM]**


### <a name='macro-editor'></a>Macro Editor
Key(s) | Function
------- | -------
 `[CTRL]`+`[C]` | Copy instrument
 `[CTRL]`+`[V]` | Paste instrument
 `[R]` | Set restart/loop position
 `[T]` | Toggle tone output
 `[N]` | Toggle noise output
 `[V]` | Toggle voice change **[FM]**
 `[W]` | Toggle waveform change **[SCC]**
 `[-]` | Set the deviation type to 'subtract'
 `[+]` | Set the deviation type to 'add'
 `[_]`/`[=]` | Set the deviation type to 'absolute' 


### <a name='waveform-editor'></a>Waveform Editor
Key(s) | Function
------- | -------
 `[ESC]` | Exit waveform editor
 `[UP]`/`[DOWN]` | Increase/decrease the current waveform column in steps of 8
 `[SHIFT]`+`[UP]`/`[DOWN]`| Increase/decrease the current waveform column in steps of 1
 `[CTRL]`+`[C]` | Copy waveform
 `[CTRL]`+`[V]` | Paste waveform

### <a name='waveform-hexeditor'></a>Waveform Hex-Editor
Key(s) | Function
------- | -------
 `[ESC]` | Exit hex waveform editor
 `[UP]`/`[DOWN]`/`[LEFT]`/`[RIGHT]` | Move cursor
 `[0..9]` / `[A..F]` | Input value


### <a name='voice-editor'></a>Voice Editor
Key(s) | Function
------- | -------
 `[ESC]` | Exit voice editor
 `[UP]`/`[DOWN]` | Select FM parameter
 `[LEFT]`/`[RIGHT]` | Set FM parameter


### <a name='fm-instrument-dialog'></a>FM Instrument Dialog

Key(s) | Function
------- | -------
 `[ESC]` | Exit dialog
 `[UP]` | Move to previous instrument
 `[DOWN]` | Move to next instrument
 `[LEFT]` | Move to previous category
 `[RIGHT]` | Move to next category
 `[ENTER]` | Select instrument


## <a name='drum-editor'></a>Drum Editor

Key(s) | Function
------- | -------
 `[ESC]` | Exit drum editor
 `[B]` | Toggle bass drum
 `[S]` | Toggle snare
 `[T]` | Toggle tom
 `[C]` | Toggle cymbal
 `[H]` | Toggle hi-hat
 `[ENTER]` | Toggle percussion bit
 `[CTRL]`+`[N]` | Set drum name


## <a name='sample-editor'></a>Sample Editor

Key(s) | Function
------- | -------
 `[ESC]` | Exit sample editor
 `[F5]` | Open sample file dialog
 `[CTRL]`+`[UP]/[DOWN]` | Change sample



