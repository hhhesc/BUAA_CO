`timescale 1ns/1ps
module HCU_JUD(
    input[31:0] instr,
    input condition,
    output CalReg,
    output CalImm,
    output Load,
    output Store,
    output Branch,
    output JR,
    output Jump,
    output Link,
    output MD,
    output Load_HILO,
    output Store_HILO,
    output newinstr,
    output[4:0] tar
    );

 Ctrl uut(
    .instr      (instr),
    .MD         (MD),
    .CalImm     (CalImm),
    .CalReg     (CalReg),
    .Store_HILO (Store_HILO),
    .Store      (Store),
    .Load_HILO  (Load_HILO),
    .Load       (Load),
    .Link       (Link),
    .JR         (JR),
    .Jump       (Jump),
    .newinstr   (newinstr),
    .condition  (condition),
    .Branch     (Branch)
    );

    assign tar = (CalReg||Load_HILO)?instr[`rd]: 
                 (CalImm||Load)?instr[`rt]: 
                 (Link)?31:
                 0;

endmodule: HCU_JUD