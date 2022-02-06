defmodule Twetch.API.ParseTest do
  use ExUnit.Case

  alias Twetch.API.Parse

  describe "payees/1" do
    test "validates expected data successfully" do
      invoice = "invoice"
      address_1 = "15evjiAagwaFNydP5J9Pvr1k4qpngqcZUn"
      address_2 = "17xCBD1pVM1vE7YbnHV6cz5xgKAT1U2PkJ"

      payees = [
        %{
          "amount" => 0.00020506,
          "currency" => "BSV",
          "to" => address_1,
          "types" => ["post"],
          "user_id" => "0"
        },
        %{
          "amount" => 0.00002278,
          "currency" => "BSV",
          "to" => address_2,
          "types" => ["api-request"],
          "user_id" => "13796"
        }
      ]

      assert {:ok,
              %{
                invoice: ^invoice,
                payees: [
                  %{address: ^address_1, sats: 20506},
                  %{address: ^address_2, sats: 2278}
                ]
              }} = Parse.payees(%{"invoice" => invoice, "payees" => payees, "errors" => []})
    end
  end
end
