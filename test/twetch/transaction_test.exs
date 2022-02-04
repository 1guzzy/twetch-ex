defmodule Twetch.TransactionTest do
  use ExUnit.Case

  alias Twetch.Transaction
  alias BSV.{Address, KeyPair, Script}

  doctest Transaction

  describe "build/5" do
    test "builds transaction" do
      content = "Hello Twetchverse"
      action = "twetch/post@0.0.1"

      %{privkey: privkey, pubkey: pubkey} = KeyPair.new()
      address = pubkey |> Address.from_pubkey()

      account = %{
        privkey: privkey,
        address: address
      }

      payees = %{invoice: "invoice"}
      utxos = []

      assert %Script{chunks: [:OP_FALSE, :OP_RETURN | tail]} =
               Transaction.build(action, account, utxos, payees, content)

      assert length(tail) == 31
    end
  end
end
