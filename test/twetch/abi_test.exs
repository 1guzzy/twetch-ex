defmodule Twetch.ABITest do
  use ExUnit.Case

  alias Twetch.ABI
  alias BSV.{Address, KeyPair}

  @bProtocolPrefix "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut"
  @mapProtocolPrefix "1PuQa7K62MiKCtssSLKy1kh56WWU7MtUR5"
  @aipProtocolPrefix "15PciHG22SNLQJXMoSUaWVi7WSqc7hCfva"

  doctest ABI

  describe "build_template/2" do
    test "builds ABI post template" do
      bPrefix = @bProtocolPrefix
      mapPrefix = @mapProtocolPrefix
      aipPrefix = @aipProtocolPrefix
      content = "Hello Twetchverse"

      assert [
               ^bPrefix,
               ^content,
               "text/plain",
               "text",
               "no_file.txt",
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
             ] = ABI.build_template("twetch/post@0.0.1", content)
    end
  end

  describe "build/2" do
    test "builds ABI post" do
      bPrefix = @bProtocolPrefix
      mapPrefix = @mapProtocolPrefix
      aipPrefix = @aipProtocolPrefix
      content = "Hello Twetchverse"
      invoice = "invoice"
      %{privkey: privkey, pubkey: pubkey} = KeyPair.new()
      address = pubkey |> Address.from_pubkey() |> Address.to_string()

      params = %{
        content: content,
        invoice: invoice,
        privkey: privkey,
        address: address
      }

      assert [
               ^bPrefix,
               ^content,
               "text/plain",
               "text",
               "no_file.txt",
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
               ^invoice,
               "|",
               ^aipPrefix,
               "BITCOIN_ECDSA",
               ^address,
               _signature
             ] = ABI.build("twetch/post@0.0.1", params)
    end
  end
end
