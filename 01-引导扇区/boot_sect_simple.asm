; 最简单的引导扇区
; 功能: 无限循环
; 编译: nasm -f bin boot_sect_simple.asm -o boot_sect_simple.bin
; 运行: qemu-system-x86_64 boot_sect_simple.bin

loop:
    jmp loop                 ; 跳转到自身，形成无限循环

; 填充 0，使文件总大小为 510 字节
; $ = 当前地址
; $$ = 节起始地址
; 510-($-$$) = 还需要填充的字节数
times 510-($-$$) db 0

; 魔数 - BIOS 检查这 2 个字节来判断是否可引导
; 小端序: 0xaa55 存储为 55 aa
dw 0xaa55
