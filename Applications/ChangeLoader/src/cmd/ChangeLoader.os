///////////////////////////////////////////////////////////////////////////////
//
// CLI-интерфейс для oscript-app
// 
//The MIT License (MIT)
// 
// Copyright (c) 2016 Andrei Ovsiankin
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//
// Рекомендованная структура модуля точки входа приложения
//
///////////////////////////////////////////////////////////////////////////////

#Использовать cli
#Использовать "."
// #Использовать "../core"

///////////////////////////////////////////////////////////////////////////////
Перем Приложение;

Функция КаталогЛогов() Экспорт

    Возврат Приложение.ПолучитьКоманду().ЗначениеОпции("logs");

КонецФункции

Процедура ВыполнитьКоманду(Знач КомандаПриложения) Экспорт
	КомандаПриложения.ВывестиСправку();
КонецПроцедуры


Процедура ВыполнитьПриложение()

	ИмяПродукта = ПараметрыПриложения.ИмяПродукта();

    Приложение = Новый КонсольноеПриложение(ИмяПродукта, "Версионирование правил обмена 1С с помощью git");
    Приложение.Версия("v version", ПараметрыПриложения.ВерсияПродукта());

    УстановитьПараметрыКоманды(Приложение);
    УстановитьКоманды(Приложение);

    ПараметрыПриложения.УстановитьПриложение(Приложение);

    Приложение.Запустить(АргументыКоманднойСтроки);

КонецПроцедуры // ВыполнениеКоманды()

Процедура УстановитьКоманды(Знач Приложение)

    Приложение.ДобавитьКоманду("config", 
        "Группа команд для управления конфигурацией", 
        Новый КомандаConfig)
    ;

    Приложение.УстановитьОсновноеДействие(ЭтотОбъект);

КонецПроцедуры

Процедура УстановитьПараметрыКоманды(Знач Приложение)

    Приложение.Опция("l logs", , "Путь к каталогу для сохранения логов платформы")
        .ТСтрока()
        .Обязательный(Истина)
    ;

    Приложение.Опция("s srvname", , "Имя сервера 1С")
        .ТСтрока()
        .Обязательный()
    ;

    Приложение.Опция("b ibname", , "Имя базы данных 1С")
        .ТСтрока()
        .Обязательный()
    ;

    Приложение.Опция("u user", , "Имя пользователя")
        .ТСтрока()
        .Обязательный()
    ;

    Приложение.Опция("p pwd", , "Пароль пользователя")
        .ТСтрока()
        .Обязательный()
    ;

    Приложение.Опция("uc", , "Код разблокировки")
        .ТСтрока()
    ;

    // Обязательный() для опций не работает >_<
    // fix: https://github.com/Morkhe/cli/commit/b42b1838b09984180a003962367e0f181aee63cf
    Приложение.УстановитьСпек("--logs --srvname --ibname --user --pwd [--uc]");

КонецПроцедуры

Попытка
    ВыполнитьПриложение();
Исключение
    Сообщить(ОписаниеОшибки());
КонецПопытки;
