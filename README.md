# Salesforce + Mule Quality Workshop

外部サービス利用申請を題材にした、テスト観点作成とホワイトボックステストケース設計の研修アプリです。

参加者は共有Salesforce Developer Org上の画面を操作し、主催者PCで起動しているMule APIとDocker MySQLを共有利用します。

## 全体構成

```text
参加者PCのブラウザ
  -> 共有Developer Org
  -> LWC
  -> Apex
  -> Named Credential: MuleWorkshop
  -> Cloudflare Quick Tunnel
  -> 主催者PCのMule API
  -> 主催者PCのDocker MySQL
```

Salesforceには申請データを保存しません。登録データはMule経由でMySQLに保存します。

## 主な機能

- 最近の申請一覧表示
- 申請番号クリックによる詳細モーダル表示
- 新規申請登録
- 条件付き入力項目の表示と値クリア
- 処理中spinner
- Apex -> Mule -> MySQLの連携

更新・削除機能はありません。

## ドキュメント

| 用途 | ファイル |
| --- | --- |
| アーキテクチャ | `docs/architecture.md` |
| Muleセットアップ | `docs/setup-mule.md` |
| Salesforceセットアップ | `docs/setup-salesforce.md` |
| 当日運用手順 | `docs/workshop-runbook.md` |
| 参加者向け仕様書兼要件書 | `docs/participant/functional-spec.md` |
| 参加者向けホワイトボックス設計シート | `docs/participant/whitebox-test-case-sheet.md` |
| 主催者向け資料 | `docs/facilitator` |

参加者向け配布物には `docs/facilitator` と `facilitator-assets` を含めないでください。

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

発行されたQuick Tunnel URLをSalesforceのNamed Credential `MuleWorkshop` に設定します。

## Salesforceデプロイ

接続済みDeveloper Orgへデプロイする場合は、通常次を使います。

```powershell
cd SFWorkshop\SfWorkshop
sf project deploy start --source-dir force-app --target-org vscodeOrg
```

Named CredentialのQuick Tunnel URLはソースコードに保存しません。Salesforce Setupで手動設定します。

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

既存コンテナやボリュームは削除せず、研修用テーブルのデータを初期化します。

## 網羅率デモ

主催者専用のテスト資産は `facilitator-assets` にあります。

```powershell
.\scripts\run-facilitator-coverage-demo.ps1 -Mode baseline
.\scripts\run-facilitator-coverage-demo.ps1 -Mode full
```

網羅率は品質を直接保証するものではありません。入力値、条件分岐、エラー処理、DB登録値、通信経路、運用手順も品質観点として扱ってください。
