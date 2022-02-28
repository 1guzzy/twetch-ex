defmodule Twetch.ABI do
  @moduledoc """
  A module for constructing Twetch actions based on Twetch's Application Binary Interface schemas
  """
  alias Twetch.Account
  alias BSV.{Address, Message, Hash}

  @doc """
  Create new instance of Twetch ABI for the given action and args.
  """
  def new(name, args) do
    with {:ok, data} <- File.read(Path.join(__DIR__, "/abi/schema.json")),
         {:ok, schema} <- Jason.decode(data) do
      action = Map.put(schema["actions"][name], "name", name)
      args = Enum.map(action["args"], &build_args(&1, args))

      {:ok, %{action: action, args: args}}
    end
  end

  defp build_args(arg, opts) do
    case Keyword.get(opts, arg_key(arg)) do
      nil -> arg_value(arg)
      value -> value
    end
  end

  defp arg_key(%{"name" => name}), do: String.to_atom(name)

  def arg_value(%{"value" => value}), do: value
  def arg_value(%{"replaceValue" => replace_value}), do: replace_value
  def arg_value(%{"defaultValue" => default_value}), do: default_value

  @doc """
  Replace arg values.
  """
  def update(bot, %{action: action, args: args}, invoice) do
    {:ok, %{privkey: privkey, address: address}} = Account.get(bot)

    replacements = %{
      "\#{mySignature}" => fn arg, args -> sign(arg, args, privkey) end,
      "\#{myAddress}" => fn _arg, _args -> Address.to_string(address) end,
      "\#{invoice}" => fn _arg, _args -> invoice end
    }

    {:ok,
     %{action: action, args: Enum.reduce(action["args"], args, &replace(&1, &2, replacements))}}
  end

  defp replace(%{"replaceValue" => value} = abi, args, replacements) do
    Enum.map(args, fn arg ->
      cond do
        arg == value ->
          replacements[value].(abi, args)

        true ->
          arg
      end
    end)
  end

  defp replace(_arg, args, _replacements), do: args

  defp sign(arg, args, privkey) do
    %{"messageStartIndex" => startIndex, "messageEndIndex" => endIndex} = arg

    args
    |> Enum.slice(startIndex..endIndex)
    |> Enum.join("")
    |> Hash.sha256(encoding: :hex)
    |> Message.sign(privkey, encoding: :base64)
  end
end
