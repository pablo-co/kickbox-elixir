defmodule Kickbox do
  alias Kickbox.Verification

  @default_base_uri "https://api.kickbox.io/v2"
  @verify_path "verify"
  @env_api_key System.get_env("KICKBOX_API_KEY")

  defmodule ApiError do
    defexception [:message]

    def exception(%{message: message}) do
      %ApiError{message: message}
    end

    def exception(%{params: params, response: response}) do
      message = """
      There was a problem verifying the email through the Postmark API.

      Here is the response:
      #{inspect response, limit: :infinity}

      Here are the params we sent:
      #{inspect params, limit: :infinity}

      If you are deploying to Heroku and using ENV variables to handle your API
      key, you will need to explicitly export the variables so they are
      available at compile time.
      Add the following configuration to your elixir_buildpack.config:
      config_vars_to_export=(
        DATABASE_URL
        KICKBOX_API_KEY
      )
      """
      %ApiError{message: message}
    end
  end

  def verify(email, options \\ []) do
    options = options |> to_map() |> merge_with_defaults()
    api_key = get_key(options)
    params = build_params(email, options)
    uri = [base_uri(), "/", @verify_path, "?", URI.encode_query(params)]

    case :hackney.get(uri, with: :body) do
      {:ok, status, _headers, response} when status > 299 ->
        raise(ApiError, %{params: params, response: response})
      {:ok, status, headers, reference} ->
        reference
        |> decode_reference()
        |> Map.merge(Enum.into(headers, %{}))
        |> new_verification()
      {:error, reason} ->
        raise(ApiError, %{message: inspect(reason)})
    end
  end

  def get_key(config) do
    if config[:api_key] in [nil, ""] do
      raise_api_key_error(config)
    else
      config[:api_key]
    end
  end

  defp new_verification(attrs \\ %{}) do
    attrs |> string_map_to_list() |> Verification.new_verification()
  end

  defp string_map_to_list(map) do
    [
      email: map["email"],
      success?: map["success"],
      role?: map["role"],
      free?: map["free"],
      accept_all?: map["acccept_all"],
      disposable?: map["disposable"],
      did_you_mean: map["did_you_mean"],
      domain: map["domain"],
      user: map["use"],
      sendex: map["sendex"],
      message: map["message"],
      result: map["result"],
      reason: map["reason"],
      balance: map["X-Kickbox-Balance"]
    ]
  end

  defp decode_reference(reference) do
    {:ok, body} = reference |> :hackney.body()
    Poison.decode!(body)
  end

  defp raise_api_key_error(config) do
    raise ArgumentError, """
    There was no API key set for Kickbox.
    * Here are the config options that were passed in:
    #{inspect config}
    """
  end

  defp build_params(email, params) do
    Map.merge(params, %{email: email })
  end

  defp merge_with_defaults(params) do
    Map.merge(default_params, params)
  end

  defp base_uri do
    Application.get_env(:kickbox, :kickbox_base_uri) || @default_base_uri
  end

  defp api_key do
    Application.get_env(:kickbox, :kickbox_api_key) || @env_api_key
  end

  defp default_params do
    %{
      timeout: 6000,
      api_key: api_key()
    }
  end

  defp to_map(keyword_list) do
    Enum.into(keyword_list, %{})
  end
end
