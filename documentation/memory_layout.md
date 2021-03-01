


```
            +-----------------+
  Page 0    |XXXXXXXXXXXXXXXXX| $0100
            |                 |
            |   Generic code  |
            |- - - - - - - - -+
            |Element swap code|
            +-----------------+ $4000
  Page 1    |                 |
            |   Main code     |
            |                 |
            |-  -  -  -  -  - +
            | Main swap code  |
            +-----------------+ $8000
  Page 2    |                 |
            |   Song data     |
            |                 |
            |                 |
            |                 |
            +-----------------+ $c000
  Page 3    |                 |
            |   Variables     |
            |                 |
            |                 |
            |XXXXXXXXXXXXXXXXX|  System Variables +
            +-----------------+  stack
```

## TTSCC Code layout
Generic code | Main code | Main swap code | Element swap code
---------|----------|---------|----
 main.asm| cursor.asm | replayerSCC.asm | sampleeditor.asm
 configurationRAM.asm | vdp.asm | configeditor.asm | samplebox.asm
 patternbox.asm | screen.asm |  configbox.asm | 
 trackbox.asm | clipboard.asm |  fileinsdialog.asm | macrobox.asm 
 sequencebox.asm| song.asm |filesamdialog.asm  | macroeditor.asm
 songbox.asm| keyboard.asm| | 
 patterneditor.asm | musickeyboard.asm| | 
 filedialogRAM.asm | isr.asm| | 
 filedialog.asm | mapper.asm| | 
 sccwavebox.asm | disk.asm| | 
 sccdetect.asm | compression2.asm| | 
 keyjazz.asm | vram_swapper.asm| | 
 instrumentbox.asm | replayerSCCRAM.asm| | 
 vu.asm | window.asm|| | 
 loadinstruments.asm|| | 
 editlog.asm|| | 

## TTSMS Code layout
Generic code | Main code | Main swap code | Element swap code
---------|----------|---------|----
main.asm | vpd.asm | replayerFM.asm | filedialog.asm
configurationRAM.asm | screen.asm | configeditor.asm | voicemanager.asm
patternbox.asm | clipboard.asm | configbox.asm | FMvoicebox.asm
trackbox.asm | song.asm | fileinsdialog.asm | drumeditor.asm
sequencebox.asm | keyboard.asm |  | drumeditbox.asm
songbox.asm | musickeyboard.asm |  | 
patterneditor.asm | isr.asm |   | 
filedialogRAM.asm | mapper.asm |  | 
macroeditor.asm | disk.asm |  | 
macroboxFM.asm | compression2.asm |  | 
voicemanagerRAM.asm | editlog.asm |  | 
keyjazz.asm | vram_swapper.asm |  | 
instrumentbox.asm | window.asm |  | 
vuFM.asm | replayerFMRAM.asm |  | 
loadinstruments.asm |  |  | 
cursor.asm |  |  | 
