; boot_print_newline.asm
; 功能: 打印多行文本（带换行）
; 编译: nasm -f bin boot_print_newline.asm -o boot_print_newline.bin
; 运行: qemu-system-x86_64 boot_print_newline.bin

mov si, message     ; si 指向字符串地址

print_loop:
    mov al, [si]    ; 读取当前字符
    cmp al, 0       ; 检查是否为字符串结尾
    je end_print

    cmp al, 10      ; 检查是否为换行符 (LF = 10)
    jne print_char

    ; 处理换行：先回车(CR=13)，再换行(LF=10)
    mov ah, 0x0e
    mov al, 13      ; CR (Carriage Return) - 回到行首
    int 0x10
    mov al, 10      ; LF (Line Feed) - 换到下一行
    int 0x10
    inc si
    jmp print_loop

print_char:
    mov ah, 0x0e
    int 0x10
    inc si
    jmp print_loop

end_print:
    jmp $           ; 无限循环

; 数据段：多行文本 (10 = 换行符)
message: db 'Line 1', 10, 'Line 2', 10, 'Line 3', 0

times 510-($-$$) db 0
dw 0xaa55
