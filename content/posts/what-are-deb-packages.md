---
title: "Что такое .deb пакеты и с чем их едят"
date: 2023-04-16T16:48:20+03:00
tags: ["IT", "Linux", "Apt", "Debian", "Git"]
categories: ["IT", "Linux", "Git"]
---

Все нетруъ пользователи Linux (а иногда и труъ) встречались с Deb пакетами. Но не все когда-либо паковали что-либо. А как известно, ``в жизни надо попробовать всё``. Поэтому, я постараюсь описать в этой статье ``как запаковать свой .deb пакет и не умереть``.

``прим.: статья не претендует на полноценный мануал. Это просто укуренный опыт автора, которым он решил спасти всех, у кого тоже горит от Debian-way``

## .deb в разрезе

Конечно, в мире Linux'а все любят ~~пингвинов~~ стандарты и удобный менеджмент установок. А так как дистров народился целый зоопарк, то пришлось выдумывать эдакий способ всё это объединить. Потому, в бог знает каком году был выдуман и запилен божественный стандарт .deb, название которого буквально кричало о богатой фантазии.

В итоге, на данный момент мы получаем примерно такую картину:
```

.deb пакеты  --->  native (только Debian)
\--------------->  non-native
\--------------->  source (исходники)
\--------------->  binary (готовые бинарки)

```

И over 9k утилит для ведения и сборки этих самых пакетов.

## Исходный код

``Debian — дистр, в котором внутренних политик больше, чем частиц в обозримой вселенной``, именно поэтому, инициализация это чуть первее, чем последний шаг в создании своего пакета. От части, это всё потому, что ъ-дебиановцы уверовали в другую последовательность, а именно ``построй дом, заложи фундамент``: подразумевается, что при любых обстоятельствах контрольные файлы, git и прочее должны быть созданы только после полной готовности первой версии исходного кода. Поэтому, напишем свой hello-world для начала.

Первым делом пишется конечно же Makefile!
```Makefile
# Makefile
SOURCES := supercalifragilisticexpialidocious.c
TARGET := supercalifragilisticexpialidocious

all:
    $(CC) $(CFLAGS) -c $(SOURCES) -o $(TARGET)
```

И сам наш код
```c
// supercalifragilisticexpialidocious.c
#include <stdio.h>

int main(void)
{
    // print my shiny hello world!
    printf("Hello world!\n");
    return 0;
}
```

## Наконец, debian..!

Теперь мы можем приступить и к контрольным файлам и к git'у. Именно к ним вместе. Ведь в Debian не обошлись без своего ``очень нужного всем и вся`` стандарта для ведения git'а с пакетами. А именно, весь стандарт по большей части заключается в изменении названия ``master`` (``прим.: ну или main...``) на ``upstream``. По этой причине, существует целая утилита для ``правильного`` ведения репозитория: ``git-buildpackage`` или в народе ``gbp``.

Немножко настроим ``dh_make``, чтобы он правильно указывал наше авторство:
```sh
export DEBEMAIL="johndoe@gmail.com" # <--- ваш email
export DEBFULLNAME="John Doe"       # <--- ваше имя
```

Создадим сам шаблон с контрольными файлами и TXZ архив с исходниками.
``dh_make --createorig -p supercalifragilistic_0.1 -clgpl3 -s``

На выхлопе получим папку ``debian`` с горсткой файлов и ``../supercalifragilistic_0.1.orig.tar.xz``. Теперь мы можем смело импортировать наш TXZ в ``gbp``.
```sh
git init # <--- инициализируем репозиторий

# импортируем TXZ в git. Fakeroot ставит файлам root:root
echo "supercalifragilistic" | fakeroot gbp import-orig ../supercalifragilistic_0.1.orig.tar.xz
```

И от руки редачим все нужные нам файлы в ``debian`` директории, ``*.ex`` удаляем
```sh
cd debian
rm *.ex
rm README.*
echo "" > supercalifragilistic-docs.docs
vim control
```

## Билдим пакет

Чтобы сбилдить пакет мы воспользуемся sbuild'ом. Следующая часть нужна, если вы используете его впервые: вам придётся создать для него chroot

```sh
# установим sbuild и setup-скрипт
sudo apt install sbuild sbuild-debian-developer-setup
sudo sbuild-debian-developer-setup
# ожидаем создания chroot'а...
```

Теперь у нас есть chroot для sbuild'а, мы можем сбилдить пакет:

```sh
# вызываем sbuild с git'ом
sudo gbp buildpackage --git-builder=sbuild
# почувствуйте себя хакером из фильмов...
```

И вуа-ля, мы можем увидеть в ``../`` наш ``.deb`` файл!

## Заключение

Debian'у стоит лучше и проще документировать некоторые вещи. Но, как мы видим, сборка пакетов с нуля - вполне возможна и не так ужасна, как казалось!