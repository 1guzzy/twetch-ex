defmodule Twetch.BProtocol do
  @moduledoc """
  A module for building the B protocol of a Twetch transaction.
  """
  alias BSV.Script

  @bProtocolPrefix "19HxigV4QyBv3tHpQVcUEQyq1pzZVdoAut"

  @doc """
  Appends the B protocol to the given op_return.
  """
  def build(op_return, content) do
    op_return
    |> Script.push(@bProtocolPrefix)
    |> Script.push(content)
    |> Script.push("text/plain")
    |> Script.push("text")
    |> Script.push("FILENAME?")
  end
end
