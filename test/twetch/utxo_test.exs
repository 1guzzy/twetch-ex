defmodule Twetch.UTXOTest do
  use ExUnit.Case

  alias Twetch.UTXO

  describe "fetch/0" do
    setup do
      base64_ext_key =
        "A+2y713mUHU17yQlTCZLryMuP7SsYt3yZrivquVgrjdy1oCLJDHnrsLvoKWZF9wa6VGpCtuP1oPO0NVtLR1KYA=="

      Application.put_env(:twetch, :base64_ext_key, base64_ext_key)
    end

    test "successfully gets utxos" do
      utxos = [
        %{
          "path" => "1",
          "satoshis" => "1830713",
          "txid" => "1621958979c3f2bd1c51648f9f5ca2527450bd7fc083b36aba7d5f81ffc9f516",
          "vout" => 4
        }
      ]

      utxo_body = JSON.encode!(%{"utxos" => utxos})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: utxo_body}}
      end)

      assert {:ok, ^utxos} = UTXO.fetch()
    end

    test "handles no utxos result" do
      utxo_body = JSON.encode!(%{"utxos" => []})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: utxo_body}}
      end)

      assert {:error, "No UTXOs found"} = UTXO.fetch()
    end

    test "handles utxo error response" do
      error = "Error fetching wallet"
      utxo_body = JSON.encode!(%{"error" => error})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: utxo_body}}
      end)

      assert {:error, ^error} = UTXO.fetch()
    end

    test "handles utxo bad response" do
      utxo_body = JSON.encode!("<><>")

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: utxo_body}}
      end)

      assert {:error, "Unable to parse Twetch utxos response"} = UTXO.fetch()
    end
  end
end
