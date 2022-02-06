defmodule Twetch.TransactionTest do
  use ExUnit.Case

  alias Twetch.Transaction
  alias BSV.{Address, KeyPair, Tx}

  doctest Transaction

  describe "build/5" do
    setup do
      base64_ext_key =
        "A+2y713mUHU17yQlTCZLryMuP7SsYt3yZrivquVgrjdy1oCLJDHnrsLvoKWZF9wa6VGpCtuP1oPO0NVtLR1KYA=="

      Application.put_env(:twetch, :base64_ext_key, base64_ext_key)
    end

    test "builds transaction" do
      content = "Hello Twetchverse"
      action = "twetch/post@0.0.1"

      %{privkey: privkey, pubkey: pubkey} = KeyPair.new()
      address = pubkey |> Address.from_pubkey()

      account = %{
        privkey: privkey,
        address: address,
        pubkey: pubkey
      }

      payees = %{
        invoice: "8da29a25-906f-4e79-a45d-15a3555769a5",
        payees: [
          %{address: "1Gj9Ss4PE6bSQUwWUVx8LvgxnD4mpQxQMA", sats: 19165},
          %{address: "13sxDC5J183161yr4HponctFedE2z7jiGA", sats: 2129}
        ]
      }

      utxos = [
        %BSV.UTXO{
          outpoint: %BSV.OutPoint{
            hash:
              <<22, 245, 201, 255, 129, 95, 125, 186, 106, 179, 131, 192, 127, 189, 80, 116, 82,
                162, 92, 159, 143, 100, 81, 28, 189, 242, 195, 121, 137, 149, 33, 22>>,
            vout: 4
          },
          txout: %BSV.TxOut{
            satoshis: 1_830_713,
            script: %BSV.Script{
              chunks: [
                :OP_DUP,
                :OP_HASH160,
                <<235, 191, 218, 67, 105, 94, 84, 211, 45, 164, 55, 137, 92, 185, 106, 48, 246,
                  211, 238, 224>>,
                :OP_EQUALVERIFY,
                :OP_CHECKSIG
              ],
              coinbase: nil
            }
          }
        }
      ]

      assert {:ok, %Tx{inputs: inputs, outputs: outputs}} =
               Transaction.build(action, account, utxos, payees, content)

      assert length(inputs) == 1
      assert length(outputs) == 4
    end
  end
end
