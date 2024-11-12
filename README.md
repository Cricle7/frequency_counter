# frequency_counte

### **摘要**

本课程设计报告围绕数字频率计展开。数字频率计作为一种重要的电子测量仪器，在电子工程等领域具有广泛的应用。本次课程设计详细阐述了数字频率计的设计原理、实现方法及测试过程。通过对电路的精心设计和调试，实现了对输入信号频率的准确测量。该数字频率计具有测量精度高、稳定性好、操作简便等特点。在设计过程中，充分运用了数字电路的相关知识，包括计数器、寄存器、译码器等逻辑器件的应用。经过实际测试，该数字频率计能够准确地测量不同频率范围内的信号，满足了课程设计的要求，为电子测量技术的学习和实践提供了有益的参考。
本文设计了一种创新的数字频率计，采用输入捕获方法代替传统的等效采样方法进行频率测量。相比等效采样法，输入捕获法在精度和测量范围方面具有显著优势。该方法不仅提高了频率计的测量准确度，还能够在更广的频率范围内稳定运行，实现高达0.5%以内的测量误差。通过输入捕获技术，本设计满足了高精度测量的要求，且在整个设计频率范围内无需频段切换，极大地简化了系统结构并提升了操作便捷性。
由于本次设计采用了输入捕获的方法和流水线设计，实现了从测量到输出结果为微秒级延迟。相比于传统的等效测量法对于部分频率的测量需要 10 秒的情况，这是一个极大的提升。这种创新的设计不仅提高了测量的速度，还增强了系统的实时性和响应能力，能够更好地满足现代电子测量领域对于快速、准确测量的需求。同时，流水线设计也提高了系统的处理效率，使得多个测量任务可以同时进行，进一步提升了系统的性能。
### Abstract

This course project focuses on the development of a digital frequency meter, a crucial electronic measurement instrument with extensive applications in the field of electronic engineering. The report provides a comprehensive exposition of the design principles, implementation methodologies, and testing procedures employed in creating the digital frequency meter. Through meticulous circuit design and debugging, the frequency meter successfully achieves accurate measurement of input signal frequencies, exhibiting high precision, excellent stability, and user-friendly operation.

The design leverages fundamental digital circuit concepts, including the utilization of counters, registers, and decoders, to facilitate reliable frequency measurement. Empirical testing validates the device's ability to accurately measure signals across a broad range of frequencies, thereby fulfilling the course project requirements and offering valuable insights for both academic study and practical application in electronic measurement technologies.

A notable innovation in this design is the adoption of the input capture method in place of the traditional equivalent sampling technique for frequency measurement. Compared to equivalent sampling, the input capture approach offers significant advantages in terms of precision and measurement range. This method not only enhances the accuracy of frequency measurements but also ensures stable operation over a wider frequency spectrum, achieving measurement errors within 0.5%. Additionally, the input capture technique eliminates the need for frequency band switching, thereby simplifying the system architecture and improving operational convenience.

Furthermore, the incorporation of a pipelined design enables the system to process measurements with microsecond-level delays from acquisition to output. This represents a substantial improvement over conventional equivalent measurement methods, which may require up to 10 seconds for certain frequency measurements. The innovative design not only accelerates measurement speed but also enhances the system's real-time responsiveness and operational efficiency, making it well-suited to meet the demands of modern electronic measurement applications that require rapid and precise data acquisition. The pipelined architecture also boosts processing efficiency, allowing multiple measurement tasks to be conducted concurrently and thereby further enhancing overall system performance.

In conclusion, the developed digital frequency meter demonstrates robust performance characteristics, including high measurement accuracy, stability, and efficiency. The successful integration of input capture and pipelined design methodologies ensures that the system operates reliably within the specified frequency ranges, providing a valuable tool for electronic measurements and serving as an effective reference for future advancements in the field.

## Keywords

Digital Frequency Meter, FPGA, Input Capture, Pipelined Design, Frequency Measurement, Digital Circuits, Electronic Engineering, Measurement Accuracy, System Stability
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

输入捕获是测量输入信号的频率、脉宽或周期的重要手段。基本原理是在时钟信号的控制下，通过捕获输入信号的边沿变化时间，计算输入信号的相关特性。FPGA 实现输入捕获时，凭借其并行处理能力，非常高效和灵活的。

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

## 第三章 单元电路和算法模块具体细节

### 3.1 FPGA 输入捕获算法设计

#### 3.1.1 输入信号同步

由于 FPGA 的时钟与外部输入信号不一定同步，因此在捕获输入信号之前，首先需要对输入信号进行同步处理。常用的同步方法是通过双寄存器（或多级触发器）同步输入信号，以避免由于不同步带来的亚稳态问题。通过同步，输入信号才能在 FPGA 时钟域内稳定，从而保证信号捕获的正确性。

#### 3.1.2 边沿检测

同步后的输入信号需要进行边沿检测。边沿检测是通过比较信号同步后的前后两拍状态，来确定输入信号是否发生了上升沿或下降沿。上升沿是输入信号从低电平转为高电平，下降沿则是信号从高电平转为低电平。通过此机制，可以精准地捕捉到信号的变化时刻。

#### 3.1.3 捕获计数器

在 FPGA 中，输入捕获的关键在于记录输入信号边沿变化的时间。每个时钟周期都会增加一个计数器的值，计数器的值即表示当前时刻的时钟周期。捕获到边沿变化时，当前计数器的值会被保存，用于后续计算信号的周期或频率。

#### 3.1.4 测量完成标志

为了标记一次输入捕获的完成，通常会引入一个测量完成信号。每当一次完整的周期被捕获后，系统就会通过该标志信号向上层模块或系统发出通知，表示输入捕获操作已经完成，可以进行后续的频率和周期的计算。

### 3.2 FPGA 四舍五入算法算法设计

在 FPGA 中实现四舍五入操作时，我们采用了一个基于 BCD（Binary-Coded Decimal，二进制编码十进制）表示的算法。该算法主要功能是将一个 24 位的 BCD 数字四舍五入到最近的十进制整数。四舍五入的具体处理规则如下：

1. **四舍五入规则**：

   - 判断 BCD 数字的个位是否大于或等于 5。如果是，则向十位进位。
   - 如果个位数大于等于 5，则十位加一，并处理可能的进位问题（例如十位为 9 时，进位到百位）。
   - 对于每一位的进位，从个位开始逐级处理，直到高位。
2. **数据输入与输出**：

   - 输入的 BCD 数字为 24 位，表示为六个 4 位的数字，每个 4 位数字代表一个十进制数。
   - 输出的 BCD 数字为 20 位，表示经过四舍五入后的结果。

#### 3.2.1 设计方案

该模块的设计基于时钟同步工作，并通过控制信号 `start` 和 `done` 来协调操作。设计流程如下：

- **输入分解**：输入的 BCD 数字（24 位）被拆解为 6 个 4 位的 BCD 数字，每一位代表十进制的一个数位（从最高位的百万位到个位）。
- **四舍五入逻辑**：

  - 通过比较个位的值与 5 进行判断。
  - 如果个位数大于或等于 5，则对十位进行加一处理，并考虑进位的传播。
  - 若某一位达到 9 以后，会发生进位，进位继续传递到高位，直到最高位（百万位）。
- **输出赋值**：经处理后的每一位数字被存入输出寄存器中，并最终通过BCD编码输出。
- **状态控制**：
  使用 `start` 信号启动四舍五入操作，使用 `done` 信号标记四舍五入操作完成。模块在 `start` 信号有效时开始工作，并在操作完成后通过 `done` 信号通知外部。

#### 3.2.2 四舍五入算法方框图及原理

**方框图**：

在整体方框图中，`BCD_Rounding` 模块包含以下主要部分：

1. **输入数据处理单元**：接收 24 位的 BCD 输入，将其分解为 6 个 4 位的数字（百万位到个位）。
2. **四舍五入模块**：判断个位数，若满足四舍五入条件，则依次加一并处理进位。
3. **输出寄存器**：将四舍五入后的结果存储为 20 位 BCD 数字。
4. **状态控制**：通过 `start` 和 `done` 信号控制操作的开始与结束。

**原理说明**：

- **四舍五入核心**：根据 BCD 数字的个位，判断是否需要向上进位。如果 `units_in >= 5`，则十位开始进位，依此类推直到高位。若某一位加一后超出 9，则将其置为 0，并将进位传递给下一位。
- **进位传播**：进位从低位（个位）开始，逐步向高位传播，直到最高位。若所有位都进位，最终输出将为零。

### 3. 3 FPGA 除数不是常数的除法转乘法算法

在本设计中，我们需要实现一个高效的除法器，用于计算常数除法操作，即将一个 32 位被除数除以常数 5000。为了提高性能，传统的除法操作被优化为乘法操作。具体做法是预计算常数 5000 的倒数，并将该倒数与被除数相乘，从而实现除法操作。由于常数倒数是一个固定值，因此这一优化可以有效减少硬件资源的使用，并提高运算速度。

- **常数倒数预计算**：通过预计算 `1 / 5000` 乘以 `2^32`，得到了一个常数 `RECIPROCAL`，其值为 `32'd858993`。这一倒数值用于代替除法运算中的除数部分，避免了每次执行除法时的计算开销。
- **流水线结构设计**：设计使用了三阶段流水线，其中第一阶段用于存储输入数据，第二阶段进行乘法计算，第三阶段输出商。流水线的引入使得系统能够在较短的时间内处理多个除法任务，提高了整体的吞吐量。
- **零除检测**：
  当被除数为零时，输出结果应为零。因此，通过引入 `is_zero` 信号，检测被除数是否为零，若是零，则直接将商设为零。

### 3.4 流水线除法器设计

#### 3.4.1 模块概述

本模块 **Iterative_Divider** 实现了一个基于迭代算法的除法器，用于在 FPGA 中执行无符号整数的除法运算。该除法器接受被除数和除数作为输入，经过多次迭代后输出商和余数，并在运算完成时发出完成信号。本设计旨在通过流水线结构提高除法运算的效率，适用于需要频繁进行除法运算的应用场景。

#### 3.4.2 模块接口

模块 **Iterative_Divider** 的接口定义如下：

- **输入信号**

  - `clk`：时钟信号，用于同步模块的所有操作。
  - `rst_n`：低电平有效的复位信号，用于初始化模块状态。
  - `start`：启动信号，当此信号为高电平且模块未在处理时，开始一次新的除法运算。
  - `numerator`：32位被除数输入。
  - `divisor`：32位除数输入。
- **输出信号**

  - `quotient`：32位商输出。
  - `remainder`：32位余数输出。
  - `done`：完成信号，当除法运算完成时置高，通知外部模块结果可用。

#### 3.4.3 内部寄存器与信号

模块内部主要使用以下寄存器和信号来实现除法运算：

- `dividend`（64位）：用于存储扩展后的被除数和余数的中间结果。初始时将被除数左移32位，与高32位的余数部分结合。
- `divisor_reg`（32位）：存储除数的寄存器，确保除数在整个运算过程中保持不变。
- `bit`（6位）：用于记录剩余的迭代次数，初始值为32，表示32位除法运算需要进行32次迭代。
- `processing`（1位）：标志位，指示当前是否正在进行除法运算。

#### 3.4.4 除法运算流程

除法运算的实现基于经典的迭代位移算法，具体流程如下：

1. **初始化阶段**

   - 当复位信号 `rst_n` 为低电平时，所有寄存器被清零，模块处于初始状态。
   - 当 `start` 信号为高且 `processing` 标志为低时，模块开始一次新的除法运算：
     - 将 `divisor` 输入存入 `divisor_reg`。
     - 将被除数 `numerator` 左移32位后存入 `dividend`。
     - 清零 `quotient` 和 `remainder`。
     - 设置 `bit` 为32，表示需要进行32次迭代。
     - 将 `done` 置低，`processing` 置高，开始运算。
2. **迭代运算阶段**

   - 在 `processing` 为高的情况下，模块进入迭代运算：
     - 检查 `bit` 是否大于0，若是，继续迭代：
       - 将 `dividend` 左移1位，为下一位的运算做准备。
       - 将 `quotient` 左移1位，并将 `dividend` 的最高位（即之前左移的位）赋值给 `quotient` 的最低位。
       - 比较 `dividend` 的高32位与 `divisor_reg`：
         - 若 `dividend[63:32]` 大于或等于 `divisor_reg`，则执行减法操作 `dividend[63:32] = dividend[63:32] - divisor_reg`，并将 `quotient` 的最低位设置为1。
         - 否则，将 `quotient` 的最低位设置为0。
       - 将 `bit` 减1，准备下一次迭代。
     - 若 `bit` 已减至0，表示所有迭代完成：
       - 将 `dividend[63:32]` 赋值给 `remainder`，即最终余数。
       - 将 `done` 置高，表示运算完成。
       - 将 `processing` 置低，模块返回待命状态。
3. **完成阶段**

   - 当 `done` 信号为高时，外部模块可以读取 `quotient` 和 `remainder` 的值，进行后续处理。
   - 如果 `start` 信号未被激活，`done` 信号保持低电平，等待新的除法运算请求。

#### 3.4.5 时序与控制

模块的时序控制基于 FPGA 的主时钟 `clk`，所有操作在时钟上升沿进行同步。复位信号 `rst_n` 异步清零，确保在任何时刻复位信号到达时，模块能立即返回初始状态。

- **启动控制**：通过检测 `start` 信号和 `processing` 标志，确保在不冲突的情况下启动新的除法运算。
- **迭代控制**：使用 `bit` 寄存器计数迭代次数，确保除法运算的每一步都在时钟周期内完成，并逐步逼近最终结果。
- **完成控制**：通过 `done` 信号通知外部模块运算完成，确保数据的有效性和同步性。

#### 3.4.6 设计优化与考虑

为了提高除法器的效率和可靠性，设计中考虑了以下优化措施：

- **寄存器同步**：所有关键寄存器在时钟上升沿进行更新，确保数据在时钟域内的一致性和稳定性。
- **状态标志控制**：使用 `processing` 标志有效管理除法运算的状态，避免启动冲突和重复运算。
- **位移与比较优化**：通过位移操作和高位比较，简化了除法算法的实现，减少了逻辑复杂度。
- **资源利用**：该设计采用迭代算法，适用于资源有限的 FPGA 环境，平衡了运算速度和资源消耗。

### 3.5 测量处理器设计

#### 3.5.1 模块概述

**Measurement_Processor** 模块在 FPGA 系统中负责处理测量到的信号周期时间，计算相应的频率和周期值，并将结果转换为适合显示的格式。该模块主要通过实例化和集成先前设计的子模块，如除法器、二进制到 BCD 转换器及四舍五入模块，实现数据的高效处理与显示控制。**Measurement_Processor** 充当了各个功能模块的协调者，确保测量数据的准确计算和优化显示。

#### 3.5.2 模块接口

**Measurement_Processor** 模块的接口定义如下：

- **参数**

  - `CLOCK_FREQ`：系统时钟频率，默认为 50 MHz，用于配置子模块的时序。
- **输入信号**

  - `clk`：系统时钟信号，用于同步模块的所有操作。
  - `rst_n`：低电平有效的复位信号，用于初始化模块状态。
  - `measurement_done`：测量完成信号，当输入捕获模块完成一次测量后置高，触发频率和周期的计算。
  - `period_time`：32位输入信号，表示测量到的信号周期时间（单位为秒）。
- **输出信号**

  - `Segment_freq`：16位频率显示段数据，用于驱动数码管显示频率值。
  - `Segment_period`：16位周期显示段数据，用于驱动数码管显示周期值。
  - `point_1`：3位周期显示的小数点控制信号。
  - `point_2`：3位频率显示的小数点控制信号。
  - `k`：频率单位指示信号，例如千赫兹（kHz）。
  - `m`：周期单位指示信号，例如毫秒（ms）。

#### 3.5.3 内部信号与子模块

**Measurement_Processor** 模块内部主要通过以下信号和子模块实现测量数据的处理与显示控制：

- **内部信号**

  - `divider_done`：频率除法完成信号，指示频率除法器完成运算。
  - `frequency_quotient`：频率除法的商，表示计算得到的频率值。
  - `bcd_freq_done`：频率 BCD 转换完成信号。
  - `freq_bcd`：频率的 BCD 表示。
  - `freq_bcd_rounded`：频率 BCD 数据四舍五入后的结果。
  - `period_out`：周期除法的商，表示计算得到的周期值。
  - `bcd_period_done`：周期 BCD 转换完成信号。
  - `period_bcd`：周期的 BCD 表示。
  - `period_bcd_rounded`：周期 BCD 数据四舍五入后的结果。
  - `bcd_freq_round_done`：频率 BCD 四舍五入完成信号。
  - `bcd_period_round_done`：周期 BCD 四舍五入完成信号。
  - 前导零检测信号 (`freq_ten_tho_0`, `freq_tho_0`, 等) 用于优化显示段的显示内容。
- **子模块**

  - **Iterative_Divider**：用于计算频率。
  - **Binary_to_BCD**：将二进制频率和周期值转换为 BCD 格式。
  - **BCD_Rounding**：对 BCD 数据进行四舍五入处理。
  - **Pipelined_Optimized_Divider_5000**：用于计算周期。

#### 3.5.4 模块功能与工作流程

**Measurement_Processor** 模块的主要功能是协调各子模块的工作流程，确保测量数据的准确计算和优化显示。其工作流程如下：

1. **频率计算**

   - 当 `measurement_done` 信号为高且模块未在处理时，**Measurement_Processor** 启动频率计算。
   - 实例化的 **Iterative_Divider** 模块将固定值 `500_000_000` 除以 `period_time`，得到频率值 `frequency_quotient`。
   - 当除法器完成运算后，`divider_done` 信号被置高，触发频率数据的二进制到 BCD 转换。
2. **频率数据处理**

   - 实例化的 **Binary_to_BCD** 模块将 `frequency_quotient` 转换为 BCD 格式 `freq_bcd`。
   - 当 BCD 转换完成后，`bcd_freq_done` 信号被置高，触发 **BCD_Rounding** 模块对 `freq_bcd` 进行四舍五入，得到 `freq_bcd_rounded`。
   - 前导零检测逻辑根据 `freq_bcd_rounded` 的值，优化 `Segment_freq` 的显示内容，调整小数点位置 `point_2` 和频率单位指示 `k`。
3. **周期计算**

   - 实例化的 **Pipelined_Optimized_Divider_5000** 模块将 `period_time` 除以 `5000`，得到周期值 `period_out`。
   - 实例化的 **Binary_to_BCD** 模块将 `period_out` 转换为 BCD 格式 `period_bcd`。
   - 当周期 BCD 转换完成后，`bcd_period_done` 信号被置高，触发 **BCD_Rounding** 模块对 `period_bcd` 进行四舍五入，得到 `period_bcd_rounded`。
   - 前导零检测逻辑根据 `period_bcd_rounded` 的值，优化 `Segment_period` 的显示内容，调整小数点位置 `point_1` 和周期单位指示 `m`。
4. **显示段数据处理**

   - 通过组合逻辑检测 BCD 数据中的前导零，决定是否显示特定位数的数码管内容，优化显示效果。
   - 根据检测结果，调整 `Segment_freq` 和 `Segment_period` 的显示内容，并控制小数点位置 `point_1` 和 `point_2`。
   - 设置频率单位 `k` 和周期单位 `m`，指示当前显示的数据单位。

### 3.6 74HC595 驱动器原理

#### 3.6.1 74HC595

74HC595 是一种 8 位串入并出移位寄存器，常用于位宽扩展和串并转换应用。在本设计中，74HC595 移位寄存器的关键引脚和功能如下：

- **SH_CP（移位时钟）**：每个上升沿触发一次移位，将 DS 输入的 1 位数据移入寄存器。
- **DS（数据输入）**：串行数据输入端，每次上升沿输入 1 位数据。
- **ST_CP（存储时钟）**：用于将移位寄存器的数据锁存至输出寄存器。当 ST_CP 接收到上升沿时，当前移位寄存器的内容将锁存到 Q0-Q7 并行输出端。
- **Q0-Q7**：并行数据输出，显示当前寄存器内容。

在 `HC595_Driver` 模块中，时钟信号 `SH_CP` 的上升沿用于控制移位操作，而 `ST_CP` 的上升沿则用于将移位寄存器的数据传递至输出。该设计通过状态机控制移位和数据锁存，使得输入的数据能够依次移位输出至 Q0-Q7，从而实现串并转换。

#### 3.6.2 线性序列机

`HC595_Driver` 的实现依赖于一个线性序列机的工作原理。线性序列机是一种按顺序执行状态变化的有限状态机，在本设计中用于控制输出逻辑，使每个状态的输出对应于寄存器中的一位数据。序列机设计步骤如下：

1. **状态寄存器**：`SHCP_EDGE_CNT` 记录了当前状态，用于标识当前移位进度，每个时钟周期都会更新状态。
2. **逻辑网络**：基于 `SHCP_EDGE_CNT` 的值逐步控制输出引脚 `SH_CP`、`DS`、`ST_CP`。每个状态下，依次更新 DS 的输出值，并在达到计数边界时触发 `ST_CP` 锁存操作。

在本设计中，线性序列机的状态从 0 开始计数到 32，对应于一次完整的数据输出。`SHCP_EDGE_CNT` 在每个时钟周期递增，通过判断其值控制输出逻辑。

#### 3.6.3 设计方案

`HC595_Driver` 的具体设计流程如下：

1. **输入数据加载**：当 S_EN 使能信号有效时，将输入数据 `Data` 写入到 `r_data` 寄存器中，作为后续移位操作的输入源。
2. **分频计数器**：在 `Clk` 上建立分频计数器 `divider_cnt`，在计数到 `CNT_MAX` 后产生 `sck_plus` 信号，用于控制 `SH_CP` 时钟信号的频率。
3. **移位状态机**：使用 `SHCP_EDGE_CNT` 控制 32 个状态的移位过程，每 2 个时钟周期完成一次移位操作，将 `r_data` 中的数据依次移位至 `DS`，并通过 `SH_CP` 时钟信号输出至 74HC595 的输入端。
4. **锁存输出**：在移位状态机完成所有数据移位操作后，生成 `ST_CP` 脉冲信号，锁存数据至输出端 Q0-Q7。

### 3.6.4 整体方框图及原理

以下方框图展示了 `HC595_Driver` 的整体设计结构：

```
            +-------------------------------+
            |           HC595_Driver        |
            |                               |
            |    +----------------------+   |
    Clk ---->    | 分频计数器 divider  |    |
            |    +----------------------+   |
            |              |                |
    Data ----->     状态机 SHCP_EDGE_CNT    |
            |              |                |
            |    +----------------------+   |
   Reset_n-->    | 控制信号生成器      |    |
            |    | SH_CP、ST_CP、DS     |   |
            +-------------------------------+
```
