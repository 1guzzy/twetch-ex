defmodule Twetch.Account do
  @moduledoc """
  Twetch account interface.
  """
  alias BSV.{Address, ExtKey}

  @doc """
  Get Twetch account key pair & address.
  """
  def get(path \\ "m/0/0") do
    ext_key =
      :twetch
      |> Application.get_env(:base64_ext_key)
      |> ExtKey.from_seed(encoding: :base64)

    case ext_key do
      {:ok, key} ->
        %{privkey: privkey, pubkey: pubkey} = ExtKey.derive(key, path)
        address = Address.from_pubkey(pubkey)

        {:ok, %{privkey: privkey, pubkey: pubkey, address: address}}

      {:error, _error} ->
        {:error, "Unable to decode seed; Expecting base64 format"}
    end
  end
end
