; 功能: 演示字符串长度计算和字符串处理
; 编译: nasm -f bin boot_sect_string.asm -o boot_sect_string.bin
; 运行: qemu-system-x86_64 boot_sect_string.bin
; 预期输出: Length: 11

[org 0x7c00]

; ===== 初始化 BIOS 显示功能 =====
mov ah, 0x0e

; ===== 打印 "Length: " =====
mov si, msg_prefix
call print_string

; ===== 计算字符串长度 =====
mov si, message      ; si 指向字符串
call string_length   ; 调用函数计算长度
                     ; 返回后 cx 中存储长度

; ===== 打印长度数字 =====
; 将 cx 中的数字转换为十进制字符打印
mov ax, cx
mov bl, 10
div bl               ; ax / 10, al = 商, ah = 余数

add al, '0'          ; 将商转为 ASCII
mov ah, 0x0e
push ax              ; 暂存十位
int 0x10
pop ax

add ah, '0'          ; 将余数转为 ASCII
mov al, ah
int 0x10

; ===== 程序结束 =====
jmp $

; ============================================
; 函数：string_length
; 功能: 计算字符串长度（以 0 结尾）
; 输入: si = 字符串地址
; 输出: cx = 字符串长度
; 破坏: ax, si
; ============================================
string_length:
    mov cx, 0        ; 计数器清零

.count_loop:
    mov al, [si]     ; 读取当前字符
    cmp al, 0        ; 检查是否为结尾
    je .done         ; 如果是 0，结束

    inc cx           ; 计数器加 1
    inc si           ; 移动到下一个字符
    jmp .count_loop  ; 继续循环

.done:
    ret              ; 返回调用者

; ============================================
; 函数：print_string
; 功能: 打印以 0 结尾的字符串
; 输入: si = 字符串地址
; 破坏: ax, si
; ============================================
print_string:
    push si

.loop:
    mov al, [si]
    cmp al, 0
    je .done
    int 0x10
    inc si
    jmp .loop

.done:
    pop si
    ret

; ===== 数据段 =====
msg_prefix: db 'Length: ', 0
message:    db 'Hello OS!', 0

; ===== 引导扇区填充 =====
times 510-($-$$) db 0
dw 0xaa55
