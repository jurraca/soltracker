defmodule SolTracker.Block do
  @moduledoc """
  	Fetch and parse Solana Blocks.

  	check account keys for token program
  	if it exists, get its index
  	iter thru instructions, looking for that index
  	If it exists, decode the data field
  	fetch the accounts from the accounts indexes
  	return decoded data (lamport value), accounts
  """
  alias Solana.RPC

  @system_program "11111111111111111111111111111111"
  @token_program "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
  @metadata_program "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s"

  @doc """
  Fetch a block by its slot number.
  """
  def fetch(slot) do
    request = Solana.RPC.Request.get_block(slot)
    RPC.send(SolTracker.rpc_client(), request)
  end

  @doc """
  Fetch tx, whether b58 or not. 
  """
  def fetch_tx(tx_id) do
    case B58.decode58(tx_id) do
      {:ok, b} -> SolTracker.rpc_send(Solana.RPC.Request.get_transaction(b))
      {:error, _} -> SolTracker.rpc_send(Solana.RPC.Request.get_transaction(tx_id))
    end
  end

  def parse_transfers(%{"transactions" => txs}) do
    Enum.map(txs, fn %{"transaction" => tx} -> filter_txs(tx) end)
  end

  defp filter_txs(%{"message" => %{"accountKeys" => keys, "instructions" => instructions}}) do
    case get_token_program_index(keys) do
      nil -> {:ok, :no_token_program}
      i -> filter_instructions(keys, instructions, i)
    end
  end

  defp get_token_program_index(keys) when is_list(keys) do
    Enum.find_index(keys, fn x -> x == @metadata_program end)
  end

  defp get_token_program_index(_), do: {:error, "Not a list of keys."}

  defp filter_instructions(keys, instructions, index) do
    instructions
    |> Enum.filter(fn x -> Map.get(x, "programIdIndex") == index end)
    |> Enum.map(fn i -> decode_instruction_data(i) end)
    |> Enum.map(&fetch_accounts(&1, keys))
  end

  defp decode_instruction_data(%{"data" => data} = instructions) do
    decoded =
      data
      |> B58.decode58()
      # parse_data()
      |> IO.inspect()

    {:ok, decoded, instructions}
  end

  # the code for a transfer from the Token Program is "4", so we match on that. 
  defp parse_data({:ok, <<4::size(8)-little, _r::binary>> = bin}) when is_binary(bin) do
    <<4::size(8)-little, lamports::size(64)-little, rest::binary>> = bin
    %{"code" => 4, "lamports" => lamports}
  end

  defp parse_data({:error, _} = err), do: err
  defp parse_data(bin), do: bin

  def fetch_accounts({:ok, nil, _}, _keys), do: {:ok, :parse_error}

  def fetch_accounts({:ok, data, %{"accounts" => indexes}}, keys) do
    accounts = Enum.map(indexes, fn i -> Enum.at(keys, i) end)
    Map.put_new(data, "accounts", accounts)
  end
end
