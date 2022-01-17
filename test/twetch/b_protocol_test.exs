defmodule Twetch.BProtocolTest do
  use ExUnit.Case

  alias Twetch.BProtocol
  alias BSV.Script

  @bProtocolPrefix "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut"

  test "builds b protocol of twetch transaction op return" do
    text = "Hello Twetchverse"
    protocol_prefix = @bProtocolPrefix

    assert %Script{chunks: [^protocol_prefix, ^text, "text/plain", "text", "FILENAME?"]} =
             BProtocol.build(%Script{}, text)
  end
end
