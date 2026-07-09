# Salesforce + Mule Quality Workshop

外部サービス利用申請を題材にした研修用アプリです。

参加者は共有Salesforce Developer Org上の画面を操作し、主催者PCで起動している外部APIとデータベースを共有利用します。

## 構成概要

```text
参加者PCのブラウザ
  -> 共有Developer Org
  -> Cloudflare Quick Tunnel
  -> 主催者PCのMule API
  -> 主催者PCのDocker MySQL
```

Salesforceには申請データを保存しません。登録データは外部API経由で保存します。

## リポジトリ構成

| パス | 内容 |
| --- | --- |
| `MuleWorkshop/service-request-api` | Muleアプリ |
| `salesforce` | Salesforce DXソース |
| `mysql` | Docker MySQL構成 |
| `docs` | セットアップ・運用・参加者向け資料 |
| `scripts` | 補助スクリプト |

## ドキュメント

| 用途 | ファイル |
| --- | --- |
| 構成概要 | `docs/architecture.md` |
| Muleセットアップ | `docs/setup-mule.md` |
| Salesforceセットアップ | `docs/setup-salesforce.md` |
| 当日運用手順 | `docs/workshop-runbook.md` |
| 参加者向け要望書 | `docs/participant/functional-spec.md` |
| 参加者向け記入シート | `docs/participant/whitebox-test-case-sheet.md` |

## 前提ソフトウェア

- Java 17
- Maven 3.8系以上
- Salesforce CLI
- Node.js / npm
- Docker Desktop
- cloudflared
- Anypoint Studio

## 起動概要

詳細は `docs/workshop-runbook.md` を参照してください。

```powershell
docker compose -f mysql\docker-compose.yml up -d
```

Anypoint Studioで `MuleWorkshop/service-request-api` をRunします。

```powershell
cloudflared tunnel --url http://localhost:8081
```

発行されたQuick Tunnel URLをSalesforce側の接続設定へ反映します。

## Salesforceデプロイ

```powershell
cd salesforce
sf project deploy start --source-dir force-app --target-org <alias>
```

## Muleビルド確認

```powershell
cd MuleWorkshop\service-request-api
mvn clean package -nsu -DskipMunitTests
```

このプロジェクトでは `mvn mule:run` は使用しません。

## DBリセット

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\reset-shared-db.ps1
```

既存コンテナやボリュームは削除せず、研修用データを初期化します。
