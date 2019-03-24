# _IExploreCreate запуск Internet Explorer, приватный режим и автозакрытие

## Функция: 

_IExploreCreate

В отличие от _IECreate функция _IExploreCreate создаст объект IE с первого раза.
Может создавать браузер в приватном (Private) режиме
Может автоматически закрывать браузер после завершения скрипта.
Функция не следит за процессами, а создает работу, в которую помещает все дочерние процессы, и как только родительский завершается - работа удаляется и вместе с ней - закрывается браузер, со всеми вкладками. 
Это очень удобно тем, что не нужно следить за случайно забытыми и не закрытыми окнами. Система закроет все автоматически, даже если ваш скрипт упадет с ошибкой.

Функция содержит 3 параметра: 1 - URL сайта, 2 - открывать в приватном режиме или нет, 3 - автоматически закрывать или нет.

```
_IExploreCreate($sUrl = 'about:blank', $fInPrivate = True, $fInJob = True)
```

```
#include <WinAPIProc.au3>
#include <WinAPI.au3>

$oIe = _IExploreCreate('ya.ru')
ConsoleWrite('PID: ' & @extended & @CRLF)
MsgBox(0, '', 'Когда завершится этот скрипт, то закроется браузер' & @CRLF & 'Нажмите OK что бы завершить скрипт')
```

### Примечание

Не забывайте в начале сделать #include стандартных библиотек: WinAPIProc.au3, WinAPI.au3
### Примечание
В отличие от _IECreate имеет другие параметры и не ожидает загрузки страницы. Для ожидания используйте _IELoadWait

```
#include <WinAPIProc.au3>
#include <WinAPI.au3>
; #FUNCTION# ====================================================================================================================
; Name ..........: _IExploreCreate
; Description ...: Запускает Internet Explorer. Может запускать в приватном режиме. При завершении скрипта может закрывать браузер автоматически
; Syntax ........: _IExploreCreate([$sUrl = 'about:blank'[, $fInPrivate = True[, $fInJob = True]]])
; Parameters ....: $sUrl Открыть URL                                 - [optional] A string value. Default is 'about:blank'.
;                  $fInPrivate Запустить в приватном режиме          - [optional] A boolean value. Default is True.
;                  $fInJob Закрывать браузер, при завершении скрипта - [optional] A boolean value. Default is True.
; Return values .: Успех - Возвращает объект IE, @extended - PID браузера.
;                  Ошибка - Возвращает False и устанавливает @error
;                  |1 - Не удалось выполнить _WinAPI_CreateJobObject.
;                  |2 - Не удалось выполнить _WinAPI_SetInformationJobObject
;                  |3 - Не удалось выполнить _WinAPI_CreateProcess
;                  |4 - Не удалось выполнить _WinAPI_AssignProcessToJobObject
;                  |5 - Не удалось выполнить Run
;                  |6 - Не удалось дождаться окна IE за 30 секунд
;                  |7 - Не удалось получить объект IE
; Author ........: inververs
; Remarks .......: Функция не дожидается загрузки сайта. Для этого используйте _IELoadWait
; Related .......: _IECreate
; Link ..........: http://autoit-script.ru/index.php?topic=21877.msg128341#msg128341
; Example .......: _IExploreCreate('ya.ru')
; ===============================================================================================================================
Func _IExploreCreate($sUrl = 'about:blank', $fInPrivate = True, $fInJob = True)
    ;Генерируем уникальный URL, благодаря этому мы можем найти окно с этим текстом.
    Local $url = 'about:' & Random(), $sCmd

    ;Если запускаем в приватном режиме, то добавляем соответствующие ключи.
    ;Подробнее здесь https://msdn.microsoft.com/en-us/library/hh826025(v=vs.85).aspx
    If $fInPrivate = Default Or $fInPrivate Then
        $sCmd = @ProgramFilesDir & "\Internet Explorer\iexplore.exe -noframemerging -private " & $url
    Else
        $sCmd = @ProgramFilesDir & "\Internet Explorer\iexplore.exe " & $url
    EndIf

    ;Для автоматического закрытия браузера после прекращения скрипта, создаем работу и добавляет туда дочерние процессы.
    ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms684161(v=vs.85).aspx
    If $fInJob = Default Or $fInJob Then
        Local $hJob = _WinAPI_CreateJobObject()
        If Not $hJob Then Return SetError(1, 0, False)

        ;https://msdn.microsoft.com/en-us/library/windows/desktop/ms684147(v=vs.85).aspx
        Local $tInfo = DllStructCreate($tagJOBOBJECT_EXTENDED_LIMIT_INFORMATION)
        DllStructSetData($tInfo, 'LimitFlags', $JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE)

        Local Const $JobObjectExtendedLimitInformation = 9

        If Not _WinAPI_SetInformationJobObject($hJob, $JobObjectExtendedLimitInformation, $tInfo) Then
            _WinAPI_CloseHandle($hJob)
            Return SetError(2, 0, False)
        EndIf

        Local $tProcess = DllStructCreate($tagPROCESS_INFORMATION)
        Local $tStartup = DllStructCreate($tagSTARTUPINFO)

        DllStructSetData($tStartup, 'Size', DllStructGetSize($tStartup))
        ;Т.к IExplore запускает родительский процесс, который затем запускает основной браузер, то нужно родительский процесс поместить в работу поэтому приостанавливаем выполнение.
        If Not _WinAPI_CreateProcess('', $sCmd, 0, 0, 0, BitOR($CREATE_BREAKAWAY_FROM_JOB, $CREATE_SUSPENDED), 0, 0, DllStructGetPtr($tStartup), DllStructGetPtr($tProcess)) Then
            _WinAPI_CloseHandle($hJob)
            Return SetError(3, 0, False)
        EndIf

        Local $hProcess = DllStructGetData($tProcess, 'hProcess')
        ;Назначаем процесс в созданную работу
        If Not _WinAPI_AssignProcessToJobObject($hJob, $hProcess) Then
            _WinAPI_TerminateProcess($hProcess)
            _WinAPI_CloseHandle($hJob)
            Return SetError(4, 0, False)
        EndIf

        ;Процесс создан и назначен, возобновляем его работу.
        Local $hThread = DllStructGetData($tProcess, 'hThread')
        DllCall('kernel32.dll', 'dword', 'ResumeThread', 'ptr', $hThread)
        _WinAPI_CloseHandle($hThread)
    Else
        If Not Run($sCmd) Then
            Return SetError(5, 0, False)
        EndIf
    EndIf

    ;Ждем окно с уникальным текстом
    Local $hWin = WinWait("[CLASS:IEFrame]", $url, 30)
    If Not $hWin Then
        Return SetError(6, 0, False)
    EndIf

    ;Здесь мы получаем настоящий PID браузера
    Local $iPid = WinGetProcess($hWin)

    ;Здесь находим объект IE
    For $oIe In ObjCreate("Shell.Application").Windows()
        If $hWin = HWnd($oIe.hwnd) Then
            $oIe.Navigate($sUrl)
            Return SetExtended($iPid, $oIe)
        EndIf
    Next

    If $iPid Then ProcessClose($iPid)
    Return SetError(7, 0, False)
EndFunc   ;==>_IExploreCreate
```
