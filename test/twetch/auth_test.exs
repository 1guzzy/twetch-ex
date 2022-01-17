defmodule Twetch.ChallengeTest do
  use ExUnit.Case

  alias Twetch.Challenge

  describe "get_bearer_token/1" do
    setup do
      base64_ext_key =
        "A+2y713mUHU17yQlTCZLryMuP7SsYt3yZrivquVgrjdy1oCLJDHnrsLvoKWZF9wa6VGpCtuP1oPO0NVtLR1KYA=="

      %{base64_ext_key: base64_ext_key}
    end

    test "successfully gets bearer token", %{base64_ext_key: base64_ext_key} do
      challenge_body = JSON.encode!(%{message: "CHALLENGE_MESSAGE"})
      token = "SOME_TOKEN"
      completed_challenge_body = JSON.encode!(%{token: token})

      Mimic.expect(HTTPoison, :get, fn _url ->
        {:ok, %HTTPoison.Response{body: challenge_body}}
      end)

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: completed_challenge_body}}
      end)

      assert {:ok, ^token, _address} = Challenge.get_bearer_token(base64_ext_key)
    end

    test "handles bad challenge response", %{base64_ext_key: base64_ext_key} do
      challenge_body = JSON.encode!("<><>")

      Mimic.expect(HTTPoison, :get, fn _url ->
        {:ok, %HTTPoison.Response{body: challenge_body}}
      end)

      assert {:error, "Unable to parse Twetch challenge message"} =
               Challenge.get_bearer_token(base64_ext_key)
    end

    test "handles bad complete challenge response", %{base64_ext_key: base64_ext_key} do
      challenge_body = JSON.encode!(%{message: "CHALLENGE_MESSAGE"})
      completed_challenge_body = JSON.encode!("<><>")

      Mimic.expect(HTTPoison, :get, fn _url ->
        {:ok, %HTTPoison.Response{body: challenge_body}}
      end)

      Mimic.expect(HTTPoison, :post, fn _url, _body, _headers ->
        {:ok, %HTTPoison.Response{body: completed_challenge_body}}
      end)

      assert {:error, "Unable to parse Twetch bearer token response"} =
               Challenge.get_bearer_token(base64_ext_key)
    end

    test "handles incorrectly formatted ext key" do
      base64_ext_key = "not a key"

      assert {:error, "Unable to decode seed; Expecting base64 format"} =
               Challenge.get_bearer_token(base64_ext_key)
    end
  end
end
