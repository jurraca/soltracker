defmodule SolTracker.Transfers do
  use Rustler,
    otp_app: :soltracker,
    crate: :metaplex_decoder

  require Logger
  alias SolTracker.Block

  @metadata_program "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s"

  @doc """
  	Subscribe to a particular Program identified by its public key.
  	See https://docs.solana.com/developing/clients/jsonrpc-api#programsubscribe
  """
  def track(program_pub_key) do
    SolTracker.program_subscribe(program_pub_key)
  end

  def track_metadata_program() do
    SolTracker.keys()
    |> Map.get(:metadata_program)
    |> track()
  end

  @doc """
  Parse all transactions in a block (slot) for NFT transfers.
  """
  def parse_transfers_from_slot(slot) when is_integer(slot) do
    case Block.fetch(slot) do
      {:ok, %{"transactions" => nil}} -> {:ok, "No Transactions in slot #{slot}"}
      {:ok, %{"transactions" => txs}} -> parse_transfers(txs)
      msg -> {:error, msg}
    end
  end

  defp parse_transfers(txs) do
    txs
    |> Enum.map(&filter_token_transfers(&1))
    |> Enum.filter(fn i -> i !== %{} end)
  end

  @doc """
  For a transaction body, match on the postTokenBalances field, which tells us whether a Token transfer--not just a SOL transfer--occurred.
  If it exists, derive the metadata for the mint address.
  """
  def filter_token_transfers(%{"meta" => %{"postTokenBalances" => nil}}),
    do: Logger.info("No NFT transferred.")

  def filter_token_transfers(%{
        "meta" => %{"postTokenBalances" => ptb},
        "transaction" => %{"signatures" => sigs} = tx
      }) do
    # there can be more than one sig in a tx, this is a heuristic to identify the tx within the block
    tx_id = Enum.at(sigs, 0)

    ptb
    |> Enum.map(fn ptb -> derive_metadata_pda(ptb["mint"]) end)
    |> Enum.reduce(
      %{},
      fn
        {:ok, x}, acc -> Map.put_new(acc, tx_id, x)
        _, acc -> acc
      end
    )
  end

  @doc """
  Decoding function for the ProgramSubscribe websocket endpoint. Needs shortVec encoding to properly parse base64.
  """
  def decode(%{"result" => result, "subscription" => sub}), do: decode(result)

  def decode(%{
        "context" => context,
        "value" => %{"pubkey" => pubkey, "account" => %{"data" => data} = account}
      }) do
    account = %{
      slot: account["slot"],
      pubkey: pubkey,
      data: data,
      owner: account["owner"],
      lamports: account["lamports"]
    }

    if [b, "base64"] = data do
      {:ok, s} = Base.decode64(b)
      # TODO: shortvec encoding
      case Jason.encode(s) do
        {:error, _} = err -> err
        {:ok, d} -> d |> IO.inspect()
      end
    else
      Logger.warn(data)
    end
  end

  def decode(msg), do: msg

  @doc """
  From an account Base58-encoded pubKey, find a Program Derived Address (PDA) for the Token Metadata Program.
  """
  def derive_metadata_pda(account_pubkey) do
    with {:ok, meta} <- B58.decode58(@metadata_program),
         {:ok, addr} <- B58.decode58(account_pubkey),
         {:ok, pda, _i} <- Solana.Key.find_address(["metadata", meta, addr], meta) do
      pda
      |> get_metadata_from_pda()
    end
  end

  @doc """
  Get the token metadata information for a Base-58 encoded PDA.
  Get the account info for the PDA, and base58 encode it.
  Deserialize it according to the TMP spec by calling out to the Rust program via Rustler.
  """
  def get_metadata_from_pda(pda) do
    case get_metadata(pda) do
      {:ok, metadata} ->
        try do
          metadata
          |> deserialize_metadata()
          |> Jason.decode()
        catch
          _err -> Logger.warn("cannot deserialize with Metaplex format: #{metadata}")  
        end
      {:error, _} = err -> err
    end
  end

  @doc """
  Get the account info of a PDA, which for the Token Metadata Program will be the Metaplex metadata JSON itself.
  We base64-encode it bc it can handle more data than other encodings -- you will get size errors with base58.
  Return a base58-encoded string, because this is what the deserializer expects.
  """
  def get_metadata(pda) do
    request = Solana.RPC.Request.get_account_info(pda, %{"encoding" => "base64"})

    with {:ok, %{"data" => data}} <- SolTracker.rpc_send(request),
        {:ok, b} <- Base.decode64(Enum.at(data, 0)) do
      {:ok, B58.encode58(b)}
    else
      _ -> {:error, :cannot_deserialize}
    end
  end

  # handle input before we call the NIF
  defp deserialize({:ok, arg}), do: deserialize_metadata(arg)
  defp deserialize({:error, msg}), do: Jason.encode!(%{"error" => msg})

  # NIF entry point function
  def deserialize_metadata(arg), do: :erlang.nif_error(:nif_not_loaded)
end
