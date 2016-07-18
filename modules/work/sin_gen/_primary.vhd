library verilog;
use verilog.vl_types.all;
entity sin_gen is
    port(
        clk             : in     vl_logic;
        sample_clk      : in     vl_logic;
        rst             : in     vl_logic;
        enable          : in     vl_logic;
        \out\           : out    vl_logic_vector(7 downto 0);
        new_period      : out    vl_logic;
        start_conv      : out    vl_logic;
        halfcycle       : out    vl_logic
    );
end sin_gen;
