defmodule Twetch.Api.Error do
  @moduledoc false
  @type t :: %__MODULE__{message: String.t()}

  defexception [:message]
end
