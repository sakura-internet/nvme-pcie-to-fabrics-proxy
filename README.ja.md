# nvme-pcie-to-fabrics-proxy

- [README (English)](./README.md)

- (注) 現在は一部機能のみが実装されています。今後の予定については「ロードマップ」の項をご覧ください。

![ramdisk_ax7a200.jpg](docs/imgs/ramdisk_ax7a200.jpg)

fig. 1: ramdisk デザインを導入した PCIe ボードをマウントした PC の例

list 1: テスト結果の例

```
$ sudo nvme id-ctrl /dev/nvme0n1
NVME Identify Controller:
vid       : 0x10ee
ssvid     : 0x9028
sn        : 000000000000
mn        : FPGA-emulated RAMDISK
fr        : 0000
rab       : 1
ieee      : 9ca3ba
... snip ...
tnvmcap   : 1073741824
... snip ...

$ dd if=/dev/urandom of=input.img bs=4k count=16k
16384+0 records in
16384+0 records out
67108864 bytes (67 MB, 64 MiB) copied, 0.216841 s, 309 MB/s

$ sudo dd if=input.img of=/dev/nvme0n1 bs=4k count=16k
16384+0 records in
16384+0 records out
67108864 bytes (67 MB, 64 MiB) copied, 60.7511 s, 1.1 MB/s

$ sudo dd if=/dev/nvme0n1 of=output.img bs=4k count=16k
16384+0 records in
16384+0 records out
67108864 bytes (67 MB, 64 MiB) copied, 42.0484 s, 1.6 MB/s

$ diff -s input.img output.img
Files input.img and output.img are identical
```


## これは何？

- イーサネット接続を備えた PCIe FPGA 開発ボードにインストールして、PC に装着して用いる回路設計＆ファームウェアのプロジェクトです
- 該当ボードは PC から NVMe SSD デバイスとして認識され、かつその SSD への読み書きは LAN 上の予め設定した NVMe-TCP ターゲットに対する読み書きに変換されるため、PC をローカルストレージなしで NAS などの装置からブートして使用することができます (注：ネットワーク機能は開発中でありまだ使えません)
- 開発者向けのイメージが強い FPGA 開発ボードを「普段使い」で役立てるユースケースを提案します
- オープンソースで構築し、ボードの入手以外の追加コストができるだけかからないよう工夫しています
- 規格の理解、移植、部分機能の流用に便利なよう、チュートリアルとして一部機能（NVMe 規格でアクセスできる RAMDISK など）のみの実装を整備します

## 制約

- NVMe 1.3 規格を参考に作成していますが、準拠することは保証できません
- 実験用のコードであり、使用することによって発生した損害、データ損失等について責任を負えません

## ロードマップ

- 2023.02 : Xilinx FPGA を搭載した 2 種類のボードについて、NVMe 規格でアクセスできる低速な RAMDISK 実装（チュートリアル１）を整備
- tbd     : 予め設定した NVMe-TCP ターゲットへの低速な読み書き（チュートリアル２）を整備
- tbd     : read / write をハードウェア実装することによる高速化

## サポートする FPGA 開発ボード

| ボード名 (カッコ内は符号) | コアFPGA           | PCIe 規格 | イーサネット規格                      | 書き込みツール                      | 開発フェーズ     | note                                                                  |
|---------------------------|--------------------|-----------|---------------------------------------|-------------------------------------|------------------|-----------------------------------------------------------------------|
| Xilinx Alveo U50 (au50)   | Virtex Ultrascale+ | gen3 x8   | QSFP+ 4x breakout を用いた 10GbE 接続 | Alveo Programming Cable (別売)      | チュートリアル 1 | Alveo Vivado Secure Site へのアクセスが必要（Xilinx 社 FAE に確認要）|
| ALINX ax7a200 (ax7a200)   | Artix-7 xc7a200    | gen2 x2   | RJ-45 ポートからの 1GbE 接続          | AL321 書き込みケーブル (キット付属) | チュートリアル 1 |                                                                       |

## ディレクトリ構造

```
├── LICENSE
├── README.md                : 英語版 README
├── README.ja.md             : このファイル
├── docs
├── tutorials
│   ├── 01_ramdisk           : チュートリアル１（NVMe 規格でアクセスできる RAMDISK）
│   │   ├── xilinx_2022.1    : ここで `make` コマンドを発行することで Xilinx ツールの PATH が通ったシェルをセットアップできます
│   │   │   ├── Makefile
│   │   │   ├── README.md
│   │   │   ├── au50         : ここで `make` コマンドを発行することで Alveo U50 用の EEPROM コンフィグレーションファイル生成を行えます
│   │   │   ├── ax7a200      : ここで `make` コマンドを発行することで AX7A200 用の EEPROM コンフィグレーションファイル生成を行えます
│   │   │   └── docker
│   │   └── (intelfpga_)     : 予約
│   └── (02_lwip)            : 予約
└── (mainline)               : 予約
```

## 動作環境

- サポートされている PCIe FPGA 開発ボード

- 書き込みツール

- コンパイル＆焼き込み用 PC
  + x86\_64 アーキテクチャの Linux ホスト PC
  + 16GB 以上のメモリ推奨（大型の FPGA はより多くメモリを要求する場合があります）
  + 数百GB 程度のストレージ空き容量 (特に /opt のサイズが必要です)
  + docker コマンドがユーザ権限で使用できる必要があります
  + USB 接続の書き込みツールにユーザの読み書き権限がついた状態としてください
    * 一部のツールはデフォルトで ftdi\_sio ドライバがバインドされてしまい、一旦それらをアンバインドする作業が必要な場合があります

- エミュレートされた NVMe SSD にアクセスする環境
  + PCIe スロットを搭載したホスト PC (x86-based, arm-based, and etc.)
  + NVMe ドライバを搭載した OS (Linux, Windows, and etc.)
    * テストは現在 x86\_64 Linux ホストのみで行われています

## 使い方

1. コンパイラツールチェインをインストールして PATH に通す作業
  + 使用したい開発段階のディレクトリに移動します (例 : "01\_ramdisk")
  + さらに {FPGAベンダ}\_{ツールチェインバージョン} の命名則のディレクトリに移動します（例 : "xilinx\_2022.1"）
  + `$ make` コマンドで該当ツールチェイン向けの環境を整備した docker image を用いたシェル環境に移動します
    * 初回は /opt にツールチェイン本体をインストールする必要があります。image 内 /root/install.sh スクリプトを使用することでインストールの手間を削減できます。
  + 別途コンパイラツールチェインをインストールしておりすでに PATH に必要なコマンドが通っている場合、この段階はスキップ可能です。

2. コンパイルと EEPROM 用コンフィグレーションファイルの入手
  + {該当ボードの符号名} ディレクトリに移動します（例 : "au50"）
    * 注 : alveo U50 ボードは au50 用 BDF (board definition file) を ext\_resource ディレクトリ以下に準備する必要があります。該当ディレクトリの README を確認してください。
  + `$ make` コマンドでコンパイルが実行され、完了後 `output` ディレクトリに EEPROM コンフィグレーションファイルが配置されます。（例： Xilinx FPGA においては .mcs ファイル）

3. FPGA 開発ボードへの EEPROM の書き込み
  + ツールチェインごとの書き込みツールを起動しプログラミングケーブル経由でボード上 EEPROM にコンフィグファイルを書き込みます
  + 手順の詳細は各ディレクトリの README を参照してください

4. ボードをテスト用 PC に装着して電源投入
  + Linux においては典型的には /dev/nvme0n1 として認識され、`gdisk` でパーティショニング、`mkfs.ext4` などでフォーマット可能です。

注 : チュートリアル用の RAMDISK サンプルでは電源断とともに書き込んだデータはすべて消失することに注意してください。

## 参考リンク
- [NVM Express Base Specification](https://nvmexpress.org/developers/nvme-specification/)
  + [https://nvmexpress.org/wp-content/uploads/NVM-Express-1_3d-2019.03.20-Ratified.pdf](https://nvmexpress.org/wp-content/uploads/NVM-Express-1_3d-2019.03.20-Ratified.pdf)

