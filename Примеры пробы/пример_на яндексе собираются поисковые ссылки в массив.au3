#include <IE.au3>
#include <Array.au3>

HotKeySet('{Esc}', '_Exit'); выход по кнопке Esc
$j = 0 ;счетчик найденных ссылок
Dim $aLinks[$j + 1][2];массив, в котором будут храниться найденные ссылки

$sSearch = 'kseniya';слово, которое будем искать

$oIE = _IECreate('http://ya.ru');открываем IE
$oForm = _IEFormGetCollection($oIE, 0);получаем форму
$oSearch = _IEFormElementGetObjByName($oForm, 'text') ;получаем объект по имени
_IEFormElementSetValue($oSearch, $sSearch);вставляем слово для поиска
_IEFormSubmit($oForm, 0) ;отправляем запрос
_IELoadWait($oIE);ждем

;~ For $i = 0 To 4 ;будем искать ссылки на 5-и первых страницах с результатами поиска.
;~     If $i Then ;на первой странице уже искали
;~         $sText = _IEBodyReadText($oIE) ;читаем текст на странице
;~         If StringInStr($sText, 'следующая') Then ;если на странице есть этот текст
;~             _IELinkClickByText($oIE, 'следующая') ;кликаем по ссылке, т.е. переходим на следующую страницу
;~         Else ;если на странице нет текста 'следующая'
;~             ExitLoop;выходим из цикла
;~         EndIf
;~     EndIf
    $oLinks = _IELinkGetCollection($oIE) ;получаем коллекцию ссылок на странице
    For $oLink In $oLinks ;в цикле проверяем все ссылки на странице
        If StringInStr($oLink.innertext, $sSearch) Then ;если в тексте ссылки есть искомое слово
            $j += 1;увеличиваем счетчик на 1
            ReDim $aLinks[$j + 1][2];изменяем размер массива
            $aLinks[$j][0] = $oLink.innertext;добавляем в массив текст ссылки
            $aLinks[$j][1] = $oLink.href;добавляем в массив адрес ссылки
        EndIf
    Next
    $aLinks[0][0] = $j;присваиваем этому элементу массива число - количество найденных ссылок.
;~ Next
;_IEQuit($oIE) ;можно закрыть окно IE
_ArrayDisplay($aLinks, 'Найденные ссылки');показываем полученный массив
;теперь можно делать с найденными ссылками все, что Вам надо, например,
;сохранить найденные сведения в файл:
;~ $hFile = FileOpen(@ScriptDir & '\Links.txt', 2)
;~ FileWrite($hFile, 'По запросу "' & $sSearch & '" на yandex.ru найдено ' & $aLinks[0][0] & _
;~         ' ссылок:' & @CRLF & @CRLF)
;~ For $i = 1 To $aLinks[0][0]
;~     If $i <> $aLinks[0][0] Then
;~         FileWrite($hFile, $i & '. Текст ссылки: ' & $aLinks[$i][0] & @CRLF & _
;~                 'Адрес ссылки: ' & $aLinks[$i][1] & @CRLF & @CRLF)
;~     Else
;~         FileWrite($hFile, $i & '. Текст ссылки: ' & $aLinks[$i][0] & @CRLF & _
;~                 'Адрес ссылки: ' & $aLinks[$i][1])
;~     EndIf
;~ Next
;~ FileClose($hFile)
;~ MsgBox(64, '', 'Готово :)')

Func _Exit()
    _IEQuit($oIE)
    Exit
EndFunc   ;==>_Exit


;~ ;Подсчет ссылок на странице.
;~ #include <IE.au3>
;~ $oIE = _IE_Example ("basic")
;~ $oLinks = _IELinkGetCollection ($oIE)
;~ $iNumLinks = @extended
;~ MsgBox(4096, "Link Info", $iNumLinks & " links found")
;~ For $oLink In $oLinks
;~     MsgBox(4096, "Link Info", $oLink.href)
;~ Next