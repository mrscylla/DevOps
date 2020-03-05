#Использовать strings
#Использовать logos

Перем РежимыОтслеживаемыхИзменений Экспорт;

Функция ПолучитьНазваниеТекущейВетки(КаталогРепозитария) Экспорт

	ПроцессГит = Создатьпроцесс("git rev-parse --abbrev-ref HEAD"
								, КаталогРепозитария
								, Истина
								, Ложь
								, КодировкаТекста.UTF8);
	ПроцессГит.Запустить();										
	ПроцессГит.ОжидатьЗавершения();
	
	НазваниеТекущейВетки  = СокрЛП(ПроцессГит.ПотокВывода.Прочитать());

	Возврат НазваниеТекущейВетки;

КонецФункции

Функция ПолучитьНазваниеВеткиСлияния() Экспорт

	ПроцессГит = Создатьпроцесс("git cherry -v HEAD MERGE_HEAD"
								, ТекущийКаталог()
								, Истина
								, Ложь
								, КодировкаТекста.UTF8);
	ПроцессГит.Запустить();										
	ПроцессГит.ОжидатьЗавершения();

	ТекстСообщения  = ПроцессГит.ПотокВывода.Прочитать();

	Возврат СокрЛП(ТекстСообщения);
	//Возврат "origin1c";
	
КонецФункции

Функция НайтиПутьРодительскогоОбъекта(ТекущийПуть, Журнал)

	Журнал.Отладка("Ищу родителя для: " + ТекущийПуть);

	МасСтр = СтрРазделить(ТекущийПуть, "\");
	
	ФайлСуществует = Ложь;

	Пока Не ФайлСуществует Цикл
		
		МасСтр.Удалить(МасСтр.Количество() - 1);
	
		ПутьРодитель = СтрСоединить(МасСтр, "\") + ".xml";
		ПутьРодитель = СтрЗаменить(ПутьРодитель, "Config.xml", "Config\Configuration.xml");

		Файл = Новый Файл(ПутьРодитель);

		Журнал.Отладка("Пробую: " + ПутьРодитель);

		Если Файл.Существует() И Не СтрНайти(ПутьРодитель, "Form.xml") И Не СтрНайти(ПутьРодитель, "Forms")  Тогда

			ФайлСуществует = Истина;
			Журнал.Отладка("Файл существует: " + ПутьРодитель);

		КонецЕсли;

	КонецЦикла;	

	Возврат ПутьРодитель;

КонецФункции

Функция ОбработатьСтрокуИзмененияКонфигурации(Знач Стр, Знач СтрЗТ, ПутьКРепозиторию, Журнал)

	// "R088" ???
	Если Стр[0] = "R088" ИЛИ СтрЗаканчиваетсяНа(СтрЗТ, "ConfigDumpInfo.xml") Тогда
		Журнал.Информация(СтрШаблон("Пропускаю  %1 %2", Стр[0], Стр[1]));
		Возврат Неопределено;
	КонецЕсли;

	БылоПреобразование = Ложь;
	
	ПозExt = СтрНайти(СтрЗТ, "\Ext\");
	Если ПозExt И НЕ СтрНайти(СтрЗТ, "Config\Ext\")
		И Не СтрНайти(СтрЗТ, "ObjectModule") 
		И Не СтрНайти(СтрЗТ, "ManagerModule") 
		И Не СтрНайти(СтрЗТ, "CommandModule") Тогда // Эти модули загружаются частично из папки \Ext объектов
	
		// Модули форм совершенно точно не загружаются (возможно это ошибка платформы), необходимо загружать объект формы
		Если СтрНайти(СтрЗТ, "Forms") И СтрНайти(СтрЗТ, "Module.bsl") Тогда
			ПозМодуля = СтрНайти(СтрЗТ, "Module.bsl");
			ИмяФормы = Сред(СтрЗТ, ПозExt + 5, ПозМодуля - ПозExt - 6);
			СтрЗТ = Сред(СтрЗТ, 1, ПозExt + 4) + ИмяФормы  + ".xml";	
		Иначе
			СтрЗТ = Сред(СтрЗТ, 1, ПозExt - 1) + ".xml";
		КонецЕсли;
		
		БылоПреобразование = Истина;

	КонецЕсли;		
	
	Если СтрНайти(СтрЗТ, "Config.xml") Тогда // Сюда не должны попадать
		СтрЗТ = ОбъединитьПути(ПутьКРепозиторию, "Config\Configuration.xml");
	КонецЕсли;			
	
	Если БылоПреобразование Тогда
		Журнал.Информация(СтрШаблон("Преобразовано: %1 \ %2 -> %3", ПутьКРепозиторию, СтрЗаменить(Стр[1], "/", "\"), СтрЗТ));
	КонецЕсли;

	Возврат СтрЗТ;

КонецФункции



Функция ОбработатьСтрокуИзмененияВнешнихОбработок(Знач Стр, Знач СтрЗТ, ПутьКРепозиторию, Журнал)
	
	ТекущийФайл = Новый Файл(СтрЗТ);
	Родитель = Новый Файл(ТекущийФайл.Путь);
	Пока Не СтрЗаканчиваетсяНа(Родитель.ПолноеИмя, РежимыОтслеживаемыхИзменений.ВнешниеОбработки) 
		И Не ТекущийФайл.ПолноеИмя = Родитель.ПолноеИмя Цикл
		СтрЗТ = Родитель.ПолноеИмя;
		ТекущийФайл = Новый Файл(СтрЗТ);
		Родитель = Новый Файл(ТекущийФайл.Путь);
	КонецЦикла;

	Возврат СтрЗТ;

КонецФункции

Функция ОбработатьСтрокуИзменения(Знач Стр, ОтслеживаемыеИзменения, ПутьКРепозиторию, Журнал)

	Если Лев(Стр[0], 1) = "R" Тогда
		СтрЗТ = СтрШаблон("%1\%2", ПутьКРепозиторию, СтрЗаменить(Стр[2], "/", "\"));			
	ИначеЕсли Не ПустаяСтрока(Стр) Тогда
		СтрЗТ = СтрШаблон("%1\%2", ПутьКРепозиторию, СтрЗаменить(Стр[1], "/", "\"));
	Иначе
		СтрЗТ = "";
	КонецЕсли;

	Если СтрНайти(СтрЗТ, ОтслеживаемыеИзменения) Тогда
		Если ОтслеживаемыеИзменения = РежимыОтслеживаемыхИзменений.ОсновнаяКонфигурация Тогда
			СтрЗТ = ОбработатьСтрокуИзмененияКонфигурации(Стр, СтрЗТ, ПутьКРепозиторию, Журнал);
		ИначеЕсли ОтслеживаемыеИзменения = РежимыОтслеживаемыхИзменений.ВнешниеОбработки Тогда
			СтрЗТ = ОбработатьСтрокуИзмененияВнешнихОбработок(Стр, СтрЗТ, ПутьКРепозиторию, Журнал);
		Иначе
			СтрЗТ = Неопределено;
		КонецЕсли;
	Иначе
		Журнал.Информация(СтрШаблон("Пропускаю  %1 %2", Стр[0], СтрЗТ));
	КонецЕсли;
		
	Возврат СтрЗТ;

КонецФункции

Функция ТаблицаИзмененныхФайлов(ПутьКРепозиторию, ОтслеживаемыеИзменения, ИмяФайлаСпискаФайлов, Журнал) Экспорт

	ТЗ = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("Новый");
	ТЗ.Колонки.Добавить("Путь");
	ТЗ.Колонки.Добавить("Уровень");

	ЧТ = Новый ЧтениеТекста(ИмяФайлаСпискаФайлов, КодировкаТекста.UTF8);

	Стр = ЧТ.ПрочитатьСтроку();
	Пока Не Стр = Неопределено Цикл

		Журнал.Отладка("Обрабатываю " + Стр);

		Стр = СтрРазделить(Стр, Символы.Таб);
		ИзмененныйФайл = ОбработатьСтрокуИзменения(Стр, ОтслеживаемыеИзменения, ПутьКРепозиторию, Журнал);
		Если ИзмененныйФайл = Неопределено Или Не СтрНайти(ИзмененныйФайл, ОтслеживаемыеИзменения) Тогда
			Стр = ЧТ.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;
		
		Если (Стр[0] = "A" Или Стр[0] = "D") И СтрЗаканчиваетсяНа(ИзмененныйФайл, "xml") Тогда
	
			СтрРодитель = НайтиПутьРодительскогоОбъекта(ИзмененныйФайл, Журнал);

			СтрТз = ТЗ.Добавить();
			СтрТз.Новый = Ложь;
			СтрТз.Путь = СтрРодитель;
			СтрТз.Уровень = -СтрЧислоВхождений(СтрРодитель, "\");

			Журнал.Информация(СтрШаблон("%1 %2 -> %3", Стр[0], ИзмененныйФайл, СтрРодитель));

		КонецЕсли;

		// Удаленные обработки включаем в любом случае
		Если Не Стр[0] = "D" Или СтрНайти(ИзмененныйФайл, РежимыОтслеживаемыхИзменений.ВнешниеОбработки) Тогда

			ЭтоНовыйОбъект = Стр[0] = "A";

			СтрТз = ТЗ.Добавить();
			СтрТз.Новый = ЭтоНовыйОбъект;
			СтрТз.Путь = ИзмененныйФайл;
			СтрТз.Уровень = -СтрЧислоВхождений(ИзмененныйФайл, "\"); 
		
		КонецЕсли;
		
		Стр = ЧТ.ПрочитатьСтроку();
		
	КонецЦикла;

	ЧТ.Закрыть();

	ТЗ.Сортировать("Уровень, Путь");
	ТЗ.Свернуть("Путь");
	Возврат ТЗ;

КонецФункции

Функция СкопироватьИзмененныеФайлыВоВременныйКаталог(ТЗ, ПутьКРепозиторию, ИмяФайлаСпискаФайлов, Журнал)

	ПутьКВременномуКаталогу = ОбъединитьПути(КаталогВременныхФайлов(), "1C_GIT_PART");
	СоздатьКаталог(ПутьКВременномуКаталогу);
	УдалитьФайлы(ПутьКВременномуКаталогу, "*.*");

	ИмяВрФайла = ПолучитьИмяВременногоФайла();
	ЗТ = Новый ЗаписьТекста(ИмяВрФайла, КодировкаТекста.UTF8);

	Для Каждого СтрТз Из ТЗ Цикл
		
		ПутьКРезультатуКопирования = СтрЗаменить(СтрТз.Путь, ПутьКРепозиторию, ПутьКВременномуКаталогу);
		ИсходныйФайл = Новый Файл(СтрТз.Путь);
		НовыйФайл = Новый Файл(ПутьКРезультатуКопирования);
		
		Журнал.Информация(СтрШаблон("Копирую во временный каталог: %1 в %2", ИсходныйФайл.ПолноеИмя, НовыйФайл.ПолноеИмя));		
		СоздатьКаталог(НовыйФайл.Путь);
		Если ИсходныйФайл.Существует() Тогда
			КопироватьФайл(ИсходныйФайл.ПолноеИмя, НовыйФайл.ПолноеИмя);
		КонецЕсли;
		
		ЗТ.ЗаписатьСтроку(ПутьКРезультатуКопирования);
	
		//Копирование одноименных (объекту) папок в папку загрузки
		ПутьОбъект = ОбъединитьПути(ИсходныйФайл.Путь, ИсходныйФайл.ИмяБезРасширения);
		СкопироватьФайлыКаталога(ПутьОбъект, ПутьКВременномуКаталогу, ПутьКРепозиторию, Журнал);
		
		Если ИсходныйФайл.ИмяБезРасширения = "Configuration" Тогда
			ПутьExt = ОбъединитьПути(ИсходныйФайл.Путь, "Ext");
			СкопироватьФайлыКаталога(ПутьExt, ПутьКВременномуКаталогу, ПутьКРепозиторию, Журнал);
		КонецЕсли;
		
	КонецЦикла;

	ЗТ.Закрыть();

	УдалитьФайлы(ИмяФайлаСпискаФайлов);
	ПереместитьФайл(ИмяВрФайла, ИмяФайлаСпискаФайлов);

	Возврат ПутьКВременномуКаталогу;

КонецФункции

Процедура СкопироватьФайлыКаталога(Источник, Получатель, ПутьКРепозиторию, Журнал)

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

		Журнал.Информация(СтрШаблон("Копирую во временный каталог: %1 в %2", ИсходныйФайл.ПолноеИмя, НовыйФайл.Путь));
		СоздатьКаталог(НовыйФайл.Путь);
		КопироватьФайл(ИсходныйФайл.ПолноеИмя, НовыйФайл.ПолноеИмя);

	КонецЦикла;

КонецПроцедуры

Функция ОбработатьФайлИзменений(ПутьКРепозиторию, ОтслеживаемыеИзменения, ИмяФайлаСпискаФайлов, Журнал) Экспорт
	
	ТЗ = ТаблицаИзмененныхФайлов(ПутьКРепозиторию, ОтслеживаемыеИзменения, ИмяФайлаСпискаФайлов, Журнал);
	ПутьКРепозиторию = СкопироватьИзмененныеФайлыВоВременныйКаталог(ТЗ, ПутьКРепозиторию, ИмяФайлаСпискаФайлов, Журнал);
	
	Возврат ТЗ.Количество();
	
КонецФункции

Процедура ПерейтиНаВетку(ПутьКРепозиторию, ИмяВетки, Журнал = неопределено) Экспорт

	ТекущаяВетка = ПолучитьНазваниеТекущейВетки(ПутьКРепозиторию);

	// Проверить текущую ветку и если она не соответствует, перейти на нее
	Если Не ТекущаяВетка = ИмяВетки Тогда
	
		ЗапуститьПриложение("git checkout " + ИмяВетки, ПутьКРепозиторию, Истина);
		
	ИначеЕсли Не Журнал = Неопределено Тогда
		
		Журнал.Информация("переход на ветку " + ИмяВетки + " так как текущая ветка и так " + ТекущаяВетка);
		
	КонецЕсли;

КонецПроцедуры

Процедура ПолучитьСписокИзмененийВФайл(Знач ПутьКРепозиторию, Знач ИмяФайлаСпискаФайлов, Журнал, СравниваемыеКомиты = Неопределено) Экспорт
	
	Если Не СравниваемыеКомиты = Неопределено И СравниваемыеКомиты.Количество() = 2 Тогда
		Сообщить("Запускаю: cmd /C git diff " + СравниваемыеКомиты[0] + " " + СравниваемыеКомиты[1] + " --name-status > " + ИмяФайлаСпискаФайлов);
		ЗапуститьПриложение("cmd /C git diff " + СравниваемыеКомиты[0] + " " + СравниваемыеКомиты[1] + " --name-status > " + ИмяФайлаСпискаФайлов, ПутьКРепозиторию, Истина);
	
	Иначе
		
		ЗапуститьПриложение("cmd /C git diff @{1}.. --name-status > " + ИмяФайлаСпискаФайлов, ПутьКРепозиторию, Истина);
		//ЗапуститьПриложение("cmd /C git diff d1315564988df781c8d8e88245564284cc82e7bf f43dc75005c330be4c8f88b9df87593da94e07eb --name-status > " + ИмяФайлаСпискаФайлов, ПутьКРепозиторию, Истина);
		
	КонецЕсли;	
	
	
КонецПроцедуры

СтруктураРежимов = Новый Структура;
СтруктураРежимов.Вставить("ОсновнаяКонфигурация", "Config\");
СтруктураРежимов.Вставить("ВнешниеОбработки", "Ext_processors\");
РежимыОтслеживаемыхИзменений = Новый ФиксированнаяСтруктура(СтруктураРежимов);

// ВремКаталог = "D:\Users\AAZ\git\erp";
// СписокФайлов = "D:\Users\AAZ\git\files.txt";

// Коммиты = Новый Массив;
// Коммиты.Добавить("76d6d63810c39a976b58e797a2f07cc1d9519466");
// Коммиты.Добавить("09f45e5eca3df3ce4b576660ba1710c4d86b81ef");
// // ПолучитьСписокИзмененийВФайл(ВремКаталог, СписокФайлов, 
// // 	Логирование.ПолучитьЛог("load_changes.app.git"), Коммиты);
	

// КоличествоИзменений = ОбработатьФайлИзменений(ВремКаталог, 
// 	РежимыОтслеживаемыхИзменений.ОсновнаяКонфигурация, 
// 	СписокФайлов, 
// 	Логирование.ПолучитьЛог("load_changes.app.git"));	

// Сообщить(КоличествоИзменений);
