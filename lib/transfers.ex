defmodule SolTracker.Transfers do

	use Rustler,
		otp_app: :soltracker,
		crate: :metaplex_decoder 

	@system_program "11111111111111111111111111111111"
	@token_program "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
	@metadata_program "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s"

	def track(program_pub_key) do
		SolTracker.program_subscribe(program_pub_key)
	end

	def decode(%{"result" => result, "subscription" => sub}) do
		IO.inspect(sub) # todo: validate the subscription id is the one we expect
		decode(result)
	end

	def decode(%{"context" => context, "value" => %{"pubkey" => _pubkey, "account" => account}}) do 
		%{
			slot: Map.get(context, "slot"),
			program: account["data"],
			lamports: Map.get(account, "lamports"),
			owner: Map.get(account, "owner")
		}
	end

	def decode(msg), do: msg

	@doc """
	From an account Base58-encoded pubKey, find a Program Derived Address (PDA) for the Token Metadata Program.
	"""
	def get_metadata_pda(account_pubkey) do
		with {:ok, meta} <- B58.decode58!(@metadata_program),
			{:ok, addr} = B58.decode58(account_pubkey),
			{:ok, pda, _i} = Solana.Key.find_address(["metadata", meta, addr], meta) do 

			B58.encode58(pda)
		end
	end

	@doc"""
	Get the token metadata information for a Base-58 encoded PDA.
	Get the account info for the PDA, and base58 encode it.
	Deserialize it according to the TMP spec by calling out to the Rust program via Rustler.
	"""
	def metadata_from_pda(pda_58) do
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