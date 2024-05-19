defmodule TestHelper.Nock do
  @moduledoc """
  I am a testing module that has some common definitions for nock
  functions.
  """

  import Nock

  @spec using_dec_core() :: Noun.t()
  def using_dec_core() do
    arm = Noun.Format.parse_always("[8 [9 342 0 1.023] 9 2 10 [6 0 14] 0 2]")
    sample = 999
    [arm, sample | logics_core()]
  end

  @spec using_sign_core() :: Noun.t()
  def using_sign_core() do
    arm =
      Noun.Format.parse_always("[8 [9 10 0 31] 9 2 10 [6 [0 28] 0 29] 0 2]")

    sample = [999 | 888]
    [arm, sample | logics_core()]
  end

  @spec using_verify_core() :: Noun.t()
  def using_verify_core() do
    arm =
      Noun.Format.parse_always("[8 [9 4 0 31] 9 2 10 [6 [0 28] 0 29] 0 2]")

    sample = [999 | 888]
    [arm, sample | logics_core()]
  end

  @spec using_sign_detatched_core() :: Noun.t()
  def using_sign_detatched_core() do
    arm =
      Noun.Format.parse_always("[8 [9 23 0 31] 9 2 10 [6 [0 28] 0 29] 0 2]")

    sample = [999 | 888]
    [arm, sample | logics_core()]
  end

  @spec using_verify_detatched_core() :: Noun.t()
  def using_verify_detatched_core() do
    arm =
      Noun.Format.parse_always(
        "[8 [9 22 0 31] 9 2 10 [6 [0 28] [0 58] 0 59] 0 2]"
      )

    sample = [999 | 888]
    [arm, sample | logics_core()]
  end

  @spec factorial() :: Noun.t()
  def factorial() do
    arm = Noun.Format.parse_always("
    [ 8
      [1 1 0]
      8
      [ 1
        6
        [5 [0 30] 1 0]
        [0 13]
        9
        2
        10
        [30 8 [9 342 0 4.095] 9 2 10 [6 0 62] 0 2]
        10
        [6 [8 [9 20 0 4.095] 9 2 10 [6 [0 29] 0 28] 0 2] 0 12]
        0
        1
      ]
      9
      2
      0
      1
    ]")
    sample = 1
    [arm, sample | logics_core()]
  end

  # TODO :: Add hoon code for this
  @spec increment_counter_val(Noun.t()) :: Noun.t()
  def increment_counter_val(val) do
    arm = [[1 | val], 4, 12, [1 | 0], [0 | 6], 1, val | 0]
    sample = 0
    [[8, [1 | sample], [1 | arm], 0 | 1] | logics_core()]
  end

  # [%ctr 0]
  def zero_counter(val) do
    arm = [1, val | 0]
    sample = 0
    [[8, [1 | sample], [1 | arm], 0 | 1] | logics_core()]
  end
end
