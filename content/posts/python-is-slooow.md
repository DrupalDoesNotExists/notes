---
title: "Python медленный..."
date: 2023-04-15T22:21:22+03:00
tags: ["IT", "Python", "Производительность"]
categories: ["IT", "Python"]
---

— основной довод всех C, C++, Java, да и просто труъ программистов, которым когда-то (а то есть всегда) приходилось отвечать на вопрос "почему вам не нравится Python?". Эта статья — универсальный ответ на все высказывания подобного вида.

## Python - интерпретируемый!

Многие называет Python медленным по причине его ``интерпретируемости``. Ага, вот где спрятался дъявол!

Неожиданно, но Python на самом деле ``работает по той же схеме, что и Java``! Вспомним, как происходит компиляция и исполнение Java программы:

```

# Компиляция
XYZ.java -> javac -> Токенизатор -> Парсер -> Bytecode (XYZ.class)

# Исполнение
XYZ.class -> java -> Интерпретатор -> Инструкция 1
                     \--------------> Инструкция 2
                     ...
                     \--------------> Инструкция 3405691582

```

А теперь посмотрим, как с этим справляется Python:

```

xyz.py -> python -> Токенизатор -> Парсер -> Bytecode (xyz.pyc)
                                                         | |
                                                    Интерпретатор...

```

Почти идентично. За исключением того, что Python по-умолчанию исполняет полученный bytecode сразу. Это можно отключить с использованием модуля compileall.

Тем, кто всё ещё не верит в Bytecode'овую змеиную сущность доступна [статья](https://docs.python.org/3/library/dis.html). Также, стоит заметить, что ``Python способен "компилироваться"`` не только в один формат, это зависит от имплементации: [Jython](https://www.jython.org/) компилируется в JVM bytecode, [IronPython](https://ironpython.net/) в .NET форматы, [PyPy](https://www.pypy.org/) вообще поддерживает [over 9k!](https://ru.wikipedia.org/wiki/It%E2%80%99s_Over_9000!) выхлопов.

## Мой X на Python медленнее, чем на Y

Очень часто, в аргумент к тому, что Python медленный приводят фразы вида:

> Мой адронный коллайдер на Python медленнее, чем на Go

Такое мнение часто далеко от истины и возникает по причине некорректного сравнения. Часто получается так, что сравнивающий не до конца знает Python со всеми его фишками и изяществами, из-за чего буквально дословно транслирует код на искомом языке на Python. Это, конечно же приводит к не самым быстрым и элегантным решениям, из-за чего и получается огромная разница в скорости выполнения.

## Cython, ctypes и прочие

К тому же, Python (а именно дефакто CPython) очень хорошо интегрируется c С/C++/Rust'ом и вообще всем, что компилируется в *.so формат. Примером тому служит стандартный модуль ctypes для низкоуровневой работы с shared библиотеками.

Также, нельзя не отметить модуль-расширение для Python'а под названием Cython. Он позволяет добавить в синтаксис Python вставки на C и удобно их использовать. При этом, ``вся трансляция C кода, компиляция shared библиотеки и генерация .pyi файлов безболезненно произойдёт за сценой``. Вам останется ``лишь подключить готовый файл через обычный import``.

Ну и в конце концов, многие крупные проекты, такие как tensorflow, numpy, scipy, pytorch, keras, pandas и другие написаны на C. И хотя они имеют совместимость с Java/Rust/Go благодаря биндингам, совместимость с Python намного стабильнее.

## Заключение

Конечно, Python не способен догонять в производительности C, но он всё ещё остаётся ``достаточно быстрым, сохраняя все свои фичи``. ``К тому же, каждый язык предназначен для своей сферы и хорош по своему``. Все споры о том, какой язык лучше, а какой хуже — это конечно ``обычные холивары``, ведь Python всё равно выигрывает :D.