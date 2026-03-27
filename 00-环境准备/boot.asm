; 简单的引导程序测试
; 功能: 屏幕显示 'Hello OS!'

mov ah, 0x0e        ; BIOS 显示字符功能
mov al, 'H'         ; 字符 H
int 0x10            ; 调用 BIOS 中断

mov al, 'e'
int 0x10

mov al, 'l'
int 0x10

mov al, 'l'
int 0x10

mov al, 'o'
int 0x10

mov al, ' '
int 0x10

mov al, 'O'
int 0x10

mov al, 'S'
int 0x10

mov al, '!'
int 0x10

jmp $               ; 无限循环

; 填充到 512 字节（引导扇区大小）
times 510-($-$$) db 0
dw 0xaa55           ; 引导扇区魔数
