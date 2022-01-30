defmodule Twetch.TransactionTest do
  use ExUnit.Case

  alias Twetch.Transaction
  alias BSV.{Address, KeyPair, Script}
  doctest Transaction

  describe "build_op_return/3" do
    test "builds post op return" do
      content = "Hello Twetchverse"
      invoice = "invoice"
      action = "twetch/post@0.0.1"

      %{privkey: privkey, pubkey: pubkey} = KeyPair.new()
      address = pubkey |> Address.from_pubkey() |> Address.to_string()

      params = %{
        content: content,
        invoice: invoice,
        privkey: privkey,
        address: address
      }

      assert %Script{chunks: [:OP_FALSE, :OP_RETURN | tail]} =
               Transaction.build_op_return(action, params)

      assert length(tail) == 31
    end
  end
end
