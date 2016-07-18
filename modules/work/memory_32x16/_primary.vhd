library verilog;
use verilog.vl_types.all;
entity memory_32x16 is
    generic(
        data_width      : integer := 16;
        address_width   : integer := 5;
        ram_depth       : integer := 32
    );
    port(
        data_1          : in     vl_logic_vector;
        data_2          : out    vl_logic_vector;
        wr_en1          : in     vl_logic;
        rd_en2          : in     vl_logic;
        clk             : in     vl_logic;
        address_1       : in     vl_logic_vector;
        address_2       : in     vl_logic_vector
    );
end memory_32x16;
