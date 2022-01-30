defmodule Twetch.ABI.BProtocol do
  @moduledoc """
  A module for building the B protocol of Twetch ABI.
  """
  @bProtocolPrefix "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut"

  @doc """
  Appends the B protocol to the given action.
  """
  def build(content) do
    [@bProtocolPrefix, content, "text/plain", "text", "no_file.txt"]
  end
end
