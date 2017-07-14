#Использовать cmdline
#Использовать v8runner
#Использовать logos

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

    Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

АргументыКС = Новый ПарсерАргументовКоманднойСтроки();
АргументыКС.ДобавитьИменованныйПараметр("-dpath");
АргументыКС.ДобавитьИменованныйПараметр("-ibname");
АргументыКС.ДобавитьИменованныйПараметр("-usr");
АргументыКС.ДобавитьИменованныйПараметр("-pwd");

Параметры = АргументыКС.Разобрать(АргументыКоманднойСтроки);

ПутьКПоставке = Параметры["-dpath"];
ИмяРабочейБазы = Параметры["-ibname"];
Пользователь = Параметры["-usr"];
Пароль = Параметры["-pwd"];


ИмяФайлаЖурнала = ОбъединитьПути(ТекущийКаталог(), "Logs", ИмяРабочейБазы, "update.log");
Файл = Новый Файл(ИмяФайлаЖурнала);
СоздатьКаталог(Файл.Путь);
КаталогЖурналов = Файл.Путь;

Журнал = Логирование.ПолучитьЛог("update.app.production");
Журнал.УстановитьУровень(УровниЛога.Информация);
Журнал.УстановитьРаскладку(ЭтотОбъект);

КонсольЖурн = Новый ВыводЛогаВКонсоль;
ФайлЖурнала = Новый ВыводЛогаВФайл;
ФайлЖурнала.ОткрытьФайл(ИмяФайлаЖурнала);

Журнал.ДобавитьСпособВывода(ФайлЖурнала);
Журнал.ДобавитьСпособВывода(КонсольЖурн);

//Версия рабочего сервера отличается от версии сервера разработки
УправлениеКонфигуратором = Новый УправлениеКонфигуратором();
ПутьКПлатформе1С = УправлениеКонфигуратором.ПолучитьПутьКВерсииПлатформы("8.3.9");

//Проверяем флаг и если есть, обновляем
Файл = Новый Файл(ОбъединитьПути(ПутьКПоставке, "needupdate.flg"));

ЖурналОбновленияРабочейБазы = ОбъединитьПути(КаталогЖурналов, "LoadCfg_" + ИмяРабочейБазы + ".log");

Если Файл.Существует() Тогда

	ЧТ = Новый ЧтениеТекста(Файл.ПолноеИмя);
	ИмяФайлаКонфигурации = СокрЛП(ЧТ.ПрочитатьСтроку());
	ЧТ.Закрыть();
	
	Журнал.Информация("Начало обновления рабочей базы " + ИмяРабочейБазы);
	ПроцессКонфигуратора = Создатьпроцесс("""" + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /IBName """ + ИмяРабочейБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /LoadCfg " + ИмяФайлаКонфигурации + " /UpdateDBCfg /out " + ЖурналОбновленияРабочейБазы
											,ПутьКПоставке
											,Истина
											,Ложь
											,КодировкаТекста.UTF8);
	ПроцессКонфигуратора.Запустить();										
	ПроцессКонфигуратора.ОжидатьЗавершения();
	
	Журнал.Информация("Завершено обновление рабочей базы " + ИмяРабочейБазы);
	
Иначе

	Журнал.Информация("обновление рабочей базы " + ИмяРабочейБазы + " не требуется.");	
	
КонецЕсли;