---
title: "Как сделать автоматические уведомления в Telegram канал"
date: 2023-04-16T13:16:33+03:00
tags: ["IT", "Блог", "Telegram"]
categories: ["IT", "Блог"]
---

Так как этот блог хостится на github, здесь доступны ``shiny brand new workflow™``. Поэтому, опишу как разбирать commit сообщения и автоматически отправлять уведомления о постах в Telegram канал.

## Канал в Telegram

Сначала создайте канал в Telegram. В нём собственно и будут все ваши уведомления. Теперь вы можете сразу получить его ID, но мне удобнее будет сделать это через curl и бота.

``прим.: нужен именно числовой ID, иначе бот не сможет отправить первое сообщение``

## Бот в Telegram

Теперь надо создать бота в Telegram. Это можно сделать через [Bot Father](https://t.me/BotFather) в телеграмме. Там есть встроенные инструкции, поэтому сам процесс создания не описываю.

После создания скопируйте токен для http api, с ним мы будем отправлять сообщения. Добавьте своего бота в нужный канал в качестве админа. Чтобы получить ID чата, я отправлю в него первое сообщение и выполню

```
curl https://api.telegram.org/bot<token>/getUpdates
```

и скопирую ID из поля ``chat_id`` в полученном JSON.

## Github Secrets

Github позволяет создавать ``секреты``, которые будут доступны только как переменные в Workflow. В них мы и будем хранить ``токены`` и ``chat_id``. Для того, чтобы их создать, перейдите в ``Settings/Secrets and variables/Actions`` и нажмите там кнопку ``New repository secret``. Потом укажите для секрета название ``TELEGRAM_CHANNEL`` и в поле значения запишите ID своего канала.

Повторите ту же процедуру для секрета с названием ``TELEGRAM_TOKEN`` и запишите в значение свой токен.

## Github Workflow

Теперь напишем свой workflow файл. Для этого я предлагаю использовать кастомный bash скрипт + appleboy/telegram-action. Вот мой вариант скрипта, он работает для формата ``*post: slug-field; My title is a sentence``:

```bash
#!/bin/bash
# scripts/trim-commit-msg.sh
# Trim commit message and get new post meta

# get commit message from argv
commit_msg=$1
meta=$(echo ${commit_msg} | sed 's/post: /post:/g' | sed 's/; /;/g' | awk -F'post:' '{print $2}')
echo ${meta}

# split meta by ; (bash-compatible ONLY!)
values=(${meta//;/ })

# put github output
echo "slug=${values[0]}" >> $GITHUB_OUTPUT
echo "title=${values[@]:1}" >> $GITHUB_OUTPUT
```

Скрипт получает как аргумент коммит сообщение и через ``sed и awk`` вырезает из него все лишние куски. Потом получившуюся строку вида ``slug;Title`` он разбивает на массив ``values``. В конце записываются 2 github output'а, о них вы можете прочесть в [документации самого Github](https://github.blog/changelog/2022-10-11-github-actions-deprecating-save-state-and-set-output-commands/).

Ну и сам workflow файл:

```yaml
# .github/workflows/telegram.yaml
# send telegram message
name: Telegram
on: [push, workflow_dispatch]

permissions:
  contents: read

jobs:
  message:
    if: "contains(${{ github.event.head_commit.message }}, 'post:')"
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Parse commit message
        id: msg_parse
        run: ./scripts/trim-commit-msg.sh "${{ github.event.head_commit.message }}"
      - name: Telegram
        uses: appleboy/telegram-action@master
        with:
          to: ${{ secrets.TELEGRAM_CHANNEL }}
          token: ${{ secrets.TELEGRAM_BOT_TOKEN }}
          format: markdown
          message: |
            [${{ steps.msg_parse.outputs.title }}](https://${{ github.repository_owner }}.github.io/${{ github.event.repository.name }}/${{ steps.msg_parse.outputs.slug }})

            Автор: ${{ github.event.head_commit.author.name }}
```

Он запускается либо ``вручную``, либо на ``push'е``, проверяет, что сообщение содержит ``post:`` и после этого получает и запускает sh скрипт. В конце, в Telegram отправляется markdown сообщение, которое собирается из переменных и результатов выполнения скрипта.

``прим.: коммит с постом обязательно должен быть последним в push'е!``

## Заключение

Проверить работу этого механизма вы можете в Телеграмм канале блога, ведь там как раз есть такой же бот.
