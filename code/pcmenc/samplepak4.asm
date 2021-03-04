      org   0x8000
C_PER           equ $6a*32
DEFAULT_NOTE    equ C_PER/8


      db    "P","A","K",0

samples:
      dw    period7, DEFAULT_NOTE, 0         
      dw    data7
      dw    period10, DEFAULT_NOTE, 0         
      dw    data10
      dw    period17, DEFAULT_NOTE, 0
      dw    data17
      dw    period19, DEFAULT_NOTE, 0
      dw    data19
      dw    period28, DEFAULT_NOTE, 0
      dw    data28
      dw    period32, DEFAULT_NOTE, 0
      dw    data32
      dw    period_empty, DEFAULT_NOTE, 0         
      dw    data7
      dw    period_empty, DEFAULT_NOTE, 0         
      dw    data7
      dw    period_empty, DEFAULT_NOTE, 0         
      dw    data7
      dw    period_empty, DEFAULT_NOTE, 0         
      dw    data7
      dw    period_empty, DEFAULT_NOTE, 0         
      dw    data7
      dw    period_empty, DEFAULT_NOTE, 0         
      dw    data7            
      dw    period_empty, DEFAULT_NOTE, 0         
      dw    data7
      dw    period_empty, DEFAULT_NOTE, 0         
      dw    data7
      dw    period_empty, DEFAULT_NOTE, 0         
      dw    data7    


period7:
    dw 0x0357,0x0357,0x0357,0x0357,0x0357,0x0357,0x0351,0x0351,0x0351,0x0351,0x0351,0x0357,0x0747,0x0747,0x0747
period_empty:
    dw -1 ; frame terminator 
period10:
    dw 0x015F,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB,0x02BB
    dw -1 ; frame terminator 
period17:
    dw 0x0177,0x03FF,0x03F8,0x03F8,0x03F8,0x03FF,0x03F8,0x03F8,0x03F8,0x03F0,0x03F0,0x03F8,0x03F8,0x03F8,0x03F8,0x0371,0x0371,0x03F8,0x03F8,0x03F8,0x03F8,0x03F8,0x03F0,0x03F0,0x03F8,0x04C9,0x0302,0x03F8,0x03F8
    dw -1 ; frame terminator 
period19:
    dw 0x0237,0x023B,0x0248,0x024C,0x034B,0x0357,0x0271,0x04D2,0x01EF,0x01E4,0x01DD,0x01DD,0x0351,0x01B7,0x01BB,0x0297,0x0747,0x0747,0x0747,0x0747,0x0747,0x0747,0x0747,0x0747,0x0747,0x0747
    dw -1 ; frame terminator 
period28:
    dw 0x0531,0x0531,0x0528,0x0378,0x0371,0x0371,0x05FC,0x051E,0x030E,0x0417,0x040F,0x0747
    dw -1 ; frame terminator 
period32:
    dw 0x0371,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0417,0x0747,0x0747,0x0747,0x0747
    dw -1 ; frame terminator 


data7:
    db 0x2A,0x25,0xF2,0xF4,0x0A,0x16,0xFA,0xED,0xE8,0xCE,0xDE,0x36,0x4A,0x37,0xE2,0xC5,0xF0,0x02,0xEC,0xE5,0xF3,0x1B,0x19,0x16,0x16,0xF5,0xD6,0xED,0x05,0x1C,0xDD,0xC8
    db 0xBB,0xB3,0x09,0xE9,0xDA,0x12,0x59,0x4F,0xEF,0xBF,0xF3,0xED,0xE6,0xF1,0x04,0x02,0x03,0x35,0x2B,0xF8,0xDF,0xE6,0xFA,0x22,0xFE,0xB5,0xD3,0x27,0x46,0x07,0x3A,0x2C
    db 0x52,0x7F,0xE5,0xC7,0xE7,0xE7,0xAB,0xE4,0x3C,0x35,0xF1,0x39,0x4B,0xDB,0xB8,0xEC,0x17,0x0A,0xFC,0xEC,0xBD,0xFA,0x67,0x50,0x23,0x16,0xBE,0x8B,0xDF,0x09,0xEA,0xD8
    db 0xC1,0xDB,0x3B,0x40,0xE2,0x20,0x36,0x0E,0xAF,0x2E,0x0F,0x27,0xD6,0x00,0xAD,0xD8,0x2A,0x7F,0x44,0x1C,0xDC,0xB1,0xF7,0xE9,0xF9,0xDB,0x33,0x4A,0x5E,0x0A,0xF5,0xA8
    db 0xF8,0x0A,0xEB,0x1D,0x09,0x13,0x14,0xFF,0xE8,0xC7,0xDC,0x3E,0x58,0x35,0xFA,0xC5,0xEB,0xE3,0xF5,0x18,0x03,0x15,0x4C,0x26,0xF6,0xBD,0xAE,0x0B,0x30,0x46,0x1D,0xE9
    db 0x23,0x16,0xEF,0xD1,0xC5,0x02,0x30,0x33,0x2D,0xE9,0xCA,0xE1,0x0D,0x0B,0xFC,0x07,0x15,0x1E,0x0D,0xE9,0xC3,0xEC,0x01,0x3E,0x34,0x0D,0xD0,0xE1,0xE8,0x01,0x09,0x22
    db 0xFE,0x05,0x29,0x18,0x02,0xE5,0xF5,0x0A,0xFE,0x02,0x01,0xFB,0x13,0x0D,0xED,0xF4,0xD8,0xF9,0x38,0x34,0x05,0xEC,0xE0,0xD0,0xE2,0x21,0x34,0x02,0x15,0x04,0xE5,0xDF
    db 0x09,0xEC,0xF6,0x04,0xFA,0xF7,0x18,0x09,0x04,0xEB,0xE5,0x0B,0x1E,0x0B,0x0B,0xFA,0xE4,0xD3,0xFF,0x34,0x21,0xF6,0xFC,0xF2,0xF5,0xF4,0x06,0x11,0xFA,0xE9,0x15,0x1E
    db 0x1A,0x0F,0x00,0xF3,0xFA,0x1D,0x0B,0xF2,0xE9,0xE6,0xEF,0x05,0x24,0x2B,0x0F,0xE8,0xF1,0xF9,0xFD,0xEE,0x02,0x0C,0xF0,0xF8,0x28,0x26,0xFD,0xF8,0xEA,0xE1,0xE5,0x0E
    db 0x13,0xEF,0xE2,0xD3,0xEF,0x19,0x2E,0x18,0x07,0xE8,0xF4,0x07,0x01,0xF8,0xED,0xF3,0xF2,0x16,0x25,0x22,0xEF,0xFA,0xEE,0xF1,0xF0,0x07,0x05,0x05,0xF8,0x0B,0x17,0x13
    db 0x18,0x0D,0x01,0xF8,0xF9,0x0A,0x0D,0xFB,0xE2,0xF0,0xFE,0x12,0x16,0x17,0xF5,0xF3,0xFE,0x08,0xF4,0xF9,0xF9,0xF6,0xFB,0x12,0x19,0x0D,0xFE,0xF7,0xEF,0xE6,0xF6,0x0E
    db 0x0B,0xF7,0xF1,0x00,0x04,0xF8,0x08,0x0C,0x03,0xFF,0x0C,0xFB,0xF3,0xF7,0x01,0x00,0x03,0x0C,0x0A,0x01,0xF9,0xFE,0xFB,0xFD,0xFE,0x0F,0xFD,0xF8,0xFF,0x07,0xFB,0x05
    db 0xFE,0x07,0x02,0xFA,0x03,0x00,0x04,0xFF,0xFE,0x07,0xFB,0x01,0x04,0x00,0xFE,0xFD,0x09,0xFD,0xFE,0x05,0xFE,0x02,0xFE,0x02,0x02,0xF9,0x04,0x04,0xFF,0xFD,0x01,0x05
    db 0xFE,0x03,0x01,0xFC,0x02,0xFF,0x05,0x00,0xFA,0x06,0x02,0xFE,0x01,0x02,0x01,0xFE,0x03,0x00,0xFF,0x01,0x00,0x05,0xFD,0xFF,0x04,0xFF,0x00,0x01,0x01,0xFE,0x00,0x04
    db 0x00,0x00,0xFE,0x02,0x03,0xFD,0x02,0x01,0xFF,0x02,0x01,0x01,0xFD,0x01,0x03,0x00,0x01,0xFE,0x01,0x00,0xFF,0x04,0xFE,0xFF,0x01,0x01,0x02,0xFD,0x02,0x00,0xFF,0x03
data10:
    db 0xDC,0xE2,0xF8,0x0C,0xF2,0xD6,0xE9,0x09,0x13,0x1D,0x20,0x03,0xF0,0x0A,0x24,0x1C,0x0E,0x00,0xE3,0xD6,0xF1,0x07,0xF4,0xDF,0xDF,0xDF,0xEA,0x10,0x23,0x07,0xF4,0x00
    db 0xAB,0x81,0xAE,0xC1,0xF0,0x4F,0x66,0x51,0x52,0x1A,0xB8,0xA3,0xA0,0x92,0xD8,0x30,0x42,0x5F,0x70,0x2C,0xE7,0xCB,0x93,0x83,0xC4,0xF8,0x20,0x64,0x72,0x3E,0x24,0xEC
    db 0xB1,0x8E,0xBC,0xDD,0x06,0x4D,0x64,0x43,0x32,0x08,0xB8,0xA4,0xB2,0xB3,0xE8,0x37,0x48,0x4D,0x54,0x1A,0xD5,0xC3,0xA8,0x9D,0xD5,0x10,0x29,0x56,0x61,0x2D,0x07,0xE1
    db 0xC1,0xA8,0xC2,0xE6,0x09,0x39,0x52,0x3D,0x25,0x04,0xCA,0xB2,0xBB,0xC5,0xEB,0x28,0x41,0x43,0x41,0x1B,0xE2,0xC9,0xB7,0xB0,0xD4,0x08,0x28,0x45,0x4E,0x2D,0x06,0xE3
    db 0xC9,0xB2,0xC5,0xE9,0x0D,0x31,0x49,0x39,0x20,0x01,0xD3,0xB9,0xC0,0xCE,0xEA,0x20,0x3B,0x3C,0x38,0x1D,0xEA,0xCD,0xC1,0xBA,0xD3,0x04,0x23,0x39,0x45,0x2D,0x08,0xE9
    db 0xD2,0xBD,0xC6,0xE8,0x09,0x27,0x3E,0x35,0x1D,0x05,0xDE,0xC3,0xC4,0xD4,0xEA,0x15,0x34,0x34,0x2D,0x1D,0xF1,0xD2,0xCA,0xC5,0xD6,0x01,0x1F,0x2E,0x39,0x2A,0x07,0xEA
    db 0xD5,0xC8,0xCE,0xEE,0x10,0x23,0x35,0x2F,0x16,0xFB,0xE1,0xC9,0xCA,0xDE,0xF3,0x15,0x2F,0x30,0x23,0x15,0xF0,0xD3,0xCE,0xD0,0xDE,0x04,0x22,0x2A,0x2F,0x24,0x01,0xE6
    db 0xDA,0xD2,0xD5,0xF0,0x10,0x1F,0x2C,0x29,0x13,0xF9,0xE5,0xD2,0xCF,0xE2,0xF7,0x12,0x29,0x2B,0x1D,0x10,0xF2,0xD8,0xD3,0xDA,0xE4,0x03,0x1F,0x26,0x26,0x1F,0x01,0xE6
    db 0xDC,0xDA,0xDD,0xF2,0x11,0x1D,0x25,0x24,0x10,0xF4,0xE7,0xD9,0xD6,0xE7,0xFE,0x12,0x23,0x27,0x18,0x0C,0xF5,0xDD,0xD7,0xDF,0xE9,0x03,0x1D,0x22,0x1F,0x1A,0x02,0xE7
    db 0xDF,0xDF,0xE4,0xF5,0x12,0x1C,0x1F,0x1D,0x0E,0xF3,0xE6,0xDE,0xDB,0xEB,0x03,0x12,0x1F,0x22,0x14,0x05,0xF2,0xE1,0xDB,0xE5,0xF0,0x05,0x1B,0x21,0x1A,0x13,0xFF,0xE7
    db 0xE3,0xE3,0xEA,0xF6,0x0F,0x19,0x1A,0x17,0x0C,0xF4,0xE9,0xE4,0xE2,0xED,0x05,0x10,0x19,0x1C,0x13,0x03,0xF3,0xE6,0xDF,0xE8,0xF3,0x05,0x16,0x1D,0x17,0x0F,0x00,0xEB
    db 0xE6,0xE7,0xEE,0xF8,0x0C,0x17,0x16,0x12,0x0A,0xF4,0xEA,0xE7,0xE7,0xEF,0x05,0x10,0x15,0x17,0x11,0x00,0xF2,0xEB,0xE4,0xEB,0xF7,0x06,0x12,0x19,0x14,0x0C,0xFE,0xEE
    db 0xE9,0xE9,0xF1,0xFB,0x0B,0x14,0x13,0x0E,0x07,0xF6,0xEC,0xEA,0xEC,0xF2,0x04,0x0F,0x13,0x13,0x0E,0xFF,0xF2,0xEE,0xE9,0xEC,0xFB,0x08,0x0F,0x16,0x11,0x08,0xFD,0xF0
    db 0xEC,0xEC,0xF4,0x00,0x0B,0x12,0x11,0x0B,0x05,0xF7,0xED,0xEC,0xF0,0xF5,0x05,0x0E,0x10,0x0F,0x0C,0xFF,0xF2,0xEF,0xED,0xF0,0xFC,0x09,0x0E,0x12,0x0E,0x06,0xF9,0xF2
    db 0xEF,0xEE,0xF5,0x02,0x09,0x0F,0x10,0x09,0x04,0xF7,0xF0,0xEF,0xF2,0xF7,0x05,0x0D,0x0E,0x0C,0x09,0xFF,0xF2,0xF0,0xF0,0xF2,0xFC,0x09,0x0C,0x0F,0x0D,0x05,0xF9,0xF3
    db 0xF1,0xF1,0xF6,0x02,0x08,0x0C,0x0D,0x09,0x00,0xF7,0xF2,0xF0,0xF4,0xF8,0x03,0x0B,0x0D,0x0A,0x08,0xFF,0xF3,0xF2,0xF2,0xF3,0xFC,0x09,0x0A,0x0C,0x0B,0x03,0xF7,0xF4
    db 0xF3,0xF3,0xF6,0x03,0x08,0x0B,0x0C,0x07,0xFE,0xF7,0xF3,0xF1,0xF5,0xFC,0x05,0x0A,0x0D,0x08,0x06,0xFC,0xF4,0xF3,0xF4,0xF5,0xFD,0x08,0x0A,0x09,0x09,0x02,0xF7,0xF5
    db 0xF3,0xF4,0xF7,0x03,0x08,0x09,0x09,0x06,0xFD,0xF7,0xF5,0xF3,0xF6,0xFC,0x04,0x08,0x0A,0x07,0x04,0xFB,0xF5,0xF3,0xF5,0xF7,0xFF,0x07,0x09,0x09,0x07,0x03,0xF8,0xF5
    db 0xF7,0xF6,0xFA,0x03,0x07,0x07,0x06,0x06,0xFC,0xF7,0xF6,0xF4,0xF6,0xFF,0x05,0x07,0x0A,0x06,0x04,0xFB,0xF7,0xF4,0xF6,0xF8,0xFF,0x06,0x09,0x07,0x07,0x01,0xF7,0xF6
data17:
    db 0x15,0xF1,0x08,0x1E,0x15,0xFC,0x06,0x24,0x2C,0x08,0xF1,0x00,0x0E,0x13,0xFD,0xFA,0x1D,0x13,0xFE,0xE3,0xEA,0x0F,0x1A,0x0D,0x01,0x06,0x0F,0x05,0xED,0xF5,0x17,0x27
    db 0x33,0x09,0x19,0x08,0xB2,0xBB,0xB7,0xEE,0x46,0x6F,0x5D,0x41,0xE7,0xAE,0xB5,0xB3,0xFF,0x21,0x1C,0xF7,0xC4,0xAB,0xD0,0xFB,0x4D,0x73,0x61,0x2F,0xDF,0xAB,0xA8,0xC5
    db 0x30,0xF3,0xAF,0xBF,0xB5,0xE9,0x11,0xF1,0xD7,0xC1,0xAF,0xCD,0x1E,0x3E,0x7F,0x6A,0x3B,0xF9,0xCF,0xAB,0xD4,0xEB,0xF5,0x0E,0xD5,0xB0,0xB8,0xC6,0xF3,0x5D,0x56,0x68
    db 0xBB,0xD3,0x2D,0x43,0x4E,0x4F,0xF4,0xD0,0xCB,0xC2,0xE9,0x1A,0xF9,0xF6,0xD3,0xA5,0xC0,0xDF,0x10,0x4C,0x55,0x2B,0x12,0xCF,0xB9,0xCE,0xE8,0x01,0x1E,0xF0,0xCE,0xC3
    db 0x0D,0x1F,0x02,0xE7,0xC8,0xB9,0xDF,0x10,0x40,0x59,0x4C,0x19,0xF2,0xC9,0xCC,0xE5,0x09,0x17,0x13,0xE4,0xC9,0xCC,0xD2,0x11,0x3E,0x50,0x4D,0x2A,0xE5,0xD8,0xD1,0xDE
    db 0x09,0x24,0xE2,0xE1,0xC8,0xE8,0x15,0x0E,0x0E,0xF5,0xBF,0xD2,0xE8,0x0A,0x44,0x51,0x38,0x26,0xE8,0xCA,0xE3,0xE3,0x01,0x20,0xFC,0xDF,0xDA,0xC1,0xEA,0x20,0x32,0x49
    db 0xCC,0xF1,0x16,0x29,0x48,0x36,0x13,0xF3,0xD4,0xD0,0xEE,0xF4,0x07,0x08,0xE7,0xD6,0xDC,0xE1,0x0C,0x36,0x37,0x35,0x1F,0xEC,0xD9,0xDA,0xDA,0xFE,0x0B,0xF7,0xEF,0xDD
    db 0xF7,0xFE,0xFF,0xF9,0xE4,0xDB,0xE5,0xF9,0x1B,0x32,0x2D,0x23,0x07,0xDE,0xD9,0xDB,0xE5,0x02,0x05,0xF3,0xED,0xE0,0xE4,0xFA,0x14,0x2C,0x34,0x21,0x08,0xE6,0xD6,0xDC
    db 0x1D,0x18,0xF2,0xDD,0xDE,0xE1,0xEC,0x00,0xF2,0xF0,0xEC,0xE3,0xF2,0x0C,0x1A,0x29,0x24,0x11,0xF8,0xE2,0xDA,0xE4,0xE9,0xF6,0x02,0xF4,0xEF,0xF0,0xED,0x06,0x1F,0x22
    db 0xEB,0xF0,0xF2,0x13,0x1D,0x21,0x26,0x12,0xF7,0xE9,0xDB,0xDD,0xF1,0xF0,0x00,0xFE,0xED,0xF0,0xFB,0x08,0x19,0x26,0x1C,0x19,0xFF,0xE4,0xE0,0xE2,0xE4,0xFD,0xFF,0xF4
    db 0xF4,0xDB,0xF6,0xF2,0x02,0x06,0xF1,0xFA,0x0A,0x0A,0x1E,0x22,0x12,0x0B,0xF3,0xDA,0xE1,0xE5,0xE6,0x04,0x04,0xF4,0x08,0xFA,0xFA,0x16,0x15,0x1B,0x20,0x07,0xEF,0xE9
    db 0x1E,0x13,0x00,0xF3,0xDB,0xD5,0xE8,0xEB,0xFA,0x11,0x05,0x03,0x09,0x01,0x0C,0x18,0x15,0x15,0x0B,0xED,0xE2,0xDE,0xDF,0xED,0x02,0x09,0x0E,0x0A,0x03,0x09,0x0D,0x11
    db 0x0B,0x0A,0x0C,0x08,0x0D,0x17,0x12,0x0C,0xFE,0xE9,0xDF,0xE5,0xE5,0xF8,0x0A,0x0C,0x0F,0x11,0x06,0x0B,0x0E,0x0D,0x14,0x0D,0xF9,0xEC,0xE4,0xDD,0xEB,0xF0,0x00,0x0F
    db 0xE8,0xEC,0xF1,0x00,0x12,0x0A,0x0D,0x10,0x08,0x0B,0x0D,0x08,0x0C,0x02,0xEB,0xEB,0xE5,0xE8,0xF6,0x05,0x0D,0x13,0x0E,0x0C,0x0E,0x06,0x0D,0x0C,0x06,0x02,0xF2,0xE8
    db 0x0A,0x05,0x07,0xFB,0xEB,0xEF,0xE9,0xED,0x00,0x0D,0x0E,0x15,0x0E,0x08,0x0C,0x06,0x05,0x0C,0xFF,0xF5,0xF4,0xE6,0xEC,0xF2,0xFA,0x0D,0x15,0x10,0x13,0x0E,0x05,0x0C
    db 0x02,0x05,0x0E,0x0C,0x0E,0x10,0x0C,0x07,0x06,0x01,0xFA,0xF3,0xF5,0xF8,0xF4,0xFA,0xFD,0xFF,0x02,0x07,0x0B,0x0B,0x10,0x0B,0x0B,0x0D,0x08,0xFE,0xF7,0xFE,0xF8,0xF1
    db 0xF1,0xF3,0xF2,0xF7,0xFE,0x00,0x01,0x05,0x0C,0x0D,0x0C,0x0D,0x0B,0x07,0x04,0xFD,0xF7,0xF7,0xF5,0xF0,0xF2,0xF7,0xFB,0xFC,0x01,0x06,0x0D,0x0E,0x10,0x0D,0x0C,0x07
    db 0x05,0xF8,0xF8,0xF2,0xEB,0xEE,0xEF,0xF9,0x0C,0x12,0x15,0x19,0x11,0x0E,0x0A,0x07,0x04,0xF9,0xF2,0xF0,0xEC,0xEC,0xF1,0xFC,0x0C,0x11,0x16,0x15,0x12,0x0E,0x0A,0x07
    db 0x0E,0x11,0x0E,0x09,0x09,0x07,0xFB,0xF4,0xEF,0xEA,0xEC,0xF0,0xF8,0x08,0x0E,0x12,0x11,0x10,0x0C,0x08,0x06,0x04,0xF9,0xF5,0xF1,0xEB,0xED,0xF0,0xF8,0x08,0x0F,0x12
    db 0xF4,0xF4,0x01,0x0D,0x11,0x13,0x15,0x0F,0x0A,0x0B,0x04,0x00,0xF8,0xF3,0xF1,0xF2,0xEF,0x00,0x07,0x09,0x12,0x11,0x0F,0x10,0x0D,0x06,0x0A,0x02,0xF3,0xF7,0xEF,0xF1
    db 0x00,0xFA,0xF3,0xF1,0xEE,0xF3,0xF6,0x00,0x0B,0x0C,0x0D,0x0D,0x0A,0x08,0x0B,0x08,0x06,0xF8,0xF6,0xF2,0xF4,0xF2,0xFA,0x06,0x07,0x0E,0x0E,0x0A,0x0D,0x09,0x08,0x09
    db 0x08,0x0A,0x08,0x09,0x07,0x05,0xFB,0xF5,0xF1,0xF1,0xF4,0xF5,0xFD,0x05,0x06,0x09,0x09,0x0B,0x09,0x09,0x06,0x07,0xFC,0xF4,0xF3,0xF2,0xF2,0xF9,0x05,0x05,0x0A,0x09
    db 0xFF,0xFC,0x00,0x08,0x0A,0x08,0x08,0x09,0x08,0x08,0x08,0xFC,0xF7,0xF6,0xF2,0xF3,0xF4,0xF5,0x03,0x05,0x07,0x0A,0x0A,0x08,0x0A,0x08,0x06,0x03,0xF6,0xF5,0xF4,0xF3
    db 0x06,0xFF,0xF4,0xF6,0xF3,0xF7,0x00,0xFB,0x07,0x07,0x05,0x09,0x0B,0x07,0x0C,0x09,0x06,0x03,0xF5,0xF4,0xF6,0xF5,0xF9,0x05,0x05,0x06,0x07,0x05,0x08,0x09,0x09,0x08
    db 0x07,0x09,0x08,0x09,0x07,0xFF,0xF6,0xF7,0xF3,0xF5,0xF8,0xF7,0x02,0x05,0x02,0x02,0x09,0x07,0x09,0x08,0x05,0x02,0xF7,0xF4,0xF4,0xF7,0xF6,0x00,0x05,0x04,0x04,0x04
    db 0x00,0x05,0x04,0x05,0x04,0x06,0x07,0x07,0x06,0xF7,0xF8,0xF1,0xF9,0xFF,0xFC,0x06,0x03,0x05,0x03,0x06,0x08,0x04,0x03,0xF4,0xF6,0xF7,0xFA,0x06,0x03,0x07,0xFF,0x01
    db 0x05,0x01,0xFC,0xFA,0xF6,0xFC,0xFE,0x02,0x05,0x05,0x05,0x00,0xFD,0xF7,0xF9,0xFC,0xFC,0x00,0x06,0x07,0x05,0x05,0x01,0xFA,0xFD,0xFB,0xFD,0xFE,0xFF,0x02,0x06,0x04
    db 0x00,0x05,0x04,0x04,0x05,0xFF,0xF6,0xF9,0xF5,0xF7,0xF7,0x01,0x05,0x04,0x05,0x04,0x05,0x04,0x05,0x04,0x05,0x02,0xF8,0xF5,0xF6,0xF7,0xF9,0x05,0x04,0x04,0x04,0x04
    db 0x02,0x05,0x04,0x05,0x04,0x04,0x04,0x05,0x04,0x05,0x02,0xFA,0xF8,0xF7,0xF8,0xF6,0xFD,0x05,0x04,0x05,0x04,0x04,0x04,0x04,0x05,0x04,0x05,0xFB,0xF6,0xF8,0xF7,0xF7
data19:
    db 0x4C,0x6E,0x6F,0x67,0x4F,0x16,0xD3,0xA5,0x81,0x84,0x82,0x83,0x82,0x83,0x83,0x82,0x85,0x93,0xBB,0xEE,0x1B,0x46,0x68,0x7C,0x7D,0x7D,0x7D,0x7E,0x7D,0x7D,0x74,0x6E
    db 0x8E,0x85,0x83,0x82,0x83,0x83,0x82,0x8E,0xA3,0xBE,0xD7,0xF4,0x17,0x36,0x59,0x74,0x78,0x7C,0x7E,0x7D,0x7D,0x7D,0x76,0x60,0x3F,0x23,0x07,0xF2,0xDD,0xC5,0xAA,0x9C
    db 0xA8,0xB6,0xD4,0xE6,0xFF,0x1A,0x38,0x54,0x64,0x6E,0x6E,0x68,0x60,0x5A,0x56,0x4E,0x44,0x2D,0x1B,0x14,0x05,0xF0,0xE2,0xD1,0xC0,0xAE,0xA8,0xA8,0xA4,0x9D,0x92,0x8E
    db 0x2E,0x36,0x4A,0x53,0x61,0x67,0x68,0x66,0x5F,0x54,0x44,0x35,0x2A,0x22,0x17,0x06,0xF2,0xE2,0xDB,0xCA,0xB2,0xA3,0x99,0x95,0x98,0x9A,0x9C,0xA6,0xBA,0xD3,0xE6,0x00
    db 0x08,0x11,0x19,0x1E,0x16,0xFE,0xE7,0xD7,0xD6,0xD9,0xE2,0xEC,0xF2,0x01,0x0D,0x0E,0x0D,0x0A,0x06,0xFD,0x08,0x13,0x18,0x1B,0x21,0x1F,0x15,0x01,0xEC,0xDD,0xDC,0xD8
    db 0x00,0xED,0xDD,0xCF,0xCF,0xD8,0xE9,0xFC,0x00,0x0E,0x0D,0x0C,0x0F,0x12,0x1E,0x15,0x0E,0x14,0x12,0x0F,0x06,0x02,0xFD,0xEE,0xE3,0xDC,0xDC,0xE0,0xE3,0xF9,0x07,0x10
    db 0x21,0x2C,0x1A,0x0D,0xFF,0xF0,0xE2,0xD6,0xCF,0xC8,0xC2,0xC2,0xBF,0xBC,0xC1,0xC6,0xCD,0xD7,0xE6,0xFD,0x14,0x25,0x32,0x39,0x43,0x49,0x49,0x47,0x3E,0x38,0x2A,0x23
    db 0x08,0xE0,0xD6,0xD5,0xDB,0xE9,0xE9,0xEC,0xEE,0xF9,0x1C,0x30,0x30,0x28,0x25,0x0C,0xF2,0xF0,0xEA,0xF9,0x02,0xF0,0xE7,0xE4,0xEA,0xFC,0x13,0x1A,0x1D,0x16,0x0E,0x0E
    db 0x16,0x12,0x0F,0x09,0x05,0x03,0xFD,0xF7,0xF1,0xEB,0xE9,0xE8,0xEB,0xEE,0xEF,0xF2,0xF4,0xF4,0xF7,0xFD,0xFF,0x03,0x05,0x09,0x0B,0x0A,0x0B,0x0C,0x0F,0x11,0x15,0x14
    db 0x09,0x0A,0x08,0x08,0x0A,0x0D,0x10,0x10,0x10,0x0F,0x0D,0x0B,0x07,0x05,0x07,0x06,0x01,0xFD,0xFB,0xF7,0xF5,0xF3,0xF3,0xF4,0xF4,0xF3,0xF3,0xF4,0xFA,0xFF,0xFF,0x00
    db 0xF7,0xF7,0xF8,0xFB,0xFE,0x02,0x08,0x0D,0x0E,0x0C,0x0C,0x0E,0x10,0x12,0x10,0x0E,0x0D,0x0B,0x08,0x06,0x05,0x03,0x00,0xFD,0xFC,0xFA,0xF9,0xF6,0xF4,0xF3,0xF1,0xEF
    db 0x0E,0x0F,0x10,0x0E,0x0C,0x0B,0x0B,0x08,0x06,0x05,0x03,0xFE,0xFB,0xF9,0xF8,0xF8,0xF7,0xF4,0xF3,0xF3,0xF4,0xF6,0xF7,0xFB,0xFE,0xFE,0xFE,0xFF,0x01,0x03,0x05,0x0A
    db 0xFC,0xFC,0xFB,0xF9,0xF7,0xF8,0xFC,0x03,0x08,0x07,0x08,0x04,0x02,0xFE,0xFE,0x01,0x04,0x02,0x01,0x03,0x04,0x02,0xFF,0xFE,0x00,0xFE,0xFE,0x00,0x02,0x05,0x04,0x04
    db 0x07,0x05,0x05,0x04,0x03,0x02,0x00,0xFE,0xFE,0xFD,0xFC,0xFB,0xFB,0xFB,0xFA,0xFA,0xFA,0xFB,0xFB,0xFC,0xFD,0xFF,0xFF,0xFF,0xFF,0xFE,0xFE,0x00,0x03,0x04,0x05,0x06
    db 0x01,0xFF,0xFF,0xFD,0xFD,0xFC,0xFC,0xFC,0xFC,0xFD,0xFD,0xFE,0xFF,0xFF,0x00,0x00,0x00,0x01,0x01,0x00,0x00,0x01,0x02,0x04,0x04,0x04,0x04,0x04,0x03,0x03,0x03,0x03
    db 0x04,0x02,0xFE,0xFB,0xF9,0xF6,0xF5,0xF3,0xF1,0xF2,0xF4,0xF5,0xF6,0xF9,0xFB,0xFE,0x01,0x04,0x05,0x08,0x0A,0x0C,0x0E,0x10,0x0F,0x0D,0x0C,0x09,0x05,0x02,0xFF,0xFD
    db 0x04,0xFC,0xFB,0xFB,0xFB,0xFD,0xFB,0x00,0x07,0x09,0x09,0x02,0xFC,0xFC,0x01,0xFC,0xFA,0xFC,0x04,0x0C,0x0C,0x08,0x00,0xF8,0xF7,0xFA,0xFC,0xFB,0x05,0x0B,0x0E,0x0B
    db 0xFD,0xFA,0xF6,0xF5,0xF9,0xFB,0x03,0x0B,0x12,0x0F,0x04,0xF7,0xF4,0xF7,0xF8,0xFC,0x05,0x0B,0x0E,0x09,0x01,0xF9,0xF6,0xF7,0xFE,0x03,0x06,0x0B,0x0A,0x03,0xFC,0xF9
    db 0xF9,0xF8,0x00,0x05,0x06,0x09,0x08,0x06,0xFD,0xF9,0xF9,0xFA,0xFE,0x04,0x05,0x05,0x07,0x05,0x01,0xFD,0xFB,0xFC,0xFE,0xFF,0x01,0x02,0x06,0x08,0x07,0x02,0xFF,0xFB
    db 0xFB,0xFB,0xFE,0x04,0x07,0x08,0x08,0x07,0xFF,0xFA,0xF8,0xF8,0xFC,0x04,0x07,0x0A,0x09,0x07,0xFF,0xF9,0xF6,0xFA,0xFF,0x03,0x07,0x09,0x08,0x05,0xFE,0xFA,0xF7,0xFA
    db 0xFE,0x06,0x06,0x08,0x07,0x03,0xFE,0xFC,0xFB,0xFC,0x00,0x05,0x05,0x05,0x04,0x03,0x00,0xFD,0xFF,0x02,0x02,0x03,0xFE,0xFE,0xFD,0x01,0x06,0x07,0x06,0x03,0xFD,0xF9
    db 0xFB,0xFA,0x01,0x07,0x08,0x08,0x05,0xFF,0xFA,0xF9,0xFB,0xFD,0x02,0x06,0x08,0x08,0x03,0xFE,0xFC,0xFA,0xFC,0xFF,0x02,0x05,0x07,0x08,0x05,0xFF,0xFD,0xFC,0xF9,0xFC
    db 0x01,0x03,0x06,0x07,0x07,0x05,0x02,0xFD,0xFA,0xF9,0xFA,0xFF,0x04,0x08,0x0A,0x0A,0x03,0xFC,0xF9,0xF7,0xF9,0xFD,0x06,0x09,0x0A,0x09,0x06,0xFF,0xF8,0xF5,0xF6,0xFE
    db 0x07,0x0C,0x0B,0x07,0x03,0xFC,0xF7,0xF5,0xF9,0x02,0x08,0x0B,0x09,0x05,0x00,0xFB,0xF8,0xF7,0xFA,0x03,0x09,0x09,0x08,0x05,0xFF,0xFC,0xFA,0xFB,0xFD,0x01,0x04,0x04
    db 0x06,0x04,0x01,0xFD,0xFF,0xFF,0xFE,0xFF,0x00,0x02,0x03,0x03,0x02,0x03,0x03,0x03,0xFF,0xFB,0xFC,0xFE,0x01,0x04,0x05,0x05,0x04,0x02,0xFF,0xFB,0xFB,0xFC,0x02,0x06
    db 0x05,0x06,0x04,0x02,0xFC,0xFA,0xFA,0xFD,0x04,0x05,0x05,0x05,0x04,0x02,0xFE,0xFB,0xFB,0xFD,0x02,0x06,0x06,0x06,0x03,0x00,0xFD,0xFC,0xFC,0xFE,0x02,0x04,0x03,0x03
data28:
    db 0x27,0x16,0x1A,0xF3,0x46,0x21,0x00,0x08,0x72,0x7C,0x7F,0x2A,0x04,0x24,0xBB,0xC0,0x04,0xEC,0xE5,0x6A,0x55,0x28,0xF7,0xEF,0x43,0x3A,0xA6,0xC8,0x01,0xFF,0xA1,0xD7
    db 0xC1,0xC3,0x13,0xB4,0xF3,0x3B,0x62,0x3D,0x11,0xAA,0x8D,0xDE,0xF9,0xBF,0x19,0x34,0xDB,0xD3,0xD4,0xB3,0x3B,0x13,0x2A,0x1C,0x39,0xD4,0xC7,0xE9,0xFF,0xF4,0xEE,0xB0
    db 0x3B,0xD6,0x4E,0x26,0x0E,0x3F,0xF0,0x10,0xD5,0xE3,0x4B,0xE6,0xE9,0x14,0xEA,0xFD,0xF3,0xE0,0xE8,0xAC,0x34,0xDC,0x06,0xD6,0xFE,0x17,0x03,0x38,0x0F,0xEC,0x3B,0xE3
    db 0xEE,0xF7,0x05,0xBE,0x0F,0xDD,0xD3,0xFB,0xEB,0x16,0x22,0x0C,0x31,0xE9,0x57,0xE2,0x13,0x23,0x19,0xF1,0x09,0xE3,0xF1,0xE2,0xD5,0xD3,0x1B,0xD4,0xC9,0xE3,0xCE,0x08
    db 0x1E,0xD2,0xE9,0xF7,0xEC,0x09,0x00,0x1E,0x0C,0x39,0x1C,0xED,0x0C,0xFA,0xE8,0x07,0xCB,0xF4,0xE3,0xED,0xFE,0x08,0x0A,0xF5,0xFB,0xFF,0xE6,0xE4,0xD0,0xF9,0xF1,0xF7
    db 0xE1,0xF2,0xDA,0xD7,0xF9,0xD8,0xF4,0x04,0xDF,0xD3,0xF1,0xF0,0xF2,0x02,0x00,0xF5,0x0A,0x1F,0x1F,0x36,0x09,0xED,0x06,0x0A,0x00,0x02,0xE4,0xE5,0xFD,0xFF,0xD5,0xF1
    db 0x08,0xE5,0xFE,0xE0,0xF9,0xFE,0xEC,0x02,0x04,0xE7,0xF4,0xE1,0xF7,0x0D,0xE9,0x02,0xE5,0xEF,0x03,0xE6,0xE2,0xED,0x16,0xFB,0xFA,0xF9,0xEE,0xFB,0x04,0xFE,0xDC,0xF8
    db 0xF5,0xDD,0xDE,0xE2,0xE4,0xF5,0xD8,0x00,0xEE,0xD9,0xED,0x16,0x05,0x02,0x15,0xF7,0xF2,0x0A,0x07,0xFC,0xE8,0xC7,0xE3,0xD4,0xCD,0xD0,0xF3,0xF1,0xEA,0xF0,0xF5,0xF5
    db 0xE8,0xE1,0xDF,0xD8,0xE9,0xEC,0xDB,0xED,0xDD,0xF9,0xF7,0xE8,0xEC,0xED,0xE9,0xF1,0xEE,0xF5,0xE9,0xFA,0x01,0xFA,0xFA,0xFE,0x11,0xF0,0xFC,0xE8,0xD6,0xF9,0xDF,0xEB
    db 0xF8,0xF7,0xF4,0xF8,0xDC,0xEC,0xEC,0xEC,0xF2,0xFA,0xEA,0xD2,0xE6,0xF0,0xEA,0xED,0xF1,0xE9,0xFE,0xF6,0xE9,0xF5,0xEB,0xE3,0xE4,0xEC,0xF2,0xE3,0xE7,0xEA,0xDB,0xEF
    db 0xE6,0xE6,0xE1,0xE1,0xE2,0xDC,0xE8,0xF0,0xEA,0xE7,0xE7,0xE3,0xE1,0xEC,0xEE,0xEE,0xEF,0xF8,0xF1,0xE4,0xE4,0xE8,0xF0,0xF6,0xEF,0xEE,0xE4,0xEB,0xE8,0xEC,0xF0,0xE3
    db 0xF1,0xE8,0xEF,0xE8,0xE7,0xEC,0xE2,0xE6,0xE4,0xF2,0xED,0xED,0xF3,0xEA,0xE9,0xF1,0xE4,0xEA,0xE7,0xE8,0xE6,0xE4,0xF2,0xE6,0xF3,0xEF,0xF3,0xFA,0xE7,0xF4,0xF1,0xEF
data32:
    db 0xE7,0x0A,0xAD,0x2F,0x19,0xAC,0xEC,0xD3,0xC1,0xF7,0x11,0x4A,0x10,0x3D,0x27,0x2F,0x44,0x25,0xA7,0x10,0xD5,0xB9,0xF4,0xCB,0xAF,0xB9,0x17,0x28,0x28,0x35,0x16,0x16
    db 0x2A,0xE8,0xB4,0xAD,0xBA,0x2F,0xEF,0x0E,0xFC,0xEB,0xF2,0xF9,0xCD,0x1F,0x14,0x33,0x1C,0xF6,0x17,0x10,0x34,0x61,0x03,0xD4,0xDB,0xAB,0xEB,0xF2,0x0B,0x28,0xFC,0x11
    db 0xC1,0xB7,0xDD,0x63,0x52,0x56,0x42,0x52,0xDA,0xD7,0xCF,0x09,0x13,0xC5,0xEB,0xD5,0x17,0x01,0x05,0xF9,0x07,0x09,0x13,0x2E,0x23,0x1B,0xC3,0x05,0xFA,0xE0,0xDA,0xBE
    db 0x3D,0x08,0x4B,0x25,0xE6,0x92,0xBB,0xE8,0xCD,0xE4,0x32,0x14,0x3F,0x64,0x36,0x13,0xE0,0xD4,0x25,0xDE,0x20,0xEC,0xD8,0xB8,0xB3,0xC0,0x13,0xF7,0x34,0x38,0x21,0x44
    db 0x2D,0xF8,0xD1,0x47,0x2A,0x01,0x2C,0xDA,0xC2,0x3F,0x09,0xEB,0xB5,0xCA,0x02,0xAF,0x2A,0x51,0x32,0x1D,0x1B,0xC6,0x08,0xC6,0x05,0x4E,0x0C,0x39,0xED,0xDB,0xFE,0xD5
    db 0x15,0xFA,0xEF,0xE7,0xAF,0xD6,0xE9,0x13,0x00,0xFC,0x5D,0x19,0x0D,0x5F,0xE6,0xF5,0x09,0xC2,0xAA,0xA8,0xEB,0xFF,0xF6,0x47,0x66,0x0F,0x46,0x27,0x06,0xE3,0x81,0xD8
    db 0xFE,0x15,0x01,0x33,0xFC,0xBE,0x1A,0x2F,0xEB,0x0B,0xFB,0xEC,0xC6,0xCA,0xC5,0xC6,0x18,0x47,0x2E,0x45,0x5C,0xE5,0x0B,0x0E,0xFE,0xB4,0x9D,0xB7,0xA7,0xED,0x3A,0x53
    db 0xE2,0xDC,0xE7,0xFA,0x02,0x15,0x2E,0x38,0x26,0x02,0x15,0xA2,0xD4,0x12,0x28,0x17,0x1C,0x14,0xE6,0xCE,0x01,0xE9,0xD9,0xFB,0xF0,0xEB,0x4E,0x18,0x1F,0x16,0x34,0xFD
    db 0x22,0x37,0xEE,0x0F,0x0A,0x01,0xF1,0xA7,0xB9,0xDE,0xE4,0x18,0x20,0x3A,0x41,0x01,0x23,0x1B,0xC5,0xDC,0xEC,0xD7,0x05,0xF8,0x20,0xEF,0xF7,0x17,0xE4,0xE7,0x22,0x03
    db 0xDD,0xEB,0xEE,0xE3,0xCB,0x0C,0xF7,0x3E,0x2E,0x0A,0x2C,0x04,0x0C,0xF8,0xD3,0xD9,0xD5,0xC2,0xE9,0x0E,0x27,0x3F,0x0A,0x49,0x0C,0xCE,0xEE,0x02,0xFE,0x01,0xE5,0xE1
    db 0xCD,0xD9,0xE9,0x07,0x17,0x02,0x16,0xF7,0xEB,0xF5,0xEC,0xFE,0x07,0xF1,0x0E,0xFD,0x00,0x17,0x14,0x19,0x09,0xDC,0xDD,0xDA,0xE5,0xFF,0x06,0x0E,0xFB,0x0A,0x2D,0x0B
    db 0x20,0x0F,0x2A,0x22,0x1F,0x1F,0xF2,0xED,0xF0,0xF8,0xF9,0xE1,0xFD,0xF0,0x00,0xF3,0x0F,0xF5,0x10,0xF3,0x11,0x1E,0x0D,0x03,0xE7,0xFD,0x04,0xF5,0xEE,0xEC,0xF1,0xF4
    db 0x1F,0x0D,0xE7,0xF2,0xE6,0xD9,0xF0,0xE7,0xFD,0x10,0x11,0x26,0x1C,0x06,0x00,0xED,0x04,0x03,0xFF,0x06,0xED,0xDA,0xF1,0xEA,0x09,0x08,0x06,0x20,0x17,0x09,0x0D,0x00
    db 0x03,0xF9,0x11,0x0C,0xF6,0xF6,0xF5,0x1F,0xFD,0xF8,0xFD,0xEA,0xE0,0xF5,0xF9,0x10,0x11,0xF8,0x13,0xFC,0xFB,0xFD,0xF4,0x13,0x07,0x05,0x01,0xFB,0xED,0x03,0xE4,0xF1
    db 0xF8,0xF5,0xE2,0xF8,0x05,0xEC,0x10,0x08,0x00,0x0D,0x11,0x0B,0x03,0x04,0x04,0xED,0xEC,0xFB,0xE7,0xEE,0xFF,0x02,0x11,0x0B,0x0E,0x19,0x03,0xEE,0xE5,0xEC,0xFD,0x02
    db 0x0E,0x09,0xFE,0xFE,0x07,0xFB,0xFE,0x07,0x00,0xF1,0xF6,0xEB,0xE8,0xFD,0x02,0xFF,0x16,0x14,0x10,0xFD,0x13,0x07,0xFF,0xF3,0xEA,0xDE,0xE6,0xF6,0x00,0x14,0x0F,0x18
    db 0xFE,0xF3,0xEF,0x06,0x0E,0x03,0x13,0x07,0xFA,0xEA,0xF8,0xFC,0xFE,0x07,0x10,0xFD,0xF7,0x03,0xF2,0xFE,0xF4,0xF0,0xF1,0x05,0x10,0x08,0x09,0x15,0x0A,0xFD,0xFC,0xF2
    db 0x00,0x04,0x0A,0x03,0xF6,0xEE,0xEA,0xF1,0xF0,0xF5,0x10,0x0C,0x06,0x12,0x0C,0x0A,0xFA,0xF4,0xF2,0xEF,0x00,0x07,0xF9,0x05,0x04,0xF5,0xFC,0x02,0xF7,0x06,0x01,0x0A
    db 0xF4,0xF2,0xFD,0x0C,0x0A,0x0A,0x01,0xF8,0xE9,0xF3,0x06,0x0C,0x0E,0xFC,0xFD,0xFC,0xF6,0xF7,0xFB,0x01,0x02,0x09,0x06,0x01,0xF8,0xF7,0xF2,0xFF,0x07,0x0B,0x09,0xF3
    db 0xFD,0xFE,0x09,0xFE,0xFB,0xFB,0xF9,0x00,0x03,0x0A,0x07,0xF8,0xF1,0xFA,0xFB,0x07,0x07,0x02,0xFE,0xFF,0x00,0xF5,0xF3,0xF8,0x01,0x0B,0x04,0x09,0xFD,0xF1,0xED,0xFD
    db 0x06,0x0C,0x06,0xFE,0xFA,0xF6,0xFE,0xFD,0x00,0xFD,0x01,0x08,0xFD,0x01,0xFF,0xFB,0xF6,0xFD,0x04,0x07,0xFE,0xFA,0xFD,0x04,0x02,0xFA,0xFB,0xF5,0xFB,0x07,0x06,0x08
    db 0xFC,0xF9,0xF3,0xF5,0x01,0x09,0x07,0xFF,0xFD,0x00,0xF9,0xF5,0xFB,0xFF,0x05,0x05,0x04,0x04,0xF8,0xF5,0xF5,0x02,0x05,0x08,0x04,0xF9,0xF8,0xFE,0x01,0x00,0xFF,0xFE
