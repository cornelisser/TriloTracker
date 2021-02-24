
<a href="trilotracker.md">< back</a>

# Drum Editor (FM)

A macro line consists out the following components:

1. Percussion bits (what percussion to trigger)
    - `B` - basedrum
    - `S` - snare
    - `T` - tom
    - `C` - cymbal
    - `H` - hi-hat
2. Basedrum channel
    - Note or relative pitch change (`-FF..+FF`)
    - `0..F` - basedrum volume
3. Hi-hat/snare channel
    - Note or relative pitch change (`-FF..+FF`)
    - `0..F` - hi-hat volume
    - `0..F` - snare volume
4. Tom/cymbal channel
    - Note or relative pitch change (`-FF..+FF`)
    - `0..F` - tom volume
    - `0..F` - cymbal volume

### Percussion bits

On each row you can set which percussion to trigger. You can use `[ENTER]` to toggle the percussion at the cursor or just type the letter of the percussion bit `[B, S, T, C, H]`. This way multiple percussion can be played at the same time as you can only play 1 drum macro at the time.

### Basedrum channel

The base drum has its own tone register and volume setting. 
You can set the tone using a note or an offset (using `-` or `+`) (which is added/subtracted from the last know tone value). 
The volume can be set to values `$1`-`$F`. 
Note: The tone and volume values are optional. If not specified any previous value will be used.

### Hi-Hat/Snare channel

Same as the base drum channel but the hi-hat and snare share the same tone value. They do have their own volume values.

### Tom/Cymbal channel

Same as hi-hat/snare channel. 
Changing the Cymbal can lead to a far better Snare. So I have been told. **[Opinion]**

<a href="img\drumeditor.png"><img src="img\drumeditor.png" width="500px"/></a>