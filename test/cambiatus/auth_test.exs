defmodule Cambiatus.AuthTest do
  use Cambiatus.DataCase

  alias Cambiatus.{Auth, Auth.InvitationId, Auth.Request}
  alias Cambiatus.Repo

  describe "invitations" do
    setup :valid_community_and_user

    test "list_invitations/0 returns all invitations" do
      invitation = insert(:invitation)
      [found_invitation] = Auth.list_invitations()

      assert found_invitation.id == invitation.id
    end

    test "get_invitation!/1 returns the invitation with given id" do
      invitation = insert(:invitation)
      public_invitation_id = InvitationId.encode(invitation.id)
      found_invitation = Auth.get_invitation!(public_invitation_id)

      assert found_invitation.id == invitation.id
      assert found_invitation.creator_id == invitation.creator_id
      assert found_invitation.community_id == invitation.community_id
    end

    test "create_invitation/1 with valid data creates a invitation",
         %{
           community: community,
           user: user
         } do
      invitation = insert(:invitation, %{community: community, creator: user})

      assert invitation.community_id == community.symbol
      assert invitation.creator_id == user.account
    end

    test "get_invitation! accepts strings and returns the correct invitation" do
      invitation = insert(:invitation)

      found_invitation =
        Auth.get_invitation!(invitation.id |> Cambiatus.Auth.InvitationId.encode())

      assert invitation.id == found_invitation.id
    end

    test "get_invitation accepts strings and returns the correct invitation" do
      invitation = insert(:invitation)

      {:ok, found_invitation} =
        Auth.get_invitation(invitation.id |> Cambiatus.Auth.InvitationId.encode())

      assert invitation.id == found_invitation.id
    end

    test "get_invitation returns appropriate error message with invalid invitation" do
      res = Auth.get_invitation("someincorrectid")

      assert res == {:error, "Invitation not found"}
    end

    test "create_invitation/1 with invalid data returns error changeset" do
      assert {:error, "Can't parse arguments"} = Auth.create_invitation(%{})
    end

    test "change_invitation/1 returns a invitation changeset" do
      invitation = insert(:invitation)

      assert %Ecto.Changeset{} = Auth.change_invitation(invitation)
    end
  end

  describe "get_request/1" do
    test "returns an existing request" do
      user = insert(:user)
      request = insert(:request, user: user)
      response = Auth.get_request(user.account)

      assert request.id == response.id
      assert request.phrase == response.phrase
    end

    test "returns nil if finds none request" do
      user = insert(:user)

      assert nil == Auth.get_request(user.account)
    end
  end

  describe "get_valid_request/1" do
    test "returns one valid request" do
      user = insert(:user)
      request = insert(:request, user: user)
      response = Auth.get_valid_request(user.account)

      assert request.id == response.id
      assert request.phrase == response.phrase
    end

    test "retuns nil if non requests are valid" do
      user = insert(:user)

      insert(:request, user: user, updated_at: DateTime.add(DateTime.utc_now(), -31, :second))

      assert nil == Auth.get_valid_request(user.account)
    end
  end

  describe "delete_expired_requests/0" do
    test "deletes all expired requests" do
      insert(:request)
      insert(:request, updated_at: DateTime.add(DateTime.utc_now(), -31, :second))
      insert(:request, updated_at: DateTime.add(DateTime.utc_now(), -31, :second))
      insert(:request, updated_at: DateTime.add(DateTime.utc_now(), -31, :second))

      assert 4 == Request |> Repo.all() |> Enum.count()
      assert {3, nil} == Auth.delete_expired_requests()
      assert 1 == Request |> Repo.all() |> Enum.count()
    end
  end

  describe "Session" do
    setup do
      {:ok, %{user_agent: "Safari", ip_address: "192.168.1.1", token: Faker.String.base64(32)}}
    end

    test "create_session/1 creates a session", params do
      user = insert(:user)
      {:ok, session} = Auth.create_session(Map.merge(params, %{user_id: user.account}))

      assert session.user_id == user.account
    end

    test "create_session/1 with a long user-agent", params do
      user = insert(:user)

      {:ok, session} =
        Auth.create_session(
          Map.merge(params, %{
            user_id: user.account,
            user_agent: Faker.String.base64(300)
          })
        )

      assert session.user_id == user.account
    end
  end
end
