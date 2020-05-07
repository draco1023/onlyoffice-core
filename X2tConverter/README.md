# x2t converter quick start

Для сборки onlyoffice конвертера (onlyoffice-worker) с различными версиями SDKJS нужно выполнить следующие шаги:

```bash
git clone --depth 1 -b as_master https://github.com/airslateinc/onlyoffice-core.git
```

Создать свою ветку от `as_master` и изменить название ветки SDKJS с которой необходимо собрать конвертер.

```bash
cd ./onlyoffice-core
git checkout -b converter/sdkjs-v1
```

Установить название ветки SDKJS в файл `./X2tConverter/SDKJS_VERSION`

```bash
cd ./onlyoffice-core
echo converter-v5.5.1.76 > ./X2tConverter/SDKJS_VERSION
```

Создать коммит с измененным файлом и `git push`
Результат сборки можно забрать из артефактов билда [github actions](https://github.com/airslateinc/onlyoffice-core/actions?query=workflow%3AX2T)
