# Salesforceセットアップ

## 対象DXプロジェクト

Developer Orgに接続済みの作業用DXプロジェクトは次です。

```text
SFWorkshop/SfWorkshop
```

研修アプリの元ソースは次にも保持しています。

```text
salesforce
```

主催者がDeveloper Orgへデプロイする場合は、接続済みの `SFWorkshop/SfWorkshop` 側を使います。

## Org接続確認

```powershell
cd C:\Users\VC02064\Documents\sf-mule-quality-workshop\SFWorkshop\SfWorkshop
sf org display --target-org vscodeOrg
```

`Connected Status` が `Connected` であればデプロイできます。

## デプロイ

検証だけ行う場合:

```powershell
sf project deploy start --source-dir force-app --target-org vscodeOrg --dry-run
```

実デプロイ:

```powershell
sf project deploy start --source-dir force-app --target-org vscodeOrg
```

一部だけ反映する場合:

```powershell
sf project deploy start --source-dir force-app\main\default\classes --source-dir force-app\main\default\lwc --target-org vscodeOrg
sf project deploy start --source-dir force-app\main\default\tabs --source-dir force-app\main\default\permissionsets --target-org vscodeOrg
```

Developer Orgはsource tracking非対応のため、`sf project deploy preview` は使えない場合があります。

## Named Credential

SetupからNamed Credential `MuleWorkshop` を作成または更新します。

| 項目 | 値 |
| --- | --- |
| Label | MuleWorkshop |
| Name | MuleWorkshop |
| URL | Cloudflare Quick Tunnel URL |
| 認証 | なし |
| 認証ヘッダー生成 | オフ |

URLは次のようにパスなしで設定します。

```text
https://xxxxx.trycloudflare.com
```

`/api/v1` や `/requests` は入れません。Apex側が `callout:MuleWorkshop/api/v1/requests` として付与します。

`MuleSoft Anypoint Platform US` などの外部ログイン情報は今回使いません。Bearer認証ヘッダーが付くと、Cloudflare Quick TunnelやローカルMuleへの呼び出しで想定外のエラーになることがあります。

## Permission Set

```powershell
sf org assign permset --name Service_Request_Workshop --target-org vscodeOrg
```

参加者ユーザーにも同じPermission Setを付与してください。

## タブ

アプリランチャーまたはタブから「外部サービス利用申請」を開きます。

画面では次を確認します。

- 最近の申請一覧が表示される。
- `再取得` 押下中にspinnerが表示される。
- 申請番号クリックで詳細モーダルが開く。
- 新規申請登録後、成功Toastが出る。
- エラー時に赤いToastが出る。
- 登録後に一覧が更新される。

ブラウザやLightningのキャッシュで古いLWCが表示される場合があります。デプロイ後は一度ブラウザをリロードしてください。
