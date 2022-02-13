defmodule Twetch.ABITest do
  use ExUnit.Case

  alias BSV.{Address, Hash, Message}
  alias Twetch.{Account, ABI}

  import Support.TestConfig

  @bProtocolPrefix "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut"
  @mapProtocolPrefix "1PuQa7K62MiKCtssSLKy1kh56WWU7MtUR5"
  @aipProtocolPrefix "15PciHG22SNLQJXMoSUaWVi7WSqc7hCfva"

  doctest ABI

  describe "new/1" do
    test "creates new abi map for given action" do
      action = "twetch/post@0.0.1"
      bPrefix = @bProtocolPrefix
      mapPrefix = @mapProtocolPrefix
      aipPrefix = @aipProtocolPrefix
      bContent = "Hello Twetchverse"
      args = [bContent: bContent]

      assert {:ok,
              %{
                action: _action,
                args: [
                  ^bPrefix,
                  ^bContent,
                  "text/plain",
                  "text",
                  "twetch.txt",
                  "|",
                  ^mapPrefix,
                  "SET",
                  "twdata_json",
                  "null",
                  "url",
                  "null",
                  "comment",
                  "null",
                  "mb_user",
                  "null",
                  "reply",
                  "null",
                  "type",
                  "post",
                  "timestamp",
                  "null",
                  "app",
                  "twetch",
                  "invoice",
                  "#\{invoice}",
                  "|",
                  ^aipPrefix,
                  "BITCOIN_ECDSA",
                  "#\{myAddress}",
                  "#\{mySignature}"
                ]
              }} = ABI.new(action, args)
    end
  end

  describe "update/2" do
    setup do
      mock_app_config()
      {:ok, action} = ABI.new("twetch/post@0.0.1", bContent: "Hello")

      action
    end

    test "updates abi for post action", abi do
      {:ok, %{pubkey: pubkey, address: address}} = Account.get()
      str_address = Address.to_string(address)
      invoice = "10101"

      assert {:ok, %{args: args}} = ABI.update(abi, invoice)
      assert [^invoice, "|", _aip, _algo, ^str_address, signature] = Enum.slice(args, -6..-1)

      hash =
        args
        |> Enum.slice(0..25)
        |> Enum.join("")
        |> Hash.sha256(encoding: :hex)

      assert Message.verify(signature, hash, pubkey)
    end
  end
end
