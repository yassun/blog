+++
title = "Withings Bodyの計測結果を取得した"
date = 2022-02-20T12:00:00+00:00

[taxonomies]
tags = ["Rust","withings"]
+++

今年から筋トレを開始し、知人に勧められた`Withings Body`を購入した。

# Withings Body
[https://www.withings.com/jp/ja/scales](https://www.withings.com/jp/ja/scales)
- WiFi/Bluetoothに接続できるスマート体重計。
- 専用アプリをインストールすることで体重や体脂肪等のダッシュボードを見ることができる。
- 面白い点としてOAuth認証でWebAPIが公開されていて計測結果の情報に自由にアクセスできる。

# APIでできること
計測した結果は殆どアクセスできる。
睡眠パッドやウォッチのAPIも含まれているため色々なエントリポイントがある。
[api-reference](https://developer.withings.com/api-reference)

体重計の情報の取得に必要なAPIは以下。
- [OAuth2](https://developer.withings.com/api-reference#tag/oauth2)
- [Measure](https://developer.withings.com/api-reference#tag/measure)

## API KeyとSecretの取得
API利用のためには以下からアプリを作成してAPI KeyとSecretの取得する必要がある。
[https://oauth.withings.com/](https://oauth.withings.com/)


## Authentication Codeの取得

[oauth2-authorize](https://developer.withings.com/api-reference#operation/oauth2-authorize)

以下URLにGetでアクセスすることで`authentication code`を取得できる。
```
https://account.withings.com/oauth2_user/authorize2?response_type=code&client_id=`your_client_id`&redirect_uri=https%3A%2F%2Flocalhost&scope=user.info%2Cuser.metrics&state=demo
```

今回はCLIから利用を想定しているので`redirect_uri`にlocalhostに指定してリダイレクトされたURLパラメータから`code`を取得した。

`code`の有効期限は30秒しかないので注意。

## Access Tokenの取得

[oauth2-getaccesstoken](https://oauth.withings.com/api-reference#operation/oauth2-getaccesstoken)

以下URLにPOSTでアクセスすることで`Access Token`を取得できる。

```
curl --data "action=requesttoken&grant_type=authorization_code&client_id=`your_client_id`&client_secret=`your_client_secret`&code=`上記で取得したauthentication_code`&redirect_uri=http://localhost/" 'https://wbsapi.withings.net/v2/oauth2'
```

`action`と`authorization_code`は固定の文字列が入る。

## Measure情報の取得
[measure-getmeas](https://developer.withings.com/api-reference#operation/measure-getmeas)

以下URLにPOSTでアクセスすることで`Measure情報`を取得できる。

```
curl --header "Authorization: Bearer `上記で取得したAccess Token`" --data "action=getmeas&meastype=1&category=1" 'https://wbsapi.withings.net/measure'
```

パラメータで指定できる項目が沢山あるが、体重取得時に使うパラメータは以下で良さそう。

```
meastype: 1 // Weight (kg)
category: 1 // for real measures
startdate: `unix time` // Measures' start date.
enddate:   `unix time` // Measures' end date
````

体脂肪など他の情報も同時に取得したい場合は`meastype`の代わりに`meastypes`を使用使用する。

```
meastypes=1,6
```

# RustでAPIのクライアントライブラリを作った

結構な頻度でトークンの再取得/リフレッシュを行う必要があり大変だったのでRustでAPIクライアントを作った。
[https://github.com/yassun/withings-api](https://github.com/yassun/withings-api)

こちらを使って定期的に`Getmeas`を呼ぶことでSlackやLineに最新の測定結果を通知することが可能になった。
