--------------------------------------------------------------------------------
-- Файл      : spi_slave.vhd
-- Проєкт    : Лабораторна робота №3, варіант 21 (SPI, VHDL)
-- Опис      : SPI Slave, режим 0 (CPOL = 0, CPHA = 0), MSB first.
--             Слугує «іншим пристроєм» для перевірки Master у тестбенчі та
--             самостійною перевіркою приймача (Rx) і передавача (Tx) Slave.
--             Лінії SCK, MOSI, SS_N синхронізуються 2-тригерним синхронізатором
--             у домен системного такту clk, тому має виконуватись
--             f_clk >= 4 * f_SCK (у проєкті f_clk = 16 * f_SCK).
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave is
    generic (
        DATA_WIDTH : positive := 8
    );
    port (
        clk      : in  std_logic;                                 -- системний такт Slave
        rst      : in  std_logic;                                 -- синхронне скидання, активний рівень '1'
        tx_data  : in  std_logic_vector(DATA_WIDTH-1 downto 0);   -- слово, яке Slave віддає Master-у (діє на момент спаду SS_N)
        rx_data  : out std_logic_vector(DATA_WIDTH-1 downto 0);   -- слово, прийняте від Master
        rx_valid : out std_logic;                                 -- імпульс '1' (1 такт): rx_data оновлено
        sck      : in  std_logic;                                 -- тактовий сигнал від Master
        mosi     : in  std_logic;                                 -- дані від Master
        miso     : out std_logic;                                 -- дані до Master ('Z', коли Slave не вибрано)
        ss_n     : in  std_logic                                  -- вибір Slave, активний рівень '0'
    );
end entity spi_slave;

architecture rtl of spi_slave is

    -- Синхронізатори вхідних ліній (захист від метастабільності)
    signal sck_s1, sck_s2, sck_prev : std_logic := '0';
    signal mosi_s1, mosi_s2         : std_logic := '0';
    signal ss_s1, ss_s2, ss_prev    : std_logic := '1';

    signal rising_sck  : std_logic;   -- детектор зростаючого фронту SCK
    signal falling_sck : std_logic;   -- детектор спадного фронту SCK
    signal ss_fall     : std_logic;   -- початок обміну (спад SS_N)

    signal bit_cnt  : natural range 0 to DATA_WIDTH := 0;
    signal rx_shift : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); -- регістр приймача Slave
    signal tx_shift : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); -- регістр передавача Slave
    signal miso_r   : std_logic := '0';
    signal rx_data_r: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal valid_r  : std_logic := '0';

begin

    rising_sck  <= sck_s2 and (not sck_prev);
    falling_sck <= (not sck_s2) and sck_prev;
    ss_fall     <= (not ss_s2) and ss_prev;

    rx_data  <= rx_data_r;
    rx_valid <= valid_r;
    miso     <= miso_r when ss_s2 = '0' else 'Z';   -- шина MISO у високоімпедансному стані без вибору

    process (clk)
    begin
        if rising_edge(clk) then
            -- 2-тригерні синхронізатори та регістри попереднього значення
            sck_s1   <= sck;     sck_s2  <= sck_s1;   sck_prev <= sck_s2;
            mosi_s1  <= mosi;    mosi_s2 <= mosi_s1;
            ss_s1    <= ss_n;    ss_s2   <= ss_s1;    ss_prev  <= ss_s2;

            valid_r <= '0';

            if rst = '1' then
                bit_cnt   <= 0;
                rx_shift  <= (others => '0');
                tx_shift  <= (others => '0');
                miso_r    <= '0';
                rx_data_r <= (others => '0');

            elsif ss_fall = '1' then
                -- Початок обміну: завантаження слова на передачу, старший біт на MISO
                tx_shift <= tx_data;
                miso_r   <= tx_data(DATA_WIDTH-1);
                bit_cnt  <= 0;

            elsif ss_s2 = '0' then
                if rising_sck = '1' then
                    -- Rx: фіксація біта MOSI по зростаючому фронту SCK
                    rx_shift <= rx_shift(DATA_WIDTH-2 downto 0) & mosi_s2;
                    bit_cnt  <= bit_cnt + 1;
                    if bit_cnt = DATA_WIDTH-1 then
                        rx_data_r <= rx_shift(DATA_WIDTH-2 downto 0) & mosi_s2;
                        valid_r   <= '1';
                    end if;
                elsif falling_sck = '1' then
                    -- Tx: наступний біт на MISO по спадному фронту SCK
                    tx_shift <= tx_shift(DATA_WIDTH-2 downto 0) & '0';
                    miso_r   <= tx_shift(DATA_WIDTH-2);
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
