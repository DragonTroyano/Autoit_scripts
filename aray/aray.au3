#include <array.au3>
Local $array[3][2], $array_new[0][2], $file = @ScriptDir & '\1.txt'
$array[0][0] = 1
$array[0][1] = 2
$array[1][0] = 3
$array[1][1] = 4
$array[2][0] = 5
$array[2][1] = 6

_ArrayDisplay($array, 'Исходный массив')
FileWriteFromArray($file, $array)
File_ReadToArray($file, $array_new)
_ArrayDisplay($array_new, 'Чтение из файла')

Func FileWriteFromArray($spath, $sarray)
    Local $fo = FileOpen($spath,1)
    For $i = 0 To UBound($sarray) - 1
        FileWriteLine($spath, $sarray[$i][0] & '|' & $sarray[$i][1])
    Next
    FileClose($fo)
EndFunc   ;==>FileWriteFromArray

Func File_ReadToArray($spath_f, ByRef $sarray_f)
    Local $line = 1, $index = 0, $col = 1
    Local $fo = FileOpen($spath_f)
    While 1
        $frl = FileReadLine($spath_f, $line)
        If @error = -1 Then
            FileClose($fo)
            Return
        EndIf
        $strsplt = StringSplit($frl,'|',2)
        ReDim $sarray_f[$col][2]
        $sarray_f[$index][0] = $strsplt[0]
        $sarray_f[$index][1] = $strsplt[1]
        $line += 1
        $index += 1
        $col += 1
    WEnd
EndFunc   ;==>File_ReadToArray