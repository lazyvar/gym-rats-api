# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GymRats.Repo.insert!(%GymRats.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

master_splinter = %{
  email: "gym@rat.one",
  full_name: "Master Splinter",
  password: "password",
  profile_picture_url:
    "https://vignette.wikia.nocookie.net/non-aliencreatures/images/6/69/MasterSplinter-1990.jpeg/revision/latest/scale-to-width-down/340?cb=20170726012939"
}

leo = %{
  email: "gym@rat.two",
  full_name: "Leo",
  password: "password",
  profile_picture_url:
    "https://vignette.wikia.nocookie.net/tmnt/images/b/b2/OOTS_UK_Poster_01.jpg/revision/latest/scale-to-width-down/340?cb=20160505180413"
}

mike = %{
  email: "gym@rat.three",
  full_name: "Michelangelo",
  password: "password",
  profile_picture_url:
    "https://i0.wp.com/www.teenagemutantninjaturtles.com/wp-content/uploads/2018/05/Michelangelo.png?fit=1024%2C573&ssl=1"
}

don = %{
  email: "gym@rat.four",
  full_name: "Donatello Turtle",
  password: "password",
  profile_picture_url:
    "https://www.biography.com/.image/t_share/MTE5NTU2MzE2NTg5MzYwNjUx/donatello-21032601-1-402.jpg"
}

raph = %{
  email: "gym@rat.five",
  full_name: "Raphael TMNT",
  password: "password",
  profile_picture_url:
    "https://upload.wikimedia.org/wikipedia/en/7/72/Raphael_%28Teenage_Mutant_Ninja_Tutles%29.jpg"
}

master_splinter =
  GymRats.Model.Account.registration_changeset(%GymRats.Model.Account{}, master_splinter)
  |> GymRats.Repo.insert!()

leo =
  GymRats.Model.Account.registration_changeset(%GymRats.Model.Account{}, leo)
  |> GymRats.Repo.insert!()

mike =
  GymRats.Model.Account.registration_changeset(%GymRats.Model.Account{}, mike)
  |> GymRats.Repo.insert!()

don =
  GymRats.Model.Account.registration_changeset(%GymRats.Model.Account{}, don)
  |> GymRats.Repo.insert!()

raph =
  GymRats.Model.Account.registration_changeset(%GymRats.Model.Account{}, raph)
  |> GymRats.Repo.insert!()

tmnt_upcoming = %{
  profile_picture_url:
    "https://thumbor.forbes.com/thumbor/960x0/https%3A%2F%2Fblogs-images.forbes.com%2Ferikkain%2Ffiles%2F2018%2F02%2FTMNT-4.jpg",
  name: "TMNT Rising",
  start_date: DateTime.utc_now() |> DateTime.add(172_800, :second),
  end_date: DateTime.utc_now() |> DateTime.add(172_800 * 2, :second),
  code: "123456",
  time_zone: "EST"
}

tmnt_active = %{
  profile_picture_url:
    "https://thumbor.forbes.com/thumbor/960x0/https%3A%2F%2Fblogs-images.forbes.com%2Ferikkain%2Ffiles%2F2018%2F02%2FTMNT-4.jpg",
  name: "TMNT",
  start_date: DateTime.utc_now() |> DateTime.add(-4 * 172_800, :second),
  end_date: DateTime.utc_now() |> DateTime.add(172_800 * 3, :second),
  code: "abcdef",
  time_zone: "EST"
}

tmnt_past = %{
  profile_picture_url:
    "https://thumbor.forbes.com/thumbor/960x0/https%3A%2F%2Fblogs-images.forbes.com%2Ferikkain%2Ffiles%2F2018%2F02%2FTMNT-4.jpg",
  name: "TMNT Done",
  start_date: DateTime.utc_now() |> DateTime.add(-1 * 172_800 * 2, :second),
  end_date: DateTime.utc_now() |> DateTime.add(-1 * 172_800, :second),
  code: "abc123",
  time_zone: "EST"
}

tmnt_upcoming =
  GymRats.Model.Challenge.changeset(%GymRats.Model.Challenge{}, tmnt_upcoming)
  |> GymRats.Repo.insert!()

tmnt_active =
  GymRats.Model.Challenge.changeset(%GymRats.Model.Challenge{}, tmnt_active)
  |> GymRats.Repo.insert!()

tmnt_past =
  GymRats.Model.Challenge.changeset(%GymRats.Model.Challenge{}, tmnt_past)
  |> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_upcoming.id,
  gym_rats_user_id: master_splinter.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_upcoming.id,
  gym_rats_user_id: leo.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_upcoming.id,
  gym_rats_user_id: mike.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_upcoming.id,
  gym_rats_user_id: don.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_upcoming.id,
  gym_rats_user_id: raph.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_active.id,
  gym_rats_user_id: master_splinter.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_active.id,
  gym_rats_user_id: leo.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_active.id,
  gym_rats_user_id: mike.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_active.id,
  gym_rats_user_id: don.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_active.id,
  gym_rats_user_id: raph.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_past.id,
  gym_rats_user_id: master_splinter.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_past.id,
  gym_rats_user_id: leo.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_past.id,
  gym_rats_user_id: mike.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_past.id,
  gym_rats_user_id: don.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Membership{}
|> GymRats.Model.Membership.changeset(%{
  challenge_id: tmnt_past.id,
  gym_rats_user_id: raph.id,
  owner: true
})
|> GymRats.Repo.insert!()

%GymRats.Model.Workout{}
|> GymRats.Model.Workout.changeset(%{
  calories: "100",
  description: "How do you do.",
  title: "Yeah!",
  photo_url: "https://picsum.photos/200/200",
  challenge_id: tmnt_active.id,
  gym_rats_user_id: master_splinter.id
})
|> GymRats.Repo.insert!()

%GymRats.Model.Workout{}
|> GymRats.Model.Workout.changeset(%{
  steps: "100",
  description: "Doing fine...",
  title: "No.",
  photo_url: "https://picsum.photos/100/200",
  challenge_id: tmnt_active.id,
  gym_rats_user_id: mike.id
})
|> GymRats.Repo.insert!()

%GymRats.Model.Workout{}
|> GymRats.Model.Workout.changeset(%{
  points: "300",
  title: "Komibungha.",
  photo_url: "https://picsum.photos/300/100",
  challenge_id: tmnt_active.id,
  gym_rats_user_id: leo.id
})
|> GymRats.Repo.insert!()

%GymRats.Model.Workout{}
|> GymRats.Model.Workout.changeset(%{
  distance: "100000",
  title: "Pump it up.",
  photo_url: "https://picsum.photos/300/300",
  challenge_id: tmnt_active.id,
  gym_rats_user_id: raph.id
})
|> GymRats.Repo.insert!()

%GymRats.Model.Workout{}
|> GymRats.Model.Workout.changeset(%{
  description: "LETS GET IT.",
  title: "Pick things up, put them down.",
  photo_url: "https://picsum.photos/500/200",
  challenge_id: tmnt_active.id,
  gym_rats_user_id: don.id
})
|> GymRats.Repo.insert!()
