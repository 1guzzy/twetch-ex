defmodule Twetch do
  @moduledoc """
  Documentation for `Twetch`.
  """
  alias Twetch.{ABI, API, UTXO, Transaction, Account}

  @doc """
  Publish Twetch post.
  """
  def publish("twetch/post@0.0.1" = action, bContent) do
    template = ABI.build_template(action, bContent)

    with {:ok, account} <- Account.get(),
         {:ok, payees} <- API.get_payees(action, template),
         {:ok, utxos} <- UTXO.fetch(account.pubkey),
         {:ok, tx} <- Transaction.build(action, account, utxos, payees, bContent),
         raw_tx <- Transaction.to_hex(tx),
         :ok <- API.publish(action, raw_tx) do
      {:ok, tx}
    end
  end
end
