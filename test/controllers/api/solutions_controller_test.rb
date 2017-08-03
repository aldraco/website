require_relative './test_base'

class API::SolutionsControllerTest < API::TestBase
  test "latest should return 401 with incorrect token" do
    get latest_api_solutions_path, as: :json
    assert_response 401
  end

  test "latest should return 404 when there is no track" do
    setup_user
    exercise = create :exercise
    get latest_api_solutions_path(exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response 404
    expected = {error: "Track not found", fallback_url: tracks_url}
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "latest should return 404 when there is no exercise" do
    setup_user
    track = create :track
    get latest_api_solutions_path(track_id: track.slug), headers: @headers, as: :json
    assert_response 404
    expected = {error: "Exercise not found", fallback_url: track_url(track)}
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "index should return 404 when solution is missing" do
    setup_user
    track = create :track
    exercise = create :exercise, track: track

    get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json

    assert_response 404
  end

  test "latest should return 200 if user is solution_user" do
    setup_user
    exercise = create :exercise
    track = exercise.track
    solution = create :solution, user: @current_user, exercise: exercise
    create :user_track, user: solution.user, track: track

    get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response :success
  end

  test "latest should return 200 if user is mentor" do
    setup_user
    exercise = create :exercise
    track = exercise.track
    create :track_mentorship, user: @current_user, track: track
    solution = create :solution, exercise: exercise
    create :user_track, user: solution.user, track: track

    get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response :success
  end

  test "latest should return 200 if solution is published" do
    setup_user
    exercise = create :exercise
    track = exercise.track
    solution = create :solution, exercise: exercise, published_at: DateTime.yesterday
    create :user_track, user: solution.user, track: track

    get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response :success
  end

  test "latest should return 403 for a normal user when the solution is not published" do
    setup_user
    exercise = create :exercise
    track = exercise.track
    solution = create :solution, exercise: exercise
    create :user_track, user: solution.user, track: track

    get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json
    assert_response 403
  end

  test "latest should return solution when solution is unlocked" do
    setup_user
    exercise = create :exercise
    track = exercise.track
    solution = create :solution, user: @current_user, exercise: exercise

    expected = {foo: 'bar'}
    responder = mock(to_hash: expected)
    API::SolutionResponder.expects(:new).returns(responder)

    get latest_api_solutions_path(track_id: track.slug, exercise_id: exercise.slug), headers: @headers, as: :json

    assert_response :success
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal expected, actual
  end

  test "update should return 401 with incorrect token" do
    patch api_solution_path(1), headers: @headers, as: :json
    assert_response 401
  end

  test "update should 404 if the solution doesn't exist" do
    setup_user
    patch api_solution_path(999), headers: @headers, as: :json
    assert_response 404
  end

  test "update should 404 if the solution belongs to someone else" do
    setup_user
    solution = create :solution
    patch api_solution_path(solution.id), headers: @headers, as: :json
    assert_response 404
  end

  test "update should create iteration" do
    skip
    setup_user
    exercise = create :exercise
    track = exercise.track
    solution = create :solution, user: @current_user, exercise: exercise
    code = "Some code here"

    CreatesIteration.expects(:create!).with(solution, code)

    test_image = Rails.root / "app/assets/images/logo.png"
    info = Rack::Test::UploadedFile.new(__FILE__, "text/json")
    keys = ['file1', 'file2']
    file1 = Rack::Test::UploadedFile.new(__FILE__, "text/plain")
    file2 = Rack::Test::UploadedFile.new(__FILE__, "text/plain")

    patch api_solution_path(solution.id),
          params: {
            files_list: keys,
            keys[0] => file1, keys[1] => file2
          },
          headers: @headers,
          as: :json

    assert_response :success
  end
end
