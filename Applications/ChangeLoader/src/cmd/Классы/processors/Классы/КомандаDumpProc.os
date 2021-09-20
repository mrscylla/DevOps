///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды
//
///////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать fs
// #Использовать "../../../../core"

Перем Конфигуратор;

Перем КаталогОбработок;
Перем КаталогНазначения;

Перем ЛогПриложения;
Перем ЛогРазборкиОбработок;

Процедура ОписаниеКоманды(Знач Команда) Экспорт

	УстановитьПараметрыКоманды(Команда);
	УстановитьКоманды(Команда);

КонецПроцедуры // НастроитьКоманду

Процедура УстановитьКоманды(Знач Команда)

КонецПроцедуры

Процедура УстановитьПараметрыКоманды(Знач Команда)

	Команда.Аргумент("SOURCE", , "Каталог, содержащий обработки для разбора")
		.ТСтрока()
	;

	Команда.Аргумент("DEST", , "Каталог, в который будут сохранены исходные файлы обработок")
		.ТСтрока()
	;

	Команда.Спек = "SOURCE DEST";

КонецПроцедуры


// Выполняет присваивание значений входящих параметров переменным модуля
//
// Параметры:
//	Команда - КомандаПриложения - выполняемая команда
//
Процедура ПрочитатьВходящиеПараметры(Знач Команда)

	ПараметрыПриложения.УстановитьПараметрыПриложения(Команда.Приложение);

	КаталогОбработок = Команда.ЗначениеАргумента("SOURCE");
	КаталогНазначения = Команда.ЗначениеАргумента("DEST");

	ЛогРазборкиОбработок = ОбъединитьПути(ПараметрыПриложения.КаталогЛогов(), "dump_processors.log");

КонецПроцедуры

Процедура ПодготовитьСлужебныеФайлы()

	ФС.ОбеспечитьКаталог(КаталогНазначения);

	ОбщийФункционал.ОчиститьТекстовыйФайл(ЛогРазборкиОбработок);

КонецПроцедуры

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   Приложение - Модуль - Модуль менеджера приложения
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	ПрочитатьВходящиеПараметры(Команда);
	ПодготовитьСлужебныеФайлы();

	Конфигуратор = ПараметрыПриложения.ПодключитьКонфигуратор();

	ВыполнитьРазборкуВнешнихОбработок();
	
КонецПроцедуры // ВыполнитьКоманду

Процедура ВыполнитьРазборкуВнешнихОбработок()

	КомандаРазборки = "/DumpExternalDataProcessorOrReportToFiles ""%1"" ""%2""";
	ШаблонИмениОбработки = ОбъединитьПути(КаталогОбработок, "%1");

	Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ЛогРазборкиОбработок);	
	ЛогПриложения.Информация("Начало разборки обработок");

	ВременныйКаталог = ОбъединитьПути(КаталогВременныхФайлов(), "Ext_Processors_1C");
	ФС.ОбеспечитьПустойКаталог(ВременныйКаталог);

	УспешноРазобрано = 0;
	ОбработкиДляРазбора = НайтиФайлы(КаталогОбработок, "*.e?f");
	Для Каждого Обработка Из ОбработкиДляРазбора Цикл
		
		РезультатРазборки = Истина;
		ВременныйКаталогОбработки = ОбъединитьПути(ВременныйКаталог, Обработка.ИмяБезРасширения);
		ФС.ОбеспечитьКаталог(ВременныйКаталогОбработки);

		ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
		ПараметрыЗапуска.Добавить(СтрШаблон(КомандаРазборки, ВременныйКаталогОбработки, Обработка.ПолноеИмя));
		
		Попытка
			Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Исключение
			ЛогПриложения.Ошибка(СтрШаблон("Не удалось разобрать обработку: %1", Обработка.ИмяБезРасширения));
			РезультатРазборки = Ложь;
		КонецПопытки;

		Если РезультатРазборки Тогда
			КаталогОбработки = ОбъединитьПути(КаталогНазначения, Обработка.ИмяБезРасширения);
			ФС.ОбеспечитьПустойКаталог(КаталогОбработки);
			ФС.КопироватьСодержимоеКаталога(ВременныйКаталогОбработки, КаталогОбработки);
			
			УспешноРазобрано = УспешноРазобрано + 1;
		КонецЕсли;

		Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ЛогРазборкиОбработок, Ложь);

	КонецЦикла;

	УдалитьФайлы(ВременныйКаталог, ПолучитьМаскуВсеФайлы());

	ЛогПриложения.Информация(СтрШаблон("Успешно разобрано %1 из %2 обработок", 
		УспешноРазобрано, 
		ОбработкиДляРазбора.Количество()));

КонецПроцедуры

ЛогПриложения = ПараметрыПриложения.Лог();
