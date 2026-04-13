; 功能: 演示字符串比较
; 编译: nasm -f bin boot_sect_strcmp.asm -o boot_sect_strcmp.bin
; 运行: qemu-system-x86_64 boot_sect_strcmp.bin
; 预期输出: YY (第一个比较相同，第二个不同)

[org 0x7c00]

; ===== 初始化 =====
mov ah, 0x0e

; ===== 测试 1: 比较相同的字符串 =====
mov si, str1
mov di, str2
call strcmp

; 打印结果（ax = 0 表示相同，-1 表示不同）
cmp ax, 0
je .same1
mov al, 'N'
jmp .print1
.same1:
    mov al, 'Y'
.print1:
    int 0x10

; ===== 测试 2: 比较不同的字符串 =====
mov si, str1
mov di, str3
call strcmp

cmp ax, 0
je .same2
mov al, 'N'
jmp .print2
.same2:
    mov al, 'Y'
.print2:
    int 0x10

jmp $

; ============================================
; 函数：strcmp
; 功能: 比较两个字符串是否相同
; 输入: si = 字符串1, di = 字符串2
; 输出: ax = 0(相同) / -1(不同)
; 破坏: si, di, ax
; ============================================
strcmp:
    push si
    push di

.loop:
    mov al, [si]     ; 读取字符串1的字符
    mov bl, [di]     ; 读取字符串2的字符

    cmp al, bl       ; 比较两个字符
    jne .different   ; 不相同，返回 -1

    cmp al, 0        ; 检查是否到达结尾
    je .same         ; 两个字符串都结束，相同

    inc si
    inc di
    jmp .loop

.different:
    mov ax, -1
    jmp .done

.same:
    mov ax, 0

.done:
    pop di
    pop si
    ret

; ===== 数据段 =====
str1: db 'Hello', 0
str2: db 'Hello', 0
str3: db 'World', 0

; ===== 引导扇区填充 =====
times 510-($-$$) db 0
dw 0xaa55
