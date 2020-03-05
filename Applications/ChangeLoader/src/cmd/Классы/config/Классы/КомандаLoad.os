///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды
//
///////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать fs
#Использовать "../../../../core"

Перем Конфигуратор;

Перем ЗагрузкаКонфигурации;
Перем ТолькоИзменения;
Перем Коммиты;

Перем ЗагрузкаРасширения;
Перем НаименованияРасширений;

Перем ОбновитьБазуДанных;
Перем ОбновитьДамп;

Перем КаталогРепозитория;

Перем ЛогПриложения;
Перем ЛогПлатформы;



Процедура ОписаниеКоманды(Знач Команда) Экспорт

	УстановитьПараметрыКоманды(Команда);
	УстановитьКоманды(Команда);

КонецПроцедуры // НастроитьКоманду

Процедура УстановитьКоманды(Знач Команда)

КонецПроцедуры

Процедура УстановитьПараметрыКоманды(Знач Команда)

	Команда.Опция("c config", Ложь, "Загрузка основной конфигурации")
		.ТБулево()
	;

	// Команда.Опция("e extension", , "Имена расширений для загрузки (-e=ext1 -e=ext2 ...)")
	// 	.ТМассивСтрок()
	// ;

	// TODO: получать имена конфигураций или извлекать из файла configuration.xml
	Команда.Опция("e extension", Ложь, "Загрузка конфигурации расширения")
		.ТБулево()
	;

	Команда.Опция("u update", Ложь, "Обновить конфигурацию базы данных после загрузки")
		.ТБулево()
	;

	Команда.Опция("i configDumpInfo", Ложь, "Выгрузка ConfigDumpInfo.xml после загрузки конфигурации")
		.ТБулево()
	;

	Команда.Аргумент("REPO", , "Репозиторий конфигурации")
		.ТСтрока()
	;

	Команда.Опция("d diff", Ложь, "Загрузка только измененных файлов (актуально только для основной конфигурации). 
								|Если не указывается аргумент COMMIT, то происходит загрузка изменений последнего коммита.")
		.ТБулево()
	;

	Команда.Аргумент("COMMIT", , "Хэши коммитов, между которыми вычисляются изменения в репозитории (строго 2 хэша). " +
								"Только при вкл. флаге --changes")
		.ТМассивСтрок()
		.Обязательный(Ложь)
	;

	// Команда.Спек = "((-c | -e...) | (-c -e...)) REPO [-d COMMIT...]";
	Команда.Спек = "((-c | -e) | (-c -e)) [-u] [-i] REPO [-d [COMMIT...]]";

КонецПроцедуры


// Выполняет присваивание значений входящих параметров переменным модуля
//
// Параметры:
//	Команда - КомандаПриложения - выполняемая команда
//
Процедура ПрочитатьВходящиеПараметры(Знач Команда)

	ПараметрыПриложения.УстановитьПараметрыПриложения(Команда.Приложение);

	ЗагрузкаКонфигурации = Команда.ЗначениеОпции("config");
	ЗагрузкаРасширения = Команда.ЗначениеОпции("extension");

	ОбновитьБазуДанных = Команда.ЗначениеОпции("update");
	ОбновитьДамп = Команда.ЗначениеОпции("configDumpInfo");

	КаталогРепозитория = Команда.ЗначениеАргумента("REPO");

	ТолькоИзменения = Команда.ЗначениеОпции("diff");
	Коммиты = Команда.ЗначениеАргумента("COMMIT");
	
	// НаименованияРасширений = Команда.ЗначениеОпции("extension");
	// ЗагрузкаРасширения = НаименованияРасширений.Количество();

	ЛогПлатформы = ОбъединитьПути(ПараметрыПриложения.КаталогЛогов(), "load_cfg.log");

КонецПроцедуры

Процедура ПодготовитьСлужебныеФайлы()

	// ФС.ОбеспечитьКаталог(КаталогПоставки);

	ОбщийФункционал.ОчиститьТекстовыйФайл(ЛогПлатформы);
	// ОбщийФункционал.ОчиститьТекстовыйФайл(ФлагОбновления);

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
	НастройкиЗагрузки = ПодготовитьНастройкиЗагрузкиКонфигураций();

	// ВыполнитьСинтаксическийКонтроль(НастройкиВыгрузки);
	ВыполнитьЗагрузкуКонфигураций(НастройкиЗагрузки);
	
КонецПроцедуры // ВыполнитьКоманду

Функция ПодготовитьНастройкиЗагрузкиКонфигураций()

	Настройки = Новый ТаблицаЗначений();
	Настройки.Колонки.Добавить("Наименование");
	Настройки.Колонки.Добавить("КаталогКонфигурации");
	Настройки.Колонки.Добавить("ДополнительныйКлюч");
	Настройки.Колонки.Добавить("ТолькоИзменения");
	Настройки.Колонки.Добавить("ФайлИзменений");
	Настройки.Колонки.Добавить("КоличествоИзменений");

	Если ЗагрузкаКонфигурации Тогда
		ДобавитьНастройкуЗагрузкиКонфигурации(Настройки,
			"Основная",
			ОбъединитьПути(КаталогРепозитория, "Config"),
			,
			ТолькоИзменения
		);
	КонецЕсли;

	// Для Каждого Расширение Из НаименованияРасширений Цикл
	Если ЗагрузкаРасширения Тогда
		ДобавитьНастройкуЗагрузкиКонфигурации(Настройки, 
			"Расширение_РТИТС", 
			ОбъединитьПути(КаталогРепозитория, "Extension"),
			СтрШаблон("-Extension %1", ОбщийФункционал.ОбернутьВКавычки("Расширение_РТИТС"))
		);
	КонецЕсли;
	// КонецЦикла;

	Возврат Настройки;

КонецФункции

&SupressWarning
Процедура ДобавитьНастройкуЗагрузкиКонфигурации(Знач Настройки, Знач Наименование, Знач Каталог, Знач ДополнительныйКлюч = "", ТолькоИзменения = Ложь)

	ИмяФайлаИзменений = ПолучитьИмяВременногоФайла(".txt");

	НоваяСтрока = Настройки.Добавить();
	НоваяСтрока.Наименование = Наименование;
	НоваяСтрока.КаталогКонфигурации = Каталог;
	НоваяСтрока.ДополнительныйКлюч = ДополнительныйКлюч;
	НоваяСтрока.ТолькоИзменения = ТолькоИзменения;
	НоваяСтрока.ФайлИзменений = ИмяФайлаИзменений;
	НоваяСтрока.КоличествоИзменений = 0;

	Если Ложь Тогда
		УдалитьФайлы(ИмяФайлаИзменений);
	КонецЕсли;

КонецПроцедуры

Процедура ПодготовитьСписокИзмененныхФайлов(Настройка, КаталогЗагрузки)

	ПодключитьСценарий("../../lib/git.os", "git");
	git = Новый git();

	//git.ПерейтиНаВетку(Параметры.ПутьКРепозиторию, Параметры.ИмяВетки);
	git.ПолучитьСписокИзмененийВФайл(КаталогЗагрузки, 
		Настройка.ФайлИзменений, 
		ЛогПриложения, 
		Коммиты
	);

	Настройка.КоличествоИзменений = git.ОбработатьФайлИзменений(КаталогЗагрузки,
		git.РежимыОтслеживаемыхИзменений.ОсновнаяКонфигурация,
		Настройка.ФайлИзменений, 
		ЛогПриложения
	);

	Настройка.ДополнительныйКлюч = СтрШаблон("%1 -ListFile %2", Настройка.ДополнительныйКлюч, Настройка.ФайлИзменений);

КонецПроцедуры

Процедура ВыполнитьЗагрузкуКонфигураций(Знач НастройкиЗагрузки)

	ЛогПриложения.Информация("Начало загрузки конфигураций из файлов");

	Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ЛогПлатформы, Ложь);
	Для Каждого Настройка Из НастройкиЗагрузки Цикл

		ТекстСообщения = СтрШаблон("Загрузка конфигурации из файлов: %1", Настройка.Наименование);
		ОбщийФункционал.ЗаписатьВТекстовыйФайл(ЛогПлатформы, Символы.ПС + ТекстСообщения);
		ЛогПриложения.Информация(ТекстСообщения);

		КаталогЗагрузки = КаталогРепозитория;
		Если Настройка.ТолькоИзменения Тогда
			
			ПодготовитьСписокИзмененныхФайлов(Настройка, КаталогЗагрузки);
			Если Не Настройка.КоличествоИзменений Тогда
				ЛогПриложения.Информация("Отсутствуют изменения в репозитории %1", Настройка.КаталогКонфигурации);
				Продолжить;
			КонецЕсли;

		КонецЕсли;

		ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
		// ПараметрыЗапуска.Добавить(СтрШаблон("/LoadConfigFromFiles %1 %2 %3", 
		// 	КаталогЗагрузки, Настройка.ДополнительныйКлюч, "-updateConfigDumpInfo"));
		ПараметрыЗапуска.Добавить(СтрШаблон("/LoadConfigFromFiles %1", КаталогЗагрузки));
		ПараметрыЗапуска.Добавить(Настройка.ДополнительныйКлюч);
		
		Если ОбновитьДамп Тогда
			ПараметрыЗапуска.Добавить("-updateConfigDumpInfo");
		КонецЕсли;

		Если ОбновитьБазуДанных Тогда
			ПараметрыЗапуска.Добавить("/UpdateDBCfg");
		КонецЕсли;

		Путь = ФС.ОтносительныйПуть(КаталогРепозитория, Настройка.КаталогКонфигурации);
		Результат = Истина;
		Попытка
			Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Исключение
			Результат = Ложь;
		КонецПопытки;

		ТекстСообщения = "Загрузка конфигурации %1 завершена %2";
		Если Результат Тогда
			ЛогПриложения.Информация(СтрШаблон(ТекстСообщения, Настройка.Наименование, "успешно"));
			Если Не КаталогЗагрузки = Настройка.КаталогКонфигурации Тогда
				ДампКонфигурацииВрем = ОбъединитьПути(КаталогЗагрузки, "ConfigDumpInfo.xml");
				ДампКонфигурацииРепо = ОбъединитьПути(Настройка.КаталогКонфигурации, "ConfigDumpInfo.xml");
	
				Сообщение = СтрШаблон("Копирую рабочий каталог: %1 в %2", ДампКонфигурацииВрем, ДампКонфигурацииРепо);
				ЛогПриложения.Информация(Сообщение);
	
				КопироватьФайл(ДампКонфигурацииВрем, ДампКонфигурацииРепо);
			КонецЕсли;
		Иначе
			ЛогПриложения.Информация(СтрШаблон(ТекстСообщения, Настройка.Наименование, "с ошибками"));
		КонецЕсли;

		УдалитьФайлы(Настройка.ФайлИзменений);

	КонецЦикла;

КонецПроцедуры

ЛогПриложения = ПараметрыПриложения.Лог();



