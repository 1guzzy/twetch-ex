defmodule Twetch.MAPProtocol do
  @moduledoc """
  A module for building the MAP protocol of a Twetch transaction.
  """
  alias BSV.Script

  @mapProtocolPrefix "1PuQa7K62MiKCtssSLKy1kh56WWU7MtUR5"

  @doc """
  Appends the MAP protocol to the given op_return.
  """
  def build(op_return, opts \\ []) do
    op_return
    |> Script.push(@mapProtocolPrefix)
    |> Script.push("SET")
    |> set_field("tw_data_json", Keyword.get(opts, :tw_data_json))
    |> set_field("url", Keyword.get(opts, :url))
    |> set_field("comment", Keyword.get(opts, :comment))
    |> set_field("mb_user", Keyword.get(opts, :mb_user))
    |> set_field("reply", Keyword.get(opts, :reply))
    |> Script.push("type")
    |> Script.push("post")
    |> set_field("timestamp", Keyword.get(opts, :timestamp))
    |> Script.push("app")
    |> Script.push("twetch")
    |> set_field("invoice", Keyword.get(opts, :invoice))
  end

  defp set_field(script, field, nil), do: set_field(script, field, "null")

  defp set_field(script, field, value) do
    script
    |> Script.push(field)
    |> Script.push(value)
  end
end
