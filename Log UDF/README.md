# Log.au3

AutoIt: 3.3.6.1
Версия: 1.0

Категория: Автоматизация

Описание: Библиотека позволяет создавать текстовые лог-файлы (.log), которые имеют сдедующий формат (см. ниже). Пользоваться всем этим экстремально просто (см. пример). Вообщем, даже и сказать больше нечего, попробуйте сами.

:)

```
###Event Log Files UDF Exaple###

2010-08-29  20:26:44  (0006)  Program start
2010-08-29  20:26:44  (0008)  Pinging www.autoitscript.com...
2010-08-29  20:26:44  (0005)  Ping is successful, Time = 73 ms
2010-08-29  20:26:44  (0007)  Program exit

2010-08-29  20:26:44  (0006)  Program start
2010-08-29  20:26:44  (0008)  Pinging www.autoitscript.com...
2010-08-29  20:26:44  (0005)  Ping is successful, Time = 110 ms
2010-08-29  20:26:44  (0007)  Program exit
```
Пример:
```

#Include <Log.au3>

Opt('MustDeclareVars', 1)

Global $hLog, $Time

$hLog = _Log_Open(@ScriptDir & '\MyProg.log', '###Event Log Files UDF Exaple###')
_Log_Report($hLog, 'Program start', 6)
_Log_Report($hLog, 'Pinging www.autoitscript.com...', 8)
$Time = Ping('www.autoitscript.com')
If $Time Then
    _Log_Report($hLog, 'Ping is successful, Time = ' & $Time & ' ms', 5)
Else
    Switch @error
        Case 1
            _Log_Report($hLog, 'Ping is fails, host is offline', 1)
        Case 2
            _Log_Report($hLog, 'Ping is fails, host is unreachable', 2)
        Case 3
            _Log_Report($hLog, 'Ping is fails, bad destination', 3)
        Case Else
            _Log_Report($hLog, 'Ping is fails, unknown error', 4)
    EndSwitch
EndIf
_Log_Report($hLog, 'Program exit', 7)
_Log_Close($hLog)
```

Источник: [Log UDF (оффициальный форум)](https://www.autoitscript.com/forum/topic/119032-log-udf/)
Автор: Yashied
[Русский форум](https://autoit-script.ru/index.php?topic=2586.0)
