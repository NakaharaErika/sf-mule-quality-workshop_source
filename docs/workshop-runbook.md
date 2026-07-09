# ワークショップ運用手順

この手順は主催者PCで実施します。参加者PCではSalesforceへログインして画面操作と資料閲覧を行います。

## 当日の起動順

1. Docker Desktopを起動する。
2. MySQLを起動する。
3. DB初期データを確認またはリセットする。
4. Anypoint StudioでMuleを起動する。
5. ローカルMule APIを確認する。
6. Cloudflare Quick Tunnelを起動する。
7. SalesforceのNamed Credential `MuleWorkshop` を更新する。
8. Salesforce画面で一覧表示と登録を確認する。
9. 参加者へSalesforceログイン情報と資料を案内する。

## MySQL起動

初回のみ:

```powershell
Copy-Item mysql\.env.example mysql\.env
notepad mysql\.env
```

起動:

```powershell
docker compose -f mysql\docker-compose.yml up -d
docker compose -f mysql\docker-compose.yml ps
```

MySQLは `127.0.0.1:3307` のみに公開します。Adminerは `http://127.0.0.1:8080` で確認できます。

## DBリセット

PowerShellの実行ポリシーで止まる場合があるため、次で実行します。

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\reset-shared-db.ps1
```

このスクリプトはコンテナやボリュームを削除せず、`service_request` のデータを初期化してseedを入れ直します。

日本語が文字化けする場合は、AdminerでDB内の値を確認し、上記リセットを再実行してください。

## Mule起動

Anypoint Studioで `MuleWorkshop/service-request-api` をRunします。

ビルド確認:

```powershell
cd MuleWorkshop\service-request-api
mvn clean package -nsu -DskipMunitTests
```

疎通確認:

```powershell
Invoke-RestMethod "http://127.0.0.1:8081/api/v1/requests?limit=10"
```

MuleをStopすると、Cloudflare Quick Tunnelが起動していてもSalesforceからの呼び出しは成功しません。

## Cloudflare Quick Tunnel

Mule起動後に、別PowerShellで実行します。

```powershell
cloudflared tunnel --url http://localhost:8081
```

表示されたURLを控えます。

```text
https://xxxxx.trycloudflare.com
```

このPowerShellは閉じないでください。閉じるとQuick Tunnelも停止します。

## Named Credential更新

Salesforce SetupでNamed Credential `MuleWorkshop` を開き、URLをQuick Tunnel URLへ更新します。

```text
https://xxxxx.trycloudflare.com
```

パスは入れません。認証はなし、認証ヘッダー生成はオフにします。

## Salesforce確認

1. 「外部サービス利用申請」タブを開く。
2. 最近の申請一覧が表示されることを確認する。
3. 新規申請を1件登録する。
4. 画面上で登録結果が分かることを確認する。
5. 登録後に一覧が更新されることを確認する。

## 参加者PCからの利用

参加者PCからでも、同じ共有Developer Orgへログインでき、Permission Setが付与されていれば利用できます。

参加者PCにMule、Docker、MySQL、cloudflaredは不要です。通信はSalesforce上のApexからNamed Credentialを経由して主催者PCへ向かいます。

## 停止順

研修終了後は次の順に停止します。

1. Salesforce画面操作を終了する。
2. `cloudflared` を実行しているPowerShellで `Ctrl+C` を押す。
3. Anypoint StudioでMuleアプリをStopする。
4. 必要に応じてMySQLを停止する。

```powershell
docker compose -f mysql\docker-compose.yml down
```

DB内容を残したくない場合のみ、主催者判断でボリューム削除を検討します。通常の研修終了では不要です。

## 配布物

- Phase1: `docs/participant/functional-spec.md`
- Phase2: ソース閲覧範囲と `docs/participant/whitebox-test-case-sheet.md`
- 主催者専用資料は公開リポジトリには含めません。

## よくあるトラブル

| 事象 | 確認点 |
| --- | --- |
| `cloudflared` が見つからない | cloudflaredのインストールとPATH |
| Salesforce画面が反応しない | Mule、Quick Tunnel、Named Credential URL |
| SalesforceログにBearer認証が出る | Named Credentialの認証設定をなしにする |
| `リモート サーバーに接続できません` | Muleが8081で起動しているか |
| DBエラー | Docker MySQL、`mysql/.env`、Muleの `config.yaml` |
| 文字化け | DBリセット、SQLファイルのUTF-8、Adminerの表示 |
| デプロイ後に画面が古い | ブラウザリロード、Lightningキャッシュ |
