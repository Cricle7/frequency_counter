# frequency_counte

### **摘要**

本课程设计报告围绕数字频率计展开。数字频率计作为一种重要的电子测量仪器，在电子工程等领域具有广泛的应用。本次课程设计详细阐述了数字频率计的设计原理、实现方法及测试过程。通过对电路的精心设计和调试，实现了对输入信号频率的准确测量。该数字频率计具有测量精度高、稳定性好、操作简便等特点。在设计过程中，充分运用了数字电路的相关知识，包括计数器、寄存器、译码器等逻辑器件的应用。经过实际测试，该数字频率计能够准确地测量不同频率范围内的信号，满足了课程设计的要求，为电子测量技术的学习和实践提供了有益的参考。
本文设计了一种创新的数字频率计，采用输入捕获方法代替传统的等效采样方法进行频率测量。相比等效采样法，输入捕获法在精度和测量范围方面具有显著优势。该方法不仅提高了频率计的测量准确度，还能够在更广的频率范围内稳定运行，实现高达0.5%以内的测量误差。通过输入捕获技术，本设计满足了高精度测量的要求，且在整个设计频率范围内无需频段切换，极大地简化了系统结构并提升了操作便捷性。
由于本次设计采用了输入捕获的方法和流水线设计，实现了从测量到输出结果为微秒级延迟。相比于传统的等效测量法对于部分频率的测量需要 10 秒的情况，这是一个极大的提升。这种创新的设计不仅提高了测量的速度，还增强了系统的实时性和响应能力，能够更好地满足现代电子测量领域对于快速、准确测量的需求。同时，流水线设计也提高了系统的处理效率，使得多个测量任务可以同时进行，进一步提升了系统的性能。

### **第一章 技术指标**

#### **1.1 系统的功能要求**

本系统的主要功能是高精度测量输入信号的频率、周期和脉宽。通过创新的输入捕获方法，系统在宽测量范围内实现了较高的测量精度，并将频率、周期和脉宽的测量误差控制在0.5%以内。系统支持实时显示测量结果，适应正弦波、三角波和矩形波等不同类型的输入信号，满足多种测量需求。

#### **1.2 系统的结构要求**

系统由输入信号模块、测量电路模块、档位转换模块和显示模块组成。采用输入捕获方法替代传统等效采样技术，使系统在不需频段切换的情况下即可完成高精度测量。输入捕获技术适应性强，既能测量频率，也能测量周期和脉宽，简化了系统结构并提升了操作便捷性。

#### **1.3 电气指标**

1. **频率测量范围**：支持1Hz至99.9KHz的频率测量，显示精度为3位有效数字。
2. **周期测量范围**：1ms至1s。
3. **脉宽测量范围**：1ms至1s。
4. **测量精度**：输入捕获法使频率、周期和脉宽测量误差控制在0.5%以内。
5. **输入信号类型**：支持正弦波、三角波和矩形波，输入阻抗大于1MΩ，减少对信号源的影响。

#### **1.4 设计条件**

系统设计采用5V直流电源，逻辑电平符合TTL标准。为确保输入捕获技术的精度需求，系统选用高稳定性晶振作为参考时钟源，以保证测量准确性。

#### **1.5 扩展指标**

为更准确地显示测量值的小数精度，本系统在3位数码管上采用多位显示策略，以实现小数点后多位数字的展现，具体方案如下：

1. **动态小数点位置**：根据不同的测量范围，系统会自动调整小数点的位置。例如，在测量频率较低的情况下，显示的数值精确到小数点后两位，以提升显示的分辨率。系统通过数码管自带的动态控制电路，在适当位置点亮小数点，实现小数部分的显示。
2. **滚动显示精度扩展**：若小数点后需要显示的位数超过3位数码管的容量，系统可按段滚动显示整个数值。例如，显示一个精确到小数点后3位的结果时，系统会先显示整数位及小数点后前两位，再切换显示小数点后第3位的数字，实现更高精度的显示。

3位数码管能够灵活展现小数点后的多位数值，实现了测量结果的高精度显示，有效提高了系统的实用性和读数的直观性。

## 第二章 整体方案设计

### 2.1 算法设计

本系统通过输入捕获的方法来实现对信号周期、频率和脉宽的测量。主要算法包括：

1. **输入信号的边沿检测**：利用上升沿和下降沿检测实现高、低电平时间的测量。使用状态机对信号的上升沿和下降沿进行捕获，记录高电平和低电平持续的时钟周期数。
  
2. **周期、频率和脉宽的计算**：
   - **频率计算**：通过计数周期时间，将系统时钟频率（50 MHz）除以周期时间得到信号的频率。
   - **周期计算**：直接通过时钟周期计数实现周期时间的捕获，结合系统时钟频率计算实际周期。
   - **小数点精度控制**：将测量值转换为BCD码并进行四舍五入，以便在显示时控制小数点精度。

3. **显示数值转换和控制**：利用BCD转换和四舍五入算法，将测量得到的周期和频率以适当的小数点精度显示在数码管上。显示时根据数值大小动态调整显示的小数点位置。

### 2.2 设计方案

系统设计方案主要包括以下模块：

1. **输入捕获模块（Input_Capture_Module）**：负责输入信号的边沿检测和周期、脉宽的计数。该模块采用同步电路捕获信号边沿，利用计数器分别记录高电平和低电平时间。

2. **测量处理模块（Measurement_Processor）**：处理捕获的数据，计算出频率和周期，并将其转换为BCD格式以便于数码管显示。该模块包含除法运算器和BCD转换模块，实现频率和周期的小数点位置动态调整。

3. **显示控制模块（Hex8_Test）**：接收BCD格式的测量结果，并控制数码管的显示，包括小数点位置的动态调整和测量单位（频率和周期）的选择。

4. **主控模块（Top_Module）**：集成以上模块，通过 `mod_sel` 控制选择测量项目（周期或脉宽），并实时刷新显示输出。该模块协调各个子模块的数据流，保证测量数据的准确性。

### 2.3 整体方框图及原理

#### 整体方框图

```
                  +-------------------------------+
                  |           Top_Module          |
                  |-------------------------------|
                  |   mod_sel    |    clk, rst_n  |
                  |   (模式选择) |   (时钟、复位) |
                  |                               |
                  |     +--------------------+    |
                  |     |  Input_Capture     |    |
                  |     |    Module          |    |
                  |     |                    |    |
                  |     +--------------------+    |
                  |                               |
                  |     +--------------------+    |
                  |     | Measurement        |    |
                  |     | Processor          |    |
                  |     |                    |    |
                  |     +--------------------+    |
                  |                               |
                  |     +--------------------+    |
                  |     |    Hex8_Test       |    |
                  |     |  (Display Control) |    |
                  |     +--------------------+    |
                  |                               |
                  +-------------------------------+
```

#### 原理说明

1. **信号捕获与边沿检测**：`Input_Capture_Module` 通过时钟同步检测输入信号的上升沿和下降沿，以确定高电平和低电平的持续时间。检测到一个完整周期后，将测得的周期和脉宽信息发送至测量处理模块。

2. **测量处理与数值转换**：`Measurement_Processor` 接收周期时间或高电平时间，根据测量模式选择对频率或周期进行计算。通过除法和BCD转换实现对频率和周期的计算结果转换，并四舍五入后输出至显示控制模块。根据实际精度控制小数点位置。

3. **显示输出控制**：`Hex8_Test` 模块负责将测量数据输出至3位数码管，包括小数点的动态调整和单位显示，确保用户能够直观查看测量结果。

---

以上是第二章整体设计的各个环节和模块说明。该设计能够在不更换测量档位的情况下，实现高精度的测量和显示。
### 核心模块简介

1. **Top_Module**
   - 系统主模块，集成了输入捕获、测量处理和显示功能。
   - 通过 `mod_sel` 控制测量不同的信号参数（周期或高电平脉宽）。
   - 包含 `Input_Capture_Module` 进行输入信号的捕获，`Measurement_Processor` 处理测量数据，`hex8_test` 控制显示输出。

2. **Input_Capture_Module**
   - 输入捕获模块，用于测量输入信号的周期、高电平时间和低电平时间。
   - 通过检测信号的上升沿和下降沿实现周期和脉宽的测量。
   - 使用状态机分别处理高电平时间和低电平时间，并在完成时输出 `measurement_done` 信号。

3. **Measurement_Processor**
   - 测量处理模块，完成频率和周期的计算、转换成BCD码并四舍五入以便于显示。
   - `Iterative_Divider` 计算频率，通过将时钟频率除以周期时间得到频率。
   - `Binary_to_BCD` 和 `BCD_Rounding` 模块将二进制结果转换成BCD码并四舍五入。
   - 通过 `Segment_freq` 和 `Segment_period` 输出显示数据，并控制显示的小数点和单位标志位（`k` 和 `m`）。

4. **Hex8_Test**
   - 数码管显示模块，用于将BCD码的测量结果显示在7段数码管上。
   - 动态控制小数点位置，根据测量的精度要求显示不同的数位。

### 主要逻辑解释

- **频率测量**
   - `Iterative_Divider` 用于将时钟频率除以输入信号的周期时间，以计算频率。
   - 结果由 `Binary_to_BCD` 模块转换为BCD格式，以便在数码管上显示。
   - 四舍五入模块进一步提升精度，通过 `Segment_freq` 输出频率数据，`point_1` 控制小数点位置。

- **周期测量**
   - `Pipelined_Optimized_Divider_5000` 模块计算周期。
   - 类似于频率测量，周期也通过BCD转换和四舍五入以便显示。
   - `Segment_period` 输出周期数据，`point_2` 控制显示的小数点位置。

- **显示控制**
   - 根据测量结果动态控制小数点位置和数码管的单位标志，提供直观的显示。
   - 3位数码管用于显示测量精度，可根据需要调整小数点显示的位置。

### 显示和测量控制

代码中实现了对不同测量结果的显示，尤其是小数点位置和单位标志位的切换，通过 `Segment_freq` 和 `Segment_period` 输出对应的BCD码，使得结果能够准确显示在3位数码管上。
### **第二章 整体方案设计**

#### **2.1 算法设计**
本系统采用输入捕获算法，利用微控制器（MCU）或其他处理器的输入捕获功能，通过精确记录输入信号的上升沿或下降沿时间，实现频率、周期和脉宽的高精度测量。具体算法设计如下：

1. **频率测量算法**：输入信号的每个上升沿或下降沿触发一次捕获事件，记录捕获时间。两次捕获事件的时间差即为信号周期的倒数，从而得到频率值。根据测量精度要求，进行多次采样取平均值以减少误差。

2. **周期测量算法**：在输入捕获功能的配合下，记录两个连续上升沿或下降沿的时间差，即可得到信号的周期值。周期值可用于验证频率测量结果的精确性。

3. **脉宽测量算法**：通过捕获一个完整的高电平或低电平周期的时间间隔，即可计算脉宽。在一个完整周期内，分别测量高电平时间和低电平时间，进一步提高测量精度。

4. **多位数显示算法**：为显示小数点后多位数值，系统采用动态显示算法，将测量值按分段方式轮流显示在3位数码管上，并灵活控制小数点位置，使用户能够直观读取精确的测量结果。

#### **2.2 设计方案**
为实现高精度频率、周期和脉宽测量，系统整体设计方案包括以下模块：

1. **信号输入模块**：负责接收待测信号，适应不同幅度的输入信号（正弦波、三角波、矩形波），并进行阻抗匹配和前端整形处理。
   
2. **测量控制模块**：核心控制单元（如MCU）负责信号捕获、数据处理和显示控制。利用输入捕获功能，处理测量过程中的频率、周期和脉宽数据，并按照需求进行分段计算和显示。

3. **显示模块**：使用3位数码管动态显示测量结果，采用高频扫描技术实现小数点后的多位显示。根据测量范围自动调整小数点位置，并根据测量值实现滚动显示。

4. **电源管理模块**：提供稳定的+5V电源供应，确保系统稳定运行，并为各模块提供所需的工作电压。

#### **2.3 整体方框图及原理**
整体系统方框图如图所示，包含信号输入模块、测量控制模块、显示模块和电源管理模块，各模块的基本原理如下：

1. **信号输入模块**：输入信号经过阻抗匹配和整形处理后，确保输入信号符合测量电路要求，并将其传递至测量控制模块。

2. **测量控制模块**：微控制器在每次检测到输入信号的触发沿（如上升沿）时，启动输入捕获功能，记录捕获事件的时间戳。通过计算相邻时间戳之间的时间差，可以得到信号的频率、周期或脉宽。测量完成后，系统将数值转换为显示格式，并传输至显示模块。

3. **显示模块**：测量结果在3位数码管上循环显示，通过动态扫描技术实现小数点后多位数值的显示。根据测量结果的精度要求，动态调整小数点位置，提供直观的显示界面。

4. **电源管理模块**：为系统提供稳定的+5V电源，并对各模块进行电压调节，保证系统在不同工作状态下的稳定性。

整体方案设计通过输入捕获法实现高精度的频率、周期和脉宽测量，简化了系统设计，同时在3位数码管上动态显示多位测量结果，实现了高精度的显示效果。
