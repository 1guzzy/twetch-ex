defmodule Twetch.Transaction do
  @moduledoc """
  A module for building valid Twetch transactions.
  """
  alias BSV.Script
  alias Twetch.ABI

  @doc """
  Build op return of Twetch transaction.
  """
  def build_op_return(action, params) do
    script =
      %Script{}
      |> Script.push(:OP_FALSE)
      |> Script.push(:OP_RETURN)

    action
    |> ABI.build(params)
    |> Enum.reduce(script, &Script.push(&2, &1))
  end
end
