defmodule Twetch.Account do
  @moduledoc """
  Twetch account interface.
  """
  alias BSV.{Address, ExtKey}

  @doc """
  Get Twetch account key pair & address.
  """
  def get(path \\ "-1") do
    ext_key = ExtKey.from_seed(get_env(:base64_ext_key), encoding: :base64)

    case ext_key do
      {:ok, key} ->
        full_path = get_path(path)
        %{privkey: privkey, pubkey: pubkey} = ExtKey.derive(key, full_path)
        address = Address.from_pubkey(pubkey)

        {:ok, %{privkey: privkey, pubkey: pubkey, address: address}}

      {:error, _error} ->
        {:error, "Unable to decode seed; Expecting base64 format"}
    end
  end

  defp get_env(key), do: Application.get_env(:twetch, key)

  defp get_path("-1"), do: "m/0/0"
  defp get_path(path), do: "m/44'/0'/0'/0/" <> path
end
