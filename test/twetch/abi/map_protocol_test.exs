defmodule Twetch.ABI.MAPProtocolTest do
  use ExUnit.Case

  alias Twetch.ABI.MAPProtocol

  @mapProtocolPrefix "1PuQa7K62MiKCtssSLKy1kh56WWU7MtUR5"

  describe "build/2" do
    test "builds map protocol of twetch abi with nulls" do
      protocol_prefix = @mapProtocolPrefix

      assert [
               ^protocol_prefix,
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
               "null",
               "timestamp",
               "null",
               "app",
               "twetch",
               "invoice",
               "null"
             ] = MAPProtocol.build([])
    end

    test "builds map protocol of twetch transaction with opts values" do
      protocol_prefix = @mapProtocolPrefix
      twdata_json = "twdata_json"
      url = "url"
      comment = "comment"
      mb_user = "mb_user"
      reply = "reply"
      timestamp = "timestamp"
      invoice = "invoice"
      type = "post"

      opts = [
        twdata_json: twdata_json,
        url: url,
        comment: comment,
        mb_user: mb_user,
        reply: reply,
        timestamp: timestamp,
        invoice: invoice,
        type: type
      ]

      assert [
               ^protocol_prefix,
               "SET",
               "twdata_json",
               ^twdata_json,
               "url",
               ^url,
               "comment",
               ^comment,
               "mb_user",
               ^mb_user,
               "reply",
               ^reply,
               "type",
               ^type,
               "timestamp",
               ^timestamp,
               "app",
               "twetch",
               "invoice",
               ^invoice
             ] = MAPProtocol.build([], opts)
    end
  end
end
