defmodule Twetch.APITest do
  use ExUnit.Case

  alias Twetch.API
  alias Twetch.API.Error

  import Support.TestConfig

  describe "get_payees/2" do
    setup do
      bot = mock_app_config()

      %{bot: bot, abi: %{action: %{"name" => "twetch/post@0.0.1"}, args: []}}
    end

    test "successfully get payees", %{bot: bot, abi: abi} do
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
        {:ok, %HTTPoison.Response{body: Jason.encode!(payees)}}
      end)

      assert {:ok, %{invoice: ^invoice, payees: [_payee_1, _payee_2]}} = API.get_payees(bot, abi)
    end

    test "handles twetch error response", %{bot: bot, abi: abi} do
      error_body = Jason.encode!(%{"errors" => ["err1", "err2"]})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: error_body}}
      end)

      assert {:error, %Error{message: "err1err2"}} = API.get_payees(bot, abi)
    end

    test "handles http error response", %{bot: bot, abi: abi} do
      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:error, %HTTPoison.Error{reason: "eek!"}}
      end)

      assert {:error, %Error{message: "HTTPoison error: eek!"}} = API.get_payees(bot, abi)
    end

    test "handles malformed response", %{bot: bot, abi: abi} do
      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: "[%"}}
      end)

      assert {:error, %Error{message: "Invalid json response."}} = API.get_payees(bot, abi)
    end

    test "handles bad response", %{bot: bot, abi: abi} do
      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: Jason.encode!("")}}
      end)

      assert {:error, %Error{message: "Unexpected Twetch payees response"}} =
               API.get_payees(bot, abi)
    end
  end

  describe "get_utxos/1" do
    test "successfully gets utxos" do
      str_pubkey = "str_pubkey"

      utxos = [
        %{
          "path" => "1",
          "satoshis" => "1830713",
          "txid" => "1621958979c3f2bd1c51648f9f5ca2527450bd7fc083b36aba7d5f81ffc9f516",
          "vout" => 4
        }
      ]

      utxo_body = Jason.encode!(%{"utxos" => utxos})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: utxo_body}}
      end)

      assert {:ok, ^utxos} = API.get_utxos(str_pubkey)
    end

    test "handles no utxos result" do
      str_pubkey = "str_pubkey"
      utxo_body = Jason.encode!(%{"utxos" => []})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: utxo_body}}
      end)

      assert {:error, %Error{message: "No UTXOs found"}} = API.get_utxos(str_pubkey)
    end

    test "handles utxo error response" do
      str_pubkey = "str_pubkey"
      error = "Error fetching wallet"
      utxo_body = Jason.encode!(%{"error" => error})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: utxo_body}}
      end)

      assert {:error, %Error{message: ^error}} = API.get_utxos(str_pubkey)
    end

    test "handles utxo bad response" do
      str_pubkey = "str_pubkey"
      utxo_body = Jason.encode!("<><>")

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: utxo_body}}
      end)

      assert {:error, %Error{message: "Unexpected Twetch utxos response"}} =
               API.get_utxos(str_pubkey)
    end
  end

  describe "get_challenge/1" do
    test "successfully gets challenge" do
      message = "CHALLENGE_MESSAGE"
      challenge_body = Jason.encode!(%{message: message})

      Mimic.expect(HTTPoison, :get, fn _url ->
        {:ok, %HTTPoison.Response{body: challenge_body}}
      end)

      assert {:ok, ^message} = API.get_challenge()
    end

    test "handles bad challenge response" do
      challenge_body = Jason.encode!("<><>")

      Mimic.expect(HTTPoison, :get, fn _url ->
        {:ok, %HTTPoison.Response{body: challenge_body}}
      end)

      assert {:error, %Error{message: "Unexpected Twetch authentication challenge response"}} =
               API.get_challenge()
    end
  end

  describe "get_bearer_token/1" do
    test "successfully gets bearer token" do
      address = "addresss"
      message = "message"
      signature = "signature"
      token = "token"
      completed_challenge_body = Jason.encode!(%{token: token})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: completed_challenge_body}}
      end)

      assert {:ok, ^token} = API.get_bearer_token(address, message, signature)
    end

    test "handles error bearer token response" do
      completed_challenge_body = Jason.encode!(%{error: "error"})

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: completed_challenge_body}}
      end)

      assert {:error, %Twetch.API.Error{message: "error"}} = API.get_bearer_token("", "", "")
    end

    test "handles bad bearer token response" do
      completed_challenge_body = Jason.encode!("<><>")

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: completed_challenge_body}}
      end)

      assert {:error, %Twetch.API.Error{message: "Unexpected Twetch bearer token response"}} =
               API.get_bearer_token("", "", "")
    end
  end
end
