--------------------------------------------------------------------------------
-- Файл      : spi_master.vhd
-- Проєкт    : Лабораторна робота №3, варіант 21 (SPI, VHDL)
-- Опис      : SPI Master, режим 0 (CPOL = 0, CPHA = 0), порядок бітів MSB first.
--             Модуль виконує дві функції одночасно (дуплекс):
--               * передавач (Tx): зсувний регістр tx_shift виставляє біти на MOSI;
--               * приймач   (Rx): зсувний регістр rx_shift збирає біти з MISO.
--             Тактовий сигнал SCK формується дільником частоти з параметром CLK_DIV.
--
-- Тайминги режиму 0:
--   * у стані спокою SCK = 0, SS_N = 1;
--   * дані на MOSI змінюються по спадному фронту SCK (та при активації SS_N);
--   * дані з MISO фіксуються по зростаючому фронту SCK.
--
-- Частота SCK = f_clk / (2 * CLK_DIV).
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master is
    generic (
        DATA_WIDTH : positive := 8;  -- розрядність слова, біт
        CLK_DIV    : positive := 8   -- тактів clk на півперіод SCK (>= 4, перевірено симуляцією)
    );
    port (
        clk     : in  std_logic;                                  -- системний такт
        rst     : in  std_logic;                                  -- синхронне скидання, активний рівень '1'
        start   : in  std_logic;                                  -- імпульс '1' запускає обмін
        tx_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);    -- слово для передачі
        rx_data : out std_logic_vector(DATA_WIDTH-1 downto 0);    -- прийняте слово (діє при done = '1' і до наступного обміну)
        busy    : out std_logic;                                  -- '1' поки триває обмін
        done    : out std_logic;                                  -- імпульс '1' (1 такт) після завершення обміну
        sck     : out std_logic;                                  -- тактовий сигнал SPI
        mosi    : out std_logic;                                  -- Master Out Slave In
        miso    : in  std_logic;                                  -- Master In Slave Out
        ss_n    : out std_logic                                   -- вибір Slave, активний рівень '0'
    );
end entity spi_master;

architecture rtl of spi_master is

    -- Стани скінченного автомата (FSM)
    type state_t is (IDLE,   -- очікування команди start
                     LOW,    -- SCK = 0: пів періоду очікування перед зростаючим фронтом
                     HIGH,   -- SCK = 1: пів періоду очікування перед спадним фронтом
                     TRAIL); -- завершальна пауза перед зняттям SS_N

    signal state    : state_t := IDLE;
    signal cnt      : natural range 0 to CLK_DIV-1 := 0;           -- лічильник півперіоду SCK
    signal bit_cnt  : natural range 0 to DATA_WIDTH-1 := 0;        -- номер поточного біта
    signal tx_shift : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); -- регістр передавача
    signal rx_shift : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); -- регістр приймача

    signal sck_r    : std_logic := '0';
    signal mosi_r   : std_logic := '0';
    signal ss_n_r   : std_logic := '1';
    signal busy_r   : std_logic := '0';
    signal done_r   : std_logic := '0';
    signal rx_data_r: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    -- Вихідні порти беруться з регістрів (без комбінаційних глітчів)
    sck     <= sck_r;
    mosi    <= mosi_r;
    ss_n    <= ss_n_r;
    busy    <= busy_r;
    done    <= done_r;
    rx_data <= rx_data_r;

    process (clk)
    begin
        if rising_edge(clk) then
            done_r <= '0';                       -- done - одиночний імпульс

            if rst = '1' then
                state     <= IDLE;
                cnt       <= 0;
                bit_cnt   <= 0;
                sck_r     <= '0';
                mosi_r    <= '0';
                ss_n_r    <= '1';
                busy_r    <= '0';
                tx_shift  <= (others => '0');
                rx_shift  <= (others => '0');
                rx_data_r <= (others => '0');
            else
                case state is

                    ------------------------------------------------------------
                    when IDLE =>
                        sck_r  <= '0';
                        ss_n_r <= '1';
                        busy_r <= '0';
                        if start = '1' then
                            tx_shift <= tx_data;                 -- завантаження слова
                            mosi_r   <= tx_data(DATA_WIDTH-1);   -- старший біт виставляється до першого SCK
                            ss_n_r   <= '0';                     -- вибір Slave
                            busy_r   <= '1';
                            bit_cnt  <= 0;
                            cnt      <= 0;
                            state    <= LOW;
                        end if;

                    ------------------------------------------------------------
                    when LOW =>                                  -- SCK = 0
                        if cnt = CLK_DIV-1 then
                            cnt      <= 0;
                            sck_r    <= '1';                     -- зростаючий фронт SCK
                            -- Rx: фіксація біта MISO у зсувний регістр приймача
                            rx_shift <= rx_shift(DATA_WIDTH-2 downto 0) & miso;
                            state    <= HIGH;
                        else
                            cnt <= cnt + 1;
                        end if;

                    ------------------------------------------------------------
                    when HIGH =>                                 -- SCK = 1
                        if cnt = CLK_DIV-1 then
                            cnt   <= 0;
                            sck_r <= '0';                        -- спадний фронт SCK
                            if bit_cnt = DATA_WIDTH-1 then
                                state <= TRAIL;                  -- усі біти передано
                            else
                                -- Tx: зсув і виставлення наступного біта на MOSI
                                tx_shift <= tx_shift(DATA_WIDTH-2 downto 0) & '0';
                                mosi_r   <= tx_shift(DATA_WIDTH-2);
                                bit_cnt  <= bit_cnt + 1;
                                state    <= LOW;
                            end if;
                        else
                            cnt <= cnt + 1;
                        end if;

                    ------------------------------------------------------------
                    when TRAIL =>                                -- пауза перед зняттям SS_N
                        if cnt = CLK_DIV-1 then
                            cnt       <= 0;
                            ss_n_r    <= '1';                    -- Slave знято з вибору
                            rx_data_r <= rx_shift;               -- публікація прийнятого слова
                            done_r    <= '1';
                            busy_r    <= '0';
                            state     <= IDLE;
                        else
                            cnt <= cnt + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

end architecture rtl;
