defmodule Twetch.Challenge do
  @moduledoc """
  A module for completing Twetch authentication challenge.
  """
  alias BSV.{Address, ExtKey, Message}
  alias Twetch.API

  @doc """
  Complete Twetch developer challenge to get bearer token. This function is
  meant to be a one time convenience function for getting a Twetch bearer_token.
  """
  def get_bearer_token(base64_ext_key, path \\ "m/0/0") do
    with {:ok, privkey, address} <- get_privkey_and_address(base64_ext_key, path),
         {:ok, message} <- API.get_challenge(),
         signature <- Message.sign(message, privkey),
         {:ok, bearer_token} <- API.get_bearer_token(address, message, signature) do
      {:ok, bearer_token, address}
    end
  end

  defp get_privkey_and_address(base64_ext_key, path) do
    ext_key = ExtKey.from_seed(base64_ext_key, encoding: :base64)

    case ext_key do
      {:ok, key} ->
        %{privkey: privkey, pubkey: pubkey} = ExtKey.derive(key, path)

        address =
          pubkey
          |> Address.from_pubkey()
          |> Address.to_string()

        {:ok, privkey, address}

      {:error, _error} ->
        {:error, "Unable to decode seed; Expecting base64 format"}
    end
  end
end
