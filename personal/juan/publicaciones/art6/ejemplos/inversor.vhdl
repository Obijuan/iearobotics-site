library ieee;
use ieee.std_logic_1164.all;

entity inversor is
  
  port (
    entrada : in  std_logic;
    salida  : out std_logic);

end inversor;

architecture beh of inversor is

begin  -- beh

  salida <= not entrada;

end beh;
