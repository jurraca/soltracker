defmodule SolTracker do
  @moduledoc """
  Basic RPC and websocket subscription help.
  """
  alias Solana.RPC

  @rpc_url "https://api.mainnet-beta.solana.com"

  @doc """
    Create an RPC client for Solana Mainnet.
  """
  def rpc_client(), do: RPC.client(network: @rpc_url)

  @doc """
    Send a request via RPC.
  """
  def rpc_send(request), do: RPC.send(rpc_client(), request)

  @doc """
    Subscribe to logs for a specific base58-encoded address. 
    Spawns a new supervised Client process. 
  """
  def logs_subscribe(pubkey \\ "all") do
    params = %{
      "id" => 1,
      "jsonrpc" => "2.0",
      "method" => "logsSubscribe",
      "params" => [
        %{"mentions" => [pubkey]},
        %{"encoding" => "jsonParsed", "commitment" => "finalized"}
      ]
    }

    {:ok, msg} = Jason.encode(params)
    spawn_subscription(msg)
  end

  @doc """
    Subscribe to notifications that a specific contract has been called, identified by its address. Default encoding is json.
    Spawns a new supervised Client process. 
  """
  def program_subscribe(pubkey) do
    params = %{
      "id" => 1,
      "jsonrpc" => "2.0",
      "method" => "programSubscribe",
      "params" => [pubkey, %{"commitment" => "finalized", "encoding" => "jsonParsed"}]
    }

    {:ok, msg} = Jason.encode(params)
    spawn_subscription(msg)
  end

  @doc """
    Unsubscribe from notifications. 
  """
  def program_unsubscribe(pid, subscription_id) do
    {:ok, msg} =
      Jason.encode(%{
        "id" => 1,
        "jsonrpc" => "2.0",
        "method" => "programUnsubscribe",
        "params" => [subscription_id]
      })

    WebSockex.cast(pid, {:send, {:binary, msg}})
  end

  @doc """
    Starts a websocket client as a process. `WebSockex.cast` returns a tuple with the process PID. 
    In practice, for multiple subscriptions, the result of this call should track the PIDs in a registry or similar.
  """
  def spawn_subscription(msg) do
    {:ok, pid} = SolTracker.Client.start_link([])
    WebSockex.cast(pid, {:send, {:binary, msg}})
  end

  def program_keys() do
    %{
      system_program: "11111111111111111111111111111111",
      token_program: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
      metadata_program: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s"
    }
  end
end
