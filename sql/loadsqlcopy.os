#Использовать InternetMail

Процедура Оповестить(ТипОповещения = "Окончание", НазваниеБазы)

	СтруктураАдресов = Новый Структура;
	СтруктураАдресов.Вставить("ERP_MAV", Новый Структура("Email, Telegram","aleksey.marochkin@rtits.ru","-1001094974811"));
	СтруктураАдресов.Вставить("ECM_MAV", Новый Структура("Email, Telegram","aleksey.marochkin@rtits.ru","-1001094974811"));
	
	СтруктураАдресов.Вставить("ERP_MMY", Новый Структура("Email, Telegram","Mikhail.Madekin@rtits.ru",""));
	СтруктураАдресов.Вставить("ECM_MMY", Новый Структура("Email, Telegram","Mikhail.Madekin@rtits.ru",""));
	
	СтруктураАдресов.Вставить("ERP_BAS", Новый Структура("Email, Telegram","Aleksandr.Bogatov@rtits.ru","-1001124057695"));
	СтруктураАдресов.Вставить("ERP_BAS2", Новый Структура("Email, Telegram","Aleksandr.Bogatov@rtits.ru","-1001124057695"));
	
	СтруктураАдресов.Вставить("ERP_DAI", Новый Структура("Email, Telegram","Andrey.Dobrynin@rtits.ru",""));
	СтруктураАдресов.Вставить("ECM_DAI", Новый Структура("Email, Telegram","Andrey.Dobrynin@rtits.ru",""));
	
	СтруктураАдресов.Вставить("ERP_SOV", Новый Структура("Email, Telegram","Olga.Stogova@rtits.ru",""));

	СтруктураАдресов.Вставить("ERP_KAN", Новый Структура("Email, Telegram","Aleksey.Klimashenko@rtits.ru","-1001139532612"));
	СтруктураАдресов.Вставить("ECM_KAN", Новый Структура("Email, Telegram","Aleksey.Klimashenko@rtits.ru","-1001139532612"));
	
	СтруктураАдресов.Вставить("ERP_KSP", Новый Структура("Email, Telegram","Sergey.Kiselev@rtits.ru",""));
	СтруктураАдресов.Вставить("ERP_MSS", Новый Структура("Email, Telegram","Sergey.Menzhesarov@rtits.ru","-1001107290583"));
	
	СтруктураАдресов.Вставить("ERP_KDS", Новый Структура("Email, Telegram","Dmitriy.Klimashin@rtits.ru","-1001075061753"));
	СтруктураАдресов.Вставить("ECM_KDS", Новый Структура("Email, Telegram","Dmitriy.Klimashin@rtits.ru","-1001075061753"));
	
	СтруктураАдресов.Вставить("ERP_MVV", Новый Структура("Email, Telegram","Viktoriya.Malysheva@rtits.ru","-1001147344720"));

	//СтруктураАдресов.Вставить("ERP_TEST1", Новый Структура("Email, Telegram","Olga.Stogova@rtits.ru",""));
	СтруктураАдресов.Вставить("ERP_TEST1", Новый Структура("Email, Telegram","aleksey.marochkin@rtits.ru","-1001094974811"));
	СтруктураАдресов.Вставить("ERP_TEST2", Новый Структура("Email, Telegram","aleksey.marochkin@rtits.ru","-1001094974811"));
	СтруктураАдресов.Вставить("ERP_TEST3", Новый Структура("Email, Telegram","aleksey.marochkin@rtits.ru","-1001094974811"));
	//СтруктураАдресов.Вставить("ERP_TEST1", Новый Структура("Email, Telegram","Sergey.Kiselev@rtits.ru",""));
	
	ТекстСообщения = "";
	
	Если ТипОповещения = "Окончание" Тогда
	
		ТекстСообщения = "Загрузка последней копии базы " + НазваниеБазы + " завершена!"
	
	Иначе
	
		ТекстСообщения = "Началась загрузка последней копии базы " + НазваниеБазы + "!" + Символы.ПС +  "О завершении будет сообщено дополнительно."
	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураАдресов[НазваниеБазы].Email) Тогда
		
		ОтправитьПочтовоеСообщение(СтруктураАдресов[НазваниеБазы].Email, ТекстСообщения);
	
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СтруктураАдресов[НазваниеБазы].Telegram) Тогда
		
		Зап = Новый HTTPЗапрос("/bot373923831:AAGqI4Fu4UogxTVaxaq7rb_dNE4BWorbjZs/sendMessage?chat_id=" + СтруктураАдресов[НазваниеБазы].Telegram + "&text=" + ТекстСообщения);
		
		Соед = Новый HTTPСоединение("api.telegram.org");
		Соед.Получить(Зап);
		
	КонецЕсли;	

КонецПроцедуры

Процедура ОтправитьПочтовоеСообщение(Адрес, ТекстСообщения)

	Профиль = Новый ИнтернетПочтовыйПрофиль;
	Профиль.АдресСервераSMTP = "mx.rtits.ru";
	
	Профиль.ПортSMTP = 587;
	
	Профиль.ПользовательSMTP = "Tasks-1C@rtits.ru";
	Профиль.ПарольSMTP = "k0D7vSTC";
	
	Почта = Новый ИнтернетПочта;
	Почта.Подключиться(Профиль);

	Сообщение = Новый ИнтернетПочтовоеСообщение;
	Сообщение.Отправитель = "Tasks-1C@rtits.ru";
	Сообщение.Тема = "Уведомление о загрузке SQL копии базы";
	Текст = Сообщение.Тексты.Добавить(ТекстСообщения);
	Текст.ТипТекста = ТипТекстаПочтовогоСообщения.ПростойТекст; 
	Адрес = Сообщение.Получатели.Добавить(Адрес);
	
	Почта.Послать(Сообщение, ,ПротоколИнтернетПочты.SMTP);
	
КонецПроцедуры


ИмяРодительскогоПлана = АргументыКоманднойСтроки[0];
РабочийКаталог = АргументыКоманднойСтроки[1];

//ERP-MAV-2

МассивСтрок = СтрРазделить(ИмяРодительскогоПлана, "-");
МассивСтрок.Удалить(МассивСтрок.Количество() - 1);
БазаИсточник = МассивСтрок[0] + "_Production";
НазваниеБазы = СтрСоединить(МассивСтрок,"_");

Оповестить("Начало", НазваниеБазы);

ПроцессSqlCMD = СоздатьПроцесс("""C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\SQLCMD.EXE"" -S RTITS-1C-04 -v sourcedb=""" + БазаИсточник + """ db=""" + НазваниеБазы + """ bakfile=""D:\DBBACKUP\" + БазаИсточник + "_Copy.bak"" -i D:\Users\MAV\GIT\devops\sql\LoadBackupFileToDB.sql -o " + РабочийКаталог + "\Logs\sql.log"
							,РабочийКаталог
							,Истина
							,Ложь
							,КодировкаТекста.ANSI);
ПроцессSqlCMD.Запустить();										
ПроцессSqlCMD.ОжидатьЗавершения();

Вывод  = СокрЛП(ПроцессSqlCMD.ПотокВывода.Прочитать());

Сообщить(Вывод);

Оповестить("Окончание", НазваниеБазы);

