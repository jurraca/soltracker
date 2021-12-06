defmodule SolTracker.Transfers do

	use Rustler,
		otp_app: :soltracker,
		crate: :metaplex_decoder 

	alias SolTracker.Block

	@system_program "11111111111111111111111111111111"
	@token_program "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
	@metadata_program "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s"

	def track(program_pub_key \\ @metadata_program) do
		SolTracker.program_subscribe(program_pub_key)
	end

	def parse_transfers_from_slot(slot) when is_integer(slot) do
		{:ok, %{"transactions" => txs}} = Block.fetch(slot)

		Enum.map(txs, &fetch_token_transfers(&1))		
	end

	def fetch_tx(tx_id) do
		case B58.decode58(tx_id) do
		   {:ok, b} -> SolTracker.rpc_send(Solana.RPC.Request.get_transaction(b))
		   {:error, _} ->  SolTracker.rpc_send(Solana.RPC.Request.get_transaction(tx_id))
		end
	end

	def fetch_token_transfers(%{"meta" => %{"postTokenBalances" => []}}), do: nil

	def fetch_token_transfers(%{"meta" => %{"postTokenBalances" => ptb}, "transaction" => %{"signatures" => sigs} = tx}) do
		tx_id = Enum.at(sigs, 0) # there can be more than one sig in a tx, this is a heuristic to identify the tx within the block
		
		ptb
		|> Enum.map(fn ptb -> derive_metadata_pda(ptb["mint"]) end)
		|> Enum.reduce(
			%{},
			fn {:ok, x}, acc -> Map.put_new(acc, tx_id, x)
				_, acc -> acc
			 end)
	end

	def decode(%{"result" => result, "subscription" => sub}), do: decode(result)

	def decode(%{"context" => context, "value" => %{"pubkey" => pubkey, "account" => %{"data" => data} = account}}) do
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
			IO.inspect(data)
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
			|> B58.encode58()
			|> get_metadata_from_pda()
		end
	end

	@doc"""
	Get the token metadata information for a Base-58 encoded PDA.
	Get the account info for the PDA, and base58 encode it.
	Deserialize it according to the TMP spec by calling out to the Rust program via Rustler.
	"""
	def get_metadata_from_pda(pda_58) do
		pda_58
		|> get_metadata()
		|> deserialize_metadata()
		|> Jason.decode()
	end

	@doc """
	Get the account info of a PDA, which for the Token Metadata Program will be the Metaplex metadata JSON itself.
	We base64-encode it bc it can handle more data than other encodings -- you will get size errors with base58.
	Return a base58-encoded string, because this is what the deserializer expects.
	"""
	def get_metadata(pda) do
		{:ok, bin} = B58.decode58(pda)
		request = Solana.RPC.Request.get_account_info(bin, %{"encoding" => "base64"})
		with {:ok, %{"data" => data}} <- SolTracker.rpc_send(request),
			{:ok, b} <- Base.decode64(Enum.at(data, 0)) do
			B58.encode58(b)
		end
	end

	def deserialize_metadata(arg), do: :erlang.nif_error(:nif_not_loaded)
end