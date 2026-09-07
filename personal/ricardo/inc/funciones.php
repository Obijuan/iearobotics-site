<?


// -------------------------------------------------------------------------
// -- ShowTitle: Show basic title, pass in title text
// -------------------------------------------------------------------------
function ShowTitle($PageName) {
global $PHP_SELF, $HTTP_SERVER_VARS;
print '<table cellspacing="0" width="100%" style="border:1px solid #020A31">';
print ' <tr>';
print ' <td rowspan="2" class="menu_title" width="100%">'.$PageName.'<br><span class="menu_address">http://'.$HTTP_SERVER_VARS['HTTP_HOST'].$PHP_SELF.'</span></td>';
print ' </tr>';
print ' </tr>';
print '</table>';
print '<p>';
}
function MenuTD($link, $text) {
global $menucount;
print '<td class="menu_top" nowrap onmouseover="this.style.backgroundColor=\'#111122\';" onmouseout="this.style.backgroundColor=\'#000000\';" onclick="menu'.$menucount.'.click();">';
print ' <a id="menu'.$menucount.'" class="menu_top" href="'.$link.'">'.$text.'</a>';
print '</td>';
}




// -------------------------------------------------------------------------
// -- ShowThumbTR: show thumbnail and link
// -------------------------------------------------------------------------
function ShowThumbTR($path, $FileName, $Description) {
$size = getimagesize($path.$FileName);
$thumbsize = getimagesize($path.'_'.$FileName);
print '<tr>';
print '<td class="ThumbImg">';
ShowThumb($path, $FileName, $Description);
print '</td>';
print '<td class="ThumbDescription" width="100%">'.$Description.'<p align="right"><i>'.$size[0].'x'.$size[1].', '.GetFileSize($path.$FileName).'</i></p></td>';
print '</tr>';
}
function ShowThumb($path, $FileName, $Description) {
$thumbsize = getimagesize($path.'_'.$FileName);
print '<a href="pictureviewer.php?File='.$path.$FileName.'&Description='.$Description.'"><img src="'.$path.''.$FileName.'" width="'.$thumbsize[0].'" height="'.$thumbsize[1].'" border="0"></a>';
}
function ShowImage($FileName) {
$size = getimagesize($FileName);
print '<center><img src="'.$FileName.'" width="'.$size[0].'" height="'.$size[1].'"></center>';
}


// -------------------------------------------------------------------------
// -- GetFileSize: returns file size with ,'s and k|M|Gb
// -------------------------------------------------------------------------
function GetFileSize($file) {
$size = number_format(filesize($file));
$size = substr($size, 0, strlen($size) - 4);

if (filesize($file) > 1000000000) {
$size = $size . 'GB';
} elseif (filesize($file) > 1000000) {
$size = $size . 'MB';
} elseif (filesize($file) > 1000) {
$size = $size . 'k';
} else {
$size = $size . ' bytes';
}
return $size;
}




// -------------------------------------------------------------------------
// -- ShowPic: show thumbnail and link for passed in file
// -------------------------------------------------------------------------
function ShowPic($Message) {
print "<p><font size=\"+1\" color=\"#DDDDFF\"><b>";
colorize($Message, "99ccff", "0099ff");
print "</b></font>";
}






// -------------------------------------------------------------------------
// -- h4: Formatting for header4
// -------------------------------------------------------------------------
function h4($Message) {
print "<p><font size=\"+1\" color=\"#DDDDFF\"><b>";
colorize($Message, "99ccff", "0099ff");
print "</b></font>";
}





// -------------------------------------------------------------------------
// -- colorize: gradient color change of $Message, from $Start to $End (hex), $Mirror determines if it's a straight gradient or a mirror
// -------------------------------------------------------------------------
function colorize($Message, $Start="99ccff", $End="0099ff", $Mirror='yes') {
$Length = strlen($Message);

$CurRed = $Start_Red = HexDec($Start[0] . $Start[1]);
$CurGreen = $Start_Green = HexDec($Start[2] . $Start[3]);
$CurBlue = $Start_Blue = HexDec($Start[4] . $Start[5]);
$End_Red = HexDec($End[0] . $End[1]);
$End_Green = HexDec($End[2] . $End[3]);
$End_Blue = HexDec($End[4] . $End[5]);

//print'<br><font color=white><b>debug:</b> Length='.$Length.'</font>';
//print'<br><font color=white><b>debug:</b> StartRed='.($Start_Red).'; StartGreen='.($Start_Green).'; StartBlue='.($Start_Blue).'</font>';
//print'<br><font color=white><b>debug:</b> EndRed='.($End_Red).'; EndGreen='.($End_Green).'; EndBlue='.($End_Blue).'</font>';
//print'<br><font color=white><b>debug:</b> RedSpan='.($End_Red-$CurRed).'; GreenSpan='.($End_Green-$CurGreen).'; BlueSpan='.($End_Blue-$CurBlue).'</font>';
if ($Mirror == 'yes') {
$StepRed = (abs($End_Red - $CurRed )) / ( ($Length-1) / 2 );
$StepGreen = (abs($End_Green - $CurGreen)) / ( ($Length-1) / 2 );
$StepBlue = (abs($End_Blue - $CurBlue )) / ( ($Length-1) / 2 );
} else {
$StepRed = (abs($End_Red - $CurRed )) / ($Length-1);
$StepGreen = (abs($End_Green - $CurGreen)) / ($Length-1);
$StepBlue = (abs($End_Blue - $CurBlue )) / ($Length-1);
}
if ($StepRed == 0) { $StepRed = 1; }
if ($StepGreen == 0) { $StepGreen = 1; }
if ($StepBlue == 0) { $StepBlue = 1; }
//print'<br><font color=white><b>debug:</b> StepRed='.$StepRed.'; StepGreen='.$StepGreen.'; StepBlue='.$StepBlue.'</font>';

for ($i = 0; $i < $Length; $i++) {
$Color = '#' . PadZero(DecHex($CurRed)) . PadZero(DecHex($CurGreen)) . PadZero(DecHex($CurBlue));
print '<font color="'.$Color.'">' . $Message[$i] . '</font>';

//print'<br><font color=white><b>debug:</b> i='.$i.'; CurRed='.$CurRed.'; Color='.$Color.'; start_Red='.$Start_Red.'; End_Red='.$End_Red.'; cur+step='.($CurRed+$StepRed).'</font>';
//print'<br><font color=white><b>debug:</b> i='.$i.'; CurGreen='.$CurGreen.'; Color='.$Color.'; start_Green='.$Start_Green.'; End_Green='.$End_Green.'; cur+step='.($CurGreen+$StepGreen).'</font>';
//print'<br><font color=white><b>debug:</b> i='.$i.'; CurBlue='.$CurBlue.'; Color='.$Color.'; start_blue='.$Start_Blue.'; End_Blue='.$End_Blue.'; cur+step='.($CurBlue+$StepBlue).'</font>';

if ($Mirror == 'yes' && $i >= round($Length / 2)) {

     if ($Start_Red > $End_Red) {
if (($CurRed + $StepRed ) <= $Start_Red) { $CurRed += $StepRed ; } else { $CurRed = $Start_Red; }
     } else {
if (($CurRed - $StepRed ) >= $Start_Red) { $CurRed -= $StepRed ; } else { $CurRed = $End_Red; }
     }
if ($Start_Green > $End_Green) {
if (($CurGreen + $StepGreen) <= $Start_Green) { $CurGreen += $StepGreen; } else { $CurGreen = $Start_Green; }
     } else {
if (($CurGreen - $StepGreen) >= $Start_Green) { $CurGreen -= $StepGreen; } else { $CurGreen = $End_Green; }
     }
if ($Start_Blue > $End_Blue) {
if (($CurBlue + $StepBlue ) <= $Start_Blue) { $CurBlue += $StepBlue ; } else { $CurBlue = $Start_Blue; }
     } else {
if (($CurBlue - $StepBlue ) >= $Start_Blue) { $CurBlue -= $StepBlue ; } else { $CurBlue = $End_Blue; }
}

} else { // mirror = no

     if ($Start_Red > $End_Red) {
if (($CurRed - $StepRed ) >= $Start_Red) { $CurRed -= $StepRed ; } else { $CurRed = $Start_Red; }
     } else {
if (($CurRed + $StepRed ) <= $End_Red) { $CurRed += $StepRed ; } else { $CurRed = $End_Red; }
     }
if ($Start_Green > $End_Green) {
if (($CurGreen - $StepGreen) >= $Start_Green) { $CurGreen -= $StepGreen; } else { $CurGreen = $Start_Green; }
     } else {
if (($CurGreen + $StepGreen) <= $End_Green) { $CurGreen += $StepGreen; } else { $CurGreen = $End_Green; }
     }
if ($Start_Blue > $End_Blue) {
if (($CurBlue - $StepBlue ) >= $Start_Blue) { $CurBlue -= $StepBlue ; } else { $CurBlue = $Start_Blue; }
     } else {
if (($CurBlue + $StepBlue ) <= $End_Blue) { $CurBlue += $StepBlue ; } else { $CurBlue = $End_Blue; }
}

}
}
}
function PadZero($Value) {
if (!$Value) { $Value = '0'; }
// print " (HexDec[$Value]: ".HexDec($Value);
if (HexDec($Value) <= 16) {
$Value = '0'.$Value;
}
// print " Final: $Value)";
return $Value;
}



// -------------------------------------------------------------------------
// -- FatalError: Fatal Error message, exit.
// -------------------------------------------------------------------------
function FatalError($Message, $Control="NULL") {
global $PHP_SELF;
$Line = $Control;

print "<p><font color=BB0000><b>Fatal Error:</b> $Message";
if ($Control != "NoFileMessage") {
print " </font><font size='-1'>( File: $PHP_SELF ";
if ($Line != "NULL") { print "Line $Line"; } else { print "Unknown Line"; }
print ", Generated: ".ConvertTimeDate()." )</font><br>";
}

exit();
}





// -------------------------------------------------------------------------
// -- Error: Normal Error, display error and continue.
// -------------------------------------------------------------------------
function Error($Message, $Line = "NULL") {
global $PHP_SELF;

print "<p><font color=BB0000><b>Error:</b> $Message </font><font size='-1'>( File: $PHP_SELF ";
if ($Line != "NULL") { print "Line $Line"; } else { print "Unknown Line"; }
print ", Generated: ".ConvertTimeDate()." )</font><br>";
}





// -------------------------------------------------------------------------
// -- UserError: Error on inputs, etc that the user generates, display error and continue.
// -------------------------------------------------------------------------
function UserError($Message, $Line = "NULL") {
global $PHP_SELF;

print "<p><font color=BB0000><b>Error:</b> $Message </font><br>";
}





// -------------------------------------------------------------------------
// -- D: Debug Error, display error and time/date and continue.
// -------------------------------------------------------------------------
function D($Message, $Line = "NULL") {
global $PHP_SELF;

print "<p><font color=00BB00><b>Debug:</b> $Message </font><font size='-1'>( File: $PHP_SELF ";
if ($Line != "NULL") { print "Line $Line"; } else { print "Unknown Line"; }
print ", Generated: ".ConvertTimeDate()." )</font><br>";
}





// -------------------------------------------------------------------------
// -- ConvertTimeDate: Converts raw time/date to nice looking output.
// -- $Raw = array with standard getdate() values
// -------------------------------------------------------------------------
function ConvertTimeDate($Raw = "NULL") {
global $PHP_SELF;

if ($Raw = "NULL") {
$temp = date("M.d.y") . " at " . date("g:i:sa");
} else {
$temp = date("M.d.y", $Raw) . " at " . date("g:i:sa", $Raw);
}

return $temp;

}





// -------------------------------------------------------------------------
// -- T_Start: starts tables, several styles, has first row header.
// -------------------------------------------------------------------------
function T_Start($Title1="Option", $Title2="Description", $Color='Blue') {
global $PHP_SELF;

if ($Color == 'Blue') {
$FillColor = '#0055aa';
$BorderColor = '#002277';
$TitleColor = '#ffffff';
}
if ($Color == 'Black') {
$FillColor = '#555555';
$BorderColor = '#000000';
$TitleColor = '#ffffff';
}
if ($Color == 'Red') {
$FillColor = '#770000';
$BorderColor = '#aa0000';
$TitleColor = '#ffffff';
}

print "<center>";
print "<table width=80% border=1 cellpadding=3 cellspacing=0 bordercolor=$BorderColor>";
print " <tr bgcolor=$FillColor>";
print " <td align=center><font color=$TitleColor><b>$Title1</b></font></td>";
print " <td align=center><font color=$TitleColor><b>$Title2</b></font></td>";
print " </tr>";

}



// -------------------------------------------------------------------------
// -- T_Row: For each row in the table.
// -------------------------------------------------------------------------
//## begin ########### T_Row ###################### Prints each line
function T_Row($LeftCell, $RightCell, $LeftAlign="center", $RightAlign="left") {
global $PHP_SELF;

print " <tr>";
print " <td align=$LeftAlign valign=middle>$LeftCell</td>";
print " <td align=$RightAlign valign=top>$RightCell</td>";
print " </tr>";

}



// -------------------------------------------------------------------------
// -- T_End: Ends tables
// -------------------------------------------------------------------------
//## begin ########### T_End ###################### Ends tables
function T_End() {
global $PHP_SELF;

print "</table><p>";
print "</center>";

}





?>

