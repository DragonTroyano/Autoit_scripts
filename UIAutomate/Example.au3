; Демонстрация автоматизации Chrome версии 53

#include "UIAutomate.au3"

Opt("WinTitleMatchMode", 2)

; Данные регистрации
Global $sLogin = "User"
Global $sPassword = "12345"

; Запуск Chrome с параметром --force-renderer-accessibility
; При отсутствии этого параметра доступ к элементам страницы будет запрещён
Run(@ProgramFilesDir & "\Google\Chrome\Application\chrome.exe --force-renderer-accessibility")
$hWnd = WinWait(" - Google Chrome", "", 3)
If Not $hWnd Then Exit

; Создание элемента с использованием дескриптора окна
$oParent = _UIA_GetElementFromHandle($hWnd)

; Поиск кнопки с именем "Новая вкладка" и клик по ней
$oElement = _UIA_GetControlTypeElement($oParent, "UIA_ButtonControlTypeId", "Новая вкладка")
_UIA_ElementMouseClick($oElement)

; Поиск строки адреса и установка текста
$oElement = _UIA_GetControlTypeElement($oParent, "UIA_EditControlTypeId", "Адресная строка и строка поиска")
_UIA_ElementTextSetValue($oElement, "autoit-script.ru")

; Переход на сайт
Send("{enter}")

; Ожидание загрузки страницы по наличию элемента "Недавние сообщения"
_UIA_WaitControlTypeElement($oParent, "UIA_TextControlTypeId", "Недавние сообщения")

; Отключение вывода ошибок
$UIA_ConsoleWriteError = 0

; Поиск элемента для ввода пароля
$oElement = _UIA_GetControlTypeElement($oParent, "UIA_EditControlTypeId", True, "IsPassword")

; Включение вывода ошибок
$UIA_ConsoleWriteError = 1

; Регистрация при наличии поля пароля
If IsObj($oElement) Then

  ; Установка фокуса в поле пароля и ввод данных
  _UIA_ElementSetFocus($oElement)
  Send($sPassword)

  ; Заполнение поля логина
  Send("+{tab}")
  Send($sLogin)

  ; Поиск и нажатие кнопки "Вход"
  $oElement = _UIA_GetControlTypeElement($oParent, "UIA_ButtonControlTypeId", "Вход")
  _UIA_ElementDoDefaultAction($oElement)
EndIf

; Ожидание загрузки страницы по наличию ссылки "Примеры и рабочие проекты"
$oElement = _UIA_WaitControlTypeElement($oParent, "UIA_HyperlinkControlTypeId", "Примеры и рабочие проекты")

; Проверка успешной регистрации
If Not IsObj($oElement) Then Exit

; Переход по ссылке "Примеры и рабочие проекты"
_UIA_ElementDoDefaultAction($oElement)

; Ожидание загрузки страницы по наличию части имени элемента " это не раздел по общим вопросам"
_UIA_WaitControlTypeElement($oParent, 0xC364, "не раздел по общим", Default, True)

; Поиск элемента поиска, установка фокуса, ввод данных
$oElement = _UIA_GetControlTypeElement($oParent, "UIA_EditControlTypeId", "")
_UIA_ElementSetFocus($oElement)
Send("UIAutomate")

; Поиск и нажатие кнопки "Поиск"
$oElement = _UIA_GetControlTypeElement($oParent, 0xC350, "Поиск")
_UIA_ElementDoDefaultAction($oElement)