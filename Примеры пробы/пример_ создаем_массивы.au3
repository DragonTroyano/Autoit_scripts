; Скрипт показывающий массивы


#include <Array.au3> ; для _ArrayDisplay.

Local $aArray[10][5]
Local $iRows = UBound($aArray, 1) ; Обще количество строк. В данном примере 10.
Local $iCols = UBound($aArray, 2) ; Обще количество колонок. В данном примере 5.
Local $iDimension = UBound($aArray, 0) ; Размерность массива, к примеру 1/2/3 -мерный.

MsgBox(4096, "", "Массив " & $iDimension & '-мерный' & @CRLF & _
        'с количеством строк ' & $iRows & @CRLF & _
        'с количеством колонок: ' & $iCols)

; Заполнение массива данными
For $i = 0 To $iRows - 1
    For $j = 0 To $iCols - 1
        $aArray[$i][$j] = "стр: " & $i & ", кол: " & $j
    Next
Next

; Просмотр массива
_ArrayDisplay($aArray, 'С указанием строки и колонки в ячейках')