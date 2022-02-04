defmodule Twetch.API do
  @moduledoc """
  An interface to Twetch API.
  """
  alias Twetch.API.{Client, Error, Validate, Parse}

  @doc """
  Get payee and invoice information for the given Twetch post.
  """
  def get_payees(action, args) do
    body =
      Jason.encode!(%{
        action: action,
        args: args,
        client_identifier: get_env(:client_id)
      })

    with {:ok, response} <- call_endpoint(:payees, body),
         :ok <- Validate.payees(response),
         {:ok, payees} <- Parse.payees(response) do
      {:ok, payees}
    end
  end

  @doc """
  Get Twetch account UTXOs.
  """
  def get_utxos(str_pubkey) do
    body = Jason.encode!(%{pubkey: str_pubkey, amount: 1})

    with {:ok, response} <- call_endpoint(:utxos, body),
         :ok <- Validate.utxos(response),
         {:ok, utxos} <- Parse.utxos(response) do
      {:ok, utxos}
    end
  end

  @doc """
  Get Twetch authentication challenge message.
  """
  def get_challenge() do
    with {:ok, response} <- call_endpoint(:challenge),
         :ok <- Validate.challenge(response),
         {:ok, challenge} <- Parse.challenge(response) do
      {:ok, challenge}
    end
  end

  @doc """
  Get Twetch bearer_token.
  """
  def get_bearer_token(address, message, signature) do
    body =
      Jason.encode!(%{
        address: address,
        message: message,
        signature: signature
      })

    with {:ok, response} <- call_endpoint(:bearer_token, body),
         :ok <- Validate.bearer_token(response),
         {:ok, token} <- Parse.bearer_token(response) do
      {:ok, token}
    end
  end

  defp get_env(key) do
    :twetch
    |> Application.get_env(:config)
    |> Keyword.get(key)
  end

  defp call_endpoint(endpoint, params \\ %{}) do
    case Client.make_request(endpoint, params) do
      {:ok, body} ->
        {:ok, body}

      {:error, %Jason.DecodeError{}} ->
        {:error, %Error{message: "Invalid json response."}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %Error{message: "HTTPoison error: #{reason}"}}

      {:error, error} ->
        {:error, error}
    end
  end
end
