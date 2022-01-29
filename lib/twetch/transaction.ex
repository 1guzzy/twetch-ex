defmodule Twetch.Transaction do
  @moduledoc """
  A module for building valid Twetch transactions.
  """
  alias BSV.{UTXO, Script}
  alias Twetch.{BProtocol, MAPProtocol, AIPProtocol}

  def build_op_return_args(content) do
    script =
      %Script{}
      |> BProtocol.build(content)
      |> protocol_boundary()
      |> MAPProtocol.build(invoice: "#\{invoice}")
      |> protocol_boundary()
      |> AIPProtocol.build(nil, nil)

    script.chunks
  end

  # def build(content, utxo_params, outputs) do
  # UTXO.from_params!() |> IO.inspect()
  # end

  def build_op_return(content, privkey, address) do
    %Script{}
    |> Script.push(:OP_FALSE)
    |> Script.push(:OP_RETURN)
    |> BProtocol.build(content)
    |> protocol_boundary()
    |> MAPProtocol.build()
    |> protocol_boundary()
    |> AIPProtocol.build(privkey, address)
  end

  defp protocol_boundary(op_return), do: Script.push(op_return, "|")
end
