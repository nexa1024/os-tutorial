# 函数和字符串 - 代码组织与复用

> 从零开始编写操作系统 - 第五章

## 开始之前你可能需要 Google 了解的概念

**function, call, ret, label, string, loop**

## 目的

学会编写汇编函数，掌握字符串处理技巧，理解代码复用的基础

---

## 🌟 支持一下

如果这个教程对你有帮助，欢迎到 GitHub 项目点个 star 支持：

⭐ [github.com/nexa1024/os-tutorial](https://github.com/nexa1024/os-tutorial)

你的 star 是我继续更新的动力！谢谢 🙏

---

## 📚 理论知识

在学习本章代码之前，建议先阅读以下理论知识：

| 文档 | 内容 |
|------|------|
| [函数基础详解 →](https://github.com/nexa1024/os-tutorial/blob/main/05-函数和字符串/function-basics.md) | 什么是函数、call/ret 机制、栈帧结构 |

---

## 汇编中的函数

### 什么是函数？

在高级语言中，我们这样定义函数：
```c
void print_string(char* str) {
    // 打印字符串
}
```

在汇编中，函数本质上就是**一段带标签的代码**：
```nasm
print_string:
    ; 函数代码
    ret
```

### call 和 ret 指令

| 指令 | 作用 | 等价操作 |
|------|------|----------|
| `call label` | 调用函数 | `push ip` + `jmp label` |
| `ret` | 返回 | `pop ip` |

**执行流程：**
```
call print_string:
    1. 将返回地址压栈
    2. 跳转到 print_string

ret:
    1. 从栈中弹出返回地址
    2. 跳转到返回地址
```

---

## 参数传递方式

### 方式一：通过寄存器传递（简单快速）

```nasm
; 调用：将字符串地址放入 si
mov si, message
call print_string

; 函数：从 si 读取参数
print_string:
    mov al, [si]
    ; ...
    ret
```

### 方式二：通过栈传递（正规但复杂）

```nasm
; 调用：参数压栈后调用
push si
call print_string
add sp, 2  ; 清理参数

; 函数：从栈读取参数
print_string:
    mov bp, sp
    mov si, [bp+2]  ; 读取参数
    ; ...
    ret
```

**在引导扇区阶段，我们主要使用寄存器传递参数**，因为这种方式简单直接。

---

## 代码示例

### 示例 1：字符串处理函数

**文件：** `boot_sect_string.asm`

```nasm
; 功能: 演示字符串长度计算和字符串处理
; 编译: nasm -f bin boot_sect_string.asm -o boot_sect_string.bin
; 运行: qemu-system-x86_64 boot_sect_string.bin
; 预期输出: Length: 11

[org 0x7c00]

; ===== 初始化 BIOS 显示功能 =====
mov ah, 0x0e

; ===== 计算字符串长度 =====
mov si, message      ; si 指向字符串
call string_length   ; 调用函数计算长度
                     ; 返回后 cx 中存储长度

; ===== 打印结果 =====
; 由于我们只能打印字符，需要手动将数字转换为字符
; 这里简化处理，只打印长度个 'X' 来表示
mov cx, 0            ; 清空 cx（用于计数）
mov si, message      ; 重新指向字符串
call string_length   ; 再次调用获取长度

; 将长度（cx）转换为字符打印
; 注意：这里简单处理，长度不能超过 9
add cl, '0'          ; 将数字转换为 ASCII 字符
mov al, cl
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

; ===== 数据段 =====
message: db 'Hello OS!', 0

; ===== 引导扇区填充 =====
times 510-($-$$) db 0
dw 0xaa55
```

---

### 示例 2：打印字符串函数

**文件：** `boot_sect_function.asm`

```nasm
; 功能: 演示函数调用和字符串打印
; 编译: nasm -f bin boot_sect_function.asm -o boot_sect_function.bin
; 运行: qemu-system-x86_64 boot_sect_function.bin
; 预期输出: Hello OS!

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
```

**编译与运行：**
```powershell
nasm -f bin boot_sect_function.asm -o boot_sect_function.bin
qemu-system-x86_64 boot_sect_function.bin
```

---

### 示例 3：字符串比较函数

**文件：** `boot_sect_strcmp.asm`

```nasm
; 功能: 演示字符串比较
; 编译: nasm -f bin boot_sect_strcmp.asm -o boot_sect_strcmp.bin
; 运行: qemu-system-x86_64 boot_sect_strcmp.bin

[org 0x7c00]

; ===== 初始化 =====
mov ah, 0x0e

; ===== 比较相同的字符串 =====
mov si, str1
mov di, str2
call strcmp

; 打印结果（ax = 0 表示相同）
cmp ax, 0
je .same1
mov al, 'N'
jmp .print1
.same1:
    mov al, 'Y'
.print1:
    int 0x10

; ===== 比较不同的字符串 =====
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
```

---

## 标签命名规范

### 局部标签（以 . 开头）

```nasm
print_string:
.loop:              ; 局部标签，属于 print_string
    ; ...
    jmp .loop       ; 只能在函数内跳转
.done:
    ret
```

**优点：**
- 避免标签名冲突
- 代码结构更清晰
- 可以在不同函数中使用相同的局部标签名

### 全局标签

```nasm
print_string:       ; 全局标签
start:              ; 全局标签
```

---

## 函数设计规范

### 寄存器约定（简化版）

| 寄存器 | 说明 | 谁负责保存 |
|--------|------|-----------|
| `ax, cx, dx` | 临时寄存器 | 调用者保存（如果需要） |
| `si, di, bp` | 保留寄存器 | 被调用者保存 |

### 函数注释模板

```nasm
; ============================================
; 函数：function_name
; 功能: 简要描述函数功能
; 输入: 寄存器/内存 = 参数说明
; 输出: 寄存器 = 返回值说明
; 破坏: 列出会被修改的寄存器
; ============================================
function_name:
    ; 函数体
    ret
```

---

## 字符串操作技巧

### 字符串在内存中的表示

```
地址:    0x7E00  0x7E01  0x7E02  0x7E03  0x7E04  0x7E05  0x7E06  0x7E07  0x7E08
内容:      'H'     'e'     'l'     'l'     'o'     '!'      0
           ↑
          si 指向这里
```

### 常用字符串操作模式

```nasm
; 遍历字符串
mov si, string
.loop:
    mov al, [si]
    cmp al, 0
    je .done
    ; 处理字符
    inc si
    jmp .loop
.done:

; 字符串长度
mov cx, 0
mov si, string
.loop:
    mov al, [si]
    cmp al, 0
    je .done
    inc cx
    inc si
    jmp .loop
.done:
```

---

## 常见问题

### Q: call 和 jmp 有什么区别？
**A:**
- `jmp` 是无条件跳转，不保存返回地址
- `call` 会先将返回地址压栈，再跳转，配合 `ret` 使用

### Q: ret 一定要配对 call 吗？
**A:** 是的。`ret` 从栈中弹出返回地址，如果没有 `call` 配对，会跳到错误的地址。

### Q: 为什么函数内要 push/pop 寄存器？
**A:** 函数可能会修改寄存器的值，调用者可能需要这些值，所以需要保存和恢复。

### Q: 局部标签和全局标签有什么区别？
**A:**
- 全局标签：可以在整个文件中访问
- 局部标签（以 `.` 开头）：只能在所属的函数/范围内访问

### Q: 如何传递多个参数？
**A:** 可以使用多个寄存器（si, di, cx, dx）或通过栈传递。

---

## 练习

1. 编写一个 `string_copy` 函数，复制字符串
2. 编写一个 `string_concat` 函数，连接两个字符串
3. 编写一个 `to_upper` 函数，将小写字母转为大写
4. 实现一个简单的字符串查找函数

---

## 代码文件列表

| 文件 | 描述 |
|------|------|
| `boot_sect_string.asm` | 字符串长度计算示例 |
| `boot_sect_function.asm` | 函数调用和字符串打印 |
| `boot_sect_strcmp.asm` | 字符串比较示例 |

---

## 汇编指令说明

### 新指令

| 指令 | 语法 | 说明 |
|------|------|------|
| `call` | `call label` | 调用函数：压入返回地址并跳转 |
| `ret` | `ret` | 返回：弹出返回地址并跳转 |
| `push` | `push reg16` | 压栈：保存寄存器值 |
| `pop` | `pop reg16` | 出栈：恢复寄存器值 |

### 标签

| 类型 | 语法 | 作用域 |
|------|------|--------|
| 全局标签 | `label:` | 整个文件 |
| 局部标签 | `.label:` | 当前函数 |

---

## 下一章

在下一章中，我们将学习**内存段管理**，理解 x86 的分段内存模型！

---

## 参考资源

- [函数基础详解](https://github.com/nexa1024/os-tutorial/blob/main/05-函数和字符串/function-basics.md)
- [os-tutorial 原仓库](https://github.com/cfenollosa/os-tutorial)
- [os-tutorial 中文版](https://github.com/ruiers/os-tutorial-cn)
- [x86 Assembly - Wikibooks](https://en.wikibooks.org/wiki/X86_Assembly)
