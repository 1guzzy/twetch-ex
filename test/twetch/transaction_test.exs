defmodule Twetch.TransactionTest do
  use ExUnit.Case

  alias Twetch.Transaction
  alias BSV.{Address, KeyPair, Script}

  @bProtocolPrefix "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut"
  @mapProtocolPrefix "1PuQa7K62MiKCtssSLKy1kh56WWU7MtUR5"
  @aipProtocolPrefix "15PciHG22SNLQJXMoSUaWVi7WSqc7hCfva"

  doctest Transaction

  describe "build_op_return_args/1" do
    test "builds post op return args" do
      bPrefix = @bProtocolPrefix
      mapPrefix = @mapProtocolPrefix
      aipPrefix = @aipProtocolPrefix
      content = "Hello Twetchverse"

      assert [
               ^bPrefix,
               "Hello Twetchverse",
               "text/plain",
               "text",
               "FILENAME?",
               "|",
               ^mapPrefix,
               "SET",
               "tw_data_json",
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
             ] = Transaction.build_op_return_args(content)
    end
  end

  describe "build_op_return/3" do
    test "builds post op return" do
      bPrefix = @bProtocolPrefix
      mapPrefix = @mapProtocolPrefix
      aipPrefix = @aipProtocolPrefix
      content = "Hello Twetchverse"
      %{privkey: privkey, pubkey: pubkey} = KeyPair.new()
      address = pubkey |> Address.from_pubkey() |> Address.to_string()

      assert %Script{
               chunks: [
                 :OP_FALSE,
                 :OP_RETURN,
                 ^bPrefix,
                 ^content,
                 "text/plain",
                 "text",
                 "FILENAME?",
                 "|",
                 ^mapPrefix,
                 "SET",
                 "tw_data_json",
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
                 "null",
                 "|",
                 ^aipPrefix,
                 "BITCOIN_ECDSA",
                 ^address,
                 _signature
               ]
             } = Transaction.build_op_return(content, privkey, address)
    end
  end
end
