library ieee;
use ieee.std_logic_1164.all;

entity tb_inv is
end tb_inv;

architecture beh of tb_inv is

component inversor
    port (
    entrada : in  std_logic;
    salida  : out std_logic);
end component;

signal entrada : std_logic:='0';
signal salida  : std_logic;

begin  -- tb_inv

  -- Instanciar inversor
  INV: inversor
    port map (
      entrada => entrada,
      salida  => salida);

  -- Generar una senal cuadrada por la entrada del inversor
  process
  begin  -- process
    wait for 50 ns;
    entrada<= '0';
    wait for 20 ns;
    entrada<= '1';   
  end process;

end beh;
