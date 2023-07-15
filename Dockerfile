# ベースイメージを指定します。Golangの公式イメージを使用します。
FROM golang:latest

# コンテナ内に作業ディレクトリを作成します。
WORKDIR /app

# ホストのカレントディレクトリのファイルをコンテナの作業ディレクトリにコピーします。
COPY . .

# Goの依存関係を解決します。
RUN go mod download

# アプリケーションをビルドします。
RUN go build -o main .

# コンテナ起動時に実行されるコマンドを指定します。
CMD ["./main"]
