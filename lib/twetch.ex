defmodule Twetch do
  @moduledoc """
  Documentation for `Twetch`.
  """
  alias Twetch.{ABI, API, UTXO, Transaction}

  @doc """
  Publish Twetch post.
  """
  def publish(action_name, args) do
    with {:ok, action} <- ABI.new(action_name, args),
         {:ok, %{invoice: invoice, payees: payees}} <- API.get_payees(action),
         {:ok, updated_action} <- ABI.update(action, invoice),
         {:ok, inputs} <- UTXO.build_inputs(),
         {:ok, tx} <- Transaction.build(updated_action.args, inputs, payees),
         {:ok, txid} <- API.publish(action_name, tx) do
      {:ok, txid}
    end
  end
end
