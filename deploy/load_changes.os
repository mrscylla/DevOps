#Использовать cmdline
#Использовать logos
#Использовать v8runner

//Для логирования
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

    Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

КодВозврата = 0;
ИнфоОСкрипте = ТекущийСценарий();
КаталогСкрипта = ИнфоОСкрипте.Каталог;
ЧастичнаяЗагрузка = Истина;

ПодключитьСценарий(ОбъединитьПути(КаталогСкрипта, "..\lib\git.os"), "git");
git = Новый git();

УправлениеКонфигуратором = Новый УправлениеКонфигуратором();
ПутьКПлатформе1С = УправлениеКонфигуратором.ПолучитьПутьКВерсииПлатформы("8.3");

//#Область Определение параметров

АргументыКС = Новый ПарсерАргументовКоманднойСтроки();
АргументыКС.ДобавитьИменованныйПараметр("-repo");
АргументыКС.ДобавитьИменованныйПараметр("-branch");
АргументыКС.ДобавитьИменованныйПараметр("-ibname");
АргументыКС.ДобавитьИменованныйПараметр("-srvname");
АргументыКС.ДобавитьИменованныйПараметр("-usr");
АргументыКС.ДобавитьИменованныйПараметр("-pwd");
АргументыКС.ДобавитьИменованныйПараметр("-fastupdate");
АргументыКС.ДобавитьИменованныйПараметр("-fixedchanges");
АргументыКС.ДобавитьИменованныйПараметр("-dpath");
АргументыКС.ДобавитьИменованныйПараметр("-deploycfg");
АргументыКС.ДобавитьИменованныйПараметр("-deployext");
АргументыКС.ДобавитьИменованныйПараметр("-loadall");
АргументыКС.ДобавитьИменованныйПараметр("-fromHash");
АргументыКС.ДобавитьИменованныйПараметр("-toHash");
АргументыКС.ДобавитьИменованныйПараметр("-db");
АргументыКС.ДобавитьИменованныйПараметр("-loadchanges");
АргументыКС.ДобавитьИменованныйПараметр("-loadextension");
АргументыКС.ДобавитьИменованныйПараметр("-updatecfgdump");
АргументыКС.ДобавитьИменованныйПараметр("-updatedb");
АргументыКС.ДобавитьИменованныйПараметр("-syntaxctrl");

Параметры = АргументыКС.Разобрать(АргументыКоманднойСтроки);

ПутьКРепозитарию = Параметры["-repo"];
ИмяВетки = Параметры["-branch"];
ИмяСервера = Параметры["-srvname"];
ИмяБазы = Параметры["-ibname"];
Пользователь = Параметры["-usr"];
Пароль = Параметры["-pwd"];
БыстроеОбновление = ?(Параметры["-fastupdate"] = "true", Истина, Ложь);
НеПолучатьИзменения = ?(Параметры["-fixedchanges"] = "true", Истина, Ложь);
ПутьКПоставке = Параметры["-dpath"];
ВыгружатьКонфигурацию = Параметры["-deploycfg"];
ВыгружатьРасширение = Параметры["-deployext"];
ЗагрузитьВсе = ?(Параметры["-loadall"] = "true", Истина, Ложь);
ПервыйХеш = Параметры["-fromHash"];
ВторойХеш = Параметры["-toHash"];
ЗагрузитьИзменения = ?(Параметры["-loadchanges"] = "false", Ложь, Истина);
ЗагрузитьРасширение = ?(Параметры["-loadextension"] = "false", Ложь, Истина);
ОбновитьДампКонфигурации = ?(Параметры["-updatecfgdump"] = "false", Ложь, Истина);
ОбновитьБазуДанных = ?(Параметры["-updatedb"] = "false", Ложь, Истина);
СинтаксическийКонтроль = ?(Параметры["-syntaxctrl"] = "true", Истина, Ложь);

//-------------------------------------------------------

//Нужные папки всегда создаем
Если ЗначениеЗаполнено(ПутьКПоставке) Тогда
	
	СоздатьКаталог(ПутьКПоставке);
	
КонецЕсли;	

//#Область НастройкиЖурнала

ИмяФайлаЖурнала = ОбъединитьПути(ТекущийКаталог(), "Logs", ИмяБазы, ИмяВетки + ".log");
Файл = Новый Файл(ИмяФайлаЖурнала);
СоздатьКаталог(Файл.Путь);
КаталогЖурналов = Файл.Путь;

Журнал = Логирование.ПолучитьЛог("load_changes.app.loading");
Журнал.УстановитьУровень(УровниЛога.Информация);
Журнал.УстановитьРаскладку(ЭтотОбъект);

КонсольЖурн = Новый ВыводЛогаВКонсоль;
ФайлЖурнала = Новый ВыводЛогаВФайл;
ФайлЖурнала.ОткрытьФайл(ИмяФайлаЖурнала, "windows-1251");

Журнал.ДобавитьСпособВывода(ФайлЖурнала);
Журнал.ДобавитьСпособВывода(КонсольЖурн);

ЖурналЗагрузкиИзменений = ОбъединитьПути(КаталогЖурналов, "LoadChanges_" + ИмяБазы + ".log");
ЖурналЗагрузкиИзмененийРасширения = ОбъединитьПути(КаталогЖурналов, "LoadChanges_ext_" + ИмяБазы + ".log");
ЖурналВыгрузкиФайлапоставки = ОбъединитьПути(КаталогЖурналов, "Deploy_" + ИмяБазы + ".log");
ЖурналСинтаксическогоКонтроля = ОбъединитьПути(КаталогЖурналов, "CheckModules_" + ИмяБазы + ".log");
ЖурналОбновленияДампа = ОбъединитьПути(КаталогЖурналов, "UpdConfigDump_" + ИмяБазы + ".log");

//#КонецОбласти

// Проверка заполнения основных параметров
// 	Обязательные параметры: ИмяСервера, ИмяБазы, Пользователь, Пароль
Если Не ЗначениеЗаполнено(ИмяСервера) ИЛИ Не ЗначениеЗаполнено(ИмяБазы) ИЛИ Не ЗначениеЗаполнено(Пользователь) ИЛИ Не ЗначениеЗаполнено(Пароль) Тогда

	Журнал.Ошибка("Не заполнены обязательные параметры! (Обязательные параметры: ИмяСервера, ИмяБазы, Пользователь, Пароль)");
	ЗавершитьРаботу(-1);

КонецЕсли;

// Загрузка изменений в конфигурацию и расширение (Необходимые параметры: ПутьКРепозитарию, ИмяВетки)
Если ЗагрузитьИзменения ИЛИ ЗагрузитьВсе Тогда 

	Если БыстроеОбновление Тогда

		Журнал.Информация("Включен режим быстрого обновления");

	КонецЕсли;

	Если Не ЗначениеЗаполнено(ПутьКРепозитарию) ИЛИ Не ЗначениеЗаполнено(ИмяВетки) Тогда
	
		Журнал.Ошибка("Не заполнены параметры ""ПутьКРепозитарию"" ИЛИ ""ИмяВетки"". Загрузка изменений не возможна!");
	
	Иначе
		
		ИмяФайлаСпискаФайлов = ОбъединитьПути(?(ЗначениеЗаполнено(ПутьКПоставке), ПутьКПоставке, ТекущийКаталог()), ИмяБазы, ИмяВетки + "_lastfiles.txt");
		Файл = Новый Файл(ИмяФайлаСпискаФайлов);
		СоздатьКаталог(Файл.Путь);
		Журнал.Информация("формирую список измененных файлов в " + ИмяФайлаСпискаФайлов);

		// Переключить ветку GIT на "ИмяВетки"
		Журнал.Информация("Переход на ветку  " + ИмяВетки + " в репозитории " + ПутьКРепозитарию); 
		git.ПерейтиНаВетку(ПутьКРепозитарию, ИмяВетки);

		// Получить список измененных файлов или установить признак полной загрузки
		Если НеПолучатьИзменения Тогда

			КолВоИзменений = 1;
			Журнал.Информация("использую существующий список файлов " + ИмяФайлаСпискаФайлов);

		Иначе

			Если ЗначениеЗаполнено(ПервыйХеш) И ЗначениеЗаполнено(ВторойХеш) Тогда

				МассивКоммитов = Новый Массив;
				МассивКоммитов.Добавить(ПервыйХеш);
				МассивКоммитов.Добавить(ВторойХеш);
				
			КонецЕсли;	

			// Получить список измененных файлов текущей ветки GIT
			Журнал.Информация("получение списка из " + ПутьКРепозитарию);
			git.ПолучитьСписокИзмененийВФайл(ПутьКРепозитарию, ИмяФайлаСпискаФайлов, Журнал, МассивКоммитов);
			КолВоИзменений = git.ОбработатьФайлИзменений(ПутьКРепозитарию, ИмяФайлаСпискаФайлов, Журнал);

		КонецЕсли;	
		
		Если КолВоИзменений <> 0 Тогда

			Если КолВоИзменений < 0 или ЗагрузитьВсе Тогда
			
				ЧастичнаяЗагрузка = Ложь;
			
			КонецЕсли;

			Если БыстроеОбновление Тогда

				Журнал.Информация("Включен режим быстрого обновления");

			КонецЕсли;
			
			
			//Загрузка основной конфигурации
			Журнал.Информация("Начало " + ?(ЧастичнаяЗагрузка, "частичной", "полной") + " загрузки конфигурации из файлов.");
			Журнал.Информация("Запуск: """ + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /S """ + ИмяСервера + "\" + ИмяБазы + """ /N """ + Пользователь + """ /P ""******"" /LoadConfigFromFiles " + ПутьКРепозитарию + "\Config " + ?(ЧастичнаяЗагрузка, "-ListFile " + ИмяФайлаСпискаФайлов, "") + ?(ОбновитьБазуДанных, " /UpdateDBCfg", "") + " /out " + ОбъединитьПути(КаталогЖурналов, "loadchanges_" + ИмяБазы + ".log"));
			ПроцессКонфигуратора = Создатьпроцесс("""" + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /S """ + ИмяСервера + "\" + ИмяБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /LoadConfigFromFiles " + ПутьКРепозитарию + "\Config " + ?(ЧастичнаяЗагрузка, "-ListFile " + ИмяФайлаСпискаФайлов, "") + ?(ОбновитьБазуДанных, " /UpdateDBCfg", "") + " /UpdateDBCfg /out " + ЖурналЗагрузкиИзменений
													,ПутьКРепозитарию
													,Истина
													,Ложь
													,КодировкаТекста.UTF8);
			ПроцессКонфигуратора.Запустить();										
			ПроцессКонфигуратора.ОжидатьЗавершения();

			Журнал.Информация("обновление базы " + ИмяБазы + " завершено");
			
			ЧТ = Новый ЧтениеТекста(ЖурналЗагрузкиИзменений);
			РезультатЗагрузкиИзменений = ЧТ.Прочитать();
			ИзмененияЗагруженыУспешно = СтрНайти(РезультатЗагрузкиИзменений, "Обновление конфигурации успешно завершено") > 0;
			ЧТ.Закрыть();	
		
			Журнал.Информация(?(ЧастичнаяЗагрузка, "Частичная", "Полная") + " загрузка из файлов " + ?(ИзмененияЗагруженыУспешно, "успешно завершена", "не удалась") + " (см. " + ЖурналЗагрузкиИзменений + ")");
		
			// Загрузка расширения конфигурации -------------------
			Журнал.Информация("Начало полной загрузки расширения из файлов.");
			Журнал.Информация("Запуск: """ + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /S """ + ИмяСервера + "\" + ИмяБазы + """ /N """ + Пользователь + """ /P ""******"" /LoadConfigFromFiles " + ПутьКРепозитарию + "\Extension -Extension ""Расширение_РТИТС"" " + ?(ОбновитьБазуДанных, " /UpdateDBCfg", "") + " /out " + ЖурналЗагрузкиИзмененийРасширения);
			ПроцессКонфигуратора = Создатьпроцесс("""" + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /S """ + ИмяСервера + "\" + ИмяБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /LoadConfigFromFiles " + ПутьКРепозитарию + "\Extension -Extension ""Расширение_РТИТС"" " + ?(ОбновитьБазуДанных, " /UpdateDBCfg", "") + " /out " + ЖурналЗагрузкиИзмененийРасширения
													,ПутьКРепозитарию
													,Истина
													,Ложь
													,КодировкаТекста.UTF8);
			ПроцессКонфигуратора.Запустить();										
			ПроцессКонфигуратора.ОжидатьЗавершения();

			ЧТ = Новый ЧтениеТекста(ЖурналЗагрузкиИзмененийРасширения);
			РезультатЗагрузкиИзменений = ПроцессКонфигуратора.КодВозврата = 0;
			ЧТ.Закрыть();
			
			Журнал.Информация("обновление расширения для базы " + ИмяБазы + " завершено " + ?(РезультатЗагрузкиИзменений, "успешно.", "не успешно."));
			//-----------------------------------------------------	
		
		Иначе

			Журнал.Информация("Изменений в репозитории """ + ПутьКРепозитарию + """ нет.");	
		
		КонецЕсли;
		
	КонецЕсли;
	
КонецЕсли;

// Синтаксический контроль
Если СинтаксическийКонтроль Тогда //

	Если ИзмененияЗагруженыУспешно Тогда
	
		Журнал.Информация("Проведение синтаксического контроля модулей"); // /CheckModules [-ThinClient] [-WebClient] [-Server] [-ExternalConnection] [-ThickClientOrdinaryApplication] [-MobileAppClient] [-MobileAppServer] [-ExtendedModulesCheck][-
		ПроцессКонфигуратора = Создатьпроцесс("""" + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /S """ + ИмяСервера + "\" + ИмяБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /CheckModules -ThinClient -WebClient -Server -ExternalConnection /out " + ЖурналСинтаксическогоКонтроля
												,ПутьКРепозитарию
												,Истина
												,Ложь
												,КодировкаТекста.UTF8);
		ПроцессКонфигуратора.Запустить();										
		ПроцессКонфигуратора.ОжидатьЗавершения();

		ЧТ = Новый ЧтениеТекста(ЖурналСинтаксическогоКонтроля);
		РезультатЗагрузкиИзменений = ЧТ.Прочитать();
		СинтаксическийКонтрольУспешен = СтрНайти(РезультатЗагрузкиИзменений, "Синтаксических ошибок не обнаружено!") > 0;
		ЧТ.Закрыть();
		
		Журнал.Информация("Синтаксический контроль в базе " + ИмяБазы + " завершен " + ?(СинтаксическийКонтрольУспешен, "успешно!", "с ошибками!"));
	
	Иначе
	
	КонецЕсли;
	
КонецЕсли;	
 		
// Выгрузка конфигурации в файл		
Если ВыгружатьКонфигурацию И ((СинтаксическийКонтроль и СинтаксическийКонтрольУспешен) ИЛИ Не СинтаксическийКонтроль) Тогда

	Если Не ЗначениеЗаполнено(ПутьКПоставке) Тогда
	
		Журнал.Ошибка("Не заполнен путь к поставке! Параметр -dPath неопределен!");
		
	Иначе
	
		Журнал.Информация("Начало подготовки файла выгрузки конфигурации");
		ПроцессКонфигуратора = Создатьпроцесс("""" + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /S """ + ИмяСервера + "\" + ИмяБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /DumpCfg " + ОбъединитьПути(ПутьКПоставке, ИмяБазы + ".cf") + " /out " + ЖурналВыгрузкиФайлапоставки
												,ПутьКРепозитарию
												,Истина
												,Ложь
												,КодировкаТекста.UTF8);
		ПроцессКонфигуратора.Запустить();										
		ПроцессКонфигуратора.ОжидатьЗавершения();
		
		Журнал.Информация("выгрузка конфигурации из базы " + ИмяБазы + " завершена");
	
		ЧТ = Новый ЧтениеТекста(ЖурналВыгрузкиФайлапоставки);
		РезультатПодготовкипоставки = ЧТ.Прочитать();
		ПоставкаСозданаУспешно = СтрНайти(РезультатПодготовкипоставки, "Сохранение конфигурации успешно завершено") > 0;
		ЧТ.Закрыть();
	
		Если ПоставкаСозданаУспешно Тогда
		
			ЗТ = Новый ЗаписьТекста(ОбъединитьПути(ПутьКПоставке, "needupdate.flg"));
			ЗТ.ЗаписатьСтроку(ОбъединитьПути(ПутьКПоставке, ИмяБазы + ".cf"));
			ЗТ.Закрыть();
			Журнал.Информация("Создан семафор необходимости обновления рабочей базы.");
		
		КонецЕсли;
	
	
	КонецЕсли;

КонецЕсли;		
	
// Обновить ConfigDump.xml	
Если ОбновитьДампКонфигурации Тогда	

	Если Не ЗначениеЗаполнено(ПутьКРепозитарию) ИЛИ Не ЗначениеЗаполнено(ИмяВетки) Тогда

		Журнал.Ошибка("невозможно обновить дамп конфигурации если не заданы параметры ""ПутьКРепозитарию"" и ""ИмяВетки"" ");
	
	Иначе
		// Переключить ветку GIT на "ИмяВетки"
		Журнал.Информация("Переход на ветку  " + ИмяВетки + " в репозитории " + ПутьКРепозитарию); 
		git.ПерейтиНаВетку(ПутьКРепозитарию, ИмяВетки);
		
		Журнал.Информация("Начало обновления файла дампа конфигурации");
		ПроцессКонфигуратора = Создатьпроцесс("""" + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /S """ + ИмяСервера + "\" + ИмяБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /DumpCfg " + ОбъединитьПути(ПутьКПоставке, ИмяБазы + ".cf") + " /out " + ЖурналОбновленияДампа
												,ПутьКРепозитарию
												,Истина
												,Ложь
												,КодировкаТекста.UTF8);
		ПроцессКонфигуратора.Запустить();										
		ПроцессКонфигуратора.ОжидатьЗавершения();

		РезультатОбновленияДампа = ПроцессКонфигуратора.КодВозврата = 0;			
		
		Журнал.Информация("Обновление дампа конфигурации завершено " + ?(РезультатОбновленияДампа, "успешно!", "не удачно!"));
	
	КонецЕсли;
	
КонецЕсли;

ФайлЖурнала.Закрыть();

ЗавершитьРаботу(КодВозврата);