defmodule Twetch.API.ValidateTest do
  use ExUnit.Case

  alias Twetch.API.{Error, Validate}

  describe "payees/1" do
    test "validates expected data successfully" do
      invoice = "invoice"

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

      assert :ok = Validate.payees(%{"invoice" => invoice, "payees" => payees, "errors" => []})
    end

    test "returns error when expected key is missing" do
      invoice = "invoice"

      payees = [
        %{
          "amount" => 0.00020506,
          "to" => "15evjiAagwaFNydP5J9Pvr1k4qpngqcZUn",
          "types" => ["post"],
          "user_id" => "0"
        },
        %{
          "amount" => 0.00002278,
          "to" => "17xCBD1pVM1vE7YbnHV6cz5xgKAT1U2PkJ",
          "types" => ["api-request"],
          "user_id" => "13796"
        }
      ]

      assert {:error, %Error{message: "Unexpected payee format"}} =
               Validate.payees(%{"invoice" => invoice, "payees" => payees, "errors" => []})
    end
  end
end
