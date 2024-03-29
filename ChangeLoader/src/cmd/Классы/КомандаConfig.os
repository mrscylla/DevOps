///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды
//
///////////////////////////////////////////////////////////////////////////////

#Использовать "./config/"

Процедура ОписаниеКоманды(Знач Команда) Экспорт

	УстановитьПараметрыКоманды(Команда);
	УстановитьКоманды(Команда);

КонецПроцедуры // НастроитьКоманду

Процедура УстановитьКоманды(Знач Команда)

	Команда.ДобавитьПодкоманду("dump", 
		"Выгрузка конфигурации в CF файл", 
		Новый КомандаDumpCfg)
	;

	Команда.ДобавитьПодкоманду("load", 
		"Загрузка конфигурации из XML файлов", 
		Новый КомандаLoadCfg)
	;

	Команда.ДобавитьПодкоманду("configDumpInfo", 
		"Выгрузка файла ConfigDumpInfo.xml", 
		Новый КомандаConfigDumpInfo)
	;

КонецПроцедуры

Процедура УстановитьПараметрыКоманды(Знач Команда)

КонецПроцедуры

// Выполняет присваивание значений входящих параметров переменным модуля
//
// Параметры:
//	Команда - КомандаПриложения - выполняемая команда
//
Процедура ПрочитатьВходящиеПараметры(Знач Команда)

	ПараметрыПриложения.УстановитьПараметрыПриложения(Команда.Приложение);

КонецПроцедуры

Процедура ПодготовитьСлужебныеФайлы()


КонецПроцедуры

// Выполняет логику команды
// 
// Параметры:
//   Команда - Соответствие - Соответствие ключей командной строки и их значений
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	ПрочитатьВходящиеПараметры(Команда);
	ПодготовитьСлужебныеФайлы();
	
	Команда.ВывестиСправку();

КонецПроцедуры // ВыполнитьКоманду
