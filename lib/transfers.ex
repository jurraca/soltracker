defmodule SolTracker.Transfers do 

	# The Solana SystemProgram, a str len 32
	@system_program "11111111111111111111111111111111"
	@token_program "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"

	# System Program transfers are just SOL transfers from one account to the other, not an NFT.
	def track() do
		SolTracker.logs_subscribe(@system_program)
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
end