defmodule Support.TestConfig do
  @moduledoc """
  Test helper for setting Twetch app config.
  """

  def mock_app_config() do
    [
      client_id: "client_id",
      mock_bot: [
        token: "token",
        base64_ext_key:
          "A+2y713mUHU17yQlTCZLryMuP7SsYt3yZrivquVgrjdy1oCLJDHnrsLvoKWZF9wa6VGpCtuP1oPO0NVtLR1KYA=="
      ]
    ]
    |> Enum.map(fn {key, value} -> Application.put_env(:twetch, key, value) end)

    :mock_bot
  end
end
