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

	Команда.Аргумент("COMMIT", , "Хэши коммитов, между которыми вычисляются изменения в репозитории (до 2 хэшей). "
								+ "Только при вкл. опции --diff
								| 1 хэш: будет загружена разница между указанным хэшем и HEAD
								| 2 хэша: будет загружена разница между указанными хэшами")
		.ТМассивСтрок()
		.Обязательный(Ложь)
	;

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

	КаталогРепозитория = СтрЗаменить(Команда.ЗначениеАргумента("REPO"), "'", "");
	ЛогПриложения.Информация(КаталогРепозитория);

	ТолькоИзменения = Команда.ЗначениеОпции("diff");
	Коммиты = Команда.ЗначениеАргумента("COMMIT");

	ЛогПлатформы = ОбъединитьПути(ПараметрыПриложения.КаталогЛогов(), "load_cfg.log");

КонецПроцедуры

Процедура ПодготовитьСлужебныеФайлы()

	ОбщийФункционал.ОчиститьТекстовыйФайл(ЛогПлатформы);

КонецПроцедуры

// Выполняет логику команды
// 
// Параметры:
//   Команда - Соответствие - Соответствие ключей командной строки и их значений
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ПрочитатьВходящиеПараметры(Команда);
	ПодготовитьСлужебныеФайлы();

	Конфигуратор = ПараметрыПриложения.ПодключитьКонфигуратор();
	НастройкиЗагрузки = ПодготовитьНастройкиЗагрузкиКонфигураций();

	ВыполнитьЗагрузкуКонфигураций(НастройкиЗагрузки);
	
КонецПроцедуры // ВыполнитьКоманду

Функция ПодготовитьНастройкиЗагрузкиКонфигураций()

	Настройки = Новый ТаблицаЗначений();
	Настройки.Колонки.Добавить("Наименование");
	Настройки.Колонки.Добавить("КаталогКонфигурации");
	Настройки.Колонки.Добавить("ДополнительныйКлюч");
	Настройки.Колонки.Добавить("ТолькоИзменения");
	Настройки.Колонки.Добавить("ФайлИзменений");
	Настройки.Колонки.Добавить("ЕстьИзменения");
	Настройки.Колонки.Добавить("КаталогДляЗагрузки");

	Если ЗагрузкаКонфигурации Тогда
		ДобавитьНастройкуЗагрузкиКонфигурации(Настройки,
			"Основная",
			ОбъединитьПути(КаталогРепозитория, "Config"),
			,
			ТолькоИзменения
		);
	КонецЕсли;

	Если ЗагрузкаРасширения Тогда
		ДобавитьНастройкуЗагрузкиКонфигурации(Настройки, 
			"Расширение_РТИТС", 
			ОбъединитьПути(КаталогРепозитория, "Extension"),
			СтрШаблон("-Extension %1", ОбщийФункционал.ОбернутьВКавычки("Расширение_РТИТС"))
		);
	КонецЕсли;

	Возврат Настройки;

КонецФункции

Процедура ДобавитьНастройкуЗагрузкиКонфигурации(Знач Настройки, Знач Наименование, Знач Каталог, Знач ДополнительныйКлюч = "", ТолькоИзменения = Ложь)

	// BSLLS:MissingTemporaryFileDeletion-off
	ИмяФайлаИзменений = ПолучитьИмяВременногоФайла(".txt");
	// BSLLS:MissingTemporaryFileDeletion-on

	НоваяСтрока = Настройки.Добавить();
	НоваяСтрока.Наименование = Наименование;
	НоваяСтрока.КаталогКонфигурации = Каталог;
	НоваяСтрока.ДополнительныйКлюч = ДополнительныйКлюч;
	НоваяСтрока.ТолькоИзменения = ТолькоИзменения;
	НоваяСтрока.ФайлИзменений = ИмяФайлаИзменений;
	НоваяСтрока.ЕстьИзменения = 0;
	НоваяСтрока.КаталогДляЗагрузки = ВременныйКаталогДляЗагрузки();

КонецПроцедуры

Процедура ПодготовитьСписокИзмененныхФайлов(Настройка)

	Гит = Новый Гит(КаталогРепозитория, ЧастиРепозитория.ОсновнаяКонфигурация, ЛогПриложения);
	Гит.СформироватьСписокИзмененныхФайлов(Настройка.ФайлИзменений, Коммиты);
	Настройка.ЕстьИзменения = Гит.ЕстьИзмененныеФайлы();

	Гит.СкопироватьИзмененныеФайлыВоВременныйКаталог(Настройка.ФайлИзменений, Настройка.КаталогДляЗагрузки);

	Настройка.ДополнительныйКлюч = СтрШаблон("%1 -ListFile %2", Настройка.ДополнительныйКлюч, Настройка.ФайлИзменений);

КонецПроцедуры

Функция ВременныйКаталогДляЗагрузки()

	// BSLLS:MissingTemporaryFileDeletion-off
	Файл = Новый Файл(ПолучитьИмяВременногоФайла());
	// BSLLS:MissingTemporaryFileDeletion-on
	ИмяКаталога = Файл.Имя;

	ПутьКВременномуКаталогу = ОбъединитьПути(КаталогВременныхФайлов(), ИмяКаталога);
	ФС.ОбеспечитьПустойКаталог(ПутьКВременномуКаталогу);

	Возврат ПутьКВременномуКаталогу;

КонецФункции

Процедура ВыполнитьЗагрузкуКонфигураций(Знач НастройкиЗагрузки)

	ЛогПриложения.Информация("Начало загрузки конфигураций из файлов");

	Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ЛогПлатформы, Ложь);
	Для Каждого Настройка Из НастройкиЗагрузки Цикл

		ТекстСообщения = СтрШаблон("Загрузка конфигурации из файлов: %1", Настройка.Наименование);
		ОбщийФункционал.ЗаписатьВТекстовыйФайл(ЛогПлатформы, Символы.ПС + ТекстСообщения);
		ЛогПриложения.Информация(ТекстСообщения);

		КаталогДляЗагрузки = ОбъединитьПути(Настройка.КаталогДляЗагрузки, "Config");
		Если Настройка.ТолькоИзменения Тогда
			
			ПодготовитьСписокИзмененныхФайлов(Настройка);
			Если Не Настройка.ЕстьИзменения Тогда
				ЛогПриложения.Информация("Отсутствуют изменения в репозитории %1", Настройка.КаталогКонфигурации);
				УдалитьВременныеФайлы(Настройка);
				Продолжить;
			КонецЕсли;

		КонецЕсли;

		ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
		ПараметрыЗапуска.Добавить(СтрШаблон("/LoadConfigFromFiles %1 %2", КаталогДляЗагрузки, Настройка.ДополнительныйКлюч));

		Если ОбновитьДамп Тогда 
			ПараметрыЗапуска.Добавить("-updateConfigDumpInfo");
		КонецЕсли;

		Если ОбновитьБазуДанных Тогда
			ПараметрыЗапуска.Добавить("/UpdateDBCfg");
		КонецЕсли;

		Для Каждого Параметр Из ПараметрыЗапуска Цикл
			ЛогПриложения.Информация(Параметр);
		КонецЦикла;

		Результат = Истина;
		Попытка
			ЛогПриложения.Информация("Запуск конфигуратора для загрузки");
			Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Исключение
			Результат = Ложь;
		КонецПопытки;

		ЛогПриложения.Информация("Результат: " + Результат);
		ТекстСообщения = "Загрузка конфигурации %1 завершена %2";
		Если Результат Тогда
			ЛогПриложения.Информация(СтрШаблон(ТекстСообщения, Настройка.Наименование, "успешно"));
			Если ОбновитьДамп И Не КаталогДляЗагрузки = Настройка.КаталогКонфигурации Тогда
				ДампКонфигурацииВрем = ОбъединитьПути(КаталогДляЗагрузки, "ConfigDumpInfo.xml");
				ДампКонфигурацииРепо = ОбъединитьПути(Настройка.КаталогКонфигурации, "ConfigDumpInfo.xml");
	
				Сообщение = СтрШаблон("Копирую рабочий каталог: %1 в %2", ДампКонфигурацииВрем, ДампКонфигурацииРепо);
				ЛогПриложения.Информация(Сообщение);
	
				КопироватьФайл(ДампКонфигурацииВрем, ДампКонфигурацииРепо);
			КонецЕсли;
		Иначе
			ЛогПриложения.Информация(СтрШаблон(ТекстСообщения, Настройка.Наименование, "с ошибками"));
		КонецЕсли;

		УдалитьВременныеФайлы(Настройка);

	КонецЦикла;

КонецПроцедуры

Процедура УдалитьВременныеФайлы(Настройка)
	
	УдалитьФайлы(Настройка.ФайлИзменений);
	Если Настройка.ТолькоИзменения Тогда
		УдалитьФайлы(Настройка.КаталогДляЗагрузки);
	КонецЕсли;

КонецПроцедуры

ЛогПриложения = ПараметрыПриложения.Лог();
