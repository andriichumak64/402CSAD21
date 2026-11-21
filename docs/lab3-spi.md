# Лабораторна робота №3 - SPI на VHDL (варіант 21)

SPI Master (режим 0, 8 біт, MSB first) + Slave для перевірки + самоперевірний тестбенч.

| Файл | Призначення |
|---|---|
| `hdl/spi_master.vhd` | Master: передавач (MOSI) і приймач (MISO), дільник частоти SCK |
| `hdl/spi_slave.vhd` | Slave («інший пристрій»), синхронізація SCK/MOSI/SS_N |
| `tb/tb_spi.vhd` | Тестбенч: clk, rst, 7 обмінів, автоматична перевірка |
| `docs/fsm_master.png` | Діаграма станів передавача |
| `sim/run_ghdl.sh` | Запуск симуляції в GHDL |

Частота SCK = f_clk / (2 * CLK_DIV); у тестбенчі f_clk = 50 МГц, CLK_DIV = 8, SCK = 3.125 МГц.

## Симуляція
- **GHDL + GTKWave:** `./sim/run_ghdl.sh`, потім `gtkwave sim/spi.vcd`.
- **Vivado:** додати файли з `hdl/` як Design Sources, `tb/tb_spi.vhd` як Simulation Source (тип VHDL або VHDL 2008), Top = `tb_spi`, Run Simulation, `run 30 us`.
- **ModelSim/Questa:** `vcom hdl/*.vhd tb/tb_spi.vhd`, `vsim work.tb_spi`, `add wave -r /*`, `run 30 us`.
