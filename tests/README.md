# Автопроверки без платформы 1С

Полный прогон правил игр требует 1С. Здесь — smoke-тесты схемы JSON, миграции полей и наличия ключевых символов в исходниках.

Запуск:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\run_checks.ps1
```

Фикстуры: `tests/fixtures/`.
