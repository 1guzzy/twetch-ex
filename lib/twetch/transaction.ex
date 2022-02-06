defmodule Twetch.Transaction do
  @moduledoc """
  A module for building valid Twetch transactions.
  """
  alias BSV.{Address, TxBuilder, Tx}
  alias BSV.Contract.{P2PKH, OpReturn}
  alias Twetch.{Account, ABI}

  def build(
        action,
        utxos,
        %{invoice: invoice, payees: payees},
        content
      ) do
    {:ok, %{privkey: privkey, address: address}} = Account.get()

    abi_params = %{
      privkey: privkey,
      address: address,
      content: content,
      invoice: invoice
    }

    outputs = [
      OpReturn.lock(0, %{data: ABI.build(action, abi_params)})
      | Enum.map(
          payees,
          &P2PKH.lock(&1.sats, %{address: Address.from_string!(&1.address)})
        )
    ]

    tx =
      %TxBuilder{inputs: utxos, outputs: outputs}
      |> TxBuilder.sort()
      |> TxBuilder.change_to(address)
      |> TxBuilder.to_tx()

    {:ok, tx}
  end

  def to_hex(tx), do: Tx.to_binary(tx, encoding: :hex)
end
