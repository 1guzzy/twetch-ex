defmodule Twetch.UTXO do
  @moduledoc """
  A module for getting your Twetch UTXOs.
  """
  alias BSV.{ExtKey, PubKey}
  alias Twetch.Api

  @doc """
  Get Twetch account UTXOs.

  TODO this module needs updated since api refactor
  """
  def fetch() do
    with {:ok, pubkey} <- get_pubkey(),
         {:ok, utxos} <- Api.get_utxos(pubkey) do
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
end
