-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Tomas Dolak xdolak09

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal rd_en        : std_logic := '0';
    signal clk_cnt_en   : std_logic := '0';
    signal out_vld      : std_logic := '0';
    signal clk_cnt      : std_logic_vector(4 downto 0) := (others => '0');
    signal dat_cnt      : std_logic_vector(3 downto 0) := (others => '0');
    signal data_shift   : std_logic_vector(7 downto 0) := (others => '0');
    signal cnt_mitbit   : std_logic_vector(3 downto 0) := (others => '0');
    signal re_end       : std_logic := '0';
    signal rdy_start    : std_logic := '0';
    signal start        : std_logic := '0';
    signal dff1_out     : std_logic := '0';
    signal save_din     : std_logic := '0';
begin
    
    -- D flip-flop
    process(CLK, RST)
    begin
        if RST = '1' then
            dff1_out <= '0';
        elsif rising_edge(CLK) then
            dff1_out <= DIN;
        end if;
    end process;
    
    -- D flip-flop
    process(CLK, RST)
    begin
        if RST = '1' then
            save_din <= '0';
        elsif rising_edge(CLK) then
            save_din <= dff1_out;
        end if;
    end process;
    -- zde dva D klopne obvody, ktere jsou pripojeny seriove na DIN a vedou do shift_registru
    -- zarucuji konzistentnost vstupu 

    -- citc, ktery odpocitava zacatek a konec
    clk_cnt_counter : process(CLK) begin
        if rising_edge(CLK) then 
            if RST = '1' then 
                clk_cnt <= "00000";
            end if;
            if clk_cnt_en = '1' then
                clk_cnt <= clk_cnt + 1;
            else
                clk_cnt <= "00000";
            end if;
            if rd_en = '1' and clk_cnt(4) = '1' then
                clk_cnt <= "00001";
            end if;
        end if;
    end process;

    rdy_start <= '1' when clk_cnt = "10000" else '0';
    re_end <= '1' when clk_cnt = "10000" else '0';

    -- citac, ktery cita 16 cyklu CLK
    mitbit_counter: process(CLK) begin
        if rising_edge(CLK) then 
            if RST = '1' then 
                cnt_mitbit <= "0000";
            end if;
            if start = '1' then 
                cnt_mitbit <= cnt_mitbit + 1;
            else
                cnt_mitbit <= "1111";
            end if;
        end if;
    end process;

    -- citac, ktery cita pocet zaznamenanych bitu, vzdy kdyz se ma cist se 
    -- inkrementuje jeho hodnota
    data_counter: process(CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then
                dat_cnt <= "0000";
            else
                if rd_en = '1' and cnt_mitbit = "1111" then
                    dat_cnt <= dat_cnt + 1;
                end if;
                if rd_en = '0' then
                    dat_cnt <= "0000";
                end if;
            end if;
        end if;
    end process;  

    
                
    -- posuvny registr do ktere ho se ukladaji hodnoty ze INPUTU pokazde kdyz se napocita do sestnacteho taktu
    shift_register: process(CLK)
    begin
        if rising_edge(CLK) then
            if rd_en = '1' and cnt_mitbit = "1111" then
                data_shift <= save_din & data_shift(7 downto 1);
                end if;
            end if;
    end process;
    
    -- v moment kdy ma kompletni data -> odeslat na vystup 
    DOUT <= data_shift when out_vld = '1' else (others => '0');
    DOUT_VLD <= out_vld;
    
    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
        port map (
        CLK             => CLK,
        RST             => RST,
        DAT             => DIN,
        ALL_DATA_READ   => dat_cnt(3),
        READ_EN         => rd_en,
        CLK_CNT_EN      => clk_cnt_en,
        RE_END          => re_end,
        VALID           => out_vld,
        RDY_START       => rdy_start,
        START           => start
        );
            

end architecture;
                    
                    