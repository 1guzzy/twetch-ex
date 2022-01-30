defmodule Twetch.ABI.BProtocolTest do
  use ExUnit.Case

  alias Twetch.ABI.BProtocol

  @bProtocolPrefix "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut"

  test "builds b protocol of twetch transaction op return" do
    text = "Hello Twetchverse"
    protocol_prefix = @bProtocolPrefix

    assert [^protocol_prefix, ^text, "text/plain", "text", "no_file.txt"] = BProtocol.build(text)
  end
end
