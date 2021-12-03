defmodule SolTracker.Transfers do

	use Rustler,
		otp_app: :soltracker,
		crate: :metaplex_decoder 

	# The Solana SystemProgram, a str len 32
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
		meta = B58.decode58!("metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s")
		addr = B58.decode58!(account_pubkey)

		{:ok, pda, _i} = Solana.Key.find_address(["metadata", meta, addr], meta)
		B58.encode58(pda)
	end

	@doc"""
	Get the token metadata information for a Base-58 encoded PDA.
	Get the account info for the PDA, and base58 encode it.
	Deserialize it according to the TMP spec by calling out to the Rust program via Rustler.
	"""
	def metadata_from_pda(pda_58) do
		pda_58
		|> pda_to_b58()
		|> deserialize_metadata()
		|> Jason.decode()
	end


	def pda_to_b58(pda) do
		{:ok, bin} = B58.decode58(pda)
		request = Solana.RPC.Request.get_account_info(bin, %{"encoding" => "base64"})
	   	{:ok, %{"data" => data}} = Solana.RPC.send(SolTracker.rpc_client(), request)
	   	{:ok, b} = Base.decode64(Enum.at(data, 0))
	   	B58.encode58(b)
	end

	def deserialize_metadata(arg), do: :erlang.nif_error(:nif_not_loaded)
end