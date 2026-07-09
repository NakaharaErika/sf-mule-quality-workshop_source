# Muleセットアップ

## 対象プロジェクト

Anypoint Studioで扱うMuleプロジェクトは次です。

```text
MuleWorkshop/service-request-api
```

`service-request-api1` が存在する場合でも、研修で使う標準の場所は `service-request-api` です。

## 使用バージョン

| 項目 | バージョン |
| --- | --- |
| Mule Runtime | 4.12.0 |
| Java | 17 |
| Mule Maven Plugin | 4.10.0 |
| MUnit | 3.7.1 |
| APIkit | 1.11.17 |
| Database Connector | 1.16.0 |
| MySQL JDBC Driver | 8.4.0 |

## 設定ファイル

DB接続情報は研修用として次に記載しています。

```text
MuleWorkshop/service-request-api/src/main/resources/config.yaml
```

この研修ではSecure Configuration Propertiesによる暗号化は扱いません。実案件ではパスワードを平文管理しないでください。

## Anypoint StudioへのImport

1. Anypoint Studioを通常起動する。
2. Workspaceとして `MuleWorkshop` を選択する。
3. `File > Import... > Anypoint Studio > Anypoint Studio Project from File System` を選択する。
4. `MuleWorkshop/service-request-api` を選択する。
5. `pom.xml` が存在するプロジェクトとしてImportされていることを確認する。

`pom.xml is missing` や `EmptyProjectDescriptor cannot be cast` が出る場合は、空ディレクトリや古いImport結果を選んでいる可能性があります。Package Explorerから対象プロジェクトを削除して、ファイルは削除せずにImportし直してください。

## JDBC Driver

MySQL JDBC DriverはPOMに依存関係として含めています。Studio画面で追加する場合は、次の座標を使います。

```text
Group Id: com.mysql
Artifact Id: mysql-connector-j
Version: 8.4.0
```

`mysql:mysql-connector-java:8.4.0` は今回の正しい指定ではありません。

## 起動

このプロジェクトでは `mvn mule:run` は使用しません。Mule Maven Plugin 4.10.0には `run` goalがありません。

起動はAnypoint Studioから行います。

1. Docker MySQLを起動する。
2. `service-request-api` を右クリックする。
3. `Run As > Mule Application` を選択する。
4. ConsoleでMuleアプリの起動完了を確認する。

ビルド確認だけを行う場合は次を実行できます。

```powershell
cd MuleWorkshop\service-request-api
mvn clean package -nsu -DskipMunitTests
```

## ローカル疎通確認

Mule起動後、別PowerShellで確認します。

```powershell
Invoke-RestMethod "http://127.0.0.1:8081/api/v1/requests?limit=10"
```

`リモート サーバーに接続できません` と出る場合は、Muleが8081で起動していません。

## Studioでよくある警告

`Connection is not secure. Should use HTTPS` はローカル研修用HTTP Listenerに対する警告です。今回は無視できます。

Studio上で警告が表示される場合があります。ビルドが成功し、疎通確認が通るなら研修利用上は進めて構いません。
