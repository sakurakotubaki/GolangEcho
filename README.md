# Go言語でechoを使う
今回は、ダミーのデータを配列に追加するREST APIをechoを使って作成します。

echoの環境構築をする方法
https://echo.labstack.com/docs/quick-start

server.goを作成して、サンプルコードを書く
```go
package 1

import (
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

// ShoppingItemという構造体を定義します。
type ShoppingItem struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

// ShoppingListは、買い物リストを表します。
var ShoppingList []ShoppingItem

func main() {
	// Echoのインスタンスを作成します。
	e := echo.New()

	/// [ルーティングを設定します]
	// ここでは、GET /shoppingで買い物リストを取得するAPIを定義しています。
	e.GET("/shopping", getShoppingList)
	// ここでは、POST /shoppingで買い物リストに新しいアイテムを追加するAPIを定義しています。
	e.POST("/shopping", createShoppingItem)
	// ここでは、PUT /shopping/:idで買い物リストのアイテムを更新するAPIを定義しています。
	e.PUT("/shopping/:id", updateShoppingItem)
	// ここでは、DELETE /shopping/:idで買い物リストのアイテムを削除するAPIを定義しています。
	e.DELETE("/shopping/:id", deleteShoppingItem)

	// ポート番号が8080のサーバーを起動します。
	e.Start(":8080")
}

// getShoppingListは、買い物リストを取得するAPIです。
func getShoppingList(c echo.Context) error {
	// 買い物リストをJSONで返します。
	return c.JSON(http.StatusOK, ShoppingList)
}

// createShoppingItemは、買い物リストに新しいアイテムを追加するAPIです。
func createShoppingItem(c echo.Context) error {
	// リクエストボディをShoppingItem構造体にバインドします。
	item := new(ShoppingItem)
	// バインドに失敗した場合は、400 Bad Requestを返します。
	if err := c.Bind(item); err != nil {
		// エラーをJSONで返します。
		return c.JSON(http.StatusBadRequest, err)
	}
  // 買い物リストの末尾にアイテムを追加します。
	item.ID = len(ShoppingList) + 1
	// 買い物リストをJSONで返します。
	ShoppingList = append(ShoppingList, *item)
  // 201 Createdを返します。
	return c.JSON(http.StatusCreated, item)
}

// updateShoppingItemは、買い物リストのアイテムを更新するAPIです。
func updateShoppingItem(c echo.Context) error {
	// パスパラメータからIDを取得します。
	id, _ := strconv.Atoi(c.Param("id"))
  // リクエストボディをShoppingItem構造体にバインドします。
	item := new(ShoppingItem)
	// バインドに失敗した場合は、400 Bad Requestを返します。
	if err := c.Bind(item); err != nil {
		// エラーをJSONで返します。
		return c.JSON(http.StatusBadRequest, err)
	}
  // 買い物リストのアイテムを更新します。
	for i, existingItem := range ShoppingList {
		// IDが一致するアイテムを探します。
		if existingItem.ID == id {
			// 見つかったアイテムのIDを更新します。
			item.ID = id
			// 買い物リストのアイテムを更新します。
			ShoppingList[i] = *item
			// 更新したアイテムをJSONで返します。
			return c.JSON(http.StatusOK, item)
		}
	}
  // アイテムが見つからなかった場合は、404 Not Foundを返します。
	return c.JSON(http.StatusNotFound, "Item not found")
}

// deleteShoppingItemは、買い物リストのアイテムを削除するAPIです。
func deleteShoppingItem(c echo.Context) error {
	// パスパラメータからIDを取得します。 _ は、エラーを無視するための変数です。
	id, _ := strconv.Atoi(c.Param("id"))
  // 買い物リストのアイテムを削除します。
	for i, item := range ShoppingList {
		// IDが一致するアイテムを探します。
		if item.ID == id {
			// 買い物リストからアイテムを削除します。
			ShoppingList = append(ShoppingList[:i], ShoppingList[i+1:]...)
			// 204 No Contentを返します。
			return c.NoContent(http.StatusNoContent)
		}
	}
  // アイテムが見つからなかった場合は、404 Not Foundを返します。
	return c.JSON(http.StatusNotFound, "Item not found")
}
```


ローカルサーバーを起動するコマンド
```
go run server.go
```

## 📡HTTP POSTするcurlコマンド
```
curl -X POST -H "Content-Type: application/json" -d '{"name": "洗濯洗剤"}' http://localhost:8080/shopping
```

２個目のデータを追加
```
curl -X POST -H "Content-Type: application/json" -d '{"name": "キッチンペーパー"}' http://localhost:8080/shopping
```

## Docker化する方法
GolangのREST APIをDocker化する手順を説明します。

Dockerfileの作成:
まず、プロジェクトのルートディレクトリにDockerfileを作成します。以下の内容をDockerfileに追加します。
```Dockerfile
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
```

Dockerイメージのビルド:
Dockerfileを使用して、Dockerイメージをビルドします。以下のコマンドを実行します。

```
docker build -t my-golang-app .
```

コンテナの起動:
Dockerイメージからコンテナを起動します。以下のコマンドを実行します。

```
docker run -p 8080:8080 my-golang-app
```

これにより、GolangのREST APIがDockerコンテナ内で実行されます。

Curlでのエンドポイントへのアクセス:
REST APIにアクセスするためには、Curlを使用します。以下のエンドポイントを使用して、各APIにアクセスできます。
- 買い物リストの取得(GET): http://localhost:8080/shopping
- 新しいアイテムの追加(POST): http://localhost:8080/shopping
- アイテムの更新(PUT): http://localhost:8080/shopping/:id
- アイテムの削除(DELETE): http://localhost:8080/shopping/:id
注意: :idは実際のアイテムのIDに置き換えてください。

例えば、買い物リストの取得(GET)の場合、以下のコマンドを実行します。

注意: :idは実際のアイテムのIDに置き換えてください。

例えば、買い物リストの取得(GET)の場合、以下のコマンドを実行します。

```
curl http://localhost:8080/shopping
```

これで、GolangのREST APIがDockerコンテナ内で実行され、指定したエンドポイントにアクセスできるようになります。