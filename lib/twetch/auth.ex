defmodule Twetch.Challenge do
  @moduledoc """
  A module for completing Twetch authentication challenge.
  """
  alias BSV.{Address, ExtKey, Message}

  @twetch_auth_api "https://auth.twetch.app/api/v1"

  @doc """
  Complete Twetch developer challenge to get bearer token. This function is
  meant to be a one time convenience function for getting a Twetch bearer_token.
  """
  def get_bearer_token(base64_ext_key, path \\ "m/0/0") do
    with {:ok, privkey, address} <- get_privkey_and_address(base64_ext_key, path),
         {:ok, message} <- get_challenge(),
         {:ok, bearer_token} <- complete_challenge(privkey, address, message) do
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

  defp get_challenge() do
    url = @twetch_auth_api <> "/challenge"

    case HTTPoison.get(url) do
      {:ok, response} ->
        response.body
        |> JSON.decode()
        |> parse_message()

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_message({:ok, %{"message" => message}}), do: {:ok, message}
  defp parse_message(_), do: {:error, "Unable to parse Twetch challenge message"}

  defp complete_challenge(privkey, address, message) do
    url = @twetch_auth_api <> "/authenticate"
    headers = [{"content-type", "application/json"}]

    body =
      JSON.encode!(%{
        address: address,
        message: message,
        signature: Message.sign(message, privkey)
      })

    case HTTPoison.post(url, body, headers) do
      {:ok, response} ->
        response.body
        |> JSON.decode()
        |> parse_token()

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_token({:ok, %{"token" => token}}), do: {:ok, token}
  defp parse_token({:ok, %{"error" => error}}), do: {:error, error}
  defp parse_token(_), do: {:error, "Unable to parse Twetch bearer token response"}
end
