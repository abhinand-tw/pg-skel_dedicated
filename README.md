pg-skel
=======

Создание postgresql template database.

Описание
--------

Решение применяется в случаях, когда проекту необходима БД, в которой некоторые операции выполнены под ролью суперпользователя, т.е. роли владельца БД тут недостаточно.

Примеры таких операций:

* CREATE EXTENSION
* копирование файлов в /usr/share/postgresql/tsearch_data

Для того, чтобы убрать потребность в суперпользователе при каждом деплое, принимается следующий алгоритм работы

1. В кластере создается шаблонная БД (template database)
2. Пользовательские БД создаются из этого шаблона

Текущий проект предназначен для выполнения шага 1.

Зависимости
-----------

* Linux 64bit (git, make, wget)
* Postgres (по умолчанию переменные настроены для варианта установки как системного сервиса)

Быстрый старт
-------------

На локальной системе должен быть развернут Postgres, добавлена русская локаль.
```
git clone https://github.com/TenderPro/pg-skel.git
cd pg-skel_dedicated
make start
```

License
-------

This project is under the MIT License. See the [LICENSE](LICENSE) file for the full license text.

Copyright (c) 2016 [Tender.Pro](http://www.tender.pro)
