# windows-batch-tools

Windows の標準コマンドだけで動く、ちょっとした作業用のバッチファイル集です。
インストールは不要で、`bin` フォルダを PATH に通すか、そのままダブルクリック／コマンドプロンプトから使えます。

| ファイル | できること | 使っている標準コマンド |
|---|---|---|
| [cab-split.bat](bin/cab-split.bat) | 大きなファイルを圧縮して、指定サイズの CAB ファイルに分割する | `makecab` |
| [cab-join.bat](bin/cab-join.bat) | 分割した CAB ファイルから元のファイルを復元する | `extrac32` |
| [hash.bat](bin/hash.bat) | ファイルのハッシュ値を表示する／2 つのファイルが同じか比べる | `certutil` |
| [mirror-backup.bat](bin/mirror-backup.bat) | フォルダをバックアップ先にミラーリングする（事前確認モードあり） | `robocopy` |

## 使い方

### ファイルを分割して、元に戻す

メールの添付上限やアップロードの容量制限があるときに、大きなファイルを分けて渡す用途を想定しています。

```bat
rem 500MB ずつに分割（backup_cab\backup_1.cab, backup_2.cab, ... ができる）
cab-split.bat backup.zip 500

rem 受け取った側：CAB をすべて同じフォルダに置き、1 つ目を指定して復元
cab-join.bat backup_cab\backup_1.cab D:\restore

rem 元のファイルと同じか確認
hash.bat backup.zip D:\restore\backup.zip
```

- 分割サイズの既定値は 100MB、指定できる上限は 2000MB です
- 圧縮形式は LZX なので、分割と同時に容量も小さくなります（すでに圧縮済みの zip や動画はあまり縮みません）

### ハッシュ値の確認

```bat
hash.bat setup.iso                 rem SHA256 を表示
hash.bat setup.iso MD5             rem アルゴリズムを指定
hash.bat a.zip b.zip               rem 2 つを比べて [OK] / [NG] を表示（終了コードも 0 / 1）
```

### フォルダのバックアップ

```bat
rem まずは dry で、何がコピー・削除されるかだけ確認する
mirror-backup.bat C:\work D:\backup\work dry

rem 問題なければ実行
mirror-backup.bat C:\work D:\backup\work
```

`/MIR` を使うので、**元のフォルダから消したファイルはバックアップ先からも消えます**。必ず `dry` で確認してから実行してください。
ログはバックアップ先の `_backup_logs` フォルダに日時付きで残ります。

## 書くときに気をつけたこと

- **入力チェックを先に行う**：ファイルの有無、数値かどうか、上書きになる場合などは処理の前に止めて、理由を表示する
- **終了コードを返す**：成功は `0`、失敗は `1` 以上、使い方の誤りは `2`。ほかのバッチやタスクスケジューラから結果を判定できる
- **空白や括弧を含むパスでも動くようにする**：変数は `"%VAR%"` の形で必ずクォートし、括弧のブロック内でパスを展開しない（`Program Files (x86)` のような括弧を含むパスで構文が壊れないため）
- **文字化けを避ける**：表示メッセージは英語にして、文字コードの違う環境でもそのまま動くようにしている
- **robocopy の終了コード**：0〜7 は成功（ビットフラグ）、8 以上が失敗なので、`errorlevel 1` ではなく `8` 以上で判定している

## 開発について

このリポジトリは AI コーディングアシスタントの Claude（Anthropic）を使って作成しています。
