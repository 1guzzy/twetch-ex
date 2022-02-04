defmodule Twetch.API.Validate do
  @moduledoc """
  Validate Twetch API responses.
  """
  alias Twetch.API.Error

  @doc """
  Validate Twetch payees route response.
  """
  def payees(%{"invoice" => _invoie, "payees" => _payees, "errors" => []}), do: :ok
  def payees(%{"errors" => errors}), do: {:error, %Error{message: List.to_string(errors)}}
  def payees(_), do: {:error, unexpected_error("payees")}

  @doc """
  Validate Twetch utxos route response.
  """
  def utxos(%{"utxos" => []}), do: {:error, %Error{message: "No UTXOs found"}}
  def utxos(%{"error" => error}), do: {:error, %Error{message: error}}
  def utxos(%{"utxos" => _utxos}), do: :ok
  def utxos(_), do: {:error, unexpected_error("utxos")}

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
