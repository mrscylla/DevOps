#Использовать v8runner
#Использовать logos

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

    Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

ПодключитьСценарий("lib\git.os", "git");
git = Новый git();

ПутьКРепозитарию = АргументыКоманднойСтроки[0];
ИмяВетки = АргументыКоманднойСтроки[1];
ИмяБазы = АргументыКоманднойСтроки[2];
Пользователь = АргументыКоманднойСтроки[3];
Пароль = АргументыКоманднойСтроки[4];
НеПолучатьИзменения = Ложь;
//НеПолучатьИзменения = АргументыКоманднойСтроки[5];
//Если НеПолучатьИзменения = неопределено Тогда НеПолучатьИзменения = ложь; Иначе НеПолучатьИзменения = Истина; КонецЕсли;

ИмяФайлаЖурнала = ОбъединитьПути(ТекущийКаталог(), "Logs", ИмяБазы, ИмяВетки + ".log");
Файл = Новый Файл(ИмяФайлаЖурнала);
СоздатьКаталог(Файл.Путь);
КаталогЖурналов = Файл.Путь;

Журнал = Логирование.ПолучитьЛог("load_changes.app.loading");
Журнал.УстановитьУровень(УровниЛога.Информация);
Журнал.УстановитьРаскладку(ЭтотОбъект);

КонсольЖурн = Новый ВыводЛогаВКонсоль;
ФайлЖурнала = Новый ВыводЛогаВФайл;
ФайлЖурнала.ОткрытьФайл(ИмяФайлаЖурнала);

Журнал.ДобавитьСпособВывода(ФайлЖурнала);
Журнал.ДобавитьСпособВывода(КонсольЖурн);

ИмяФайлаСпискаФайлов = ОбъединитьПути(ТекущийКаталог(), ИмяБазы, ИмяВетки + "_lastfiles.txt");
Файл = Новый Файл(ИмяФайлаСпискаФайлов);
СоздатьКаталог(Файл.Путь);

УправлениеКонфигуратором = Новый УправлениеКонфигуратором();
ПутьКПлатформе1С = УправлениеКонфигуратором.ПолучитьПутьКВерсииПлатформы("8.3.10");

Журнал.Информация("формирую список последних файлов в " + ИмяФайлаСпискаФайлов);

// Переключить ветку GIT на "ИмяВетки"
Журнал.Информация("переход на ветку  " + ИмяВетки + " в репозитории " + ПутьКРепозитарию); 
git.ПерейтиНаВетку(ПутьКРепозитарию, ИмяВетки);


Если НЕ НеПолучатьИзменения Тогда

	// Получить список измененных файлов текущей ветки GIT
	Журнал.Информация("получение списка из " + ПутьКРепозитарию);
	git.ПолучитьСписокИзмененийВФайл(ПутьКРепозитарию, ИмяФайлаСпискаФайлов, Журнал);
	КолВоИзменений = git.ОбработатьФайлИзменений(ПутьКРепозитарию, ИмяФайлаСпискаФайлов, Журнал);

Иначе

	КолВоИзменений = 1;
	Журнал.Информация("использую существующий список файлов " + ИмяФайлаСпискаФайлов);

КонецЕсли;

ЧастичнаяЗагрузка = Истина;

Если КолВоИзменений <> 0 Тогда

	Если КолВоИзменений < 0 Тогда
	
		ЧастичнаяЗагрузка = Ложь;
	
	КонецЕсли;

	ЖурналЗагрузкиИзменений = ОбъединитьПути(КаталогЖурналов, "LoadChanges_" + ИмяБазы + ".log");
	ЖурналВыгрузкиФайлапоставки = ОбъединитьПути(КаталогЖурналов, "Deploy_" + ИмяБазы + ".log");
	ЖурналСинтаксическогоКонтроля = ОбъединитьПути(КаталогЖурналов, "CheckModules_" + ИмяБазы + ".log");
	
	Журнал.Информация("Начало " + ?(ЧастичнаяЗагрузка, "частичной", "полной") + " загрузки конфигурации из файлов.");
	Журнал.Информация("Запуск: """ + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /IBName """ + ИмяБазы + """ /N """ + Пользователь + """ /P ""******"" /LoadConfigFromFiles " + ПутьКРепозитарию + "\Config " + ?(ЧастичнаяЗагрузка, "-ListFile " + ИмяФайлаСпискаФайлов, "") + " /UpdateDBCfg /out " + ОбъединитьПути(КаталогЖурналов, "loadchanges_" + ИмяБазы + ".log"));
	ПроцессКонфигуратора = Создатьпроцесс("""" + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /IBName """ + ИмяБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /LoadConfigFromFiles " + ПутьКРепозитарию + "\Config " + ?(ЧастичнаяЗагрузка, "-ListFile " + ИмяФайлаСпискаФайлов, "") + " /UpdateDBCfg /out " + ЖурналЗагрузкиИзменений
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
	
	Если ИзмененияЗагруженыУспешно Тогда
	
		Журнал.Информация("Проведение синтаксического контроля модулей"); // /CheckModules [-ThinClient] [-WebClient] [-Server] [-ExternalConnection] [-ThickClientOrdinaryApplication] [-MobileAppClient] [-MobileAppServer] [-ExtendedModulesCheck][-
		ПроцессКонфигуратора = Создатьпроцесс("""" + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /IBName """ + ИмяБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /CheckModules -ThinClient -WebClient -Server -ExternalConnection /out " + ЖурналСинтаксическогоКонтроля
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
		
		Если СинтаксическийКонтрольУспешен Тогда

			Журнал.Информация("Начало подготовки файла выгрузки конфигурации");
			ПроцессКонфигуратора = Создатьпроцесс("""" + ПутьКПлатформе1С + """ DESIGNER /UC 456654 /IBName """ + ИмяБазы + """ /N """ + Пользователь +""" /P """ + Пароль + """ /DumpCfg " + ПутьКРепозитарию + "\Deploy\" + ИмяБазы + ".cf /out " + ЖурналВыгрузкиФайлапоставки
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
			
				ЗТ = Новый ЗаписьТекста(ОбъединитьПути(ПутьКРепозитарию, "Deploy\needupdate.flg"));
				ЗТ.ЗаписатьСтроку("Deploy\" + ИмяБазы + ".cf");
				ЗТ.Закрыть();
				Журнал.Информация("Создан семафор необходимости обновления рабочей базы.");
			
			КонецЕсли;
			
		КонецЕсли;	
	
	Иначе	
	
		Журнал.Ошибка("загрузка изменений в базу """ + ИмяБазы + """ не удалась, см. " + ЖурналЗагрузкиИзменений);
	
	КонецЕсли;
	
Иначе

	Журнал.Информация("Изменений в репозитории """ + ПутьКРепозитарию + """ нет.");

КонецЕсли;

// Загрузить изменения



ФайлЖурнала.Закрыть();