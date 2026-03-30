# 引导扇区

> 从零开始编写操作系统 - 第一章

## 开始之前你可能需要 Google 了解的概念

**assembler, BIOS**

## 目的

创建一个文件，让 BIOS 识别为可引导的磁盘

---

## 理论基础

### 启动流程

```
上电 → BIOS → 引导扇区 → 操作系统
```

1. 计算机上电后，首先运行主板 **BIOS** 程序
2. BIOS 不知道如何加载操作系统，所以把加载任务交给 **引导扇区**
3. 引导扇区负责加载操作系统内核

### 引导扇区规范

| 属性 | 值 |
|------|-----|
| **位置** | 磁盘第一个扇区 (cylinder 0, head 0, sector 0) |
| **大小** | 512 字节 |
| **魔数** | 最后 2 字节必须是 `0xAA55`（小端序存储为 `55 AA`） |
| **魔数位置** | 第 511-512 字节 |

> **为什么是 0xAA55？**
> 这是 BIOS 规范定义的魔数。BIOS 会检查最后两个字节是否为 `0xAA55`，如果是，则认为该磁盘是可引导的。

### 什么是魔数？

**魔数 (Magic Number)** 是指在文件或数据结构中，用于标识文件类型或格式特定位置的一组固定字节值。

#### 类比理解

| 现实类比 | 计算机中的魔数 |
|---------|---------------|
| 身份证号码 | 文件类型标识 |
| 商品条形码 | 格式验证码 |
| 封口印章 | 真实性验证 |

#### 常见文件魔数示例

| 文件类型 | 魔数（十六进制） | 位置 |
|---------|-----------------|------|
| **JPEG** | `FF D8 FF` | 文件开头 |
| **PNG** | `89 50 4E 47` | 文件开头 |
| **ZIP** | `50 4B 03 04` | 文件开头 |
| **ELF** | `7F 45 4C 46` | 文件开头 |
| **引导扇区** | `55 AA` | 文件末尾 |

#### 魔数的历史原因

引导扇区魔数 `0xAA55` 是 **IBM PC BIOS 规范** 定义的：

- **0xAA** = `10101010`（交替的 1 和 0）
- **0x55** = `01010101`（交替的 0 和 1）

这种模式在早期的硬件中容易被识别和验证。

#### 引导扇区完整结构

```
┌────────────────────────────────────┐
│  0-509 字节: 引导代码               │
├────────────────────────────────────┤
│  510-511 字节: 魔数 0xAA55         │ ← BIOS 检查这里
└────────────────────────────────────┘
```

如果没有这个魔数，BIOS 会提示：
```
Boot failure: No bootable device available
```

---

## 最简单的引导扇区

### 十六进制形式

```
e9 fd ff 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[... 共 29 行，每行 16 个零字节 ...]
00 00 00 00 00 00 00 00 00 00 00 00 00 00 55 aa
```

**结构解析：**

| 字节 | 内容 | 说明 |
|------|------|------|
| 0-2 | `e9 fd ff` | `jmp -3` 指令（无限循环） |
| 3-509 | 全 `00` | 填充字节 |
| 510-511 | `55 aa` | 魔数 `0xAA55`（小端序） |

> **小端序（Little-Endian）**：x86 架构采用小端序，低字节存储在低地址。`0xAA55` 在内存中存储为 `55 AA`。

---

## 汇编代码实现

### boot_sect_simple.asm

```nasm
; 最简单的引导扇区
; 功能: 无限循环

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
```

---

## 编译与运行

### Windows 平台

```powershell
# 进入目录
cd G:\Nexa1024Projects\os-tutorial\01-引导扇区

# 编译
nasm -f bin boot_sect_simple.asm -o boot_sect_simple.bin

# 运行
qemu-system-x86_64 boot_sect_simple.bin

# 如果出现 SDL 错误，使用无图形模式
qemu-system-x86_64 -nographic boot_sect_simple.bin
```

### Linux/Mac 平台

```bash
# 编译
nasm -f bin boot_sect_simple.asm -o boot_sect_simple.bin

# 运行
qemu boot_sect_simple.bin

# 或指定架构
qemu-system-x86_64 boot_sect_simple.bin
```

---

## NASM 语法说明

| 语法 | 含义 | 示例 |
|------|------|------|
| `db` | Define Byte，定义 1 字节 | `db 0x55` |
| `dw` | Define Word，定义 2 字节 | `dw 0xaa55` |
| `dd` | Define Doubleword，定义 4 字节 | `dd 0x12345678` |
| `times` | 重复指令 | `times 510 db 0` |
| `$` | 当前内存地址 | `times 510-($-$$) db 0` |
| `$$` | 当前节起始地址 | `times 510-($-$$) db 0` |
| `jmp label` | 无条件跳转 | `jmp loop` |

---

## 预期结果

QEMU 窗口打开后显示：

```
Booting from Hard Disk...
```

然后...什么都没有！你正在运行一个无限循环 😄

这是正常的！这个引导扇区的唯一功能就是永远循环。

---

## 调试技巧

### 查看二进制内容

```powershell
# Windows (使用 PowerShell)
Format-Hex boot_sect_simple.bin

# 或使用十六进制编辑器查看
# 推荐工具: HxD, hexedit
```

### 验证魔数

```powershell
# 查看最后 2 字节
# 应该是: 55 aa
```

---

## 常见问题

### Q: 编译时提示 "invalid combination of opcode and operands"
**A:** 检查 NASM 版本，确保使用 2.0+ 版本

### Q: QEMU 报告 "could not open SDL"
**A:** 使用 `-nographic` 参数：`qemu-system-x86_64 -nographic boot_sect_simple.bin`

### Q: 为什么是 510 字节而不是 512？
**A:** 因为最后 2 字节是魔数 `0xaa55`，所以代码部分占 510 字节

### Q: 0xAA55 为什么写成 55 AA？
**A:** x86 是小端序架构，低字节存储在低地址。`0xaa55` 的高字节是 `aa`，低字节是 `55`，所以内存中存储为 `55 aa`。

---

## 下一章

在下一章中，我们将学习如何在屏幕上打印字符！

---

## 🌟 支持一下

如果这个教程对你有帮助，欢迎到 GitHub 项目点个 star 支持：

⭐ [github.com/nexa1024/os-tutorial](https://github.com/nexa1024/os-tutorial)

你的 star 是我继续更新的动力！谢谢 🙏

---

## 参考资源

- [os-tutorial 原仓库](https://github.com/cfenollosa/os-tutorial)
- [os-tutorial 中文版](https://github.com/ruiers/os-tutorial-cn)
- [BIOS 中断向量表](https://en.wikipedia.org/wiki/BIOS_interrupt_call)
- [x86 小端序](https://en.wikipedia.org/wiki/Endianness#Little-endian)
