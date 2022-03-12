<a href="trilotracker.md">< back</a>


# TTSCC 
```
        frq not noi wav vol
|R00tnw +FF +95 +1F 1F _F xxxxx
```

```
 [HEADER]
   00 - Length                          ; length of the marco (0x00..0x1f)
   01 - Restart                         ; restart position (loop) (0x00..0x1f, 0xff = no restart)
   02 - Waveform                        ; related waveform (0..31)
 [/HEADER]
 [ROW] 0..<Length-1>                    ; each row is 4 bytes.
  +00- [  N | ND | ND | Nv | Nv | Nv | Nv | Nv ] 
  +01- [  T | TD | VD | VD | Vv | Vv | Vv | Vv ] 
  +02- [  Tv| Tv | Tv | Tv | Tv | Tv | Tv | Tv ] 
  +03- [ Wl | .. | .. | .. | Tv | Tv | Tv | Tv ]

new version:
  +03- [ Wl | .. | .. | Wv | Wv | Wv | Wv | Wv ] 
  +04- [ ND | ND | Nv | Nv | Nv | Nv | Nv | Nv ] 
 [/ROW]
```

Character | Description
------- | -------
 `N` | noise output (1=enabled).
 `T` | tone output (1=enabled).
 `ND`| noise deviation (00=base value, 10=add value, 11=subtract value).
 `TD`| tone deviation (0=add value, 1=subtract value).
 `Nv` | 5bit noise value (0x00-0x1f).
 `Tv` | 8bit tone value (0x00-0xff).
 `VD`| volume deviation (00=base value, 10=add value, 11=subtract value).
 `Vv`| 4bit volume value (0x0-0xf).
 `Wl`| waveform link (0x00-0x1f).
 new version  | 
 `Wv`| waveform value (0x00-0x1f).
 `ND`| semi-note deviation (10=base value, 00=add value, 01=subtract value, 11 = reset deviation).
 `Nv`| semi-note value (base: 0x00-0x5f, relative: 0x00-0x3f)


**note** *Noise only has effect on the PSG. Waveform only has effect on the SCC.*

# TTFM

```
        frq not noi voi vol
|R00tnw +FF +95 +1F  F _F xxxxx
```

```
 [HEADER]
   00 - Length                          ; length of the marco (0x00..0x1f)
   01 - Restart                         ; restart position (loop) (0x00..0x1f, 0xff = no restart)
   02 - Voice                           ; related voice (0..192)
 [/HEADER]
 [ROW] 0..<Length-1>                    ; each row is 4 bytes.
  +00- [  N | ND | ND | Nv | Nv | Nv | Nv | Nv ] 
  +01- [  T | TD | VD | VD | Vv | Vv | Vv | Vv ] 
  +02- [  Tv| Tv | Tv | Tv | Tv | Tv | Tv | Tv ] 
  +03- [  Vl| .. | .. | .. | Tv | Tv | Tv | Tv ]
 [/ROW]
```

{|
|`N`| noise output (1=enabled).
  `T` | tone output (1=enabled).
  `ND`| noise deviation (00=base value, 10=add value, 11=subtract value).
  `TD`| tone deviation (0=add value, 1=subtract value).
  `Nv` | 5bit noise value (0x00-0x1f).
  `Tv` | 12bit tone value (0x000-0xfff).
  `VD`| volume deviation (00=base value, 10=add value, 11=subtract value, 11 = reset deviation).
  `Vv`| 4bit volume value (0x0-0xf).
  `Vl`| FM voice link. If set the Nv value contains the voice number
|}

**note** *Noise only has effect on the PSG.Voice only has effect on the FM.*


# TTSMS
```
        frq not voi vol      noi    vol
|R00tnw +FF +95  F _F xxxxx F[XXX] F xxxxx
```


```
 [HEADER]
   00 - Length                          ; length of the marco (0x00..0x1f)
   01 - Restart                         ; restart position (loop) (0x00..0x1f, 0xff = no restart)
   02 - Voice                           ; related voice (0..192)
 [/HEADER]
 [ROW] 0..<Length-1>                    ; each row is 4 bytes.
  +00- [  N | Nt | Nt | Nt | Nv | Nv | Nv | Nv ] 
  +01- [  T | TD | VD | VD | Vv | Vv | Vv | Vv ] 
  +02- [  Tv| Tv | Tv | Tv | Tv | Tv | Tv | Tv ] 
  +03- [  Vl| .. | .. | .. | Tv | Tv | Tv | Tv ]
 [/ROW]
```

{|
|`N`| noise output (1=enabled).
  `T` | tone output (1=enabled).
  `Nt`| noise type (0 - 7).
  `TD`| 3bit tone deviation (0=add value, 1=subtract value).
  `Nv` | 4bit noise volume (0x0-0xf).
  `Tv` | 10bit tone value (0x000-0x3ff).
  `VD`| volume deviation (00=base value, 10=add value, 11=subtract value, 11 = reset deviation).
  `Vv`| 4bit volume value (0x0-0xf).
  `Vl`| FM voice link. If set the low 4bits of the noise contains the voice number
|}

**note** *Noise only has effect on the PSG.Voice only has effect on the FM.*
