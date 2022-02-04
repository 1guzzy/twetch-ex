defmodule Twetch.Transaction do
  @moduledoc """
  A module for building valid Twetch transactions.
  """
  alias BSV.Script
  alias Twetch.ABI

  def build(action, account, _utxos, payees, content) do
    params = %{
      privkey: account.privkey,
      address: account.address,
      content: content,
      invoice: payees.invoice
    }

    build_op_return(action, params)
  end

  defp build_op_return(action, params) do
    script =
      %Script{}
      |> Script.push(:OP_FALSE)
      |> Script.push(:OP_RETURN)

    action
    |> ABI.build(params)
    |> Enum.reduce(script, &Script.push(&2, &1))
  end
end
