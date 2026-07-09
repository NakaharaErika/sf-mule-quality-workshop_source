# 構成概要

この研修アプリは、共有Salesforce Developer Orgから主催者PC上のAPIへ接続し、主催者PC上のDocker MySQLへ申請データを保存します。

```text
参加者PCのブラウザ
  -> 共有Developer Org
  -> Salesforce画面
  -> Salesforceサーバー側処理
  -> Cloudflare Quick Tunnel
  -> 主催者PCのMule API
  -> 主催者PCのDocker MySQL
```

## 方針

- 参加者PCから主催者PCのMuleやMySQLへ直接接続しません。
- Cloudflare Quick Tunnel URLはソースコードへ書きません。
- Quick Tunnel URLは研修当日にSalesforce側の接続設定へ手動反映します。
- Salesforceには申請データを保存しません。
- MuleとMySQLは主催者PCでのみ起動します。
- 参加者PCにはDocker、Mule、cloudflaredは不要です。

## データの流れ

利用者がSalesforce画面で申請を登録すると、Salesforceから外部APIへ申請内容が送信されます。外部APIは申請データをMySQLへ保存します。

一覧表示では、Salesforce画面から外部APIへ問い合わせ、保存済みの申請情報を取得します。

## ローカル公開範囲

MySQLはローカルPC内からの接続を前提にします。外部ネットワークへMySQLを直接公開しません。

Cloudflare Quick Tunnelは、Salesforceから主催者PCのローカルAPIへ到達するために利用します。Muleが停止している場合、Quick Tunnelが起動していてもSalesforceからの呼び出しは成功しません。
