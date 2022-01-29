defmodule Twetch.Api.Parse do
  @moduledoc """
  A parser for handling Twetch Api responses.
  """

  @doc """
  Parse Twetch payees route response.
  """
  def payees(%{"invoice" => invoie, "payees" => payees}) do
    {:ok, %{invoice: invoie, payees: payees}}
  end

  @doc """
  Parse Twetch utxos route response.
  """
  def utxos(%{"utxos" => utxos}), do: {:ok, utxos}

  @doc """
  Parse Twetch authentication challenge route response.
  """
  def challenge(%{"message" => message}), do: {:ok, message}

  @doc """
  Parse Twetch bearer token route response.
  """
  def bearer_token(%{"token" => token}), do: {:ok, token}
end
