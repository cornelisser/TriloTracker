<a href="trilotracker.md">< back</a>

# Instrument Editor
Default all instruments are empty (no sound). At first it might be a little confusing but once you are used to it it will take little effort to create your own instruments.


## Macro 
A macro step is built up like this:


TTSCC | TTFM | TTSMS
---------|----------|---------
 ` r ss TNW fFFF nNN vV` | ` r ss TNV fFFF vV nNN L ` |  `r ss TNV fFFF N X vV` 

 
Column type | Description | Values
----------|-------------|---------
| r | Restart column. The [R] indicator marks the loop position.|
| ss | Macro step number.| $00 - $1f (32 steps)
| T | Tone enabled/disabled.| 'T'(enabled) or 't'
| N | Noise enabled/disabled.| 'N'(enabled) or 'n'
| W | Waveform link. (see note below)| 'W'(enabled) or 'w'.
| V | FM Voice link. (see note below)| 'V'(enabled) or 'v'.
| f | Tone (frequency) deviation type .| '+' or '-'
| FFF | Tone change in addition to the previous macro step.| $000-$fff (4096 steps)
| n | Noise deviation type.| '_', '+' or '-'
| NN | Noise change in addition to the previous macro step(+/-) or absolute(_).| $00-$1f (32 steps)
| NN | In case of W enabled waveform link| $00-$1F 
| N | Noise value (absolute) First 4 values sets the periodic noise and next 4 set white noise options. | $0-$7 (8 steps)
| L | Voice link | Voice $0-$f
| v | Volume deviation type. | '_', '+' or '-'
| V | Volume change in addition to the previous macro step (+/-) or absolute(_).| $0-$f (16 steps)
| X | Noise volume (absolute).| $0-$f (16 steps)


<red>**note:**</red> When using the waveform or voice link; Make sure to manual restore the starting voice in the first step using waveform link.

The most simple instrument macro is this (you can test a macro using the 'keyjazz' mode:<br>
```
 R 00 Tn +000 _00 _F         
```
This macro will generate a constant sound. As the tone (T) is enabled and the volume is at max. But you can make much nicer instruments using multiple macro steps.
E.g. the volume can be used set the ADSR (Attack,Decay and Sustain, Release).

The noise columns are only processed when the instrument is used in a PSG channel. Do remember that there is only 1 noise channel (the 4th PSG channel). When using multiple instruments that produce noise (noise enabled) on the same tic, only the last noise value is used.


## Waveform [TTSCC]
The waveform is only used by the SCC. Without it the SCC will not generate sound (even if the Tone is enabled). A waveform is a 32 byte sample that is played constantly (looped). Each instrument can be linked to 1 of 32 available waveform slots.

## FM voice [TTFM][TTSMS]
The FM Voice is only used by the OPLL. Next to the default 15 HW voices there are a set of software voice available. The last 16 voices are customs voices. These voices can be created/edited and will be saved. 

## Filedialog
With `[F5]` the instrument file dialog is opened. Here you can load/save instruments, macro's,  waveforms and custom voices.