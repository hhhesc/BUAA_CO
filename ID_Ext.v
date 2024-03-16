`timescale 1ns / 1ps
module ID_Ext(
    input [15:0] In,
    input [2:0] ExtCtrl,
    output [31:0] ExtRes
    );

`include "parameter.v"

    assign ExtRes = ExtCtrl==Ext_ZeroExt?{{16{1'b0}},{In}}: //0拓展
                    ExtCtrl==Ext_LeftShiftForTwo?{{14{1'b0}},{In},{2{1'b0}}}: //左移两位
                    ExtCtrl==Ext_SignExt?{{16{In[15]}},{In}}: //符号拓展
                    ExtCtrl==Ext_Lui?{{In},{16{1'b0}}}://lui
                    ExtCtrl==Ext_OneExt?{{16{1'b1}},{In}}:
                    0;


endmodule
