defmodule Twetch.UTXO do
  @moduledoc """
  A module for getting your Twetch UTXOs.
  """
  alias BSV.{Address, Contract, PubKey, Script, UTXO}
  alias Twetch.Api

  @doc """
  Get Twetch account UTXOs.
  """
  @spec fetch(PubKey.t()) :: {:ok, list(UTXO.t())} | {:error, any()}
  def fetch(pubkey) do
    str_pubkey = PubKey.to_binary(pubkey, encoding: :hex)
    address = Address.from_pubkey(pubkey)

    with {:ok, raw_utxos} <- Api.get_utxos(str_pubkey) do
      {:ok, Enum.map(raw_utxos, &to_utxo(&1, address))}
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
