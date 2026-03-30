# os-tutorial

> 从零开始编写操作系统 - 中文教程

## 简介

本教程基于 [cfenollosa/os-tutorial](https://github.com/cfenollosa/os-tutorial) 和 [ruiers/os-tutorial-cn](https://github.com/ruiers/os-tutorial-cn)，是一个手把手教你从零开始编写 x86 操作系统的学习项目。

### 这个项目是做什么的

简单说，就是教你怎么写一个操作系统。

不用担心很难，我们会从最基础的开始：
- 先写个能让电脑识别的"启动扇区"
- 然后在屏幕上打印几个字
- 再学着用汇编写点小功能
- 最后慢慢加上 C 语言内核

整个过程就像搭积木一样，一块一块往上加。

### 适合谁看

- 对计算机底层好奇的同学
- 想了解操作系统原理的朋友
- 有一定编程基础，但没写过 OS 的开发者
- 单纯想玩一玩汇编的爱好者

### 特点

- 📚 **循序渐进** - 每章 5-15 分钟即可完成
- 💻 **代码驱动** - 边学边写，理论结合实践
- 🌏 **中文文档** - 详细的中文注释和说明
- 🔧 **无需 GRUB** - 从零编写自己的引导程序

### 前置要求

不需要任何操作系统开发经验，但建议了解：
- 基本的编程概念
- 十六进制/二进制
- 命令行操作

---

## 🌟 支持一下

如果这个教程对你有帮助，欢迎到 GitHub 项目点个 star 支持：

⭐ [github.com/nexa1024/os-tutorial](https://github.com/nexa1024/os-tutorial)

你的 star 是我继续更新的动力！谢谢 🙏

---

## 环境要求

| 工具 | 最低版本 | 用途 |
|------|---------|------|
| NASM | 2.0+ | x86 汇编编译器 |
| QEMU | 任意版本 | x86 系统模拟器 |
| Git | 可选 | 版本控制 |

**Windows 用户**请参阅 [`00-环境准备/README.md`](00-环境准备/README.md)

---

## 目录结构

```
os-tutorial/
├── 00-环境准备/           # 开发环境搭建指南
├── 01-引导扇区/           # BIOS 启动流程、魔数 0xAA55
├── 02-引导打印/           # BIOS 中断 int 0x10 屏幕打印
├── 03-引导内存/           # 读取系统内存信息
├── 04-引导栈/             # 栈的使用与管理
├── 05-函数和字符串/        # 汇编函数与字符串处理
├── 06-引导段/             # 内存段管理
├── 07-bootsector-disk/    # 磁盘 I/O 操作
├── 08-32bit-print/        # 32 位模式打印
├── 09-32bit-gdt/          # 全局描述符表
├── 10-32bit-enter/        # 进入保护模式
├── 11-kernel-crosscompiler/# 构建交叉编译器
├── 12-kernel-c/           # C 语言内核
└── ...
```

---

## 学习进度

| 章节 | 状态 | 描述 |
|------|:----:|------|
| 00-环境准备 | ✅ | NASM、QEMU 安装配置 |
| 01-引导扇区 | ✅ | BIOS 启动流程、魔数 0xAA55 |
| 02-引导打印 | ✅ | BIOS 中断 int 0x10 |
| 03-引导内存 | ⏳ | 读取 BIOS 内存信息 |
| 04-引导栈 | ⏳ | 栈的使用与管理 |
| 05-函数和字符串 | ⏳ | 汇编函数与字符串处理 |
| 06-引导段 | ⏳ | 内存段管理 |
| 07-bootsector-disk | ⏳ | 磁盘 I/O 操作 |
| 08-32bit-print | ⏳ | 32 位模式打印 |
| 09-32bit-gdt | ⏳ | 全局描述符表 |
| 10-32bit-enter | ⏳ | 进入保护模式 |
| 11-kernel-crosscompiler | ⏳ | 构建交叉编译器 |
| 12-kernel-c | ⏳ | C 语言内核 |

---

## 攻略路线

### 第一阶段：引导程序 (00-07)
```
环境搭建 → 引导扇区 → 屏幕打印 → 内存管理 → 栈 → 函数 → 段 → 磁盘
```

### 第二阶段：保护模式 (08-10)
```
32位打印 → GDT → 进入保护模式
```

### 第三阶段：C 语言内核 (11-12+)
```
交叉编译 → C内核 → 中断 → Shell → 文件系统 → 多任务
```

---

## 快速开始

### 编译并运行第一个引导程序

```bash
# 进入目录
cd 01-引导扇区

# 编译
nasm -f bin boot_sect_simple.asm -o boot_sect_simple.bin

# 在 QEMU 中运行
qemu-system-x86_64 boot_sect_simple.bin
```

### Windows 用户

```powershell
# 编译
nasm -f bin boot_sect_simple.asm -o boot_sect_simple.bin

# 运行
qemu-system-x86_64 boot_sect_simple.bin

# 或无图形模式
qemu-system-x86_64 -nographic boot_sect_simple.bin
```

---

## 如何学习

1. **按顺序学习** - 每章基于前一章内容，建议依次完成
2. **先读 README** - 每章开头有前置概念和学习目标
3. **查阅代码** - 代码包含详细中文注释
4. **动手修改** - 尝试修改代码加深理解

---

## 参考资源

- [os-tutorial 原仓库](https://github.com/cfenollosa/os-tutorial)
- [os-tutorial 中文版](https://github.com/ruiers/os-tutorial-cn)
- [x86 汇编参考](https://www.felixcloutier.com/x86/)
- [OSDev Wiki](https://wiki.osdev.org/)
- [INT 10h - Wikipedia](https://en.wikipedia.org/wiki/INT_10H)

---

## 许可

MIT License