defmodule BeSpiral.Auth.Invitation do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias BeSpiral.{Commune.Community, Accounts.User}

  schema "invitations" do
    belongs_to(:community, Community, references: :symbol, type: :string)
    belongs_to(:creator, User, references: :account, type: :string)

    timestamps()
  end

  @required_fields ~w(community_id creator_id)a

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
