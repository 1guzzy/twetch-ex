defmodule Twetch.API.Client do
  @moduledoc """
  A http client for Twetch.
  """

  @api_url "https://api.twetch.app/v1"
  @auth_url "https://auth.twetch.app/api/v1"
  @utxo_url "https://metasync.twetch.app/wallet/utxo"

  def make_request(:payees, bot, body), do: post(@api_url <> "/payees", body, auth_headers(bot))
  def make_request(:publish, bot, body), do: post(@api_url <> "/publish", body, auth_headers(bot))

  def make_request(:client_id, bot, body),
    do: post(@auth_url <> "/client-identifier", body, auth_headers(bot))

  def make_request(:utxos, body), do: post(@utxo_url, body, headers())
  def make_request(:challenge, _body), do: get(@auth_url <> "/challenge")
  def make_request(:bearer_token, body), do: post(@auth_url <> "/authenticate", body, headers())

  defp get(url) do
    case HTTPoison.get(url) do
      {:ok, response} -> Jason.decode(response.body)
      {:error, error} -> {:error, error}
    end
  end

  defp post(url, body, headers) do
    case HTTPoison.post(url, body, headers) do
      {:ok, response} -> Jason.decode(response.body)
      {:error, error} -> {:error, error}
    end
  end

  defp headers(), do: [{"content-type", "application/json"}]

  defp auth_headers(bot) do
    [
      {"content-type", "application/json"},
      {"Authorization", "Bearer #{get_env(bot)}"}
    ]
  end

  defp get_env(bot), do: Application.get_env(:twetch, bot) |> Keyword.get(:token)
end
