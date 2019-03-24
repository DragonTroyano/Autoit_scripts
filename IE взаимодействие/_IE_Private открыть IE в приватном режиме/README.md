# _IExploreCreate запуск Internet Explorer, приватный режим и автозакрытие

## Источник
[Autoit форум](http://autoit-script.ru/index.php?topic=18303.0)

## Пример

```
#include <ie.au3>
$oIe = _IE_Private()
_IENavigate($oIe, 'ya.ru')
```