//sdma boubdaries
`define A11 8
`define A12 16
`define A13 32
`define A14 64
`define A15 128 
`define A16 256 
`define A17 512 
`define A18 1024

//adma attributes
`define valid 0
`define End 1
`define DatTarg 2
`define AddrSel 3
`define BurstLen 11:4
`define DatTransDir 1:0

//global defines
`define BLKSIZE_W 12
`define BLKCNT_W 16
`define CMD_TIMEOUT_W 24
`define DATA_TIMEOUT_W 29

//cmd module interrupts
`define INT_CMD_SIZE 6
`define INT_CMD_CC 0        //Completion Error
`define INT_CMD_EI 1        //End bit Error
`define INT_CMD_CTE 2       //Timeout interrupt
`define INT_CMD_CCRCE 3     //CRC Error Interrupt
`define INT_CMD_CIE  4      //Index Error Interrupt
`define INT_CMD_DC 5        // Data line not busy

//data module interrupts
`define INT_DATA_SIZE 6
`define INT_DATA_CC 0
`define INT_DATA_EI 1
`define INT_DATA_CTE 2
`define INT_DATA_CCRCE 3
`define INT_DATA_CFE 4
`define INT_DATA_BRE 5

//command register defines
`define CMD_REG_SIZE 14
`define CMD_RESPONSE_CHECK 1:0
//`define CMD_BUSY_CHECK 2
`define CMD_CRC_CHECK 3
`define CMD_IDX_CHECK 4
`define CMD_WITH_DATA 5
`define CMD_INDEX 13:8

//register addreses
`define argument 8'h00
`define command 8'h04
`define resp0 8'h08
`define resp1 8'h0c
`define resp2 8'h10
`define resp3 8'h14
`define data_timeout 8'h18
`define controller 8'h1c
`define cmd_timeout 8'h20
`define clock_d 8'h24
`define reset 8'h28
`define voltage 8'h2c
`define capa 8'h30
`define cmd_isr 8'h34
`define cmd_iser 8'h38
`define data_isr 8'h3c
`define data_iser 8'h40
`define blksize 8'h44
`define blkcnt 8'h48
`define dst_src_addr 8'h60

//wb module defines
`define RESET_BLOCK_SIZE 12'd511
`define RESET_CLK_DIV 0
`define SUPPLY_VOLTAGE_mV 3300

//initialize command sequence
`define CMD_CONTENT_INDEX 39:0
`define CHECKCRC_INDEX 40
`define WAITBUSY_INDEX 41
`define SETTING_INDEX 43:42

`define NUM_INIT 4
`define INSTRU_WIDTH 44
`define RCA_ADDR 16'h0002
