defmodule Twetch do
  @moduledoc """
  Documentation for `Twetch`.
  """
  alias Twetch.{ABI, API, UTXO, Transaction}

  @doc """
  Publish Twetch post.
  """
  def publish("twetch/post@0.0.1" = action, bContent) do
    template = ABI.build_template(action, bContent)

    with {:ok, payees} <- API.get_payees(action, template),
         {:ok, inputs} <- UTXO.build_inputs(),
         {:ok, tx} <- Transaction.build(action, inputs, payees, bContent),
         raw_tx <- Transaction.to_hex(tx),
         :ok <- API.publish(action, raw_tx) do
      {:ok, tx}
    end
  end
end
