#Использовать v8runner

Функция ПодключитьКонфигуратор(Знач Команда) Экспорт

    СтрокаПодключения = СтрШаблон("/IBConnectionString""Srvr=%1; Ref='%2'""", 
            Команда.ЗначениеОпции("srvname"),
            Команда.ЗначениеОпции("ibname")
    );

	// Сообщить(СтрокаПодключения);

    Конфигуратор = Новый УправлениеКонфигуратором();
    Конфигуратор.УстановитьКонтекст(СтрокаПодключения, 
            Команда.ЗначениеОпции("user"), 
            Команда.ЗначениеОпции("pwd")
    );

    КодРазблокировки =  Команда.ЗначениеОпции("uc");
    Если ЗначениеЗаполнено(КодРазблокировки) Тогда
        Конфигуратор.УстановитьКлючРазрешенияЗапуска(КодРазблокировки);
    КонецЕсли;
 
    Возврат Конфигуратор;

КонецФункции

Процедура ОчиститьТекстовыйФайл(ИмяФайла) Экспорт

    ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, , , Ложь);
    ЗаписьТекста.Записать("");
    ЗаписьТекста.Закрыть();

КонецПроцедуры

Процедура ЗаписатьВТекстовыйФайл(ИмяФайла, Текст) Экспорт

    ЗаписьТекста = Новый ЗаписьТекста(ИмяФайла, , , Истина);
    ЗаписьТекста.ЗаписатьСтроку(Текст);
    ЗаписьТекста.Закрыть();

КонецПроцедуры

Функция ОбернутьВКавычки(Знач Строка) Экспорт
    
    Результат = Строка;
    Если Не Лев(Строка, 1) = """" И Не Прав(Строка, 1) = """" Тогда
		Результат = СтрШаблон("""%1""", Строка);
    КонецЕсли;
    
    Возврат Результат;

КонецФункции