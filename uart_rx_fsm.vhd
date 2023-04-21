-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Tomas Dolak xdolak09

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
        CLK             : in    std_logic;
        RST             : in    std_logic;
        DAT             : in    std_logic;
        ALL_DATA_READ   : in    std_logic;
        RDY_START       : in    std_logic;
        RE_END          : in    std_logic;
        READ_EN         : out   std_logic;
        CLK_CNT_EN      : out   std_logic;
        START           : out   std_logic;
        VALID           : out   std_logic
    );
end entity;

architecture behavioral of UART_RX_FSM is
type t_state is (IDLE, START_BIT, RECEIVE_DATA, STOP_BIT, DATA_VALID);
signal next_state   : t_state;
signal state        : t_state;
begin
    
    -- Present state register
    state_register: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= IDLE;
                else
                state <= next_state;
            end if;
        end if;
    end process;
    

    -- next state combinatorial logic 
    next_state_logic: process (CLK,DAT,RDY_START,ALL_DATA_READ,RE_END,state) 
    begin
        next_state <= state;            
        case state is
            when IDLE => 
            if DAT = '0' then
                next_state <= START_BIT;
            end if;
            when START_BIT =>
                if RDY_START = '1' then
                    next_state <= RECEIVE_DATA;
                end if;
            when RECEIVE_DATA =>
                if ALL_DATA_READ = '1' then
                    next_state <= STOP_BIT;
                    end if;
            when STOP_BIT =>
                if RE_END = '1' then
                    next_state <= DATA_VALID;
                end if;
            when DATA_VALID => 
                next_state <= IDLE;
            end case;  
    end process;
    
    -- output logic 
    READ_EN <= '1' when state = RECEIVE_DATA else '0';
    VALID <= '1' when state = DATA_VALID else '0';
    CLK_CNT_EN <= '0' when state = DATA_VALID or state = IDLE else '1';
    START <= '1' when state = RECEIVE_DATA else '0';
                
end architecture;