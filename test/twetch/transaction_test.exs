defmodule Twetch.TransactionTest do
  use ExUnit.Case

  alias Twetch.Transaction
  alias BSV.Tx

  import Support.TestConfig

  doctest Transaction

  describe "build/4" do
    setup do
      mock_app_config()
    end

    test "builds transaction" do
      content = "Hello Twetchverse"
      action = "twetch/post@0.0.1"

      payees = %{
        invoice: "8da29a25-906f-4e79-a45d-15a3555769a5",
        payees: [
          %{address: "1Gj9Ss4PE6bSQUwWUVx8LvgxnD4mpQxQMA", sats: 19165},
          %{address: "13sxDC5J183161yr4HponctFedE2z7jiGA", sats: 2129}
        ]
      }

      inputs = inputs()

      assert {:ok, %Tx{inputs: _inputs, outputs: outputs}} =
               Transaction.build(action, inputs, payees, content)

      assert length(inputs) == 1
      assert length(outputs) == 4
    end
  end

  defp inputs() do
    [
      %BSV.Contract{
        ctx: nil,
        mfa:
          {BSV.Contract.P2PKH, :unlocking_script,
           [
             %{
               keypair: %{
                 address: %BSV.Address{
                   pubkey_hash:
                     <<155, 232, 124, 199, 213, 9, 84, 235, 183, 244, 150, 55, 49, 155, 152, 3,
                       72, 100, 236, 250>>
                 },
                 privkey: %BSV.PrivKey{
                   compressed: true,
                   d:
                     <<117, 50, 1, 7, 150, 121, 87, 87, 123, 183, 47, 159, 205, 75, 162, 0, 104,
                       112, 99, 215, 174, 115, 144, 237, 119, 32, 53, 238, 136, 22, 194, 58>>
                 },
                 pubkey: %BSV.PubKey{
                   compressed: true,
                   point: %Curvy.Point{
                     x:
                       84_074_819_617_297_360_037_784_527_403_983_588_432_082_143_519_544_548_970_640_332_004_658_690_225_544,
                     y:
                       22_034_076_043_129_515_429_879_151_551_280_227_226_709_781_224_779_910_855_401_771_191_042_534_182_339
                   }
                 }
               }
             }
           ]},
        opts: [],
        script: %BSV.Script{chunks: [], coinbase: nil},
        subject: %BSV.UTXO{
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
                <<155, 232, 124, 199, 213, 9, 84, 235, 183, 244, 150, 55, 49, 155, 152, 3, 72,
                  100, 236, 250>>,
                :OP_EQUALVERIFY,
                :OP_CHECKSIG
              ],
              coinbase: nil
            }
          }
        }
      }
    ]
  end
end
