$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$failed = 0
function Assert-True($cond, $msg) {
  if (-not $cond) { Write-Host "FAIL: $msg" -ForegroundColor Red; $script:failed++ }
  else { Write-Host "OK: $msg" -ForegroundColor Green }
}
$om = Get-ChildItem -Path $root -Recurse -Filter "ObjectModule.bsl" | Where-Object { $_.FullName -match "Ext" } | Select-Object -First 1 -ExpandProperty FullName
$form = Get-ChildItem -Path $root -Recurse -Filter "Module.bsl" | Where-Object { $_.FullName -match "Form" } | Select-Object -First 1 -ExpandProperty FullName
Assert-True ([bool]$om) "ObjectModule.bsl exists"
Assert-True ([bool]$form) "Form Module.bsl exists"
$omText = [System.IO.File]::ReadAllText($om)
$formText = [System.IO.File]::ReadAllText($form)
$needOm = @(
  [string][char]0x0412 + "ерсияСхемыПартии",
  "МигрироватьСостояниеПартии",
  "НовыйИдентификаторИгрока",
  "ХешПароляКомнаты",
  "ДобавитьЗаписьЖурналаПартии",
  "ДобавитьСообщениеЧатаПартии",
  "ОтметитьСтартХодаПартии",
  "ОбновитьИндексКомнатJSON",
  "ХодШапкиЛегален",
  "ХодШахматЛегален",
  "ТекстСетевойОшибки",
  "идИгроков",
  "парольХеш",
  "ходНачатМс"
)
# Use UTF8 bytes for Cyrillic markers via here-string file instead:
$markersOm = @(
  "ВерсияСхемыПартии","МигрироватьСостояниеПартии","НовыйИдентификаторИгрока","ХешПароляКомнаты",
  "ДобавитьЗаписьЖурналаПартии","ДобавитьСообщениеЧатаПартии","ОтметитьСтартХодаПартии",
  "ОбновитьИндексКомнатJSON","ХодШапкиЛегален","ХодШахматЛегален","ТекстСетевойОшибки",
  "идИгроков","парольХеш","ходНачатМс"
)
foreach ($s in $markersOm) { Assert-True ($omText.Contains($s)) ("ObjectModule has $s") }
$markersForm = @(
  "ЗахватитьЗамокФайла","ЗаписатьСостояниеВФайл","ПопыткаПереподключения","ОтправитьЧат",
  "ОбновитьСписокКомнат","ОчиститьСтарыеПартии","ПоказатьСетевуюОшибку","ОжидаемаяВерсия"
)
foreach ($s in $markersForm) { Assert-True ($formText.Contains($s)) ("Form Module has $s") }
$fx1 = Join-Path $PSScriptRoot "fixtures\party_v1_legacy.json"
$fx2 = Join-Path $PSScriptRoot "fixtures\party_v2_full.json"
$t1 = [System.IO.File]::ReadAllText($fx1)
$t2 = [System.IO.File]::ReadAllText($fx2)
Assert-True ($t1.Contains('"схема": 1') -or $t1.Contains('"схема":1')) "fixture v1 schema"
Assert-True (-not $t1.Contains('"идИгроков"')) "fixture v1 no player ids"
Assert-True ($t2.Contains('"схема": 2') -or $t2.Contains('"схема":2')) "fixture v2 schema"
Assert-True ($t2.Contains('"идИгроков"')) "fixture v2 player ids"
Assert-True ($t2.Contains('"журнал"')) "fixture v2 journal"
Assert-True ($t2.Contains('"чат"')) "fixture v2 chat"
Assert-True ($t2.Contains('"парольХеш"')) "fixture v2 password"
Assert-True (Test-Path (Join-Path $root "docs\ARCHITECTURE.md")) "ARCHITECTURE.md"
Assert-True (Test-Path (Join-Path $root "docs\RULES_CHECKLIST.md")) "RULES_CHECKLIST.md"
Assert-True (Test-Path (Join-Path $root "README.md")) "README.md"
if ($failed -gt 0) { Write-Host "FAILED: $failed"; exit 1 }
Write-Host "All checks passed"; exit 0