<style type="text/css">
<!--
  H1 {
    font-family: Current Schoolbook, Arial;
    background-color: blue;
    color: rgb(192,192,192);
    letter-spacing: 2px;
    font-weight: bold;
    text-align: center;
    border: thin outset rgb(192,192,192);
    margin-left: 25px;
    margin-right: 25px;
    margin-top: 10px;
    padding: 2px;
  }
  -->
</style>

<?
	//  Sección multimedia

	include("conexion.php");

	// vemos el número total de imagenes y videos
	$consulta="SELECT count(*) FROM Multimedia WHERE View='Y'";
	$resultado=mysql_query($consulta,$conex);
	$fila=mysql_fetch_array($resultado);
	$num_imagenes=$fila[0];

	// preparamos la lectura de las imagenes
	if ( $opcion == "todas" ) {
		echo "<title>Resultado Elementos Multimedia</title>";
		echo "<CENTER><H1>Ficheros ordenados por Tipo, Categoría y Fecha</H1></CENTER>";
		$consulta="SELECT * FROM Multimedia WHERE View='Y' ORDER BY Tipo, Categoria1, Categoria2, Fecha DESC";
	} else if ( $opcion == "seleccion" ) {
		echo "<CENTER><H1>Resultado Búsqueda de Imágenes/Videos</H1></CENTER>";
		echo "<title>Resultado Imágenes/Videos</title>";
		$consulta="SELECT * FROM Multimedia WHERE View='Y' AND ";
		if ($Tipo <> "") {
			$consulta=$consulta." Tipo LIKE '".$Tipo."' AND ";
		}
		if ($Categoria1 <> "") {
			$consulta=$consulta." Categoria1 LIKE '".$Categoria1."' AND ";
		}
		if ($Categoria2 <> "") {
			$consulta=$consulta." Categoria2 LIKE '".$Categoria2."' AND ";
		}
		$consulta=$consulta." Fecha >= '".$Fecha."' ORDER BY Fecha LIMIT ".$Limite;
//		echo $consulta;
	}
	else {
		$consulta="SELECT * FROM Multimedia WHERE View='Y' ORDER BY Fecha DESC LIMIT 10";
	}
	
	// realizamos la consulta
	$resultado=mysql_query($consulta,$conex);
	
	// Ponemos información general
	?>
	<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
		<TR>
			<TD width="2%">&nbsp;</TD>
			<TD width="48%" bgcolor="lightgrey" align="left"><B><I>&nbsp;Sección Imágenes/Videos</I></B></TD>
			<TD width="48%" bgcolor="lightgrey" align="right"><I>Número total de ficheros: <?echo $num_imagenes?></I>&nbsp;</TD>
			<TD width="2%">&nbsp;</TD>
		</TR>
	</TABLE>
	<BR>
	<?
			
	// bucle para representar los downloads
	while ($imagen=mysql_fetch_array($resultado) ) {
		$fecha=formato_fecha($imagen['Fecha']);

		?>

		<TABLE bgcolor="lightyellow" width="98%" border="1" cellspacing="0" cellpadding="0" align="center">
			<TR>
					<? if ($imagen['Tipo']=="Foto" || $imagen['Tipo']=="Pantallazo" ) { 
						echo "<TD rowspan='4' width='15%'>";
						echo "<img name='multimedia' src='".$imagen['Download']."' border='0' width='100' height='70'>";
						echo "</TD>";
					} else { 
						echo "<TD width='15%' rowspan='4' align='center'>".$imagen['Tipo']."</TD>";
					}?>
				<TD width="15%" align="center" rowspan="4">
					<B>&nbsp;<?echo $imagen['Titulo']?>&nbsp;</B><BR>
					<font size="-1"><I><?echo $imagen['Tipo'];?> : <?echo $fecha?></I></font><BR>
					<font size="-1"><I><?echo $imagen['Categoria1'];?></I></font><BR>
					<font size="-1"><I><?echo $imagen['Categoria2']?></I>&nbsp;</font><BR>
				</TD>
				<TD width="55%" align="left" rowspan="4" align="center">&nbsp;<?echo $imagen['Descripcion']?></TD>
				<TD width="15%" align="center"><A href="<?echo $imagen['Download']?>"><font size="-1"><B>Descarga</B></FONT></A></TD>
			</TR>
			<TR>
				<TD bgcolor="" align="center"><A href="<?echo $imagen['Enlace']?>"><font size="-1"><B>Más información</B></FONT></A></TD>
			</TR>
		</TABLE>
		<BR>
		<?
	}

	if ( $opcion == "" ) {
	?>

	<!-- ponemos una sección de búsquedas -->
	<TR>	
		<TD bgcolor="#6495ED"><!-- @@@ vacio --></TD>
					
		<!-- pongo la zona de búsquedas asociada a esta página -->
		
		<TD colspan=3 bgcolor="white" align="center">
			<? form_imagenes(); ?>
		</TD>
	</TR>
	<?
	}
	
	// liberamos la conexión
	mysql_free_result($resultado);
	mysql_close($conex);


function formato_fecha( $fecha ) {
	return $fecha;
}

function form_imagenes() {
	?>
	<HR NOSHADE>
		<FORM name='formulario' method='POST' Action=''>
		<TABLE align='center'>
		<TR bgcolor='silver'>
			<TD><B>Tipo</B></TD>
			<TD>  
				<? $texto=''; set_columna( "Multimedia"," Tipo", "Tipo", $texto) ; ?>
			</TD>
			<TD><B>Categoria1</B></TD>
			<TD>  
				<? $texto=''; set_columna( "Multimedia"," Categoria1", "Categoria1", $texto) ; ?>
			</TD>
			<TD><B>Fecha origen</B></TD>
			<TD> 
			<SCRIPT LANGUAGE="javascript">
			<!--
				today=new Date();
				var ie4=document.all?1:0
				var s_year=today.getYear()-1;
				var s_day=today.getDate();
				var s_month=today.getMonth()+1;
					
				if (!ie4) { s_year=s_year+1900; }  // pongo la fecha segun el tipo de navegador
				document.write("<INPUT type='text' name='s_year' size=5 maxlength=4 value="+s_year+" onchange='check_date()'>");
				document.write("<INPUT type='text' name='s_month' size=3 maxlength=2 value="+s_month+" onchange='check_date()'>");
				document.write("<INPUT type='text' name='s_day' size=3 maxlength=2 value="+s_day+" onchange='check_date()'>"); 
			-->
			</SCRIPT>
			</TD>
			<TD><B>Límite</B></TD>
			<TD><input type='text' name='Limite' size='5' maxlength='5' value='10'></TD>
		</TR>
		<TR bgcolor='silver'>
			<TD colspan='2'></TD>
			<TD><B>Categoria2</B></TD>
			<TD>
				<? $texto=''; set_columna( "Multimedia"," Categoria2", "Categoria2", $texto) ; ?>
			</TD>
			<TD align='right' colspan='2'>
				<BUTTON name='buscar' onClick="window.open(pon_llamada(),'Resultado')"> Buscar </BUTTON>
			</TD>
			<TD colspan='2'>
				<BUTTON name='todos' onClick="window.open('imagenes.php?opcion=todas','Resultado')"> Ver Todas </BUTTON>
			</TD>
		</TR>
	</TABLE>
	</FORM>
	<HR NOSHADE>
<?
}


// Pone en una lista select la columna seleccionada de una tabla
function set_columna($tabla, $campo, $nombre,$orden) {
	echo "<SELECT name='".$nombre."' onchange='".$orden."' >";
	$consulta="select ".$campo." from ".$tabla." group by ".$campo;
	$resultado=mysql_query($consulta);
	if ( !empty($resultado)) {
		while ($row=mysql_fetch_row($resultado) ) {
			echo "<OPTION value=\"".$row[0]."\">".$row[0];  
		}
		mysql_free_result($resultado);
	}
	echo "</SELECT>";
}
?>

<SCRIPT LANGUAGE="javascript">


/*
	verificamos la fecha
	los valores en lugar de introducirlos como parámetros
	los tomamos directamente del HTML
*/
function check_date() {

	var v_anno=document.formulario.s_year.value;
	var v_month=document.formulario.s_month.value;
	var v_day=document.formulario.s_day.value;
	
	var fecha_hoy=new Date();
	var fecha_dato=new Date(v_anno,v_month-1,v_day);

	if ( v_month<1 || v_month>12) {	alert("Mes incorrecto: "+v_month); }
	if ( v_day<1 || v_day>31) { alert("Día incorrecto: "+v_day); }
	if (fecha_hoy.getTime() < fecha_dato.getTime() ) {
			alert("Futuro ??? "+v_anno+"-"+v_month+"-"+v_day);
	}
}

<!--
function pon_llamada() {
	var llamada="imagenes.php?opcion=seleccion";
	var date=(document.formulario.s_year.value*10000)+(document.formulario.s_month.value*100)+(document.formulario.s_day.value*1);
	llamada=llamada+"&Limite="+document.formulario.Limite.value;				
	llamada=llamada+"&Categoria1="+document.formulario.Categoria1.value;
	llamada=llamada+"&Tipo="+document.formulario.Tipo.value;
	llamada=llamada+"&Fecha="+date;
	llamada=llamada+"&Categoria2="+document.formulario.Categoria2.value;
	
	return llamada;
}
-->
				</SCRIPT>
