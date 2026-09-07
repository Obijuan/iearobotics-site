package test is
  function holac return integer;
  attribute foreign of holac : function is "VHPIDIRECT holac";
end test;

package body test is
  function holac return integer is
  begin
    assert false severity failure;
  end holac;
end test;

-------------------------------------------------------------------------------
-- Programa Hola mundo
-- Tomado del manual de GHDL
-------------------------------------------------------------------------------
use std.textio.all;
use work.test.holac;

entity hola_mundo is
end hola_mundo;

architecture beh of hola_mundo is
begin
  process
    variable l : line;
    variable v : integer;
  begin
    l := new string'("Hola desde VHDL...");
    writeline (output, l);
    v:=holac;
    wait;
  end process;
end beh;

