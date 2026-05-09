**日本語** | [English](README_EN.md)

# flash-japanese.nvim

[flash.nvim](https://github.com/folke/flash.nvim) を使って、ローマ字入力で日本語テキストにジャンプする Neovim プラグインです。

## 特徴

- ローマ字入力でひらがな・カタカナ・漢字にジャンプ
- SKK 辞書（130,000 以上のエントリ）を活用
- flash.nvim とのシームレスな統合

## なぜ flash-japanese？

- **外部依存なし** — C バイナリや Deno が必要な Migemo 系プラグインと違い、プラグインマネージャだけですぐに使えます
- **flash.nvim ベース** — flash.nvim の薄いラッパーとして動作し、コードベースは小さく安定しています。flash.nvim の機能（ラベル、マルチウィンドウ、オペレーター待機モード）はそのまま使えます
- **高速なバッファスコープマッチング** — 画面に表示されている漢字のみをマッチ対象にするため、正規表現の候補が少なく、検索が高速で、ジャンプまでのキーストロークも少なくなります

## 要件

- Neovim 0.8 以上
- [flash.nvim](https://github.com/folke/flash.nvim)

## インストール

### [lazy.nvim](https://github.com/folke/lazy.nvim) の場合

```lua
{
  "walkersumida/flash-japanese.nvim",
  version = "*",
  dependencies = { "folke/flash.nvim" },
  opts = {},
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim) の場合

```lua
use {
  "walkersumida/flash-japanese.nvim",
  requires = { "folke/flash.nvim" },
  config = function()
    require("flash-japanese").setup()
  end,
}
```

> **注意:** 以下の設定例は lazy.nvim の `opts` 構文を使用しています。packer.nvim の場合は同じオプションを `setup()` に渡してください。

## 使い方

1. `sj` を押す（デフォルトのキーマップ）
2. ローマ字を入力する（例：`ten`）
3. マッチする日本語テキスト（天、点、店、てん、テン など）にラベルが表示される
4. ラベルキーを押してジャンプ

## 設定

### デフォルト設定

```lua
-- lazy.nvim の場合
{
  "walkersumida/flash-japanese.nvim",
  version = "*",
  dependencies = { "folke/flash.nvim" },
  opts = {
    -- キーマッピング
    keys = {
      jump = "sj",  -- false に設定するとデフォルトキーマップを無効化
    },

    -- ローマ字入力をそのままリテラルマッチに含める（英語テキストにもマッチ）
    include_raw_input = false,

    -- ジャンプ後の誤入力防止のクールダウン期間（ミリ秒、0 で無効化）
    cooldown_ms = 1000,

    -- デバッグモード（検索パターンをログ出力）
    debug = false,

    -- flash.nvim に渡すオプション
    flash_opts = {},
  },
}
```

### カスタムキーマップ

```lua
-- lazy.nvim の場合
{
  "walkersumida/flash-japanese.nvim",
  version = "*",
  dependencies = { "folke/flash.nvim" },
  opts = {
    keys = {
      jump = false,  -- デフォルトキーマップを無効化
    },
  },
}
```

独自のキーマップを設定:

```lua
vim.keymap.set({ "n", "x", "o" }, "<leader>j", function()
  require("flash-japanese").jump()
end, { desc = "Flash Japanese" })
```

## ローマ字変換

標準的なローマ字入力に対応しています:

| ローマ字 | ひらがな |
|--------|----------|
| a, i, u, e, o | あ, い, う, え, お |
| ka, ki, ku, ke, ko | か, き, く, け, こ |
| sha, shi, shu, she, sho | しゃ, し, しゅ, しぇ, しょ |
| kya, kyu, kyo | きゃ, きゅ, きょ |
| nn | ん |
| kk（二重子音） | っk |

## 仕組み

1. ローマ字入力をひらがなに変換し、さらにカタカナにも変換して両方を検索候補にする
2. 現在のバッファに表示されている漢字をスキャンし、SKK 辞書の前方一致検索でマッチする漢字を検索候補に追加
3. すべての候補（ひらがな・カタカナ・漢字）を Vim の正規表現パターンに結合
4. flash.nvim がすべてのマッチをハイライト

## 開発

### 辞書の再生成

プラグインにはビルド済みの `dict.json` が同梱されています。最新の SKK 辞書から再生成するには:

```bash
# SKK-JISYO.L をダウンロード
curl -sL "https://raw.githubusercontent.com/skk-dev/dict/master/SKK-JISYO.L" -o /tmp/SKK-JISYO.L

# dict.json を再生成（Go が必要）
cd scripts
go run convert_skk_dict.go /tmp/SKK-JISYO.L ../lua/flash-japanese/dict.json
```

## ライセンス

GPL-2.0

## クレジット

- [flash.nvim](https://github.com/folke/flash.nvim) by folke
- [SKK Dictionary](https://skk-dev.github.io/dict/) — 漢字マッピング
