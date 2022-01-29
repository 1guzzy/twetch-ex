defmodule Twetch.UTXO do
  @moduledoc """
  A module for getting your Twetch UTXOs.
  """
  alias BSV.{Address, Contract, ExtKey, PubKey, Script, UTXO}

  @twetch_utxo_url "https://metasync.twetch.app/wallet/utxo"

  @doc """
  Get Twetch account UTXOs.
  """
  @spec fetch() :: {:ok, list(UTXO.t())} | {:error, any()}
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

        {:ok, pubkey}

      {:error, _error} ->
        {:error, "Unable to decode seed; Expecting base64 format"}
    end
  end

  defp get_utxos(pubkey) do
    headers = [{"content-type", "application/json"}]

    body = JSON.encode!(%{pubkey: PubKey.to_binary(pubkey, encoding: :hex), amount: 1})

    case HTTPoison.post(@twetch_utxo_url, body, headers) do
      {:ok, response} ->
        address = Address.from_pubkey(pubkey)

        response.body
        |> JSON.decode()
        |> parse_utxos(address)

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_utxos({:ok, %{"utxos" => []}}, _address), do: {:error, "No UTXOs found"}

  defp parse_utxos({:ok, %{"utxos" => utxos}}, address) do
    {:ok, Enum.map(utxos, &to_utxo(&1, address))}
  end

  defp parse_utxos({:ok, %{"error" => error}}, _address), do: {:error, error}
  defp parse_utxos(_garbage, _address), do: {:error, "Unable to parse Twetch utxos response"}

  defp to_utxo(%{"txid" => txid, "vout" => vout, "satoshis" => sats}, address) do
    script =
      sats
      |> Contract.P2PKH.lock(%{address: address})
      |> Contract.to_script()
      |> Script.to_binary(encoding: :hex)

    UTXO.from_params!(%{"txid" => txid, "vout" => vout, "satoshis" => sats, "script" => script})
  end
end
