defmodule KickboxTest do
  use ExUnit.Case
  doctest Kickbox
  alias Kickbox.FakeKickbox

  @config %{api_key: "123_abc"}
  @config_with_bad_key %{api_key: nil}
  setup do
    FakeKickbox.start_server(self)

    on_exit fn ->
      FakeKickbox.shutdown()
    end

    :ok
  end

  test "raises if the api key is nil" do
    assert_raise ArgumentError, ~r/no API key set/, fn ->
      Kickbox.verify("valid@email.com", @config_with_bad_key)
    end

    assert_raise ArgumentError, ~r/no API key set/, fn ->
      Kickbox.get_key(@config_with_bad_key)
    end
  end

  test "raises if the response is not a success" do
    assert_raise Kickbox.ApiError, fn ->
      Kickbox.verify("INVALID_EMAIL", @config)
    end
  end

  test "verify/2 sends to the right url" do
    Kickbox.verify("valid@email.com", @config)

    assert_receive {:fake_kickbox, %{request_path: request_path}}
    assert request_path == "/verify"
  end

  test "verify/2 adds email and timeout to the URL params" do
    Kickbox.verify("valid@email.com", api_key: "api_key", timeout: 100)

    assert_receive {:fake_kickbox, %{params: params}}
    assert params["email"] == "valid@email.com"
    assert params["timeout"] == "100"
  end

  test "verify/2 loads the API key from the environment" do
    Application.put_env(:kickbox, :kickbox_api_key, "api_key")
    Kickbox.verify("valid@email.com")

    assert_receive {:fake_kickbox, %{params: %{"api_key" => api_key}}}
    assert api_key == "api_key"
  end
end
