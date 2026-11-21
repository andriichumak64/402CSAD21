--------------------------------------------------------------------------------
-- Файл      : tb_spi.vhd
-- Проєкт    : Лабораторна робота №3, варіант 21 (SPI, VHDL)
-- Опис      : Тестбенч для функціональної верифікації SPI (режим 0, 8 біт, MSB first).
--             Імітує зовнішнє середовище:
--               * генерує тактовий сигнал clk (50 МГц) та сигнал скидання rst;
--               * подає тестові слова на вхід передавача Master (tx_data + start);
--               * Slave імітує «інший пристрій»: приймає слово від Master (перевірка
--                 Tx Master / Rx Slave) і віддає власне слово (перевірка Rx Master).
--             Тестбенч самоперевірний: після кожного обміну порівнюються
--             отримані слова з очікуваними, підсумок виводиться в консоль.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_spi is
end entity tb_spi;

architecture sim of tb_spi is

    constant CLK_PERIOD : time    := 20 ns;   -- 50 МГц
    constant DATA_WIDTH : integer := 8;
    constant CLK_DIV    : integer := 8;       -- f_SCK = 50 МГц / (2*8) = 3.125 МГц

    -- Сигнали, що з'єднують Master і Slave
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal sim_done : boolean   := false;

    signal start     : std_logic := '0';
    signal m_tx_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal m_rx_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal busy      : std_logic;
    signal done      : std_logic;

    signal sck  : std_logic;
    signal mosi : std_logic;
    signal miso : std_logic;
    signal ss_n : std_logic;

    signal s_tx_data  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal s_rx_data  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_rx_valid : std_logic;

    -- Допоміжна функція: слово у вигляді шістнадцяткового рядка (для повідомлень)
    function to_hex (v : std_logic_vector(7 downto 0)) return string is
        constant digits : string(1 to 16) := "0123456789ABCDEF";
        variable hi : integer := to_integer(unsigned(v(7 downto 4)));
        variable lo : integer := to_integer(unsigned(v(3 downto 0)));
    begin
        return "0x" & digits(hi + 1) & digits(lo + 1);
    end function;

begin

    ----------------------------------------------------------------------------
    -- Перевіряємий пристрій 1: Master (Tx + Rx)
    ----------------------------------------------------------------------------
    dut_master : entity work.spi_master
        generic map (DATA_WIDTH => DATA_WIDTH, CLK_DIV => CLK_DIV)
        port map (clk => clk, rst => rst, start => start,
                  tx_data => m_tx_data, rx_data => m_rx_data,
                  busy => busy, done => done,
                  sck => sck, mosi => mosi, miso => miso, ss_n => ss_n);

    ----------------------------------------------------------------------------
    -- Перевіряємий пристрій 2: Slave («зовнішній пристрій»)
    ----------------------------------------------------------------------------
    dut_slave : entity work.spi_slave
        generic map (DATA_WIDTH => DATA_WIDTH)
        port map (clk => clk, rst => rst,
                  tx_data => s_tx_data, rx_data => s_rx_data, rx_valid => s_rx_valid,
                  sck => sck, mosi => mosi, miso => miso, ss_n => ss_n);

    ----------------------------------------------------------------------------
    -- Генератор тактового сигналу
    ----------------------------------------------------------------------------
    clk_gen : process
    begin
        while not sim_done loop
            clk <= '0'; wait for CLK_PERIOD / 2;
            clk <= '1'; wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    ----------------------------------------------------------------------------
    -- Сценарій тестування
    ----------------------------------------------------------------------------
    stimulus : process
        variable errors : integer := 0;
        variable tests  : integer := 0;

        -- Один повний обмін: Master передає m_word, Slave віддає s_word
        procedure transfer (m_word : in std_logic_vector(7 downto 0);
                            s_word : in std_logic_vector(7 downto 0)) is
        begin
            m_tx_data <= m_word;
            s_tx_data <= s_word;
            wait until rising_edge(clk);
            start <= '1';                              -- імпульс запуску на 1 такт
            wait until rising_edge(clk);
            start <= '0';
            wait until rising_edge(clk) and done = '1'; -- очікування завершення обміну
            wait for 2 * CLK_PERIOD;                   -- час на встановлення rx_valid/rx_data Slave

            tests := tests + 1;
            -- Перевірка Tx (Master -> Slave): Slave має прийняти m_word
            if s_rx_data = m_word then
                report "TX OK  : Master sent " & to_hex(m_word) & ", Slave received " & to_hex(s_rx_data);
            else
                report "TX ERROR: sent " & to_hex(m_word) & ", received " & to_hex(s_rx_data) severity error;
                errors := errors + 1;
            end if;
            -- Перевірка Rx (Slave -> Master): Master має прийняти s_word
            if m_rx_data = s_word then
                report "RX OK  : Slave sent " & to_hex(s_word) & ", Master received " & to_hex(m_rx_data);
            else
                report "RX ERROR: sent " & to_hex(s_word) & ", received " & to_hex(m_rx_data) severity error;
                errors := errors + 1;
            end if;
            wait for 4 * CLK_PERIOD;                   -- пауза між обмінами
        end procedure;
    begin
        -- Скидання
        rst <= '1';
        wait for 5 * CLK_PERIOD;
        rst <= '0';
        wait for 5 * CLK_PERIOD;

        -- Тестові вектори (Master -> Slave / Slave -> Master)
        transfer(x"A5", x"3C");    -- чергування бітів
        transfer(x"5A", x"C3");    -- інвертований попередній шаблон
        transfer(x"FF", x"00");    -- усі одиниці / усі нулі
        transfer(x"00", x"FF");
        transfer(x"81", x"7E");    -- крайні біти (перевірка MSB/LSB)
        transfer(x"0F", x"F0");

        -- Повторне скидання під час простою: після нього обмін має працювати
        rst <= '1'; wait for 3 * CLK_PERIOD; rst <= '0'; wait for 3 * CLK_PERIOD;
        transfer(x"C9", x"36");

        report "SUMMARY: transfers = " & integer'image(tests) &
               ", errors = " & integer'image(errors);
        if errors = 0 then
            report "TEST PASSED" severity note;
        else
            report "TEST FAILED" severity failure;
        end if;

        sim_done <= true;
        wait;
    end process;

end architecture sim;
