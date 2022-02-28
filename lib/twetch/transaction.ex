defmodule Twetch.Transaction do
  @moduledoc """
  A module for building valid Twetch transactions.
  """
  alias BSV.{Address, TxBuilder, Tx}
  alias BSV.Contract.{P2PKH, OpReturn}
  alias Twetch.Account

  def build(bot, args, inputs, payees) do
    {:ok, %{address: address}} = Account.get(bot)

    tx =
      %TxBuilder{inputs: inputs, outputs: outputs(args, payees)}
      |> TxBuilder.sort()
      |> TxBuilder.change_to(address)
      |> TxBuilder.to_tx()
      |> Tx.to_binary(encoding: :hex)

    {:ok, tx}
  end

  defp outputs(args, payees) do
    [
      OpReturn.lock(0, %{data: args})
      | Enum.map(
          payees,
          &P2PKH.lock(&1.sats, %{address: Address.from_string!(&1.address)})
        )
    ]
  end
end
