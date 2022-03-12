<a href="trilotracker.md">< back</a>
# Effect commands

<!-- vscode-markdown-toc -->
* [0xy - Arpeggio](#0xy---arpeggio)
* [1xy - Portamento up](#1xy---portamento-up)
* [2xy - Portamento down](#2xy---portamento-down)
* [3xy - Tone Portamento](#3xy---tone-portamento)
* [4xy - Vibrato](#4xy---vibrato)
* [5xy - Tone Portamento + Volume Slide](#5xy---tone-portamento-+-volume-slide)
* [6xy - Vibrato + Volume Slide](#6xy---vibrato-+-volume-slide)
* [7xy - Tremolo](#7xy---tremolo)
* [8xy - PSG HW Envelope Low](#8xy---psg-hw-envelope-low)
* [9xy - PSG HW Envelope High](#9xy---psg-hw-envelope-high)
* [Axy    -    Volume slide](#axy---volume-slide)
* [Bxy - SCC commands](#bxy---scc-commands)
   * [B0y - Set waveform](#b0y---set-waveform)
   * [B1y - Set waveform](#b1y---set-waveform)
   * [B3y - Duty Cycle](#b3y---duty-cycle)
   * [B50 - Soften Waveform](#b50---soften-waveform)
   * [BE0 - Reset](#be0---reset)
* [Bxy - PSG Auto Envelope](#bxy---psg-auto-envelope)
* [Cxy - SCC morph](#cxy---scc-morph)
   * [C0y-C1y Morph](#c0y-c1y-morph)
   * [CAy - LoFi Sample](#cay---lofi-sample)
   * [CC0 - Morph Carbon Copy](#cc0---morph-carbon-copy)
   * [CEx - Morph type](#cex---morph-type)
   * [CFy - Morph speed](#cfy---morph-speed)
* [Cxy - FM drum commands](#cxy---fm-drum-commands)
   * [C00 - Drum reset](#c00---drum-reset)
   * [Cxy - Drum](#cxy---drum)
* [D00 - Pattern end](#d00---pattern-end)
* [Exy - Extended commands](#exy---extended-commands)
   * [E0y - Arpeggio speed](#e0y---arpeggio-speed)
   * [E1y - Fine slide up](#e1y---fine-slide-up)
   * [E2y    -     Fine slide down](#e2y---fine-slide-down)
   * [E50    -     LEgato (Note link)](#e50---note-link)
   * [E6y    -     Track detune](#e6y---track-detune)
   * [E8y    -     Global transpose](#e8y---global-transpose)
   * [E8y    -     Tone panning](#e8y---tone-panning)
   * [E9y    -     Noise panning](#e9y---noise-panning)
   * [EBy    -     Brightness](#eby---brightness)
   * [ECy    -     Note cut delay](#ecy---note-cut-delay)
   * [EDy    -     Note delay](#edy---note-delay)
   * [EFy    -     Trigger](#efy---trigger)
* [Fxy    -    Replay Speed](#fxy---replay-speed)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

**<red>Note:</red>** *Some of the effect commands described below are only available for specific sound chips. If an effect is not supported on all chips this will be mentioned on the effect.* 

**Note:** *There are two types of effect command; primary and secondary. Only one primary effect command can be active per track. When a primary effect command is started the previous will be cancelled. Secondary effect commands do not cancel other primary or secondary effect commands.*  

## <a name='0xy---arpeggio'></a>0xy - Arpeggio 
<sup>Primary effect</sup><br>
Cycles between note, note+x halftones, note+y halftones.<br> 
When y = 0 a short arpeggio will be played. You can stop the arpeggio with 100, 200, 300, 400, etc. The speed of the arpeggio is controlled using the E0y (Arpeggio speed) effect command.   

Example:
```
 C-4 1. 047      Play arpeggio C-4, E-4, G-4
 ... .. ...  
 ... .. 0C0      Play (short) arpeggio C-4, C-5 
 ... .. ...  
 ... .. 100      Stop arpeggio 
``` 



## <a name='1xy---portamento-up'></a>1xy - Portamento up
<sup>Primary effect</sup><br>
This will slide up the pitch of the current note being played by the given step size (in xy) each tic. Values for x and y range between 1 and 255 ($1-$FF). 100 will halts the portamento.

Example:
```
 C#4 .. ...      Play a note
 ... .. 106      Portamento up in steps of 6 on each tic.
 ... .. ...      
 G-4 .. ...      New note. Portamento is reset.
 ... .. 106      Slide the new note in steps of 6 again.
 ... .. ...      
 ... .. 100      The portamento is halted. But not reset.
```


## <a name='2xy---portamento-down'></a>2xy - Portamento down
<sup>Primary effect</sup><br>
Same as portamento up bit his will slide up the pitch of the current note being played by the given step size (in xy) each tic.

## <a name='3xy---tone-portamento'></a>3xy - Tone Portamento
<sup>Primary effect</sup><br>
This command is used together with a note, and will bend the current pitch at the given step size, on each tic, towards the specified note. Use 300 to stop the portamento when needed.

Example:
```
 C-4 1. ...
 F-4 .. 305 (bend the note up towards F-4)
 ... .. ... (continue to slide up, until F-4 is reached)
```


## <a name='4xy---vibrato'></a>4xy - Vibrato
<sup>Primary effect</sup><br>
Vibrato with speed x and depth y. This command will oscillate the frequency of the current note with a sine wave. The depth value ranges from 1 to 13 ($1 - $D). Higher values are ignored. The speed x set the speed in number of tics from 1 to 15 ($1 - $F). The vibrato can be updated during the effect by using 40y (set new depth) or 4x0 (set new speed). 400 will stop the effect.

<sup>(Note: The standalone replayer only supports depths 1-8.) <sup>

Example:
```
 C-4 .. ...
 ... .. 442 Start vibrato with depth 2 and speed 4
 ... .. ... 
 ... .. 404 Update the vibrato depth to 4 and keep speed the same. 
``` 


## <a name='5xy---tone-portamento-+-volume-slide'></a>5xy - Tone Portamento + Volume Slide
<sup>Primary effect</sup><br>
This command is equivalent to Tone-Portamento and Volume Slide. (3xy + Axy). First set the Tone-Portamento.

Example:
```
 C-4 .. ...
 G-4 .. 302 Start tone portamento
 ... .. 502 Continue tone portamento and start volume slide
 ... .. ... 
```

## <a name='6xy---vibrato-+-volume-slide'></a>6xy - Vibrato + Volume Slide
<sup>Primary effect</sup><br>
This command is equivalent to Vibrato and Volume Slide. (4xy + Axy). First set the Vibrato.

Example:
```
 C-4 .. ...
 G-4 .. 424 Start tone vibrato
 ... .. 602 Continue vibrato and start volume slide
 ... .. ... 
```

## <a name='7xy---tremolo'></a>7xy - Tremolo
<sup>Primary effect</sup><br>
Tremolo with speed x and depth y. This command will oscillate the volume of the current note with a sine wave. The depth value ranges from 1 to 13 ($1 - $D). Higher values are ignored. The speed x set the speed in number of tics from 1 to 15 ($1 - $F). The vibrato can be updated during the effect by using 70y (set new depth) or 7x0 (set new speed). 700 will stop the effect.

## <a name='8xy---psg-hw-envelope-low'></a>8xy - PSG HW Envelope Low
<sup>Primary effect **[PSG: AY3-8910 only]**</sup><br>

This command sets the frequency of the lower byte of the hardware envelope register. The frequency value sets the speed of the envelope will stay in effect until changed.

This command only sets the envelope frequency and can be used in any track (even non-PSG tracks). 

## <a name='9xy---psg-hw-envelope-high'></a>9xy - PSG HW Envelope High
This command sets the frequency of the high byte of the hardware envelope register. The frequency value sets the speed of the envelope will stay in effect until changed.

This command only sets the envelope frequency and can be used in any track (even non-PSG tracks). 

## <a name='axy---volume-slide'></a>Axy    -    Volume slide
<sup>Primary effect</sup><br>

Slide up or down the current volume. The higher the value the faster the slide. Value can range from $1 to $F.
```
... .. A20    Slides up the current volume each (16-2) 14 ticks by one.
... .. A0E    Slides down the current volume each (16-14) 2 tics by one.

```

## <a name='bxy---scc-commands'></a>Bxy - SCC commands
<sup>Secondary effect **[SCC only]**</sup><br>

#### <a name='b0y---set-waveform'></a>B0y - Set waveform
Changes the current waveform into the waveform specified in y. Only waveforms $00..$0F can be used.

#### <a name='b1y---set-waveform'></a>B1y - Set waveform
Changes the current waveform into the waveform specified in y. Only waveforms $10..$1F can be used.

#### <a name='b3y---duty-cycle'></a>B3y - Duty Cycle
Generates a square waveform. The value ($0 - $f) in y defines the shape (0-50%) of the waveform to generate in steps of 3,125%.

Example:
```
 ... .. B10       Waveform 3,1%: |_______
 ... .. B17                25% : ##______
```
#### <a name='b50---soften-waveform'></a>B50 - Soften Waveform
Divides the current waveform amplitudes in halve to create a waveform with lower volume (e.g. for delay track or lower volumes)

#### <a name='be0---reset'></a>BE0 - Reset
Resets the waveform to the waveform related to the current instrument.

## <a name='bxy---psg-auto-envelope'></a>Bxy - PSG Auto Envelope
Calculates envelope register value based on the current note on the same line. x and y can be used to: x - Multiply the tone value by x. y - divide the tone value by y.

Example:
```
A-1 .. B23       Takes tone value of A-4 and 
                 multiplies with 2 and divides by 3           
```
This effect command can be used to find specific envelope tone values to set 8xy and 9xy. Value is shown in debug information. 
The stand-alone replayer does not support this effect as it takes a lot of time to calculate the values. Replace the Bxy by 8xy and 9xy effect commands.

### <a name='cxy---scc-morph'></a>Cxy - SCC morph
<sup>Secondary effect **[SCC only]**</sup><br>
Waveform morphing will morph between 2 waveforms. The morphing is done in 16 steps using variable intervals. Only 1 morph at the same time is possible. Multiple tracks can use the same morphing waveform by using the 'Morph Carbon Copy' command.
A morph will always complete in the background. 
Morph in a track is cancelled by a note, rest (-R-), instrument or Bxy effect.

#### <a name='c0y-c1y-morph'></a>C0y-C1y Morph
Morph from current waveform (set in instrument macro or by C0y or C1y) into waveform in parameter (00-1F)

#### <a name='cay---lofi-sample'></a>CAy - LoFi Sample
Play a Lo-Fi sample. If placed next to a note it will be played back at that note. In case of no note the sample is played back  using the default tone in the set in the sample data. Sample uses the track defined volume.

#### <a name='cc0---morph-carbon-copy'></a>CC0 - Morph Carbon Copy
Follow mode (Carbon C0py). The track will follow the current morph waveform.

#### <a name='cex---morph-type'></a>CEx - Morph type
Sets the morph type. 0 (default) = Start morph from current set waveform (by instrument or effect). 1 = Continue from last written waveform data to SCC.

#### <a name='cfy---morph-speed'></a>CFy - Morph speed
Sets the speed of the morphing. between the 16 steps. 0 = total time is 16 tics (CFF = 256 tics (50hz 5,12sec/ 60Hz 4,27sec)

## <a name='cxy---fm-drum-commands'></a>Cxy - FM drum commands
<sup>Secondary effect **[SCC only]**</sup><br>

**note:** _This effect only affects the FM chip drum channels. But the drum commands can be used in any track (even PSG) and will affect the FM chip drum channels._
**note:** _Only 1 drum macro can be played at the same time._

At default the drum macros are initialized as below:
```
 preset     |1|2|3|4|5|6|7|8|9|A|B|C|D|E|F| Note |
            ======================================
 bass-drum  |x| |x| | |x| |x| |x|x| |x|x| | F-3  |
 snare-drum | |x|x| | | |x|x| | | |x|x| | | A-1  |
 hi-hat     | | | |x| | | | | | |x|x|x| |x|  "   |
 cymbal     | | | | |x|x|x|x| | | | | |x|x| C-1  |
 tom        | | | | | | | | |x|x| | | |x| |  "   |

```

#### <a name='c00---drum-reset'></a>C00 - Drum reset
Resets percussion tone/volume registers to default.

#### <a name='cxy---drum'></a>Cxy - Drum 
Play the corresponding drum macro ($1-$13)



## <a name='d00---pattern-end'></a>D00 - Pattern end
<sup>Secondary effect</sup><br>
Stops playing the current pattern and continues to the next pattern.


## <a name='exy---extended-commands'></a>Exy - Extended commands
<sup>Secondary effect</sup><br>

#### <a name='e0y---arpeggio-speed'></a>E0y - Arpeggio speed
Sets the (global) speed of the Arpeggio effect (0xy). $0=fast,$f=slow

#### <a name='e1y---fine-slide-up'></a>E1y - Fine slide up
y value sets the value to slide up. This is only done once. This command is useful on higher notes for portamento or as note detune.

#### <a name='e2y---fine-slide-down'></a>E2y    -     Fine slide down
y value sets the value to slide down. This is only done once. This command is useful on higher notes for portamento or as note detune.

#### <a name='e50---note-link'></a>E50    -     Legato (Note link)
Links the note next to this command with the previous note. The instrument macro is not restarted.

#### <a name='e6y---track-detune'></a>E6y    -     Track detune
y value sets the track detune for all notes played till set differently. Values $0..$7 are positive values and values $8..$F are negative values (-1..-7)


#### <a name='e8y---global-transpose'></a>E8y    -     Global transpose
y value sets the global transpose for all notes in halve notes. Values $0..$7 are positive (0..7) values and values $8..$F are negative values (-0..-7)<br>
```
---.. E82    Will add 2 halve notes to all notes played.
---.. ...
---.. E80    Global transpose is set back to original (reset).
```

#### <a name='eby---brightness'></a>EBy    -     Brightness
[FM only]

y value changes  TL (Total Level) of the modulator up or down until the software voice number is changed. Values $1..$7 are positive values and values $9..$F are negative values (-1..-7). EB0 and EB8 will reset the brigtness changes. Brightness only works on the software voice of the YM2413. Not the hardware voices ($1-$f). And the value is valid for the all tracks/channels playing this software voice. Using this effect command on the same row multiple times will accumulate the effect.



#### <a name='ecy---note-cut-delay'></a>ECy    -     Note cut delay
y value sets the delay in ticks to wait before stopping the current note.

#### <a name='edy---note-delay'></a>EDy    -     Note delay
y value sets the delay in ticks to wait before starting the note.


#### <a name='efy---trigger'></a>EFy    -     Trigger
y value is set in the trigger variable. The trigger can be used to sync programs to the music.


## <a name='fxy---replay-speed'></a>Fxy    -    Replay Speed
Set the speed (values 2-63) to play the music data. The xy value sets the delay in ‘halve’ ticks to wait between each pattern row.

Due to the halve ticks, any odd speed number will alternate.F09 will play alternating 8 and 9 ticks.
