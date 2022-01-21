defmodule Twetch.ApiTest do
  use ExUnit.Case

  alias Twetch.{Api, Transaction}

  describe "get_payees/2" do
    setup do
      opts = [
        client_id: "client_id",
        token: "token"
      ]

      Application.put_env(:twetch, :config, opts)

      %{action: "twetch/post@0.0.1", args: Transaction.build_op_return_args("Hello Twetchverse")}
    end

    test "successfully get payees", %{action: action, args: args} do
      invoice = "9e9a2c66-4c60-4280-9c7f-32abe3fb4831"

      payees = [
        %{
          "amount" => 0.00020506,
          "currency" => "BSV",
          "to" => "15evjiAagwaFNydP5J9Pvr1k4qpngqcZUn",
          "types" => ["post"],
          "user_id" => "0"
        },
        %{
          "amount" => 0.00002278,
          "currency" => "BSV",
          "to" => "17xCBD1pVM1vE7YbnHV6cz5xgKAT1U2PkJ",
          "types" => ["api-request"],
          "user_id" => "13796"
        }
      ]

      payees = %{
        "errors" => [],
        "estimate" => 0.0199997952,
        "exchangeRate" => 87.78,
        "invoice" => invoice,
        "payees" => payees
      }

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: JSON.encode!(payees)}}
      end)

      assert {:ok, %{invoice: ^invoice, payees: [_payee_1, _payee_2]}} =
               Api.get_payees(action, args)
    end

    test "handles twetch error response", %{action: action, args: args} do
      error = "Error!"
      error_body = JSON.encode!(%{"errors" => [error]})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: error_body}}
      end)

      assert {:error, [^error]} = Api.get_payees(action, args)
    end

    test "handles http error response", %{action: action, args: args} do
      error = "Error!"

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:error, %HTTPoison.Error{reason: error}}
      end)

      assert {:error, ^error} = Api.get_payees(action, args)
    end

    test "handles malformed response", %{action: action, args: args} do
      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: "[%"}}
      end)

      assert {:error, "Unable to parse json"} = Api.get_payees(action, args)
    end

    test "handles bad response", %{action: action, args: args} do
      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: JSON.encode!("")}}
      end)

      assert {:error, "No payees in response"} = Api.get_payees(action, args)
    end
  end
end
