+++
title = "開発用にNUCを買った"
date = 2023-01-04T12:00:00+00:00

[taxonomies]
tags = ["dev","NUC"]
+++


去年からインテルのミニPC（NUC）を開発機としてメイン使いしている。

<img src="https://blog.yasun.dev/nuc/1.jpg" width="300">

Docker for Macの速度や、M1Macに変えてから諸々のDockerイメージのサポートが遅れがちだったりと不便を感じていた際に、
同じ会社の人がやっていた構成が快適そうだったので参考にさせてもらった。


基本はM1MacからSSH接続して開発している。

最近はvimからVS Codeに移行したのでExtentionの`Remote - SSH`を使ってコードを編集し、
Docker等で立ち上げたローカル環境に接続する場合はdnsmasqを使って名前解決をしている。

## 購入したNUC

- サイズ、スペックを検討して「NUC11TNKi5」を購入した。
- NUC11TNKi5についてはこちらの記事でとてもわかりやすく解説されている。
	- [手のひらサイズでリッチな超小型PC「NUC 11 Pro」。第11世代Core i5搭載モデルをレビュー](https://pc.watch.impress.co.jp/docs/column/hothot/1317129.html)

## 用意したもの

### USBメモリ
- ブート用に2G以上のUSBメモリが必要。

### メモリ
- 対応規格: DDR4 SO-DIMM×2(DDR4-3200対応、最大64GB)
- CrucialのノートPC用メモリを購入した
	- https://www.amazon.co.jp/dp/B07ZLC7VNH

### SSD
- 対応規格: M.2(2280、PCI Express 4.0 x4)、M.2(2242、SATA)
- NUC11TNKi5はM.2対応SSDのみを利用可能なので注意が必要
	- https://www.amazon.co.jp/dp/B08NDH38D7

##  OSのセットアップ

### ブートUSBの作成
- 手順はubuntuの公式ページを参照
	- https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-macos#0
	- 基本的な手順は以下
		- USBメモリを初期化
		- 利用するバージョンのISOファイルをダウンロード
		- Etcherを使ってブートUSBにする
	- 自分はGUIを使う用途が無さそうだったのでUbuntu Serverを選んだ

### Ubuntuのインストール
- 作成したUSBを差して起動するとウィザードが出る。
- でない場合はBootメニューからUSBを指定する。

## ネットワークの接続
- Netplanでネットワークの設定を追加する。
- Netplanの設定ファイルは`/etc/netplan/`配下にある。
- ファイルの読み込み順で上書きされるので `/etc/netplan/99_config.yaml` のように最後に読み込まれるファイル名で作成する。
- 固定IPを使うかどうか、無線/有線で設定内容が変わってくる。
	- 詳しくはこちら: https://netplan.io/examples/

#### WIFIで固定IPを使う例
```
network:
  version: 2
  wifis:
    wlo1:
      dhcp4: no
      dhcp6: no
      access-points:
        "{使いたいSSID}":
          password: "{パスワード}"
      addresses: [{IPアドレス(CIDR表記のサブネットマスク)}]
      gateway4: {デフォルトゲートウェイのIPアドレス}
      nameservers:
        addresses: [{DNSアドレス}]
```

#### 有線で固定IPを使う例

```
network:
  version: 2
  ethernets:
    {インターフェース名}:
      dhcp4: false
      dhcp6: false
      addresses: [{IPアドレス(CIDR表記のサブネットマスク)}]
      gateway4: {デフォルトゲートウェイのIPアドレス}
      nameservers:
        addresses: [{DNSアドレス}]
```

- 変更後は `sudo netplan apply`で反映させる。

## SSH
- 他と同様にssh key を作成してconfigに追加する。
```
Host nuc
  User {ユーザー}
  HostName {NUCのIP}
  IdentityFile {作った鍵の場所}
  Port {開けてるSSHポート}
  ServerAliveInterval 60
  ServerAliveCountMax 5
```


## VS Codeの設定
- VS CodeからSSH経由でNUCに接続する
- Extentionから`Remote - SSH`をインストールして`ssh config`のパスを指定する。
	- https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh


## dnsmasqの設定
- NUC上で立ち上げたWebアプリケーション等にMacからブラウザ表示等をするためdnsmasqを利用する。
- Macにdnsmasqをhomebrewでインストールする。
- `*.dev.me`の解決をNUCにする場合は以下。
```
echo 'address=/dev.me/::1' >> $(brew --prefix)/etc/dnsmasq.conf
echo 'address=/dev.me/{NUCのIPアドレス}' >> $(brew --prefix)/etc/dnsmasq.conf

echo "nameserver ::1" >> /etc/resolver/dev.me'
echo "nameserver 127.0.0.1" >> /etc/resolver/dev.me'
```
