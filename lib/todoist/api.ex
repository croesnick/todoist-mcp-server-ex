# lib/todoist_api.ex
defmodule TodoistMcpServer.Todoist.Api do
  @moduledoc """
  Module for interacting with the Todoist API.
  This module provides functions to manage tasks, projects, and other resources in Todoist.
  """

  use GenServer
  require Logger

  @base_url "https://api.todoist.com/api/v1"
  @tasks_url "#{@base_url}/tasks"

  @type get_tasks_request_params :: %{
          optional(:project_id) => String.t(),
          optional(:label) => String.t(),
          optional(:limit) => number()
        }

  @type task :: %{
          added_at: String.t(),
          added_by_uid: String.t(),
          assigned_by_uid: nil | String.t(),
          checked: boolean(),
          child_order: integer(),
          completed_at: nil | String.t(),
          content: String.t(),
          day_order: integer(),
          deadline: nil | String.t(),
          description: String.t(),
          due: nil | String.t(),
          duration: nil | integer() | float(),
          id: String.t(),
          is_collapsed: boolean(),
          is_deleted: boolean(),
          labels: list(String.t()),
          note_count: integer(),
          parent_id: nil | String.t(),
          priority: integer(),
          project_id: String.t(),
          responsible_uid: nil | String.t(),
          section_id: String.t(),
          updated_at: String.t(),
          user_id: String.t()
        }

  @type get_tasks_reponse :: list(task())

  @type state :: %{
          api_key: String.t()
        }

  @spec start_link(%{api_key: String.t()}) :: {:ok, pid()} | {:error, any()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def task_url(), do: "#{@tasks_url}"
  def task_url(task_id), do: "#{@tasks_url}/#{task_id}"

  def get_projects do
    GenServer.call(__MODULE__, :get_projects)
  end

  @spec get_tasks(get_tasks_request_params()) :: {:ok, list()} | {:error, String.t()}
  @spec get_tasks() :: {:error, binary()} | {:ok, list()}
  def get_tasks(params \\ %{}) do
    GenServer.call(__MODULE__, {:get_tasks, params})
  end

  def add_task(project_id, content, opts \\ []) do
    GenServer.call(__MODULE__, {:add_task, project_id, content, opts})
  end

  def edit_task(task_id, changes) do
    GenServer.call(__MODULE__, {:edit_task, task_id, changes})
  end

  def complete_task(task_id) do
    GenServer.call(__MODULE__, {:complete_task, task_id})
  end

  @impl true
  @spec init(%{api_key: String.t()}) :: {:ok, state()}
  def init(opts) do
    {:ok, opts}
  end

  @impl true
  @spec handle_call({:get_tasks, get_tasks_request_params()}, any(), state()) ::
          {:reply, {:ok, get_tasks_reponse()} | {:error, String.t()}, state()}
  def handle_call({:get_tasks, params}, _from, state) do
    response = Req.get!(@tasks_url, params: params, auth: {:bearer, state.api_key})

    if response.body["next_cursor"] != nil do
      Logger.warning("There's more than one page of tasks. Pagination is not implemented yet.")
    end

    {:reply, {:ok, response.body["results"]}, state}
  end

  @impl true
  def handle_call(:get_projects, _from, state) do
    # Get projects from Todoist
    {:reply, {:ok, []}, state}
  end

  @impl true
  def handle_call({:add_task, _project_id, _content, _opts}, _from, state) do
    # Add task to Todoist
    {:reply, {:ok, %{}}, state}
  end

  @impl true
  def handle_call({:edit_task, _task_id, _changes}, _from, state) do
    # Edit task in Todoist
    {:reply, {:ok, %{}}, state}
  end

  @impl true
  def handle_call({:complete_task, _task_id}, _from, state) do
    # Complete task in Todoist
    {:reply, {:ok, true}, state}
  end
end
