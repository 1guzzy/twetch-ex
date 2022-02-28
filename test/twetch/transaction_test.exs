defmodule Twetch.TransactionTest do
  use ExUnit.Case

  alias Twetch.Transaction
  alias BSV.Tx

  import Support.TestConfig

  doctest Transaction

  describe "build/3" do
    test "builds transaction" do
      bot = mock_app_config()
      args = []
      inputs = []

      payees = [
        %{address: "1Gj9Ss4PE6bSQUwWUVx8LvgxnD4mpQxQMA", sats: 19165},
        %{address: "13sxDC5J183161yr4HponctFedE2z7jiGA", sats: 2129}
      ]

      assert {:ok, raw_tx} = Transaction.build(bot, args, inputs, payees)
      {:ok, tx} = Tx.from_binary(raw_tx, encoding: :hex)

      assert length(tx.inputs) == 0
      # would be 4 but theres no change output because there are no inputs
      assert length(tx.outputs) == 3
    end
  end
end
