///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды
//
///////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать fs
#Использовать "../../../../core"

Перем Конфигуратор;

Перем КаталогОбработок;

Перем КаталогРепозитория;
Перем ТолькоИзменения;
Перем Коммиты;

Перем КорневыеФайлыОбработок;

Перем ЛогПриложения;
Перем ЛогCборкиОбработок;

Процедура ОписаниеКоманды(Знач Команда) Экспорт

	УстановитьПараметрыКоманды(Команда);
	УстановитьКоманды(Команда);

КонецПроцедуры // НастроитьКоманду

Процедура УстановитьКоманды(Знач Команда)

КонецПроцедуры

Процедура УстановитьПараметрыКоманды(Знач Команда)

	Команда.Аргумент("REPO", , "Сборка обработок репозитория")
		.ТСтрока()
	;

	Команда.Аргумент("DEST", , "Каталог, в который будут сохранены собранные обработки")
		.ТСтрока()
	;

	Команда.Опция("d diff", Ложь, "Сборка только измененных обработок (актуально только для сборки из репозитория). 
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

	Команда.Спек = "REPO DEST [-d [COMMIT...]]";

КонецПроцедуры


// Выполняет присваивание значений входящих параметров переменным модуля
//
// Параметры:
//	Команда - КомандаПриложения - выполняемая команда
//
Процедура ПрочитатьВходящиеПараметры(Знач Команда)

	ПараметрыПриложения.УстановитьПараметрыПриложения(Команда.Приложение);

	КаталогОбработок = Команда.ЗначениеАргумента("DEST");

	КаталогРепозитория = Команда.ЗначениеАргумента("REPO");
	ТолькоИзменения = Команда.ЗначениеОпции("diff");
	Коммиты = Команда.ЗначениеАргумента("COMMIT");

	ЛогCборкиОбработок = ОбъединитьПути(ПараметрыПриложения.КаталогЛогов(), "build_processors.log");

КонецПроцедуры

Процедура ПодготовитьСлужебныеФайлы()

	ФС.ОбеспечитьКаталог(КаталогОбработок);

	ОбщийФункционал.ОчиститьТекстовыйФайл(ЛогCборкиОбработок);

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

	ВыполнитьСборкуВнешнихОбработок();
	
КонецПроцедуры // ВыполнитьКоманду

Процедура ЗаполнитьСписокКорневыхОбработок()
	
	// Пользователь сам указал список
	Если Не ЗначениеЗаполнено(КаталогРепозитория) Тогда
		Возврат;
	КонецЕсли;
	
	Если ТолькоИзменения И Не Коммиты = Неопределено Тогда
		ЖурналСпискаФайлов = ПолучитьИмяВременногоФайла(".txt");

		Гит = Новый Гит(КаталогРепозитория, ЛогПриложения, ЧастиРепозитория.ВнешниеОбработки);
		Гит.СформироватьСписокИзмененныхФайлов(ЖурналСпискаФайлов, Коммиты);
		ТаблицаИзмененныхФайлов = Гит.ТаблицаИзмененныхФайлов();
		
		УдалитьФайлы(ЖурналСпискаФайлов);
		
		КаталогиОбработок = Новый Массив;
		Для Каждого Строка Из ТаблицаИзмененныхФайлов Цикл
			Каталог = Новый Файл(Строка.Путь);
			Если Каталог.Существует() Тогда
				КаталогиОбработок.Добавить(Каталог);
			КонецЕсли;
		КонецЦикла;

	Иначе
		КаталогиОбработок = НайтиФайлы(КаталогРепозитория, ПолучитьМаскуВсеФайлы());

	КонецЕсли;

	КорневыеФайлыОбработок = Новый Массив;
	Для Каждого Каталог Из КаталогиОбработок Цикл		
		Если Не Каталог.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;

		СодержимоеКаталога = НайтиФайлы(Каталог.ПолноеИмя, "*.xml");
		Если СодержимоеКаталога.Количество() Тогда
			КорневыеФайлыОбработок.Добавить(СодержимоеКаталога[0].ПолноеИмя);
		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Процедура ВыполнитьСборкуВнешнихОбработок()

	КомандаСборки = "/LoadExternalDataProcessorOrReportFromFiles ""%1"" ""%2""";
	ШаблонИмениОбработки = ОбъединитьПути(КаталогОбработок, "%1");

	Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ЛогCборкиОбработок);	

	УспешноСобрано = 0;
	ЗаполнитьСписокКорневыхОбработок();

	ЛогПриложения.Информация("Начало сборки обработок");

	Для Каждого Обработка Из КорневыеФайлыОбработок Цикл
		Файл = Новый Файл(Обработка);
		ПутьКОбработке = СтрШаблон(ШаблонИмениОбработки, Файл.ИмяБезРасширения);
		
		РезультатСборки = Истина;

		ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
		ПараметрыЗапуска.Добавить(СтрШаблон(КомандаСборки, Обработка, ПутьКОбработке));
		Попытка
			Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		Исключение
			ЛогПриложения.Ошибка(СтрШаблон("Не удалось собрать обработку: %1", Обработка));
			РезультатСборки = Ложь;
		КонецПопытки;

		Если РезультатСборки Тогда
			УспешноСобрано = УспешноСобрано + 1;
		КонецЕсли;

		Конфигуратор.УстановитьИмяФайлаСообщенийПлатформы(ЛогCборкиОбработок, Ложь);

	КонецЦикла;

	Сообщение = СтрШаблон("Успешно собрано %1 из %2 обработок", УспешноСобрано, КорневыеФайлыОбработок.Количество());
	ЛогПриложения.Информация(Сообщение);

КонецПроцедуры

ЛогПриложения = ПараметрыПриложения.Лог();
