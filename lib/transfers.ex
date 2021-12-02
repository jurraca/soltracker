defmodule SolTracker.Transfers do

	use Rustler,
		otp_app: :soltracker,
		crate: :metaplex_decoder 

	# The Solana SystemProgram, a str len 32
	@system_program "11111111111111111111111111111111"
	@token_program "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"

	# System Program transfers are just SOL transfers from one account to the other, not an NFT.
	def track() do
		SolTracker.program_subscribe(@token_program)
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

	def metadata_from_pda(pda) do 
		pda
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