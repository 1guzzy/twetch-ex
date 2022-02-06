defmodule Twetch.ABI.AIPProtocolTest do
  use ExUnit.Case

  alias Twetch.ABI.AIPProtocol
  alias BSV.{Address, Hash, Message, KeyPair}

  @aipProtocolPrefix "15PciHG22SNLQJXMoSUaWVi7WSqc7hCfva"

  doctest AIPProtocol

  describe "build/3" do
    test "builds map protocol of twetch transaction op return" do
      %{privkey: privkey, pubkey: pubkey} = KeyPair.new()
      address = Address.from_pubkey(pubkey)
      str_address = Address.to_string(address)

      action = Enum.map(0..30, &"TEST-#{&1}")

      hash =
        action
        |> Enum.slice(0..25)
        |> Enum.join("")
        |> Hash.sha256(encoding: :hex)

      assert [@aipProtocolPrefix, "BITCOIN_ECDSA", ^str_address, signature] =
               action
               |> AIPProtocol.build(privkey, address)
               |> Enum.slice(-4..-1)

      assert Message.verify(signature, hash, pubkey)
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
