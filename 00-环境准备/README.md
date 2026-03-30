# Windows x64 平台环境搭建指南

> 从零开始编写操作系统 - Windows 环境准备

## 开始之前你可能需要 Google 了解的概念

**windows, terminal, compiler, emulator, nasm, qemu**

## 目的

安装运行教程代码所需要的软件

---

## 🌟 支持一下

如果这个教程对你有帮助，欢迎到 GitHub 项目点个 star 支持：

⭐ [github.com/nexa1024/os-tutorial](https://github.com/nexa1024/os-tutorial)

你的 star 是我继续更新的动力！谢谢 🙏

---

## 必须安装的工具

| 工具 | 用途 | 下载/安装方式 |
|------|------|---------------|
| **NASM** | x86 汇编编译器 | [nasm.us](https://www.nasm.us/) 下载 `nasm-*-installer-x64.exe` |
| **QEMU** | x86 系统模拟器 | [qemu.org/download](https://www.qemu.org/download/) 下载 Windows 64位安装包 |
| **Git** | 克隆教程代码 | [git-scm.com](https://git-scm.com/download/win) |

---

## 详细安装步骤

### 1️⃣ 安装 NASM

**方法1: 手动安装（推荐）**
```
1. 访问 https://www.nasm.us/downloads.php
2. 下载 nasm-2.16.03-installer-x64.exe（或最新版本）
3. 运行安装程序，安装到默认路径
4. 安装后添加到 PATH: C:\Program Files\NASM
```

**方法2: 使用 winget**
```powershell
winget install nasm.nasm
```

**验证安装：**
```powershell
nasm --version
```

---

### 2️⃣ 安装 QEMU

**方法1: 手动安装（推荐）**
```
1. 访问 https://www.qemu.org/download/#windows
2. 下载 qemu-w64-setup-202xxxx.exe（最新版本）
3. 运行安装程序
4. 安装时勾选 "Add QEMU to PATH" 选项
5. 如果没有Add QEMU to PATH选项，可以手动将安装路径添加到系统PATH
```

**方法2: 使用 winget**
```powershell
winget install -e --id QEMU.QEMU
```

**方法3: 使用 Chocolatey**
```powershell
choco install qemu
```

**验证安装：**
```powershell
qemu-system-x86_64 --version
```

---

### 3️⃣ 安装 Git（可选）

如果需要克隆教程代码仓库：
```
访问 https://git-scm.com/download/win
下载并安装 Git for Windows
```

---

## 测试安装

### 快速验证

```powershell
# 检查 NASM 版本
nasm --version

# 检查 QEMU 版本
qemu-system-x86_64 --version
```

### 实际测试：编写第一个引导程序

创建文件 `boot.asm`：

```nasm
; 简单的引导程序测试
; 功能: 屏幕显示 'Hello OS!'

mov ah, 0x0e        ; BIOS 显示字符功能
mov al, 'H'         ; 字符 H
int 0x10            ; 调用 BIOS 中断

mov al, 'e'
int 0x10

mov al, 'l'
int 0x10

mov al, 'l'
int 0x10

mov al, 'o'
int 0x10

mov al, ' '
int 0x10

mov al, 'O'
int 0x10

mov al, 'S'
int 0x10

mov al, '!'
int 0x10

jmp $               ; 无限循环

; 填充到 512 字节（引导扇区大小）
times 510-($-$$) db 0
dw 0xaa55           ; 引导扇区魔数
```

### 编译并运行

```powershell
# 编译
nasm -f bin boot.asm -o boot.bin

# 运行（图形界面模式）
qemu-system-x86_64 boot.bin

# 或运行（无图形界面模式）
qemu-system-x86_64 -nographic boot.bin

```

### 预期结果

QEMU 窗口打开后，屏幕左上角显示：

```
Hello OS!
```

- 按 `Ctrl+Alt+G` 释放鼠标（图形模式）
- 关闭窗口或按 `Ctrl+A` 然后 `X` 退出（无图形模式）

---

## Windows 与 Linux/Mac 的区别

| 特性 | Windows | Linux/Mac |
|------|---------|-----------|
| 路径分隔符 | `\` | `/` |
| 列出文件 | `dir` | `ls` |
| 查看文件 | `type` | `cat` |
| QEMU 命令 | `qemu-system-x86_64.exe` | `qemu-system-x86_64` |

---

## 参考资源

- [QEMU 官方下载页](https://www.qemu.org/download/)
- [NASM 官方网站](https://www.nasm.us/)
- [os-tutorial 原仓库](https://github.com/cfenollosa/os-tutorial)
- [os-tutorial 中文版](https://github.com/ruiers/os-tutorial-cn)
