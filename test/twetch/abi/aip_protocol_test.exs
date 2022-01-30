defmodule Twetch.ABI.AIPProtocolTest do
  use ExUnit.Case

  alias Twetch.ABI.AIPProtocol
  alias BSV.{Address, Hash, Message, KeyPair}

  @aipProtocolPrefix "15PciHG22SNLQJXMoSUaWVi7WSqc7hCfva"

  doctest AIPProtocol

  describe "build/3" do
    test "builds map protocol of twetch transaction op return" do
      protocol_prefix = @aipProtocolPrefix
      %{privkey: privkey, pubkey: pubkey} = KeyPair.new()
      address = pubkey |> Address.from_pubkey() |> Address.to_string()
      action = ["TEST", "ACTION"]

      assert [
               "TEST",
               "ACTION",
               ^protocol_prefix,
               "BITCOIN_ECDSA",
               ^address,
               signature
             ] = AIPProtocol.build(action, privkey, address)

      assert Message.verify(signature, List.to_string(action) |> Hash.sha256(), pubkey)
    end

    test "builds map protocol args of twetch transaction" do
      protocol_prefix = @aipProtocolPrefix
      action = ["TEST"]

      assert [
               "TEST",
               ^protocol_prefix,
               "BITCOIN_ECDSA",
               "#\{myAddress}",
               "#\{mySignature}"
             ] = AIPProtocol.build(action)
    end
  end
end
