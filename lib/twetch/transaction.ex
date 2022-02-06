defmodule Twetch.Transaction do
  @moduledoc """
  A module for building valid Twetch transactions.
  """
  alias BSV.{Address, TxBuilder, KeyPair, Tx}
  alias BSV.Contract.{P2PKH, OpReturn}
  alias Twetch.ABI

  def build(
        action,
        %{privkey: privkey, address: address},
        utxos,
        %{invoice: invoice, payees: payees},
        content
      ) do
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

    inputs = Enum.map(utxos, &P2PKH.unlock(&1, %{keypair: KeyPair.from_privkey(privkey)}))

    tx =
      %TxBuilder{inputs: inputs, outputs: outputs}
      |> TxBuilder.sort()
      |> TxBuilder.change_to(address)
      |> TxBuilder.to_tx()

    {:ok, tx}
  end

  def to_hex(tx), do: Tx.to_binary(tx, encoding: :hex)
end
