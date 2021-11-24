defmodule SolTracker.Client do
  @moduledoc """
  Documentation for `SolTracker`.
  """
  use WebSockex
  alias SolTracker.Block

  @url "wss://api.mainnet-beta.solana.com"

  def start_link(opts) do
    WebSockex.start_link(@url, __MODULE__, opts)
  end

  @impl WebSockex
  def handle_frame({:text, msg}, state) do
    msg
    |> Jason.decode()
    |> filter_msg()

    {:ok, state}
  end

  @impl WebSockex
  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end

  @impl WebSockex
  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end

  def filter_msg({:ok, %{"method" => "rootNotification", "params" => params}}) do 
    %{"result" => root, "subscription" => sub} = params
    IO.inspect("Root Notification for subscription #{sub}")

    root
    |> Block.fetch()
    |> Block.print()
  end

  def filter_msg({:ok, %{"method" => "logsNotification", "params" => params}}) do
    params
    |> Map.take(["result", "subscription"])
    |> IO.inspect()
  end

  def filter_msg({:ok, %{"method" => "programNotification", "params" => params}}) do
    params 
    |> Map.take(["result", "subscription"])
    |> SolTracker.Transfers.decode()
    |> IO.inspect()
  end

  def filter_msg({:ok, %{"result" => result}}) when is_integer(result) do
    IO.inspect("Subscription: " <> Integer.to_string(result))
  end

  def filter_msg({:ok, msg}) do
    IO.inspect(msg)
  end
end
