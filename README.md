# drawing

## 环境配置

参考 [Visual Studio 2019 配置汇编和masm32教程-CSDN博客](https://blog.csdn.net/DongMaoup/article/details/120506468)

开发工具

- Visual Studio Community 2022
- MASM32
- Win32 API

项目配置

- 新建空项目

- 右键选中项目名称->生成依赖项->生成自定义->勾选masm

- 项目属性->链接器->常规->附加库目录->添加`~/masm32/lib`，我这里是C:\DevTools\masm32\lib

- 项目属性->Microsoft Macro Assembler->General->Include paths->添加`~/masm32/include`，我这里是C:\DevTools\masm32\include

- 将项目配置为 'Debug/Release' 构建模式和 'X86' 目标平台

## 项目结构

header.inc	头文件，声明函数，定义全局常量

main.asm	程序入口，创建窗口

menu.asm	菜单相关，创建菜单，菜单项响应处理函数

paint.asm	绘制相关，橡皮擦函数、自由绘制函数等

winproc.asm	窗口消息处理，如VM_COMMAND

## Window

Win32桌面应用的开发过程就是，创建窗口，循环处理事件消息（鼠标、键盘）

## GDI

绘图最重要的一个结构体是`PAINTSTRUCT`

它有一个成员变量`HDC hdc`存储了绘制设备相关属性，比如画笔属性

所有绘图操作都在`BeginPaint`和`EndPaint`两个函数之间完成

以画笔`Pen`为例，设置画笔属性有三种方式：

可参考[设置笔或画笔颜色 - Win32 apps | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/win32/gdi/setting-the-pen-or-brush-color)

- `SetDCPenColor`直接修改当前的HDC.PEN的属性

- `GetStockObject`或者`CreatePen`返回一个全新Pen，然后通过`SelectObject`设置一个新的Pen

关于画笔的样式，可查看CreatePen的API，参数iStyle可设置为实线、虚线等

## 成员分工

...

## 参考

[绘画和绘图 - Win32 apps | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/win32/gdi/painting-and-drawing)

[使用 Win32 API 生成桌面 Windows 应用 - Win32 apps | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/win32/)

