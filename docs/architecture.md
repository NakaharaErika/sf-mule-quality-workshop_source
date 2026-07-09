# アーキテクチャ

この研修アプリは、共有Salesforce Developer Orgから主催者PC上のMule APIへ接続し、主催者PC上のDocker MySQLへ申請データを保存します。

```text
参加者PCのブラウザ
  -> 共有Developer Org
  -> LWC: externalServiceRequestWorkspace
  -> Apex Controller / Service
  -> Named Credential: MuleWorkshop
  -> Cloudflare Quick Tunnel
  -> 主催者PCのMule service-request-api
  -> 主催者PCのDocker MySQL workshop_db.service_request
```

## 固定方針

- LWCはMuleへ直接HTTP通信しません。
- Apexは `callout:MuleWorkshop` だけを使用してMule APIを呼び出します。
- Cloudflare Quick Tunnel URLはソースコードへ書きません。
- Quick Tunnel URLは研修当日にSalesforce SetupのNamed Credentialへ手動設定します。
- Salesforceには業務データを保存しません。
- 更新・削除機能は作りません。
- 登録と一覧表示、申請番号クリックによる詳細表示だけを扱います。
- MuleとMySQLは主催者PCでのみ起動します。
- 参加者PCにはDocker、Mule、cloudflaredは不要です。

## 主な責務

| 層 | 責務 |
| --- | --- |
| LWC | 入力、条件付き表示、値クリア、一覧表示、詳細モーダル、処理中spinner |
| Apex | 入力の再検証、Named Credential経由のHTTP Callout、HTTPエラーの利用者向け変換 |
| Mule | RAML検証、業務バリデーション、Choiceによる業務分岐、DataWeave変換、DB登録と一覧取得 |
| MySQL | 申請データの永続化、初期データ、申請番号のユニーク制約 |
| Cloudflare Quick Tunnel | Salesforceから主催者PCのローカルMuleへ到達する一時URLの提供 |

## 通信とデータ保存

Salesforce画面で登録された業務データは、ApexからMuleへJSONで送信され、MuleがMySQLへ保存します。Salesforce側にはカスタムオブジェクトを作らず、申請内容を保存しません。

一覧表示ではMuleがMySQLから最近の申請を取得し、Apex経由でLWCへ返します。LWCは一覧には主要項目だけを表示し、申請番号クリック時に同じレスポンス内の詳細項目をモーダル表示します。

## ローカル公開範囲

MySQLはDocker Composeで `127.0.0.1:3307` のみに公開します。外部ネットワークへMySQLを直接公開しません。

Cloudflare Quick Tunnelは `http://localhost:8081` へ転送します。Muleが停止している場合、Cloudflare URLが存在していてもSalesforceからの呼び出しは成功しません。

## テスト教材としての分離

参加者は主に仕様からテスト観点を考え、後半でソースを読んでホワイトボックステストケースを設計します。主催者専用のテスト資産、模範解答、mutation候補は `facilitator-assets` と `docs/facilitator` に分離します。

参加者配布物にはテストコード、模範解答、mutation候補を含めないでください。
