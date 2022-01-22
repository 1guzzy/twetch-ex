defmodule Twetch.UTXO do
  @moduledoc """
  A module for getting your Twetch UTXOs.
  """
  alias BSV.{ExtKey, PubKey}

  @twetch_utxo_url "https://metasync.twetch.app/wallet/utxo"

  @doc """
  Get Twetch account UTXOs.
  """
  def fetch() do
    with {:ok, pubkey} <- get_pubkey(),
         {:ok, utxos} <- get_utxos(pubkey) do
      {:ok, utxos}
    end
  end

  defp get_pubkey() do
    ext_key =
      :twetch
      |> Application.get_env(:base64_ext_key)
      |> ExtKey.from_seed(encoding: :base64)

    case ext_key do
      {:ok, key} ->
        %{pubkey: pubkey} = ExtKey.derive(key, "m/0/0")

        {:ok, PubKey.to_binary(pubkey, encoding: :hex)}

      {:error, _error} ->
        {:error, "Unable to decode seed; Expecting base64 format"}
    end
  end

  defp get_utxos(pubkey) do
    headers = [{"content-type", "application/json"}]

    body = JSON.encode!(%{pubkey: pubkey, amount: 1})

    case HTTPoison.post(@twetch_utxo_url, body, headers) do
      {:ok, response} ->
        response.body
        |> JSON.decode()
        |> parse_utxos()

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_utxos({:ok, %{"utxos" => []}}), do: {:error, "No UTXOs found"}
  defp parse_utxos({:ok, %{"utxos" => utxos}}), do: {:ok, utxos}
  defp parse_utxos({:ok, %{"error" => error}}), do: {:error, error}
  defp parse_utxos(_), do: {:error, "Unable to parse Twetch utxos response"}
end
