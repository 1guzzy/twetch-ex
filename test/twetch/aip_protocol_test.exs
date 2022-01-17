defmodule Twetch.AIPProtocolTest do
  use ExUnit.Case

  alias Twetch.AIPProtocol
  alias BSV.{Address, Hash, Message, Script, KeyPair}

  @aipProtocolPrefix "15PciHG22SNLQJXMoSUaWVi7WSqc7hCfva"

  doctest AIPProtocol

  describe "build/3" do
    test "builds map protocol of twetch transaction op return" do
      protocol_prefix = @aipProtocolPrefix
      %{privkey: privkey, pubkey: pubkey} = KeyPair.new()
      address = pubkey |> Address.from_pubkey() |> Address.to_string()
      script = %Script{chunks: ["TEST"]}

      assert %Script{
               chunks: [
                 "TEST",
                 ^protocol_prefix,
                 "BITCOIN_ECDSA",
                 ^address,
                 signature
               ]
             } = AIPProtocol.build(script, privkey, address)

      assert Message.verify(signature, Script.to_binary(script) |> Hash.sha256(), pubkey)
    end

    test "builds map protocol args of twetch transaction" do
      protocol_prefix = @aipProtocolPrefix
      script = %Script{chunks: ["TEST"]}

      assert %Script{
               chunks: [
                 "TEST",
                 ^protocol_prefix,
                 "BITCOIN_ECDSA",
                 "#\{myAddress}",
                 "#\{mySignature}"
               ]
             } = AIPProtocol.build(script, nil, nil)
    end
  end
end
