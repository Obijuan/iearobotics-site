----------------------------------------------------
-- inversor.vhdl  (c) Juan Gonzalez. Dic   2002   --
----------------------------------------------------
-- Ejemplos para aprender VHDL                     -
--                                                 -
-- Creacion de una entidad que es un inversor      -
-- Licencia GPL                                    -
----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------
-- Se define una entidad que es un inversor
-- i: Entrada
-- o: Salida
--------------------------------------------
entity inversor is
  port (i : in std_logic; o: out std_logic);
end inversor;

architecture ttl of inversor is
begin
  o <= not i;
end ttl;



