library verilog;
use verilog.vl_types.all;
entity syn_fifo is
    generic(
        data_width      : integer := 24;
        address_width   : integer := 5;
        ram_depth       : integer := 32
    );
    port(
        data_out        : out    vl_logic_vector;
        full            : out    vl_logic;
        empty           : out    vl_logic;
        data_in         : in     vl_logic_vector;
        clk             : in     vl_logic;
        rst_a           : in     vl_logic;
        wr_en           : in     vl_logic;
        rd_en           : in     vl_logic
    );
end syn_fifo;
