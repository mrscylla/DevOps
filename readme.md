# Небольшой сборник наработок, возникших при работе 1С разработчиков с Git и не только

[Change Loader](/ChangeLoader/readme.md) - модуль oscript, созданный, для загрузки Diff из ветки Git, а в дальнейшем его функционал расширен и  до работы с внешними обработками (справочник дополнительные обработки и отчеты).

[Deploy](deploy/readme.md) - старые (исторические) наработки которые жалко выкинуть

[Git](git/readme.md) - полезные "штуки" для Git

[pscripts](pscripts/readme.md) - полезные powershell скрипты

[SQL](/sql/) - скрипты используемые для ежедневного создания копий БД. Сложилась в компании такая практика иметь, так называемые базы-копии ProductionCopy которые разворачиваются ежедневно из утреннего SQL бэкапа. Эти копии очищаются от записей в "мусорных таблицах" и сжимаются средствами MS-SQL (База 350Гб ужимается в 120Гб). После сжатия делаются файлы бэкапов, которые по кнопке в CI/CD (пока используется Atlassian Bamboo) могут быть развернуты в тестовую базу аналитика или разработчика. Без привлечения ИТ администраторов.

