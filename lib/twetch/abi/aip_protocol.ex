defmodule Twetch.ABI.AIPProtocol do
  @moduledoc """
  A module for building the AIP protocol of the Twetch ABI.
  """
  alias BSV.{Address, Message, Hash}

  @aipProtocolPrefix "15PciHG22SNLQJXMoSUaWVi7WSqc7hCfva"

  @doc """
  Appends the AIP protocol template to the given action.
  """
  def build(action) do
    append_fields(action, "#\{myAddress}", "#\{mySignature}")
  end

  @doc """
  Appends the AIP protocol to the given action.
  """
  def build(action, privkey, address) do
    str_address = Address.to_string(address)

    signature =
      action
      |> Enum.slice(0..25)
      |> Enum.join("")
      |> Hash.sha256(encoding: :hex)
      |> Message.sign(privkey, encoding: :base64)

    append_fields(action, str_address, signature)
  end

  defp append_fields(action, address, signature) do
    action ++ [@aipProtocolPrefix, "BITCOIN_ECDSA", address, signature]
  end
end
