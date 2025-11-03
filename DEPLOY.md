# GitHubデプロイ手順

## 1. GitHubでリポジトリを作成

1. https://github.com にログイン
2. 右上の「+」→「New repository」をクリック
3. 以下を設定：
   - Repository name: `feature-engineering-push-notice`（またはお好みの名前）
   - Description: `プッシュ通知の特徴量エンジニアリングとF2転換率分析プロジェクト`
   - Public/Private: お好みで選択
   - **重要**: README、.gitignore、ライセンスは追加しない（既にファイルがあるため）
4. 「Create repository」をクリック

## 2. ローカルでGitを初期化してアップロード

以下のコマンドを順番に実行してください：

```bash
# feature_engineering_push_notice ディレクトリに移動
cd feature_engineering_push_notice

# Gitリポジトリを初期化
git init

# すべてのファイルを追加
git add .

# 初回コミット
git commit -m "Initial commit: Push notification feature engineering project"

# ブランチ名を main に設定（GitHubのデフォルト）
git branch -M main

# リモートリポジトリを追加（YOUR_USERNAME を自分のGitHubユーザー名に置き換え）
git remote add origin https://github.com/YOUR_USERNAME/feature-engineering-push-notice.git

# アップロード
git push -u origin main
```

## 注意事項

- `YOUR_USERNAME` は自分のGitHubユーザー名に置き換えてください
- リポジトリ名が異なる場合は、`feature-engineering-push-notice` の部分も変更してください
- 初回の `git push` でユーザー名とパスワード（またはPersonal Access Token）の入力が求められます

## トラブルシューティング

### Personal Access Tokenが必要な場合
GitHubは2021年8月以降、パスワード認証を廃止しています。Personal Access Tokenが必要です：
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. 「Generate new token」をクリック
3. `repo` スコープを選択してトークンを生成
4. パスワードの代わりにこのトークンを使用

