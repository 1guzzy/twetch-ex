defmodule Twetch.MAPProtocolTest do
  use ExUnit.Case

  alias Twetch.MAPProtocol
  alias BSV.Script

  @mapProtocolPrefix "1PuQa7K62MiKCtssSLKy1kh56WWU7MtUR5"

  describe "build/2" do
    test "builds map protocol of twetch transaction with nulls" do
      protocol_prefix = @mapProtocolPrefix

      assert %Script{
               chunks: [
                 ^protocol_prefix,
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
                 "null"
               ]
             } = MAPProtocol.build(%Script{})
    end

    test "builds map protocol of twetch transaction with opts values" do
      protocol_prefix = @mapProtocolPrefix
      tw_data_json = "tw_data_json"
      url = "url"
      comment = "comment"
      mb_user = "mb_user"
      reply = "reply"
      timestamp = "timestamp"
      invoice = "invoice"

      opts = [
        tw_data_json: tw_data_json,
        url: url,
        comment: comment,
        mb_user: mb_user,
        reply: reply,
        timestamp: timestamp,
        invoice: invoice
      ]

      assert %Script{
               chunks: [
                 ^protocol_prefix,
                 "SET",
                 "tw_data_json",
                 ^tw_data_json,
                 "url",
                 ^url,
                 "comment",
                 ^comment,
                 "mb_user",
                 ^mb_user,
                 "reply",
                 ^reply,
                 "type",
                 "post",
                 "timestamp",
                 ^timestamp,
                 "app",
                 "twetch",
                 "invoice",
                 ^invoice
               ]
             } = MAPProtocol.build(%Script{}, opts)
    end
  end
end
