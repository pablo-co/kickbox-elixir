defmodule Kickbox.FakeKickbox do
  use Plug.Router

  plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  pass: ["*/*"],
  json_decoder: Poison
  plug :match
  plug :dispatch

  def start_server(parent) do
    Agent.start_link(fn -> HashDict.new end, name: __MODULE__)
    Agent.update(__MODULE__, &HashDict.put(&1, :parent, parent))
    port = get_free_port
    Application.put_env(:kickbox, :kickbox_base_uri, "http://localhost:#{port}")
    Plug.Adapters.Cowboy.http __MODULE__, [], port: port, ref: __MODULE__
  end

  defp get_free_port do
    {:ok, socket} = :ranch_tcp.listen(port: 0)
    {:ok, port} = :inet.port(socket)
    :erlang.port_close(socket)
    port
  end

  def shutdown do
    Plug.Adapters.Cowboy.shutdown(__MODULE__)
  end

  get "verify" do
    case get_in(conn.params, ["email"]) do
      "INVALID_EMAIL" ->
        conn |> send_resp(500, "Error!!") |> send_to_parent()
      _ ->
        conn |> send_resp(200, valid_response()) |> send_to_parent()
    end
  end

  defp send_to_parent(conn) do
    parent = Agent.get(__MODULE__, fn(set) -> HashDict.get(set, :parent) end)
    send parent, {:fake_kickbox, conn}
    conn
  end

  defp valid_response do
    %{
      result: "deliverable",
      reason: nil,
      role: false,
      free: false,
      disposable: false,
      accept_all: false,
      did_you_mean: nil,
      sendex: 0.23,
      email: "bill.lumbergh@gmail.com",
      user: "bill.lumbergh",
      domain: "gmail.com",
      success: true,
      message: nil
    } |> Poison.encode!()
  end
end
