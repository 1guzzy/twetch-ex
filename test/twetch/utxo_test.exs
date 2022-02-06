defmodule Twetch.UTXOTest do
  use ExUnit.Case

  alias Twetch.UTXO

  import Support.TestConfig

  describe "build_inputs/0" do
    test "successfully gets inputs" do
      mock_app_config()

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

      assert {:ok,
              [%BSV.Contract{subject: %{outpoint: %{vout: ^vout}, txout: %{satoshis: 1_830_713}}}]} =
               UTXO.build_inputs()
    end
  end
end
