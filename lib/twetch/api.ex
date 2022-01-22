defmodule Twetch.Api do
  @moduledoc """
  An interface to Twetch API.
  """
  @twetch_api "https://api.twetch.app/v1"

  @doc """
  Get payee and invoice information for the given Twetch post.
  """
  def get_payees(action, args) do
    url = @twetch_api <> "/payees"

    body =
      JSON.encode!(%{
        action: action,
        args: args,
        client_identifier: get_env(:client_id)
      })

    with {:ok, response} <- make_request(url, body),
         {:ok, payees} <- parse_payees(response) do
      {:ok, payees}
    end
  end

  defp make_request(url, body) do
    with {:ok, response} <- HTTPoison.post(url, body, headers()),
         {:ok, decoded_response} <- JSON.decode(response.body),
         :ok <- check_errors(decoded_response) do
      {:ok, decoded_response}
    else
      {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
      {:error, {:unexpected_token, _}} -> {:error, "Unable to parse json"}
      {:error, error} -> {:error, error}
    end
  end

  defp headers() do
    [{"content-type", "application/json"}, {"authorization", "Bearer #{get_env(:token)}"}]
  end

  defp get_env(key) do
    :twetch
    |> Application.get_env(:config)
    |> Keyword.get(key)
  end

  defp check_errors(%{"errors" => []}), do: :ok
  defp check_errors(%{"errors" => errors}), do: {:error, errors}
  defp check_errors(_), do: :ok

  defp parse_payees(%{"invoice" => invoie, "payees" => payees}) do
    {:ok, %{invoice: invoie, payees: payees}}
  end

  defp parse_payees(_), do: {:error, "No payees in response"}
end
