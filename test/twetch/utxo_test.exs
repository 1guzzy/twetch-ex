defmodule Twetch.UTXOTest do
  use ExUnit.Case

  alias BSV.KeyPair
  alias Twetch.UTXO

  describe "fetch/0" do
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

      %{pubkey: pubkey} = KeyPair.new()

      assert {:ok, [utxo]} = UTXO.fetch(pubkey)
      assert %BSV.UTXO{outpoint: %{vout: ^vout}, txout: %{satoshis: 1_830_713}} = utxo
    end
  end
end
