import subprocess
import sys
import os
import requests

def main():
    # プログラム引数の取得
    if len(sys.argv) != 3:
        print("引数の数が正しくありません。")
        return

    url = sys.argv[1]
    port = sys.argv[2]

    # @redocly/cliのインストールチェック
    try:
        subprocess.check_output(['npm', '@redocly/cli', '--version'], shell=True)
    except subprocess.CalledProcessError:
        print("@redocly/cli hasn't been installed.")
        return

    # URI文字列の生成
    uri = f"http://{url}:{port}/api-json"

    # "html"ディレクトリの作成
    os.makedirs("html", exist_ok=True)

    # GETリクエストの送信
    try:
        response = requests.get(uri)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"GETリクエストの送信中にエラーが発生しました: {e}")
        return

    with open("html/api.json", "w", encoding="utf-8") as file:
        file.write(response.text)

    # jsonからhtmlに変換
    subprocess.run(['npx', '@redocly/cli', 'build-docs', 'html/api.json', '-o', 'html/index.html'], shell=True)

if __name__ == "__main__":
    main()

