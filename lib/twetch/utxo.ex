defmodule Twetch.UTXO do
  @moduledoc """
  A module for getting your Twetch UTXOs.
  """
  alias BSV.{Address, Contract, ExtKey, PubKey, Script, UTXO}
  alias Twetch.Api

  @doc """
  Get Twetch account UTXOs.
  """
  @spec fetch() :: {:ok, list(UTXO.t())} | {:error, any()}
  def fetch() do
    with {:ok, pubkey} <- get_pubkey(),
         str_pubkey <- PubKey.to_binary(pubkey, encoding: :hex),
         {:ok, raw_utxos} <- Api.get_utxos(str_pubkey) do
      address = Address.from_pubkey(pubkey)

      {:ok, Enum.map(raw_utxos, &to_utxo(&1, address))}
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

  defp to_utxo(%{"txid" => txid, "vout" => vout, "satoshis" => sats}, address) do
    script =
      sats
      |> Contract.P2PKH.lock(%{address: address})
      |> Contract.to_script()
      |> Script.to_binary(encoding: :hex)

    UTXO.from_params!(%{"txid" => txid, "vout" => vout, "satoshis" => sats, "script" => script})
  end
end
