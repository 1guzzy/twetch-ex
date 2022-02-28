defmodule Twetch.UTXO do
  @moduledoc """
  A module for getting your Twetch UTXOs and turning them into spendable transaction inputs.
  """
  alias BSV.{Contract, PubKey, Script, UTXO}
  alias Twetch.{Account, API}

  @doc """
  Get Twetch account UTXOs for the given bot.
  """
  @spec build_inputs(atom()) :: {:ok, list(UTXO.t())} | {:error, any()}
  def build_inputs(bot) do
    with {:ok, %{pubkey: pubkey}} <- Account.get(bot),
         str_pubkey <- PubKey.to_binary(pubkey, encoding: :hex),
         {:ok, utxos} <- API.get_utxos(str_pubkey) do
      {:ok, Enum.map(utxos, &to_input(bot, &1))}
    end
  end

  # probably an easier way to do this
  defp to_input(bot, %{"txid" => txid, "vout" => vout, "satoshis" => str_sats, "path" => path}) do
    {sats, _truncate} = Integer.parse(str_sats)
    {:ok, account} = Account.get(bot, path)
    script = build_input_script(sats, account.address)

    %{"txid" => txid, "vout" => vout, "satoshis" => sats, "script" => script}
    |> UTXO.from_params!()
    |> Contract.P2PKH.unlock(%{keypair: account})
  end

  defp build_input_script(sats, address) do
    sats
    |> Contract.P2PKH.lock(%{address: address})
    |> Contract.to_script()
    |> Script.to_binary(encoding: :hex)
  end
end
