; boot_print_loop.asm
; 功能: 使用循环打印字符串
; 编译: nasm -f bin boot_print_loop.asm -o boot_print_loop.bin
; 运行: qemu-system-x86_64 boot_print_loop.bin

mov si, message     ; si 指向字符串地址 (si = Source Index)

print_loop:
    mov al, [si]    ; 读取当前字符到 al 寄存器
    cmp al, 0       ; 检查是否为字符串结尾 (0 = NULL)
    je end_print    ; 如果是 0，结束打印

    mov ah, 0x0e    ; BIOS 显示字符功能
    int 0x10        ; 调用 BIOS 中断

    inc si          ; si 加 1，移动到下一个字符
    jmp print_loop  ; 继续循环

end_print:
    jmp $           ; 无限循环

; 数据段
message: db 'Hello from OS!', 0

; 填充到 512 字节
times 510-($-$$) db 0
dw 0xaa55
