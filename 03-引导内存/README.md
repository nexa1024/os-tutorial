# 引导内存 - 内存寻址与引导扇区偏移

> 从零开始编写操作系统 - 第三章

## 开始之前你可能需要 Google 了解的概念

**memory offsets, pointers**

## 目的

理解 BIOS 如何将引导扇区加载到内存，以及如何正确访问内存中的数据

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
| [内存偏移详解 →](https://github.com/nexa1024/os-tutorial/blob/main/03-引导内存/memory-offsets.md) | 什么是偏移、引导扇区 0x7C00、org 指令作用 |
| [指针详解 →](https://github.com/nexa1024/os-tutorial/blob/main/03-引导内存/pointers.md) | 指针概念、直接/间接寻址、方括号含义 |

---

## 内存布局

### BIOS 内存布局图

BIOS 启动时，会将引导扇区（512 字节）加载到内存地址 `0x7C00` 处：

```
内存地址          内容                    大小
─────────────────────────────────────────────
0x0000           中断向量表 (IVT)        1KB
0x0400           BIOS 数据区             256B
...
0x7C00           ← 引导扇区加载位置      512B
0x7E00           引导扇区结束
...
0x9FC00           可用内存结束            640KB
```

### 为什么是 0x7C00？

这是历史原因：
- 早期 PC 有 32KB 内存（0x0000-0x7FFF）
- BIOS 需要空间存放自己（约 8KB）
- 引导扇区放在内存末尾附近（0x7C00）
- 之后加载操作系统到 0x7E00

这个地址成为标准，一直保留到现在。

---

## 直接寻址 vs 间接寻址

### 两种寻址方式

```nasm
; 方式 1：直接寻址 - 获取标签的地址值
mov al, the_secret     ; al = the_secret 的内存地址
                       ; 结果：al 中存的是地址，不是 'X'

; 方式 2：间接寻址 - 获取标签指向的内容
mov al, [the_secret]   ; al = the_secret 地址处存储的值
                       ; 结果：al 中存的是 'X'
```

### 图示理解

```
内存地址     内容
─────────────────────────
0x7C00     ...代码...
0x7C2D     the_secret: db "X"  ← 'X' 存储在这里

直接寻址: mov al, the_secret
         ┌─────────┐
al =     │ 0x7C2D  │  ← 获取地址
         └─────────┘

间接寻址: mov al, [the_secret]
         ┌─────────┐
al =     │   'X'   │  ← 获取内容
         └─────────┘
```

---

## 代码示例

### 示例 1：4 种内存访问方式对比

**文件：** `boot_sect_memory.asm`

这个程序演示 4 种不同的内存访问方式，只有 **方式 3 和 4** 能正确打印 'X'：

```nasm
; 功能: 演示 4 种不同的内存访问方式
; 编译: nasm -f bin boot_sect_memory.asm -o boot_sect_memory.bin
; 运行: qemu-system-x86_64 boot_sect_memory.bin
; 预期输出: 1[2¢3X4X

; ===== 设置 BIOS 显示功能 =====
mov ah, 0x0e        ; BIOS int 0x10, ah=0x0e = 显示字符模式

; ============================================
; 尝试 1：直接获取标签（错误）
; ============================================
; 问题：mov al, the_secret 获取的是标签的地址值
;       而不是该地址处存储的内容
; 结果：会打印出地址值，而不是 'X'
mov al, '1'
int 0x10            ; 打印 '1'
mov al, the_secret  ; 获取 the_secret 的地址值
int 0x10            ; 打印地址值（错误！不是 'X'）

; ============================================
; 尝试 2：间接寻址但缺少偏移（错误）
; ============================================
; 问题：[the_secret] 会解引用获取内容，但地址不对
;       汇编器认为代码从 0x0000 开始
;       但 BIOS 把引导扇区加载到 0x7c00
;       所以需要加上 0x7c00 的偏移
; 结果：会打印出 0x0000 处的随机数据
mov al, '2'
int 0x10            ; 打印 '2'
mov al, [the_secret]    ; 尝试获取内容，但地址缺少 0x7c00 偏移
int 0x10            ; 打印垃圾数据（错误！）

; ============================================
; 尝试 3：手动加上 0x7c00 偏移（正确！）
; ============================================
; 正确：先获取标签地址，加上 0x7c00 偏移，再解引用
;       这样就能访问到正确的内存位置
; 注意：不能用 [ax]，因为 x86 不允许同一指令中
;       源和目标都是同一个寄存器
;       所以需要用 bx 作为中转
mov al, '3'
int 0x10            ; 打印 '3'
mov bx, the_secret  ; 获取标签地址到 bx
add bx, 0x7c00      ; 加上 BIOS 加载偏移
mov al, [bx]        ; 解引用获取内容
int 0x10            ; 打印 'X'（正确！）

; ============================================
; 尝试 4：直接硬编码地址（正确但不实用）
; ============================================
; 正确：直接使用 0x7c2d（the_secret 的实际地址）
; 问题：每次修改代码都要重新计算偏移量
;       可以用 xxd boot_sect_memory.bin 查看 'X' 在第几个字节
;       不推荐这种方式
mov al, '4'
int 0x10            ; 打印 '4'
mov al, [0x7c2d]    ; 直接硬编码地址
int 0x10            ; 打印 'X'（正确但不推荐）

; ===== 程序结束 =====
jmp $               ; 无限循环，程序停在这里

; ===== 数据段 =====
the_secret:
    db "X"          ; 存储 'X' 字符（ASCII 0x58）

; ===== 引导扇区填充 =====
times 510-($-$$) db 0
dw 0xaa55
```

**编译与运行：**
```powershell
nasm -f bin boot_sect_memory.asm -o boot_sect_memory.bin
qemu-system-x86_64 boot_sect_memory.bin
```

**预期输出：** `1[2¢3X4X`（1 和 2 后面是乱码，3 和 4 后面是正确的 X）

---

### 示例 2：使用 org 指令简化代码

**文件：** `boot_sect_memory_org.asm`

使用 `[org 0x7c00]` 指令，让汇编器自动处理地址偏移：

```nasm
; 功能: 使用 org 指令自动处理内存偏移
; 编译: nasm -f bin boot_sect_memory_org.asm -o boot_sect_memory_org.bin
; 运行: qemu-system-x86_64 boot_sect_memory_org.bin

; ===== 告诉汇编器代码加载地址 =====
[org 0x7c00]        ; 告诉 NASM：这段代码会被加载到 0x7c00
                    ; 所有标签地址都会自动加上这个偏移

mov ah, 0x0e        ; 设置 BIOS 显示功能

; ============================================
; 尝试 1：直接获取标签（仍然错误）
; ============================================
; 问题：即使有 org，mov al, the_secret 还是获取地址
;       不是内容，所以仍然错误
mov al, '1'
int 0x10
mov al, the_secret  ; 获取地址（不是内容）
int 0x10            ; 打印地址值（错误）

; ============================================
; 尝试 2：间接寻址（现在正确了！）
; ============================================
; 正确：有了 org 后，[the_secret] 会自动使用正确的地址
;       the_secret 的实际地址 = 标签偏移 + 0x7c00
;       这是推荐的标准写法！
mov al, '2'
int 0x10
mov al, [the_secret]    ; 解引用获取内容（org 已处理偏移）
int 0x10            ; 打印 'X'（正确！）

; ============================================
; 尝试 3：重复加偏移（错误）
; ============================================
; 问题：org 已经自动加了 0x7c00，我们又手动加了一次
;       相当于加了两次偏移，地址错了
mov al, '3'
int 0x10
mov bx, the_secret  ; 获取地址（org 已加偏移）
add bx, 0x7c00      ; 又加了一次偏移（错误！）
mov al, [bx]
int 0x10            ; 打印垃圾数据

; ============================================
; 尝试 4：直接硬编码地址（仍然正确但不实用）
; ============================================
; 正确：直接使用绝对地址，不受 org 影响
; 问题：仍然不推荐
mov al, '4'
int 0x10
mov al, [0x7c2d]    ; 硬编码地址
int 0x10            ; 打印 'X'（正确但不推荐）

; ===== 程序结束 =====
jmp $

; ===== 数据段 =====
the_secret:
    db "X"

; ===== 引导扇区填充 =====
times 510-($-$$) db 0
dw 0xaa55
```

**编译与运行：**
```powershell
nasm -f bin boot_sect_memory_org.asm -o boot_sect_memory_org.bin
qemu-system-x86_64 boot_sect_memory_org.bin
```

**预期输出：** `1[2X3X4X`（2 和 4 后面是正确的 X）

---

## org 指令详解

### org 指令的作用

```nasm
[org 0x7c00]
```

`org` 告诉汇编器："这段代码会被加载到内存地址 0x7c00"。

### 有 org vs 无 org

| 写法 | 标签地址 | 访问方式 | 是否正确 |
|------|---------|---------|---------|
| 无 org | `the_secret = 0x2d` | `mov al, [0x2d]` | ❌ 错误 |
| 无 org | `the_secret = 0x2d` | `mov al, [0x2d+0x7c00]` | ✅ 正确 |
| 有 org | `the_secret = 0x7c2d` | `mov al, [the_secret]` | ✅ 正确 |
| 有 org | `the_secret = 0x7c2d` | `mov al, [the_secret+0x7c00]` | ❌ 重复偏移 |

### 推荐写法

```nasm
[org 0x7c00]

mov al, [label]     ; 简洁、正确、推荐！
```

---

## 内存地址计算

### 如何计算数据在二进制文件中的位置

```bash
# 用 xxd 查看二进制文件
xxd boot_sect_memory.bin

# 输出类似：
# 00002a0: 010e b07c 0a10 b07e 0a10 b0bb 2d00 00c7  ...|...}....-...
#         ^^
#         0x2d 就是 'X' 的位置
```

### 偏移计算公式

```
实际内存地址 = 文件偏移 + 0x7c00
```

---

## 编译与运行

### Windows 平台

```powershell
# 编译
nasm -f bin boot_sect_memory.asm -o boot_sect_memory.bin

# 运行
qemu-system-x86_64 boot_sect_memory.bin

# 无图形模式
qemu-system-x86_64 -nographic boot_sect_memory.bin
```

### Linux/Mac 平台

```bash
# 编译
nasm -f bin boot_sect_memory.asm -o boot_sect_memory.bin

# 运行
qemu boot_sect_memory.bin
```

---

## 预期结果

### boot_sect_memory.bin

屏幕显示：`1[2¢3X4X`
- `1` 后面是乱码（直接打印地址值）
- `2` 后面是乱码（访问错误地址）
- `3` 后面是 `X`（正确！）
- `4` 后面是 `X`（正确！）

### boot_sect_memory_org.bin

屏幕显示：`1[2X3X4X`
- `1` 后面是乱码（直接打印地址值）
- `2` 后面是 `X`（正确！org 自动处理偏移）
- `3` 后面是乱码（重复加偏移）
- `4` 后面是 `X`（正确！）

---

## 常见问题

### Q: 为什么引导扇区必须在 0x7C00？
**A:** 这是 BIOS 规范。早期 PC 的内存布局决定了这个地址，一直保留到现在作为标准。

### Q: 不用 org 指令可以吗？
**A:** 可以，但需要手动在每个标签访问时加 0x7c00 偏移，很麻烦且容易出错。

### Q: [label] 和 label 有什么区别？
**A:** `label` 是标签的地址值，`[label]` 是该地址处存储的内容（类似指针解引用）。

### Q: 为什么不能用 mov al, [ax]？
**A:** x86 架构不允许同一指令中源和目标使用同一个寄存器作为内存地址，需要用 bx、si、di 等寄存器。

### Q: 如何查看数据在二进制文件中的位置？
**A:** 使用 `xxd file.bin` 或 `hexdump -C file.bin` 查看。

---

## 练习

1. 在 boot_sect_memory.asm 中添加一个字符串，尝试打印它
2. 计算你自己代码中 'X' 的偏移量（用 xxd 验证）
3. 尝试不使用 org 指令，手动加偏移访问数据
4. 编写一个程序，打印内存中多个不同的字符

---

## 代码文件列表

| 文件 | 描述 |
|------|------|
| `boot_sect_memory.asm` | 基础示例：演示 4 种内存访问方式，理解偏移问题 |
| `boot_sect_memory_org.asm` | 进阶示例：使用 org 指令自动处理偏移 |

---

## 汇编指令说明

### 新指令

| 指令 | 全称 | 说明 |
|------|------|------|
| `add` | Add | 加法运算 |
| `org` | Origin | 设置代码起始地址（伪指令） |

### 寻址方式

| 方式 | 语法 | 说明 |
|------|------|------|
| 立即数 | `mov al, 5` | 直接使用数值 |
| 寄存器 | `mov al, bl` | 使用寄存器值 |
| 直接寻址 | `mov al, [0x7c00]` | 访问指定内存地址 |
| 寄存器间接 | `mov al, [bx]` | 使用寄存器作为地址指针 |
| 标签直接 | `mov al, label` | 获取标签地址值 |
| 标签间接 | `mov al, [label]` | 获取标签指向的内容 |

### 伪指令

| 指令 | 说明 |
|------|------|
| `[org addr]` | 告诉汇编器代码加载地址 |
| `times count db 0` | 填充指定数量的字节 |

---

## 下一章

在下一章中，我们将学习**栈**的使用，理解函数调用和局部变量如何存储！

---

## 参考资源

- [os-tutorial 原仓库](https://github.com/cfenollosa/os-tutorial)
- [os-tutorial 中文版](https://github.com/ruiers/os-tutorial-cn)
- [OSDev Wiki - Memory Map](https://wiki.osdev.org/Memory_Map)
- [x86 Memory Addressing Modes](https://www.cs.virginia.edu/~evans/cs216/guides/x86.html)
