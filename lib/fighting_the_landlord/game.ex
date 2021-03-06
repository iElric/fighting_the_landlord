defmodule FightingTheLandlord.Game do
  alias FightingTheLandlord.Poker

  @base_point 5

  defguardp guard_player_id(player_id) when player_id >= 0 and player_id <= 2

  def new() do
    # new a game state
    %{
      # indicate the number of landlord call, the maximum should be 3
      landlord_call: 0,
      # indicate current game phase: 1. call_landlord 2. card_play
      phase: :call_landlord,
      # playerid
      landlord: nil,

      # call_landlord_pass_counter: 0,
      # playerid
      # in call landlord phase, this indicates whose turn to call, in card play phase, this indicate whose turn to play
      whose_turn: Enum.random(0..2),
      # in phase call_landlord, the hands is list of length 4, the first three are players' hands, the fourth is 3 left overs card_index_list
      # in phase card_play, the hands is list of length 3, all of them are players'hands
      # the indexes corresponds to playerid
      hands: Poker.deal_cards(),
      # players is a list of string to hold players' name
      players: [],
      points: [0, 0, 0],
      # each bomb in this round of game will result the base point * 2
      bomb_number: 0,
      # the first element in this tuple indicate the playerid (0, 1, 2), second is the hands played by that player
      previous_play: {nil, nil}
    }
  end

  @doc """
  Players' view in phase call landlord.
  """

  def player_view(
        %{
          phase: :call_landlord,
          whose_turn: game_whose_turn,
          hands: game_hands,
          points: game_points,
          players: game_players
        },
        player_id
      )
      when guard_player_id(player_id) do
    %{
      phase: :call_landlord,
      landlord: nil,
      left: %{
        name: Enum.at(game_players, rem(player_id + 2, 3)),
        points: Enum.at(game_points, rem(player_id + 2, 3)),
        cards: length(Enum.at(game_hands, rem(player_id + 2, 3)))
      },
      right: %{
        name: Enum.at(game_players, rem(player_id + 1, 3)),
        points: Enum.at(game_points, rem(player_id + 1, 3)),
        cards: length(Enum.at(game_hands, rem(player_id + 1, 3)))
      },
      self: %{
        name: Enum.at(game_players, player_id),
        points: Enum.at(game_points, player_id),
        cards: Enum.at(game_hands, player_id)
               |> Poker.card_string()
      },
      active: game_whose_turn === player_id,
      left_over_cards: Enum.at(game_hands, 3)
                       |> Poker.card_string()
    }
  end

  @doc """
  Observers' view in phase call landlord.
  """

  def player_view(
        %{
          phase: :call_landlord,
          hands: game_hands,
          points: game_points,
          players: game_players
        },
        player_id
      )
      when player_id > 2 do
    %{
      phase: :call_landlord,
      landlord: nil,
      left: %{
        name: Enum.at(game_players, 0),
        points: Enum.at(game_points, 0),
        cards: Enum.at(game_hands, 0)
               |> Poker.card_string()
      },
      right: %{
        name: Enum.at(game_players, 1),
        points: Enum.at(game_points, 1),
        cards: Enum.at(game_hands, 1)
               |> Poker.card_string()
      },
      self: %{
        name: Enum.at(game_players, 2),
        points: Enum.at(game_points, 2),
        cards: Enum.at(game_hands, 2)
               |> Poker.card_string()
      },
      active: false,
      left_over_cards: Enum.at(game_hands, 3)
                       |> Poker.card_string()
    }
  end


  @doc """
  Players' view in phase card play.
  """

  def player_view(
        %{
          phase: :card_play,
          landlord: game_landlord,
          whose_turn: game_whose_turn,
          hands: game_hands,
          points: game_points,
          previous_play: {game_previous_player, game_previous_played_cards},
          players: game_players
        },
        player_id
      )
      when guard_player_id(player_id) do
    %{
      phase: :card_play,
      landlord: relative_position(game_landlord, player_id),
      left: %{
        name: Enum.at(game_players, rem(player_id + 2, 3)),
        points: Enum.at(game_points, rem(player_id + 2, 3)),
        cards: length(Enum.at(game_hands, rem(player_id + 2, 3)))
      },
      right: %{
        name: Enum.at(game_players, rem(player_id + 1, 3)),
        points: Enum.at(game_points, rem(player_id + 1, 3)),
        cards: length(Enum.at(game_hands, rem(player_id + 1, 3)))
      },
      self: %{
        name: Enum.at(game_players, player_id),
        points: Enum.at(game_points, player_id),
        cards: Enum.at(game_hands, player_id)
               |> Poker.card_string()
      },
      active: game_whose_turn === player_id,
      previous_play: %{
        position: relative_position(game_previous_player, player_id),
        cards: game_previous_played_cards
               |> Poker.card_string()
      }
    }
  end

  @doc """
  Observers' view in phase card play.
  """
  def player_view(
        %{
          phase: :card_play,
          landlord: game_landlord,
          hands: game_hands,
          points: game_points,
          previous_play: {game_previous_player, game_previous_played_cards},
          players: game_players
        },
        player_id
      )
      when player_id > 2 do
    %{
      phase: :card_play,
      landlord: position(game_landlord),
      left: %{
        name: Enum.at(game_players, 0),
        points: Enum.at(game_points, 0),
        cards: Enum.at(game_hands, 0)
               |> Poker.card_string()
      },
      right: %{
        name: Enum.at(game_players, 1),
        points: Enum.at(game_points, 1),
        cards: Enum.at(game_hands, 1)
               |> Poker.card_string()
      },
      self: %{
        name: Enum.at(game_players, 2),
        points: Enum.at(game_points, 2),
        cards: Enum.at(game_hands, 2)
               |> Poker.card_string()
      },
      active: false,
      previous_play: %{
        position: position(game_previous_player),
        cards: game_previous_played_cards
               |> Poker.card_string()
      }
    }
  end

  defp position(player_id) do
    cond do
      player_id === 0 ->
        :left

      player_id === 1 ->
        :right

      true ->
        :self
    end
  end

  # calculate the player_id position relative to base_id
  defp relative_position(base_id, player_id) do
    cond do
      base_id === player_id ->
        :self

      base_id === rem(player_id + 1, 3) ->
        :right

      true ->
        :left
    end
  end

  @doc """
  Ensure that the players list in game_state contains only unique names.
  Return the index of that player_name if it exist. Otherwise return nil.
  """
  defp name_to_index(game_state, player_name) do
    Enum.find_index(game_state.players, fn name -> name === player_name end)
  end

  def add_player(game_state, player_name) do
    index = name_to_index(game_state, player_name)

    if is_nil(index) do
      # add player name and return the game_state and index
      %{players: game_players} = game_state

      game_players =
        game_players
        |> Enum.reverse()

      game_players = [player_name | game_players]

      game_players =
        game_players
        |> Enum.reverse()

      {Map.put(game_state, :players, game_players), length(game_players) - 1}
    else
      # return the game_state and previous index if the name is already in the list
      {game_state, index}
    end
  end

  def has_enough_players?(game_state) do
    length(game_state.players) >= 3
  end

  def call_landlord(game_state, player_id)
      when guard_player_id(player_id) do
    if game_state.phase === :call_landlord and game_state.whose_turn === player_id do
      %{hands: game_hands} = game_state
      landlord_hands = Poker.sort(Enum.at(game_hands, player_id) ++ Enum.at(game_hands, 3))
      # update the landlord hands and delete the leftover cards
      game_hands =
        List.replace_at(game_hands, player_id, landlord_hands)
        |> Enum.reverse()
        |> tl()
        |> Enum.reverse()

      game_state
      # specify the landlord
      |> Map.put(:landlord, player_id)
        # update phase
      |> Map.put(:phase, :card_play)
        # landlord start first
        # |> Map.put(:whose_turn, player_id)
        # update landlord hands
      |> Map.put(:hands, game_hands)
    end
  end

  def pass_landlord(game_state, player_id) when guard_player_id(player_id) do
    if game_state.phase === :call_landlord and game_state.whose_turn === player_id do
      %{landlord_call: game_landlord_call, whose_turn: game_whose_turn} = game_state
      # if the two previous players passed
      if game_landlord_call === 2 do
        # all three players gave up to be landlord, the game will start a new round
        start_new_round(game_state, Enum.random(0..2))
      else
        # this player pass, update the whose_turn
        game_state
        |> Map.put(:whose_turn, rem(game_whose_turn + 1, 3))
        |> Map.put(:landlord_call, game_landlord_call + 1)
      end
    end
  end


  @doc """
  Return winner id if the winner exist, return nil otherwise
  """
  def who_wins(%{phase: :card_play, hands: game_hands}) do
    winner =
      game_hands
      |> Enum.with_index()
      |> Enum.filter(fn {hand, _} -> length(hand) === 0 end)

    if winner === [] do
      nil
    else
      [{_, winner_id}] = winner
      winner_id
    end
  end

  # Start a new round
  def start_new_round(game_state, winner_id) when guard_player_id(winner_id) do
    points = calculate_score(game_state)

    game_state = game_state
                 |> Map.put(:points, points)

    new()
    |> Map.put(:whose_turn, winner_id)
    |> Map.put(:points, game_state.points)
    |> Map.put(:players, game_state.players)
  end

  defp calculate_score(game_state) do
    %{
      phase: game_phase,
      whose_turn: game_whose_turn,
      landlord: game_landlord,
      points: game_points,
      bomb_number: game_bomb_number
    } = game_state

    score =
      (@base_point * :math.pow(2, game_bomb_number))
      |> round()

    # this if is to fix a bug when no body call landlord, when we call
    # start_new_round, the points will be updated
    # this solution maybe not elegant
    if game_phase === :card_play do
      if game_landlord === game_whose_turn do
        game_points
        |> Enum.with_index()
        |> Enum.map(
             fn {point, index} ->
               if index === game_landlord do
                 point + score * 2
               else
                 point - score
               end
             end
           )
      else
        game_points
        |> Enum.with_index()
        |> Enum.map(
             fn {point, index} ->
               if index === game_landlord do
                 point - score * 2
               else
                 point + score
               end
             end
           )
      end
    else
      game_points
    end
  end

  defp play_cards_helper(game_state, player_id, cards) do
    current_hand = Enum.at(game_state.hands, player_id)
    current_hand = current_hand -- cards
    updated_hands = List.replace_at(game_state.hands, player_id, current_hand)

    game_state =
      game_state
      |> Map.put(:previous_play, {player_id, cards})
      |> Map.put(:hands, updated_hands)

    if is_nil(who_wins(game_state)) do
      game_state
      |> Map.put(:whose_turn, rem(game_state.whose_turn + 1, 3))
    else
      game_state
    end
  end

  @doc """
  Return nil if this play is illegal, otherwise return the new game_state
  """

  def play_cards(game_state, player_id, card_indexes)
      when guard_player_id(player_id) do
    if game_state.phase === :card_play and game_state.whose_turn === player_id do
      %{hands: game_hands, previous_play: game_previous_play, bomb_number: game_bomb_number} =
        game_state

      hand = Enum.at(game_hands, player_id)

      cards =
        retrieve_cards(
          hand
          |> Enum.with_index(),
          card_indexes,
          []
        )

      category = Poker.category_of_hands(cards)
      {game_previous_player, game_previous_cards} = game_previous_play
      new_game_state = game_state
      # if the cards are playable
      if !is_nil(category) do
        {{t, _}, _} = category

        # if player_id is the previous player who played cards or he/she is the first to play in this round
        # he/she can play any valid cards type
        if player_id === game_previous_player or game_previous_player === nil do
          new_game_state =
            if t === :bomb do
              new_game_state
              |> Map.put(:bomb_number, game_bomb_number + 1)
            else
              new_game_state
            end

          play_cards_helper(new_game_state, player_id, cards)
        else
          {cur_type, cur_weight} = category
          {prev_type, prev_weight} = Poker.category_of_hands(game_previous_cards)

          if Poker.is_first_beat_second?({cur_type, cur_weight}, {prev_type, prev_weight}) do
            new_game_state =
              if t === :bomb do
                new_game_state
                |> Map.put(:bomb_number, game_bomb_number + 1)
              else
                new_game_state
              end

            play_cards_helper(new_game_state, player_id, cards)
          end
        end
      end
    end
  end

  def pass(game_state, player_id) do
    if game_state.phase === :card_play and game_state.whose_turn === player_id do
      {previous_player, _} = game_state.previous_play
      # can't pass if the player is the previous player who played cards
      # can't pass if the player is the first one to play in this game
      if previous_player === player_id or previous_player === nil do
        nil
      else
        game_state
        |> Map.put(:whose_turn, rem(game_state.whose_turn + 1, 3))
      end
    end
  end

  defp retrieve_cards(_, [], acc) do
    Enum.reverse(acc)
  end

  # hands are list which has been passed to Enum.with_index
  defp retrieve_cards(hands, card_indexes, acc) do
    [head1 | tail1] = hands
    [head2 | tail2] = card_indexes
    {card, index} = head1

    if index === head2 do
      retrieve_cards(tail1, tail2, [card | acc])
    else
      retrieve_cards(tail1, card_indexes, acc)
    end
  end
end
