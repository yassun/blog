+++
title = "ブログをZolaに移行した"
date = 2021-12-28T11:20:00+00:00

[taxonomies]
tags = ["Rust", "Zola"]
+++


ブログをそろそろ再開したいと思い、ついでなので環境も[旧ブログ](https://yasun.hatenablog.jp/)から別のものに移行することにした。

# 比較
移行に伴い昨今のSSG事情を調査した。
[jamstack - Site Generators](https://jamstack.org/generators/)

`Hugo`、`Gatsby`、`Next.js`、`Hexo` あたりが人気 。`Jekyll`も根強い。

調査中にRust製の`Zola`というものを見つけ、最近はRustを書くことが多いので使ってみることにした。

# Zola

- [Rust製SSG](https://www.getzola.org/)
- テンプレートエンジンに[Tera](https://github.com/Keats/tera)を採用しており、こちらもRust製。
	- similar to Jinja2, Django templates, Liquid, and Twig.
- コンテンツはCommonMarkで記述する。

# Install

シングルバイナリなのでbrewでinstallできる。

```bash
 $ brew install zola
```

# Hello world
`zola init ディレクトリ名` で初期構築を対話式で行うことができる。

```bash
zola init blog
Welcome to Zola!
Please answer a few questions to get started quickly.
Any choices made can be changed by modifying the `config.toml` file later.
> What is the URL of your site? (https://example.com): https://yassun.github.io/blog/
> Do you want to enable Sass compilation? [Y/n]: Y
> Do you want to enable syntax highlighting? [y/N]: y
> Do you want to build a search index of the content? [y/N]: y
```

作成直後のディレクトリ構成。config.toml以外は空の状態。
```bash
$ tree blog
blog
├── config.toml
├── content
├── sass
├── static
├── templates
└── themes

```

`zola serve` を実行するとローカル環境で表示を確認することができる。
```bash
$ zola serve                                                                                                                                                                                                                           Building site...
Checking all internal links with anchors.
> Successfully checked 0 internal link(s) with anchors.
-> Creating 0 pages (0 orphan) and 0 sections
Done in 9ms.

Web server is available at http://127.0.0.1:1111
```

# Hosting
試しにGitHub Pagesにホスティングしてみる。

`zola build`を実行するとhtmlを`public`配下に生成できるので
こちらを`gh-pages -d public`等でgh-pagesにpushすると`https://[ユーザ名].github.io/[リポジトリ名]/`にホスティングされる。
```bash
$ zola build
Checking all internal links with anchors.
> Successfully checked 0 internal link(s) with anchors.
-> Creating 0 pages (0 orphan) and 0 sections
Done in 13ms.
```

CI経由でのデプロイも簡単にできる。[deployment](https://www.getzola.org/documentation/deployment/github-pages/)

# themes
初期状態では味気ないのでテーマをいれてみる。

[installing-and-using-themes](https://www.getzola.org/documentation/themes/installing-and-using-themes/)

[ここ](https://www.getzola.org/themes/)から好きなテーマを選択し、該当のリポジトリを`thems`ディレクトリ配下にcloneもしくは`submodule add` で追加する。

追加後に`config.toml`に`theme = "テーマ名"`の記述をすると有効になる。

今回は[tale-zola](https://www.getzola.org/themes/tale-zola/)を選択した。

# Content

実際にこの記事を書いてみる。
[content/overview](https://www.getzola.org/documentation/content/overview/)

`content/`配下に置かれたマークダウンがそのまま記事として生成され、URLリソース等もファイル名とディレクトリに一致する。

表示形式については `templates/`配下のファイルでカスタマイズ可能。
[templates/overview](https://www.getzola.org/documentation/templates/overview/)

テンプレートの中身は[Tera](https://tera.netlify.app/)を使って記述することができる。

# ここまでの所感
## Pros
- シングルバイナリなので依存モジュール等のパッケージ管理が不要。
- コマンドがシンプルで覚える事が少なくデプロイまですぐに行うことができる。
- ビルドが早い。ビルト時のエラーも親切。

## Cons
- 公式テーマが少ない。
	- その他のSSGに比べると圧倒的に少ない。

デザインに関するこだわりも少なく、なるべくシンプルに運用したいと思っていたので自分の要望にはかなりマッチしていた。

このまましばらく運用を続けて行こうと思う。
