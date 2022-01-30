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
      sats = "1830713"
      vout = 4

      utxo_body =
        Jason.encode!(%{
          "utxos" => [
            %{
              "path" => "1",
              "satoshis" => sats,
              "txid" => "1621958979c3f2bd1c51648f9f5ca2527450bd7fc083b36aba7d5f81ffc9f516",
              "vout" => vout
            }
          ]
        })

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: utxo_body}}
      end)

      assert {:ok, [utxo]} = UTXO.fetch()
      assert %BSV.UTXO{outpoint: %{vout: ^vout}, txout: %{satoshis: ^sats}} = utxo
    end
  end
end
