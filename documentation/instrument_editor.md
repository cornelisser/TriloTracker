# Instrument Editor
## TTSCC (AY-3-8910 + SCC)
## TTFM (AY-3-8910 + YM2413)
## TTSMS (SN76489 + YM2413)
1. Loop
    - `R` - restart/loop position
2. Components
    - `T` - toggle tone component
    - `N` - toggle noise component
    - `V` - toggle voice link
3. Tone component
    - `-FFF..+FFF` - relative pitch offset
    - `0..F` - noise volume fixed (`_`) or relative (`+`, `-`)
4. Noise component
    - Noise type
        - `0 [pHi]` - pulse high
        - `1 [pMe]` - pulse medium
        - `2 [pLo]` - pulse low
        - `3 [pCh]` - pulse channel
        - `4 [wHi]` - white noise high
        - `5 [wMe]` - white noise medium
        - `6 [wLo]` - white noise low
        - `7 [wCh]` - white noise channel
    - `0..F` - noise volume fixed (`_`) or relative (`+`, `-`)
5. Voice link component
    - `0..F` - hardware voice number
