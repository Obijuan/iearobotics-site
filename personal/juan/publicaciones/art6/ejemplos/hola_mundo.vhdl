-----------------------------
-- Programa Hola mundo
-- Tomado del manual de GHDL
-----------------------------
use std.textio.all;

entity hola_mundo is
end hola_mundo;

architecture beh of hola_mundo is
begin
  process
    variable l : line;
  begin
    l := new string'("¡¡Hola mundo!!");
    writeline (output, l);
    wait;
  end process;
end beh;

