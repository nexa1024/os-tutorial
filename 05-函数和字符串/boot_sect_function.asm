; 功能: 演示函数调用和字符串打印
; 编译: nasm -f bin boot_sect_function.asm -o boot_sect_function.bin
; 运行: qemu-system-x86_64 boot_sect_function.bin
; 预期输出:
;   Hello OS!
;   Welcome to OS development!

[org 0x7c00]

; ===== 初始化 BIOS 显示功能 =====
mov ah, 0x0e

; ===== 调用函数打印字符串 =====
mov si, hello_msg    ; 参数：si 指向字符串
call print_string    ; 调用打印函数

mov si, newline      ; 打印换行
call print_string

mov si, world_msg    ; 打印另一条消息
call print_string

mov si, newline      ; 再打印一个换行
call print_string

; ===== 程序结束 =====
jmp $

; ============================================
; 函数：print_string
; 功能: 打印以 0 结尾的字符串
; 输入: si = 字符串地址
; 输出: 无
; 破坏: ax, si
; ============================================
print_string:
    push si           ; 保存 si（调用者保存寄存器）
                     ; 因为函数内会修改 si

.loop:
    mov al, [si]     ; 读取当前字符
    cmp al, 0        ; 检查是否为结尾
    je .done         ; 如果是 0，结束

    int 0x10         ; 打印字符

    inc si           ; 移动到下一个字符
    jmp .loop        ; 继续循环

.done:
    pop si           ; 恢复 si
    ret              ; 返回调用者

; ===== 数据段 =====
hello_msg: db 'Hello OS!', 0
newline:   db 13, 10, 0     ; CR + LF + NULL
world_msg: db 'Welcome to OS development!', 0

; ===== 引导扇区填充 =====
times 510-($-$$) db 0
dw 0xaa55
