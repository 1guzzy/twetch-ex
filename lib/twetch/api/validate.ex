defmodule Twetch.API.Validate do
  @moduledoc """
  Validate Twetch API responses.
  """
  alias Twetch.API.Error

  @doc """
  Validate Twetch payees route response.
  """
  def payees(%{"invoice" => _invoie, "payees" => payees, "errors" => []}), do: check_payee(payees)
  def payees(%{"errors" => errors}), do: {:error, %Error{message: List.to_string(errors)}}
  def payees(_), do: {:error, unexpected_error("payees")}

  defp check_payee([]), do: {:error, %Error{message: "No payees"}}

  defp check_payee(payees) do
    if Enum.all?(payees, &payee/1) do
      :ok
    else
      {:error, %Error{message: "Unexpected payee format"}}
    end
  end

  defp payee(%{"to" => _to, "currency" => "BSV", "amount" => _amount}), do: true
  defp payee(_), do: false

  @doc """
  Validate Twetch utxos route response.
  """
  def utxos(%{"utxos" => []}), do: {:error, %Error{message: "No UTXOs found"}}
  def utxos(%{"error" => error}), do: {:error, %Error{message: error}}
  def utxos(%{"utxos" => _utxos}), do: :ok
  def utxos(_), do: {:error, unexpected_error("utxos")}

  @doc """
  Validate Twetch publish response.
  """
  def publish(%{"errors" => [], "published" => true, "broadcasted" => true}), do: :ok
  def publish(%{"errors" => errors}), do: {:error, %Error{message: List.to_string(errors)}}
  def publish(_), do: {:error, unexpected_error("publish")}

  @doc """
  Validate Twetch authentication challenge route response.
  """
  def challenge(%{"message" => _message}), do: :ok
  def challenge(_), do: {:error, unexpected_error("authentication challenge")}

  @doc """
  Validate Twetch bearer token route response.
  """
  def bearer_token(%{"token" => _token}), do: :ok
  def bearer_token(%{"error" => error}), do: {:error, %Error{message: error}}
  def bearer_token(_), do: {:error, unexpected_error("bearer token")}

  defp unexpected_error(type), do: %Error{message: "Unexpected Twetch #{type} response"}
end
