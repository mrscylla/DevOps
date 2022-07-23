
#Использовать strings
#Использовать logos

Перем ПутьКРепозиторию;
Перем ТипОперации;
Перем ЛогПриложения;

Перем ИзмененныеФайлы;

Процедура ПриСозданииОбъекта(Репозиторий, ТипОперацииЗагрузки, Лог)
	ПутьКРепозиторию = Репозиторий;
	ТипОперации = ТипОперацииЗагрузки;
	ЛогПриложения = Лог;
КонецПроцедуры

Процедура УстановитьЛогПриложения(Лог) Экспорт
	ЛогПриложения = Лог;
КонецПроцедуры

Функция ИмяТекущейВетки()

	ПроцессГит = Создатьпроцесс("git branch --show-current",
		ПутьКРепозиторию,
		Истина,
		Ложь,
		КодировкаТекста.UTF8
	);

	ПроцессГит.Запустить();										
	ПроцессГит.ОжидатьЗавершения();
	
	НазваниеТекущейВетки  = СокрЛП(ПроцессГит.ПотокВывода.Прочитать());

	Возврат НазваниеТекущейВетки;

КонецФункции

Функция ПутьКорневогоФайлаОбъектаМетаданных(ТекущийПуть)

	ЧастиПути = СтрРазделить(ТекущийПуть, "\");
	
	ФайлСуществует = Ложь;

	Пока Не ФайлСуществует Цикл
		
		ЧастиПути.Удалить(ЧастиПути.Количество() - 1);
	
		ПутьРодитель = СтрСоединить(ЧастиПути, "\") + ".xml";

		// Если изначально грузился корневой файл, то вместе с ним надо грузить configuration
		Если СтрЗаканчиваетсяНа(ПутьРодитель, "Config.xml") Тогда
			ПутьРодитель = СтрЗаменить(ПутьРодитель, "Config.xml", "Config\Configuration.xml");
		КонецЕсли;

		Файл = Новый Файл(ПутьРодитель);
		Если Файл.Существует() И Не СтрНайти(ПутьРодитель, "Form.xml") И Не СтрНайти(ПутьРодитель, "Forms")  Тогда
			ФайлСуществует = Истина;
		КонецЕсли;

	КонецЦикла;	

	Возврат ПутьРодитель;

КонецФункции

Функция ПутьРодительскогоФайлаКонфигурации(Знач ПолныйПуть)
	
	Обрабатывать = НЕ СтрНайти(ПолныйПуть, "Config\Ext\")
		И Не СтрНайти(ПолныйПуть, "ObjectModule") 
		И Не СтрНайти(ПолныйПуть, "ManagerModule") 
		И Не СтрНайти(ПолныйПуть, "CommandModule"); 

	ПозицияExt = СтрНайти(ПолныйПуть, "\Ext\");
	Если ПозицияExt И Обрабатывать Тогда // Эти модули загружаются частично из папки \Ext объектов
	
		// Модули форм совершенно точно не загружаются (возможно это ошибка платформы), необходимо загружать объект формы
		Если СтрНайти(ПолныйПуть, "Forms") И СтрНайти(ПолныйПуть, "Module.bsl") Тогда
			ПозицияМодуля  = СтрНайти(ПолныйПуть, "Module.bsl");
			ПолныйПуть = Лев(ПолныйПуть, ПозицияМодуля - 2) + ".xml"; // Form.xml
		Иначе
			ПолныйПуть = Лев(ПолныйПуть, ПозицияExt - 1) + ".xml";
		КонецЕсли;

	КонецЕсли;		

	Возврат ПолныйПуть;

КонецФункции

Функция ПутьРодительскогоФайлаВнешнихОбработок(Знач ПутьКФайлу)
	
	ТекущийФайл = Новый Файл(ПутьКФайлу);
	Родитель = Новый Файл(ТекущийФайл.Путь);
	Пока Не СтрЗаканчиваетсяНа(Родитель.ПолноеИмя, ЧастиРепозитория.ВнешниеОбработки) 
		И Не ТекущийФайл.ПолноеИмя = Родитель.ПолноеИмя Цикл
		
		ПутьКФайлу = Родитель.ПолноеИмя;
		ТекущийФайл = Новый Файл(ПутьКФайлу);
		Родитель = Новый Файл(ТекущийФайл.Путь);

	КонецЦикла;

	Возврат ПутьКФайлу;

КонецФункции

Функция ПутьРодительскогоФайла(ПутьКФайлу)

	Если ТипОперации = ЧастиРепозитория.ОсновнаяКонфигурация Тогда
		ПутьКРодителю = ПутьРодительскогоФайлаКонфигурации(ПутьКФайлу);
	ИначеЕсли ТипОперации = ЧастиРепозитория.ВнешниеОбработки Тогда
		ПутьКРодителю = ПутьРодительскогоФайлаВнешнихОбработок(ПутьКФайлу);
	КонецЕсли;
		
	Возврат ПутьКРодителю;

КонецФункции

Функция НеобходимоОбрабатыватьФайл(ПолныйПуть)

	Обрабатывать = Истина;

	Если Не СтрНайти(ПолныйПуть, ТипОперации) Тогда
		Обрабатывать = Ложь;
	КонецЕсли;

	Если СтрЗаканчиваетсяНа(ПолныйПуть, "ConfigDumpInfo.xml") Тогда
		Обрабатывать = Ложь;
	КонецЕсли;

	Возврат Обрабатывать;

КонецФункции

Функция ОписаниеИзмененногоФайла(СтатусФайла)

	Описание = Новый Структура;
	Описание.Вставить("Статус");
	Описание.Вставить("ПолныйПуть");
	Описание.Вставить("ОбрабатыватьФайл", Ложь);

	ЧастиСтатуса = СтрРазделить(СтатусФайла, Символы.Таб);

	Описание.Статус = Лев(ЧастиСтатуса[0], 1); // R, A, D, M

	Путь = ЧастиСтатуса[ЧастиСтатуса.Количество() - 1];
	ПолныйПуть = ОбъединитьПути(ПутьКРепозиторию, СтрЗаменить(Путь, "/", "\"));
	Описание.ОбрабатыватьФайл = НеобходимоОбрабатыватьФайл(ПолныйПуть);

	Если Описание.ОбрабатыватьФайл Тогда
		Описание.ПолныйПуть = ПутьРодительскогоФайла(ПолныйПуть);
	КонецЕсли;

	Возврат Описание;

КонецФункции

Функция ТаблицаИзмененныхФайлов() Экспорт

	Возврат ИзмененныеФайлы;

КонецФункции

Процедура ЗаполнитьТаблицуИзмененныхФайлов(ИмяФайлаСпискаФайлов)

	ИзмененныеФайлы = Новый ТаблицаЗначений;
	ИзмененныеФайлы.Колонки.Добавить("Путь");
	ИзмененныеФайлы.Колонки.Добавить("Уровень");

	Чтение = Новый ЧтениеТекста(ИмяФайлаСпискаФайлов, КодировкаТекста.UTF8);

	СтрокаФайла = Чтение.ПрочитатьСтроку();
	Пока Не СтрокаФайла = Неопределено Цикл

		ОписаниеФайла = ОписаниеИзмененногоФайла(СтрокаФайла);
		Если Не ОписаниеФайла.ОбрабатыватьФайл Тогда
			СтрокаФайла = Чтение.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;

		// Добавление родительского объекта
		Если СтрНайти("A,D", ОписаниеФайла.Статус) И СтрЗаканчиваетсяНа(ОписаниеФайла.ПолныйПуть, "xml") Тогда
	
			КорневойФайл = ПутьКорневогоФайлаОбъектаМетаданных(ОписаниеФайла.ПолныйПуть);

			СтрокаТаблицы = ИзмененныеФайлы.Добавить();
			СтрокаТаблицы.Путь = КорневойФайл;
			СтрокаТаблицы.Уровень = -СтрЧислоВхождений(КорневойФайл, "\");

		КонецЕсли;

		// Непосредственно сам измененный объект
		// Удаленные обработки включаем в любом случае
		Если Не ОписаниеФайла.Статус = "D" Или СтрНайти(ОписаниеФайла.ПолныйПуть, ЧастиРепозитория.ВнешниеОбработки) Тогда

			СтрокаТаблицы = ИзмененныеФайлы.Добавить();
			СтрокаТаблицы.Путь = ОписаниеФайла.ПолныйПуть;
			СтрокаТаблицы.Уровень = -СтрЧислоВхождений(ОписаниеФайла.ПолныйПуть, "\"); 
		
		КонецЕсли;
		
		СтрокаФайла = Чтение.ПрочитатьСтроку();
		
	КонецЦикла;

	Чтение.Закрыть();

	ИзмененныеФайлы.Сортировать("Уровень, Путь");
	ИзмененныеФайлы.Свернуть("Путь");

КонецПроцедуры

Процедура СкопироватьИзмененныеФайлыВоВременныйКаталог(ИмяФайлаСпискаФайлов, ПутьКВременномуКаталогу) Экспорт

	ЛогПриложения.Информация("Копирование файлов в каталог " + ПутьКВременномуКаталогу);

	ИмяВрФайла = ПолучитьИмяВременногоФайла();
	ЗаписьТекста = Новый ЗаписьТекста(ИмяВрФайла, КодировкаТекста.UTF8);

	Для Каждого ИзмененныйФайл Из ИзмененныеФайлы Цикл
		
		ПутьКРезультатуКопирования = СтрЗаменить(ИзмененныйФайл.Путь, ПутьКРепозиторию, ПутьКВременномуКаталогу);
		ИсходныйФайл = Новый Файл(ИзмененныйФайл.Путь);
		НовыйФайл = Новый Файл(ПутьКРезультатуКопирования);
				
		СоздатьКаталог(НовыйФайл.Путь);
		Если ИсходныйФайл.Существует() Тогда
			КопироватьФайл(ИсходныйФайл.ПолноеИмя, НовыйФайл.ПолноеИмя);
		КонецЕсли;
		
		ЗаписьТекста.ЗаписатьСтроку(ПутьКРезультатуКопирования);
	
		// Копирование одноименных (объекту) папок в папку загрузки
		ПутьОбъект = ОбъединитьПути(ИсходныйФайл.Путь, ИсходныйФайл.ИмяБезРасширения);
		СкопироватьФайлыКаталога(ПутьОбъект, ПутьКВременномуКаталогу);
		
		Если ИсходныйФайл.ИмяБезРасширения = "Configuration" Тогда
			ПутьExt = ОбъединитьПути(ИсходныйФайл.Путь, "Ext");
			СкопироватьФайлыКаталога(ПутьExt, ПутьКВременномуКаталогу);
		КонецЕсли;
		
	КонецЦикла;

	ЗаписьТекста.Закрыть();

	УдалитьФайлы(ИмяФайлаСпискаФайлов);
	ПереместитьФайл(ИмяВрФайла, ИмяФайлаСпискаФайлов);
	
	ЛогПриложения.Информация("Завершено копирование файлов в каталог " + ПутьКВременномуКаталогу);

КонецПроцедуры

Процедура СкопироватьФайлыКаталога(Источник, Получатель)

	Каталог = Новый Файл(Источник);
	Если Не Каталог.Существует() Тогда
		Возврат;
	КонецЕсли;

	МассивФайлов = НайтиФайлы(Источник, "*.*", Истина);
	Для Каждого ИсходныйФайл Из МассивФайлов Цикл
		Если Не ИсходныйФайл.Существует() Или ИсходныйФайл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;

		ПутьКРезультатуКопирования = СтрЗаменить(ИсходныйФайл.ПолноеИмя, ПутьКРепозиторию, Получатель);
		НовыйФайл = Новый Файл(ПутьКРезультатуКопирования);

		СоздатьКаталог(НовыйФайл.Путь);
		КопироватьФайл(ИсходныйФайл.ПолноеИмя, НовыйФайл.ПолноеИмя);

	КонецЦикла;

КонецПроцедуры

Процедура ПерейтиНаВетку(ИмяВетки) Экспорт

	ТекущаяВетка = ИмяТекущейВетки();

	// Проверить текущую ветку и если она не соответствует, перейти на нее
	Если Не ТекущаяВетка = ИмяВетки Тогда
		ЗапуститьПриложение("git checkout " + ИмяВетки, ПутьКРепозиторию, Истина);
		ЛогПриложения.Информация("Переход на ветку " + ИмяВетки);
	КонецЕсли;

КонецПроцедуры

Процедура СформироватьСписокИзмененныхФайлов(Знач ФайлВывода, СравниваемыеКоммиты = Неопределено) Экспорт
	
	ЛогПриложения.Информация("Формирование списка измененных файлов");

	Если Не СравниваемыеКоммиты = Неопределено Тогда
		
		Хеш1 = СравниваемыеКоммиты[0];
		Хеш2 = ?(СравниваемыеКоммиты.Количество() = 1, "HEAD", СравниваемыеКоммиты[1]);
		
		ШаблонКоманды = "cmd /C git diff %1 %2 --name-status > %3";
		Команда = СтрШаблон(ШаблонКоманды, Хеш1, Хеш2, ФайлВывода);
		ЗапуститьПриложение(Команда, ПутьКРепозиторию, Истина);

	Иначе
		ЗапуститьПриложение("cmd /C git diff @{1}.. --name-status > " + ФайлВывода, ПутьКРепозиторию, Истина);
		
	КонецЕсли;	
	
	ЗаполнитьТаблицуИзмененныхФайлов(ФайлВывода);

	ЛогПриложения.Информация("Сформирован список измененных файлов");

КонецПроцедуры

Функция ЕстьИзмененныеФайлы() Экспорт

	Возврат Не ИзмененныеФайлы = Неопределено И ИзмененныеФайлы.Количество();

КонецФункции