defmodule SolTracker.Repo do
	use Ecto.Repo,
		otp_app: :soltracker,
		adapter: Ecto.Adapters.Postgres
end