defmodule TwetchTest do
  use ExUnit.Case

  # alias BSV.Script
  # alias Twetch.{API, UTXO}

  doctest Twetch

  @action "twetch/post@0.0.1"

  setup do
    base64_ext_key =
      "A+2y713mUHU17yQlTCZLryMuP7SsYt3yZrivquVgrjdy1oCLJDHnrsLvoKWZF9wa6VGpCtuP1oPO0NVtLR1KYA=="

    opts = [
      client_id: "client_id",
      token: "token"
    ]

    Application.put_env(:twetch, :config, opts)
    Application.put_env(:twetch, :base64_ext_key, base64_ext_key)
  end

  # test "greets the world" do
  # bContent = "Test"
  # invoice = "9e9a2c66-4c60-4280-9c7f-32abe3fb4831"

  # payees = [
  # %{
  # "amount" => 0.00020506,
  # "currency" => "BSV",
  # "to" => "15evjiAagwaFNydP5J9Pvr1k4qpngqcZUn",
  # "types" => ["post"],
  # "user_id" => "0"
  # },
  # %{
  # "amount" => 0.00002278,
  # "currency" => "BSV",
  # "to" => "17xCBD1pVM1vE7YbnHV6cz5xgKAT1U2PkJ",
  # "types" => ["api-request"],
  # "user_id" => "13796"
  # }
  # ]

  # utxos = [
  # %BSV.UTXO{
  # outpoint: %BSV.OutPoint{
  # hash:
  # <<22, 245, 201, 255, 129, 95, 125, 186, 106, 179, 131, 192, 127, 189, 80, 116, 82,
  # 162, 92, 159, 143, 100, 81, 28, 189, 242, 195, 121, 137, 149, 33, 22>>,
  # vout: 4
  # },
  # txout: %BSV.TxOut{
  # satoshis: "1830713",
  # script: %BSV.Script{
  # chunks: [
  # :OP_DUP,
  # :OP_HASH160,
  # <<235, 191, 218, 67, 105, 94, 84, 211, 45, 164, 55, 137, 92, 185, 106, 48, 246, 211,
  # 238, 224>>,
  # :OP_EQUALVERIFY,
  # :OP_CHECKSIG
  # ],
  # coinbase: nil
  # }
  # }
  # }
  # ]

  # Mimic.expect(API, :get_payees, fn _, _ -> {:ok, %{invoice: invoice, payees: payees}} end)
  # Mimic.expect(UTXO, :fetch, fn _ -> {:ok, utxos} end)

  # assert %Script{} = Twetch.publish(@action, bContent)
  # end
end
