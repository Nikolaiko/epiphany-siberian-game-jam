# Стайл-тест — 31 октября 2026

## Фон кофейни вечером

- Итоговый ассет: `bg_cafe_evening.png`, 640×360, Indexed PNG, палитра Resurrect 64 (Kerrie Lake) из `assets/palette/resurrect-64.gpl`.
- Редактируемый файл: `bg_cafe_evening.aseprite`.
- Генерация: встроенный инструмент OpenAI image_gen, 2026-10-31.
- Полный запрос: `bg_cafe_evening_prompt.txt`.
- Исходный результат генерации: `bg_cafe_evening_source.png`.
- Обработка: Aseprite, уменьшение до 640×360 методом nearest-neighbor, перевод в Indexed с палитрой проекта без дизеринга. Скрипт: `bg_cafe_evening_process.lua`.
- Ручная ретушь не выполнялась.

## Миф в голове студента

- Итоговый ассет: `bg_student_myth.png`, 640×360, Indexed PNG, палитра Resurrect 64 (Kerrie Lake) из `assets/palette/resurrect-64.gpl`.
- Редактируемый файл: `bg_student_myth.aseprite`.
- Генерация: встроенный инструмент OpenAI image_gen, 2026-10-31.
- Полный запрос: `bg_student_myth_prompt.txt`.
- Исходный результат генерации без изменений: `bg_student_myth_source.png`.
- Обработка: Aseprite, уменьшение до 640×360 методом nearest-neighbor, перевод в Indexed с палитрой проекта без дизеринга. Скрипт: `bg_student_myth_process.lua`.
- Ручная ретушь не выполнялась.
- Сцена намеренно изображает киношный миф: сплошные латы, рогатые шлемы с плюмажами и массовое проваливание под лёд. Историческая достоверность не предполагается; конкретные кадры фильмов и изображения из хроник не использовались как входные референсы.

## Портреты студента — спокойный и удивлённый

- Итоговые ассеты: `portrait_student_calm.png`, `portrait_student_surprised.png`, каждый 64×64, Indexed PNG, прозрачный фон без полупрозрачных пикселей.
- Палитра: Resurrect 64 (Kerrie Lake) из `assets/palette/resurrect-64.gpl`; отдельный прозрачный индекс сохраняет доступность всех 64 цветов.
- Генерация: встроенный инструмент OpenAI image_gen, 2026-10-31.
- Спокойный портрет создан по образу студента из `bg_cafe_evening_source.png`; удивлённый — правкой спокойного портрета с сохранением внешности, ракурса и одежды.
- Полные запросы: `portrait_student_calm_prompt.txt`, `portrait_student_surprised_prompt.txt`.
- Исходники без изменений: `portrait_student_calm_source.png`, `portrait_student_surprised_source.png`.
- Редактируемые файлы: `portrait_student_calm.aseprite`, `portrait_student_surprised.aseprite`.
- Обработка: Aseprite, уменьшение nearest-neighbor до 64×64, порог прозрачности 128, точный выбор ближайшего цвета Resurrect 64 по расстоянию RGB без дизеринга. Скрипт: `portrait_student_process.lua`. Ручная ретушь не выполнялась.
- Превью с целым увеличением ×4: `portrait_student_calm_preview_4x.png`, `portrait_student_surprised_preview_4x.png`.

## Городские тайлы

- Генерация: встроенный инструмент OpenAI image_gen, 2026-10-31, три независимых листа: покрытия, здания, декор.
- Финальные листы: `tiles_city_terrain.png`, `tiles_city_buildings.png`, `tiles_city_props.png`, по 64×64; общий атлас `tiles_city_atlas.png`, 192×64. Базовая клетка 16×16, 35 элементов с учётом крупных объектов.
- Палитра: тематические подмножества Resurrect 64 (Kerrie Lake), точные цвета из `assets/palette/resurrect-64.gpl`.
- Полные запросы: `tiles_city_terrain_prompt.txt`, `tiles_city_buildings_prompt.txt`, `tiles_city_props_prompt.txt`.
- Оригиналы: `tiles_city_terrain_source.png`, `tiles_city_buildings_source.png`, `tiles_city_props_source.png`, без изменений.
- Обработка: Aseprite, nearest-neighbor, удаление разделителей покрытий, упаковка декора в клетки, точное сопоставление цветов без дизеринга, порог прозрачности 128. Скрипт `tiles_city_process.lua`; ручная художественная ретушь не выполнялась.
- Пример улицы `tiles_city_street_preview.png` собран из итоговых тайлов. Ресурс Godot `tiles_city.tres` содержит нарезку атласа без коллизий и автотайлинга.
- Описание и схема набора: `tiles_city_README.md`, `tiles_city_manifest.json`.

## Город v2 — дневной

- Встроенный OpenAI image_gen, 2026-10-31. Восемь генераций по прямым референсам `bg_cafe_evening_source.png` и `char_student_atlas.png`: шесть цельных зданий, покрытия и декор.
- Время суток — день, мягкий осенний свет. От кофейни взяты материалы, характер рисунка и палитра; вечернее освещение не переносилось.
- Все оригиналы, финальные PNG, файлы Aseprite, запросы и обработка находятся в `city-v2/`. Полный перечень и ссылки на запросы — `city-v2/README.md`.
- Обработка: точные тематические подмножества Resurrect 64 (Kerrie Lake), бинарная прозрачность, без дизеринга. Архитектура и декор уменьшены выбором наиболее частого цвета палитры в исходной области; покрытия — nearest-neighbor. Базовые покрытия дополнительно ограничены по цветам для устранения повторяющегося шума.
- Здания нарезаны на клетки 16×16, новое оформление подключено к существующей карте с сохранением её геометрии и препятствий. Скриншоты из Godot: `city-v2/playable_preview.png`, `city-v2/overview.png`, `city-v2/cafe_preview.png`.

## Игровой спрайт студента — PixelLab

- Источник: пользовательский экспорт PixelLab `Full-body_pixel_art_char-Idle (1)/`, 2026-10-31. Запрос и сведения о генерации сохранены в его `metadata.json`.
- Итог: `char_student_atlas.png`, 256×96, кадры 32×32; редактируемый файл `char_student_atlas.aseprite`; превью `char_student_atlas_preview_4x.png`.
- Первая строка: восемь поз покоя в порядке south, south-east, east, north-east, north, north-west, west, south-west. Вторая и третья строки: по шесть кадров ходьбы south и north, 8 кадров/с.
- Обработка: Aseprite, скрипт `char_student_process.lua`. У кадров ходьбы 48×48 удалены прозрачные поля по 8 px с каждой стороны; рисунок не масштабировался. Скрипт проверяет, что видимые пиксели не обрезаны. Все кадры сведены к ближайшему цвету Resurrect 64 без дизеринга, прозрачность бинарная.
- В `scenes/walkable_city/player.tscn` подключены четыре основные позы покоя и две анимации ходьбы. В исходном экспорте нет боковой ходьбы: при движении влево/вправо пока используется соответствующая поза покоя, без отражения рюкзака. Диагональные позы сохранены в атласе для дальнейшей работы.
- Исходные PNG сохранены без изменений; ручная ретушь не выполнялась.
