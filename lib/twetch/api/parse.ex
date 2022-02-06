defmodule Twetch.API.Parse do
  @moduledoc """
  A parser for handling Twetch API responses.
  """

  @doc """
  Parse Twetch payees route response.
  """
  def payees(%{"invoice" => invoie, "payees" => payees}) do
    {:ok, %{invoice: invoie, payees: Enum.map(payees, &parse_payee/1)}}
  end

  defp parse_payee(%{"to" => to, "currency" => "BSV", "amount" => amount}) do
    %{address: to, sats: trunc(amount * 100_000_000)}
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
