defmodule Twetch.AIPProtocol do
  @moduledoc """
  A module for building the AIP protocol of a Twetch transaction.
  """
  alias BSV.{Message, Hash, Script}

  @aipProtocolPrefix "15PciHG22SNLQJXMoSUaWVi7WSqc7hCfva"

  @doc """
  Appends the AIP protocol to the given op_return.
  """
  def build(op_return, nil, nil) do
    append_fields(op_return, "#\{myAddress}", "#\{mySignature}")
  end

  def build(op_return, privkey, address) do
    signature =
      op_return
      |> Script.to_binary()
      |> Hash.sha256()
      |> Message.sign(privkey)

    append_fields(op_return, address, signature)
  end

  defp append_fields(op_return, address, signature) do
    op_return
    |> Script.push(@aipProtocolPrefix)
    |> Script.push("BITCOIN_ECDSA")
    |> Script.push(address)
    |> Script.push(signature)
  end
end
