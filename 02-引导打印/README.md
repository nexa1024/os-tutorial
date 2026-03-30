# 引导打印 - BIOS 中断与屏幕显示

> 从零开始编写操作系统 - 第二章

## 开始之前你可能需要 Google 了解的概念

**interrupt, BIOS, ISR, IVT, int 0x10, cpu-registers**

## 目的

使用 BIOS 中断在屏幕上打印字符和字符串

---

## 📚 理论知识

在学习本章代码之前，建议先阅读以下理论知识：

| 文档 | 内容 |
|------|------|
| [中断机制详解 →](./interrupt-theory.md) | 什么是中断、硬件/软件中断、ISR、IVT |
| [CPU 寄存器指南 →](./cpu-registers.md) | 用大白话讲解寄存器（AX、BX、CX、DX、SI、DI...）|

---

## BIOS INT 0x10 - 视频中断

### 显示单个字符

```nasm
mov ah, 0x0e        ; BIOS 显示字符功能
mov al, 'A'         ; 字符 A
int 0x10            ; 调用 BIOS 中断
```

### 寄存器约定

| 寄存器 | 值 | 说明 |
|--------|-----|------|
| `ah` | `0x0e` | 功能号：在TTY模式下显示字符 |
| `al` | ASCII 字符 | 要显示的字符 |
| `int 0x10` | - | 调用 BIOS 视频中断 |

---

## 代码示例

### 示例 1：打印 "Hello OS!"

**文件：** `boot_print_hello.asm`

```nasm
; 功能: 屏幕显示 'Hello OS!'
; 编译: nasm -f bin boot_print_hello.asm -o boot_print_hello.bin
; 运行: qemu-system-x86_64 boot_print_hello.bin

; ===== 打印字符 =====
; BIOS INT 0x10 功能 0x0E: 在 TTY 模式下显示字符
; ah = 功能号 0x0e, al = 要显示的字符

mov ah, 0x0e        ; 设置 BIOS 功能号为 0x0e (显示字符)
mov al, 'H'         ; 将字符 'H' 放入 al 寄存器
int 0x10            ; 调用 BIOS 中断 0x10，执行打印

mov al, 'e'         ; 打印 'e' (ah 还是 0x0e，不需要重复设置)
int 0x10

mov al, 'l'         ; 打印第一个 'l'
int 0x10

mov al, 'l'         ; 打印第二个 'l'
int 0x10

mov al, 'o'         ; 打印 'o'
int 0x10

mov al, ' '         ; 打印空格
int 0x10

mov al, 'O'         ; 打印 'O'
int 0x10

mov al, 'S'         ; 打印 'S'
int 0x10

mov al, '!'         ; 打印 '!'
int 0x10

; ===== 程序结束 =====
jmp $               ; 跳转到当前行（无限循环），程序停在这里

; ===== 引导扇区填充 =====
; BIOS 要求引导扇区必须是 512 字节，且最后两字节是 0xaa55

times 510-($-$$) db 0    ; 用 0 填充剩余空间，直到 510 字节
                        ; $ = 当前地址, $$ = 节起始地址
                        ; 510-($-$$) = 计算需要填充的字节数

dw 0xaa55           ; 写入引导扇区魔数（小端序：55 aa）
```

**编译与运行：**
```powershell
nasm -f bin boot_print_hello.asm -o boot_print_hello.bin
qemu-system-x86_64 boot_print_hello.bin
```

---

### 示例 2：使用循环打印字符串

**文件：** `boot_print_loop.asm`

```nasm
; 功能: 使用循环打印字符串
; 编译: nasm -f bin boot_print_loop.asm -o boot_print_loop.bin
; 运行: qemu-system-x86_64 boot_print_loop.bin

; ===== 初始化 =====
mov si, message     ; 将字符串地址存入 si 寄存器（源索引寄存器）
                    ; si 常用于指向字符串或数组的当前位置

; ===== 打印循环 =====
print_loop:
    mov al, [si]    ; 从 si 指向的内存地址读取一个字符到 al
                    ; [] 表示内存访问，[si] 是"si 地址处的内容"

    cmp al, 0       ; 比较 al 和 0
                    ; 我们用 0 (NULL) 作为字符串结尾标记
    je end_print    ; 如果 al == 0，跳转到 end_print（je = Jump if Equal）

    ; ===== 打印当前字符 =====
    mov ah, 0x0e    ; 设置 BIOS 显示字符功能
    int 0x10        ; 调用中断打印 al 中的字符

    ; ===== 移动到下一个字符 =====
    inc si          ; si 寄存器加 1，指向下一个字符
                    ; inc = increment（加 1）

    jmp print_loop  ; 跳回 print_loop，继续处理下一个字符
                    ; jmp = jump（无条件跳转）

; ===== 程序结束 =====
end_print:
    jmp $           ; 无限循环，程序结束

; ===== 数据段 =====
message: db 'Hello from OS!', 0
                    ; db = define byte（定义字节）
                    ; 定义字符串 'Hello from OS!'，结尾的 0 是字符串结束符

; ===== 引导扇区填充 =====
times 510-($-$$) db 0
dw 0xaa55
```

---

### 示例 3：打印换行

**文件：** `boot_print_newline.asm`

```nasm
; 功能: 打印多行文本（处理换行符）
; 编译: nasm -f bin boot_print_newline.asm -o boot_print_newline.bin
; 运行: qemu-system-x86_64 boot_print_newline.bin

; ===== 初始化 =====
mov si, message     ; si 指向字符串地址

; ===== 打印循环 =====
print_loop:
    mov al, [si]    ; 读取当前字符
    cmp al, 0       ; 检查是否为字符串结尾
    je end_print    ; 如果是 0，结束打印

    ; ===== 检查是否是换行符 =====
    cmp al, 10      ; 检查 al 是否等于 10 (LF = 换行符)
    jne print_char  ; 如果不是换行符，跳转到 print_char
                    ; jne = Jump if Not Equal

    ; ===== 处理换行：先回车(CR)，再换行(LF) =====
    ; 在文本终端中，换行需要两个字符：
    ; CR (13) = 回到行首
    ; LF (10) = 移到下一行

    mov ah, 0x0e    ; 设置 BIOS 显示功能
    mov al, 13      ; 打印 CR (回车)
    int 0x10
    mov al, 10      ; 打印 LF (换行)
    int 0x10

    inc si          ; 跳过原始字符串中的换行符
    jmp print_loop  ; 继续循环

; ===== 打印普通字符 =====
print_char:
    mov ah, 0x0e    ; 设置 BIOS 显示功能
    int 0x10        ; 打印 al 中的字符

    inc si          ; 移动到下一个字符
    jmp print_loop  ; 继续循环

; ===== 程序结束 =====
end_print:
    jmp $           ; 无限循环

; ===== 数据段 =====
message: db 'Line 1', 10, 'Line 2', 10, 'Line 3', 0
                    ; 10 是换行符(LF)的 ASCII 值
                    ; 字符串会在打印时被换行处理

; ===== 引导扇区填充 =====
times 510-($-$$) db 0
dw 0xaa55
```

---

## 常见 BIOS 中断

| 中断号 | 功能 | 用途 |
|--------|------|------|
| `int 0x10` | 视频服务 | 显示字符、设置光标 |
| `int 0x13` | 磁盘服务 | 读写磁盘扇区 |
| `int 0x16` | 键盘服务 | 读取键盘输入 |
| `int 0x19` | 引导加载 | 重新引导系统 |

---

## ASCII 表速查

| 字符 | 十六进制 | 字符 | 十六进制 |
|------|---------|------|---------|
| '0'-'9' | 0x30-0x39 | 'A'-'Z' | 0x41-0x5A |
| 'a'-'z' | 0x61-0x7A | 空格 | 0x20 |
| 换行(LF) | 0x0A | 回车(CR) | 0x0D |

---

## 编译与运行

### Windows 平台

```powershell
# 编译
nasm -f bin <文件名>.asm -o <文件名>.bin

# 运行
qemu-system-x86_64 <文件名>.bin

# 无图形模式
qemu-system-x86_64 -nographic <文件名>.bin
```

### Linux/Mac 平台

```bash
# 编译
nasm -f bin <文件名>.asm -o <文件名>.bin

# 运行
qemu <文件名>.bin
```

---

## 预期结果

QEMU 窗口打开后，屏幕左上角显示：

```
Hello OS!
```

---

## 常见问题

### Q: 为什么字符显示在光标位置？
**A:** INT 0x10 功能 0x0E 会自动将光标移动到下一个位置。

### Q: 如何显示换行？
**A:** 需要先输出回车(CR, 0x0D)，再输出换行(LF, 0x0A)。

### Q: 支持哪些字符？
**A:** 支持 ASCII 字符集（0x00-0xFF）。

### Q: int 指令是硬件中断还是软件中断？
**A:** 是软件中断，由程序主动触发。

---

## 练习

1. 尝试打印你的名字
2. 编写一个子程序来打印字符串
3. 实现打印数字的功能

---

## 代码文件列表

| 文件 | 描述 |
|------|------|
| `boot_print_hello.asm` | 基础示例：逐字符打印 "Hello OS!" |
| `boot_print_loop.asm` | 进阶示例：使用循环打印字符串 |
| `boot_print_newline.asm` | 高级示例：打印多行文本（换行处理） |

---

## 汇编指令说明

### 寄存器

| 寄存器 | 全称 | 用途 |
|--------|------|------|
| `ax` | Accumulator | 累加器（通用寄存器） |
| `ah` | High byte of AX | ax 的高 8 位 |
| `al` | Low byte of AX | ax 的低 8 位 |
| `si` | Source Index | 源索引寄存器（常用于字符串操作） |

### 指令

| 指令 | 全称 | 说明 |
|------|------|------|
| `mov` | Move | 数据传送 |
| `int` | Interrupt | 调用中断 |
| `cmp` | Compare | 比较两个值 |
| `je` | Jump if Equal | 相等则跳转 |
| `jne` | Jump if Not Equal | 不相等则跳转 |
| `jmp` | Jump | 无条件跳转 |
| `inc` | Increment | 加 1 |
| `db` | Define Byte | 定义字节 |

### 特殊符号

| 符号 | 说明 |
|------|------|
| `$` | 当前地址 |
| `$$` | 当前节起始地址 |
| `times` | 重复指令 |
| `[]` | 内存访问 |

---

## 下一章

在下一章中，我们将学习如何读取 BIOS 内存信息！

---

## 🌟 支持一下

如果这个教程对你有帮助，欢迎到 GitHub 项目点个 star 支持：

⭐ [github.com/nexa1024/os-tutorial](https://github.com/nexa1024/os-tutorial)

你的 star 是我继续更新的动力！谢谢 🙏

---

## 参考资源

- [中断机制详解](./interrupt-theory.md)
- [os-tutorial 原仓库](https://github.com/cfenollosa/os-tutorial)
- [os-tutorial 中文版](https://github.com/ruiers/os-tutorial-cn)
- [INT 10h - Wikipedia](https://en.wikipedia.org/wiki/INT_10H)
