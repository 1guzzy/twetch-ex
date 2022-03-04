defmodule Twetch.API do
  @moduledoc """
  An interface to Twetch API.
  """
  alias Twetch.API.{Client, Error, Validate, Parse}
  alias BSV.Tx

  @doc """
  Get payee and invoice information for the given Twetch post.
  """
  def get_payees(bot, %{action: action, args: args}) do
    body =
      Jason.encode!(%{
        action: action["name"],
        args: args,
        client_identifier: get_env(:client_id)
      })

    with {:ok, response} <- call_authenticated_endpoint(:payees, bot, body),
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
  Publish Twetch.
  """
  def publish(bot, action, tx, tweet_from_twetch) do
    body =
      Jason.encode!(%{
        broadcast: true,
        action: action,
        signed_raw_tx: tx,
        payParams: %{tweetFromTwetch: tweet_from_twetch, hideTweetFromTwetchLink: true}
      })

    with {:ok, response} <- call_authenticated_endpoint(:publish, bot, body),
         :ok <- Validate.publish(response) do
      {:ok, Tx.from_binary!(tx, encoding: :hex) |> Tx.get_txid()}
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

  defp get_env(key), do: Application.get_env(:twetch, key)

  defp call_authenticated_endpoint(endpoint, bot, params) do
    case Client.make_request(endpoint, bot, params) do
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
