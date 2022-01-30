defmodule Twetch.ABI.MAPProtocol do
  @moduledoc """
  A module for building the MAP protocol of Twetch ABI.
  """
  @mapProtocolPrefix "1PuQa7K62MiKCtssSLKy1kh56WWU7MtUR5"

  @doc """
  Appends the MAP protocol to the given action.
  """
  def build(action, opts \\ []) do
    action ++
      [
        @mapProtocolPrefix,
        "SET",
        "twdata_json",
        get_field(:twdata_json, opts),
        "url",
        get_field(:url, opts),
        "comment",
        get_field(:comment, opts),
        "mb_user",
        get_field(:mb_user, opts),
        "reply",
        get_field(:reply, opts),
        "type",
        get_field(:type, opts),
        "timestamp",
        get_field(:timestamp, opts),
        "app",
        "twetch",
        "invoice",
        get_field(:invoice, opts)
      ]
  end

  defp get_field(key, opts) do
    case Keyword.get(opts, key) do
      nil -> "null"
      value -> value
    end
  end
end
