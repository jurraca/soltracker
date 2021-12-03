defmodule SolTracker do
  @moduledoc """
  Documentation for `SolTracker`.
  """
  alias Solana.RPC

  @rpc_url "https://api.mainnet-beta.solana.com"

  @doc """
    Subscribe to logs for a specific base58-encoded address. 
    Spawns a new supervised Client process. 
  """
  def logs_subscribe(pubkey \\ "all") do
    params = %{"id" => 1, "jsonrpc" => "2.0", "method" => "logsSubscribe", "params" => [%{"mentions" => [ pubkey ]}, %{"encoding" => "jsonParsed", "commitment" => "finalized"}]}
    {:ok, msg} = Jason.encode(params)
    spawn_subscription(msg)
  end

  @doc """
    Subscribe to notifications that a specific contract has been called, identified by its address. Default encoding is json.
    Spawns a new supervised Client process. 
  """
  def program_subscribe(pubkey) do 
    params = %{"id" => 1, "jsonrpc" => "2.0", "method" => "programSubscribe", "params" => [pubkey, %{"commitment" => "finalized", "encoding" => "jsonParsed"}]}
    {:ok, msg} = Jason.encode(params)
    spawn_subscription(msg)
  end

  @doc """
    Unsubscribe from notifications. 
  """
  def program_unsubscribe(pid, subscription_id) do 
    {:ok, msg} = Jason.encode(%{"id" => 1, "jsonrpc" => "2.0", "method" => "programUnsubscribe", "params" => [subscription_id]})
    WebSockex.cast(pid, {:send, {:binary, msg}})
  end

  def test_run(pid) do
    {:ok, msg} = Jason.encode(%{"method" => "rootSubscribe", "id" => 1, "jsonrpc" => "2.0"})
    WebSockex.cast(pid, {:send, {:binary, msg}})
  end

  def spawn_subscription(msg) do
    {:ok, pid} = SolTracker.Client.start_link([])
    WebSockex.cast(pid, {:send, {:binary, msg}})
  end

  def rpc_client(), do: RPC.client(network: @rpc_url)

  def rpc_send(request), do: RPC.send(rpc_client(), request)
end
