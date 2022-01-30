defmodule Twetch.ABI do
  @moduledoc """
  A module for constructing Twetch actions based on Twetch's Application Binary Interface schemas

  This module does not fully implement the Twetch ABI.
  """
  alias Twetch.ABI.{BProtocol, MAPProtocol, AIPProtocol}

  @doc """
  Build ABI template for Twetch post action.
  """
  def build_template("twetch/post@0.0.1", content) do
    BProtocol.build(content)
    |> protocol_boundary()
    |> MAPProtocol.build(invoice: "#\{invoice}", type: "post")
    |> protocol_boundary()
    |> AIPProtocol.build()
  end

  @doc """
  Build ABI for Twetch post action.
  """
  def build("twetch/post@0.0.1", %{
        content: content,
        invoice: invoice,
        privkey: privkey,
        address: address
      }) do
    BProtocol.build(content)
    |> protocol_boundary()
    |> MAPProtocol.build(invoice: invoice, type: "post")
    |> protocol_boundary()
    |> AIPProtocol.build(privkey, address)
  end

  def build(_action, _params), do: {:error, :action_not_implemented}

  defp protocol_boundary(list), do: list ++ ["|"]
end
